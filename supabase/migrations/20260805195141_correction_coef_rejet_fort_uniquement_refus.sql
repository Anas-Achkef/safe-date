-- coef_rejet_fort est defini comme "poids d'un rejet depuis l'onglet
-- Compatibles". Il ne doit donc s'appliquer qu'aux refus, pas aux
-- acceptations, sous peine de saturer l'apprentissage en une dizaine
-- de swipes.

create or replace function trg_learning_swipe() returns trigger language plpgsql as $$
declare v_coef numeric;
begin
  v_coef := case when new.signal_fort and not new.decision
                 then (select value from engine_params where key = 'coef_rejet_fort')
                 else 1 end;
  perform apply_learning(new.user_id, new.target_id, new.decision, v_coef);
  return null;
end $$;;
