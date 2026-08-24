-- ============================================================
-- Moteur de compatibilite — fonctions de calcul
-- ============================================================

-- ---------- Reconstruction du vecteur de profil ----------

create or replace function rebuild_profile_vector(p_user uuid)
returns void language plpgsql as $$
begin
  with per_slot as (
    select cp.slot,
           coalesce((select bit_or(1 << x::int)
                     from profile_answers pa, unnest(pa.option_idx) as x
                     where pa.user_id = p_user and pa.criterion_key = cp.self_key), 0) as smask,
           coalesce((select bit_or(1 << x::int)
                     from profile_answers pa, unnest(pa.option_idx) as x
                     where pa.user_id = p_user and pa.criterion_key = cp.pref_key), 0) as pmask,
           cp.pair_key
    from criterion_pairs cp
  ),
  wm as (
    select ps.slot,
           coalesce((select max(m.weight_multiplier)
                     from option_mappings m
                     where m.pair_key = ps.pair_key
                       and ((ps.pmask >> m.pref_idx) & 1) = 1), 1.0) as w
    from per_slot ps
  )
  insert into profile_vectors (user_id, self_mask, pref_mask, weight_mul,
                               answered_self, answered_pref, refreshed_at)
  select p_user,
         (select array_agg(smask order by slot) from per_slot),
         (select array_agg(pmask order by slot) from per_slot),
         (select array_agg(w     order by slot) from wm),
         (select count(*) from per_slot where smask <> 0),
         (select count(*) from per_slot where pmask <> 0),
         now()
  on conflict (user_id) do update set
    self_mask     = excluded.self_mask,
    pref_mask     = excluded.pref_mask,
    weight_mul    = excluded.weight_mul,
    answered_self = excluded.answered_self,
    answered_pref = excluded.answered_pref,
    refreshed_at  = now();
end $$;

comment on function rebuild_profile_vector is 'Reconstruit le cache denormalise des reponses d''un utilisateur. A rejouer apres toute modification de profil ou du referentiel.';

-- ---------- Score directionnel ----------

create or replace function compat_directional(p_a uuid, p_b uuid)
returns table (score numeric, evaluated integer, blocked boolean)
language plpgsql stable as $$
declare
  v_coef_max  numeric := (select value from engine_params where key = 'priorite_coef_max');
  v_min_crit  numeric := (select value from engine_params where key = 'min_criteres_affiches');
  v_plancher  numeric := (select value from engine_params where key = 'plancher_directionnel');
  v_p_phys    numeric := (select value from engine_params where key = 'poids_physique');
  v_p_val     numeric := (select value from engine_params where key = 'poids_valeurs');
  v_p_mdv     numeric := (select value from engine_params where key = 'poids_mode_vie');
  v_num       numeric := 0;
  v_den       numeric := 0;
  v_eval      integer := 0;
  v_blocked   boolean := false;
begin
  create temporary table if not exists _det (
    pair_key text, grp score_group, is_absolute boolean, matched boolean, w numeric
  ) on commit drop;
  delete from _det;

  insert into _det
  select b.pair_key, b.grp, b.is_absolute,
         bool_or(
           case
             when m.relative_op is null       then (m.accepted_mask & b.b_self) <> 0
             when m.relative_op = 'sup'       then mask_top_idx(b.b_self) >  mask_top_idx(b.a_self)
             when m.relative_op = 'sup_egal'  then mask_top_idx(b.b_self) >= mask_top_idx(b.a_self)
             when m.relative_op = 'inf'       then mask_top_idx(b.b_self) <  mask_top_idx(b.a_self)
             when m.relative_op = 'inf_egal'  then mask_top_idx(b.b_self) <= mask_top_idx(b.a_self)
             when m.relative_op = 'egal'      then mask_top_idx(b.b_self) =  mask_top_idx(b.a_self)
           end),
         max(b.base_weight * m.weight_multiplier
             * (1 + (v_coef_max - 1)
                  * greatest(0, (21 - coalesce(pr.rang, 999))::numeric / 20)))
  from (
    select cp.pair_key, cp.grp, cp.is_absolute, cp.base_weight,
           va.pref_mask[cp.slot + 1] as a_pref,
           va.self_mask[cp.slot + 1] as a_self,
           vb.self_mask[cp.slot + 1] as b_self
    from criterion_pairs cp
    cross join (select * from profile_vectors where user_id = p_a) va
    cross join (select * from profile_vectors where user_id = p_b) vb
    where va.pref_mask[cp.slot + 1] <> 0
      and vb.self_mask[cp.slot + 1] <> 0
  ) b
  join option_mappings m
    on m.pair_key = b.pair_key and ((b.a_pref >> m.pref_idx) & 1) = 1
  left join user_criterion_priorities pr
    on pr.user_id = p_a and pr.pair_key = b.pair_key
  group by b.pair_key, b.grp, b.is_absolute;

  select count(*), coalesce(bool_or(d.is_absolute and not d.matched and d.w > 0), false)
    into v_eval, v_blocked
  from _det d;

  -- Moyenne ponderee des sous-scores, renormalisee sur les seuls
  -- groupes reellement evalues.
  select coalesce(sum(g.poids * g.obtenu / g.possible), 0),
         coalesce(sum(g.poids), 0)
    into v_num, v_den
  from (
    select case d.grp when 'physique' then v_p_phys
                      when 'valeurs'  then v_p_val
                      else v_p_mdv end as poids,
           sum(d.w) filter (where d.matched) as obtenu,
           sum(d.w) as possible
    from _det d
    where d.w > 0
    group by d.grp
  ) g
  where g.possible > 0;

  return query select
    case
      when v_blocked                     then 0::numeric
      when v_eval < v_min_crit           then null::numeric
      when v_den = 0                     then null::numeric
      else greatest(round(100 * v_num / v_den, 2), v_plancher)
    end,
    v_eval,
    v_blocked;
end $$;

comment on function compat_directional is 'Compatibilite de p_a envers p_b. Renvoie null si moins de min_criteres_affiches criteres ont pu etre evalues, 0 si un filtre absolu echoue.';

-- ---------- Compatibilite mutuelle ----------

create or replace function compat_mutual(p_a uuid, p_b uuid)
returns table (taux numeric, score_ab numeric, score_ba numeric,
               evalues_ab integer, evalues_ba integer, exclu boolean)
language plpgsql stable as $$
declare
  v_pmin numeric := (select value from engine_params where key = 'mutuel_poids_min');
  ab record;
  ba record;
begin
  select * into ab from compat_directional(p_a, p_b);
  select * into ba from compat_directional(p_b, p_a);

  return query select
    case
      when ab.blocked or ba.blocked            then 0::numeric
      when ab.score is null or ba.score is null then null::numeric
      else round(v_pmin * least(ab.score, ba.score)
               + (1 - v_pmin) * greatest(ab.score, ba.score), 2)
    end,
    ab.score, ba.score, ab.evaluated, ba.evaluated,
    (ab.blocked or ba.blocked);
end $$;

comment on function compat_mutual is 'Taux affiche dans l''application. Volontairement asymetrique : le score le plus faible pese davantage, pour eviter de mettre en avant une compatibilite a sens unique.';;
