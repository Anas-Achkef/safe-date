-- ============================================================
-- Logique des transitions : les tables decrivent des etats,
-- voici ce qui fait passer de l'un a l'autre.
-- ============================================================

-- ---------- Traitements periodiques ----------

create or replace function private.expirer_demandes()
returns integer language plpgsql as $fn$
declare n integer;
begin
  update chat_requests
     set status = 'expiree', responded_at = now()
   where status = 'en_attente' and expires_at <= now();
  get diagnostics n = row_count;
  return n;
end $fn$;
comment on function private.expirer_demandes is
  'Une demande sans reponse dans le delai prevu est consideree comme ignoree. Les deux utilisateurs pourront se representer plus tard si le moteur les juge toujours compatibles.';

create or replace function private.verrouiller_conversations()
returns integer language plpgsql as $fn$
declare n integer;
begin
  update conversations
     set status = 'verrouillee', locked_at = now()
   where status = 'active' and ends_at <= now();
  get diagnostics n = row_count;
  return n;
end $fn$;
comment on function private.verrouiller_conversations is
  'Verrouillage simultane pour les deux utilisateurs a expiration du compte a rebours, afin de garantir une duree d''echange identique.';

create or replace function private.purger_cooldowns()
returns integer language plpgsql as $fn$
declare n integer;
begin
  delete from surprise_cooldowns where blocked_until <= now();
  get diagnostics n = row_count;
  return n;
end $fn$;

create or replace function private.maintenance_periodique()
returns jsonb language plpgsql as $fn$
begin
  return jsonb_build_object(
    'demandes_expirees',        private.expirer_demandes(),
    'conversations_verrouillees', private.verrouiller_conversations(),
    'cooldowns_purges',         private.purger_cooldowns(),
    'points_rdv_expires',       (select expirer_points_rendezvous()),
    'execute_a',                now()
  );
end $fn$;

-- ---------- Regles d'acces ----------

create or replace function private.compte_bloque(u uuid)
returns boolean language sql stable as $fn$
  select exists (select 1 from outstanding_debts o
                 where o.user_id = u and o.settled_at is null);
$fn$;
comment on function private.compte_bloque is
  'Tant qu''une consommation reste impayee, l''acces a l''application est bloque par un ecran de regularisation.';

create or replace function private.quota_restant(u uuid)
returns integer language sql stable as $fn$
  select case
           when (select is_premium from profiles where id = u) then null
           else greatest(0, private.engine_param('discussions_gratuit_par_jour')::int
                            - (select count(*)::int from chat_requests
                               where from_user = u
                                 and created_at >= date_trunc('day', now())))
         end;
$fn$;
comment on function private.quota_restant is
  'Nombre de nouvelles discussions encore ouvrables aujourd''hui. NULL pour un abonne : aucune limitation.';

-- ---------- Ouverture d'une discussion ----------

create or replace function private.creer_demande(u uuid, cible uuid)
returns uuid language plpgsql as $fn$
declare v_id uuid; v_quota integer; v_taux numeric;
begin
  if u = cible then
    raise exception 'Impossible de s''adresser une demande à soi-même' using errcode = 'check_violation';
  end if;
  if private.compte_bloque(u) then
    raise exception 'Régularisation requise avant toute nouvelle action' using errcode = 'check_violation';
  end if;
  if not exists (select 1 from profiles p where p.id = cible and p.is_active and p.is_verified) then
    raise exception 'Profil indisponible' using errcode = 'no_data_found';
  end if;
  if are_blocked(u, cible) then
    raise exception 'Profil indisponible' using errcode = 'no_data_found';
  end if;
  if exists (select 1 from chat_requests r
             where r.from_user = u and r.to_user = cible
               and r.status = 'en_attente' and r.expires_at > now()) then
    raise exception 'Une demande est déjà en attente auprès de cette personne' using errcode = 'unique_violation';
  end if;

  v_quota := private.quota_restant(u);
  if v_quota is not null and v_quota <= 0 then
    raise exception 'Limite quotidienne de nouvelles discussions atteinte' using errcode = 'check_violation';
  end if;

  select s.score_global into v_taux from private.compat_score(u, cible) s;

  insert into chat_requests (from_user, to_user, compat_rate, expires_at)
  values (u, cible, v_taux,
          now() + (private.engine_param('demande_expiration_s') || ' seconds')::interval)
  returning id into v_id;
  return v_id;
end $fn$;

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
     set status = case reponse when 'oui' then 'acceptee'
                               when 'non' then 'refusee'
                               else 'reportee' end,
         responded_at = now()
   where id = demande;

  if reponse = 'oui' then
    insert into conversations (request_id, user_a, user_b, ends_at)
    values (demande, r.from_user, r.to_user,
            now() + (private.engine_param('conversation_duree_s') || ' seconds')::interval)
    returning id into v_conv;
  end if;
  return v_conv;
end $fn$;

-- ---------- Anti-insistance Date Surprise ----------

create or replace function trg_surprise_cooldown() returns trigger
language plpgsql security definer set search_path to 'public','pg_temp' as $fn$
declare v_fin timestamptz;
begin
  if new.response is null or new.response = old.response then
    return null;
  end if;

  if new.response = 'accepte' then
    delete from surprise_cooldowns
     where from_user = new.from_user and to_user = new.to_user;
    return null;
  end if;

  v_fin := case new.response
             when 'indispo_jour'    then date_trunc('day',  now()) + interval '1 day'
             when 'indispo_semaine' then date_trunc('week', now()) + interval '1 week'
             when 'refus'           then now() + interval '30 days'
           end;

  -- Le blocage ne vise que l'emetteur : celui qui a decline garde la
  -- possibilite de reprendre l'initiative a tout moment.
  insert into surprise_cooldowns (from_user, to_user, blocked_until, reason)
  values (new.from_user, new.to_user, v_fin, new.response)
  on conflict (from_user, to_user) do update
    set blocked_until = greatest(surprise_cooldowns.blocked_until, excluded.blocked_until),
        reason        = excluded.reason;
  return null;
end $fn$;

create trigger surprise_proposals_cooldown
  after update of response on surprise_proposals
  for each row execute function trg_surprise_cooldown();

-- ---------- Enveloppes publiques ----------

create or replace function public.quota_restant()
returns integer language plpgsql stable security definer set search_path to 'public','pg_temp' as $fn$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.quota_restant(auth.uid());
end $fn$;

create or replace function public.creer_demande(cible uuid)
returns uuid language plpgsql security definer set search_path to 'public','pg_temp' as $fn$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.creer_demande(auth.uid(), cible);
end $fn$;

create or replace function public.repondre_demande(demande uuid, reponse date_intent)
returns uuid language plpgsql security definer set search_path to 'public','pg_temp' as $fn$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.repondre_demande(auth.uid(), demande, reponse);
end $fn$;;
