create type moderation_action as enum
  ('rappel_regles','avertissement','suspension_temporaire','bannissement','classe_sans_suite');

create table moderation_actions (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles(id) on delete cascade,
  report_id    uuid references reports(id) on delete set null,
  action       moderation_action not null,
  motif        text,
  decided_by   uuid,
  decided_at   timestamptz not null default now(),
  expires_at   timestamptz,
  leve_at      timestamptz
);
create index idx_moderation_user on moderation_actions (user_id, decided_at desc);
create index idx_moderation_actives on moderation_actions (expires_at)
  where leve_at is null and expires_at is not null;

comment on table moderation_actions is
  'Historique des mesures prises. Conserve meme apres expiration : c''est lui qui permet de detecter les comportements repetes et de graduer la sanction suivante.';

alter table moderation_actions enable row level security;
create policy p_moderation_self on moderation_actions for select
  using (user_id = auth.uid() and action <> 'classe_sans_suite');

-- ---------- Messagerie plateforme ----------

create table platform_messages (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles(id) on delete cascade,
  code        text not null,
  titre       text,
  corps       text not null,
  actions     jsonb not null default '[]'::jsonb,
  a_envoyer_a timestamptz not null default now(),
  envoye_at   timestamptz,
  lu_at       timestamptz,
  created_at  timestamptz not null default now()
);
create index idx_platform_msg_user on platform_messages (user_id, created_at desc);
create index idx_platform_msg_afaire on platform_messages (a_envoyer_a) where envoye_at is null;

comment on table platform_messages is
  'Messages emis par Safe Date dans la messagerie de l''utilisateur : rappel des regles, relance d''evaluation, fin de conversation, regularisation. a_envoyer_a permet le differe prevu au cahier des charges.';

alter table platform_messages enable row level security;
create policy p_platform_msg_self on platform_messages for select
  using (user_id = auth.uid() and envoye_at is not null);

insert into engine_params (key, value, description) values
  ('moderation_delai_rappel_h',       4, 'Delai avant envoi du rappel des regles apres un signalement, en heures'),
  ('moderation_suspension_jours',     7, 'Duree d''une suspension temporaire, en jours'),
  ('moderation_seuil_avertissement',  2, 'Signalements traites avant de passer a l''avertissement'),
  ('moderation_seuil_suspension',     3, 'Mesures anterieures avant de passer a la suspension'),
  ('moderation_seuil_bannissement',   5, 'Mesures anterieures avant de proposer le bannissement')
on conflict (key) do nothing;;
