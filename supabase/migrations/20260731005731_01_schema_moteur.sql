create schema if not exists private;
revoke all on schema private from public;
create type criterion_direction as enum ('self', 'pref');
create type collection_moment as enum ('onboarding', 'quiz', 'backend');
create type match_type as enum ('aligne', 'mapping', 'importance', 'repoussoir', 'echelle');
create type score_group as enum ('physique', 'valeurs', 'mode_vie');
create table criteria (
  key text primary key, ord smallint not null unique, moment collection_moment not null,
  category text not null, subcategory text not null, cluster text,
  direction criterion_direction not null, pair_key text not null, question text not null,
  multi_select boolean not null default false);
create index on criteria (pair_key);
create index on criteria (moment);
create table criterion_options (
  criterion_key text not null references criteria(key) on delete cascade,
  idx smallint not null check (idx between 0 and 14), label text not null,
  is_neutral boolean not null default false, primary key (criterion_key, idx));
create table criterion_pairs (
  pair_key text primary key, slot smallint not null unique check (slot between 0 and 132),
  self_key text not null references criteria(key), pref_key text not null references criteria(key),
  category text not null, cluster text, grp score_group not null, match_type match_type not null,
  is_absolute boolean not null default false, base_weight numeric(4,2) not null default 1.00,
  mapping_validated boolean not null default false);
create table option_mappings (
  pair_key text not null references criterion_pairs(pair_key) on delete cascade,
  pref_idx smallint not null, accepted_self_idx smallint[] not null default '{}',
  weight_multiplier numeric(3,2) not null default 1.00 check (weight_multiplier >= 0),
  tolerance smallint, primary key (pair_key, pref_idx));
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(), birth_date date not null,
  age_min smallint not null default 18 check (age_min >= 18), age_max smallint not null default 99,
  search_radius_km smallint not null default 25, last_location geography(point, 4326),
  is_verified boolean not null default false, is_active boolean not null default true);
create table profile_answers (
  user_id uuid not null references profiles(id) on delete cascade,
  criterion_key text not null references criteria(key), option_idx smallint[] not null,
  answered_at timestamptz not null default now(), primary key (user_id, criterion_key));
create index on profile_answers (user_id);
create table profile_vectors (
  user_id uuid primary key references profiles(id) on delete cascade,
  self_mask int[] not null, pref_mask int[] not null, weight_mul numeric[] not null,
  answered_self smallint not null default 0, answered_pref smallint not null default 0,
  refreshed_at timestamptz not null default now());
create or replace function private.refresh_profile_vectors(u uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_self int[] := array_fill(null::int, array[133]);
  v_pref int[] := array_fill(null::int, array[133]);
  v_wm numeric[] := array_fill(1.0::numeric, array[133]);
  n_self smallint := 0; n_pref smallint := 0; r record;
begin
  for r in select p.slot, a.option_idx from criterion_pairs p
    join profile_answers a on a.criterion_key = p.self_key and a.user_id = u
  loop
    v_self[r.slot + 1] := (select coalesce(sum(1 << i), 0)::int from unnest(r.option_idx) as i);
    n_self := n_self + 1;
  end loop;
  for r in select p.slot, p.match_type, a.option_idx, s.option_idx as my_own_idx
    from criterion_pairs p
    join profile_answers a on a.criterion_key = p.pref_key and a.user_id = u
    left join profile_answers s on s.criterion_key = p.self_key and s.user_id = u
  loop
    if r.match_type = 'echelle' then
      v_pref[r.slot + 1] := (select coalesce(sum(1 << g.i), 0)::int
        from option_mappings m cross join generate_series(0, 14) as g(i)
        where m.pair_key = (select pair_key from criterion_pairs where slot = r.slot)
          and m.pref_idx = r.option_idx[1] and r.my_own_idx is not null
          and m.tolerance is not null and abs(g.i - r.my_own_idx[1]) <= m.tolerance);
    else
      v_pref[r.slot + 1] := (select coalesce(sum(distinct 1 << acc), 0)::int
        from option_mappings m, unnest(m.accepted_self_idx) as acc
        where m.pair_key = (select pair_key from criterion_pairs where slot = r.slot)
          and m.pref_idx = any(r.option_idx));
    end if;
    v_wm[r.slot + 1] := coalesce((select min(m.weight_multiplier) from option_mappings m
      where m.pair_key = (select pair_key from criterion_pairs where slot = r.slot)
        and m.pref_idx = any(r.option_idx)), 1.0);
    n_pref := n_pref + 1;
  end loop;
  insert into profile_vectors (user_id, self_mask, pref_mask, weight_mul, answered_self, answered_pref, refreshed_at)
  values (u, v_self, v_pref, v_wm, n_self, n_pref, now())
  on conflict (user_id) do update set self_mask = excluded.self_mask, pref_mask = excluded.pref_mask,
    weight_mul = excluded.weight_mul, answered_self = excluded.answered_self,
    answered_pref = excluded.answered_pref, refreshed_at = now();
end $$;
create or replace function trg_refresh_vectors() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform private.refresh_profile_vectors(coalesce(new.user_id, old.user_id));
  return null;
end $$;
create trigger profile_answers_refresh after insert or update or delete on profile_answers
for each row execute function trg_refresh_vectors();
create table engine_params (
  key text primary key, value numeric not null, description text not null,
  updated_at timestamptz not null default now());
insert into engine_params (key, value, description) values
  ('poids_physique', 0.25, 'Part du sous-score physique dans le score global'),
  ('poids_valeurs', 0.40, 'Part du sous-score valeurs dans le score global'),
  ('poids_mode_vie', 0.35, 'Part du sous-score mode de vie dans le score global'),
  ('plancher_directionnel', 40.0, 'Score directionnel minimal'),
  ('min_criteres_affiches', 60.0, 'Nombre minimal de criteres evalues pour afficher un taux'),
  ('seuil_premium', 85.0, 'Seuil de floutage des profils reserves aux abonnes'),
  ('coef_rejet_fort', 3.0, 'Poids d''un rejet depuis l''onglet Compatibles'),
  ('coef_feedback_date', 5.0, 'Poids du feedback post-rendez-vous'),
  ('seuil_declassement', 20.0, 'Nombre de decisions contredisant une preference avant declassement');
alter table engine_params enable row level security;
create or replace function private.engine_param(k text) returns numeric
language sql stable security definer set search_path = public, pg_temp
as $$ select value from engine_params where key = k $$;
create or replace function private.engine_params_all() returns table (key text, value numeric)
language sql stable security definer set search_path = public, pg_temp
as $$ select key, value from engine_params $$;
revoke all on function private.engine_param(text) from public;
revoke all on function private.engine_params_all() from public;
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'service_role') then
    grant usage on schema private to service_role;
    grant execute on function private.engine_param(text) to service_role;
    grant execute on function private.engine_params_all() to service_role;
  end if;
end $$;
create or replace function private.compat_score(u_a uuid, u_b uuid)
returns table (filtres_ok boolean, score_global numeric, score_physique numeric,
  score_valeurs numeric, score_mode_vie numeric, score_a_vers_b numeric,
  score_b_vers_a numeric, criteres_evalues int, affichable boolean)
language sql stable as $$
with va as (select * from profile_vectors where user_id = u_a),
vb as (select * from profile_vectors where user_id = u_b),
ev as (select p.grp, p.is_absolute, p.base_weight,
    (va.pref_mask[p.slot+1] is not null and vb.self_mask[p.slot+1] is not null) as ab_eval,
    ((vb.self_mask[p.slot+1] & va.pref_mask[p.slot+1]) <> 0) as ab_match,
    p.base_weight * va.weight_mul[p.slot+1] as ab_w,
    (vb.pref_mask[p.slot+1] is not null and va.self_mask[p.slot+1] is not null) as ba_eval,
    ((va.self_mask[p.slot+1] & vb.pref_mask[p.slot+1]) <> 0) as ba_match,
    p.base_weight * vb.weight_mul[p.slot+1] as ba_w
  from criterion_pairs p, va, vb),
filtres as (select bool_and(case when not is_absolute then true
    when ab_eval and not ab_match then false
    when ba_eval and not ba_match then false else true end) as ok from ev),
grp as (select grp,
    sum(ab_w) filter (where ab_eval and ab_w > 0) as den_ab,
    sum(ab_w) filter (where ab_eval and ab_match and ab_w > 0) as num_ab,
    sum(ba_w) filter (where ba_eval and ba_w > 0) as den_ba,
    sum(ba_w) filter (where ba_eval and ba_match and ba_w > 0) as num_ba,
    count(*) filter (where (ab_eval or ba_eval) and not is_absolute) as n
  from ev where not is_absolute group by grp),
dir as (select grp, n, 100 * coalesce(num_ab, 0) / nullif(den_ab, 0) as s_ab,
    100 * coalesce(num_ba, 0) / nullif(den_ba, 0) as s_ba from grp),
final as (select grp, n, round((coalesce(s_ab, s_ba) + coalesce(s_ba, s_ab)) / 2, 1) as s,
    s_ab, s_ba from dir),
pond as (select
    sum(f.s * pp.value) filter (where f.s is not null)
      / nullif(sum(pp.value) filter (where f.s is not null), 0) as global,
    sum(f.s_ab * pp.value) filter (where f.s_ab is not null)
      / nullif(sum(pp.value) filter (where f.s_ab is not null), 0) as g_ab,
    sum(f.s_ba * pp.value) filter (where f.s_ba is not null)
      / nullif(sum(pp.value) filter (where f.s_ba is not null), 0) as g_ba,
    sum(f.n)::int as n_tot
  from final f join private.engine_params_all() pp on pp.key = 'poids_' || f.grp::text)
select filtres.ok, round(pond.global, 1),
  (select s from final where grp = 'physique'),
  (select s from final where grp = 'valeurs'),
  (select s from final where grp = 'mode_vie'),
  round(pond.g_ab, 1), round(pond.g_ba, 1), pond.n_tot,
  filtres.ok and pond.g_ab is not null and pond.g_ba is not null
    and pond.g_ab >= private.engine_param('plancher_directionnel')
    and pond.g_ba >= private.engine_param('plancher_directionnel')
    and pond.n_tot >= private.engine_param('min_criteres_affiches')
from filtres, pond;
$$;
create view private.v_mappings_manquants as
select p.pair_key, p.match_type, c.question, o.idx as pref_idx, o.label as pref_label
from criterion_pairs p join criteria c on c.key = p.pref_key
join criterion_options o on o.criterion_key = p.pref_key
left join option_mappings m on m.pair_key = p.pair_key and m.pref_idx = o.idx
where m.pair_key is null order by p.slot, o.idx;
create view private.v_paires_non_validees as
select p.pair_key, p.match_type, p.category, c.question as question_recherchee,
       (select count(*) from option_mappings m where m.pair_key = p.pair_key) as propositions
from criterion_pairs p join criteria c on c.key = p.pref_key
where not p.mapping_validated order by p.slot;
create view private.v_mappings_invalides as
select m.pair_key, m.pref_idx, acc as idx_inexistant
from option_mappings m join criterion_pairs p on p.pair_key = m.pair_key
cross join lateral unnest(m.accepted_self_idx) as acc
where not exists (select 1 from criterion_options o
  where o.criterion_key = p.self_key and o.idx = acc);
alter table profiles enable row level security;
alter table profile_answers enable row level security;
alter table profile_vectors enable row level security;
create policy p_profiles_self on profiles for all using (id = auth.uid()) with check (id = auth.uid());
create policy p_answers_self on profile_answers for select using (user_id = auth.uid());
create policy p_vectors_self on profile_vectors for select using (user_id = auth.uid());
alter table criteria enable row level security;
alter table criterion_options enable row level security;
alter table criterion_pairs enable row level security;
alter table option_mappings enable row level security;
create policy p_ref_read on criteria for select to authenticated using (true);
create policy p_opt_read on criterion_options for select to authenticated using (true);
create policy p_pair_read on criterion_pairs for select to authenticated using (true);;
