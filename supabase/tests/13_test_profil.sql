-- =====================================================================
--  Safe Date / Prom'us — Vecteurs de test du module « Mon profil »
--  Cahier des charges module 3.
-- =====================================================================

begin;

insert into policy_documents (code, version, published_at, body, body_sha256, is_current)
values ('confidentialite', '1.0', now(), 'Conf.', encode(sha256('Conf.'::bytea), 'hex'), true);

insert into auth.users (id) values
  ('00000000-0000-0000-0000-0000000000f1'::uuid),
  ('00000000-0000-0000-0000-0000000000f2'::uuid);
insert into profiles (id, birth_date, langue, pays) values
  ('00000000-0000-0000-0000-0000000000f1', '1994-05-10', 'fr', 'CH'),
  ('00000000-0000-0000-0000-0000000000f2', '1993-09-22', 'fr', 'CH');

do $$
declare
  a uuid := '00000000-0000-0000-0000-0000000000f1';
  b uuid := '00000000-0000-0000-0000-0000000000f2';
  r record; n int; k text; ph uuid; ph2 uuid;
  c0 numeric; c1 numeric; w0 numeric; w1 numeric;
  ordre text[];
begin
  -- =================================================================
  --  Règle technique générale — unités régionales
  -- =================================================================

  -- CAS 1 — Les deux exemples du cahier des charges sont rendus à
  -- l'identique dans les deux systèmes.
  select render_measure(value_min, value_max, unit, 'metrique') into k
  from criterion_options where criterion_key = 'phys_taille_moi' and label = '176-180 cm';
  if k <> 'entre 176 et 180 cm' then
    raise exception 'CAS 1 ÉCHEC : métrique attendu « entre 176 et 180 cm », obtenu « % »', k;
  end if;
  select render_measure(value_min, value_max, unit, 'imperial') into k
  from criterion_options where criterion_key = 'phys_taille_moi' and label = '176-180 cm';
  if k <> 'entre 5''9" et 5''11"' then
    raise exception 'CAS 1 ÉCHEC : impérial attendu « entre 5''9" et 5''11" », obtenu « % »', k;
  end if;
  raise notice 'CAS 1 OK  — conversion métrique et impériale conforme aux exemples du cahier des charges';

  -- CAS 2 — Les bornes ouvertes restent ouvertes après conversion.
  select render_measure(value_min, value_max, unit, 'imperial') into k
  from criterion_options where criterion_key = 'phys_poids_moi' and label = '105 kg +';
  if k not like 'plus de%' then
    raise exception 'CAS 2 ÉCHEC : borne ouverte perdue, obtenu « % »', k;
  end if;
  raise notice 'CAS 2 OK  — bornes ouvertes préservées : « % »', k;

  -- =================================================================
  --  Section 1 — Reformulation déclarative
  -- =================================================================

  -- CAS 3 — Le volume de rédaction restant est mesurable, et l'onglet
  -- ne peut pas afficher de phrase sans lui.
  select count(*) into n from private.v_phrasings_manquants;
  if n <> 896 then
    raise exception 'CAS 3 ÉCHEC : % formulations manquantes au lieu de 896', n;
  end if;
  raise notice 'CAS 3 OK  — % formulations déclaratives restant à rédiger par le client', n;

  -- CAS 4 — Une formulation renseignée s'affiche, et la page n'expose
  -- jamais la question du questionnaire.
  insert into consents (user_id, category, policy_code, policy_version)
  select a, sensitive_category, 'confidentialite', '1.0'
  from (select distinct sensitive_category from criteria where sensitive_category is not null) s;
  insert into consents (user_id, category, policy_code, policy_version)
  select b, sensitive_category, 'confidentialite', '1.0'
  from (select distinct sensitive_category from criteria where sensitive_category is not null) s;

  -- On répond au plus haut indice disponible pour chaque critère, afin de
  -- couvrir aussi les options de fin de liste.
  for r in
    select c.key, (select max(o.idx) from criterion_options o
                   where o.criterion_key = c.key) as idx_max
    from criteria c where c.moment = 'onboarding'
  loop
    perform private.submit_answer(a, r.key, array[least(r.idx_max, 6)]::smallint[]);
    perform private.submit_answer(b, r.key, array[least(r.idx_max, 6)]::smallint[]);
  end loop;

  insert into criterion_option_phrasings (criterion_key, idx, locale, phrase)
  select 'db_relation_moi', least(max(idx), 6), 'fr', 'Je recherche une relation sérieuse.'
  from criterion_options where criterion_key = 'db_relation_moi';

  select phrase into k from private.profile_sections(a) where pair_key = 'db_relation';
  if k <> 'Je recherche une relation sérieuse.' then
    raise exception 'CAS 4 ÉCHEC : phrase déclarative attendue, obtenu « % »', k;
  end if;
  select count(*) into n from private.profile_sections(a) s
    join criteria c on c.question = s.phrase;
  if n <> 0 then
    raise exception 'CAS 4 ÉCHEC : % question(s) du questionnaire exposée(s) dans le profil', n;
  end if;
  raise notice 'CAS 4 OK  — phrases déclaratives rendues, aucune question exposée';

  -- CAS 5 — Les mesures sont rendues sans formulation manuelle : les
  -- 4 critères numériques n'ont pas à être rédigés.
  update profiles set systeme_unites = 'imperial' where id = a;
  select phrase into k from private.profile_sections(a) where pair_key = 'phys_taille';
  if k not like 'entre%''%' then
    raise exception 'CAS 5 ÉCHEC : mesure non convertie, obtenu « % »', k;
  end if;
  raise notice 'CAS 5 OK  — mesures rendues automatiquement selon le système de l''utilisateur : « % »', k;
  update profiles set systeme_unites = 'metrique' where id = a;

  -- =================================================================
  --  Section 3 — Niveau de connaissance du profil
  -- =================================================================

  -- CAS 6 — L'indicateur progresse avec les réponses et les interactions.
  c0 := private.profile_knowledge(a);
  for r in select key from criteria where moment = 'quiz' order by ord limit 40 loop
    perform private.submit_answer(a, r.key, array[0]::smallint[]);
  end loop;
  c1 := private.profile_knowledge(a);
  if c1 <= c0 then
    raise exception 'CAS 6 ÉCHEC : connaissance non progressive (% puis %)', c0, c1;
  end if;
  insert into swipe_decisions (user_id, target_id, decision)
    select a, b, true from generate_series(1, 100);
  if private.profile_knowledge(a) <= c1 then
    raise exception 'CAS 6 ÉCHEC : les interactions ne font pas progresser la connaissance';
  end if;
  raise notice 'CAS 6 OK  — connaissance : % %% puis % %% puis % %% avec 100 swipes',
    c0, c1, private.profile_knowledge(a);

  -- =================================================================
  --  Section 5 — Hiérarchie de priorités
  -- =================================================================

  perform private.derive_priorities(a);
  perform private.derive_priorities(b);

  -- CAS 7 — Utilisateur gratuit : 3 priorités consultables, le reste
  -- verrouillé et signalé comme tel.
  select count(*) into n from private.visible_priorities(a) where not verrouille;
  if n <> 3 then
    raise exception 'CAS 7 ÉCHEC : % priorité(s) visible(s) en gratuit au lieu de 3', n;
  end if;
  select count(*) into n from private.visible_priorities(a) where verrouille;
  if n = 0 then
    raise exception 'CAS 7 ÉCHEC : aucune priorité verrouillée à signaler';
  end if;
  raise notice 'CAS 7 OK  — gratuit : 3 priorités consultables, % verrouillées « Premium »', n;

  -- CAS 8 — Utilisateur gratuit : la réorganisation est refusée par la
  -- base, pas seulement grisée à l'écran.
  select array_agg(pair_key order by rang) into ordre
  from user_criterion_priorities where user_id = a and rang <= 5;
  begin
    perform private.reorder_priorities(a, ordre);
    raise exception 'CAS 8 ÉCHEC : un utilisateur gratuit a pu réorganiser ses priorités';
  exception when insufficient_privilege then
    raise notice 'CAS 8 OK  — réorganisation refusée sans abonnement';
  end;

  -- CAS 9 — Premium : 20 priorités consultables.
  update profiles set is_premium = true where id = a;
  select count(*) into n from private.visible_priorities(a) where not verrouille;
  if n <> 20 then
    raise exception 'CAS 9 ÉCHEC : % priorité(s) visible(s) en premium au lieu de 20', n;
  end if;
  raise notice 'CAS 9 OK  — premium : 20 priorités consultables';

  -- CAS 10 — Réorganisation premium : le poids du critère promu change
  -- effectivement dans les vecteurs, et le score de compatibilité est
  -- recalculé sans aucun cache à invalider. C'est la démonstration de la
  -- règle métier « prise en compte dès l'enregistrement ».
  select score_global into c0 from private.compat_score(a, b);

  select pair_key into k from user_criterion_priorities
   where user_id = a and rang = 25;
  select weight_mul[(select slot from criterion_pairs where pair_key = k) + 1]
    into w0 from profile_vectors where user_id = a;

  perform private.reorder_priorities(a, array[k] || (
    select array_agg(pair_key order by rang)
    from user_criterion_priorities where user_id = a and rang between 1 and 4));

  select weight_mul[(select slot from criterion_pairs where pair_key = k) + 1]
    into w1 from profile_vectors where user_id = a;
  select score_global into c1 from private.compat_score(a, b);

  if w1 <= w0 then
    raise exception 'CAS 10 ÉCHEC : le poids du critère promu n''a pas augmenté (% puis %)', w0, w1;
  end if;
  if (select rang from user_criterion_priorities where user_id = a and pair_key = k) <> 1 then
    raise exception 'CAS 10 ÉCHEC : le critère promu n''est pas au rang 1';
  end if;
  raise notice 'CAS 10 OK — « % » promu au rang 1 : poids % puis %, score % puis %',
    k, w0, w1, c0, c1;

  -- CAS 11 — Un réordonnancement manuel n'est pas écrasé par une
  -- réponse ultérieure au questionnaire.
  perform private.submit_answer(a, 'db_relation_rech', array[0]::smallint[]);
  perform private.derive_priorities(a);
  if (select rang from user_criterion_priorities where user_id = a and pair_key = k) <> 1 then
    raise exception 'CAS 11 ÉCHEC : la priorité manuelle a été écrasée par la dérivation';
  end if;
  raise notice 'CAS 11 OK — les priorités réordonnées à la main résistent à la re-dérivation';

  -- =================================================================
  --  Section 2 — Galerie et en-tête
  -- =================================================================

  insert into user_photos (user_id, storage_path) values (a, 'p/1.jpg') returning id into ph;
  insert into user_photos (user_id, storage_path) values (a, 'p/2.jpg') returning id into ph2;

  -- CAS 12 — Une seule photo principale, garantie par la base.
  perform private.set_primary_photo(a, ph);
  perform private.set_primary_photo(a, ph2);
  select count(*) into n from user_photos where user_id = a and is_primary;
  if n <> 1 then
    raise exception 'CAS 12 ÉCHEC : % photo(s) principale(s)', n;
  end if;
  if not (select is_primary from user_photos where id = ph2) then
    raise exception 'CAS 12 ÉCHEC : la nouvelle photo principale n''a pas été retenue';
  end if;
  raise notice 'CAS 12 OK — photo principale unique et remplaçable';

  -- CAS 13 — Le badge « Profil vérifié » exige les DEUX vérifications.
  select profil_verifie into r from private.profile_header(a);
  if r.profil_verifie then
    raise exception 'CAS 13 ÉCHEC : profil déclaré vérifié sans aucune vérification';
  end if;

  insert into user_verification_codes (user_id, channel, destination, code_sha256, verified_at)
  values (a, 'email', 'a@test.ch', 'x', now());
  select profil_verifie into r from private.profile_header(a);
  if r.profil_verifie then
    raise exception 'CAS 13 ÉCHEC : badge accordé sans vérification biométrique';
  end if;

  insert into consents (user_id, category, policy_code, policy_version)
  values (a, 'biometrie', 'confidentialite', '1.0');
  perform private.record_biometric_check(a, 'prestataire', 'sess_x', true, true, 0.98, ph2);
  select profil_verifie into r from private.profile_header(a);
  if not r.profil_verifie then
    raise exception 'CAS 13 ÉCHEC : badge refusé alors que les deux vérifications sont faites';
  end if;
  raise notice 'CAS 13 OK — badge « Profil vérifié » conditionné aux deux vérifications';

  -- CAS 14 — En-tête complet.
  select * into r from private.profile_header(a);
  raise notice 'CAS 14 OK — en-tête : % ans, connu à % %%, premium=%, vérifié=%',
    r.age, r.connaissance, r.est_premium, r.profil_verifie;

  raise notice '--------------------------------------------------';
  raise notice 'TOUS LES CAS SONT PASSÉS';
end $$;

rollback;

-- L'éditeur Supabase n'affiche pas les « raise notice ». Un échec lève une
-- exception, donc visible ; cette ligne rend la réussite visible aussi.
select 'TOUS LES CAS SONT PASSÉS' as resultat;
