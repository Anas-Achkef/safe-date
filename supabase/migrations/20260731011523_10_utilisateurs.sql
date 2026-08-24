create table user_steps (step smallint primary key, code text not null unique,
  label text not null, est_seconds smallint not null default 30, bloquante boolean not null default true);
insert into user_steps (step, code, label, est_seconds, bloquante) values
  (1,'langue','Choix de la langue',10,true),(2,'bienvenue','Écran de bienvenue',20,true),
  (3,'compte','Création du compte et validation du code',45,true),(4,'pays','Sélection du pays',10,true),
  (5,'questionnaire','Questionnaire initial',60,true),(6,'photos','Téléchargement des photos',30,true),
  (7,'biometrie','Vérification biométrique',25,true),
  (8,'juridique','Validation juridique et activation',20,true),
  (9,'geoloc','Autorisation de la géolocalisation',15,false);
alter table profiles add column langue text, add column pays char(2), add column geoloc_precise boolean;
create table user_step_completions (
  user_id uuid not null references profiles(id) on delete cascade,
  step smallint not null references user_steps(step),
  completed_at timestamptz not null default now(), primary key (user_id, step));
create type verif_channel as enum ('email','sms');
create table user_verification_codes (
  user_id uuid primary key references profiles(id) on delete cascade,
  channel verif_channel not null, destination text not null, code_sha256 text not null,
  sent_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '15 minutes'),
  verified_at timestamptz, attempts smallint not null default 0);
create or replace function private.verify_account_code(u uuid, code text)
returns boolean language plpgsql as $$
declare ok boolean; max_essais constant int := 5;
begin
  if (select attempts from user_verification_codes where user_id = u) >= max_essais then
    raise exception 'Nombre maximal de tentatives atteint, demandez un nouveau code'
      using errcode = 'check_violation';
  end if;
  update user_verification_codes
     set attempts = attempts + 1,
         verified_at = case when code_sha256 = encode(sha256(upper(trim(code))::bytea),'hex')
                              and now() < expires_at then now() else verified_at end
   where user_id = u returning verified_at is not null into ok;
  if coalesce(ok,false) then
    insert into user_step_completions (user_id, step) values (u,3) on conflict do nothing;
  end if;
  return coalesce(ok,false);
end $$;
create or replace function private.consentements_requis_questionnaire(u uuid)
returns table (categorie sensitive_category, criteres int, accorde boolean)
language sql stable as $$
  select c.sensitive_category, count(*)::int, has_consent(u, c.sensitive_category)
  from criteria c where c.moment = 'onboarding' and c.sensitive_category is not null
  group by c.sensitive_category order by 1;
$$;
create or replace function private.complete_questionnaire_step(u uuid)
returns void language plpgsql as $$
declare manquants text; reste int;
begin
  select string_agg(categorie::text, ', ' order by categorie) into manquants
  from private.consentements_requis_questionnaire(u) where not accorde;
  if manquants is not null then
    raise exception 'Questionnaire incomplet : consentement manquant pour %.', manquants
      using errcode = 'check_violation';
  end if;
  select onboarding_total - onboarding_repondus into reste from private.answer_progress(u);
  if reste > 0 then
    raise exception 'Questionnaire incomplet : % critère(s) obligatoire(s) restant(s)', reste
      using errcode = 'check_violation';
  end if;
  insert into user_step_completions (user_id, step) values (u,5) on conflict do nothing;
end $$;
create type moderation_status as enum ('en_attente','approuvee','rejetee');
create table user_photos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  storage_path text not null, position smallint not null default 0,
  moderation moderation_status not null default 'en_attente',
  moderated_at timestamptz, created_at timestamptz not null default now());
create index on user_photos (user_id);
alter table identity_verifications add column comparison_ok boolean,
  add column comparison_score numeric(4,3),
  add column photo_id uuid references user_photos(id) on delete set null;
create or replace function private.record_biometric_check(
  u uuid, p_provider text, p_ref text, p_liveness boolean,
  p_comparison boolean, p_score numeric, p_photo uuid)
returns boolean language plpgsql as $$
declare ok boolean;
begin
  if not has_consent(u, 'biometrie') then
    raise exception 'Consentement biométrique manquant. Il doit être recueilli avant la capture du selfie.'
      using errcode = 'check_violation';
  end if;
  ok := coalesce(p_liveness,false) and coalesce(p_comparison,false);
  insert into identity_verifications (user_id, provider, provider_ref, status, liveness_ok,
    comparison_ok, comparison_score, photo_id, checked_at)
  values (u, p_provider, p_ref, (case when ok then 'validee' else 'refusee' end)::verification_status,
    p_liveness, p_comparison, p_score, p_photo, now());
  if ok then
    update profiles set is_verified = true where id = u;
    insert into user_step_completions (user_id, step) values (u,7) on conflict do nothing;
  end if;
  return ok;
end $$;
create table user_acceptances (
  user_id uuid not null references profiles(id) on delete cascade,
  policy_code text not null, policy_version text not null,
  accepted_at timestamptz not null default now(), ip_address inet,
  primary key (user_id, policy_code),
  foreign key (policy_code, policy_version) references policy_documents (code, version));
create or replace function private.user_activation_checklist(u uuid)
returns table (rang smallint, condition text, satisfaite boolean) language sql stable as $$
  with e as (select * from profiles where id = u)
  select * from (values
    (1::smallint,'Langue sélectionnée',(select langue is not null from e)),
    (2,'Compte créé et vérifié',exists (select 1 from user_step_completions where user_id=u and step=3)),
    (3,'Adresse e-mail ou numéro de téléphone validé',exists (select 1 from user_verification_codes where user_id=u and verified_at is not null)),
    (4,'Pays sélectionné',(select pays is not null from e)),
    (5,'Questionnaire initial complété',exists (select 1 from user_step_completions where user_id=u and step=5)),
    (6,'Au moins une photo de profil téléchargée',(select count(*) >= 1 from user_photos where user_id=u and moderation <> 'rejetee')),
    (7,'Vérification biométrique validée',exists (select 1 from identity_verifications where user_id=u and status='validee')),
    (8,'Conditions générales d''utilisation acceptées',exists (select 1 from user_acceptances where user_id=u and policy_code='cgu')),
    (9,'Politique de confidentialité acceptée',exists (select 1 from user_acceptances where user_id=u and policy_code='confidentialite')),
    (10,'Consentement au traitement des données personnelles validé',exists (select 1 from user_acceptances where user_id=u and policy_code='donnees_personnelles')))
  as t(rang, condition, satisfaite);
$$;
create or replace function private.activate_user(u uuid) returns void language plpgsql as $$
declare manquantes text;
begin
  select string_agg(condition,' · ' order by rang) into manquantes
  from private.user_activation_checklist(u) where not coalesce(satisfaite,false);
  if manquantes is not null then
    raise exception 'Activation impossible, conditions non remplies : %', manquantes
      using errcode = 'check_violation';
  end if;
  update profiles set is_active = true where id = u;
  insert into user_step_completions (user_id, step) values (u,8) on conflict do nothing;
end $$;
create or replace function private.set_geolocation_choice(u uuid, autorise boolean, precise boolean,
  p_code text, p_version text) returns void language plpgsql as $$
begin
  if autorise then
    insert into consents (user_id, category, policy_code, policy_version)
    values (u,'geolocalisation',p_code,p_version);
    update profiles set geoloc_precise = precise where id = u;
  else
    update consents set withdrawn_at = now()
     where user_id = u and category = 'geolocalisation' and withdrawn_at is null;
    update profiles set geoloc_precise = null where id = u;
  end if;
  insert into user_step_completions (user_id, step) values (u,9) on conflict do nothing;
end $$;
create or replace function private.proximite_disponible(u uuid)
returns boolean language sql stable as $$ select has_consent(u,'geolocalisation'); $$;
create or replace function private.user_progress(u uuid)
returns table (etape_courante smallint, etapes_total smallint, secondes_restantes int, compte_actif boolean)
language sql stable as $$
  select coalesce((select min(s.step) from user_steps s
      where not exists (select 1 from user_step_completions c where c.user_id=u and c.step=s.step)),
      (select max(step) from user_steps))::smallint,
    (select count(*) from user_steps)::smallint,
    (select coalesce(sum(s.est_seconds),0)::int from user_steps s
      where not exists (select 1 from user_step_completions c where c.user_id=u and c.step=s.step)),
    (select is_active and is_verified from profiles where id = u);
$$;
alter table user_photos enable row level security;
alter table user_acceptances enable row level security;
alter table user_step_completions enable row level security;
alter table user_verification_codes enable row level security;
create policy p_photos_self on user_photos for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy p_accept_self on user_acceptances for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy p_steps_self on user_step_completions for select using (user_id = auth.uid());
create or replace function verify_account_code(code text) returns boolean
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return private.verify_account_code(auth.uid(), code);
end $$;
create or replace function consentements_requis_questionnaire()
returns table (categorie sensitive_category, criteres int, accorde boolean)
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.consentements_requis_questionnaire(auth.uid());
end $$;
create or replace function complete_questionnaire_step() returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  perform private.complete_questionnaire_step(auth.uid());
end $$;
create or replace function user_activation_checklist()
returns table (rang smallint, condition text, satisfaite boolean)
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.user_activation_checklist(auth.uid());
end $$;
create or replace function activate_user() returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  perform private.activate_user(auth.uid());
end $$;
create or replace function set_geolocation_choice(autorise boolean, precise boolean, p_code text, p_version text)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  perform private.set_geolocation_choice(auth.uid(), autorise, precise, p_code, p_version);
end $$;
create or replace function proximite_disponible() returns boolean
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then return false; end if;
  return private.proximite_disponible(auth.uid());
end $$;
create or replace function user_progress()
returns table (etape_courante smallint, etapes_total smallint, secondes_restantes int, compte_actif boolean)
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.user_progress(auth.uid());
end $$;;
