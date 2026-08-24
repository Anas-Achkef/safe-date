-- Retrait du moteur parallele introduit par erreur : le projet disposait
-- deja de private.compat_score, private.candidate_cards et
-- private.refresh_profile_vectors, avec un encodage de pref_mask different
-- (masque des options acceptees pre-resolu, et non index de preference).

-- 1. Neutraliser les declencheurs d'apprentissage : ils s'appuyaient sur
--    compat_explain, donc sur la mauvaise semantique.
drop trigger if exists swipe_decisions_apprentissage on swipe_decisions;
drop trigger if exists conversation_decisions_apprentissage on conversation_decisions;
drop trigger if exists date_reviews_apprentissage on date_reviews;

-- 2. Supprimer les fonctions faisant doublon avec l'existant.
drop function if exists compat_candidates(uuid, integer);
drop function if exists compat_mutual(uuid, uuid);
drop function if exists compat_directional(uuid, uuid);
drop function if exists compat_explain(uuid, uuid);
drop function if exists apply_learning(uuid, uuid, boolean, numeric, score_group[]);
drop function if exists rebuild_profile_vector(uuid);

-- 3. Purger les donnees d'apprentissage issues du test, calculees avec la
--    mauvaise semantique.
truncate user_criterion_learning;

-- 4. Restaurer les vecteurs avec la fonction officielle du projet.
select private.refresh_profile_vectors(id) from profiles;;
