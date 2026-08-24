-- Les critères mis en avant étaient ordonnés par numéro de ligne du
-- fichier client, ce qui remontait le physique en premier : « Est-ce que
-- je porte des lunettes ? » en tête d'une fiche de rencontre. On ordonne
-- désormais par intérêt réel : valeurs, puis mode de vie, puis physique,
-- et à l'intérieur par pouvoir discriminant du critère.
create or replace function private.candidate_highlights(u uuid, autre uuid, n int default 3)
returns table (question text, reponse text, grp score_group)
language sql stable security definer set search_path = public, pg_temp as $$
  select c.question, o.label, p.grp
  from criterion_pairs p
  join criteria c on c.key = p.self_key
  join profile_answers a on a.user_id = autre and a.criterion_key = p.self_key
  join criterion_options o on o.criterion_key = p.self_key and o.idx = a.option_idx[1]
  join profile_vectors va on va.user_id = u
  join profile_vectors vb on vb.user_id = autre
  left join private.criterion_stats st on st.criterion_key = p.self_key
  where not p.is_absolute
    and c.sensitive_category is null
    and va.pref_mask[p.slot+1] is not null
    and vb.self_mask[p.slot+1] is not null
    and (vb.self_mask[p.slot+1] & va.pref_mask[p.slot+1]) <> 0
    and va.weight_mul[p.slot+1] > 0
  order by
    case p.grp when 'valeurs' then 0 when 'mode_vie' then 1 else 2 end,
    va.weight_mul[p.slot+1] desc,
    coalesce(st.entropie, 1.0) desc,
    c.ord
  limit n;
$$;
revoke all on function private.candidate_highlights(uuid, uuid, int) from public;;
