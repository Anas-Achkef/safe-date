-- ============================================================
-- Boucle d'apprentissage : le moteur observe l'ecart entre les
-- criteres declares et les decisions reellement prises, et ajuste
-- le poids de chaque critere pour l'utilisateur concerne.
-- ============================================================

create or replace function private.apply_learning(
  u        uuid,
  cible    uuid,
  accepte  boolean,
  coef     numeric,
  groupes  score_group[] default null
) returns void language plpgsql as
$fn$
declare
  v_am    numeric := private.engine_param('apprentissage_accept_match');
  v_an    numeric := private.engine_param('apprentissage_accept_nomatch');
  v_rn    numeric := private.engine_param('apprentissage_refus_nomatch');
  v_rm    numeric := private.engine_param('apprentissage_refus_match');
  v_min   numeric := private.engine_param('apprentissage_mul_min');
  v_max   numeric := private.engine_param('apprentissage_mul_max');
  v_ampl  numeric := private.engine_param('apprentissage_amplitude');
  v_seuil numeric := private.engine_param('seuil_declassement');
  v_delta numeric := private.engine_param('apprentissage_seuil_refresh');
  v_bouge boolean := false;
begin
  if u is null or cible is null or coef is null or coef = 0 then
    return;
  end if;

  -- Les paires eliminatoires ne s'apprennent pas : un dealbreaker reste
  -- un dealbreaker, quelles que soient les decisions observees.
  insert into user_criterion_learning (user_id, pair_key, confirmations, contradictions, observations)
  select u, e.pair_key,
         coef * case when     accepte and     e.m then v_am
                     when not accepte and not e.m then v_rn
                     else 0 end,
         coef * case when     accepte and not e.m then v_an
                     when not accepte and     e.m then v_rm
                     else 0 end,
         1
  from (
    select p.pair_key, p.grp,
           (vb.self_mask[p.slot+1] & va.pref_mask[p.slot+1]) <> 0 as m
    from criterion_pairs p
    cross join (select * from profile_vectors where user_id = u)     va
    cross join (select * from profile_vectors where user_id = cible) vb
    where not p.is_absolute
      and va.pref_mask[p.slot+1] is not null
      and vb.self_mask[p.slot+1] is not null
      and va.weight_mul[p.slot+1] > 0
  ) e
  where groupes is null or e.grp = any(groupes)
  on conflict (user_id, pair_key) do update set
    confirmations  = user_criterion_learning.confirmations  + excluded.confirmations,
    contradictions = user_criterion_learning.contradictions + excluded.contradictions,
    observations   = user_criterion_learning.observations   + 1,
    updated_at     = now();

  -- Le poids appris ne bouge que par petits pas. On ne reconstruit les
  -- vecteurs que si au moins un critere a suffisamment varie : sans cela,
  -- chaque swipe declencherait un rebalayage complet des 133 paires.
  select bool_or(abs(x.nouveau - x.learned_mul) >= v_delta) into v_bouge
  from (
    select l.learned_mul,
           greatest(v_min, least(v_max,
             1 + (l.confirmations - l.contradictions) / nullif(v_seuil, 0) * v_ampl)) as nouveau
    from user_criterion_learning l where l.user_id = u
  ) x;

  update user_criterion_learning l
     set learned_mul = greatest(v_min, least(v_max,
           1 + (l.confirmations - l.contradictions) / nullif(v_seuil, 0) * v_ampl))
   where l.user_id = u;

  if coalesce(v_bouge, false) then
    perform private.refresh_profile_vectors(u);
  end if;
end $fn$;

comment on function private.apply_learning is
  'Enregistre une decision et reevalue le poids appris des criteres concernes. Accepter malgre un critere non satisfait est le signal le plus fort ; refuser un profil qui satisfaisait le critere ne dit presque rien. groupes restreint l''apprentissage a certaines dimensions, ce qui permet d''exploiter separement les trois notes post-rendez-vous.';

-- ---------- Signal 1 : swipe ----------

create or replace function trg_learning_swipe() returns trigger
language plpgsql security definer set search_path to 'public','pg_temp' as
$fn$
declare v_coef numeric;
begin
  v_coef := case when new.signal_fort and not new.decision
                 then private.engine_param('coef_rejet_fort')
                 else 1 end;
  perform private.apply_learning(new.user_id, new.target_id, new.decision, v_coef);
  return null;
end $fn$;

create trigger swipe_decisions_apprentissage
  after insert on swipe_decisions
  for each row execute function trg_learning_swipe();

-- ---------- Signal 2 : decision de fin de conversation ----------

create or replace function trg_learning_conversation() returns trigger
language plpgsql security definer set search_path to 'public','pg_temp' as
$fn$
declare v_autre uuid;
begin
  if new.decision = 'plus_tard' then return null; end if;
  select case when c.user_a = new.user_id then c.user_b else c.user_a end
    into v_autre from conversations c where c.id = new.conversation_id;
  perform private.apply_learning(new.user_id, v_autre, new.decision = 'oui',
                                 private.engine_param('coef_conversation'));
  return null;
end $fn$;

create trigger conversation_decisions_apprentissage
  after insert on conversation_decisions
  for each row execute function trg_learning_conversation();

-- ---------- Signal 3 : evaluation post-rendez-vous ----------
-- Les trois notes correspondent exactement aux trois groupes de score :
-- chacune est donc exploitee sur sa seule dimension. La note 3 est
-- neutre et n'apprend rien.

create or replace function trg_learning_date_review() returns trigger
language plpgsql security definer set search_path to 'public','pg_temp' as
$fn$
declare v_autre uuid; v_coef numeric := private.engine_param('coef_feedback_date');
begin
  select case when d.user_a = new.user_id then d.user_b else d.user_a end
    into v_autre from dates d where d.id = new.date_id;
  if v_autre is null then return null; end if;

  if new.attirance is not null and new.attirance <> 3 then
    perform private.apply_learning(new.user_id, v_autre, new.attirance >= 4, v_coef, array['physique']::score_group[]);
  end if;
  if new.valeurs is not null and new.valeurs <> 3 then
    perform private.apply_learning(new.user_id, v_autre, new.valeurs >= 4, v_coef, array['valeurs']::score_group[]);
  end if;
  if new.mode_vie is not null and new.mode_vie <> 3 then
    perform private.apply_learning(new.user_id, v_autre, new.mode_vie >= 4, v_coef, array['mode_vie']::score_group[]);
  end if;
  return null;
end $fn$;

create trigger date_reviews_apprentissage
  after insert on date_reviews
  for each row execute function trg_learning_date_review();

-- ---------- Lecture par l'utilisateur ----------
-- Repond a la fonctionnalite Premium "telecharger une analyse de mes
-- preferences" : ce que le moteur a compris des decisions reelles.

create or replace function private.learning_profile(u uuid)
returns table (pair_key text, grp score_group, question text,
               learned_mul numeric, observations integer, tendance text)
language sql stable as
$fn$
  select l.pair_key, p.grp, c.question, l.learned_mul, l.observations,
         case when l.learned_mul >= 1.20 then 'compte plus que declare'
              when l.learned_mul <= 0.80 then 'compte moins que declare'
              else 'conforme au declare' end
  from user_criterion_learning l
  join criterion_pairs p on p.pair_key = l.pair_key
  join criteria c on c.key = p.pref_key
  where l.user_id = u
  order by abs(l.learned_mul - 1) desc, l.observations desc;
$fn$;

create or replace function public.learning_profile()
returns table (pair_key text, grp score_group, question text,
               learned_mul numeric, observations integer, tendance text)
language plpgsql stable security definer set search_path to 'public','pg_temp' as
$fn$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.learning_profile(auth.uid());
end $fn$;;
