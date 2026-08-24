-- =========================================================
-- M12 - Fusion des deux fils de decouverte
--
-- candidate_cards et fil_profils repondaient a la meme question
-- avec deux contrats differents. Deux sources de verite sur un
-- meme sujet finissent toujours par diverger : on garde le nom
-- deja appele par l'application, et on y verse ce que l'autre
-- apportait.
--
-- Apports repris de fil_profils :
--   · curseur stable (score, id) au lieu d'un OFFSET
--   · distance en palier, jamais exacte
--   · proposable / motif : le profil reste visible, le bouton non
--   · exclusions reciproques et cadrage genre / orientation
--   · lecture du cache de compatibilite au lieu d'un recalcul
-- =========================================================

-- peut_proposer lisait le moteur a chaque appel : sur un fil entier
-- cela recalculait 133 paires de criteres par profil.
create or replace function private.peut_proposer(u uuid, cible uuid)
returns table (autorise boolean, motif text)
language plpgsql stable set search_path = public, private as $$
declare
  v_cible      public.profiles;
  v_compat     record;
  v_dernier    timestamptz;
  v_tentatives int;
  v_file       int;
begin
  if u = cible then
    return query select false, 'cible_invalide'; return;
  end if;

  select * into v_cible from public.profiles where id = cible;
  if not found or not v_cible.is_active then
    return query select false, 'indisponible'; return;
  end if;

  if private.est_exclu(u, cible) or public.are_blocked(u, cible) then
    return query select false, 'indisponible'; return;
  end if;

  if exists (select 1 from public.chat_requests
             where from_user = u and to_user = cible
               and status in ('en_attente','reportee')) then
    return query select false, 'demande_deja_en_cours'; return;
  end if;

  select max(created_at) into v_dernier
  from public.chat_requests where from_user = u and to_user = cible;

  if v_dernier is not null
     and v_dernier + (private.engine_param('demande_cooldown_relance_h') || ' hours')::interval > now() then
    return query select false, 'trop_tot'; return;
  end if;

  select count(*) into v_tentatives
  from public.chat_requests
  where from_user = u and to_user = cible
    and created_at > now() - (private.engine_param('demande_fenetre_tentatives_j') || ' days')::interval;

  if v_tentatives >= private.engine_param('demande_max_tentatives') then
    return query select false, 'plafond_atteint'; return;
  end if;

  select count(*) into v_file
  from public.chat_requests r
  where r.to_user = cible
    and private.statut_effectif(r) in ('en_attente','reportee');

  if v_file >= private.engine_param('demande_file_active_max') then
    return query select false, 'indisponible'; return;
  end if;

  -- Lecture du cache plutot que recalcul integral
  select * into v_compat from private.compat_cached(u, cible);
  if v_compat.user_lo is null or not v_compat.filtres_ok then
    return query select false, 'incompatibilite_absolue'; return;
  end if;

  return query select true, null::text;
end $$;

-- ---------------------------------------------------------
-- Le fil unique
-- ---------------------------------------------------------
drop function if exists private.candidate_cards(uuid);

create function private.candidate_cards(
  u          uuid,
  p_apres    numeric default null,
  p_apres_id uuid    default null,
  p_taille   integer default null
) returns table (
  candidate_id     uuid,
  prenom           text,
  age              integer,
  photo            text,
  verifie          boolean,
  score_global     numeric,
  score_physique   numeric,
  score_valeurs    numeric,
  score_mode_vie   numeric,
  score_aller      numeric,
  score_retour     numeric,
  criteres_evalues integer,
  filtres_ok       boolean,
  affichable       boolean,
  au_dela_du_seuil boolean,
  highlights       jsonb,
  distance         text,
  proposable       boolean,
  motif            text
)
language sql stable security definer set search_path = public, private as $$
  select
    p.id, p.prenom,
    extract(year from age(current_date, p.birth_date))::int,
    (select ph.storage_path from user_photos ph
      where ph.user_id = p.id and ph.is_primary and ph.moderation <> 'rejetee'),
    p.is_verified,
    k.score_global, k.score_physique, k.score_valeurs, k.score_mode_vie,
    k.score_lo_hi, k.score_hi_lo, k.criteres_evalues,
    k.filtres_ok, k.affichable,
    coalesce(k.score_global, 0) >= private.engine_param('seuil_premium'),
    coalesce((select jsonb_agg(jsonb_build_object('question', h.question,
                                                  'reponse',  h.reponse,
                                                  'groupe',   h.grp))
              from private.candidate_highlights(u, p.id, 3) h), '[]'::jsonb),
    -- Palier, jamais une distance exacte : « 2,1 km » situe a trois rues pres
    private.distance_palier(u, p.id),
    pp.autorise,
    case when pp.autorise then null else pp.motif end
  from private.eligible_candidates(u) c
  join profiles p on p.id = c.candidate_id
  cross join lateral private.compat_cached(u, p.id) k
  cross join lateral private.peut_proposer(u, p.id) pp
  where k.user_lo is not null
    -- Le cadrage retire du fil ; un dealbreaker n'y touche pas
    and private.cadrage_ok(u, p.id)
    and not private.est_exclu(u, p.id)
    -- Curseur stable : un profil cree pendant le defilement ne decale rien
    and (p_apres is null or (k.score_global, p.id) < (p_apres, p_apres_id))
  order by k.score_global desc nulls last, p.id desc
  limit coalesce(p_taille, private.engine_param('fil_page_taille')::int);
$$;

comment on function private.candidate_cards is
  'Fil unique de la decouverte. Tous les profils restent visibles, y compris ceux qu''un critere redhibitoire rend inaccessibles : seul le cadrage retire du fil. Le curseur porte sur le couple (score, identifiant) et reste stable lorsque de nouveaux profils apparaissent pendant le defilement.';

-- ---------------------------------------------------------
-- Surface publique : le voile premium reste applique en base
-- ---------------------------------------------------------
drop function if exists public.candidate_cards();

create function public.candidate_cards(
  apres    numeric default null,
  apres_id uuid    default null,
  taille   integer default null
) returns table (
  candidate_id     uuid,
  prenom           text,
  age              integer,
  photo            text,
  verifie          boolean,
  score_global     numeric,
  score_physique   numeric,
  score_valeurs    numeric,
  score_mode_vie   numeric,
  score_aller      numeric,
  score_retour     numeric,
  criteres_evalues integer,
  filtres_ok       boolean,
  affichable       boolean,
  au_dela_du_seuil boolean,
  highlights       jsonb,
  distance         text,
  proposable       boolean,
  motif            text
)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
declare premium boolean;
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  select coalesce(is_premium, false) into premium from profiles where id = auth.uid();

  return query
  select k.candidate_id,
    case when k.au_dela_du_seuil and not premium then null else k.prenom end,
    k.age,
    case when k.au_dela_du_seuil and not premium then null else k.photo end,
    k.verifie,
    case when k.au_dela_du_seuil and not premium then null else k.score_global end,
    case when k.au_dela_du_seuil and not premium then null else k.score_physique end,
    case when k.au_dela_du_seuil and not premium then null else k.score_valeurs end,
    case when k.au_dela_du_seuil and not premium then null else k.score_mode_vie end,
    case when k.au_dela_du_seuil and not premium then null else k.score_aller end,
    case when k.au_dela_du_seuil and not premium then null else k.score_retour end,
    k.criteres_evalues, k.filtres_ok, k.affichable, k.au_dela_du_seuil,
    case when k.au_dela_du_seuil and not premium then '[]'::jsonb else k.highlights end,
    -- Le palier reste lisible sous le voile : il ne revele rien d'identifiant
    k.distance,
    k.proposable,
    k.motif
  from private.candidate_cards(auth.uid(), apres, apres_id, taille) k;
end $$;

revoke all on function public.candidate_cards(numeric, uuid, integer) from public;
grant execute on function public.candidate_cards(numeric, uuid, integer) to authenticated;

-- ---------------------------------------------------------
-- fil_profils n'a plus de raison d'exister
-- ---------------------------------------------------------
drop function if exists public.fil_profils(numeric, uuid, integer);
drop function if exists private.fil_profils(uuid, numeric, uuid, integer);;
