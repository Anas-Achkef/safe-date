create or replace function private.repondre_demande(u uuid, demande uuid, reponse date_intent)
returns uuid language plpgsql as $fn$
declare r chat_requests; v_conv uuid;
begin
  select * into r from chat_requests where id = demande;
  if r is null or r.to_user <> u then
    raise exception 'Demande introuvable' using errcode = 'no_data_found';
  end if;
  if r.status <> 'en_attente' then
    raise exception 'Cette demande a déjà été traitée' using errcode = 'check_violation';
  end if;
  if r.expires_at <= now() then
    update chat_requests set status = 'expiree', responded_at = now() where id = demande;
    raise exception 'Cette demande a expiré' using errcode = 'check_violation';
  end if;

  update chat_requests
     set status = (case reponse when 'oui' then 'acceptee'
                                when 'non' then 'refusee'
                                else 'reportee' end)::chat_request_status,
         responded_at = now()
   where id = demande;

  if reponse = 'oui' then
    insert into conversations (request_id, user_a, user_b, ends_at)
    values (demande, r.from_user, r.to_user,
            now() + (private.engine_param('conversation_duree_s') || ' seconds')::interval)
    returning id into v_conv;
  end if;
  return v_conv;
end $fn$;;
