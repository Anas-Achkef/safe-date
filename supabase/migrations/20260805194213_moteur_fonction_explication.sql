-- Detail critere par critere d'une evaluation directionnelle.
-- Sert au debogage, a la recette du jalon M2 et alimentera les
-- questions Focus Compatibilite (comprendre ce qui a fait echouer
-- ou reussir une recommandation).

create or replace function compat_explain(p_a uuid, p_b uuid)
returns table (
  pair_key    text,
  grp         score_group,
  is_absolute boolean,
  matched     boolean,
  poids       numeric,
  rang_prio   smallint
)
language sql stable as $$
with prm as (
  select max(value) filter (where key = 'priorite_coef_max') as coef_max
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
)
select b.pair_key, b.grp, b.is_absolute,
       bool_or(
         case
           when m.relative_op is null      then (m.accepted_mask & b.b_self) <> 0
           when m.relative_op = 'sup'      then mask_top_idx(b.b_self) >  mask_top_idx(b.a_self)
           when m.relative_op = 'sup_egal' then mask_top_idx(b.b_self) >= mask_top_idx(b.a_self)
           when m.relative_op = 'inf'      then mask_top_idx(b.b_self) <  mask_top_idx(b.a_self)
           when m.relative_op = 'inf_egal' then mask_top_idx(b.b_self) <= mask_top_idx(b.a_self)
           when m.relative_op = 'egal'     then mask_top_idx(b.b_self) =  mask_top_idx(b.a_self)
         end),
       max(b.base_weight * m.weight_multiplier
           * (1 + (prm.coef_max - 1)
                * greatest(0, (21 - coalesce(pr.rang, 999))::numeric / 20))),
       max(pr.rang)
from base b
cross join prm
join option_mappings m
  on m.pair_key = b.pair_key and ((b.a_pref >> m.pref_idx) & 1) = 1
left join user_criterion_priorities pr
  on pr.user_id = p_a and pr.pair_key = b.pair_key
group by b.pair_key, b.grp, b.is_absolute;
$$;

comment on function compat_explain is 'Detail critere par critere de la compatibilite de p_a envers p_b : correspondance, poids effectif et rang de priorite.';;
