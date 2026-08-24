-- Critères relatifs : certaines options "je recherche" n'expriment pas une valeur
-- absolue mais une comparaison avec la réponse de l'utilisateur lui-même
-- ("plus grand que moi", "un niveau d'études supérieur au mien").
-- On étend option_mappings plutôt que d'ajouter un match_type : une même paire
-- peut mélanger options absolues et options relatives.

create type relative_op as enum ('sup','sup_egal','inf','inf_egal','egal');

alter table option_mappings
  add column relative_op relative_op,
  add column relative_criterion_key text references criteria(key);

comment on column option_mappings.relative_op is
  'Si non nul, la correspondance est evaluee en comparant l''index self de la cible a celui du demandeur, au lieu d''utiliser accepted_self_idx. Suppose des options ordinales.';
comment on column option_mappings.relative_criterion_key is
  'Critere sur lequel porte la comparaison relative. Nul = le self_key de la paire elle-meme.';

alter table option_mappings
  add constraint option_mappings_cible_definie
  check (relative_op is not null or accepted_self_idx is not null) not valid;

alter table option_mappings validate constraint option_mappings_cible_definie;;
