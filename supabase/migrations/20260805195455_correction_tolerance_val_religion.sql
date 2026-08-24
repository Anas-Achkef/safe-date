-- val_religion est de type 'echelle' : la question posee est une IMPORTANCE
-- ("importance que l'autre ait la meme croyance"), pas un niveau attendu.
-- Le moteur compare donc le niveau de l'autre au sien, avec une tolerance
-- decroissante a mesure que l'exigence augmente.
--   1 (m'en fiche) -> tolerance 4 : tout est accepte
--   5 (obligatoire) -> tolerance 0 : meme niveau exactement
--
-- A FAIRE CONFIRMER PAR LE CLIENT : sa grille mappait ces options vers des
-- niveaux absolus (option 5 -> l'autre doit etre au niveau 5), ce qui
-- contredit la formulation de sa propre question. La tolerance ci-dessous
-- suit la conception du schema ; si Thomas voulait bien un niveau absolu,
-- c'est le match_type de la paire qu'il faut changer, pas la tolerance.

update option_mappings set tolerance = 4 where pair_key = 'val_religion' and pref_idx = 0;
update option_mappings set tolerance = 3 where pair_key = 'val_religion' and pref_idx = 1;
update option_mappings set tolerance = 2 where pair_key = 'val_religion' and pref_idx = 2;
update option_mappings set tolerance = 1 where pair_key = 'val_religion' and pref_idx = 3;
update option_mappings set tolerance = 0 where pair_key = 'val_religion' and pref_idx = 4;

select private.refresh_profile_vectors(id) from profiles;;
