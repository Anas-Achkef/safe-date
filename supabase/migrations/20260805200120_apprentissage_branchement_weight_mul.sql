create or replace function private.learned_coef(u uuid, pk text)
returns numeric language sql stable as
$fn$
  select coalesce((select l.learned_mul from user_criterion_learning l
                   where l.user_id = u and l.pair_key = pk), 1.0);
$fn$;

comment on function private.learned_coef is
  'Multiplicateur appris pour un critere donne. Vaut 1 tant qu''aucune decision n''a ete observee.';

insert into engine_params (key, value, description) values
  ('apprentissage_seuil_refresh', 0.02, 'Variation minimale d''un poids appris declenchant la reconstruction des vecteurs')
on conflict (key) do nothing;

-- Reconstruction des vecteurs : identique a l'existant, avec l'ajout du
-- coefficient appris dans le calcul de weight_mul, aux cotes de priorite_coef.
create or replace function private.refresh_profile_vectors(u uuid)
returns void language plpgsql security definer set search_path to 'public','pg_temp' as
$fn$
declare v_self int[] := array_fill(null::int, array[133]);
  v_pref int[] := array_fill(null::int, array[133]);
  v_wm numeric[] := array_fill(1.0::numeric, array[133]);
  n_self smallint := 0; n_pref smallint := 0; r record; a_correspondance boolean;
begin
  for r in select p.slot, a.option_idx from criterion_pairs p
    join profile_answers a on a.criterion_key = p.self_key and a.user_id = u
  loop
    v_self[r.slot+1] := (select coalesce(sum(1 << i),0)::int from unnest(r.option_idx) as i);
    n_self := n_self + 1;
  end loop;

  for r in select p.slot, p.pair_key, p.match_type, a.option_idx, s.option_idx as my_own_idx,
      pr.rang as rang_priorite
    from criterion_pairs p
    join profile_answers a on a.criterion_key = p.pref_key and a.user_id = u
    left join profile_answers s on s.criterion_key = p.self_key and s.user_id = u
    left join user_criterion_priorities pr on pr.user_id = u and pr.pair_key = p.pair_key
  loop
    -- Une correspondance ABSENTE et une correspondance VIDE ne veulent pas
    -- dire la même chose. Absente : le client n'a pas encore tranché, le
    -- critère doit sortir du calcul. Vide : le client a dit « aucune option
    -- ne convient », c'est un vrai désaccord.
    a_correspondance := exists (select 1 from option_mappings m
      where m.pair_key = r.pair_key and m.pref_idx = any(r.option_idx));

    if not a_correspondance then
      v_pref[r.slot+1] := null;
    elsif r.match_type = 'echelle' then
      v_pref[r.slot+1] := (select coalesce(sum(1 << g.i),0)::int
        from option_mappings m cross join generate_series(0,14) as g(i)
        where m.pair_key = r.pair_key and m.pref_idx = r.option_idx[1]
          and r.my_own_idx is not null and m.tolerance is not null
          and abs(g.i - r.my_own_idx[1]) <= m.tolerance);
    else
      v_pref[r.slot+1] := (select coalesce(sum(distinct 1 << acc),0)::int
        from option_mappings m, unnest(m.accepted_self_idx) as acc
        where m.pair_key = r.pair_key and m.pref_idx = any(r.option_idx));
    end if;

    -- Poids effectif : declare par le client x priorite de l'utilisateur
    -- x ce que ses decisions reelles ont appris sur ce critere.
    v_wm[r.slot+1] := coalesce((select min(m.weight_multiplier) from option_mappings m
        where m.pair_key = r.pair_key and m.pref_idx = any(r.option_idx)),1.0)
      * priorite_coef(r.rang_priorite)
      * private.learned_coef(u, r.pair_key);

    if a_correspondance then n_pref := n_pref + 1; end if;
  end loop;

  insert into profile_vectors (user_id, self_mask, pref_mask, weight_mul, answered_self, answered_pref, refreshed_at)
  values (u, v_self, v_pref, v_wm, n_self, n_pref, now())
  on conflict (user_id) do update set self_mask=excluded.self_mask, pref_mask=excluded.pref_mask,
    weight_mul=excluded.weight_mul, answered_self=excluded.answered_self,
    answered_pref=excluded.answered_pref, refreshed_at=now();
end $fn$;;
