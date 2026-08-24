-- =========================================================
-- M8 - Expiration serveur + boite de reception
-- =========================================================

-- ---------------------------------------------------------
-- 1. Expiration : reecriture
--    L'ancienne version ne traitait que les demandes ouvertes
--    en statut en_attente. Il faut aussi couvrir les demandes
--    reportees et les demandes jamais ouvertes (stale_at).
-- ---------------------------------------------------------
create or replace function private.expirer_demandes()
returns integer
language plpgsql as $$
declare n integer;
begin
  update chat_requests
     set status = 'expiree', responded_at = now()
   where status in ('en_attente','reportee')
     and (
       (opened_at is not null and expires_at <= now())   -- delai de reponse ecoule
       or (opened_at is null and stale_at <= now())      -- jamais ouverte, peremption
     );
  get diagnostics n = row_count;
  return n;
end $$;

comment on function private.expirer_demandes is
  'Couvre les deux echeances : le delai de reponse (compte a rebours demarre a l''ouverture) et la peremption d''une demande jamais ouverte.';

create or replace function private.purger_exclusions()
returns integer
language plpgsql as $$
declare n integer;
begin
  delete from profile_exclusions
   where expires_at is not null and expires_at <= now();
  get diagnostics n = row_count;
  return n;
end $$;

comment on function private.purger_exclusions is
  'Supprime les exclusions arrivees a echeance. Les exclusions permanentes (expires_at nul) ne sont jamais purgees.';

create or replace function private.maintenance_periodique()
returns jsonb
language plpgsql as $$
begin
  return jsonb_build_object(
    'demandes_expirees',          private.expirer_demandes(),
    'conversations_verrouillees', private.verrouiller_conversations(),
    'cooldowns_purges',           private.purger_cooldowns(),
    'exclusions_purgees',         private.purger_exclusions(),
    'points_rdv_expires',         (select expirer_points_rendezvous()),
    'suspensions_levees',         private.lever_suspensions(),
    'messages_envoyes',           private.envoyer_messages_plateforme(),
    'execute_a',                  now());
end $$;

-- ---------------------------------------------------------
-- 2. Distance par paliers
--    La distance exacte est localisante : 2,1 km designe
--    un rayon de quelques rues. On ne publie qu'un palier.
-- ---------------------------------------------------------
create or replace function private.distance_palier(a uuid, b uuid)
returns text
language sql stable as $$
  select case
    when pa.last_location is null or pb.last_location is null then null
    when d <   1000 then 'moins de 1 km'
    when d <   5000 then '1 a 5 km'
    when d <  10000 then '5 a 10 km'
    when d <  25000 then '10 a 25 km'
    when d <  50000 then '25 a 50 km'
    else 'plus de 50 km'
  end
  from profiles pa, profiles pb,
       lateral (select st_distance(pa.last_location, pb.last_location) as d) x
  where pa.id = a and pb.id = b;
$$;

comment on function private.distance_palier is
  'Ne publie jamais la distance exacte. Un palier suffit a situer l''autre sans permettre de le localiser par recoupement.';

-- ---------------------------------------------------------
-- 3. Boite de reception : onglet "conversations proposees"
-- ---------------------------------------------------------
create or replace function private.boite_reception(u uuid)
returns table (
  demande_id       uuid,
  emetteur         uuid,
  prenom           text,
  age              integer,
  photo_principale text,
  profil_verifie   boolean,
  type_rencontre   public.rencontre_type,
  compat_rate      numeric,
  ecran_ordre      public.score_group[],
  ecran_vignette   public.score_group,
  distance         text,
  statut           public.chat_request_status,
  secondes_restantes integer,
  reportable       boolean
)
language sql stable set search_path = public, private as $$
  select
    r.id,
    r.from_user,
    p.prenom,
    h.age,
    h.photo_principale,
    h.profil_verifie,
    r.type_rencontre,
    r.compat_rate,
    r.ecran_ordre,
    r.ecran_ordre[1],
    private.distance_palier(u, r.from_user),
    private.statut_effectif(r),
    case
      when private.statut_effectif(r) not in ('en_attente','reportee') then 0
      when r.expires_at is null then null            -- pas encore ouverte : chrono non demarre
      else greatest(0, extract(epoch from r.expires_at - now()))::int
    end,
    (r.postpone_count = 0)
  from public.chat_requests r
  join public.profiles p on p.id = r.from_user
  cross join lateral private.profile_header(r.from_user) h
  where r.to_user = u
    and (
      private.statut_effectif(r) in ('en_attente','reportee')
      or (r.status = 'expiree' and r.responded_at > now() - interval '1 hour')
    )
    and not private.est_exclu(u, r.from_user)
  order by
    (private.statut_effectif(r) in ('en_attente','reportee')) desc,
    r.compat_rate desc nulls last,
    r.created_at desc
  limit 20;
$$;

comment on function private.boite_reception is
  'ecran_vignette est le premier des trois ecrans choisi par l''emetteur : c''est ce qu''il a decide de mettre en avant. secondes_restantes est nul tant que la demande n''a pas ete ouverte. Les demandes expirees depuis moins d''une heure restent listees pour permettre l''affichage floute, mais leur statut effectif interdit toute action.';

create or replace function public.boite_reception()
returns table (
  demande_id       uuid,
  emetteur         uuid,
  prenom           text,
  age              integer,
  photo_principale text,
  profil_verifie   boolean,
  type_rencontre   public.rencontre_type,
  compat_rate      numeric,
  ecran_ordre      public.score_group[],
  ecran_vignette   public.score_group,
  distance         text,
  statut           public.chat_request_status,
  secondes_restantes integer,
  reportable       boolean
)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.boite_reception(auth.uid());
end $$;

revoke all on function public.boite_reception() from public;
grant execute on function public.boite_reception() to authenticated;;
