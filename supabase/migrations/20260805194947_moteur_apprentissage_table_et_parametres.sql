-- ============================================================
-- Boucle d'apprentissage — le moteur ajuste, utilisateur par
-- utilisateur, le poids reel de chaque critere en observant
-- l'ecart entre ce qui est declare et ce qui est decide.
-- ============================================================

create table user_criterion_learning (
  user_id        uuid not null references profiles(id) on delete cascade,
  pair_key       text not null references criterion_pairs(pair_key) on delete cascade,
  confirmations  numeric not null default 0,
  contradictions numeric not null default 0,
  learned_mul    numeric not null default 1.0,
  observations   integer not null default 0,
  updated_at     timestamptz not null default now(),
  primary key (user_id, pair_key)
);

comment on table user_criterion_learning is
  'Poids appris par utilisateur et par critere. Un critere systematiquement contredit par les decisions reelles est progressivement declasse, sans jamais etre annule.';
comment on column user_criterion_learning.learned_mul is
  'Multiplicateur applique au poids du critere, borne entre apprentissage_mul_min et apprentissage_mul_max.';

alter table user_criterion_learning enable row level security;
create policy p_learning_self on user_criterion_learning for select
  using (user_id = auth.uid());

-- ---------- Ponderation des signaux ----------
-- Les quatre situations n'ont pas la meme valeur informative.
-- Accepter un profil malgre un critere non satisfait est le signal
-- le plus fort : le critere declare n'est pas une vraie exigence.
-- Refuser un profil qui satisfaisait le critere ne dit presque rien,
-- le refus venant probablement d'ailleurs.

insert into engine_params (key, value, description) values
  ('apprentissage_accept_match',    0.25, 'Poids d''une acceptation sur un critere satisfait (confirmation faible)'),
  ('apprentissage_accept_nomatch',  1.00, 'Poids d''une acceptation malgre un critere non satisfait (contradiction forte)'),
  ('apprentissage_refus_nomatch',   1.00, 'Poids d''un refus sur un critere non satisfait (confirmation forte)'),
  ('apprentissage_refus_match',     0.10, 'Poids d''un refus malgre un critere satisfait (signal tres faible)'),
  ('apprentissage_mul_min',         0.25, 'Multiplicateur appris minimal'),
  ('apprentissage_mul_max',         1.75, 'Multiplicateur appris maximal'),
  ('apprentissage_amplitude',       0.75, 'Amplitude de l''ajustement atteinte a seuil_declassement contradictions nettes'),
  ('coef_conversation',             2.00, 'Poids d''une decision prise a l''issue d''une conversation')
on conflict (key) do nothing;;
