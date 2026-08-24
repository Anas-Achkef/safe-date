-- Options v2 : integration des demandes formulees par le client dans la colonne
-- Commentaire de la grille de correspondance (source : grille_import_v1).

-- ---------- 1. Nouvelles options ----------

insert into criterion_options (criterion_key, idx, label) values
  -- animaux : deux positions manquantes cote "ce que je suis"
  ('animaux_moi', 5, 'Je déteste les animaux'),
  ('animaux_moi', 6, 'Je n''aime quasiment que les chiens/chats'),

  -- db_relation : ajout de l'amitie des deux cotes (demande explicite du client)
  ('db_relation_moi',  3, 'Amitié'),
  ('db_relation_rech', 3, 'Ouvert(e) à tout type de rencontre'),
  ('db_relation_rech', 4, 'Amitié'),

  -- mob_transp : le deux-roues motorise manquait
  ('mob_transp_moi', 4, 'Moto / vélomoteur'),

  -- psy_vision : la position mediane et l'indifference manquaient
  ('psy_vision_moi',  2, 'Réaliste'),
  ('psy_vision_rech', 2, 'Peu m''importe'),

  -- val_morale : la tolerance cote soi, l'independance cote recherche
  ('val_morale_moi',  6, 'Tolérance'),
  ('val_morale_rech', 6, 'L''indépendance'),

  -- vice_conso : separation tabac / alcool
  ('vice_conso_moi',  4, 'Ne bois jamais'),
  ('vice_conso_rech', 4, 'Fumée interdite'),

  -- val_etudes : refonte complete du cote "je recherche"
  ('val_etudes_rech', 2, 'Au minimum Bac +3'),
  ('val_etudes_rech', 3, 'Au minimum Bac +5'),
  ('val_etudes_rech', 4, 'Ayant un doctorat'),
  ('val_etudes_rech', 5, 'Un niveau supérieur au mien'),
  ('val_etudes_rech', 6, 'Un niveau inférieur au mien'),
  ('val_etudes_rech', 7, 'Un niveau identique au mien'),

  -- phys_taille / phys_poids : options relatives et indifference demandees
  ('phys_taille_rech', 10, 'Plus grand(e) que moi'),
  ('phys_taille_rech', 11, 'Plus petit(e) que moi'),
  ('phys_taille_rech', 12, 'Peu importe'),
  ('phys_poids_rech',  10, 'Peu importe');

-- ---------- 2. Reformulations d'options ----------

update criterion_options set label = 'Égal'                        where criterion_key='mob_transp_moi'  and idx=3;
update criterion_options set label = 'Véhiculé (moto/voiture)'     where criterion_key='mob_transp_rech' and idx=0;
update criterion_options set label = 'Justice'                     where criterion_key='val_morale_moi'  and idx=1;
update criterion_options set label = 'Respect'                     where criterion_key='val_morale_moi'  and idx=2;
update criterion_options set label = 'Ne fume jamais'              where criterion_key='vice_conso_moi'  and idx=3;
update criterion_options set label = 'Au moins le BAC'             where criterion_key='val_etudes_rech' and idx=0;
update criterion_options set label = 'Non, le diplôme ne compte pas' where criterion_key='val_etudes_rech' and idx=1;

update criterion_options set label = 'Non, on a tous des imperfections de peau'  where criterion_key='peau_acne_rech'   and idx=1;
update criterion_options set label = 'Les activités chill à la maison'          where criterion_key='loisir_amis_rech' and idx=0;
update criterion_options set label = 'Mon partenaire gère ses finances comme il/elle le souhaite' where criterion_key='fin_comport_rech' and idx=3;
update criterion_options set label = 'Discret, ne monopolise pas la parole'     where criterion_key='com_integ_rech'   and idx=1;
update criterion_options set label = 'À l''écoute'                              where criterion_key='com_integ_rech'   and idx=2;
update criterion_options set label = 'Fan des appels'                           where criterion_key='com_canal_rech'   and idx=1;
update criterion_options set label = 'Attendre que je revienne vers elle/lui'   where criterion_key='com_conflit_rech' and idx=2;
update criterion_options set label = 'Je ne recherche pas quelqu''un de créatif' where criterion_key='psy_creativ_rech' and idx=1;
update criterion_options set label = 'Très responsable'                         where criterion_key='psy_respons_rech' and idx=0;
update criterion_options set label = 'Dans un esprit enfantin, sans toujours penser davantage' where criterion_key='psy_respons_rech' and idx=1;
update criterion_options set label = 'Aimer les activités aquatiques'           where criterion_key='sport_eau_rech'   and idx=0;
update criterion_options set label = 'Je n''attends pas de faire des sports aquatiques avec mon/ma partenaire' where criterion_key='sport_eau_rech' and idx=1;
update criterion_options set label = 'Voyager écolo'                            where criterion_key='voyage_transp_rech' and idx=1;

-- ---------- 3. Reformulations de questions ----------

update criteria set question = 'Je recherche quelqu''un qui a un niveau de scolarité minimum :' where key='val_etudes_rech';
update criteria set question = 'Je cherche quelqu''un qui est proche de sa famille :'            where key='soc_famille_rech';
update criteria set question = 'Au niveau des émotions, je veux que mon/ma partenaire :'         where key='com_emot_rech';
update criteria set question = 'L''autre doit-il/elle avoir un engagement politique ?'           where key='val_politique_rech';
update criteria set question = 'Importance de la croyance en religion pour mon/ma partenaire :'  where key='val_religion_rech';

-- ---------- 4. vice_conso passe en choix multiple ----------
-- Le client scinde "Ne fume/bois jamais" en deux options distinctes. En choix
-- unique, une personne qui ne fume ni ne boit ne pourrait declarer qu'une seule
-- des deux et echouerait l'autre filtre. Le champ profile_answers.option_idx
-- etant deja un tableau, on bascule ce critere en multi-select.

update criteria set multi_select = true where key = 'vice_conso_moi';;
