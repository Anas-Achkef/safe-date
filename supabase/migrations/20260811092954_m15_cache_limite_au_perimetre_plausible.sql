-- =========================================================
-- M15 - Le cache ne couvre que les paires plausibles
--
-- Le pre-calcul est quadratique : 2 000 profils font 2 millions
-- de paires, 10 000 en font 50 millions. Rechauffer l'ensemble
-- est hors de portee, et surtout inutile — la grande majorite
-- de ces couples ne se verront jamais, faute de se trouver dans
-- le rayon de recherche l'un de l'autre.
--
-- On ne pre-calcule donc que ce qui peut reellement etre montre.
-- Le reste garde son calcul paresseux : rien n'est perdu, c'est
-- simplement calcule au moment ou l'on en a besoin.
-- =========================================================

insert into public.engine_params (key, value, description) values
  ('cache_rayon_max_km', 60, 'Distance au-dela de laquelle une paire n''est plus pre-calculee. Elle reste calculable a la demande : on renonce a l''anticiper, pas a la servir.')
on conflict (key) do nothing;

create or replace function private.paire_plausible(a uuid, b uuid)
returns boolean
language sql stable set search_path = public, private as $$
  select case
    -- Sans position connue, on ne peut rien exclure
    when pa.last_location is null or pb.last_location is null then true
    else st_dwithin(
           pa.last_location, pb.last_location,
           least(
             greatest(pa.search_radius_km, pb.search_radius_km) * 1000,
             private.engine_param('cache_rayon_max_km') * 1000
           ))
  end
  from public.profiles pa, public.profiles pb
  where pa.id = a and pb.id = b;
$$;

comment on function private.paire_plausible is
  'Vrai lorsque les deux personnes sont a portee l''une de l''autre. Sert uniquement a decider ce qu''il vaut la peine de pre-calculer : une paire jugee implausible reste parfaitement calculable a la demande.';

-- ---------------------------------------------------------
-- Le rechauffage suit le meme perimetre
-- ---------------------------------------------------------
create or replace function private.rechauffer_compat(p_lot integer default 200)
returns integer
language plpgsql set search_path = public, private as $$
declare n integer := 0; r record;
begin
  for r in
    select va.user_id as a, vb.user_id as b
    from public.profile_vectors va
    join public.profile_vectors vb on vb.user_id > va.user_id
    join public.profiles pa on pa.id = va.user_id and pa.is_active
    join public.profiles pb on pb.id = vb.user_id and pb.is_active
    left join private.compat_cache c
      on c.user_lo = va.user_id and c.user_hi = vb.user_id
     and c.vectors_stamp >= greatest(va.refreshed_at, vb.refreshed_at)
    where c.user_lo is null
      -- Deux personnes hors de portee ne se verront pas : les anticiper
      -- consommerait tout le budget de calcul sans rien servir.
      and st_dwithin(
            pa.last_location, pb.last_location,
            least(greatest(pa.search_radius_km, pb.search_radius_km) * 1000,
                  private.engine_param('cache_rayon_max_km') * 1000))
    limit p_lot
  loop
    perform private.compat_cached(r.a, r.b);
    n := n + 1;
  end loop;
  return n;
end $$;

comment on function private.rechauffer_compat is
  'Calcule par lots bornes les paires manquantes, en se limitant aux couples geographiquement plausibles. Les autres restent servies par le calcul paresseux, au moment ou une lecture les reclame.';

-- Le fil profite du perimetre : un rechauffage cible avant lecture
create or replace function private.rechauffer_pour(u uuid, p_lot integer default 100)
returns integer
language plpgsql set search_path = public, private as $$
declare n integer := 0; r record;
begin
  for r in
    select c.id
    from public.profiles c
    join public.profiles moi on moi.id = u
    left join private.compat_cache k
      on k.user_lo = least(u, c.id) and k.user_hi = greatest(u, c.id)
    where c.id <> u and c.is_active and k.user_lo is null
      and exists (select 1 from public.profile_vectors v where v.user_id = c.id)
      and st_dwithin(moi.last_location, c.last_location,
                     least(greatest(moi.search_radius_km, c.search_radius_km) * 1000,
                           private.engine_param('cache_rayon_max_km') * 1000))
    limit p_lot
  loop
    perform private.compat_cached(u, r.id);
    n := n + 1;
  end loop;
  return n;
end $$;

comment on function private.rechauffer_pour is
  'Prepare le voisinage immediat d''une personne. Utile a la connexion : le premier fil est alors servi depuis le cache plutot que calcule sous les yeux de l''utilisateur.';;
