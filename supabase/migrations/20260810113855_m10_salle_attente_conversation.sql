-- =========================================================
-- M10 - Salle d'attente avant la conversation de 5 minutes
--
-- Deux "oui" ne demarrent pas le chronometre. Ils creent une
-- conversation prete. Le compte a rebours ne part que lorsque
-- les deux personnes sont reellement presentes : sinon une
-- rencontre se perd parce que l'un etait hors ligne.
--
-- Trois etats : interet mutuel -> prete -> demarree.
-- =========================================================

alter table public.profiles
  add column if not exists last_seen_at timestamptz;

comment on column public.profiles.last_seen_at is
  'Dernier signe de vie. Sert a determiner la presence effective, distincte de l''acceptation.';

create index if not exists profiles_last_seen on public.profiles (last_seen_at desc);

alter table public.conversations
  add column if not exists prete_at      timestamptz not null default now(),
  add column if not exists presence_a_at timestamptz,
  add column if not exists presence_b_at timestamptz;

alter table public.conversations alter column started_at drop not null;
alter table public.conversations alter column started_at drop default;
alter table public.conversations alter column ends_at   drop not null;
alter table public.conversations alter column ends_at   drop default;
alter table public.conversations alter column status    set default 'prete';

comment on column public.conversations.prete_at is
  'Moment ou les deux ont accepte. La conversation existe des cet instant, mais rien ne s''ecoule encore.';
comment on column public.conversations.started_at is
  'Nul tant que les deux personnes n''ont pas ete presentes simultanement. C''est ici, et seulement ici, que les cinq minutes commencent.';

alter table public.conversations
  drop constraint if exists conversations_demarrage_coherent;
alter table public.conversations
  add constraint conversations_demarrage_coherent
  check (num_nulls(started_at, ends_at) <> 1);

insert into public.engine_params (key, value, description) values
  ('presence_fraicheur_s',        45, 'Duree pendant laquelle un signe de vie vaut presence, en secondes.'),
  ('conversation_prete_peremption_h', 48, 'Delai au-dela duquel une conversation prete mais jamais demarree est cloturee.'),
  ('conversation_decompte_s',      3, 'Duree du decompte affiche avant le demarrage effectif.')
on conflict (key) do nothing;

-- ---------------------------------------------------------
-- 1. Signaler sa presence
-- ---------------------------------------------------------
create or replace function private.signaler_presence(u uuid)
returns integer
language plpgsql set search_path = public, private as $$
declare n integer;
begin
  update public.profiles set last_seen_at = now() where id = u;

  -- Conversations pretes dont l'autre attend : de quoi le prevenir
  select count(*) into n
  from public.conversations c
  where c.status = 'prete' and (c.user_a = u or c.user_b = u);
  return n;
end $$;

comment on function private.signaler_presence is
  'Le retour en ligne d''un utilisateur est ce qui permet de prevenir celui qui attend. Sans ce signal, la salle d''attente resterait muette.';

-- ---------------------------------------------------------
-- 2. Rejoindre : c'est la presence conjointe qui demarre
-- ---------------------------------------------------------
create or replace function private.rejoindre_conversation(u uuid, p_conv uuid)
returns table (statut public.conversation_status, demarree boolean,
               attend_qui uuid, decompte_s integer, secondes_restantes integer)
language plpgsql set search_path = public, private as $$
declare
  c        public.conversations;
  v_frais  interval := (private.engine_param('presence_fraicheur_s') || ' seconds')::interval;
  v_autre  uuid;
  v_pres_a timestamptz;
  v_pres_b timestamptz;
begin
  select * into c from public.conversations where id = p_conv for update;
  if c.id is null or (c.user_a <> u and c.user_b <> u) then
    raise exception 'Conversation introuvable' using errcode = 'no_data_found';
  end if;

  if c.status in ('verrouillee','cloturee') then
    return query select c.status, false, null::uuid, 0, 0; return;
  end if;

  -- On note la presence de l'appelant
  if c.user_a = u then
    update public.conversations set presence_a_at = now() where id = p_conv;
  else
    update public.conversations set presence_b_at = now() where id = p_conv;
  end if;

  select presence_a_at, presence_b_at into v_pres_a, v_pres_b
  from public.conversations where id = p_conv;

  -- Deja demarree : on rend simplement le temps restant
  if c.status = 'active' then
    return query select 'active'::public.conversation_status, false, null::uuid,
                        0, greatest(0, extract(epoch from c.ends_at - now()))::int;
    return;
  end if;

  v_autre := case when c.user_a = u then c.user_b else c.user_a end;

  -- Presence conjointe : le chronometre part enfin
  if v_pres_a is not null and v_pres_b is not null
     and v_pres_a > now() - v_frais and v_pres_b > now() - v_frais then
    update public.conversations
       set status     = 'active',
           started_at = now() + (private.engine_param('conversation_decompte_s') || ' seconds')::interval,
           ends_at    = now() + (private.engine_param('conversation_decompte_s') || ' seconds')::interval
                        + (private.engine_param('conversation_duree_s') || ' seconds')::interval
     where id = p_conv;

    return query select 'active'::public.conversation_status, true, null::uuid,
                        private.engine_param('conversation_decompte_s')::int,
                        private.engine_param('conversation_duree_s')::int;
    return;
  end if;

  -- Sinon on attend l'autre, sans que rien ne s'ecoule
  return query select 'prete'::public.conversation_status, false, v_autre, 0, null::int;
end $$;

comment on function private.rejoindre_conversation is
  'Le demarrage n''est jamais decide par une acceptation mais par une presence conjointe et fraiche. Tant qu''un seul est la, aucune seconde n''est consommee.';

-- ---------------------------------------------------------
-- 3. Etat lisible pour la messagerie
-- ---------------------------------------------------------
create or replace function private.etat_conversation(u uuid, p_conv uuid)
returns table (statut public.conversation_status, autre uuid, prenom_autre text,
               autre_en_ligne boolean, secondes_restantes integer, message text)
language sql stable set search_path = public, private as $$
  with c as (select * from public.conversations where id = p_conv and (user_a = u or user_b = u)),
       a as (select case when c.user_a = u then c.user_b else c.user_a end as autre from c)
  select c.status, a.autre, p.prenom,
         coalesce(p.last_seen_at > now() - (private.engine_param('presence_fraicheur_s') || ' seconds')::interval, false),
         case when c.status = 'active' and c.ends_at is not null
              then greatest(0, extract(epoch from c.ends_at - now()))::int end,
         case
           when c.status = 'prete'
                and coalesce(p.last_seen_at > now() - (private.engine_param('presence_fraicheur_s') || ' seconds')::interval, false)
             then p.prenom || ' est de nouveau en ligne. Votre conversation est prête à commencer.'
           when c.status = 'prete'
             then 'Votre conversation est prête. Nous attendons que vous soyez tous les deux disponibles.'
           when c.status = 'active'      then 'Conversation en cours.'
           when c.status = 'verrouillee' then 'Le temps est écoulé.'
           else 'Conversation close.'
         end
  from c, a
  join public.profiles p on p.id = a.autre;
$$;

comment on function private.etat_conversation is
  'Le message distingue les deux situations d''attente : l''autre est hors ligne, ou l''autre vient de revenir. La seconde appelle une notification, pas la premiere.';

-- ---------------------------------------------------------
-- 4. Creation en etat prêt, jamais demarree
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

  if reponse = 'plus_tard' then
    if r.postpone_count >= 1 then
      raise exception 'Cette demande a déjà été reportée' using errcode = 'check_violation';
    end if;
    update public.chat_requests
       set status = 'reportee', postponed_at = now(), postpone_count = postpone_count + 1,
           opened_at = coalesce(opened_at, now()),
           expires_at = coalesce(expires_at, now())
                        + (private.engine_param('demande_sursis_report_h') || ' hours')::interval
     where id = demande;
    return null;
  end if;

  if reponse = 'non' then
    update public.chat_requests set status = 'refusee', responded_at = now() where id = demande;
    perform private.exclure(r.from_user, r.to_user, u, 'refus_conversation',
      (private.engine_param('demande_exclusion_refus_mois') || ' months')::interval, r.id);
    return null;
  end if;

  update public.chat_requests set status = 'acceptee', responded_at = now() where id = demande;

  -- Conversation creee mais a l'arret : ni started_at, ni ends_at
  insert into public.conversations (request_id, user_a, user_b, status, prete_at)
  values (demande, r.from_user, r.to_user, 'prete', now())
  returning id into v_conv;

  return v_conv;
end $$;

comment on function private.repondre_demande is
  'Une acceptation cree la conversation mais ne la demarre pas. Le refus reste silencieux cote emetteur et pose une exclusion mutuelle.';

-- ---------------------------------------------------------
-- 5. Entretien : ne verrouiller que ce qui tourne
-- ---------------------------------------------------------
create or replace function private.verrouiller_conversations()
returns integer
language plpgsql set search_path = public, private as $$
declare n integer; m integer;
begin
  update public.conversations
     set status = 'verrouillee', locked_at = now()
   where status = 'active' and not illimitee
     and ends_at is not null and ends_at <= now();
  get diagnostics n = row_count;

  -- Une conversation prete depuis trop longtemps n'aboutira pas
  update public.conversations
     set status = 'cloturee', locked_at = now()
   where status = 'prete'
     and prete_at <= now() - (private.engine_param('conversation_prete_peremption_h') || ' hours')::interval;
  get diagnostics m = row_count;

  return n + m;
end $$;

-- ---------------------------------------------------------
-- 6. Wrappers publics
-- ---------------------------------------------------------
create or replace function public.signaler_presence()
returns integer
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.signaler_presence(auth.uid());
end $$;

create or replace function public.rejoindre_conversation(conversation uuid)
returns table (statut public.conversation_status, demarree boolean, attend_qui uuid,
               decompte_s integer, secondes_restantes integer)
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.rejoindre_conversation(auth.uid(), conversation);
end $$;

create or replace function public.etat_conversation(conversation uuid)
returns table (statut public.conversation_status, autre uuid, prenom_autre text,
               autre_en_ligne boolean, secondes_restantes integer, message text)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.etat_conversation(auth.uid(), conversation);
end $$;

revoke all on function public.signaler_presence() from public;
revoke all on function public.rejoindre_conversation(uuid) from public;
revoke all on function public.etat_conversation(uuid) from public;
grant execute on function public.signaler_presence() to authenticated;
grant execute on function public.rejoindre_conversation(uuid) to authenticated;
grant execute on function public.etat_conversation(uuid) to authenticated;;
