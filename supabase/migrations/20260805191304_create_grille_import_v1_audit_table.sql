drop table if exists grille_import_v1;
create table grille_import_v1 (
  src_row      int primary key,
  pair_key     text,
  pref_idx     smallint,
  pref_label   text,
  accepted     smallint[],
  poids        numeric,
  commentaire  text
);
comment on table grille_import_v1 is 'Grille de correspondance remplie par le client (Thomas GASPOZ), retournee le 29/07/2026. Table de reference/audit : ne pas modifier, sert de trace contractuelle pour la recette du jalon M2. Source : Grille_de_correspondance.xlsx onglet Correspondances.';
alter table grille_import_v1 enable row level security;;
