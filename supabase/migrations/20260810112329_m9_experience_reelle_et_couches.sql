-- =========================================================
-- M9.7 - Experience reelle, hierarchie des signaux, couches
--
-- Un swipe est une intention. Une acceptation de rendez-vous
-- est une decision. Un retour apres la rencontre est une
-- observation. Les trois ne se valent pas et ne doivent
-- jamais etre melanges.
-- =========================================================

insert into public.engine_params (key, value, description) values
  ('sig_niveau1_appr',     1.0, 'Poids du signal : swipe dans Mieux me connaitre. Interet general.'),
  ('sig_niveau2_date',     2.5, 'Poids du signal : swipe dans Partir en date. Interet dans un contexte reel de recherche.'),
  ('sig_niveau3_vecu',     6.0, 'Poids du signal : retour apres le rendez-vous. Experience reellement vecue.'),
  ('sig_niveau4_suite',    8.0, 'Poids du signal : souhait de poursuivre apres la rencontre.'),
  ('sig_niveau5_nouveau', 10.0, 'Poids du signal : nouveau rendez-vous organise. Interet reel confirme par les actes.'),
  ('exp_echelle_max',      5.0, 'Valeur maximale de l''echelle des retours post-rendez-vous.'),
  ('exp_lissage',          8.0, 'Nombre de rencontres a partir duquel le pouvoir predictif d''un critere devient credible. Volontairement bas : une rencontre reelle vaut beaucoup de swipes.')
on conflict (key) do nothing;

-- ---------------------------------------------------------
-- Couche D et E : ce qui fonctionne reellement
-- Tenue separee de user_criterion_profile, qui porte
-- l'attraction. Les fusionner ferait perdre l'essentiel.
-- ---------------------------------------------------------
create table if not exists public.user_criterion_outcome (
  user_id           uuid not null references public.profiles(id) on delete cascade,
  criterion_key     text not null,
  rencontres        integer not null default 0,
  satisfaction_moy  numeric(5,4),
  poursuites        integer not null default 0,
  taux_poursuite    numeric(5,4),
  pouvoir_predictif numeric(6,4),
  confiance         numeric(5,4),
  updated_at        timestamptz not null default now(),
  primary key (user_id, criterion_key)
);
alter table public.user_criterion_outcome enable row level security;

comment on table public.user_criterion_outcome is
  'Couches D et E : ce que les rencontres reelles ont appris. Volontairement distincte de user_criterion_profile, qui porte l''attraction. Un critere peut attirer fortement et ne rien predire de la qualite du moment passe ensemble.';
comment on column public.user_criterion_outcome.pouvoir_predictif is
  'Ecart entre la satisfaction obtenue avec les personnes portant ce critere et la satisfaction moyenne de l''utilisateur. Positif : le critere annonce de bonnes rencontres. Negatif : il attire sans tenir ses promesses.';

-- ---------------------------------------------------------
-- Consolidation de l'experience vecue
-- ---------------------------------------------------------
create or replace function private.consolider_experience(u uuid)
returns integer
language plpgsql set search_path = public, private as $$
declare
  v_max numeric := private.engine_param('exp_echelle_max');
  v_k   numeric := private.engine_param('exp_lissage');
  v_ref numeric;
  n integer;
begin
  -- Rencontres terminees pour lesquelles l'utilisateur a laisse un retour
  with vecu as (
    select d.id as date_id,
           case when d.user_a = u then d.user_b else d.user_a end as partenaire,
           least(1, greatest(0,
             (coalesce(r.attirance, 0) + coalesce(r.valeurs, 0) + coalesce(r.mode_vie, 0))
             / nullif(3 * v_max, 0))) as satisfaction,
           (f.decision = 'oui') as poursuite
    from public.dates d
    join public.date_reviews r on r.date_id = d.id and r.user_id = u
    left join public.date_followups f on f.date_id = d.id and f.user_id = u
    where (d.user_a = u or d.user_b = u)
      and d.status = 'termine'
  )
  select avg(satisfaction) into v_ref from vecu;

  if v_ref is null then
    return 0;   -- aucune rencontre notee : rien a apprendre
  end if;

  with vecu as (
    select d.id as date_id,
           case when d.user_a = u then d.user_b else d.user_a end as partenaire,
           least(1, greatest(0,
             (coalesce(r.attirance, 0) + coalesce(r.valeurs, 0) + coalesce(r.mode_vie, 0))
             / nullif(3 * v_max, 0))) as satisfaction,
           coalesce(f.decision = 'oui', false) as poursuite
    from public.dates d
    join public.date_reviews r on r.date_id = d.id and r.user_id = u
    left join public.date_followups f on f.date_id = d.id and f.user_id = u
    where (d.user_a = u or d.user_b = u) and d.status = 'termine'
  ),
  porte as (
    select v.date_id, v.satisfaction, v.poursuite, pa.criterion_key
    from vecu v
    join public.profile_answers pa on pa.user_id = v.partenaire
    join public.criteria c on c.key = pa.criterion_key and c.direction = 'self'
    where (private.engine_param('appr_criteres_sensibles') >= 1 or c.sensitive_category is null)
  ),
  agg as (
    select criterion_key,
           count(*)::int as rencontres,
           avg(satisfaction) as satisfaction_moy,
           count(*) filter (where poursuite)::int as poursuites,
           avg(case when poursuite then 1 else 0 end) as taux_poursuite
    from porte group by criterion_key
  )
  insert into public.user_criterion_outcome as t
    (user_id, criterion_key, rencontres, satisfaction_moy, poursuites,
     taux_poursuite, pouvoir_predictif, confiance, updated_at)
  select u, criterion_key, rencontres,
         round(satisfaction_moy, 4), poursuites, round(taux_poursuite, 4),
         -- Ecart a la satisfaction moyenne, tempere par le volume de rencontres
         round((satisfaction_moy - v_ref) * (rencontres / (rencontres + v_k)), 4),
         round(rencontres / (rencontres + v_k), 4),
         now()
  from agg
  on conflict (user_id, criterion_key) do update set
    rencontres = excluded.rencontres,
    satisfaction_moy = excluded.satisfaction_moy,
    poursuites = excluded.poursuites,
    taux_poursuite = excluded.taux_poursuite,
    pouvoir_predictif = excluded.pouvoir_predictif,
    confiance = excluded.confiance,
    updated_at = now();

  get diagnostics n = row_count;
  return n;
end $$;

comment on function private.consolider_experience is
  'Le retour post-rendez-vous ne modifie jamais la preference generale : il alimente une couche distincte. Un critere peut rester tres attirant tout en cessant d''etre recommande, sans que l''utilisateur ait a se dedire.';

-- ---------------------------------------------------------
-- Attraction contre reussite reelle (§4.62, §4.66)
-- ---------------------------------------------------------
create or replace function private.attraction_vs_reussite(u uuid)
returns table (criterion_key text, libelle text,
               attraction numeric, importance numeric,
               satisfaction numeric, rencontres integer,
               pouvoir_predictif numeric, verdict text)
language sql stable set search_path = public, private as $$
  select p.criterion_key, c.question,
         p.taux_oui, p.importance,
         o.satisfaction_moy, coalesce(o.rencontres, 0), o.pouvoir_predictif,
         case
           when o.rencontres is null or o.rencontres = 0 then 'jamais eprouve'
           when o.confiance < 0.4                        then 'trop peu de rencontres'
           when p.taux_oui >= 0.65 and o.pouvoir_predictif <= -0.05
             then 'attire mais ne tient pas ses promesses'
           when p.taux_oui <= 0.40 and o.pouvoir_predictif >= 0.05
             then 'sous-estime : fonctionne mieux que prevu'
           when o.pouvoir_predictif >= 0.05              then 'confirme par le vecu'
           else 'sans effet mesurable'
         end
  from public.user_criterion_profile p
  left join public.user_criterion_outcome o
         on o.user_id = p.user_id and o.criterion_key = p.criterion_key
  left join public.criteria c on c.key = p.criterion_key
  where p.user_id = u
  order by coalesce(abs(o.pouvoir_predictif), 0) desc, p.importance desc nulls last;
$$;

comment on function private.attraction_vs_reussite is
  'Confronte ce qui donne envie de dire oui a ce qui produit reellement de bons moments. Les deux verdicts les plus precieux sont les dissonances : un critere tres attirant sans effet reel, et un critere neglige qui fonctionne.';

-- ---------------------------------------------------------
-- Poids d'un signal selon son niveau (§4.61)
-- ---------------------------------------------------------
create or replace function private.poids_signal(p_niveau smallint)
returns numeric
language sql stable set search_path = public, private as $$
  select case p_niveau
    when 1 then private.engine_param('sig_niveau1_appr')
    when 2 then private.engine_param('sig_niveau2_date')
    when 3 then private.engine_param('sig_niveau3_vecu')
    when 4 then private.engine_param('sig_niveau4_suite')
    when 5 then private.engine_param('sig_niveau5_nouveau')
    else 1.0 end;
$$;

comment on function private.poids_signal is
  'Hierarchie des signaux : une intention pese moins qu''une decision, qui pese moins qu''une experience vecue, qui pese moins qu''une suite donnee a cette experience.';

-- ---------------------------------------------------------
-- Consolidation complete d'un utilisateur
-- ---------------------------------------------------------
create or replace function private.consolider_utilisateur(u uuid)
returns jsonb
language plpgsql set search_path = public, private as $$
begin
  return jsonb_build_object(
    'criteres',     private.consolider_preferences(u),
    'ponderations', private.consolider_ponderations(u),
    'experience',   private.consolider_experience(u),
    'consolide_a',  now());
end $$;

-- ---------------------------------------------------------
-- Lectures publiques
-- ---------------------------------------------------------
create or replace function public.attraction_vs_reussite()
returns table (criterion_key text, libelle text, attraction numeric, importance numeric,
               satisfaction numeric, rencontres integer, pouvoir_predictif numeric, verdict text)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.attraction_vs_reussite(auth.uid());
end $$;

revoke all on function public.attraction_vs_reussite() from public;
grant execute on function public.attraction_vs_reussite() to authenticated;;
