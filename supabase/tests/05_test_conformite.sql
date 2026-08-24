-- =====================================================================
--  Prom'us — Vecteurs de test du socle de conformité (lot 01)
--
--  Chaque cas énonce une obligation réglementaire ou une exigence de
--  store, et vérifie qu'elle est tenue par la base elle-même. Un
--  contrôle CNIL ou une revue Apple se répond avec l'exécution de ce
--  script, pas avec une capture d'écran.
-- =====================================================================

begin;

insert into policy_documents (code, version, published_at, body, body_sha256, is_current)
values ('confidentialite', '1.0', now(), 'Texte de test.',
        encode(sha256('Texte de test.'::bytea), 'hex'), true);

insert into auth.users (id) values ('00000000-0000-0000-0000-0000000000f1');
insert into profiles (id, birth_date) values
  ('00000000-0000-0000-0000-0000000000f1', '1995-06-15');

do $$
declare u uuid := '00000000-0000-0000-0000-0000000000f1'; n int; ok boolean;
begin
  -- CAS 1 — Une réponse relevant de l'article 9 ne peut pas entrer en
  -- base sans consentement actif, quel que soit le chemin d'appel.
  begin
    insert into profile_answers (user_id, criterion_key, option_idx)
    values (u, 'db_sex_or_moi', array[0]);
    raise exception 'CAS 1 ÉCHEC : la réponse sensible a été acceptée sans consentement';
  exception when check_violation then
    raise notice 'CAS 1 OK  — refus d''écriture sans consentement (art. 9)';
  end;

  -- CAS 2 — Un critère non sensible reste librement enregistrable :
  -- la contrainte ne doit pas bloquer le questionnaire ordinaire.
  insert into profile_answers (user_id, criterion_key, option_idx)
  values (u, 'phys_taille_moi', array[5]);
  raise notice 'CAS 2 OK  — critère non sensible enregistré sans entrave';

  -- CAS 3 — Après consentement, l'écriture est autorisée.
  insert into consents (user_id, category, policy_code, policy_version)
  values (u, 'orientation_sexuelle', 'confidentialite', '1.0');
  insert into profile_answers (user_id, criterion_key, option_idx)
  values (u, 'db_sex_or_moi', array[0]);
  raise notice 'CAS 3 OK  — écriture autorisée après consentement explicite';

  -- CAS 4 — Le retrait du consentement efface effectivement les données.
  -- Un retrait qui laisserait la donnée en base ne serait pas un retrait.
  update consents set withdrawn_at = now()
  where user_id = u and category = 'orientation_sexuelle';
  select count(*) into n from profile_answers
  where user_id = u and criterion_key like 'db_sex_or%';
  if n <> 0 then
    raise exception 'CAS 4 ÉCHEC : % réponse(s) sensible(s) subsistent après retrait', n;
  end if;
  select count(*) into n from profile_answers where user_id = u;
  if n <> 1 then
    raise exception 'CAS 4 ÉCHEC : le retrait a effacé des données non concernées (% restantes)', n;
  end if;
  raise notice 'CAS 4 OK  — retrait du consentement : effacement ciblé et complet';

  -- CAS 5 — Aucun compte de moins de 18 ans ne peut exister.
  begin
    insert into auth.users (id) values ('00000000-0000-0000-0000-0000000000f2');
    insert into profiles (id, birth_date)
    values ('00000000-0000-0000-0000-0000000000f2', current_date - interval '16 years');
    raise exception 'CAS 5 ÉCHEC : un profil mineur a été créé';
  exception when check_violation then
    raise notice 'CAS 5 OK  — création d''un compte mineur refusée par la base';
  end;
end $$;

-- ---------------------------------------------------------------------
--  Modération et visibilité
-- ---------------------------------------------------------------------
do $$
declare a uuid := '00000000-0000-0000-0000-0000000000a1';
        b uuid := '00000000-0000-0000-0000-0000000000b1';
        c uuid := '00000000-0000-0000-0000-0000000000c1';
        n int;
begin
  insert into auth.users (id) values (a), (b), (c);
  insert into profiles (id, birth_date, is_verified) values
    (a, '1990-01-01', true), (b, '1991-01-01', true), (c, '1992-01-01', true);

  -- CAS 6 — Le blocage est symétrique : celui qui a bloqué disparaît
  -- aussi de la vue de celui qui a été bloqué.
  insert into blocks (blocker_id, blocked_id) values (a, b);
  select count(*) into n from private.eligible_candidates(a) where candidate_id = b;
  if n <> 0 then raise exception 'CAS 6 ÉCHEC : le profil bloqué reste visible du bloqueur'; end if;
  select count(*) into n from private.eligible_candidates(b) where candidate_id = a;
  if n <> 0 then raise exception 'CAS 6 ÉCHEC : le blocage n''est pas symétrique'; end if;
  raise notice 'CAS 6 OK  — blocage symétrique et effectif dans les deux sens';

  -- CAS 7 — Un profil signalé sort du flux jusqu'à traitement, sans que
  -- le signalant ait à le bloquer lui-même.
  insert into reports (reporter_id, reported_id, reason) values (a, c, 'faux_profil');
  select count(*) into n from private.eligible_candidates(a) where candidate_id = c;
  if n <> 0 then raise exception 'CAS 7 ÉCHEC : un profil signalé reste dans le flux'; end if;
  raise notice 'CAS 7 OK  — profil signalé retiré du flux en attente de modération';

  -- CAS 8 — Suppression de compte en cascade. Aucune trace personnelle
  -- ne doit subsister, mais le signalement émis contre C doit rester
  -- exploitable par la modération après le départ du signalant.
  perform private.request_account_deletion(a);
  perform private.execute_account_deletion(a);

  select count(*) into n from profiles where id = a;
  if n <> 0 then raise exception 'CAS 8 ÉCHEC : le profil subsiste'; end if;
  select count(*) into n from profile_answers where user_id = a;
  if n <> 0 then raise exception 'CAS 8 ÉCHEC : des réponses subsistent'; end if;
  select count(*) into n from blocks where blocker_id = a or blocked_id = a;
  if n <> 0 then raise exception 'CAS 8 ÉCHEC : des blocages subsistent'; end if;
  select count(*) into n from auth.users where id = a;
  if n <> 0 then raise exception 'CAS 8 ÉCHEC : le compte d''authentification subsiste'; end if;

  select count(*) into n from reports where reported_id = c;
  if n <> 1 then
    raise exception 'CAS 8 ÉCHEC : le signalement a disparu avec son auteur (% restant)', n;
  end if;
  select count(*) into n from reports where reported_id = c and reporter_id is null;
  if n <> 1 then
    raise exception 'CAS 8 ÉCHEC : le signalement désigne encore un auteur supprimé';
  end if;
  raise notice 'CAS 8 OK  — suppression en cascade : effacement complet, signalement anonymisé et conservé';

  raise notice '--------------------------------------------------';
  raise notice 'TOUS LES CAS SONT PASSÉS';
end $$;

rollback;

-- L'éditeur Supabase n'affiche pas les « raise notice ». Un échec lève une
-- exception, donc visible ; cette ligne rend la réussite visible aussi.
select 'TOUS LES CAS SONT PASSÉS' as resultat;
