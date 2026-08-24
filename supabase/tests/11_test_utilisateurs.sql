-- =====================================================================
--  Safe Date / Prom'us — Vecteurs de test du parcours utilisateur
--  Cahier des charges module 1, étape par étape.
-- =====================================================================

begin;

insert into policy_documents (code, version, published_at, body, body_sha256, is_current)
values
  ('cgu',                  '1.0', now(), 'CGU.',  encode(sha256('CGU.'::bytea), 'hex'),  true),
  ('confidentialite',      '1.0', now(), 'Conf.', encode(sha256('Conf.'::bytea), 'hex'), true),
  ('donnees_personnelles', '1.0', now(), 'RGPD.', encode(sha256('RGPD.'::bytea), 'hex'), true);

insert into auth.users (id) values ('00000000-0000-0000-0000-0000000000d1'::uuid);
insert into profiles (id, birth_date, langue, is_active)
values ('00000000-0000-0000-0000-0000000000d1', '1996-04-02', 'fr', false);

do $$
declare
  u uuid := '00000000-0000-0000-0000-0000000000d1';
  r record; n int; ph uuid; cat text;
begin
  insert into user_step_completions (user_id, step) values (u, 1), (u, 2);

  -- =================================================================
  --  ÉTAPE 3 — création du compte
  -- =================================================================

  -- CAS 1 — Le code n'est jamais comparé en clair, un code erroné est
  -- refusé et les tentatives sont comptées.
  insert into user_verification_codes (user_id, channel, destination, code_sha256)
  values (u, 'email', 'test@example.com', encode(sha256('K7X2P'::bytea), 'hex'));

  if private.verify_account_code(u, '00000') then
    raise exception 'CAS 1 ÉCHEC : un code erroné a été accepté';
  end if;
  if not private.verify_account_code(u, ' k7x2p ') then
    raise exception 'CAS 1 ÉCHEC : le code correct a été refusé';
  end if;
  select attempts into n from user_verification_codes where user_id = u;
  if n <> 2 then raise exception 'CAS 1 ÉCHEC : tentatives non comptées (%)', n; end if;
  raise notice 'CAS 1 OK  — code vérifié par empreinte, casse et espaces tolérés, 2 tentatives';

  -- CAS 2 — Un code expiré ne passe pas, même s'il est exact.
  update user_verification_codes
     set verified_at = null, attempts = 0, expires_at = now() - interval '1 minute'
   where user_id = u;
  if private.verify_account_code(u, 'K7X2P') then
    raise exception 'CAS 2 ÉCHEC : un code expiré a été accepté';
  end if;
  raise notice 'CAS 2 OK  — code expiré refusé';
  update user_verification_codes
     set expires_at = now() + interval '15 minutes', attempts = 0 where user_id = u;
  perform private.verify_account_code(u, 'K7X2P');

  -- =================================================================
  --  ÉTAPE 5 — questionnaire et consentements en ligne
  -- =================================================================

  update profiles set pays = 'CH' where id = u;
  insert into user_step_completions (user_id, step) values (u, 4);

  -- CAS 3 — L'étape ne peut pas être franchie sans les consentements
  -- article 9, et le message désigne les catégories manquantes pour que
  -- l'écran les présente au bon moment.
  begin
    perform private.complete_questionnaire_step(u);
    raise exception 'CAS 3 ÉCHEC : étape 5 franchie sans consentement article 9';
  exception when check_violation then
    select count(*) into n from private.consentements_requis_questionnaire(u) where not accorde;
    raise notice 'CAS 3 OK  — étape 5 verrouillée, % catégorie(s) article 9 en attente', n;
  end;

  -- CAS 4 — Le trigger de conformité refuse l'écriture directe d'une
  -- réponse sensible : le verrou ne dépend pas du parcours applicatif.
  begin
    perform private.submit_answer(u, 'val_religion_moi', array[2]::smallint[]);
    raise exception 'CAS 4 ÉCHEC : réponse sensible enregistrée sans consentement';
  exception when check_violation then
    raise notice 'CAS 4 OK  — écriture directe d''une réponse article 9 refusée';
  end;

  -- CAS 5 — Consentements accordés en ligne, puis questionnaire complété.
  for cat in select categorie::text from private.consentements_requis_questionnaire(u) loop
    insert into consents (user_id, category, policy_code, policy_version)
    values (u, cat::sensitive_category, 'confidentialite', '1.0');
  end loop;

  for r in select key from criteria where moment = 'onboarding' loop
    perform private.submit_answer(u, r.key, array[0]::smallint[]);
  end loop;

  perform private.complete_questionnaire_step(u);
  select onboarding_repondus into n from private.answer_progress(u);
  if n <> 20 then raise exception 'CAS 5 ÉCHEC : questionnaire à %/20', n; end if;
  raise notice 'CAS 5 OK  — 4 consentements en ligne puis questionnaire 20/20, étape 5 franchie';

  -- =================================================================
  --  ÉTAPES 6 et 7 — photos et biométrie
  -- =================================================================

  insert into user_photos (user_id, storage_path) values (u, 'photos/profil1.jpg')
  returning id into ph;
  insert into user_step_completions (user_id, step) values (u, 6);

  -- CAS 6 — Aucune donnée biométrique ne peut être traitée sans le
  -- consentement dédié, recueilli juste avant la capture.
  begin
    perform private.record_biometric_check(u, 'prestataire', 'sess_1', true, true, 0.97, ph);
    raise exception 'CAS 6 ÉCHEC : vérification biométrique acceptée sans consentement';
  exception when check_violation then
    raise notice 'CAS 6 OK  — capture biométrique refusée sans consentement dédié';
  end;

  insert into consents (user_id, category, policy_code, policy_version)
  values (u, 'biometrie', 'confidentialite', '1.0');

  -- CAS 7 — Vivacité validée mais comparaison faciale échouée : le
  -- compte ne doit pas être vérifié. C'est le cas que la simple
  -- détection de vivacité du devis ne couvrait pas.
  if private.record_biometric_check(u, 'prestataire', 'sess_2', true, false, 0.31, ph) then
    raise exception 'CAS 7 ÉCHEC : comparaison faciale échouée mais compte vérifié';
  end if;
  if (select is_verified from profiles where id = u) then
    raise exception 'CAS 7 ÉCHEC : profil marqué vérifié à tort';
  end if;
  raise notice 'CAS 7 OK  — vivacité seule insuffisante, la comparaison 1:1 fait foi';

  if not private.record_biometric_check(u, 'prestataire', 'sess_3', true, true, 0.96, ph) then
    raise exception 'CAS 7 ÉCHEC : vérification conforme refusée';
  end if;

  -- =================================================================
  --  ÉTAPE 8 — activation
  -- =================================================================

  -- CAS 8 — Activation refusée tant que le juridique manque, avec la
  -- liste nommée.
  begin
    perform private.activate_user(u);
    raise exception 'CAS 8 ÉCHEC : activation acceptée sans acceptation juridique';
  exception when check_violation then
    select count(*) into n from private.user_activation_checklist(u) where not coalesce(satisfaite, false);
    raise notice 'CAS 8 OK  — activation refusée, % condition(s) manquante(s) sur 10', n;
  end;

  insert into user_acceptances (user_id, policy_code, policy_version) values
    (u, 'cgu', '1.0'), (u, 'confidentialite', '1.0'), (u, 'donnees_personnelles', '1.0');

  perform private.activate_user(u);
  if not (select is_active from profiles where id = u) then
    raise exception 'CAS 9 ÉCHEC : le compte n''est pas actif';
  end if;
  raise notice 'CAS 9 OK  — activation effective, 10 conditions réunies';

  -- =================================================================
  --  ÉTAPE 9 — géolocalisation, non bloquante
  -- =================================================================

  -- CAS 10 — Le refus de la géolocalisation ne désactive pas le compte,
  -- il dégrade seulement les fonctionnalités de proximité.
  perform private.set_geolocation_choice(u, false, false, 'confidentialite', '1.0');
  if not (select is_active from profiles where id = u) then
    raise exception 'CAS 10 ÉCHEC : le refus de géolocalisation a désactivé le compte';
  end if;
  if private.proximite_disponible(u) then
    raise exception 'CAS 10 ÉCHEC : la proximité est annoncée disponible malgré le refus';
  end if;
  raise notice 'CAS 10 OK — refus de géolocalisation : compte actif, proximité dégradée';

  -- CAS 11 — L'autorisation reste réversible dans les deux sens.
  perform private.set_geolocation_choice(u, true, true, 'confidentialite', '1.0');
  if not private.proximite_disponible(u) then
    raise exception 'CAS 11 ÉCHEC : autorisation accordée mais proximité indisponible';
  end if;
  raise notice 'CAS 11 OK — autorisation de géolocalisation réversible';

  -- CAS 12 — Barre de progression.
  select * into r from private.user_progress(u);
  if r.etapes_total <> 9 then
    raise exception 'CAS 12 ÉCHEC : % étapes au lieu de 9', r.etapes_total;
  end if;
  if not r.compte_actif then
    raise exception 'CAS 12 ÉCHEC : le compte devrait être actif et vérifié';
  end if;
  raise notice 'CAS 12 OK — parcours terminé : étape % sur %, compte actif',
    r.etape_courante, r.etapes_total;

  raise notice '--------------------------------------------------';
  raise notice 'TOUS LES CAS SONT PASSÉS';
end $$;

rollback;

-- L'éditeur Supabase n'affiche pas les « raise notice ». Un échec lève une
-- exception, donc visible ; cette ligne rend la réussite visible aussi.
select 'TOUS LES CAS SONT PASSÉS' as resultat;
