-- =====================================================================
--  Prom'us — Vecteurs de test du moteur de questionnaire (lot 02)
-- =====================================================================

begin;

insert into policy_documents (code, version, published_at, body, body_sha256, is_current)
values ('confidentialite', '1.0', now(), 'Texte de test.',
        encode(sha256('Texte de test.'::bytea), 'hex'), true);

insert into auth.users (id) values ('00000000-0000-0000-0000-0000000000e1');
insert into profiles (id, birth_date) values
  ('00000000-0000-0000-0000-0000000000e1', '1995-06-15');

do $$
declare
  u uuid := '00000000-0000-0000-0000-0000000000e1';
  r record; n int; k text;
begin
  -- CAS 1 — Un profil neuf ne reçoit que des critères d'inscription, et
  -- aucun critère sensible tant qu'aucun consentement n'est actif.
  select count(*) into n from private.next_questions(u, 40) where moment <> 'onboarding';
  if n <> 0 then
    raise exception 'CAS 1 ÉCHEC : % question(s) de quiz proposée(s) avant la fin de l''inscription', n;
  end if;
  select count(*) into n from private.next_questions(u, 40) q
    join criteria c on c.key = q.criterion_key
    where c.sensitive_category is not null;
  if n <> 0 then
    raise exception 'CAS 1 ÉCHEC : % critère(s) sensible(s) proposé(s) sans consentement', n;
  end if;
  select count(*) into n from private.next_questions(u, 40);
  raise notice 'CAS 1 OK  — inscription seule, % questions ouvertes sur 20 (8 en attente de consentement)', n;

  -- CAS 2 — Le consentement débloque les critères correspondants, et
  -- l'ordre du fichier client est respecté : le genre redevient premier.
  insert into consents (user_id, category, policy_code, policy_version)
  values (u, 'identite_genre', 'confidentialite', '1.0');
  select criterion_key into k from private.next_questions(u, 1);
  if k <> 'genre_moi' then
    raise exception 'CAS 2 ÉCHEC : première question attendue genre_moi, obtenue %', k;
  end if;
  raise notice 'CAS 2 OK  — le consentement débloque le critère et restaure l''ordre d''inscription';

  -- CAS 3 — Aucun critère « backend » n'est jamais proposé tant que
  -- l'arbitrage du § 2.2 de la note de cadrage n'est pas rendu.
  insert into consents (user_id, category, policy_code, policy_version) values
    (u, 'orientation_sexuelle', 'confidentialite', '1.0'),
    (u, 'convictions_religieuses', 'confidentialite', '1.0'),
    (u, 'sante', 'confidentialite', '1.0'),
    (u, 'opinions_politiques', 'confidentialite', '1.0'),
    (u, 'origine_ethnique', 'confidentialite', '1.0');
  select count(*) into n from private.next_questions(u, 300) where moment = 'backend';
  if n <> 0 then
    raise exception 'CAS 3 ÉCHEC : % critère(s) backend proposé(s)', n;
  end if;
  raise notice 'CAS 3 OK  — critères backend exclus du parcours même avec tous les consentements';

  -- CAS 4 — submit_answer refuse une option qui n'existe pas. Sans ce
  -- contrôle, l'option produirait un bit hors masque et le critère
  -- serait silencieusement mort pour le moteur.
  begin
    perform private.submit_answer(u, 'genre_moi', array[9]::smallint[]);
    raise exception 'CAS 4 ÉCHEC : option hors bornes acceptée';
  exception when check_violation then
    raise notice 'CAS 4 OK  — option hors bornes refusée';
  end;

  -- CAS 5 — Un critère à choix unique refuse une réponse multiple.
  begin
    perform private.submit_answer(u, 'genre_moi', array[0,1]::smallint[]);
    raise exception 'CAS 5 ÉCHEC : réponse multiple acceptée sur un critère mono';
  exception when check_violation then
    raise notice 'CAS 5 OK  — réponse multiple refusée sur un critère à choix unique';
  end;

  -- CAS 6 — Répondre à une face rend l'autre face de la paire prioritaire :
  -- une demi-paire n'apporte rien au score bidirectionnel.
  perform private.submit_answer(u, 'genre_moi', array[0]::smallint[]);
  select motif into k from private.next_questions(u, 300)
    where criterion_key = 'genre_rech';
  if k is distinct from 'Critère obligatoire' then
    raise exception 'CAS 6 ÉCHEC : motif inattendu pour la face complémentaire : %', k;
  end if;
  -- hors inscription, le motif doit devenir explicite
  perform private.submit_answer(u, 'chev_longueur_moi', array[1]::smallint[]);
  select motif into k from private.next_questions(u, 300)
    where criterion_key = 'chev_longueur_rech';
  if k <> 'Complète une paire déjà entamée' then
    raise exception 'CAS 6 ÉCHEC : la face complémentaire n''est pas priorisée (motif %)', k;
  end if;
  raise notice 'CAS 6 OK  — la face complémentaire d''une paire entamée est priorisée';

  -- CAS 7 — Bascule vers le quiz une fois l'inscription complète.
  for r in select key from criteria where moment = 'onboarding' loop
    perform private.submit_answer(u, r.key, array[0]::smallint[]);
  end loop;
  select count(*) into n from private.next_questions(u, 5) where moment <> 'quiz';
  if n <> 0 then
    raise exception 'CAS 7 ÉCHEC : % question hors quiz après inscription complète', n;
  end if;
  select onboarding_repondus into n from private.answer_progress(u);
  if n <> 20 then
    raise exception 'CAS 7 ÉCHEC : progression d''inscription incohérente (%)', n;
  end if;
  raise notice 'CAS 7 OK  — bascule sur le quiz interstitiel, inscription à 20/20';

  raise notice '--------------------------------------------------';
  raise notice 'TOUS LES CAS SONT PASSÉS';
end $$;

rollback;

-- L'éditeur Supabase n'affiche pas les « raise notice ». Un échec lève une
-- exception, donc visible ; cette ligne rend la réussite visible aussi.
select 'TOUS LES CAS SONT PASSÉS' as resultat;
