-- ============================================================
-- Reproposer un Date Surprise apres une premiere rencontre.
-- ============================================================

create or replace function private.peut_reproposer(u uuid, cible uuid)
returns boolean language sql stable as
$fn$
  select not exists (select 1 from surprise_cooldowns c
                     where c.from_user = u and c.to_user = cible
                       and c.blocked_until > now());
$fn$;

create or replace function private.reproposer_date_surprise(u uuid, cible uuid)
returns uuid language plpgsql as $fn$
declare v_id uuid; v_date uuid;
begin
  if private.compte_bloque(u) then
    raise exception 'Régularisation requise avant toute nouvelle action' using errcode = 'check_violation';
  end if;
  if not private.peut_reproposer(u, cible) then
    raise exception 'Vous ne pouvez pas reproposer de Date Surprise à cette personne pour le moment'
      using errcode = 'check_violation';
  end if;

  -- La reproposition suppose une rencontre precedente cloturee.
  select d.id into v_date from dates d
   where ((d.user_a = u and d.user_b = cible) or (d.user_a = cible and d.user_b = u))
     and d.closed_at is not null
   order by d.closed_at desc limit 1;
  if v_date is null then
    raise exception 'Aucun rendez-vous précédent avec cette personne' using errcode = 'no_data_found';
  end if;

  -- Un recours au bouton Help ferme definitivement la relation.
  if exists (select 1 from help_requests h where h.date_id = v_date) then
    raise exception 'Cette relation ne peut pas être relancée' using errcode = 'check_violation';
  end if;

  if exists (select 1 from surprise_proposals s
             where s.from_user = u and s.to_user = cible and s.response is null) then
    raise exception 'Une proposition est déjà en attente' using errcode = 'unique_violation';
  end if;

  insert into surprise_proposals (from_user, to_user, previous_date_id)
  values (u, cible, v_date) returning id into v_id;
  return v_id;
end $fn$;

create or replace function private.repondre_surprise(u uuid, prop uuid, p_reponse surprise_response)
returns jsonb language plpgsql as $fn$
declare s surprise_proposals; v_fin timestamptz;
begin
  select * into s from surprise_proposals where id = prop and to_user = u;
  if s is null then
    raise exception 'Proposition introuvable' using errcode = 'no_data_found';
  end if;
  if s.response is not null then
    raise exception 'Cette proposition a déjà reçu une réponse' using errcode = 'check_violation';
  end if;

  -- Le declencheur surprise_proposals_cooldown pose le blocage adapte.
  update surprise_proposals set response = p_reponse, responded_at = now()
   where id = prop;

  select blocked_until into v_fin from surprise_cooldowns
   where from_user = s.from_user and to_user = s.to_user;

  return jsonb_build_object(
    'reponse', p_reponse,
    'nouveau_parcours', p_reponse = 'accepte',
    'emetteur_bloque_jusquau', v_fin,
    'destinataire_peut_reprendre_initiative', true);
end $fn$;

comment on function private.repondre_surprise is
  'Le blocage anti-insistance ne vise que l''emetteur. Celui qui a decline conserve la possibilite de reproposer lui-meme a tout moment.';

-- ---------- Nouveau parcours apres acceptation ----------

create or replace function private.ouvrir_parcours_surprise(
  u uuid, prop uuid, creneau timestamptz)
returns uuid language plpgsql as $fn$
declare s surprise_proposals; v_conv uuid; v_req uuid;
begin
  select * into s from surprise_proposals where id = prop
     and (from_user = u or to_user = u) and response = 'accepte';
  if s is null then
    raise exception 'Proposition introuvable ou non acceptée' using errcode = 'no_data_found';
  end if;

  -- Une nouvelle conversation illimitee sert de support au parcours :
  -- les deux se connaissent deja, il n'y a plus de compte a rebours.
  insert into chat_requests (from_user, to_user, status, responded_at)
  values (s.from_user, s.to_user, 'acceptee', now()) returning id into v_req;

  insert into conversations (request_id, user_a, user_b, ends_at, illimitee)
  values (v_req, s.from_user, s.to_user, creneau, true) returning id into v_conv;

  insert into dates (user_a, user_b, partner_id, conversation_id, creneau_debut, status)
  select s.from_user, s.to_user, null, v_conv, creneau, 'en_preparation'
  where false;

  return v_conv;
end $fn$;

comment on function private.ouvrir_parcours_surprise is
  'Ouvre le parcours d''organisation apres acceptation. La selection de l''etablissement reprend le meme mecanisme que pour un premier rendez-vous, en privilegiant un lieu different de ceux deja visites ensemble.';

-- ---------- Enveloppes publiques ----------

create or replace function public.envoyer_message(
  conv uuid, p_kind message_kind default 'texte', p_body text default null,
  p_media text default null, p_duree integer default null)
returns uuid language plpgsql security definer set search_path to 'public','pg_temp' as $fn$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.envoyer_message(auth.uid(), conv, p_kind, p_body, p_media, p_duree);
end $fn$;

create or replace function public.reproposer_date_surprise(cible uuid)
returns uuid language plpgsql security definer set search_path to 'public','pg_temp' as $fn$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.reproposer_date_surprise(auth.uid(), cible);
end $fn$;

create or replace view private.v_fonctions_definisseur_exposees as
  select p.proname as fonction,
         pg_get_function_identity_arguments(p.oid) as arguments,
         case when p.prosecdef then 'CRITIQUE — droits définisseur'
              else 'À VÉRIFIER — droits appelant' end as gravite
  from pg_proc p
  join pg_namespace ns on ns.oid = p.pronamespace
  where ns.nspname = 'public'
    and p.prorettype <> 'trigger'::regtype::oid
    and ('uuid'::regtype::oid = any (p.proargtypes::oid[]))
    and pg_get_function_identity_arguments(p.oid) !~ '^(p_id |p )?uuid$'
    and p.proname <> all (array[
      'check_partner_eligibility','partner_activation_checklist','activate_partner',
      'partner_progress','diagnostic_zones','menu_label_conflit','are_blocked',
      'has_consent','set_primary_photo','reveal_establishment','compat_score',
      'creer_demande','repondre_demande','envoyer_message','reproposer_date_surprise'
    ]::name[])
  order by p.proname;;
