-- =====================================================================
-- 001 — Le point de rendez-vous, côté application
--
-- PROPOSITION. Ne pas appliquer depuis une session d'assistance : à relire
-- et à exécuter par le responsable du projet.
--
-- Rien ici ne crée de table ni ne modifie de colonne. Les données existent
-- déjà dans `date_meeting_points` ; il leur manque seulement une porte
-- publique. `private.generate_meeting_points` les produit, mais le rôle
-- `authenticated` n'a aucun droit sur le schéma `private` : l'application ne
-- peut donc pas afficher à un utilisateur le point où il doit se rendre.
--
-- Vérifié contre le schéma déployé :
--   date_meeting_points(date_id, user_id, point, arrivee_at, expires_at,
--                       revealed_at)
--   dates(id, user_a, user_b, partner_id, creneau_debut, status, created_at)
--   profiles(id, prenom, birth_date, ...)
--   partners(id, ville, ...)
-- =====================================================================

-- ---------------------------------------------------------------------
-- mon_point_rendezvous(d_id)
--
-- LA LIGNE QUI COMPTE est `mp.user_id = auth.uid()`.
--
-- Chaque participant reçoit un point distinct. Rendre les deux, ou accepter
-- un `user_id` en paramètre, permettrait de localiser l'autre personne avant
-- qu'elle n'arrive — exactement ce que le produit promet d'empêcher. La
-- fonction ne prend donc aucun identifiant d'utilisateur, conformément à la
-- règle du projet.
--
-- Les coordonnées sortent en lat/lon plutôt qu'en `geography` : le client n'a
-- pas PostGIS, et un WKB hexadécimal ne lui servirait à rien.
-- ---------------------------------------------------------------------
create or replace function public.mon_point_rendezvous(d_id uuid)
returns table (
  lat         double precision,
  lon         double precision,
  arrivee_at  timestamptz,
  expires_at  timestamptz,
  devoile_le  timestamptz
)
language sql
stable
security invoker
set search_path = public, extensions
as $$
  select
    st_y(mp.point::geometry) as lat,
    st_x(mp.point::geometry) as lon,
    mp.arrivee_at,
    mp.expires_at,
    mp.revealed_at
  from public.date_meeting_points as mp
  where mp.date_id = d_id
    and mp.user_id = auth.uid();
$$;

comment on function public.mon_point_rendezvous(uuid) is
  'Le point de rendez-vous de l''appelant pour ce rendez-vous, jamais celui '
  'de l''autre participant. Sert à guider l''approche ; l''établissement reste '
  'masqué jusqu''à reveal_establishment.';

revoke all on function public.mon_point_rendezvous(uuid) from public;
grant execute on function public.mon_point_rendezvous(uuid) to authenticated;


-- ---------------------------------------------------------------------
-- mes_rendezvous()
--
-- La liste des rendez-vous à venir, avec ce qu'il faut pour l'afficher : qui,
-- quand, où se présenter. La ville vient de `partners`, pas l'adresse — savoir
-- qu'on dîne à Genève ne dit pas dans quel restaurant.
--
-- `security invoker` : la RLS de `dates` s'applique telle quelle. Si elle
-- n'autorise pas déjà les participants à lire leur propre rendez-vous, c'est
-- cette politique qu'il faut regarder, pas cette fonction.
-- ---------------------------------------------------------------------
create or replace function public.mes_rendezvous()
returns table (
  date_id        uuid,
  autre          uuid,
  prenom_autre   text,
  age_autre      integer,
  statut         date_status,
  creneau_debut  timestamptz,
  ville          text,
  point_lat      double precision,
  point_lon      double precision,
  expires_at     timestamptz,
  lieu_devoile   boolean
)
language sql
stable
security invoker
set search_path = public, extensions
as $$
  select
    d.id,
    case when d.user_a = auth.uid() then d.user_b else d.user_a end,
    autre.prenom,
    -- `age()` s'appuie sur la date du jour : la fonction est donc `stable`,
    -- jamais `immutable`. Une erreur déjà commise sur ce projet.
    extract(year from age(autre.birth_date))::integer,
    d.status,
    d.creneau_debut,
    part.ville,
    st_y(mp.point::geometry),
    st_x(mp.point::geometry),
    mp.expires_at,
    mp.revealed_at is not null
  from public.dates as d
  join public.profiles as autre
    on autre.id = case when d.user_a = auth.uid() then d.user_b else d.user_a end
  left join public.partners as part
    on part.id = d.partner_id
  -- Le point est joint sur l'appelant : la jointure porte la même garantie
  -- que la fonction ci-dessus.
  left join public.date_meeting_points as mp
    on mp.date_id = d.id and mp.user_id = auth.uid()
  where (d.user_a = auth.uid() or d.user_b = auth.uid())
    and d.status in ('en_preparation', 'confirme', 'en_cours')
  order by d.creneau_debut;
$$;

comment on function public.mes_rendezvous() is
  'Les rendez-vous à venir de l''appelant. Ville de l''établissement, jamais '
  'son nom ni son adresse : ceux-là passent par reveal_establishment.';

revoke all on function public.mes_rendezvous() from public;
grant execute on function public.mes_rendezvous() to authenticated;
