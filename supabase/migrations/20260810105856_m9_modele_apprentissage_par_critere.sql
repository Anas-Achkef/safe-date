-- =========================================================
-- M9.3 - Modele d'apprentissage par critere
-- Importance et confiance sont deux notions distinctes.
-- Un critere peut sembler tres important sur 3 observations :
-- l'importance est alors elevee, la confiance nulle.
-- =========================================================

insert into public.engine_params (key, value, description) values
  ('appr_lissage_confiance',      25,  'Nombre d''observations a partir duquel la confiance atteint la moitie de son maximum. Plus la valeur est haute, plus le systeme est prudent.'),
  ('appr_min_obs_option',          3,  'Observations minimales sur une option avant de la faire peser dans le calcul d''importance.'),
  ('appr_fenetre_recente',       200,  'Nombre de swipes les plus recents constituant la fenetre d''analyse de tendance.'),
  ('appr_seuil_derive',         0.20,  'Ecart entre taux global et taux recent au-dela duquel une evolution de preference est signalee.'),
  ('appr_criteres_sensibles',      0,  'Inclure les criteres sensibles (origine, religion, sante, orientation, genre, opinions) dans l''apprentissage comportemental. 0 = exclus. A ne passer a 1 qu''apres arbitrage juridique explicite.')
on conflict (key) do nothing;

-- ---------------------------------------------------------
-- 1. Statistiques par option observee
-- ---------------------------------------------------------
create table if not exists public.user_option_stats (
  user_id        uuid    not null references public.profiles(id) on delete cascade,
  criterion_key  text    not null,
  option_idx     smallint not null,
  observations   integer not null default 0,
  oui            integer not null default 0,
  poids          numeric not null default 0,
  poids_oui      numeric not null default 0,
  obs_recentes   integer not null default 0,
  oui_recents    integer not null default 0,
  derniere_vue   timestamptz,
  updated_at     timestamptz not null default now(),
  primary key (user_id, criterion_key, option_idx)
);
alter table public.user_option_stats enable row level security;

comment on table public.user_option_stats is
  'Compteurs bruts par option reellement observee. poids et poids_oui sont ponderes par le contexte du swipe et par l''attention accordee a la categorie concernee : un oui donne apres trente secondes sur la photo ne pese pas comme un oui donne sans l''avoir regardee.';

-- ---------------------------------------------------------
-- 2. Profil de preference par critere (§4.40)
-- ---------------------------------------------------------
create table if not exists public.user_criterion_profile (
  user_id        uuid not null references public.profiles(id) on delete cascade,
  criterion_key  text not null,
  grp            public.score_group,
  observations   integer not null default 0,
  taux_oui       numeric(5,4),
  taux_recent    numeric(5,4),
  importance     numeric(5,4),
  confiance      numeric(5,4),
  derive         boolean not null default false,
  updated_at     timestamptz not null default now(),
  primary key (user_id, criterion_key)
);
alter table public.user_criterion_profile enable row level security;

comment on table public.user_criterion_profile is
  'Ce que le moteur pense actuellement savoir, et a quel point il en est sur. Aucune ligne ne constitue une verite : importance et confiance doivent toujours etre lues ensemble.';
comment on column public.user_criterion_profile.importance is
  'Pouvoir discriminant du critere : mesure a quel point le taux d''acceptation varie selon les options. Un critere dont toutes les options obtiennent le meme taux n''influence rien, quel que soit ce taux.';
comment on column public.user_criterion_profile.confiance is
  'Fonction du volume d''observations. Cent pour cent de oui sur une observation donne une importance apparente maximale et une confiance quasi nulle.';
comment on column public.user_criterion_profile.derive is
  'Signale un ecart marque entre le comportement global et le comportement recent. Une preference ancienne ne doit pas primer sur un comportement actuel.';

create index if not exists user_criterion_profile_tri
  on public.user_criterion_profile (user_id, importance desc nulls last);

-- ---------------------------------------------------------
-- 3. Consolidation
-- ---------------------------------------------------------
create or replace function private.consolider_preferences(u uuid)
returns integer
language plpgsql set search_path = public, private as $$
declare
  v_fenetre int := private.engine_param('appr_fenetre_recente')::int;
  v_k       numeric := private.engine_param('appr_lissage_confiance');
  v_minobs  int := private.engine_param('appr_min_obs_option')::int;
  v_seuil   numeric := private.engine_param('appr_seuil_derive');
  v_sensibles boolean := private.engine_param('appr_criteres_sensibles') >= 1;
  n integer;
begin
  -- Chaque swipe est decompose en observations, une par option portee
  -- par le profil vu, ponderee par le contexte et par l'attention.
  with base as (
    select d.id, d.decision, d.contexte, d.target_id,
           d.attention_physique, d.attention_mode_vie, d.attention_valeurs,
           d.fiabilite_attention, d.criteres_exposes, d.created_at,
           row_number() over (order by d.created_at desc) as rang
    from public.swipe_decisions d
    where d.user_id = u
  ),
  obs as (
    select b.id, b.decision, b.rang, b.created_at,
           pa.criterion_key, o.idx as option_idx, cp.grp,
           -- Poids de contexte : un swipe de rencontre pese plus qu'un swipe d'apprentissage
           case when b.contexte = 'partir_en_date'
                then private.engine_param('poids_swipe_rencontre')
                else private.engine_param('poids_swipe_apprentissage') end
           *
           -- Modulation par l'attention, proportionnelle a la fiabilite de celle-ci.
           -- Sans donnee d'attention exploitable, aucune modulation n'est appliquee.
           greatest(0.1, least(2.5,
             case
               when b.fiabilite_attention is null or b.fiabilite_attention = 0 then 1.0
               else (1 - b.fiabilite_attention)
                    + b.fiabilite_attention * 3 * coalesce(
                        case cp.grp
                          when 'physique' then b.attention_physique
                          when 'mode_vie' then b.attention_mode_vie
                          when 'valeurs'  then b.attention_valeurs
                        end, 0.3333)
             end)) as poids
    from base b
    join public.profile_answers pa on pa.user_id = b.target_id
    join public.criteria c   on c.key = pa.criterion_key and c.direction = 'self'
    join public.criterion_pairs cp on cp.pair_key = c.pair_key
    cross join lateral unnest(pa.option_idx) as o(idx)
    where (v_sensibles or c.sensitive_category is null)
      -- Un critere non expose ne peut pas avoir influence la decision
      and (b.criteres_exposes is null or pa.criterion_key = any (b.criteres_exposes))
  ),
  cumul as (
    select criterion_key, option_idx,
           count(*)::int                              as observations,
           count(*) filter (where decision)::int      as oui,
           sum(poids)                                 as poids,
           sum(poids) filter (where decision)         as poids_oui,
           count(*) filter (where rang <= v_fenetre)::int as obs_recentes,
           count(*) filter (where rang <= v_fenetre and decision)::int as oui_recents,
           max(created_at)                            as derniere_vue
    from obs group by criterion_key, option_idx
  )
  insert into public.user_option_stats as t
    (user_id, criterion_key, option_idx, observations, oui, poids, poids_oui,
     obs_recentes, oui_recents, derniere_vue, updated_at)
  select u, criterion_key, option_idx, observations, oui, poids, poids_oui,
         obs_recentes, oui_recents, derniere_vue, now()
  from cumul
  on conflict (user_id, criterion_key, option_idx) do update set
    observations = excluded.observations, oui = excluded.oui,
    poids = excluded.poids, poids_oui = excluded.poids_oui,
    obs_recentes = excluded.obs_recentes, oui_recents = excluded.oui_recents,
    derniere_vue = excluded.derniere_vue, updated_at = now();

  -- Agregation par critere : importance = pouvoir discriminant
  with s as (
    select os.criterion_key, os.option_idx, os.observations, os.poids, os.poids_oui,
           os.obs_recentes, os.oui_recents,
           case when os.poids > 0 then os.poids_oui / os.poids end as taux_opt
    from public.user_option_stats os where os.user_id = u
  ),
  glob as (
    select criterion_key,
           sum(observations)::int as observations,
           case when sum(poids) > 0 then sum(poids_oui) / sum(poids) end as taux_oui,
           case when sum(obs_recentes) > 0
                then sum(oui_recents)::numeric / sum(obs_recentes) end as taux_recent
    from s group by criterion_key
  ),
  ecart as (
    select s.criterion_key,
           -- Moyenne des ecarts entre options, ponderee par leur volume.
           -- Ramenee sur 0..1 : un ecart moyen de 0,5 vaut deja un pouvoir
           -- discriminant maximal.
           least(1, 2 * sum(abs(s.taux_opt - g.taux_oui) * s.poids)
                       / nullif(sum(s.poids), 0)) as importance
    from s join glob g on g.criterion_key = s.criterion_key
    where s.observations >= v_minobs and s.taux_opt is not null and g.taux_oui is not null
    group by s.criterion_key
  )
  insert into public.user_criterion_profile as p
    (user_id, criterion_key, grp, observations, taux_oui, taux_recent,
     importance, confiance, derive, updated_at)
  select u, g.criterion_key, cp.grp, g.observations,
         round(g.taux_oui, 4), round(g.taux_recent, 4),
         round(coalesce(e.importance, 0), 4),
         round(g.observations / (g.observations + v_k), 4),
         coalesce(abs(g.taux_recent - g.taux_oui) >= v_seuil, false),
         now()
  from glob g
  left join ecart e on e.criterion_key = g.criterion_key
  left join public.criteria c on c.key = g.criterion_key
  left join public.criterion_pairs cp on cp.pair_key = c.pair_key
  on conflict (user_id, criterion_key) do update set
    grp = excluded.grp, observations = excluded.observations,
    taux_oui = excluded.taux_oui, taux_recent = excluded.taux_recent,
    importance = excluded.importance, confiance = excluded.confiance,
    derive = excluded.derive, updated_at = now();

  get diagnostics n = row_count;
  return n;
end $$;

comment on function private.consolider_preferences is
  'Recalcul complet et idempotent pour un utilisateur. L''importance mesure la variation du taux d''acceptation entre les options d''un meme critere, pas le taux lui-meme : quatre-vingt-dix pour cent de oui sur toutes les options signifie que le critere ne discrimine rien.';

-- ---------------------------------------------------------
-- 4. Lecture (§4.40)
-- ---------------------------------------------------------
create or replace function private.profil_preferences(u uuid, p_min_conf numeric default 0)
returns table (criterion_key text, libelle text, grp public.score_group,
               observations integer, taux_oui numeric, importance numeric,
               confiance numeric, derive boolean)
language sql stable set search_path = public, private as $$
  select p.criterion_key, c.question, p.grp, p.observations,
         p.taux_oui, p.importance, p.confiance, p.derive
  from public.user_criterion_profile p
  left join public.criteria c on c.key = p.criterion_key
  where p.user_id = u and p.confiance >= p_min_conf
  order by p.importance desc nulls last, p.observations desc;
$$;

create or replace function public.profil_preferences(min_confiance numeric default 0)
returns table (criterion_key text, libelle text, grp public.score_group,
               observations integer, taux_oui numeric, importance numeric,
               confiance numeric, derive boolean)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.profil_preferences(auth.uid(), min_confiance);
end $$;

revoke all on function public.profil_preferences(numeric) from public;
grant execute on function public.profil_preferences(numeric) to authenticated;;
