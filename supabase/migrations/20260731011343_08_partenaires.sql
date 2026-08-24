create extension if not exists unaccent;
create table partner_steps (step smallint primary key check (step between 1 and 99),
  code text not null unique, label text not null, est_minutes smallint not null default 1,
  bloquante boolean not null default true);
insert into partner_steps (step, code, label, est_minutes) values
  (1,'langue','Choix de la langue',1),(2,'bienvenue','Écran de bienvenue',2),
  (3,'compte','Création du compte et validation du code',3),(4,'pays','Sélection du pays',1),
  (5,'infos','Informations générales',4),(6,'documents','Documents administratifs et fiche Google',5),
  (7,'eligibilite','Vérification des critères d''éligibilité',1),
  (8,'verif_entreprise','Vérification de l''entreprise',1),(9,'verif_postale','Vérification postale',2),
  (10,'juridique','Acceptation des documents juridiques',3),
  (11,'contrat','Signature électronique du contrat',5),(12,'menu','Création du menu',20),
  (13,'photos','Sélection des photos',5),(14,'reversements','Compte de reversement',6),
  (15,'formation','Formations obligatoires',25),(16,'activation','Activation du compte',1);
create type partner_status as enum ('brouillon','en_verification','rejete','actif','suspendu');
create table partners (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  langue text not null, pays char(2) not null, nom_commercial text, raison_sociale text,
  adresse text, code_postal text, ville text, telephone text, email text, site_web text,
  google_place_id text, google_maps_url text, google_note numeric(2,1), google_avis int,
  google_verifie_le timestamptz, status partner_status not null default 'brouillon',
  motif_rejet text, created_at timestamptz not null default now(), activated_at timestamptz);
create index on partners (owner_id);
create index on partners (status);
create table partner_step_completions (
  partner_id uuid not null references partners(id) on delete cascade,
  step smallint not null references partner_steps(step),
  completed_at timestamptz not null default now(), primary key (partner_id, step));
insert into engine_params (key, value, description) values
  ('partenaire_note_min', 3.8, 'Note Google minimale d''un etablissement partenaire'),
  ('partenaire_avis_min', 35, 'Nombre minimal d''avis Google d''un etablissement partenaire');
create or replace function check_partner_eligibility(p uuid)
returns table (eligible boolean, motif text) language plpgsql as $$
declare e partners; note_min numeric; avis_min numeric; m text := null;
begin
  select * into e from partners where id = p;
  note_min := private.engine_param('partenaire_note_min');
  avis_min := private.engine_param('partenaire_avis_min');
  if e.google_place_id is null then m := 'Fiche Google Maps introuvable ou invalide';
  elsif e.google_note is null or e.google_note < note_min then
    m := format('Note Google de %s, minimum requis %s', coalesce(e.google_note::text,'inconnue'), note_min);
  elsif e.google_avis is null or e.google_avis < avis_min then
    m := format('%s avis Google, minimum requis %s', coalesce(e.google_avis::text,'0'), avis_min);
  end if;
  if m is not null then
    update partners set status = 'rejete', motif_rejet = m where id = p;
    return query select false, m;
  else
    insert into partner_step_completions (partner_id, step) values (p, 7) on conflict do nothing;
    return query select true, null::text;
  end if;
end $$;
create or replace function trg_bloque_si_rejete() returns trigger language plpgsql as $$
begin
  if (select status from partners where id = new.partner_id) = 'rejete' then
    raise exception 'Dossier rejeté : aucune étape supplémentaire ne peut être franchie'
      using errcode = 'check_violation';
  end if;
  return new;
end $$;
create trigger partner_steps_bloque before insert on partner_step_completions
for each row execute function trg_bloque_si_rejete();
create table partner_documents (
  id uuid primary key default gen_random_uuid(),
  partner_id uuid not null references partners(id) on delete cascade,
  doc_type text not null, storage_path text not null,
  status verification_status not null default 'en_attente',
  checked_at timestamptz, created_at timestamptz not null default now());
create table partner_postal_verifications (
  partner_id uuid primary key references partners(id) on delete cascade,
  code_sha256 text not null, sent_at timestamptz not null default now(),
  verified_at timestamptz, attempts smallint not null default 0);
create or replace function private.verify_postal_code(p uuid, code text)
returns boolean language plpgsql security definer set search_path = public, pg_temp as $$
declare ok boolean;
begin
  update partner_postal_verifications
     set attempts = attempts + 1,
         verified_at = case when code_sha256 = encode(sha256(upper(trim(code))::bytea),'hex')
                            then now() else verified_at end
   where partner_id = p returning verified_at is not null into ok;
  return coalesce(ok, false);
end $$;
create table partner_acceptances (
  partner_id uuid not null references partners(id) on delete cascade,
  policy_code text not null, policy_version text not null,
  accepted_at timestamptz not null default now(), ip_address inet,
  primary key (partner_id, policy_code),
  foreign key (policy_code, policy_version) references policy_documents (code, version));
create table partner_contracts (
  partner_id uuid primary key references partners(id) on delete cascade,
  provider text not null, provider_ref text not null, document_sha256 text not null,
  status verification_status not null default 'en_attente', signed_at timestamptz);
create table partner_menu_categories (
  id uuid primary key default gen_random_uuid(),
  partner_id uuid not null references partners(id) on delete cascade,
  label text not null, position smallint not null default 0);
create table partner_menu_items (
  id uuid primary key default gen_random_uuid(),
  partner_id uuid not null references partners(id) on delete cascade,
  category_id uuid references partner_menu_categories(id) on delete set null,
  label text not null, description text, price_cents int not null check (price_cents >= 0),
  currency char(3) not null default 'EUR', is_available boolean not null default true,
  position smallint not null default 0);
create index on partner_menu_items (partner_id) where is_available;
create table menu_stopwords (mot text primary key);
insert into menu_stopwords (mot) values ('cafe'),('bar'),('restaurant'),('brasserie'),
  ('bistrot'),('salon'),('the'),('pub'),('taverne'),('auberge'),('grill'),('table'),
  ('maison'),('chez'),('les'),('des'),('une'),('sarl'),('sas'),('sasu'),('eurl'),
  ('snc'),('gmbh'),('company') on conflict do nothing;
create or replace function menu_label_conflit(p uuid, label text)
returns text language plpgsql stable as $$
declare e partners; l text; nom text; mot text;
begin
  select * into e from partners where id = p;
  l := lower(unaccent(label));
  foreach nom in array array[e.nom_commercial, e.raison_sociale] loop
    if nom is not null and length(trim(nom)) >= 3
       and position(lower(unaccent(trim(nom))) in l) > 0 then return trim(nom); end if;
  end loop;
  for mot in select distinct t.m from (
      select unnest(string_to_array(lower(unaccent(coalesce(e.nom_commercial,''))),' ')) as m
      union all
      select unnest(string_to_array(lower(unaccent(coalesce(e.raison_sociale,''))),' '))) t
    where length(t.m) >= 4 and not exists (select 1 from menu_stopwords s where s.mot = t.m)
  loop
    if l ~ ('\m' || regexp_replace(mot,'([.^$*+?()\[\]{}|\\])','\\\1','g') || '\M') then
      return mot;
    end if;
  end loop;
  return null;
end $$;
create or replace function trg_menu_label() returns trigger language plpgsql as $$
declare c text;
begin
  c := menu_label_conflit(new.partner_id, new.label);
  if c is not null then
    raise exception 'L''intitulé « % » contient le nom de l''établissement (« % »).', new.label, c
      using errcode = 'check_violation';
  end if;
  return new;
end $$;
create trigger menu_items_label before insert or update of label on partner_menu_items
for each row execute function trg_menu_label();
create type photo_source as enum ('google_reference','import_partenaire');
create table partner_photos (
  id uuid primary key default gen_random_uuid(),
  partner_id uuid not null references partners(id) on delete cascade,
  source photo_source not null, google_photo_reference text, storage_path text,
  position smallint not null default 0, created_at timestamptz not null default now(),
  check ((source='google_reference' and google_photo_reference is not null and storage_path is null)
      or (source='import_partenaire' and storage_path is not null and google_photo_reference is null)));
create table partner_payout_accounts (
  partner_id uuid primary key references partners(id) on delete cascade,
  stripe_account_id text not null unique, charges_enabled boolean not null default false,
  payouts_enabled boolean not null default false, requirements_due text[] not null default '{}',
  updated_at timestamptz not null default now());
create table training_modules (
  code text primary key, titre text not null, position smallint not null,
  obligatoire boolean not null default true, video_path text, score_min smallint not null default 80);
insert into training_modules (code, titre, position) values
  ('fonctionnement','Le fonctionnement de Safe Date',1),('accueil','L''accueil des utilisateurs',2),
  ('bonnes_pratiques','Les bonnes pratiques',3),('securite','Les règles de sécurité',4),
  ('incidents','La gestion des incidents',5),('urgence','Les procédures d''urgence',6);
create table partner_training_completions (
  partner_id uuid not null references partners(id) on delete cascade,
  module_code text not null references training_modules(code),
  quiz_score smallint not null check (quiz_score between 0 and 100),
  passed boolean generated always as (quiz_score >= 80) stored,
  completed_at timestamptz not null default now(), primary key (partner_id, module_code));
create or replace function partner_activation_checklist(p uuid)
returns table (rang smallint, condition text, satisfaite boolean) language sql stable as $$
  with e as (select * from partners where id = p)
  select * from (values
    (1::smallint,'Langue sélectionnée',(select langue is not null from e)),
    (2,'Compte créé et vérifié',exists (select 1 from partner_step_completions where partner_id=p and step=3)),
    (3,'Pays sélectionné',(select pays is not null from e)),
    (4,'Informations générales complétées',(select nom_commercial is not null and raison_sociale is not null
        and adresse is not null and telephone is not null and email is not null from e)),
    (5,'Documents administratifs validés',exists (select 1 from partner_documents where partner_id=p and status='validee')),
    (6,'Fiche Google Maps valide',(select google_place_id is not null from e)),
    (7,'Note Google supérieure ou égale au minimum requis',(select google_note >= private.engine_param('partenaire_note_min') from e)),
    (8,'Nombre d''avis Google suffisant',(select google_avis >= private.engine_param('partenaire_avis_min') from e)),
    (9,'Identité de l''établissement vérifiée',exists (select 1 from partner_step_completions where partner_id=p and step=8)),
    (10,'Vérification postale validée',exists (select 1 from partner_postal_verifications where partner_id=p and verified_at is not null)),
    (11,'Conditions générales d''utilisation acceptées',exists (select 1 from partner_acceptances where partner_id=p and policy_code='cgu')),
    (12,'Politique de confidentialité acceptée',exists (select 1 from partner_acceptances where partner_id=p and policy_code='confidentialite')),
    (13,'Consentement au traitement des données personnelles validé',exists (select 1 from partner_acceptances where partner_id=p and policy_code='donnees_personnelles')),
    (14,'Contrat de partenariat signé électroniquement',exists (select 1 from partner_contracts where partner_id=p and status='validee' and signed_at is not null)),
    (15,'Menu entièrement configuré',(select count(*) >= 1 from partner_menu_items where partner_id=p)),
    (16,'Au moins une photo sélectionnée ou importée',(select count(*) >= 1 from partner_photos where partner_id=p)),
    (17,'Compte de reversement opérationnel',exists (select 1 from partner_payout_accounts where partner_id=p and charges_enabled and payouts_enabled)),
    (18,'Formations obligatoires validées',not exists (select 1 from training_modules m
        where m.obligatoire and not exists (select 1 from partner_training_completions c
          where c.partner_id=p and c.module_code=m.code and c.passed))))
  as t(rang, condition, satisfaite);
$$;
create or replace function activate_partner(p uuid) returns void language plpgsql as $$
declare manquantes text;
begin
  select string_agg(condition,' · ' order by rang) into manquantes
  from partner_activation_checklist(p) where not coalesce(satisfaite,false);
  if manquantes is not null then
    raise exception 'Activation impossible, conditions non remplies : %', manquantes
      using errcode = 'check_violation';
  end if;
  update partners set status='actif', activated_at=now() where id = p;
  insert into partner_step_completions (partner_id, step) values (p,16) on conflict do nothing;
end $$;
create or replace function partner_progress(p uuid)
returns table (etape_courante smallint, etapes_total smallint, minutes_restantes int, statut partner_status)
language sql stable as $$
  select coalesce((select min(s.step) from partner_steps s
      where not exists (select 1 from partner_step_completions c where c.partner_id=p and c.step=s.step)),
      (select max(step) from partner_steps))::smallint,
    (select count(*) from partner_steps)::smallint,
    (select coalesce(sum(s.est_minutes),0)::int from partner_steps s
      where not exists (select 1 from partner_step_completions c where c.partner_id=p and c.step=s.step)),
    (select status from partners where id = p);
$$;
alter table partners enable row level security;
alter table partner_menu_items enable row level security;
alter table partner_menu_categories enable row level security;
alter table partner_photos enable row level security;
alter table partner_documents enable row level security;
alter table partner_payout_accounts enable row level security;
alter table partner_training_completions enable row level security;
create policy p_partners_owner on partners for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy p_menu_owner on partner_menu_items for all using (partner_id in (select id from partners where owner_id = auth.uid())) with check (partner_id in (select id from partners where owner_id = auth.uid()));
create policy p_cat_owner on partner_menu_categories for all using (partner_id in (select id from partners where owner_id = auth.uid())) with check (partner_id in (select id from partners where owner_id = auth.uid()));
create policy p_photos_owner on partner_photos for all using (partner_id in (select id from partners where owner_id = auth.uid())) with check (partner_id in (select id from partners where owner_id = auth.uid()));
create policy p_docs_owner on partner_documents for all using (partner_id in (select id from partners where owner_id = auth.uid())) with check (partner_id in (select id from partners where owner_id = auth.uid()));
create policy p_payout_read on partner_payout_accounts for select using (partner_id in (select id from partners where owner_id = auth.uid()));
create policy p_training_owner on partner_training_completions for all using (partner_id in (select id from partners where owner_id = auth.uid())) with check (partner_id in (select id from partners where owner_id = auth.uid()));;
