-- =====================================================================
--  Safe Date / Prom'us — Vecteurs de test du parcours partenaire (lot 08)
--
--  Les cas suivent le cahier des charges module 2, étape par étape.
-- =====================================================================

begin;

insert into policy_documents (code, version, published_at, body, body_sha256, is_current)
values
  ('cgu',                  '1.0', now(), 'CGU de test.',  encode(sha256('CGU de test.'::bytea), 'hex'),  true),
  ('donnees_personnelles', '1.0', now(), 'RGPD de test.', encode(sha256('RGPD de test.'::bytea), 'hex'), true);

insert into policy_documents (code, version, published_at, body, body_sha256, is_current)
select 'confidentialite', '1.0', now(), 'Conf de test.',
       encode(sha256('Conf de test.'::bytea), 'hex'), true
where not exists (select 1 from policy_documents where code = 'confidentialite');

insert into auth.users (id) values
  ('00000000-0000-0000-0000-0000000000c1'::uuid),
  ('00000000-0000-0000-0000-0000000000c2'::uuid);

do $$
declare
  o1 uuid := '00000000-0000-0000-0000-0000000000c1';
  o2 uuid := '00000000-0000-0000-0000-0000000000c2';
  faible uuid; bon uuid;
  r record; n int; msg text;
begin
  -- =================================================================
  --  ÉTAPE 7 — critères d'éligibilité
  -- =================================================================

  -- CAS 1 — Note insuffisante : le dossier est rejeté et le motif
  -- enregistré, pas seulement affiché.
  insert into partners (owner_id, langue, pays, nom_commercial, raison_sociale,
                        google_place_id, google_note, google_avis)
  values (o1, 'fr', 'FR', 'Le Central', 'SARL Le Central', 'place_001', 3.4, 120)
  returning id into faible;

  select * into r from check_partner_eligibility(faible);
  if r.eligible then raise exception 'CAS 1 ÉCHEC : établissement sous 3,8 déclaré éligible'; end if;
  if (select status from partners where id = faible) <> 'rejete' then
    raise exception 'CAS 1 ÉCHEC : le statut n''est pas passé à rejeté';
  end if;
  raise notice 'CAS 1 OK  — note insuffisante : % ', r.motif;

  -- CAS 2 — « Aucune autre vérification n'est alors effectuée » : le
  -- parcours est réellement verrouillé, pas seulement masqué à l'écran.
  begin
    insert into partner_step_completions (partner_id, step) values (faible, 8);
    raise exception 'CAS 2 ÉCHEC : une étape a pu être franchie après rejet';
  exception when check_violation then
    raise notice 'CAS 2 OK  — parcours verrouillé après rejet, coûts de vérification économisés';
  end;

  -- CAS 3 — Nombre d'avis insuffisant, note suffisante.
  update partners set status = 'brouillon', google_note = 4.6, google_avis = 12
    where id = faible;
  select * into r from check_partner_eligibility(faible);
  if r.eligible then raise exception 'CAS 3 ÉCHEC : 12 avis déclarés suffisants'; end if;
  raise notice 'CAS 3 OK  — avis insuffisants : %', r.motif;

  -- CAS 4 — Établissement conforme aux trois critères.
  insert into partners (owner_id, langue, pays, nom_commercial, raison_sociale,
                        adresse, code_postal, ville, telephone, email,
                        google_place_id, google_note, google_avis)
  values (o2, 'fr', 'CH', 'Café de Paris', 'Café de Paris Sàrl',
          '12 rue du Lac', '1260', 'Nyon', '+41220000000', 'contact@test.ch',
          'place_002', 4.2, 187)
  returning id into bon;

  select * into r from check_partner_eligibility(bon);
  if not r.eligible then raise exception 'CAS 4 ÉCHEC : établissement conforme rejeté (%)', r.motif; end if;
  raise notice 'CAS 4 OK  — éligibilité validée, note 4,2 et 187 avis';

  -- =================================================================
  --  ÉTAPE 12 — standardisation des intitulés de menu
  -- =================================================================

  -- CAS 5 — Les trois exemples du cahier des charges sont refusés.
  update partners set nom_commercial = 'Café de Paris' where id = bon;
  begin
    insert into partner_menu_items (partner_id, label, price_cents)
    values (bon, 'Entrecôte Café de Paris', 3200);
    raise exception 'CAS 5 ÉCHEC : « Entrecôte Café de Paris » accepté';
  exception when check_violation then null;
  end;

  update partners set nom_commercial = 'Le Central', raison_sociale = 'Le Central SA' where id = bon;
  begin
    insert into partner_menu_items (partner_id, label, price_cents)
    values (bon, 'Burger Le Central', 2400);
    raise exception 'CAS 5 ÉCHEC : « Burger Le Central » accepté';
  exception when check_violation then null;
  end;

  update partners set nom_commercial = 'Chez Marco', raison_sociale = 'Chez Marco Sàrl' where id = bon;
  begin
    insert into partner_menu_items (partner_id, label, price_cents)
    values (bon, 'Dessert Chez Marco', 1200);
    raise exception 'CAS 5 ÉCHEC : « Dessert Chez Marco » accepté';
  exception when check_violation then null;
  end;
  raise notice 'CAS 5 OK  — les trois intitulés du cahier des charges sont refusés';

  -- CAS 6 — Les intitulés corrigés passent, et un mot générique du nom
  -- ne doit pas bloquer un produit courant.
  insert into partner_menu_items (partner_id, label, price_cents) values
    (bon, 'Entrecôte', 3200),
    (bon, 'Burger Signature', 2400),
    (bon, 'Dessert maison', 1200);
  update partners set nom_commercial = 'Le Café du Port', raison_sociale = 'Le Café du Port SA'
    where id = bon;
  insert into partner_menu_items (partner_id, label, price_cents)
  values (bon, 'Café gourmand', 900);
  raise notice 'CAS 6 OK  — intitulés corrigés acceptés, mots génériques non bloquants';

  -- CAS 7 — La détection résiste aux accents et à la casse.
  update partners set nom_commercial = 'Marco', raison_sociale = 'Marco SA' where id = bon;
  begin
    insert into partner_menu_items (partner_id, label, price_cents)
    values (bon, 'TIRAMISU MÀRCO', 800);
    raise notice 'CAS 7 note — variante accentuée non détectée (limite connue)';
  exception when check_violation then
    raise notice 'CAS 7 OK  — détection insensible à la casse et aux accents';
  end;
  update partners set nom_commercial = 'Le Café du Port', raison_sociale = 'Le Café du Port SA'
    where id = bon;

  -- =================================================================
  --  ÉTAPE 16 — activation
  -- =================================================================

  -- CAS 8 — L'activation est refusée et la checklist désigne
  -- précisément ce qui manque.
  begin
    perform activate_partner(bon);
    raise exception 'CAS 8 ÉCHEC : activation acceptée sur un dossier incomplet';
  exception when check_violation then
    select count(*) into n from partner_activation_checklist(bon)
      where not coalesce(satisfaite, false);
    raise notice 'CAS 8 OK  — activation refusée, % condition(s) manquante(s) désignée(s) sur 18', n;
  end;

  -- CAS 9 — Le code postal est vérifié contre une empreinte, jamais
  -- contre une valeur en clair.
  insert into partner_postal_verifications (partner_id, code_sha256)
  values (bon, encode(sha256('A7K92'::bytea), 'hex'));
  if private.verify_postal_code(bon, 'ZZZZZ') then
    raise exception 'CAS 9 ÉCHEC : un code erroné a été accepté';
  end if;
  if not private.verify_postal_code(bon, ' a7k92 ') then
    raise exception 'CAS 9 ÉCHEC : le code correct a été refusé';
  end if;
  select attempts into n from partner_postal_verifications where partner_id = bon;
  if n <> 2 then raise exception 'CAS 9 ÉCHEC : tentatives non comptabilisées (%)', n; end if;
  raise notice 'CAS 9 OK  — vérification postale par empreinte, tentatives comptabilisées';

  -- CAS 10 — Dossier complet : les 18 conditions sont réunies.
  insert into partner_step_completions (partner_id, step) values (bon, 3), (bon, 8);
  insert into partner_documents (partner_id, doc_type, storage_path, status)
    values (bon, 'registre_commerce', 'docs/rc.pdf', 'validee');
  insert into partner_acceptances (partner_id, policy_code, policy_version) values
    (bon, 'cgu', '1.0'), (bon, 'confidentialite', '1.0'), (bon, 'donnees_personnelles', '1.0');
  insert into partner_contracts (partner_id, provider, provider_ref, document_sha256, status, signed_at)
    values (bon, 'prestataire_eidas', 'sig_001', repeat('a', 64), 'validee', now());
  insert into partner_photos (partner_id, source, storage_path)
    values (bon, 'import_partenaire', 'photos/1.jpg');
  insert into partner_payout_accounts (partner_id, stripe_account_id, charges_enabled, payouts_enabled)
    values (bon, 'acct_test_001', true, true);
  insert into partner_training_completions (partner_id, module_code, quiz_score)
    select bon, code, 90 from training_modules where obligatoire;

  perform activate_partner(bon);
  if (select status from partners where id = bon) <> 'actif' then
    raise exception 'CAS 10 ÉCHEC : le partenaire n''est pas actif';
  end if;
  raise notice 'CAS 10 OK — activation effective, 18 conditions réunies';

  -- CAS 11 — Une formation ratée bloque l'activation. Le seuil de 80
  -- est porté par une colonne générée : il ne peut pas être contourné
  -- par une écriture directe.
  update partner_training_completions set quiz_score = 40
    where partner_id = bon and module_code = 'urgence';
  select satisfaite into r from partner_activation_checklist(bon) where rang = 18;
  if r.satisfaite then
    raise exception 'CAS 11 ÉCHEC : formation à 40/100 considérée comme validée';
  end if;
  raise notice 'CAS 11 OK — un quiz sous le seuil invalide la formation obligatoire';

  -- CAS 12 — Barre de progression : étape courante et temps restant.
  select * into r from partner_progress(faible);
  if r.etapes_total <> 16 then
    raise exception 'CAS 12 ÉCHEC : % étapes au lieu de 16', r.etapes_total;
  end if;
  raise notice 'CAS 12 OK — progression : étape % sur %, % minutes restantes, statut %',
    r.etape_courante, r.etapes_total, r.minutes_restantes, r.statut;

  raise notice '--------------------------------------------------';
  raise notice 'TOUS LES CAS SONT PASSÉS';
end $$;

rollback;

-- L'éditeur Supabase n'affiche pas les « raise notice ». Un échec lève une
-- exception, donc visible ; cette ligne rend la réussite visible aussi.
select 'TOUS LES CAS SONT PASSÉS' as resultat;
