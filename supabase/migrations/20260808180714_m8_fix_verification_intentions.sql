create or replace function private.proposer_conversation(
  u      uuid,
  cible  uuid,
  p_type public.rencontre_type,
  ordre  public.score_group[] default array['physique','valeurs','mode_vie']::public.score_group[]
) returns uuid
language plpgsql set search_path = public, private as $$
declare
  v_check      record;
  v_compat     record;
  v_intentions public.rencontre_type[];
  v_id         uuid;
begin
  select * into v_check from private.peut_proposer(u, cible);
  if not v_check.autorise then
    raise exception 'Demande impossible (%)', v_check.motif using errcode = 'check_violation';
  end if;

  select intentions into v_intentions from public.profiles where id = cible;
  if not (p_type = any (v_intentions)) then
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
  'expires_at reste nul a l''envoi : le delai de reponse ne demarre qu''a la premiere ouverture par le destinataire. Seul stale_at court des l''emission. Le type de rencontre est valide serveur contre les intentions declarees du destinataire, avec un motif indistinguable de l''incompatibilite absolue.';;
