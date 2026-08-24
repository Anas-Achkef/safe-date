create schema if not exists private;
revoke all on schema private from public;
create table policy_documents (
  code text not null, version text not null, published_at timestamptz not null,
  body text not null, body_sha256 text not null, is_current boolean not null default false,
  primary key (code, version));
create unique index on policy_documents (code) where is_current;
create type sensitive_category as enum ('origine_ethnique','convictions_religieuses',
  'opinions_politiques','orientation_sexuelle','sante','biometrie','geolocalisation','identite_genre');
create table consents (
  user_id uuid not null references auth.users(id) on delete cascade,
  category sensitive_category not null, policy_code text not null, policy_version text not null,
  granted_at timestamptz not null default now(), withdrawn_at timestamptz,
  ip_address inet, user_agent text,
  primary key (user_id, category, granted_at),
  foreign key (policy_code, policy_version) references policy_documents (code, version));
create index on consents (user_id, category) where withdrawn_at is null;
create or replace function has_consent(u uuid, c sensitive_category)
returns boolean language sql stable as $$
  select exists (select 1 from consents where user_id = u and category = c and withdrawn_at is null);
$$;
alter table criteria add column sensitive_category sensitive_category;
update criteria set sensitive_category = 'origine_ethnique' where key in ('peau_couleur_moi','peau_couleur_rech');
update criteria set sensitive_category = 'convictions_religieuses' where key in ('val_religion_moi','val_religion_rech','val_spirit_moi','val_spirit_rech');
update criteria set sensitive_category = 'opinions_politiques' where key in ('val_politique_moi','val_politique_rech');
update criteria set sensitive_category = 'orientation_sexuelle' where key in ('db_sex_or_moi','db_sex_or_rech');
update criteria set sensitive_category = 'sante' where key in ('vice_conso_moi','vice_conso_rech');
update criteria set sensitive_category = 'identite_genre' where key in ('genre_moi','genre_rech');
create or replace function trg_check_sensitive_consent() returns trigger
language plpgsql as $$
declare cat sensitive_category;
begin
  select sensitive_category into cat from criteria where key = new.criterion_key;
  if cat is not null and not has_consent(new.user_id, cat) then
    raise exception 'Consentement manquant pour la catégorie % (critère %). RGPD art. 9.',
      cat, new.criterion_key using errcode = 'check_violation';
  end if;
  return new;
end $$;
create trigger profile_answers_consent before insert or update on profile_answers
for each row execute function trg_check_sensitive_consent();
create or replace function trg_consent_withdrawn() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if new.withdrawn_at is not null and old.withdrawn_at is null then
    delete from profile_answers where user_id = new.user_id
      and criterion_key in (select key from criteria where sensitive_category = new.category);
  end if;
  return new;
end $$;
create trigger consents_withdrawn after update on consents
for each row execute function trg_consent_withdrawn();
alter table profiles add constraint profiles_majeur
  check (birth_date <= (current_date - interval '18 years'));
create type verification_status as enum ('en_attente','validee','refusee','expiree');
create table identity_verifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  provider text not null, provider_ref text not null,
  status verification_status not null default 'en_attente',
  liveness_ok boolean, age_estimated smallint, checked_at timestamptz,
  created_at timestamptz not null default now());
comment on table identity_verifications is
  'Cette table ne contient AUCUNE donnee biometrique : ni image, ni gabarit, ni vecteur facial. Seuls le resultat et la reference opaque du prestataire sont conserves.';
create index on identity_verifications (user_id, status);
create table blocks (
  blocker_id uuid not null references auth.users(id) on delete cascade,
  blocked_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id), check (blocker_id <> blocked_id));
create index on blocks (blocked_id);
create type report_reason as enum ('faux_profil','harcelement','contenu_sexuel','mineur','violence','arnaque','comportement_rendez_vous','autre');
create type report_status as enum ('nouveau','en_cours','traite','rejete');
create table reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references auth.users(id) on delete set null,
  reported_id uuid references auth.users(id) on delete set null,
  reason report_reason not null, details text,
  status report_status not null default 'nouveau',
  created_at timestamptz not null default now(),
  handled_at timestamptz, handled_by uuid, outcome text);
create index on reports (status, created_at);
create or replace function are_blocked(a uuid, b uuid)
returns boolean language sql stable as $$
  select exists (select 1 from blocks
    where (blocker_id = a and blocked_id = b) or (blocker_id = b and blocked_id = a));
$$;
create or replace function private.eligible_candidates(u uuid)
returns table (candidate_id uuid) language sql stable security definer
set search_path = public, pg_temp as $$
  select p.id from profiles p
  where p.id <> u and p.is_active and p.is_verified and not are_blocked(u, p.id)
    and not exists (select 1 from reports r
      where r.reported_id = p.id and r.status in ('nouveau','en_cours'));
$$;
create table deletion_requests (
  user_id uuid primary key references auth.users(id) on delete cascade,
  requested_at timestamptz not null default now(),
  execute_after timestamptz not null default (now() + interval '7 days'),
  executed_at timestamptz, cancelled_at timestamptz);
create or replace function private.request_account_deletion(u uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
begin
  insert into deletion_requests (user_id) values (u)
  on conflict (user_id) do update set requested_at = now(),
    execute_after = now() + interval '7 days', cancelled_at = null;
  update profiles set is_active = false where id = u;
end $$;
create or replace function private.execute_account_deletion(u uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
begin
  delete from profile_answers where user_id = u;
  delete from profile_vectors where user_id = u;
  delete from identity_verifications where user_id = u;
  delete from blocks where blocker_id = u or blocked_id = u;
  update reports set details = null where reporter_id = u;
  delete from consents where user_id = u;
  delete from profiles where id = u;
  delete from auth.users where id = u;
  update deletion_requests set executed_at = now() where user_id = u;
end $$;
create table sensitive_access_log (
  id bigserial primary key, occurred_at timestamptz not null default now(),
  actor text not null, subject_id uuid, category sensitive_category,
  purpose text not null, row_count int);
create index on sensitive_access_log (subject_id, occurred_at desc);
alter table consents enable row level security;
alter table identity_verifications enable row level security;
alter table blocks enable row level security;
alter table reports enable row level security;
alter table deletion_requests enable row level security;
create policy p_consents_self on consents for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy p_idv_self on identity_verifications for select using (user_id = auth.uid());
create policy p_blocks_self on blocks for all using (blocker_id = auth.uid()) with check (blocker_id = auth.uid());
create policy p_reports_insert on reports for insert with check (reporter_id = auth.uid());
create policy p_deletion_self on deletion_requests for all using (user_id = auth.uid()) with check (user_id = auth.uid());
alter table sensitive_access_log enable row level security;;
