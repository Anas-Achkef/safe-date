create schema if not exists private;
create materialized view private.criterion_stats as
with rep as (select a.criterion_key, a.option_idx[1] as idx, count(*)::numeric as n
  from profile_answers a group by 1, 2),
tot as (select criterion_key, sum(n) as total, count(*) as modalites from rep group by 1)
select c.key as criterion_key, coalesce(t.total, 0)::int as reponses,
  case when t.total is null or t.total < 30 then 1.00
       when t.modalites <= 1 then 0.00
       else round((least(1.0, greatest(0.0,
         -sum(r.n / t.total * ln(r.n / t.total)) / ln(t.modalites))))::numeric, 3) end as entropie
from criteria c
left join tot t on t.criterion_key = c.key
left join rep r on r.criterion_key = c.key
group by c.key, t.total, t.modalites;
create unique index on private.criterion_stats (criterion_key);
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'service_role') then
    grant select on private.criterion_stats to service_role;
  end if;
end $$;
create or replace function private.answer_progress(u uuid)
returns table (onboarding_repondus int, onboarding_total int, quiz_repondus int,
  quiz_total int, paires_completes int, criteres_evaluables int)
language sql stable as $$
  select
    (select count(*)::int from profile_answers a join criteria c on c.key = a.criterion_key
      where a.user_id = u and c.moment = 'onboarding'),
    (select count(*)::int from criteria where moment = 'onboarding'),
    (select count(*)::int from profile_answers a join criteria c on c.key = a.criterion_key
      where a.user_id = u and c.moment = 'quiz'),
    (select count(*)::int from criteria where moment = 'quiz'),
    (select count(*)::int from criterion_pairs p
      where exists (select 1 from profile_answers where user_id = u and criterion_key = p.self_key)
        and exists (select 1 from profile_answers where user_id = u and criterion_key = p.pref_key)),
    (select count(*)::int from profile_answers where user_id = u);
$$;
create or replace function private.next_questions(u uuid, n int default 3)
returns table (criterion_key text, question text, moment collection_moment,
  grp score_group, priorite numeric, motif text)
language sql stable as $$
with autorises as (select c.* from criteria c
  where c.sensitive_category is null or has_consent(u, c.sensitive_category)),
restants as (select a.* from autorises a
  where not exists (select 1 from profile_answers pa
    where pa.user_id = u and pa.criterion_key = a.key)),
deficit as (select p.grp,
  1.0 + (count(*) filter (where not (
    exists (select 1 from profile_answers where user_id = u and criterion_key = p.self_key)
    and exists (select 1 from profile_answers where user_id = u and criterion_key = p.pref_key)
  )))::numeric / nullif(count(*), 0) as coef
  from criterion_pairs p group by p.grp),
demi_paires as (
  select p.self_key as k, p.pair_key from criterion_pairs p
  where exists (select 1 from profile_answers where user_id = u and criterion_key = p.pref_key)
  union all
  select p.pref_key, p.pair_key from criterion_pairs p
  where exists (select 1 from profile_answers where user_id = u and criterion_key = p.self_key)),
verrou as (select exists (select 1 from criteria c where c.moment = 'onboarding'
    and not exists (select 1 from profile_answers pa
      where pa.user_id = u and pa.criterion_key = c.key)) as inscription_incomplete)
select r.key, r.question, r.moment, p.grp,
  round(coalesce(s.entropie, 1.0) * (case when dp.k is not null then 2.0 else 1.0 end)
    * coalesce(d.coef, 1.0), 3) as priorite,
  case when r.moment = 'onboarding' then 'Critère obligatoire'
       when dp.k is not null then 'Complète une paire déjà entamée'
       when coalesce(s.entropie, 1.0) >= 0.9 then 'Critère fortement discriminant'
       else 'Comble le sous-score le moins documenté' end as motif
from restants r
join criterion_pairs p on p.self_key = r.key or p.pref_key = r.key
cross join verrou v
left join private.criterion_stats s on s.criterion_key = r.key
left join demi_paires dp on dp.k = r.key
left join deficit d on d.grp = p.grp
where r.moment <> 'backend'
  and (not v.inscription_incomplete or r.moment = 'onboarding')
order by (r.moment = 'onboarding') desc,
  case when r.moment = 'onboarding' then r.ord end asc, priorite desc, r.ord asc
limit n;
$$;
create or replace function private.submit_answer(u uuid, k text, idx smallint[])
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare n_opt int; multi boolean;
begin
  select count(*), bool_or(c.multi_select) into n_opt, multi
  from criterion_options o join criteria c on c.key = o.criterion_key
  where o.criterion_key = k;
  if n_opt = 0 then
    raise exception 'Critère inconnu : %', k using errcode = 'foreign_key_violation';
  end if;
  if array_length(idx, 1) is null or array_length(idx, 1) = 0 then
    raise exception 'Réponse vide pour le critère %', k using errcode = 'check_violation';
  end if;
  if not multi and array_length(idx, 1) > 1 then
    raise exception 'Le critère % n''accepte qu''une seule réponse', k using errcode = 'check_violation';
  end if;
  if exists (select 1 from unnest(idx) as i where i < 0 or i >= n_opt) then
    raise exception 'Option hors bornes pour le critère % (0 à %)', k, n_opt - 1 using errcode = 'check_violation';
  end if;
  insert into profile_answers (user_id, criterion_key, option_idx) values (u, k, idx)
  on conflict (user_id, criterion_key) do update
    set option_idx = excluded.option_idx, answered_at = now();
end $$;
create or replace function next_questions(n int default 3)
returns table (criterion_key text, question text, moment collection_moment,
  grp score_group, priorite numeric, motif text)
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.next_questions(auth.uid(), n);
end $$;
create or replace function answer_progress()
returns table (onboarding_repondus int, onboarding_total int, quiz_repondus int,
  quiz_total int, paires_completes int, criteres_evaluables int)
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.answer_progress(auth.uid());
end $$;;
