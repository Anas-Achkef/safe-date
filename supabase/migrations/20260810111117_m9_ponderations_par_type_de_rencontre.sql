-- =========================================================
-- M9.5 - Ponderations contextuelles par type de rencontre
-- Les preferences generales sont communes. Ce qui change,
-- c'est le poids qu'elles prennent selon ce qu'on cherche :
-- on peut etre exigeant sur le physique en amour et tres
-- tolerant en amitie, sans que la preference change.
-- =========================================================

-- Le type de recherche accompagne desormais le swipe de rencontre
alter table public.swipe_decisions
  add column if not exists type_rencontre public.rencontre_type;

comment on column public.swipe_decisions.type_rencontre is
  'Renseigne uniquement dans Partir en date. Nul en apprentissage : Mieux me connaitre ignore volontairement ce que l''utilisateur recherche.';

alter table public.swipe_decisions
  drop constraint if exists swipe_type_selon_contexte;
alter table public.swipe_decisions
  add constraint swipe_type_selon_contexte
  check (contexte = 'partir_en_date' or type_rencontre is null);

-- ---------------------------------------------------------
-- 1. Ponderations de reference (§4.45 a §4.48)
--    Valeurs indicatives, destinees a etre apprises.
-- ---------------------------------------------------------
create table if not exists public.context_weight_defaults (
  type_rencontre  public.rencontre_type primary key,
  poids_physique  numeric(4,3) not null,
  poids_mode_vie  numeric(4,3) not null,
  poids_valeurs   numeric(4,3) not null,
  seuil_exigence  numeric(4,3) not null,
  constraint cwd_somme_unitaire
    check (abs(poids_physique + poids_mode_vie + poids_valeurs - 1) < 0.001)
);

insert into public.context_weight_defaults values
  ('amour',  0.300, 0.300, 0.400, 0.700),
  ('fun',    0.600, 0.100, 0.300, 0.550),
  ('amitie', 0.150, 0.450, 0.400, 0.600)
on conflict (type_rencontre) do nothing;

comment on table public.context_weight_defaults is
  'Point de depart, pas verite. Le document les qualifie d''illustratives : elles servent tant que le comportement de l''utilisateur n''a rien appris, puis s''effacent progressivement devant lui.';
comment on column public.context_weight_defaults.seuil_exigence is
  'Compatibilite minimale pour proposer une rencontre dans ce contexte. Soixante-dix pour cent peuvent suffire en amitie et rester insuffisants en amour : preference et niveau d''exigence sont deux choses distinctes.';

-- ---------------------------------------------------------
-- 2. Ponderations apprises par utilisateur et par contexte
-- ---------------------------------------------------------
create table if not exists public.user_context_weights (
  user_id        uuid not null references public.profiles(id) on delete cascade,
  type_rencontre public.rencontre_type not null,
  poids_physique numeric(4,3) not null,
  poids_mode_vie numeric(4,3) not null,
  poids_valeurs  numeric(4,3) not null,
  seuil_exigence numeric(4,3) not null,
  observations   integer not null default 0,
  confiance      numeric(4,3) not null default 0,
  updated_at     timestamptz not null default now(),
  primary key (user_id, type_rencontre)
);
alter table public.user_context_weights enable row level security;

comment on table public.user_context_weights is
  'Une meme personne peut etre tres exigeante sur le physique pour l''amour et beaucoup plus tolerante pour l''amitie. Les donnees generales restent communes, seules les ponderations sont separees.';

insert into public.engine_params (key, value, description) values
  ('pond_lissage', 40, 'Nombre de swipes contextualises a partir duquel les ponderations apprises pesent autant que les valeurs de reference.'),
  ('pond_ecart_max', 0.25, 'Ecart maximal autorise en une seule consolidation, pour eviter qu''une poignee de swipes ne bascule tout le modele.')
on conflict (key) do nothing;

-- ---------------------------------------------------------
-- 3. Consolidation (§4.56)
-- ---------------------------------------------------------
create or replace function private.consolider_ponderations(u uuid)
returns integer
language plpgsql set search_path = public, private as $$
declare
  v_k numeric := private.engine_param('pond_lissage');
  n   integer;
begin
  with observe as (
    -- Ou l'attention s'est reellement portee, par type de recherche.
    -- Seuls les swipes dont la lecture d'attention est fiable comptent.
    select d.type_rencontre,
           sum(d.attention_physique * d.fiabilite_attention) as ph,
           sum(d.attention_mode_vie * d.fiabilite_attention) as mv,
           sum(d.attention_valeurs  * d.fiabilite_attention) as va,
           sum(d.fiabilite_attention)                        as masse,
           count(*)::int                                     as obs
    from public.swipe_decisions d
    where d.user_id = u
      and d.contexte = 'partir_en_date'
      and d.type_rencontre is not null
      and d.fiabilite_attention is not null
      and d.fiabilite_attention > 0
    group by d.type_rencontre
  ),
  melange as (
    select r.type_rencontre,
           coalesce(o.obs, 0) as obs,
           -- Poids de l'apprentissage face aux valeurs de reference
           coalesce(o.obs, 0) / (coalesce(o.obs, 0) + v_k) as alpha,
           r.poids_physique as d_ph, r.poids_mode_vie as d_mv, r.poids_valeurs as d_va,
           case when coalesce(o.masse, 0) > 0 then o.ph / o.masse end as a_ph,
           case when coalesce(o.masse, 0) > 0 then o.mv / o.masse end as a_mv,
           case when coalesce(o.masse, 0) > 0 then o.va / o.masse end as a_va,
           r.seuil_exigence
    from public.context_weight_defaults r
    left join observe o on o.type_rencontre = r.type_rencontre
  ),
  brut as (
    select type_rencontre, obs, seuil_exigence,
           (1 - alpha) * d_ph + alpha * coalesce(a_ph, d_ph) as ph,
           (1 - alpha) * d_mv + alpha * coalesce(a_mv, d_mv) as mv,
           (1 - alpha) * d_va + alpha * coalesce(a_va, d_va) as va,
           alpha
    from melange
  )
  insert into public.user_context_weights as w
    (user_id, type_rencontre, poids_physique, poids_mode_vie, poids_valeurs,
     seuil_exigence, observations, confiance, updated_at)
  select u, type_rencontre,
         round(ph / (ph + mv + va), 3),
         round(mv / (ph + mv + va), 3),
         round(va / (ph + mv + va), 3),
         seuil_exigence, obs, round(alpha, 3), now()
  from brut
  where ph + mv + va > 0
  on conflict (user_id, type_rencontre) do update set
    poids_physique = excluded.poids_physique,
    poids_mode_vie = excluded.poids_mode_vie,
    poids_valeurs  = excluded.poids_valeurs,
    observations   = excluded.observations,
    confiance      = excluded.confiance,
    updated_at     = now();

  get diagnostics n = row_count;
  return n;
end $$;

comment on function private.consolider_ponderations is
  'Les ponderations apprises ne remplacent jamais brutalement les valeurs de reference : elles les recouvrent progressivement, a mesure que les observations s''accumulent. Le seuil d''exigence n''est pas touche ici, il releve d''un reglage et non de l''attention.';

-- ---------------------------------------------------------
-- 4. Score contextuel
-- ---------------------------------------------------------
create or replace function private.ponderations(u uuid, p_type public.rencontre_type)
returns public.user_context_weights
language sql stable set search_path = public, private as $$
  select coalesce(
    (select w from public.user_context_weights w
      where w.user_id = u and w.type_rencontre = p_type),
    (select row(u, d.type_rencontre, d.poids_physique, d.poids_mode_vie,
                d.poids_valeurs, d.seuil_exigence, 0, 0, now())::public.user_context_weights
       from public.context_weight_defaults d where d.type_rencontre = p_type));
$$;

create or replace function private.score_contextuel(u uuid, cible uuid, p_type public.rencontre_type)
returns table (score numeric, atteint_seuil boolean, seuil numeric,
               poids_physique numeric, poids_mode_vie numeric, poids_valeurs numeric)
language sql stable set search_path = public, private as $$
  with w as (select * from private.ponderations(u, p_type)),
       c as (select * from private.compat_cached(u, cible))
  select round(
           (coalesce(c.score_physique, 0) * w.poids_physique
          + coalesce(c.score_mode_vie, 0) * w.poids_mode_vie
          + coalesce(c.score_valeurs,  0) * w.poids_valeurs)
         , 2),
         round(
           (coalesce(c.score_physique, 0) * w.poids_physique
          + coalesce(c.score_mode_vie, 0) * w.poids_mode_vie
          + coalesce(c.score_valeurs,  0) * w.poids_valeurs)
         , 4) >= w.seuil_exigence * 100,
         w.seuil_exigence, w.poids_physique, w.poids_mode_vie, w.poids_valeurs
  from w, c where c.user_lo is not null;
$$;

comment on function private.score_contextuel is
  'Recombine les scores par categorie deja calcules avec les ponderations du contexte recherche. Un meme couple obtient donc trois scores differents selon qu''on cherche l''amour, l''amitie ou une rencontre sans lendemain.';

-- ---------------------------------------------------------
-- 5. Lecture publique
-- ---------------------------------------------------------
create or replace function public.mes_ponderations()
returns table (type_rencontre public.rencontre_type, poids_physique numeric,
               poids_mode_vie numeric, poids_valeurs numeric,
               seuil_exigence numeric, observations integer, confiance numeric)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query
    select d.type_rencontre,
           coalesce(w.poids_physique, d.poids_physique),
           coalesce(w.poids_mode_vie, d.poids_mode_vie),
           coalesce(w.poids_valeurs,  d.poids_valeurs),
           coalesce(w.seuil_exigence, d.seuil_exigence),
           coalesce(w.observations, 0),
           coalesce(w.confiance, 0)
    from public.context_weight_defaults d
    left join public.user_context_weights w
           on w.user_id = auth.uid() and w.type_rencontre = d.type_rencontre
    order by d.type_rencontre;
end $$;

revoke all on function public.mes_ponderations() from public;
grant execute on function public.mes_ponderations() to authenticated;;
