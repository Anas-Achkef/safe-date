-- =========================================================
-- M8 - Demandes de conversation : cycle de vie + exclusions
-- =========================================================

-- 1. Nouveaux types
do $$ begin
  create type public.rencontre_type as enum ('amour','amitie','fun');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.exclusion_reason as enum
    ('refus_conversation','blocage','signalement','moderation');
exception when duplicate_object then null; end $$;

-- 2. Intentions declarees par l'utilisateur
alter table public.profiles
  add column if not exists intentions public.rencontre_type[]
    not null default array['amour']::public.rencontre_type[];

alter table public.profiles
  drop constraint if exists profiles_intentions_non_vide;
alter table public.profiles
  add constraint profiles_intentions_non_vide
    check (cardinality(intentions) between 1 and 3);

comment on column public.profiles.intentions is
  'Types de rencontre acceptes par l''utilisateur. Une demande d''un type non accepte est rejetee a l''envoi, sans revelation du motif exact a l''emetteur.';

-- 3. Extension de chat_requests
alter table public.chat_requests
  add column if not exists type_rencontre public.rencontre_type not null default 'amour',
  add column if not exists opened_at timestamptz,
  add column if not exists stale_at timestamptz not null default now() + interval '24 hours',
  add column if not exists postponed_at timestamptz,
  add column if not exists postpone_count smallint not null default 0,
  add column if not exists ecran_ordre public.score_group[] not null
    default array['physique','valeurs','mode_vie']::public.score_group[];

-- Le compte a rebours ne demarre plus a l'envoi mais a la premiere ouverture
alter table public.chat_requests alter column expires_at drop not null;
alter table public.chat_requests alter column expires_at drop default;

alter table public.chat_requests
  drop constraint if exists chat_requests_ecran_ordre_complet;
alter table public.chat_requests
  add constraint chat_requests_ecran_ordre_complet
    check (cardinality(ecran_ordre) = 3);

alter table public.chat_requests
  drop constraint if exists chat_requests_postpone_max;
alter table public.chat_requests
  add constraint chat_requests_postpone_max
    check (postpone_count between 0 and 1);

alter table public.chat_requests
  drop constraint if exists chat_requests_ouverture_coherente;
alter table public.chat_requests
  add constraint chat_requests_ouverture_coherente
    check (num_nulls(opened_at, expires_at) <> 1);

comment on column public.chat_requests.opened_at is
  'Premiere ouverture par le destinataire. Le delai de 30 minutes ne demarre qu''ici : une demande jamais ouverte ne peut pas expirer par simple ecoulement du temps.';
comment on column public.chat_requests.stale_at is
  'Peremption d''une demande jamais ouverte (24h). Evite l''accumulation indefinie de demandes en attente.';
comment on column public.chat_requests.ecran_ordre is
  'Ordre des trois ecrans du profil fige au moment de l''envoi. L''emetteur ne peut pas modifier ce qu''il met en avant pendant qu''une demande est en vol.';
comment on column public.chat_requests.postpone_count is
  'Nombre de reports. Limite a 1 : le report gele le compte a rebours et accorde un sursis unique.';

-- 4. Index
create unique index if not exists chat_requests_active_uniq
  on public.chat_requests (from_user, to_user)
  where status in ('en_attente','reportee');

create index if not exists chat_requests_boite_reception
  on public.chat_requests (to_user, status, created_at desc);

create index if not exists chat_requests_echeance_ouverte
  on public.chat_requests (expires_at)
  where status in ('en_attente','reportee');

create index if not exists chat_requests_echeance_dormante
  on public.chat_requests (stale_at)
  where status = 'en_attente';

-- 5. Exclusions reciproques
create table if not exists public.profile_exclusions (
  id                uuid primary key default gen_random_uuid(),
  user_lo           uuid not null references public.profiles(id) on delete cascade,
  user_hi           uuid not null references public.profiles(id) on delete cascade,
  initiator         uuid not null references public.profiles(id) on delete cascade,
  reason            public.exclusion_reason not null,
  source_request_id uuid references public.chat_requests(id) on delete set null,
  created_at        timestamptz not null default now(),
  expires_at        timestamptz,
  constraint profile_exclusions_paire_ordonnee check (user_lo < user_hi)
);

create unique index if not exists profile_exclusions_paire_uniq
  on public.profile_exclusions (user_lo, user_hi);
create index if not exists profile_exclusions_expiry
  on public.profile_exclusions (expires_at);

alter table public.profile_exclusions enable row level security;

comment on table public.profile_exclusions is
  'Exclusion mutuelle entre deux utilisateurs. Toujours reciproque : celui qui a ete refuse cesse egalement de voir celui qui a refuse, sans en etre informe. expires_at nul = permanent. Aucune policy de lecture directe : l''acces passe exclusivement par les fonctions private.';

-- 6. Fonctions internes
create or replace function private.est_exclu(a uuid, b uuid)
returns boolean
language sql stable security definer set search_path = public, private as $$
  select exists (
    select 1 from public.profile_exclusions e
    where e.user_lo = least(a,b)
      and e.user_hi = greatest(a,b)
      and (e.expires_at is null or e.expires_at > now())
  );
$$;

create or replace function private.exclure(
  a uuid, b uuid,
  p_initiator uuid,
  p_reason public.exclusion_reason,
  p_duree interval default null,
  p_request uuid default null
) returns void
language plpgsql security definer set search_path = public, private as $$
declare
  v_exp timestamptz := case when p_duree is null then null else now() + p_duree end;
begin
  insert into public.profile_exclusions
    (user_lo, user_hi, initiator, reason, source_request_id, expires_at)
  values
    (least(a,b), greatest(a,b), p_initiator, p_reason, p_request, v_exp)
  on conflict (user_lo, user_hi) do update set
    expires_at = case
      when profile_exclusions.expires_at is null or excluded.expires_at is null then null
      else greatest(profile_exclusions.expires_at, excluded.expires_at)
    end,
    reason            = excluded.reason,
    initiator         = excluded.initiator,
    source_request_id = coalesce(excluded.source_request_id, profile_exclusions.source_request_id);
end;
$$;

comment on function private.exclure is
  'Pose ou prolonge une exclusion. Une exclusion existante n''est jamais raccourcie : on conserve toujours la date la plus lointaine, et une exclusion permanente absorbe toute exclusion temporaire.';

create or replace function private.statut_effectif(r public.chat_requests)
returns public.chat_request_status
language sql stable as $$
  select case
    when r.status not in ('en_attente','reportee') then r.status
    when r.opened_at is null and r.stale_at  <= now() then 'expiree'::public.chat_request_status
    when r.opened_at is not null and r.expires_at <= now() then 'expiree'::public.chat_request_status
    else r.status
  end;
$$;

comment on function private.statut_effectif is
  'Statut recalcule a la lecture. Le floutage cote application est purement cosmetique : seule cette fonction fait foi.';;
