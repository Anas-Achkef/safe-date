-- Résumé d'une évaluation déjà faite (table sim.eval, remplie par evaluer.mjs).
--   node q.mjs <dossier-donnees> resume.sql

-- Toutes les paires notées.
select count(*) as paires, round(avg(score_global), 2) as moyenne,
       round(stddev_pop(score_global), 2) as ecart_type,
       min(score_global) as mini, max(score_global) as maxi,
       count(*) filter (where score_global >= 85) as ge85,
       count(*) filter (where score_global >= 70) as ge70,
       count(*) filter (where score_global >= 60) as ge60
  from sim.eval;

-- Les mêmes, selon qu'un critère rédhibitoire bloque la paire (filtres_ok
-- faux) et que le moteur la juge montrable (affichable).
select filtres_ok, affichable, count(*) as paires, round(avg(score_global), 2) as moyenne,
       max(score_global) as maxi, count(*) filter (where score_global >= 70) as ge70
  from sim.eval group by 1, 2 order by 1, 2;

-- Sous-scores moyens, scores par sens, et étalon brut (part des critères
-- satisfaits, sans pondération).
select round(avg(score_physique), 1) as physique, round(avg(score_valeurs), 1) as valeurs,
       round(avg(score_mode_vie), 1) as mode_vie, round(avg(a_vers_b), 1) as aller,
       round(avg(b_vers_a), 1) as retour, max(a_vers_b) as max_aller,
       round(avg(brut) * 100, 1) as brut_pct, round(max(brut) * 100, 1) as brut_max
  from sim.eval;

-- Taille de la population et paramètres du moteur qui pèsent sur le score.
select count(distinct a) as observateurs, (select count(*) from profiles) as profils,
       (select count(*) from profile_answers) as reponses
  from sim.eval;
select key, value from engine_params
 where key in ('seuil_premium', 'min_criteres_affiches', 'plancher_directionnel',
               'poids_physique', 'poids_valeurs', 'poids_mode_vie')
 order by 1;
