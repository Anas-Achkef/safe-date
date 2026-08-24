create table criterion_option_phrasings (
  criterion_key text not null, idx smallint not null, locale text not null default 'fr',
  phrase text not null, primary key (criterion_key, idx, locale),
  foreign key (criterion_key, idx) references criterion_options (criterion_key, idx) on delete cascade);
create view private.v_phrasings_manquants as
select c.ord, c.key as criterion_key, c.direction, c.category, c.question, o.idx, o.label
from criteria c join criterion_options o on o.criterion_key = c.key
left join criterion_option_phrasings p on p.criterion_key = o.criterion_key and p.idx = o.idx and p.locale = 'fr'
where p.criterion_key is null order by c.ord, o.idx;
alter table criterion_options add column value_min numeric, add column value_max numeric, add column unit text;
update criterion_options o set unit = case when o.label ~ 'cm' then 'cm' else 'kg' end,
  value_min = nullif((regexp_match(o.label,'(\d+)\s*-\s*\d+'))[1],'')::numeric,
  value_max = nullif((regexp_match(o.label,'\d+\s*-\s*(\d+)'))[1],'')::numeric
where o.criterion_key in ('phys_taille_moi','phys_taille_rech','phys_poids_moi','phys_poids_rech');
update criterion_options o set value_max = (regexp_match(o.label,'<\s*(\d+)'))[1]::numeric
where o.label ~ '^<' and o.value_min is null;
update criterion_options o set value_min = (regexp_match(o.label,'(\d+)\s*(cm|kg)\s*\+'))[1]::numeric
where o.label ~ '\+\s*$' and o.value_min is null;
create type unit_system as enum ('metrique','imperial');
alter table profiles add column systeme_unites unit_system not null default 'metrique';
create or replace function render_measure(v_min numeric, v_max numeric, v_unit text, sys unit_system)
returns text language plpgsql immutable as $$
declare f numeric; suffixe text; a text; b text;
begin
  if v_unit is null then return null; end if;
  if sys = 'metrique' then
    if v_min is null then return format('moins de %s %s', v_max, v_unit); end if;
    if v_max is null then return format('plus de %s %s', v_min, v_unit); end if;
    return format('entre %s et %s %s', v_min, v_max, v_unit);
  end if;
  if v_unit = 'kg' then
    f := 2.20462; suffixe := ' lb';
    a := case when v_min is null then null else round(v_min * f)::text end;
    b := case when v_max is null then null else round(v_max * f)::text end;
  else
    a := case when v_min is null then null else format('%s''%s"', floor(v_min/2.54/12), round(v_min/2.54) % 12) end;
    b := case when v_max is null then null else format('%s''%s"', floor(v_max/2.54/12), round(v_max/2.54) % 12) end;
    suffixe := '';
  end if;
  if a is null then return format('moins de %s%s', b, suffixe); end if;
  if b is null then return format('plus de %s%s', a, suffixe); end if;
  return format('entre %s et %s%s', a, b, suffixe);
end $$;
insert into engine_params (key, value, description) values
  ('connaissance_part_paires',0.60,'Part des paires completes dans le niveau de connaissance'),
  ('connaissance_part_entropie',0.25,'Part de la couverture ponderee par l''entropie'),
  ('connaissance_part_interactions',0.15,'Part des signaux comportementaux'),
  ('connaissance_swipes_cible',200,'Nombre de decisions de swipe pour saturer la part comportementale');
create table swipe_decisions (
  id bigserial primary key, user_id uuid not null references profiles(id) on delete cascade,
  target_id uuid not null references profiles(id) on delete cascade, decision boolean not null,
  signal_fort boolean not null default false, ecran text, duree_ms int,
  created_at timestamptz not null default now());
create index on swipe_decisions (user_id, created_at desc);
create or replace function private.profile_knowledge(u uuid)
returns numeric language sql stable as $$
  with p as (select private.engine_param('connaissance_part_paires') as w_paires,
      private.engine_param('connaissance_part_entropie') as w_entropie,
      private.engine_param('connaissance_part_interactions') as w_inter,
      private.engine_param('connaissance_swipes_cible') as cible),
  paires as (select
      avg(case when a_self and a_pref then 1.0 when a_self or a_pref then 0.5 else 0.0 end) as couverture,
      sum(case when a_self and a_pref then poids else 0 end) / nullif(sum(poids),0) as couverture_ponderee
    from (select
        exists (select 1 from profile_answers where user_id=u and criterion_key=cp.self_key) as a_self,
        exists (select 1 from profile_answers where user_id=u and criterion_key=cp.pref_key) as a_pref,
        greatest(coalesce(s1.entropie,1.0),0.05) as poids
      from criterion_pairs cp
      left join private.criterion_stats s1 on s1.criterion_key = cp.self_key
      where cp.self_key in (select key from criteria where moment <> 'backend')) t),
  inter as (select least(1.0, count(*)::numeric / (select cible from p)) as taux
    from swipe_decisions where user_id = u)
  select round(100 * (p.w_paires * coalesce(paires.couverture,0)
    + p.w_entropie * coalesce(paires.couverture_ponderee,0)
    + p.w_inter * coalesce(inter.taux,0)), 0)
  from p, paires, inter;
$$;
alter table profiles add column is_premium boolean not null default false;
insert into engine_params (key, value, description) values
  ('priorites_visibles_gratuit',3,'Priorites consultables sans abonnement'),
  ('priorites_visibles_premium',20,'Priorites consultables et reorganisables en premium'),
  ('priorite_coef_max',3.0,'Multiplicateur de poids de la priorite de rang 1');
create table user_criterion_priorities (
  user_id uuid not null references profiles(id) on delete cascade,
  pair_key text not null references criterion_pairs(pair_key) on delete cascade,
  rang smallint not null check (rang >= 1), manuel boolean not null default false,
  primary key (user_id, pair_key), unique (user_id, rang) deferrable initially deferred);
create or replace function priorite_coef(rang smallint) returns numeric language sql immutable as $$
  select case when rang is null then 1.0
    when rang >= private.engine_param('priorites_visibles_premium') then 1.0
    else private.engine_param('priorite_coef_max')
         - (private.engine_param('priorite_coef_max') - 1.0) * (rang - 1)
           / (private.engine_param('priorites_visibles_premium') - 1) end::numeric;
$$;
create or replace function private.derive_priorities(u uuid) returns void language plpgsql as $$
begin
  with declare_poids as (select cp.pair_key,
      coalesce(min(m.weight_multiplier),1.0) as poids_declare,
      coalesce(max(s.entropie),1.0) as entropie
    from criterion_pairs cp
    join profile_answers pa on pa.user_id=u and pa.criterion_key=cp.pref_key
    left join option_mappings m on m.pair_key=cp.pair_key and m.pref_idx = any(pa.option_idx)
    left join private.criterion_stats s on s.criterion_key=cp.pref_key
    group by cp.pair_key),
  classe as (select pair_key,
      row_number() over (order by poids_declare desc, entropie desc, pair_key)::smallint as rang
    from declare_poids
    where pair_key not in (select pair_key from user_criterion_priorities where user_id=u and manuel))
  insert into user_criterion_priorities (user_id, pair_key, rang, manuel)
  select u, pair_key,
    (rang + (select count(*) from user_criterion_priorities where user_id=u and manuel))::smallint, false
  from classe
  on conflict (user_id, pair_key) do update set rang = excluded.rang
    where not user_criterion_priorities.manuel;
  perform private.refresh_profile_vectors(u);
end $$;
create or replace function private.reorder_priorities(u uuid, ordre text[])
returns void language plpgsql as $$
declare max_visible int; i int;
begin
  if not (select is_premium from profiles where id = u) then
    raise exception 'La réorganisation des priorités de compatibilité est réservée aux abonnés Premium'
      using errcode = 'insufficient_privilege';
  end if;
  max_visible := private.engine_param('priorites_visibles_premium');
  if array_length(ordre,1) > max_visible then
    raise exception 'Au plus % priorités peuvent être réorganisées', max_visible using errcode='check_violation';
  end if;
  update user_criterion_priorities set rang = rang + array_length(ordre,1), manuel = false
   where user_id = u and pair_key <> all(ordre);
  for i in 1 .. array_length(ordre,1) loop
    insert into user_criterion_priorities (user_id, pair_key, rang, manuel)
    values (u, ordre[i], i::smallint, true)
    on conflict (user_id, pair_key) do update set rang = excluded.rang, manuel = true;
  end loop;
  perform private.refresh_profile_vectors(u);
end $$;
create or replace function private.visible_priorities(u uuid)
returns table (rang smallint, pair_key text, phrase text, verrouille boolean)
language sql stable as $$
  with lim as (select case when (select is_premium from profiles where id=u)
      then private.engine_param('priorites_visibles_premium')
      else private.engine_param('priorites_visibles_gratuit') end as n)
  select p.rang, p.pair_key, ph.phrase, p.rang > (select n from lim) as verrouille
  from user_criterion_priorities p
  join criterion_pairs cp on cp.pair_key = p.pair_key
  left join profile_answers pa on pa.user_id=u and pa.criterion_key=cp.pref_key
  left join criterion_option_phrasings ph on ph.criterion_key=cp.pref_key and ph.idx=pa.option_idx[1]
    and ph.locale = coalesce((select langue from profiles where id=u),'fr')
  where p.user_id = u and p.rang <= private.engine_param('priorites_visibles_premium')
  order by p.rang;
$$;
create or replace function private.refresh_profile_vectors(u uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare v_self int[] := array_fill(null::int, array[133]);
  v_pref int[] := array_fill(null::int, array[133]);
  v_wm numeric[] := array_fill(1.0::numeric, array[133]);
  n_self smallint := 0; n_pref smallint := 0; r record;
begin
  for r in select p.slot, a.option_idx from criterion_pairs p
    join profile_answers a on a.criterion_key = p.self_key and a.user_id = u
  loop
    v_self[r.slot+1] := (select coalesce(sum(1 << i),0)::int from unnest(r.option_idx) as i);
    n_self := n_self + 1;
  end loop;
  for r in select p.slot, p.pair_key, p.match_type, a.option_idx, s.option_idx as my_own_idx,
      pr.rang as rang_priorite
    from criterion_pairs p
    join profile_answers a on a.criterion_key = p.pref_key and a.user_id = u
    left join profile_answers s on s.criterion_key = p.self_key and s.user_id = u
    left join user_criterion_priorities pr on pr.user_id = u and pr.pair_key = p.pair_key
  loop
    if r.match_type = 'echelle' then
      v_pref[r.slot+1] := (select coalesce(sum(1 << g.i),0)::int
        from option_mappings m cross join generate_series(0,14) as g(i)
        where m.pair_key = r.pair_key and m.pref_idx = r.option_idx[1]
          and r.my_own_idx is not null and m.tolerance is not null
          and abs(g.i - r.my_own_idx[1]) <= m.tolerance);
    else
      v_pref[r.slot+1] := (select coalesce(sum(distinct 1 << acc),0)::int
        from option_mappings m, unnest(m.accepted_self_idx) as acc
        where m.pair_key = r.pair_key and m.pref_idx = any(r.option_idx));
    end if;
    v_wm[r.slot+1] := coalesce((select min(m.weight_multiplier) from option_mappings m
        where m.pair_key = r.pair_key and m.pref_idx = any(r.option_idx)),1.0)
      * priorite_coef(r.rang_priorite);
    n_pref := n_pref + 1;
  end loop;
  insert into profile_vectors (user_id, self_mask, pref_mask, weight_mul, answered_self, answered_pref, refreshed_at)
  values (u, v_self, v_pref, v_wm, n_self, n_pref, now())
  on conflict (user_id) do update set self_mask=excluded.self_mask, pref_mask=excluded.pref_mask,
    weight_mul=excluded.weight_mul, answered_self=excluded.answered_self,
    answered_pref=excluded.answered_pref, refreshed_at=now();
end $$;
alter table user_photos add column is_primary boolean not null default false;
create unique index user_photos_une_principale on user_photos (user_id) where is_primary;
create or replace function private.set_primary_photo(u uuid, p uuid) returns void language plpgsql as $$
begin
  update user_photos set is_primary = false where user_id = u and is_primary;
  update user_photos set is_primary = true where user_id = u and id = p;
  if not found then raise exception 'Photo introuvable pour cet utilisateur' using errcode='no_data_found'; end if;
end $$;
create or replace function private.profile_header(u uuid)
returns table (age int, photo_principale text, profil_verifie boolean, connaissance numeric, est_premium boolean)
language sql stable as $$
  select extract(year from age(current_date, e.birth_date))::int,
    (select storage_path from user_photos where user_id=u and is_primary),
    exists (select 1 from user_verification_codes where user_id=u and verified_at is not null)
      and exists (select 1 from identity_verifications where user_id=u and status='validee' and comparison_ok),
    private.profile_knowledge(u), e.is_premium
  from profiles e where e.id = u;
$$;
create or replace function private.profile_sections(u uuid)
returns table (section score_group, ord smallint, pair_key text, phrase text)
language sql stable as $$
  select cp.grp, c.ord, cp.pair_key,
    coalesce(render_measure(o.value_min,o.value_max,o.unit,
      (select systeme_unites from profiles where id=u)), ph.phrase)
  from criterion_pairs cp
  join criteria c on c.key = cp.self_key
  join profile_answers pa on pa.user_id=u and pa.criterion_key=cp.self_key
  join criterion_options o on o.criterion_key=cp.self_key and o.idx=pa.option_idx[1]
  left join criterion_option_phrasings ph on ph.criterion_key=cp.self_key and ph.idx=pa.option_idx[1]
    and ph.locale = coalesce((select langue from profiles where id=u),'fr')
  where c.moment <> 'backend' order by cp.grp, c.ord;
$$;
alter table user_criterion_priorities enable row level security;
alter table swipe_decisions enable row level security;
create policy p_prio_self on user_criterion_priorities for select using (user_id = auth.uid());
create policy p_swipe_self on swipe_decisions for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create or replace function profile_knowledge() returns numeric
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return private.profile_knowledge(auth.uid());
end $$;
create or replace function visible_priorities()
returns table (rang smallint, pair_key text, phrase text, verrouille boolean)
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.visible_priorities(auth.uid());
end $$;
create or replace function reorder_priorities(ordre text[]) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  perform private.reorder_priorities(auth.uid(), ordre);
end $$;
create or replace function set_primary_photo(photo_id uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  perform private.set_primary_photo(auth.uid(), photo_id);
end $$;
create or replace function profile_header()
returns table (age int, photo_principale text, profil_verifie boolean, connaissance numeric, est_premium boolean)
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.profile_header(auth.uid());
end $$;
create or replace function profile_sections()
returns table (section score_group, ord smallint, pair_key text, phrase text)
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.profile_sections(auth.uid());
end $$;
create or replace function compat_score(autre uuid)
returns table (filtres_ok boolean, score_global numeric, score_physique numeric,
  score_valeurs numeric, score_mode_vie numeric, score_a_vers_b numeric,
  score_b_vers_a numeric, criteres_evalues int, affichable boolean)
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  if not exists (select 1 from private.eligible_candidates(auth.uid()) where candidate_id = autre) then
    raise exception 'Ce profil ne fait pas partie de vos candidats' using errcode='insufficient_privilege';
  end if;
  return query select * from private.compat_score(auth.uid(), autre);
end $$;;
