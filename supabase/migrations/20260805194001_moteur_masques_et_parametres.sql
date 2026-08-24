-- ============================================================
-- Moteur de compatibilite — preparation
-- Les vecteurs de profil encodent les reponses sous forme de
-- masques binaires indexes par slot de paire. On precalcule le
-- masque des options acceptees pour pouvoir comparer par ET binaire.
-- ============================================================

create or replace function om_accepted_mask(a smallint[])
returns integer language sql immutable as
$$ select coalesce((select bit_or(1 << x::int) from unnest(a) as x), 0) $$;

create or replace function mask_top_idx(m integer)
returns smallint language sql immutable as
$$ select case when m is null or m = 0 then null
                else (length(to_bin(m)) - 1)::smallint end $$;
comment on function mask_top_idx is 'Index de l''option depuis son masque. Exact pour les criteres a choix unique, renvoie le rang le plus eleve en choix multiple.';

alter table option_mappings add column accepted_mask integer not null default 0;
update option_mappings set accepted_mask = om_accepted_mask(accepted_self_idx);

create or replace function trg_option_mappings_mask() returns trigger language plpgsql as
$$ begin
     new.accepted_mask := om_accepted_mask(new.accepted_self_idx);
     return new;
   end $$;

create trigger option_mappings_maj_masque
  before insert or update of accepted_self_idx on option_mappings
  for each row execute function trg_option_mappings_mask();

-- ---------- Parametres complementaires ----------

insert into engine_params (key, value, description) values
  ('mutuel_poids_min',            0.65, 'Part du score directionnel le plus faible dans le taux de compatibilite mutuelle'),
  ('distance_evaluation_m',        350, 'Eloignement minimal entre les deux utilisateurs avant d''afficher les evaluations'),
  ('conversation_duree_s',         300, 'Duree de la conversation chronometree, en secondes'),
  ('demande_expiration_s',        1800, 'Delai de reponse a une demande de discussion, en secondes'),
  ('discussions_gratuit_par_jour',   3, 'Nouvelles discussions quotidiennes en version gratuite')
on conflict (key) do nothing;;
