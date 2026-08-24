-- =========================================================
-- M9.7b - L'experience vecue se mesure par option
-- Agreger par critere revenait a moyenner ensemble les
-- personnes qui plaisent et celles qui ne plaisent pas :
-- l'ecart s'annulait exactement.
-- =========================================================

drop table if exists public.user_criterion_outcome;

create table public.user_option_outcome (
  user_id           uuid not null references public.profiles(id) on delete cascade,
  criterion_key     text not null,
  option_idx        smallint not null,
  rencontres        integer not null default 0,
  satisfaction_moy  numeric(5,4),
  poursuites        integer not null default 0,
  taux_poursuite    numeric(5,4),
  pouvoir_predictif numeric(6,4),
  confiance         numeric(5,4),
  updated_at        timestamptz not null default now(),
  primary key (user_id, criterion_key, option_idx)
);
alter table public.user_option_outcome enable row level security;

comment on table public.user_option_outcome is
  'Couches D et E, a la meme granularite que l''attraction : par option. Mesurer au niveau du critere reviendrait a moyenner ensemble les profils appreciez et les autres, ce qui annule precisement l''ecart que l''on cherche.';
comment on column public.user_option_outcome.pouvoir_predictif is
  'Ecart entre la satisfaction obtenue avec les personnes portant cette option et la satisfaction moyenne de l''utilisateur. Positif : l''option annonce de bonnes rencontres. Negatif : elle attire sans tenir ses promesses.';

create or replace function private.consolider_experience(u uuid)
returns integer
language plpgsql set search_path = public, private as $$
declare
  v_max numeric := private.engine_param('exp_echelle_max');
  v_k   numeric := private.engine_param('exp_lissage');
  v_ref numeric;
  n integer;
begin
  create temp table if not exists _vecu (
    date_id uuid, partenaire uuid, satisfaction numeric, poursuite boolean
  ) on commit drop;
  delete from _vecu;

  insert into _vecu
  select d.id,
         case when d.user_a = u then d.user_b else d.user_a end,
         least(1, greatest(0,
           (coalesce(r.attirance, 0) + coalesce(r.valeurs, 0) + coalesce(r.mode_vie, 0))
           / nullif(3 * v_max, 0))),
         coalesce(f.decision = 'oui', false)
  from public.dates d
  join public.date_reviews r on r.date_id = d.id and r.user_id = u
  left join public.date_followups f on f.date_id = d.id and f.user_id = u
  where (d.user_a = u or d.user_b = u) and d.status = 'termine';

  select avg(satisfaction) into v_ref from _vecu;
  if v_ref is null then return 0; end if;

  with porte as (
    select v.satisfaction, v.poursuite, pa.criterion_key, o.idx as option_idx
    from _vecu v
    join public.profile_answers pa on pa.user_id = v.partenaire
    join public.criteria c on c.key = pa.criterion_key and c.direction = 'self'
    cross join lateral unnest(pa.option_idx) as o(idx)
    where (private.engine_param('appr_criteres_sensibles') >= 1 or c.sensitive_category is null)
  ),
  agg as (
    select criterion_key, option_idx,
           count(*)::int as rencontres,
           avg(satisfaction) as satisfaction_moy,
           count(*) filter (where poursuite)::int as poursuites,
           avg(case when poursuite then 1 else 0 end) as taux_poursuite
    from porte group by criterion_key, option_idx
  )
  insert into public.user_option_outcome as t
    (user_id, criterion_key, option_idx, rencontres, satisfaction_moy,
     poursuites, taux_poursuite, pouvoir_predictif, confiance, updated_at)
  select u, criterion_key, option_idx, rencontres,
         round(satisfaction_moy, 4), poursuites, round(taux_poursuite, 4),
         round((satisfaction_moy - v_ref) * (rencontres / (rencontres + v_k)), 4),
         round(rencontres / (rencontres + v_k), 4), now()
  from agg
  on conflict (user_id, criterion_key, option_idx) do update set
    rencontres = excluded.rencontres, satisfaction_moy = excluded.satisfaction_moy,
    poursuites = excluded.poursuites, taux_poursuite = excluded.taux_poursuite,
    pouvoir_predictif = excluded.pouvoir_predictif, confiance = excluded.confiance,
    updated_at = now();

  get diagnostics n = row_count;
  return n;
end $$;

comment on function private.consolider_experience is
  'Le retour post-rendez-vous ne modifie jamais la preference generale : il alimente une couche distincte. Une option peut rester tres attirante tout en cessant d''etre recommandee, sans que l''utilisateur ait a se dedire.';

drop function if exists private.attraction_vs_reussite(uuid);
drop function if exists public.attraction_vs_reussite();

create function private.attraction_vs_reussite(u uuid)
returns table (criterion_key text, option_idx smallint, libelle text,
               attraction numeric, satisfaction numeric, rencontres integer,
               pouvoir_predictif numeric, verdict text)
language sql stable set search_path = public, private as $$
  select s.criterion_key, s.option_idx, o.label,
         round(case when s.poids > 0 then s.poids_oui / s.poids end, 4),
         e.satisfaction_moy, coalesce(e.rencontres, 0), e.pouvoir_predictif,
         case
           when e.rencontres is null or e.rencontres = 0 then 'jamais eprouve'
           when e.confiance < 0.35                       then 'trop peu de rencontres'
           when s.poids_oui / nullif(s.poids, 0) >= 0.65 and e.pouvoir_predictif <= -0.03
             then 'attire mais ne tient pas ses promesses'
           when s.poids_oui / nullif(s.poids, 0) <= 0.40 and e.pouvoir_predictif >= 0.03
             then 'sous-estime : fonctionne mieux que prevu'
           when e.pouvoir_predictif >= 0.03              then 'confirme par le vecu'
           else 'sans effet mesurable'
         end
  from public.user_option_stats s
  left join public.user_option_outcome e
         on e.user_id = s.user_id and e.criterion_key = s.criterion_key
        and e.option_idx = s.option_idx
  left join public.criterion_options o
         on o.criterion_key = s.criterion_key and o.idx = s.option_idx
  where s.user_id = u
  order by coalesce(abs(e.pouvoir_predictif), 0) desc, s.observations desc;
$$;

comment on function private.attraction_vs_reussite is
  'Confronte ce qui donne envie de dire oui a ce qui produit reellement de bons moments. Les deux verdicts les plus precieux sont les dissonances : une option tres attirante sans effet reel, et une option negligee qui fonctionne.';

create function public.attraction_vs_reussite()
returns table (criterion_key text, option_idx smallint, libelle text,
               attraction numeric, satisfaction numeric, rencontres integer,
               pouvoir_predictif numeric, verdict text)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.attraction_vs_reussite(auth.uid());
end $$;

revoke all on function public.attraction_vs_reussite() from public;
grant execute on function public.attraction_vs_reussite() to authenticated;;
