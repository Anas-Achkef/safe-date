create or replace function apply_learning(
  p_user     uuid,
  p_target   uuid,
  p_accepted boolean,
  p_coef     numeric,
  p_groups   score_group[] default null
) returns void language plpgsql as $$
declare
  v_am     numeric := (select value from engine_params where key = 'apprentissage_accept_match');
  v_an     numeric := (select value from engine_params where key = 'apprentissage_accept_nomatch');
  v_rn     numeric := (select value from engine_params where key = 'apprentissage_refus_nomatch');
  v_rm     numeric := (select value from engine_params where key = 'apprentissage_refus_match');
  v_min    numeric := (select value from engine_params where key = 'apprentissage_mul_min');
  v_max    numeric := (select value from engine_params where key = 'apprentissage_mul_max');
  v_ampl   numeric := (select value from engine_params where key = 'apprentissage_amplitude');
  v_seuil  numeric := (select value from engine_params where key = 'seuil_declassement');
begin
  if p_user is null or p_target is null or p_coef is null or p_coef = 0 then
    return;
  end if;

  insert into user_criterion_learning (user_id, pair_key, confirmations, contradictions, observations)
  select p_user, e.pair_key,
         p_coef * case when p_accepted     and     e.matched then v_am
                       when not p_accepted and not e.matched then v_rn
                       else 0 end,
         p_coef * case when p_accepted     and not e.matched then v_an
                       when not p_accepted and     e.matched then v_rm
                       else 0 end,
         1
  from compat_explain(p_user, p_target) e
  where e.poids > 0
    and (p_groups is null or e.grp = any(p_groups))
  on conflict (user_id, pair_key) do update set
    confirmations  = user_criterion_learning.confirmations  + excluded.confirmations,
    contradictions = user_criterion_learning.contradictions + excluded.contradictions,
    observations   = user_criterion_learning.observations   + 1,
    updated_at     = now();

  update user_criterion_learning l
     set learned_mul = greatest(v_min, least(v_max,
           1 + (l.confirmations - l.contradictions) / nullif(v_seuil, 0) * v_ampl))
   where l.user_id = p_user;
end $$;

comment on function apply_learning is
  'Enregistre une decision utilisateur et reevalue le poids appris de chaque critere concerne. p_groups restreint l''apprentissage a certaines dimensions, ce qui permet d''exploiter les notes post-rendez-vous separement.';

-- ---------- Declencheur : swipe ----------

create or replace function trg_learning_swipe() returns trigger language plpgsql as $$
declare v_coef numeric;
begin
  v_coef := case when new.signal_fort
                 then (select value from engine_params where key = 'coef_rejet_fort')
                 else 1 end;
  perform apply_learning(new.user_id, new.target_id, new.decision, v_coef);
  return null;
end $$;

create trigger swipe_decisions_apprentissage
  after insert on swipe_decisions
  for each row execute function trg_learning_swipe();

-- ---------- Declencheur : decision de fin de conversation ----------

create or replace function trg_learning_conversation() returns trigger language plpgsql as $$
declare
  v_autre uuid;
  v_coef  numeric := (select value from engine_params where key = 'coef_conversation');
begin
  if new.decision = 'plus_tard' then
    return null;
  end if;

  select case when c.user_a = new.user_id then c.user_b else c.user_a end
    into v_autre
  from conversations c where c.id = new.conversation_id;

  perform apply_learning(new.user_id, v_autre, new.decision = 'oui', v_coef);
  return null;
end $$;

create trigger conversation_decisions_apprentissage
  after insert on conversation_decisions
  for each row execute function trg_learning_conversation();

-- ---------- Declencheur : evaluation post-rendez-vous ----------
-- Les trois notes de date_reviews correspondent exactement aux trois
-- groupes de score. Chaque note est donc exploitee separement, ce qui
-- permet d'apprendre quelle dimension a reellement fonctionne.

create or replace function trg_learning_date_review() returns trigger language plpgsql as $$
declare
  v_autre uuid;
  v_coef  numeric := (select value from engine_params where key = 'coef_feedback_date');
begin
  select case when d.user_a = new.user_id then d.user_b else d.user_a end
    into v_autre
  from dates d where d.id = new.date_id;

  if v_autre is null then return null; end if;

  if new.attirance is not null and new.attirance <> 3 then
    perform apply_learning(new.user_id, v_autre, new.attirance >= 4, v_coef, array['physique']::score_group[]);
  end if;
  if new.valeurs is not null and new.valeurs <> 3 then
    perform apply_learning(new.user_id, v_autre, new.valeurs >= 4, v_coef, array['valeurs']::score_group[]);
  end if;
  if new.mode_vie is not null and new.mode_vie <> 3 then
    perform apply_learning(new.user_id, v_autre, new.mode_vie >= 4, v_coef, array['mode_vie']::score_group[]);
  end if;
  return null;
end $$;

create trigger date_reviews_apprentissage
  after insert on date_reviews
  for each row execute function trg_learning_date_review();;
