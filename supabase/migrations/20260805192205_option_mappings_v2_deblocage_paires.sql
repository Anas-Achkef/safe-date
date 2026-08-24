-- Chargement des 24 lignes de la grille restees bloquees, desormais possibles
-- puisque les options manquantes existent.

insert into option_mappings (pair_key, pref_idx, accepted_self_idx, weight_multiplier) values
  ('animaux',0,'{0,1,4,6}',1.0),('animaux',1,'{2,3,5}',2.0),('animaux',2,'{6}',1.0),('animaux',3,'{0,1,2,3,4,5,6}',1.0),
  ('db_regime',1,'{0,1,2}',0.0),
  ('db_relation',3,'{0,1,2,3}',0.0),('db_relation',4,'{3}',2.0),
  ('mob_transp',0,'{1,4}',1.0),('mob_transp',2,'{0,1,2,3,4}',0.0),
  ('psy_rigueur',0,'{0}',1.0),('psy_rigueur',1,'{1}',1.0),
  ('psy_vision',1,'{2}',1.0),('psy_vision',2,'{0,1,2}',0.0),
  ('val_morale',3,'{6}',1.0),('val_morale',6,'{3}',1.0),
  ('vice_conso',3,'{4}',2.0),('vice_conso',4,'{3}',2.0),
  ('val_etudes',1,'{0,1,2,3,4,5}',0.0),('val_etudes',2,'{3,4,5}',1.0),('val_etudes',3,'{4,5}',1.0),('val_etudes',4,'{5}',1.0),
  ('phys_taille',12,'{0,1,2,3,4,5,6,7,8,9}',0.0),
  ('phys_poids',10,'{0,1,2,3,4,5,6,7,8,9}',0.0)
on conflict (pair_key,pref_idx) do update
  set accepted_self_idx = excluded.accepted_self_idx,
      weight_multiplier = excluded.weight_multiplier;

-- Options relatives : la correspondance depend de la reponse du demandeur.
insert into option_mappings (pair_key, pref_idx, accepted_self_idx, weight_multiplier, relative_op) values
  ('phys_taille',10,'{}',1.0,'sup'),
  ('phys_taille',11,'{}',1.0,'inf'),
  ('val_etudes',5,'{}',1.0,'sup'),
  ('val_etudes',6,'{}',1.0,'inf'),
  ('val_etudes',7,'{}',1.0,'egal')
on conflict (pair_key,pref_idx) do update
  set accepted_self_idx = excluded.accepted_self_idx,
      weight_multiplier = excluded.weight_multiplier,
      relative_op       = excluded.relative_op;

update criterion_pairs set mapping_validated = true
where pair_key in ('animaux','db_regime','db_relation','mob_transp','psy_rigueur',
                   'psy_vision','val_morale','vice_conso','val_etudes',
                   'val_religion','val_politique');;
