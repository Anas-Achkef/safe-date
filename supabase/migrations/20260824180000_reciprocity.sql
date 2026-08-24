-- ============================================================================
--  Safe Date — Réciprocité
--  Réf. PRM-M7 · proposition de schéma, v2
--
--  Une seule primitive pour les deux portes de réciprocité du Module 7 :
--    · en amont  — décision de découverte  → ouverture de la conversation
--    · en aval   — décision de poursuite   → réouverture ou clôture (§7.13)
--
--  NON APPLIQUÉ. Fichier destiné à être relu puis passé en migration versionnée.
--
--  Prérequis : PostgreSQL 15+ pour « unique nulls not distinct ». Projet en 17.6.
-- ============================================================================

begin;

-- ----------------------------------------------------------------------------
--  Types
-- ----------------------------------------------------------------------------

create type reciprocity_context as enum ('decouverte', 'poursuite');

-- « plus_tard » est un état à part entière : ni oui, ni non, ni absence.
-- Il déclenche une relance différée et empêche la clôture.
create type reciprocity_answer as enum ('oui', 'non', 'plus_tard');

-- L'absence de match n'est pas une résolution : « les deux ont dit non »,
-- « les réponses divergent » et « personne n'a répondu » doivent se distinguer.
create type reciprocity_status as enum ('en_attente', 'match', 'clos');

-- Fenêtres de mise en sourdine du Date Surprise (verrous anti-insistance).
create type insistence_window as enum ('lendemain', 'fin_semaine', 'trente_jours');

-- ----------------------------------------------------------------------------
--  Décisions individuelles
--
--  Une ligne par utilisateur et par porte. La ligne de la contre-partie est
--  rendue illisible par la RLS : la promesse « nul ne connaît la réponse de
--  l'autre avant résolution » tient au niveau du protocole, pas de l'affichage.
-- ----------------------------------------------------------------------------

create table reciprocity_decisions (
  id              bigserial primary key,
  contexte        reciprocity_context not null,
  -- Renseigné pour « poursuite » uniquement : une poursuite se rattache
  -- toujours à un rendez-vous précis.
  date_id         uuid references dates(id) on delete cascade,
  user_id         uuid not null references profiles(id) on delete cascade,
  target_id       uuid not null references profiles(id) on delete cascade,
  reponse         reciprocity_answer not null,
  -- Échéance de relance, alimentée quand la réponse vaut « plus_tard ».
  relance_at      timestamptz,
  -- Horodatage d'envoi : empêche le planificateur de relancer deux fois.
  relance_sent_at timestamptz,
  decided_at      timestamptz not null default now(),
  -- Le module autorise à revenir sur sa décision : on distingue la première
  -- prise de position de la dernière modification.
  updated_at      timestamptz not null default now(),

  constraint reciprocity_decision_pas_soi
    check (user_id <> target_id),

  -- Lie le contexte à la présence du rendez-vous, sinon des lignes
  -- incohérentes s'accumulent silencieusement.
  constraint reciprocity_decision_contexte_date check (
    (contexte = 'poursuite'  and date_id is not null) or
    (contexte = 'decouverte' and date_id is null)
  ),

  constraint reciprocity_decision_relance check (
    (reponse = 'plus_tard') or (relance_at is null and relance_sent_at is null)
  ),

  unique nulls not distinct (contexte, date_id, user_id, target_id)
);

comment on table reciprocity_decisions is
  'Engagement d''un utilisateur sur une porte de réciprocité. Distinct de '
  'swipe_decisions, qui reste la trace comportementale (durée, écran, signal fort).';

-- File des relances dues : uniquement les « plus_tard » jamais relancés.
create index reciprocity_relances_dues
  on reciprocity_decisions (relance_at)
  where reponse = 'plus_tard' and relance_sent_at is null;

create index reciprocity_decisions_cible
  on reciprocity_decisions (target_id, contexte);

-- ----------------------------------------------------------------------------
--  Résolutions
--
--  Une ligne par paire et par porte, créée dès la PREMIÈRE décision. C'est
--  l'objet unique à interroger pour piloter l'ouverture de la conversation,
--  la clôture du rendez-vous et la réactivation du profil (§7.14).
-- ----------------------------------------------------------------------------

create table reciprocity_resolutions (
  id          bigserial primary key,
  contexte    reciprocity_context not null,
  date_id     uuid references dates(id) on delete cascade,
  user_a      uuid not null references profiles(id) on delete cascade,
  user_b      uuid not null references profiles(id) on delete cascade,

  -- Clé de paire canonique : sans elle, deux décisions concurrentes créent
  -- deux résolutions pour la même paire.
  pair_low    uuid generated always as (least(user_a, user_b))    stored,
  pair_high   uuid generated always as (greatest(user_a, user_b)) stored,

  statut      reciprocity_status not null default 'en_attente',
  -- Renseigné dès que le statut devient définitif (match ou clos).
  resolved_at timestamptz,

  -- Instant à partir duquel la résolution peut être révélée à un utilisateur
  -- qui n'a pas encore tranché.
  --
  -- Une clôture prononcée sur un « non » unilatéral est définitive en base
  -- immédiatement, mais la publier aussitôt trahirait la décision de l'autre :
  -- voir la conversation disparaître avant d'avoir répondu, c'est apprendre
  -- qu'on a été refusé. On diffère donc la publication, sans jamais retarder
  -- l'écriture. En découverte, personne n'attend de réponse : la révélation
  -- est immédiate et silencieuse.
  notifiable_at timestamptz,

  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),

  constraint reciprocity_resolution_pas_soi
    check (user_a <> user_b),

  constraint reciprocity_resolution_contexte_date check (
    (contexte = 'poursuite'  and date_id is not null) or
    (contexte = 'decouverte' and date_id is null)
  ),

  constraint reciprocity_resolution_resolved check (
    (statut =  'en_attente' and resolved_at is null     and notifiable_at is null) or
    (statut <> 'en_attente' and resolved_at is not null and notifiable_at is not null)
  ),

  -- « nulls not distinct » est indispensable : sans lui le contexte
  -- « decouverte », dont date_id est nul, échapperait à la contrainte.
  unique nulls not distinct (contexte, date_id, pair_low, pair_high)
);

comment on table reciprocity_resolutions is
  'État consolidé d''une paire sur une porte. En_attente tant qu''une réponse '
  'manque ou vaut plus_tard ; match sur double oui ; clos sur toute autre '
  'combinaison complète.';

create index reciprocity_resolutions_user_a on reciprocity_resolutions (user_a, statut);
create index reciprocity_resolutions_user_b on reciprocity_resolutions (user_b, statut);

-- ----------------------------------------------------------------------------
--  Journal des décisions — append-only
--
--  Le changement d'avis est un UPDATE : sans journal, la position initiale est
--  perdue. Nécessaire pour instruire une contestation de clôture, et pour le
--  cadre de traitement des signalements (R4).
-- ----------------------------------------------------------------------------

create table reciprocity_decision_log (
  id          bigserial primary key,
  -- Pas de clé étrangère : le journal doit survivre à la décision.
  decision_id bigint not null,
  contexte    reciprocity_context not null,
  date_id     uuid,
  user_id     uuid not null,
  target_id   uuid not null,
  reponse     reciprocity_answer not null,
  logged_at   timestamptz not null default now()
);

comment on table reciprocity_decision_log is
  'Journal immuable des prises de position successives. Aucune modification '
  'ni suppression n''est possible, y compris par le propriétaire des données.';

create index reciprocity_log_paire
  on reciprocity_decision_log (user_id, target_id, contexte, logged_at desc);

create or replace function private.reciprocity_log_immutable()
returns trigger
language plpgsql
as $$
begin
  raise exception 'Le journal des décisions de réciprocité est append-only'
    using errcode = 'check_violation';
end $$;

create trigger reciprocity_log_no_change
  before update or delete on reciprocity_decision_log
  for each row execute function private.reciprocity_log_immutable();

-- ----------------------------------------------------------------------------
--  Résolution
-- ----------------------------------------------------------------------------

create or replace function private.resolve_reciprocity(
  p_contexte reciprocity_context,
  p_date_id  uuid,
  p_user     uuid,
  p_target   uuid
) returns void
language plpgsql
security definer
set search_path to 'public', 'pg_temp'
as $$
declare
  v_low        uuid := least(p_user, p_target);
  v_high       uuid := greatest(p_user, p_target);
  v_mine       reciprocity_answer;
  v_theirs     reciprocity_answer;
  v_statut     reciprocity_status;
  -- Vrai quand les deux ont tranché définitivement (« plus_tard » ne tranche pas).
  v_deux_tranches boolean;
  v_notifiable timestamptz;
  v_delai_h    numeric;
begin
  -- Sérialisation sur la paire.
  --
  -- Sous READ COMMITTED, deux décisions concurrentes ne voient pas la ligne
  -- l'une de l'autre : le match ne serait jamais créé, silencieusement et sans
  -- trace. Le verrou est pris avant toute lecture et tombe en fin de
  -- transaction.
  perform pg_advisory_xact_lock(
    hashtextextended(
      v_low::text || '|' || v_high::text || '|' ||
      p_contexte::text || '|' || coalesce(p_date_id::text, ''),
      0
    )
  );

  -- La résolution existe dès la première décision : la seconde la trouve et
  -- la verrouille naturellement.
  insert into reciprocity_resolutions (contexte, date_id, user_a, user_b)
  values (p_contexte, p_date_id, v_low, v_high)
  on conflict do nothing;

  perform 1 from reciprocity_resolutions r
   where r.contexte = p_contexte
     and r.date_id is not distinct from p_date_id
     and r.pair_low = v_low and r.pair_high = v_high
   for update;

  select d.reponse into v_mine
    from reciprocity_decisions d
   where d.contexte = p_contexte
     and d.user_id = p_user and d.target_id = p_target
     and d.date_id is not distinct from p_date_id;

  select d.reponse into v_theirs
    from reciprocity_decisions d
   where d.contexte = p_contexte
     and d.user_id = p_target and d.target_id = p_user
     and d.date_id is not distinct from p_date_id;

  v_deux_tranches := (v_mine in ('oui', 'non') and v_theirs in ('oui', 'non'));

  if v_mine = 'oui' and v_theirs = 'oui' then
    v_statut := 'match';
  elsif v_mine = 'non' or v_theirs = 'non' then
    -- Un seul « non » suffit : le match est devenu impossible, attendre la
    -- seconde réponse ne laisserait qu'un état mort en base — et, en
    -- poursuite, une session que rien ne vient clore.
    v_statut := 'clos';
  else
    -- Il manque une réponse, ou l'une des deux vaut « plus_tard ».
    v_statut := 'en_attente';
  end if;

  -- Publication.
  --
  -- Immédiate lorsqu'il n'y a rien à protéger : un match, une découverte, ou
  -- une clôture sur laquelle les deux se sont déjà prononcés. Différée dans le
  -- seul cas sensible — une poursuite close alors que l'autre n'a pas tranché.
  if v_statut = 'en_attente' then
    v_notifiable := null;
  elsif v_statut = 'match'
     or p_contexte = 'decouverte'
     or v_deux_tranches then
    v_notifiable := now();
  else
    v_delai_h := coalesce(private.engine_param('delai_revelation_cloture_h'), 24);
    v_notifiable := now() + make_interval(hours => v_delai_h::int);
  end if;

  update reciprocity_resolutions r
     set statut        = v_statut,
         resolved_at   = case when v_statut = 'en_attente' then null else now() end,
         -- Une échéance déjà fixée n'est jamais repoussée : sinon une décision
         -- tardive de la contre-partie reculerait indéfiniment la révélation.
         notifiable_at = case
                           when v_statut = 'en_attente' then null
                           else least(coalesce(r.notifiable_at, v_notifiable), v_notifiable)
                         end,
         updated_at    = now()
   where r.contexte = p_contexte
     and r.date_id is not distinct from p_date_id
     and r.pair_low = v_low and r.pair_high = v_high
     and (r.statut is distinct from v_statut or r.notifiable_at is null);
end $$;

create or replace function private.trg_reciprocity_decision()
returns trigger
language plpgsql
security definer
set search_path to 'public', 'pg_temp'
as $$
begin
  insert into reciprocity_decision_log
    (decision_id, contexte, date_id, user_id, target_id, reponse)
  values
    (new.id, new.contexte, new.date_id, new.user_id, new.target_id, new.reponse);

  perform private.resolve_reciprocity(
    new.contexte, new.date_id, new.user_id, new.target_id
  );
  return new;
end $$;

create trigger reciprocity_decisions_resolve
  after insert or update of reponse on reciprocity_decisions
  for each row execute function private.trg_reciprocity_decision();

create or replace function private.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

create trigger reciprocity_decisions_touch
  before update on reciprocity_decisions
  for each row execute function private.touch_updated_at();

-- ----------------------------------------------------------------------------
--  Verrous anti-insistance — Date Surprise
--
--  Décision distincte de la poursuite : mettre en sourdine ne vaut ni refus
--  ni acceptation. Conçue maintenant, implémentable plus tard.
-- ----------------------------------------------------------------------------

create table date_surprise_locks (
  id              bigserial primary key,
  user_id         uuid not null references profiles(id) on delete cascade,
  target_id       uuid not null references profiles(id) on delete cascade,
  fenetre         insistence_window not null,
  bloque_jusqu_au timestamptz not null,
  created_at      timestamptz not null default now(),

  constraint date_surprise_lock_pas_soi check (user_id <> target_id),
  unique (user_id, target_id)
);

comment on table date_surprise_locks is
  'Mise en sourdine d''un contact pour le Date Surprise. Ne vaut pas refus : '
  'la sourdine expire, le refus non.';

-- Pas de prédicat partiel ici : « now() » n'est pas immutable et Postgres
-- refuse les fonctions volatiles dans un prédicat d'index. Le filtrage sur
-- l'échéance se fait à la requête.
create index date_surprise_locks_actifs
  on date_surprise_locks (target_id, bloque_jusqu_au desc);

create or replace function private.insistence_deadline(p_fenetre insistence_window)
returns timestamptz
language sql
-- « stable » et non « immutable » : la fonction lit now(), constant dans la
-- transaction mais pas entre deux. La marquer immutable autoriserait Postgres
-- à en figer le résultat dans un plan ou un index.
stable
as $$
  select case p_fenetre
    when 'lendemain'    then date_trunc('day', now()) + interval '1 day'
    when 'fin_semaine'  then date_trunc('week', now()) + interval '1 week'
    when 'trente_jours' then now() + interval '30 days'
  end;
$$;

-- ----------------------------------------------------------------------------
--  Sécurité
-- ----------------------------------------------------------------------------

alter table reciprocity_decisions   enable row level security;
alter table reciprocity_resolutions enable row level security;
alter table reciprocity_decision_log enable row level security;
alter table date_surprise_locks     enable row level security;

-- La décision de la contre-partie est invisible au niveau réseau.
create policy p_reciprocity_decisions_self on reciprocity_decisions
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Aucune policy sur reciprocity_resolutions — volontairement.
--
-- RLS active sans policy : la table est totalement inaccessible au rôle
-- « authenticated ». Une policy de lecture, même restreinte aux deux membres
-- de la paire, rendrait « statut » et « notifiable_at » interrogeables
-- directement et permettrait de contourner la publication différée par un
-- simple select. Et masquer la ligne au lieu du champ serait pire encore :
-- une résolution qui disparaît est un signal en soi.
--
-- La table n'est donc lisible que par my_resolutions(), en security definer,
-- qui décide seule de ce qui est publiable et quand.

create policy p_reciprocity_log_self on reciprocity_decision_log
  for select to authenticated
  using (user_id = auth.uid());

create policy p_date_surprise_locks_self on date_surprise_locks
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- ----------------------------------------------------------------------------
--  Surface publique
-- ----------------------------------------------------------------------------

create or replace function public.submit_reciprocity(
  contexte reciprocity_context,
  cible    uuid,
  reponse  reciprocity_answer,
  d_id     uuid default null,
  relance  timestamptz default null
) returns void
language plpgsql
security definer
set search_path to 'public', 'pg_temp'
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  if cible = auth.uid() then
    raise exception 'Décision sur soi-même impossible' using errcode = 'check_violation';
  end if;

  insert into reciprocity_decisions
    (contexte, date_id, user_id, target_id, reponse, relance_at)
  values
    (contexte, d_id, auth.uid(), cible, reponse,
     case when reponse = 'plus_tard'
          then coalesce(relance, now() + interval '1 day') end)
  on conflict (contexte, date_id, user_id, target_id) do update
    set reponse         = excluded.reponse,
        relance_at      = excluded.relance_at,
        relance_sent_at = null;
end $$;

-- État consolidé des paires me concernant.
create or replace function public.my_resolutions(
  p_contexte reciprocity_context default null
) returns table (
  resolution_id bigint,
  contexte      reciprocity_context,
  date_id       uuid,
  autre         uuid,
  statut        reciprocity_status,
  ma_reponse    reciprocity_answer,
  resolved_at   timestamptz
)
language plpgsql
stable
security definer
set search_path to 'public', 'pg_temp'
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;

  return query
  select r.id,
         r.contexte,
         r.date_id,
         case when r.user_a = auth.uid() then r.user_b else r.user_a end,
         -- Publication différée.
         --
         -- Qui a tranché voit le statut réel : il connaît déjà sa propre
         -- position, la clôture ne lui apprend rien sur celle de l'autre. Qui
         -- n'a pas tranché — y compris s'il a répondu « plus_tard » — ne voit
         -- la clôture qu'une fois l'échéance atteinte. Jusque-là l'écran
         -- reste identique pour les deux, et nul ne peut déduire qui a refusé.
         case
           when d.reponse in ('oui', 'non')                     then r.statut
           when r.notifiable_at is not null
            and r.notifiable_at <= now()                        then r.statut
           else 'en_attente'::reciprocity_status
         end,
         d.reponse,
         -- Masqué tant que la résolution n'est pas publiable, sinon la date
         -- trahirait ce que le statut vient de taire.
         case
           when d.reponse in ('oui', 'non')                     then r.resolved_at
           when r.notifiable_at is not null
            and r.notifiable_at <= now()                        then r.resolved_at
           else null
         end
    from reciprocity_resolutions r
    left join reciprocity_decisions d
      on d.contexte = r.contexte
     and d.date_id is not distinct from r.date_id
     and d.user_id = auth.uid()
     and d.target_id = case when r.user_a = auth.uid() then r.user_b else r.user_a end
   where auth.uid() in (r.user_a, r.user_b)
     and (p_contexte is null or r.contexte = p_contexte)
   order by r.updated_at desc;
end $$;

revoke all on function public.submit_reciprocity(reciprocity_context, uuid, reciprocity_answer, uuid, timestamptz) from public;
revoke all on function public.my_resolutions(reciprocity_context) from public;
grant execute on function public.submit_reciprocity(reciprocity_context, uuid, reciprocity_answer, uuid, timestamptz) to authenticated;
grant execute on function public.my_resolutions(reciprocity_context) to authenticated;

commit;
