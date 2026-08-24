-- ============================================================
-- MODULE 5 — Onglet "Proposer un date" : disponibilites,
-- demandes de discussion, conversation chronometree.
-- ============================================================

create type chat_request_status as enum ('en_attente','acceptee','refusee','reportee','expiree');
create type conversation_status  as enum ('active','verrouillee','cloturee');
create type message_kind         as enum ('texte','vocal');
create type date_intent          as enum ('oui','non','plus_tard');
create type focus_context        as enum ('swipe','profil','conversation','decision_date','etablissement');

-- ---------- Disponibilites ----------

create table availability_windows (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references profiles(id) on delete cascade,
  debut      timestamptz not null,
  fin        timestamptz not null,
  created_at timestamptz not null default now(),
  constraint availability_ordre check (fin > debut)
);
create index idx_availability_user_debut on availability_windows (user_id, debut);
comment on table availability_windows is 'Creneaux pendant lesquels l''utilisateur se declare disponible pour partir en date.';

alter table profiles
  add column always_available     boolean not null default false,
  add column notify_when_offline  boolean not null default false;
comment on column profiles.always_available    is 'Option SAFE Premium : disponibilite consideree comme permanente (24h/24).';
comment on column profiles.notify_when_offline is 'Option SAFE Premium : notifier les demandes de discussion meme hors application.';

-- ---------- Demandes d'ouverture de discussion ----------

create table chat_requests (
  id           uuid primary key default gen_random_uuid(),
  from_user    uuid not null references profiles(id) on delete cascade,
  to_user      uuid not null references profiles(id) on delete cascade,
  compat_rate  numeric(5,2),
  status       chat_request_status not null default 'en_attente',
  created_at   timestamptz not null default now(),
  expires_at   timestamptz not null default (now() + interval '30 minutes'),
  responded_at timestamptz,
  constraint chat_request_pas_soi_meme check (from_user <> to_user)
);
create index idx_chat_req_dest    on chat_requests (to_user, status, created_at desc);
create index idx_chat_req_exp     on chat_requests (from_user, created_at desc);
create index idx_chat_req_pending on chat_requests (expires_at) where status = 'en_attente';
comment on table chat_requests is 'Demande d''ouverture de discussion. Delai de reponse de 30 minutes, au-dela la demande expire et est consideree comme ignoree.';

-- Quota : 3 nouvelles discussions par jour en version gratuite, illimite en Premium.
create view v_chat_requests_du_jour as
  select from_user, count(*) as envoyees
  from chat_requests
  where created_at >= date_trunc('day', now())
  group by from_user;

-- ---------- Conversation chronometree ----------

create table conversations (
  id         uuid primary key default gen_random_uuid(),
  request_id uuid not null unique references chat_requests(id) on delete cascade,
  user_a     uuid not null references profiles(id) on delete cascade,
  user_b     uuid not null references profiles(id) on delete cascade,
  started_at timestamptz not null default now(),
  ends_at    timestamptz not null default (now() + interval '5 minutes'),
  locked_at  timestamptz,
  status     conversation_status not null default 'active'
);
create index idx_conv_a on conversations (user_a, started_at desc);
create index idx_conv_b on conversations (user_b, started_at desc);
comment on table conversations is 'Espace d''echange de 5 minutes ouvert lorsqu''une demande de discussion est acceptee. Verrouillage automatique a expiration, simultane pour les deux utilisateurs.';

create table messages (
  id              uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references conversations(id) on delete cascade,
  sender_id       uuid not null references profiles(id) on delete cascade,
  kind            message_kind not null default 'texte',
  body            text,
  audio_path      text,
  duration_ms     integer,
  created_at      timestamptz not null default now(),
  constraint message_contenu check (
    (kind = 'texte' and body is not null) or
    (kind = 'vocal' and audio_path is not null)
  )
);
create index idx_msg_conv on messages (conversation_id, created_at);
comment on table messages is 'Seuls le texte et le message vocal sont autorises pendant la conversation : ni photo, ni fichier, ni lien, ni coordonnees.';

create table conversation_decisions (
  conversation_id uuid not null references conversations(id) on delete cascade,
  user_id         uuid not null references profiles(id) on delete cascade,
  decision        date_intent not null,
  decided_at      timestamptz not null default now(),
  primary key (conversation_id, user_id)
);
comment on table conversation_decisions is 'Reponse a "Souhaitez-vous partir en date aujourd''hui ?" a l''issue des 5 minutes.';

-- ---------- Focus Compatibilite ----------

create table focus_compatibilite (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references profiles(id) on delete cascade,
  context          focus_context not null,
  target_user_id   uuid references profiles(id) on delete set null,
  target_partner_id uuid references partners(id) on delete set null,
  question         text not null,
  reponse          text,
  created_at       timestamptz not null default now(),
  answered_at      timestamptz
);
create index idx_focus_user on focus_compatibilite (user_id, created_at desc);
comment on table focus_compatibilite is 'Question posee par le moteur lorsqu''une decision utilisateur parait difficile a expliquer. Donnee d''apprentissage a forte valeur.';

-- ---------- RLS ----------

alter table availability_windows  enable row level security;
alter table chat_requests         enable row level security;
alter table conversations         enable row level security;
alter table messages              enable row level security;
alter table conversation_decisions enable row level security;
alter table focus_compatibilite   enable row level security;

create policy p_avail_self  on availability_windows for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy p_chatreq_partie on chat_requests for select
  using (from_user = auth.uid() or to_user = auth.uid());
create policy p_chatreq_envoi  on chat_requests for insert
  with check (from_user = auth.uid());

create policy p_conv_partie on conversations for select
  using (user_a = auth.uid() or user_b = auth.uid());

create policy p_msg_partie on messages for select
  using (conversation_id in (select id from conversations where user_a = auth.uid() or user_b = auth.uid()));
create policy p_msg_envoi on messages for insert
  with check (sender_id = auth.uid()
    and conversation_id in (select id from conversations where user_a = auth.uid() or user_b = auth.uid()));

create policy p_convdec_self on conversation_decisions for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy p_focus_self on focus_compatibilite for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());;
