-- =========================================================
-- M8 - Machine a etats des demandes de conversation
-- Etend l'existant : la signature de repondre_demande est
-- conservee a l'identique (returns uuid) pour ne pas casser
-- le contrat cote application.
-- =========================================================

insert into public.engine_params (key, value, description) values
  ('demande_delai_reponse_min',    30, 'Delai de reponse a une demande de conversation, en minutes. Demarre a la premiere ouverture par le destinataire, pas a l''envoi.'),
  ('demande_peremption_h',         24, 'Duree au-dela de laquelle une demande jamais ouverte expire d''elle-meme, en heures.'),
  ('demande_sursis_report_h',       2, 'Sursis accorde par un report (plus tard), en heures. Utilisable une seule fois par demande.'),
  ('demande_cooldown_relance_h',   24, 'Delai minimal avant de pouvoir readresser une demande a la meme personne, en heures.'),
  ('demande_max_tentatives',        3, 'Nombre maximal de demandes vers une meme personne sur la fenetre glissante.'),
  ('demande_fenetre_tentatives_j', 30, 'Largeur de la fenetre glissante de comptage des tentatives, en jours.'),
  ('demande_exclusion_refus_mois',  6, 'Duree de l''exclusion mutuelle posee par un refus, en mois.'),
  ('demande_file_active_max',       8, 'Nombre maximal de demandes actives simultanees dans la boite de reception d''un utilisateur.')
on conflict (key) do nothing;

-- ---------------------------------------------------------
-- 1. Eligibilite
-- ---------------------------------------------------------
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

  select * into v_compat from private.compat_score(u, cible);
  if not v_compat.filtres_ok then
    return query select false, 'incompatibilite_absolue'; return;
  end if;

  return query select true, null::text;
end $$;

comment on function private.peut_proposer is
  'Motifs volontairement generiques. indisponible couvre le blocage, l''exclusion, la desactivation et la saturation de file : l''emetteur ne peut pas deduire lequel s''applique, ni rien apprendre du profil cible.';

-- ---------------------------------------------------------
-- 2. Envoi
-- ---------------------------------------------------------
create or replace function private.proposer_conversation(
  u      uuid,
  cible  uuid,
  p_type public.rencontre_type,
  ordre  public.score_group[] default array['physique','valeurs','mode_vie']::public.score_group[]
) returns uuid
language plpgsql set search_path = public, private as $$
declare
  v_check  record;
  v_compat record;
  v_id     uuid;
begin
  select * into v_check from private.peut_proposer(u, cible);
  if not v_check.autorise then
    raise exception 'Demande impossible (%)', v_check.motif using errcode = 'check_violation';
  end if;

  if not (p_type = any (select intentions from public.profiles where id = cible)) then
    raise exception 'Demande impossible (incompatibilite_absolue)' using errcode = 'check_violation';
  end if;

  if cardinality(ordre) <> 3
     or cardinality(array(select distinct unnest(ordre))) <> 3 then
    raise exception 'Ordre des ecrans invalide' using errcode = 'check_violation';
  end if;

  select * into v_compat from private.compat_score(u, cible);

  insert into public.chat_requests
    (from_user, to_user, type_rencontre, compat_rate, ecran_ordre, stale_at)
  values
    (u, cible, p_type, v_compat.score_global, ordre,
     now() + (private.engine_param('demande_peremption_h') || ' hours')::interval)
  returning id into v_id;

  return v_id;
end $$;

comment on function private.proposer_conversation is
  'expires_at reste nul a l''envoi : le delai de reponse ne demarre qu''a la premiere ouverture par le destinataire. Seul stale_at court des l''emission.';

-- ---------------------------------------------------------
-- 3. Ouverture par le destinataire
-- ---------------------------------------------------------
create or replace function private.ouvrir_demande(u uuid, demande uuid)
returns public.chat_request_status
language plpgsql set search_path = public, private as $$
declare r public.chat_requests;
begin
  select * into r from public.chat_requests where id = demande for update;
  if r is null or r.to_user <> u then
    raise exception 'Demande introuvable' using errcode = 'no_data_found';
  end if;

  if r.status in ('en_attente','reportee') and private.statut_effectif(r) = 'expiree' then
    update public.chat_requests set status = 'expiree' where id = demande;
    return 'expiree';
  end if;

  if r.opened_at is null and r.status = 'en_attente' then
    update public.chat_requests
       set opened_at  = now(),
           expires_at = now() + (private.engine_param('demande_delai_reponse_min') || ' minutes')::interval
     where id = demande;
  end if;

  return r.status;
end $$;

comment on function private.ouvrir_demande is
  'Demarre le compte a rebours de 30 minutes. Idempotente : une demande deja ouverte n''est pas reinitialisee.';

-- ---------------------------------------------------------
-- 4. Reponse : oui / non / plus tard
-- ---------------------------------------------------------
create or replace function private.repondre_demande(u uuid, demande uuid, reponse public.date_intent)
returns uuid
language plpgsql set search_path = public, private as $$
declare r public.chat_requests; v_conv uuid;
begin
  select * into r from public.chat_requests where id = demande for update;
  if r is null or r.to_user <> u then
    raise exception 'Demande introuvable' using errcode = 'no_data_found';
  end if;

  if r.status not in ('en_attente','reportee') then
    raise exception 'Cette demande a déjà été traitée' using errcode = 'check_violation';
  end if;

  if private.statut_effectif(r) = 'expiree' then
    update public.chat_requests set status = 'expiree', responded_at = now() where id = demande;
    raise exception 'Cette demande a expiré' using errcode = 'check_violation';
  end if;

  -- Report : gele l'echeance et accorde un sursis unique
  if reponse = 'plus_tard' then
    if r.postpone_count >= 1 then
      raise exception 'Cette demande a déjà été reportée' using errcode = 'check_violation';
    end if;
    update public.chat_requests
       set status         = 'reportee',
           postponed_at   = now(),
           postpone_count = postpone_count + 1,
           opened_at      = coalesce(opened_at, now()),
           expires_at     = coalesce(expires_at, now())
                            + (private.engine_param('demande_sursis_report_h') || ' hours')::interval
     where id = demande;
    return null;
  end if;

  -- Refus : silencieux cote emetteur, exclusion mutuelle
  if reponse = 'non' then
    update public.chat_requests
       set status = 'refusee', responded_at = now()
     where id = demande;

    perform private.exclure(
      r.from_user, r.to_user, u, 'refus_conversation',
      (private.engine_param('demande_exclusion_refus_mois') || ' months')::interval,
      r.id);
    return null;
  end if;

  -- Acceptation
  update public.chat_requests
     set status = 'acceptee', responded_at = now()
   where id = demande;

  insert into public.conversations (request_id, user_a, user_b, ends_at)
  values (demande, r.from_user, r.to_user,
          now() + (private.engine_param('conversation_duree_s') || ' seconds')::interval)
  returning id into v_conv;

  return v_conv;
end $$;

comment on function private.repondre_demande is
  'Le refus est silencieux : cote emetteur la demande apparait simplement comme expiree. Il declenche une exclusion mutuelle, donc la disparition reciproque des deux profils du fil de l''autre.';

-- ---------------------------------------------------------
-- 5. Wrappers publics
-- ---------------------------------------------------------
create or replace function public.proposer_conversation(
  cible uuid,
  type_rencontre public.rencontre_type,
  ordre_ecrans public.score_group[] default array['physique','valeurs','mode_vie']::public.score_group[]
) returns uuid
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.proposer_conversation(auth.uid(), cible, type_rencontre, ordre_ecrans);
end $$;

create or replace function public.ouvrir_demande(demande uuid)
returns public.chat_request_status
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.ouvrir_demande(auth.uid(), demande);
end $$;

create or replace function public.peut_proposer(cible uuid)
returns table (autorise boolean, motif text)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.peut_proposer(auth.uid(), cible);
end $$;

revoke all on function public.proposer_conversation(uuid, public.rencontre_type, public.score_group[]) from public;
revoke all on function public.ouvrir_demande(uuid) from public;
revoke all on function public.peut_proposer(uuid) from public;

grant execute on function public.proposer_conversation(uuid, public.rencontre_type, public.score_group[]) to authenticated;
grant execute on function public.ouvrir_demande(uuid) to authenticated;
grant execute on function public.peut_proposer(uuid) to authenticated;;
