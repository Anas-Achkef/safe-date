-- =========================================================
-- M8 - Fil de profils (swipe vertical)
-- Curseur stable, exclusions appliquees serveur,
-- score lu depuis le cache.
-- =========================================================

insert into public.engine_params (key, value, description) values
  ('fil_page_taille', 20, 'Nombre de profils retournes par page du fil.')
on conflict (key) do nothing;

create or replace function private.fil_profils(
  u        uuid,
  p_apres  numeric  default null,   -- curseur : dernier score lu
  p_apres_id uuid   default null,   -- curseur : dernier id lu, departage les ex aequo
  p_taille integer  default null
) returns table (
  profil_id        uuid,
  prenom           text,
  age              integer,
  photo_principale text,
  profil_verifie   boolean,
  est_premium      boolean,
  compat_rate      numeric,
  score_physique   numeric,
  score_valeurs    numeric,
  score_mode_vie   numeric,
  distance         text,
  proposable       boolean,
  motif            text
)
language plpgsql set search_path = public, private as $$
declare v_taille integer := coalesce(p_taille, private.engine_param('fil_page_taille')::int);
begin
  -- Le cache doit etre chaud pour la page demandee
  perform private.compat_cached(u, c.id)
  from public.profiles c
  where c.id <> u and c.is_active
    and exists (select 1 from profile_vectors v where v.user_id = c.id)
  limit 200;

  return query
  select
    c.id, c.prenom, h.age, h.photo_principale, h.profil_verifie, h.est_premium,
    k.score_global, k.score_physique, k.score_valeurs, k.score_mode_vie,
    private.distance_palier(u, c.id),
    pp.autorise,
    case when pp.autorise then null else pp.motif end
  from public.profiles c
  cross join lateral private.compat_cached(u, c.id) k
  cross join lateral private.profile_header(c.id) h
  cross join lateral private.peut_proposer(u, c.id) pp
  where c.id <> u
    and c.is_active
    and k.user_lo is not null
    and private.cadrage_ok(u, c.id)              -- cadrage : retire du fil
    and not private.est_exclu(u, c.id)           -- refus, blocage, signalement
    and not public.are_blocked(u, c.id)
    and (p_apres is null
         or (k.score_global, c.id) < (p_apres, p_apres_id))
  order by k.score_global desc, c.id desc
  limit v_taille;
end $$;

comment on function private.fil_profils is
  'Aucun filtrage sur les dealbreakers : le profil reste visible avec proposable a faux, conformement au principe "on voit tous les profils". Seuls le cadrage et les exclusions retirent reellement du fil. Le curseur porte sur le couple (score, id) et reste stable meme si de nouveaux profils sont crees pendant le defilement, contrairement a un OFFSET.';

create or replace function public.fil_profils(
  apres numeric default null,
  apres_id uuid default null,
  taille integer default null
) returns table (
  profil_id        uuid,
  prenom           text,
  age              integer,
  photo_principale text,
  profil_verifie   boolean,
  est_premium      boolean,
  compat_rate      numeric,
  score_physique   numeric,
  score_valeurs    numeric,
  score_mode_vie   numeric,
  distance         text,
  proposable       boolean,
  motif            text
)
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.fil_profils(auth.uid(), apres, apres_id, taille);
end $$;

revoke all on function public.fil_profils(numeric, uuid, integer) from public;
grant execute on function public.fil_profils(numeric, uuid, integer) to authenticated;;
