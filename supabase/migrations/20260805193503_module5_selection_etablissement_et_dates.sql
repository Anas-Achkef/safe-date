-- ============================================================
-- MODULE 5 — Selection de l'etablissement partenaire (swipe)
-- et rattachement du rendez-vous a la conversation d'origine.
-- ============================================================

create type venue_proposal_status as enum ('en_cours','acceptee','refusee','epuisee');

create table venue_proposals (
  id              uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references conversations(id) on delete cascade,
  partner_id      uuid not null references partners(id) on delete cascade,
  ordre           smallint not null default 0,
  creneau_debut   timestamptz not null,
  score_pertinence numeric(6,3),
  status          venue_proposal_status not null default 'en_cours',
  created_at      timestamptz not null default now(),
  unique (conversation_id, partner_id)
);
create index idx_venueprop_conv on venue_proposals (conversation_id, ordre);
comment on table venue_proposals is 'Etablissements proposes un par un aux deux utilisateurs. Le nom, l''adresse exacte, les coordonnees et les photos restent masques jusqu''a confirmation du rendez-vous.';

create table venue_votes (
  proposal_id uuid not null references venue_proposals(id) on delete cascade,
  user_id     uuid not null references profiles(id) on delete cascade,
  accepted    boolean not null,
  decided_at  timestamptz not null default now(),
  duree_ms    integer,
  primary key (proposal_id, user_id)
);
comment on table venue_votes is 'Swipe droite = accepte, gauche = refuse. Un seul refus ecarte definitivement l''etablissement pour cette rencontre.';

-- ---------- Extension de la table dates ----------

alter table dates
  add column conversation_id    uuid references conversations(id) on delete set null,
  add column mode_rdv_active_at timestamptz,
  add column ended_at           timestamptz,
  add column closed_at          timestamptz,
  add column ended_by           uuid references profiles(id) on delete set null,
  add column table_number       text;

comment on column dates.mode_rdv_active_at is 'Horodatage d''activation du Mode Rendez-vous, declenche quand la presence des deux utilisateurs dans l''etablissement est confirmee.';
comment on column dates.ended_at  is 'Moment ou "Terminer le rendez-vous" a ete confirme. Reversible tant que closed_at est nul.';
comment on column dates.closed_at is 'Cloture definitive : les deux utilisateurs ont quitte l''etablissement et toutes les consommations sont reglees.';

create index idx_dates_conv on dates (conversation_id);

create table date_presence (
  date_id      uuid not null references dates(id) on delete cascade,
  user_id      uuid not null references profiles(id) on delete cascade,
  arrived_at   timestamptz,
  confirmed_at timestamptz,
  left_at      timestamptz,
  distance_m   integer,
  primary key (date_id, user_id)
);
comment on table date_presence is 'Suivi de presence par geolocalisation. distance_m sert notamment au seuil de 350 m qui conditionne l''affichage des evaluations.';

-- ---------- RLS ----------

alter table venue_proposals enable row level security;
alter table venue_votes     enable row level security;
alter table date_presence   enable row level security;

create policy p_venueprop_partie on venue_proposals for select
  using (conversation_id in (select id from conversations where user_a = auth.uid() or user_b = auth.uid()));

create policy p_venuevote_self on venue_votes for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy p_presence_self on date_presence for select
  using (user_id = auth.uid());;
