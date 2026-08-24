-- ============================================================
-- MODULE 7 — Quiz Premium, bouton Help, evaluations
-- et poursuite de la relation.
-- ============================================================

create type help_level        as enum ('discret','etablissement','angela','urgence');
create type review_status     as enum ('propose','plus_tard','passe','soumis');
create type surprise_response as enum ('accepte','indispo_jour','indispo_semaine','refus');

-- ---------- Quiz Premium ----------

create table quiz_sessions (
  id         uuid primary key default gen_random_uuid(),
  date_id    uuid not null references dates(id) on delete cascade,
  started_at timestamptz not null default now(),
  ended_at   timestamptz
);
create index idx_quizsess_date on quiz_sessions (date_id);
comment on table quiz_sessions is 'Quiz genere dynamiquement pendant le rendez-vous a partir des profils des deux utilisateurs. Reserve aux membres SAFE Premium, entierement facultatif, interruptible.';

create table quiz_questions (
  id              uuid primary key default gen_random_uuid(),
  session_id      uuid not null references quiz_sessions(id) on delete cascade,
  ordre           smallint not null default 0,
  question        text not null,
  source_pair_key text references criterion_pairs(pair_key) on delete set null,
  options         jsonb not null default '[]'::jsonb,
  created_at      timestamptz not null default now()
);
create index idx_quizq_session on quiz_questions (session_id, ordre);
comment on column quiz_questions.source_pair_key is 'Critere de compatibilite ayant inspire la question. Les points communs ne sont jamais reveles directement : ils doivent se decouvrir au fil de l''echange.';

create table quiz_answers (
  question_id uuid not null references quiz_questions(id) on delete cascade,
  user_id     uuid not null references profiles(id) on delete cascade,
  answer_idx  smallint,
  answer_text text,
  answered_at timestamptz not null default now(),
  primary key (question_id, user_id)
);
comment on table quiz_answers is 'Reponses jamais visibles par les autres utilisateurs. Servent uniquement a affiner le moteur de compatibilite. Aucune notion de bonne ou mauvaise reponse.';

-- ---------- Bouton Help ----------

create table fake_contacts (
  id               uuid primary key default gen_random_uuid(),
  genre            text not null,
  prenom           text not null,
  photo_path       text,
  message_template text not null,
  active           boolean not null default true
);
comment on table fake_contacts is 'Contacts fictifs predefinis servant a afficher une fausse conversation permettant a l''utilisateur de justifier naturellement son depart.';

create table help_requests (
  id                 uuid primary key default gen_random_uuid(),
  date_id            uuid not null references dates(id) on delete cascade,
  user_id            uuid not null references profiles(id) on delete cascade,
  level              help_level not null,
  fake_contact_id    uuid references fake_contacts(id) on delete set null,
  partner_notified_at timestamptz,
  created_at         timestamptz not null default now(),
  resolved_at        timestamptz
);
create index idx_help_date on help_requests (date_id, created_at desc);
comment on table help_requests is 'L''utilisation du bouton Help est strictement confidentielle : l''autre utilisateur n''en est jamais informe. La nature exacte de la demande n''est pas transmise a l''etablissement.';

create table help_user_reports (
  help_request_id uuid primary key references help_requests(id) on delete cascade,
  user_id         uuid not null references profiles(id) on delete cascade,
  raison          text,
  recit           text,
  comportement    text,
  ressenti        text,
  complement      text,
  submitted_at    timestamptz not null default now()
);
comment on table help_user_reports is 'Formulaire confidentiel presente a l''utilisateur une fois qu''il s''est eloigne d''au moins 350 metres de l''etablissement.';

create table help_staff_reports (
  id                 uuid primary key default gen_random_uuid(),
  help_request_id    uuid not null references help_requests(id) on delete cascade,
  partner_id         uuid not null references partners(id) on delete cascade,
  staff_identifiant  text,
  table_number       text,
  circonstances      text,
  faits              text,
  actions            text,
  depart_accompagne  boolean,
  secours_appeles    boolean,
  observations       text,
  dangerosite        smallint not null check (dangerosite between 1 and 5),
  submitted_at       timestamptz not null default now()
);
create index idx_staffrep_partner on help_staff_reports (partner_id, submitted_at desc);
comment on column help_staff_reports.dangerosite is '1 aucune situation preoccupante · 2 legerement inhabituelle · 3 vigilance particuliere · 4 preoccupant, intervention importante · 5 risque manifeste. Strictement confidentiel, jamais communique aux utilisateurs.';
comment on table help_staff_reports is 'Rapport d''intervention obligatoire au titre du contrat de partenariat. Le personnel relate des faits objectifs, sans jugement sur les utilisateurs.';

-- ---------- Evaluation de l'etablissement ----------

create table venue_reviews (
  date_id          uuid not null references dates(id) on delete cascade,
  user_id          uuid not null references profiles(id) on delete cascade,
  partner_id       uuid not null references partners(id) on delete cascade,
  note_produits    smallint check (note_produits between 1 and 5),
  note_rapport_qp  smallint check (note_rapport_qp between 1 and 5),
  note_service     smallint check (note_service between 1 and 5),
  note_globale     numeric(3,2) check (note_globale between 1 and 5),
  commentaire      text,
  publier_google   boolean not null default false,
  status           review_status not null default 'propose',
  created_at       timestamptz not null default now(),
  submitted_at     timestamptz,
  primary key (date_id, user_id)
);
create index idx_venuerev_partner on venue_reviews (partner_id, submitted_at desc);
comment on column venue_reviews.note_globale is 'Moyenne des trois criteres, proposee automatiquement mais librement modifiable par l''utilisateur.';
comment on table venue_reviews is 'Evaluation totalement independante de la qualite de la rencontre. Proposee des la sortie de l''etablissement, sans delai supplementaire.';

-- ---------- Evaluation de la rencontre ----------

create table date_reviews (
  date_id     uuid not null references dates(id) on delete cascade,
  user_id     uuid not null references profiles(id) on delete cascade,
  attirance   smallint check (attirance between 1 and 5),
  valeurs     smallint check (valeurs between 1 and 5),
  mode_vie    smallint check (mode_vie between 1 and 5),
  commentaire text,
  created_at  timestamptz not null default now(),
  primary key (date_id, user_id)
);
comment on table date_reviews is 'Strictement confidentiel : jamais communique au partenaire, jamais rendu public. Affiche seulement lorsque les deux utilisateurs sont separes d''au moins 350 metres.';

-- ---------- Poursuite de la relation ----------

create table date_followups (
  date_id    uuid not null references dates(id) on delete cascade,
  user_id    uuid not null references profiles(id) on delete cascade,
  decision   date_intent not null,
  decided_at timestamptz not null default now(),
  primary key (date_id, user_id)
);
comment on table date_followups is 'Souhait de poursuivre la discussion. Le choix de l''autre n''est jamais revele avant que les deux reponses soient enregistrees.';

create table surprise_proposals (
  id               uuid primary key default gen_random_uuid(),
  from_user        uuid not null references profiles(id) on delete cascade,
  to_user          uuid not null references profiles(id) on delete cascade,
  previous_date_id uuid references dates(id) on delete set null,
  response         surprise_response,
  created_at       timestamptz not null default now(),
  responded_at     timestamptz,
  constraint surprise_pas_soi_meme check (from_user <> to_user)
);
create index idx_surprise_dest on surprise_proposals (to_user, created_at desc);

create table surprise_cooldowns (
  from_user     uuid not null references profiles(id) on delete cascade,
  to_user       uuid not null references profiles(id) on delete cascade,
  blocked_until timestamptz not null,
  reason        surprise_response not null,
  primary key (from_user, to_user)
);
comment on table surprise_cooldowns is 'Anti-insistance : indisponible aujourd''hui bloque jusqu''au lendemain, cette semaine jusqu''a la fin de semaine, refus pendant 30 jours. Ne s''applique qu''a l''emetteur : celui qui a decline peut reprendre l''initiative a tout moment.';

-- ---------- RLS ----------

alter table quiz_sessions      enable row level security;
alter table quiz_questions     enable row level security;
alter table quiz_answers       enable row level security;
alter table fake_contacts      enable row level security;
alter table help_requests      enable row level security;
alter table help_user_reports  enable row level security;
alter table help_staff_reports enable row level security;
alter table venue_reviews      enable row level security;
alter table date_reviews       enable row level security;
alter table date_followups     enable row level security;
alter table surprise_proposals enable row level security;
alter table surprise_cooldowns enable row level security;

create policy p_fakecontacts_read on fake_contacts for select
  using (active);

create policy p_quizsess_partie on quiz_sessions for select
  using (date_id in (select id from dates where user_a = auth.uid() or user_b = auth.uid()));
create policy p_quizq_partie on quiz_questions for select
  using (session_id in (select s.id from quiz_sessions s join dates d on d.id = s.date_id
                        where d.user_a = auth.uid() or d.user_b = auth.uid()));
create policy p_quizans_self on quiz_answers for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy p_help_self on help_requests for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy p_helpuserrep_self on help_user_reports for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy p_helpstaffrep_partenaire on help_staff_reports for all
  using (partner_id in (select id from partners where owner_id = auth.uid()))
  with check (partner_id in (select id from partners where owner_id = auth.uid()));

create policy p_venuerev_self on venue_reviews for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy p_daterev_self on date_reviews for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy p_followup_self on date_followups for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy p_surprise_partie on surprise_proposals for select
  using (from_user = auth.uid() or to_user = auth.uid());
create policy p_surprise_envoi on surprise_proposals for insert
  with check (from_user = auth.uid());
create policy p_cooldown_emetteur on surprise_cooldowns for select
  using (from_user = auth.uid());;
