-- =====================================================================
--  Safe Date / Prom'us — AUDIT D'EXPOSITION
--
--  Ce script ne vérifie pas que le schéma est correct : il vérifie qu'il
--  est FERMÉ. Il se met successivement dans la peau d'un porteur de clé
--  anonyme, puis d'un utilisateur authentifié qui tente de lire les
--  données d'un autre, et rend un tableau de verdicts.
--
--  Il doit tourner sur un environnement reproduisant Supabase : rôles
--  anon / authenticated / service_role, privilèges par défaut du schéma
--  public, et auth.uid() lisant request.jwt.claim.sub. Sans cela il ne
--  démontre rien — c'est précisément l'erreur qui a laissé passer onze
--  défauts d'exposition dans les versions précédentes.
-- =====================================================================

begin;

-- Deux victimes de test
insert into auth.users (id) values
  ('aaaaaaaa-0000-0000-0000-000000000001'),
  ('bbbbbbbb-0000-0000-0000-000000000002');
insert into profiles (id, birth_date, langue, pays, is_active, is_verified) values
  ('aaaaaaaa-0000-0000-0000-000000000001', '1994-01-01', 'fr', 'CH', true, true),
  ('bbbbbbbb-0000-0000-0000-000000000002', '1995-01-01', 'fr', 'CH', true, true);

insert into policy_documents (code, version, published_at, body, body_sha256, is_current)
values ('confidentialite','1.0',now(),'C',encode(sha256('C'::bytea),'hex'),true);
insert into consents (user_id, category, policy_code, policy_version)
select 'bbbbbbbb-0000-0000-0000-000000000002'::uuid, s.sensitive_category, 'confidentialite','1.0'
from (select distinct sensitive_category from criteria where sensitive_category is not null) s;
select private.submit_answer('bbbbbbbb-0000-0000-0000-000000000002',
                             'db_sex_or_moi', array[0]::smallint[]);
select private.submit_answer('bbbbbbbb-0000-0000-0000-000000000002',
                             'val_religion_moi', array[2]::smallint[]);
insert into user_photos (user_id, storage_path) values
  ('bbbbbbbb-0000-0000-0000-000000000002', 'photos/victime.jpg');
insert into user_verification_codes (user_id, channel, destination, code_sha256)
values ('bbbbbbbb-0000-0000-0000-000000000002', 'email', 'victime@test.ch',
        encode(sha256('SECRET'::bytea),'hex'));

create temporary table verdicts (
  ordre int, acteur text, tentative text, resultat text, verdict text);

-- ---------------------------------------------------------------------
--  Sonde générique : exécute une requête sous un rôle donné et compare
--  le nombre de lignes obtenu au maximum tolérable.
-- ---------------------------------------------------------------------
create or replace function pg_temp.sonde(
  p_ordre int, p_acteur text, p_role text, p_sub text,
  p_tentative text, p_sql text, p_max int)
returns void language plpgsql as $$
declare n int; msg text;
begin
  begin
    execute format('set local role %I', p_role);
    if p_sub is null then
      perform set_config('request.jwt.claim.sub', '', true);
    else
      perform set_config('request.jwt.claim.sub', p_sub, true);
    end if;
    execute 'select count(*) from (' || p_sql || ') s' into n;
    reset role;
    insert into verdicts values (p_ordre, p_acteur, p_tentative, n || ' ligne(s)',
      case when n <= p_max then 'FERMÉ' else 'FUITE' end);
  exception when others then
    reset role;
    msg := sqlerrm;
    insert into verdicts values (p_ordre, p_acteur, p_tentative,
      left(msg, 60), 'FERMÉ (refus)');
  end;
end $$;

-- Sonde d'écriture : exécute une instruction modifiante et compte les
-- lignes affectées. Une instruction modifiante ne peut pas être imbriquée
-- dans un « select count(*) from (…) ».
create or replace function pg_temp.sonde_ecriture(
  p_ordre int, p_acteur text, p_role text, p_sub text,
  p_tentative text, p_sql text, p_doit_reussir boolean)
returns void language plpgsql as $$
declare n int; msg text;
begin
  begin
    execute format('set local role %I', p_role);
    perform set_config('request.jwt.claim.sub', coalesce(p_sub, ''), true);
    execute p_sql;
    get diagnostics n = row_count;
    reset role;
    insert into verdicts values (p_ordre, p_acteur, p_tentative, n || ' ligne(s) écrite(s)',
      case when p_doit_reussir then 'OUVERT (attendu)' else 'FUITE' end);
  exception when others then
    reset role;
    msg := sqlerrm;
    insert into verdicts values (p_ordre, p_acteur, p_tentative, left(msg, 55),
      case when p_doit_reussir then 'PANNE' else 'FERMÉ (refus)' end);
  end;
end $$;

-- =====================================================================
--  A. PORTEUR DE LA CLÉ ANONYME
--     Cette clé est publique : embarquée dans l'application mobile,
--     extractible de n'importe quel binaire.
-- =====================================================================

select pg_temp.sonde(1,'anon','anon',null,'Lire les profils',
  'select * from profiles', 0);
select pg_temp.sonde(2,'anon','anon',null,'Lire les réponses au questionnaire',
  'select * from profile_answers', 0);
select pg_temp.sonde(3,'anon','anon',null,'Lire les consentements article 9',
  'select * from consents', 0);
select pg_temp.sonde(4,'anon','anon',null,'Lire les photos de profil',
  'select * from user_photos', 0);
select pg_temp.sonde(5,'anon','anon',null,'Lire les codes de vérification',
  'select * from user_verification_codes', 0);
select pg_temp.sonde(6,'anon','anon',null,'Lire les paramètres du moteur',
  'select * from engine_params', 0);
select pg_temp.sonde(7,'anon','anon',null,'Lire la table de correspondance',
  'select * from option_mappings', 0);
select pg_temp.sonde(8,'anon','anon',null,'Lire les zones de rendez-vous',
  'select * from partner_safe_zones', 0);
select pg_temp.sonde(9,'anon','anon',null,'Lire les signalements',
  'select * from reports', 0);
select pg_temp.sonde(10,'anon','anon',null,'Lire les statistiques de population',
  'select * from private.criterion_stats', 0);
select pg_temp.sonde(11,'anon','anon',null,'Appeler l''accesseur des paramètres',
  'select private.engine_param(''point_rdv_dist_min'')', 0);
select pg_temp.sonde(12,'anon','anon',null,'Supprimer un compte (RPC)',
  'select private.execute_account_deletion(''bbbbbbbb-0000-0000-0000-000000000002'')', 0);
select pg_temp.sonde(13,'anon','anon',null,'Écrire une réponse chez autrui',
  'select private.submit_answer(''bbbbbbbb-0000-0000-0000-000000000002'',''phys_taille_moi'',array[0]::smallint[])', 0);
select pg_temp.sonde(14,'anon','anon',null,'Lister les candidats',
  'select * from eligible_candidates()', 0);

-- =====================================================================
--  B. UTILISATEUR AUTHENTIFIÉ QUI VISE UN AUTRE UTILISATEUR
--     Le cas réaliste : un compte légitime qui tente de lire ou de
--     modifier les données d'un tiers.
-- =====================================================================

select pg_temp.sonde(20,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire le profil de B','select * from profiles where id = ''bbbbbbbb-0000-0000-0000-000000000002''', 0);
select pg_temp.sonde(21,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire les réponses de B','select * from profile_answers where user_id = ''bbbbbbbb-0000-0000-0000-000000000002''', 0);
select pg_temp.sonde(22,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire l''orientation sexuelle de B',
  'select * from profile_answers where user_id = ''bbbbbbbb-0000-0000-0000-000000000002'' and criterion_key = ''db_sex_or_moi''', 0);
select pg_temp.sonde(23,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire les consentements de B','select * from consents where user_id = ''bbbbbbbb-0000-0000-0000-000000000002''', 0);
select pg_temp.sonde(24,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire les photos de B','select * from user_photos where user_id = ''bbbbbbbb-0000-0000-0000-000000000002''', 0);
select pg_temp.sonde(25,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire le code de vérification de B','select * from user_verification_codes where user_id = ''bbbbbbbb-0000-0000-0000-000000000002''', 0);
select pg_temp.sonde(26,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire les vecteurs de B','select * from profile_vectors where user_id = ''bbbbbbbb-0000-0000-0000-000000000002''', 0);
select pg_temp.sonde(27,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Supprimer le compte de B',
  'select private.execute_account_deletion(''bbbbbbbb-0000-0000-0000-000000000002'')', 0);
select pg_temp.sonde(28,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Écrire une réponse chez B',
  'select private.submit_answer(''bbbbbbbb-0000-0000-0000-000000000002'',''phys_taille_moi'',array[0]::smallint[])', 0);
select pg_temp.sonde(29,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire la géométrie des points de rendez-vous',
  'select private.engine_param(''point_rdv_dist_min'')', 0);
select pg_temp.sonde(30,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire la table de correspondance','select * from option_mappings', 0);
select pg_temp.sonde(31,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire les zones de rendez-vous','select * from partner_safe_zones', 0);

select pg_temp.sonde(32,'anon','anon',null,'Lire les vues de diagnostic (questions et options)',
  'select * from v_mappings_manquants', 0);
select pg_temp.sonde(33,'anon','anon',null,'Lire les correspondances par la vue de diagnostic',
  'select * from v_mappings_invalides', 0);
select pg_temp.sonde(34,'anon','anon',null,'Lire les formulations manquantes',
  'select * from v_phrasings_manquants', 0);
select pg_temp.sonde(35,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire les vues de diagnostic','select * from v_mappings_manquants', 0);
select pg_temp.sonde(36,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire la posture de sécurité','select * from v_tables_sans_rls', 0);
select pg_temp.sonde_ecriture(37,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Écrire une réponse en direct par la Data API',
  'insert into profile_answers (user_id, criterion_key, option_idx)
   values (''aaaaaaaa-0000-0000-0000-000000000001'',''phys_taille_moi'',array[0]::smallint[])',
  false);

-- =====================================================================
--  C. CE QUI DOIT RESTER OUVERT
--     Un schéma fermé qui empêche l'application de fonctionner ne vaut
--     pas mieux qu'un schéma ouvert.
-- =====================================================================

select pg_temp.sonde(40,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire son propre profil','select * from profiles where id = ''aaaaaaaa-0000-0000-0000-000000000001''', 999);
select pg_temp.sonde(41,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire le référentiel des critères','select * from criteria', 999);
select pg_temp.sonde(42,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Obtenir ses prochaines questions','select * from next_questions(3)', 999);
select pg_temp.sonde(43,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Consulter sa progression','select * from answer_progress()', 999);
select pg_temp.sonde(44,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lister ses candidats','select * from eligible_candidates()', 999);
select pg_temp.sonde(45,'utilisateur A','authenticated','aaaaaaaa-0000-0000-0000-000000000001',
  'Lire les statistiques de population','select * from private.criterion_stats', 999);
select pg_temp.sonde(46,'anon','anon',null,'Lire les CGU avant inscription',
  'select * from policy_documents', 999);
select pg_temp.sonde(47,'utilisateur B','authenticated','bbbbbbbb-0000-0000-0000-000000000002',
  'Écrire sa réponse par submit_answer',
  'select 1 from (select public.submit_answer(''phys_taille_moi'', array[3]::smallint[])) x', 999);
select pg_temp.sonde_ecriture(48,'utilisateur B','authenticated','bbbbbbbb-0000-0000-0000-000000000002',
  'Retirer son consentement article 9 (droit RGPD)',
  'update consents set withdrawn_at = now()
    where user_id = ''bbbbbbbb-0000-0000-0000-000000000002''
      and category = ''orientation_sexuelle''', true);

-- =====================================================================
--  VERDICT
-- =====================================================================

select acteur, tentative, resultat, verdict from verdicts order by ordre;

rollback;
