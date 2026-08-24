create function private.enregistrer_swipe(
  u uuid, cible uuid, p_garde boolean,
  p_contexte public.swipe_contexte default 'partir_en_date',
  p_fort boolean default false, p_ecran text default null, p_duree integer default null,
  p_ecrans jsonb default null, p_ordre public.score_group[] default null,
  p_retours integer default 0, p_exposes text[] default null,
  p_consultes text[] default null, p_type public.rencontre_type default null,
  p_presentation bigint default null
) returns uuid
language plpgsql set search_path = public, private as $$
declare
  v_id      bigint;
  v_score   numeric;
  v_seuil   numeric;
  v_err     numeric;
  v_pres    public.profile_presentations;
  v_vues    public.score_group[];
  v_ignore  public.score_group[];
  v_exposes text[] := p_exposes;
begin
  if u = cible then
    raise exception 'Cible invalide' using errcode = 'check_violation';
  end if;

  if p_presentation is not null then
    select * into v_pres from public.profile_presentations
     where id = p_presentation and observer_id = u and target_id = cible;
    if v_pres.id is null then
      raise exception 'Présentation introuvable' using errcode = 'no_data_found';
    end if;

    -- La presentation fait foi sur ce qui a ete montre
    if v_exposes is null then
      select array_agg(v #>> '{}') into v_exposes
      from jsonb_each(v_pres.criteres) e, jsonb_array_elements(e.value) v;
    end if;
  end if;

  if p_contexte = 'partir_en_date' and p_type is not null then
    select s.score, s.seuil into v_score, v_seuil
    from private.score_contextuel(u, cible, p_type) s;
    if v_score is not null then
      v_err := greatest(0, least(1,
        round(abs((case when p_garde then 1 else 0 end) - v_score / 100.0), 4)));
    end if;
  end if;

  insert into public.swipe_decisions
    (user_id, target_id, decision, contexte, type_rencontre, signal_fort, ecran, duree_ms,
     duree_totale_ms, ordre_consultation, retours, criteres_exposes, criteres_consultes,
     score_predit, seuil_predit, erreur_prediction, presentation_id, snapshot)
  values
    (u, cible, p_garde, p_contexte, p_type, p_fort, p_ecran, p_duree,
     p_duree, p_ordre, coalesce(p_retours, 0)::smallint, v_exposes, p_consultes,
     v_score, v_seuil, v_err, p_presentation,
     jsonb_build_object(
       'age',         (select h.age from private.profile_header(cible) h),
       'verifie',     (select h.profil_verifie from private.profile_header(cible) h),
       'ordre_servi', v_pres.ordre_pages,
       'vecteur_le',  (select v.refreshed_at from public.profile_vectors v where v.user_id = cible)))
  returning id into v_id;

  if p_ecrans is not null then
    insert into public.swipe_ecrans (swipe_id, ecran, duree_ms, consultations)
    select v_id, (e->>'ecran')::public.score_group,
           coalesce((e->>'duree_ms')::int, 0), coalesce((e->>'consultations')::smallint, 1)
    from jsonb_array_elements(p_ecrans) e
    on conflict (swipe_id, ecran) do update
      set duree_ms      = public.swipe_ecrans.duree_ms + excluded.duree_ms,
          consultations = public.swipe_ecrans.consultations + excluded.consultations;
    perform private.calculer_attention(v_id);

    select array_agg(ecran) into v_vues
    from public.swipe_ecrans where swipe_id = v_id and duree_ms > 0;

    if v_pres.ordre_pages is not null then
      select array_agg(g) into v_ignore
      from unnest(v_pres.ordre_pages) g
      where v_vues is null or not (g = any (v_vues));
    end if;

    update public.swipe_decisions
       set pages_ignorees  = case when v_pres.ordre_pages is not null
                                  then coalesce(v_ignore, '{}'::public.score_group[]) end,
           vitesse_ms_page = case when coalesce(cardinality(v_vues), 0) > 0
                                  then (select sum(duree_ms) / cardinality(v_vues)
                                        from public.swipe_ecrans where swipe_id = v_id) end
     where id = v_id;
  end if;

  if p_contexte = 'mieux_me_connaitre' then
    return private.declencher_focus(u);
  end if;

  if not p_garde then
    perform private.exclure(u, cible, u, 'refus_conversation', interval '30 days');
  end if;

  return private.declencher_focus_erreur(u, v_id);
end $$;

comment on function private.enregistrer_swipe is
  'Quand une presentation est fournie, elle fait foi sur ce qui a ete montre : les criteres exposes en sont deduits et les pages servies mais jamais ouvertes sont calculees par difference avec les pages effectivement consultees.';

drop function if exists public.enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer, jsonb, public.score_group[], integer, text[], text[], public.rencontre_type);

create function public.enregistrer_swipe(
  cible uuid, garder boolean,
  contexte public.swipe_contexte default 'partir_en_date',
  signal_fort boolean default false, ecran text default null, duree_ms integer default null,
  ecrans jsonb default null, ordre_consultation public.score_group[] default null,
  retours integer default 0, criteres_exposes text[] default null,
  criteres_consultes text[] default null, type_rencontre public.rencontre_type default null,
  presentation_id bigint default null
) returns uuid
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.enregistrer_swipe(auth.uid(), cible, garder, contexte, signal_fort,
    ecran, duree_ms, ecrans, ordre_consultation, retours, criteres_exposes,
    criteres_consultes, type_rencontre, presentation_id);
end $$;

revoke all on function public.enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer, jsonb, public.score_group[], integer, text[], text[], public.rencontre_type, bigint) from public;
grant execute on function public.enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer, jsonb, public.score_group[], integer, text[], text[], public.rencontre_type, bigint) to authenticated;;
