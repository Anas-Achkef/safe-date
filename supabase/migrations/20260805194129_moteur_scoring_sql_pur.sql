create or replace function compat_directional(p_a uuid, p_b uuid)
returns table (score numeric, evaluated integer, blocked boolean)
language sql stable as $$
with prm as (
  select max(value) filter (where key = 'priorite_coef_max')     as coef_max,
         max(value) filter (where key = 'min_criteres_affiches') as min_crit,
         max(value) filter (where key = 'plancher_directionnel') as plancher,
         max(value) filter (where key = 'poids_physique')        as p_phys,
         max(value) filter (where key = 'poids_valeurs')         as p_val,
         max(value) filter (where key = 'poids_mode_vie')        as p_mdv
  from engine_params
),
base as (
  select cp.pair_key, cp.grp, cp.is_absolute, cp.base_weight,
         va.pref_mask[cp.slot + 1] as a_pref,
         va.self_mask[cp.slot + 1] as a_self,
         vb.self_mask[cp.slot + 1] as b_self
  from criterion_pairs cp
  cross join (select * from profile_vectors where user_id = p_a) va
  cross join (select * from profile_vectors where user_id = p_b) vb
  where va.pref_mask[cp.slot + 1] <> 0
    and vb.self_mask[cp.slot + 1] <> 0
),
det as (
  select b.pair_key, b.grp, b.is_absolute,
         bool_or(
           case
             when m.relative_op is null      then (m.accepted_mask & b.b_self) <> 0
             when m.relative_op = 'sup'      then mask_top_idx(b.b_self) >  mask_top_idx(b.a_self)
             when m.relative_op = 'sup_egal' then mask_top_idx(b.b_self) >= mask_top_idx(b.a_self)
             when m.relative_op = 'inf'      then mask_top_idx(b.b_self) <  mask_top_idx(b.a_self)
             when m.relative_op = 'inf_egal' then mask_top_idx(b.b_self) <= mask_top_idx(b.a_self)
             when m.relative_op = 'egal'     then mask_top_idx(b.b_self) =  mask_top_idx(b.a_self)
           end) as matched,
         max(b.base_weight * m.weight_multiplier
             * (1 + (prm.coef_max - 1)
                  * greatest(0, (21 - coalesce(pr.rang, 999))::numeric / 20))) as w
  from base b
  cross join prm
  join option_mappings m
    on m.pair_key = b.pair_key and ((b.a_pref >> m.pref_idx) & 1) = 1
  left join user_criterion_priorities pr
    on pr.user_id = p_a and pr.pair_key = b.pair_key
  group by b.pair_key, b.grp, b.is_absolute
),
grp as (
  select d.grp as g,
         coalesce(sum(d.w) filter (where d.matched), 0) as obtenu,
         sum(d.w) as possible
  from det d
  where d.w > 0
  group by d.grp
),
agg as (
  select coalesce(sum(x.poids * x.obtenu / x.possible), 0) as num,
         coalesce(sum(x.poids), 0)                         as den
  from (
    select case g.g when 'physique' then prm.p_phys
                    when 'valeurs'  then prm.p_val
                    else prm.p_mdv end as poids,
           g.obtenu, g.possible
    from grp g cross join prm
    where g.possible > 0
  ) x
),
tot as (
  select count(*)::integer as evalues,
         coalesce(bool_or(is_absolute and not matched and w > 0), false) as bloque
  from det
)
select
  case
    when tot.bloque                  then 0::numeric
    when tot.evalues < prm.min_crit  then null::numeric
    when agg.den = 0                 then null::numeric
    else greatest(round(100 * agg.num / agg.den, 2), prm.plancher)
  end,
  tot.evalues,
  tot.bloque
from tot cross join agg cross join prm;
$$;

comment on function compat_directional is 'Compatibilite de p_a envers p_b. Renvoie null si moins de min_criteres_affiches criteres ont pu etre evalues, 0 si un filtre absolu echoue.';;
