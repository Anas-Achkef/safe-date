-- ============================================================
-- Garde-fou anti-derive
-- Une decision n'apprend quelque chose que si elle aurait pu etre
-- differente. Un utilisateur qui accepte tout ne nous dit rien en
-- acceptant, et un utilisateur qui refuse tout ne nous dit rien en
-- refusant. On pondere donc l'apprentissage par l'entropie binaire
-- de ses decisions : maximale a 50/50, nulle a l'unanimite.
-- ============================================================

insert into engine_params (key, value, description) values
  ('apprentissage_fiabilite_min', 0.15, 'Plancher de fiabilite : meme un comportement totalement uniforme continue d''apprendre, six fois plus lentement'),
  ('apprentissage_derive_alerte', 0.60, 'Part de criteres au plancher au-dela de laquelle un profil est signale comme derivant')
on conflict (key) do nothing;

create or replace function private.learning_reliability(u uuid)
returns numeric language sql stable as
$fn$
  with d as (
    select count(*) filter (where decision)::numeric as oui,
           count(*)::numeric                         as tot
    from swipe_decisions where user_id = u
  ),
  p as (select case when tot = 0 then null else oui / tot end as p, tot from d)
  select case
           when p.p is null or p.tot < 3 then 1.0
           when p.p <= 0 or p.p >= 1     then private.engine_param('apprentissage_fiabilite_min')
           else greatest(
                  private.engine_param('apprentissage_fiabilite_min'),
                  round((-(p.p * log(2, p.p) + (1 - p.p) * log(2, 1 - p.p)))::numeric, 4))
         end
  from p;
$fn$;

comment on function private.learning_reliability is
  'Entropie binaire des decisions de swipe de l''utilisateur, bornee par un plancher. Vaut 1 pour un comportement equilibre, tombe au plancher pour un comportement unanime. En dessous de trois decisions, on ne penalise pas : il n''y a simplement rien a mesurer.';

-- ---------- Integration dans l'apprentissage ----------

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
  v_fiab  numeric;
  v_eff   numeric;
  v_bouge boolean := false;
begin
  if u is null or cible is null or coef is null or coef = 0 then
    return;
  end if;

  -- Une decision ne pese qu'a hauteur de ce qu'elle revele.
  v_fiab := private.learning_reliability(u);
  v_eff  := coef * v_fiab;

  -- Les paires eliminatoires ne s'apprennent pas.
  insert into user_criterion_learning (user_id, pair_key, confirmations, contradictions, observations)
  select u, e.pair_key,
         v_eff * case when     accepte and     e.m then v_am
                      when not accepte and not e.m then v_rn
                      else 0 end,
         v_eff * case when     accepte and not e.m then v_an
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

-- ---------- Supervision ----------

create or replace view private.v_apprentissage_derive as
  select l.user_id,
         count(*)                                              as criteres_appris,
         count(*) filter (where l.learned_mul <= private.engine_param('apprentissage_mul_min')) as au_plancher,
         round(count(*) filter (where l.learned_mul <= private.engine_param('apprentissage_mul_min'))::numeric
               / nullif(count(*), 0), 3)                       as part_plancher,
         round(private.learning_reliability(l.user_id), 3)     as fiabilite,
         max(l.observations)                                   as observations
  from user_criterion_learning l
  group by l.user_id
  having count(*) filter (where l.learned_mul <= private.engine_param('apprentissage_mul_min'))::numeric
         / nullif(count(*), 0) >= private.engine_param('apprentissage_derive_alerte');

comment on view private.v_apprentissage_derive is
  'Profils dont une part anormale de criteres est tombee au plancher. Signale un comportement indifferencie plutot qu''une preference reelle : a inspecter avant d''accorder du credit a leur profil appris.';

-- ---------- Rafraichissement de l'entropie ----------

create or replace function private.refresh_criterion_stats()
returns void language plpgsql security definer set search_path to 'public','pg_temp' as
$fn$
begin
  refresh materialized view private.criterion_stats;
end $fn$;

comment on function private.refresh_criterion_stats is
  'A planifier (quotidien suffit). Tant que la vue n''est pas rafraichie sur un volume reel, criterion_stats.entropie reste uniforme et les tris par entropie de next_questions, derive_priorities et candidate_highlights sont inertes.';;
