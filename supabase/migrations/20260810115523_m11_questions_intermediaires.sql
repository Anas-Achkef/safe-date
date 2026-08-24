-- =========================================================
-- M11.3 - Questions intermediaires, dans les deux sens
-- "Fumez-vous ?" et "accepteriez-vous quelqu'un qui fume ?"
-- sont independantes. Une divergence n'est jamais une
-- incoherence et n'entraine aucune correction automatique.
-- =========================================================

insert into public.engine_params (key, value, description) values
  ('quest_cadence_min',   8, 'Nombre minimal de profils entre deux questions intermediaires, quand le moteur connait mal l''utilisateur.'),
  ('quest_cadence_max',  30, 'Nombre maximal de profils entre deux questions, quand le profil est deja bien documente.'),
  ('quest_proba',      0.75, 'Probabilite qu''une question soit posee une fois la cadence atteinte. Une regularite parfaite donnerait l''impression d''un questionnaire.')
on conflict (key) do nothing;

create or replace function private.cadence_questions(u uuid)
returns integer
language sql stable set search_path = public, private as $$
  select greatest(
    private.engine_param('quest_cadence_min'),
    round(private.engine_param('quest_cadence_min')
      + (private.engine_param('quest_cadence_max') - private.engine_param('quest_cadence_min'))
        * coalesce((select avg(confiance) from public.user_criterion_profile where user_id = u), 0))
  )::int;
$$;

comment on function private.cadence_questions is
  'Huit profils quand tout reste a apprendre, jusqu''a trente quand le profil est documente. La cadence suit l''etat des connaissances.';

create or replace function private.question_candidate(u uuid)
returns table (criterion_key text, direction text, question text,
               multi boolean, priorite numeric)
language sql stable set search_path = public, private as $$
  select c.key, c.direction::text, c.question, c.multi_select,
         round(
           (case when pa.user_id is null then 1 else 0 end) * 0.45
           + (case when pa.user_id is null and autre.user_id is not null then 1 else 0 end) * 0.25
           + (case when coalesce(pr.derive, false) then 1 else 0 end) * 0.20
           + coalesce(cp.base_weight, 0) / nullif((select max(base_weight) from public.criterion_pairs), 0) * 0.10
         , 4) as priorite
  from public.criteria c
  join public.criterion_pairs cp on cp.pair_key = c.pair_key
  left join public.profile_answers pa on pa.user_id = u and pa.criterion_key = c.key
  left join public.criteria autre_c
         on autre_c.pair_key = c.pair_key and autre_c.direction <> c.direction
  left join public.profile_answers autre
         on autre.user_id = u and autre.criterion_key = autre_c.key
  left join public.user_criterion_profile pr on pr.user_id = u and pr.criterion_key = c.key
  where (private.engine_param('appr_criteres_sensibles') >= 1 or c.sensitive_category is null)
    and (pa.user_id is null or coalesce(pr.derive, false))
  order by priorite desc, random()
  limit 1;
$$;

comment on function private.question_candidate is
  'Choisit entre une question sur l''utilisateur et une question sur ses preferences. Le complement d''un critere renseigne dans un seul sens est privilegie : savoir qu''une personne ne fume pas ne dit rien de ce qu''elle accepte chez l''autre.';

create or replace function private.declencher_question(u uuid)
returns uuid
language plpgsql set search_path = public, private as $$
declare v_depuis int; v_cand record; v_id uuid;
begin
  if exists (select 1 from public.focus_compatibilite
             where user_id = u and answered_at is null) then return null; end if;

  select count(*) into v_depuis
  from public.swipe_decisions s
  where s.user_id = u and s.contexte = 'mieux_me_connaitre'
    and s.created_at > coalesce(
      (select max(created_at) from public.focus_compatibilite
        where user_id = u and context = 'question_intermediaire'),
      '-infinity'::timestamptz);

  if v_depuis < private.cadence_questions(u) then return null; end if;
  if random() > private.engine_param('quest_proba') then return null; end if;

  select * into v_cand from private.question_candidate(u);
  if not found then return null; end if;

  insert into public.focus_compatibilite (user_id, context, criterion_key, question)
  values (u, 'question_intermediaire', v_cand.criterion_key, v_cand.question)
  returning id into v_id;
  return v_id;
end $$;

comment on function private.declencher_question is
  'La question n''apparait jamais apres chaque profil. Sa cadence suit les connaissances et garde une part d''aleatoire, pour preserver le sentiment de parcourir des profils.';

create or replace function private.apprentissage_apres_swipe(u uuid)
returns uuid
language plpgsql set search_path = public, private as $$
declare v_id uuid;
begin
  v_id := private.declencher_question(u);
  if v_id is not null then return v_id; end if;
  return private.declencher_focus(u);
end $$;

comment on function private.apprentissage_apres_swipe is
  'Une seule sollicitation a la fois. La question intermediaire passe avant le Focus de serie : elle comble un manque identifie, le second explore une intuition.';

create function private.focus_en_attente(u uuid)
returns table (focus_id uuid, contexte public.focus_context, criterion_key text,
               direction text, question text, intitule text,
               multi boolean, options jsonb)
language sql stable set search_path = public, private as $$
  select f.id, f.context, f.criterion_key, c.direction::text, f.question,
         case
           when f.context = 'question_intermediaire' and c.direction = 'self'
             then 'Parlons un peu de vous'
           when f.context = 'question_intermediaire'
             then 'Et chez les autres ?'
           when f.sens then 'Qu''est-ce qui t''a particulièrement attiré ?'
           else 'Qu''est-ce qui te plaît moins ?'
         end,
         coalesce(c.multi_select, false),
         coalesce(f.options,
           (select jsonb_agg(jsonb_build_object('idx', o.idx, 'label', o.label) order by o.idx)
              from public.criterion_options o where o.criterion_key = c.key))
  from public.focus_compatibilite f
  left join public.criteria c on c.key = f.criterion_key
  where f.user_id = u and f.answered_at is null
  order by f.created_at limit 1;
$$;

create function public.focus_en_attente()
returns table (focus_id uuid, contexte public.focus_context, criterion_key text,
               direction text, question text, intitule text,
               multi boolean, options jsonb)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.focus_en_attente(auth.uid());
end $$;

revoke all on function public.focus_en_attente() from public;
grant execute on function public.focus_en_attente() to authenticated;

-- Le swipe d'apprentissage passe par le nouvel aiguillage
create or replace function private.enregistrer_swipe(
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
  v_id bigint; v_score numeric; v_seuil numeric; v_err numeric;
  v_pres public.profile_presentations;
  v_vues public.score_group[]; v_ignore public.score_group[];
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
    v_exposes := private.cles_presentation(p_presentation);
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
      select array_agg(g) into v_ignore from unnest(v_pres.ordre_pages) g
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
    return private.apprentissage_apres_swipe(u);
  end if;

  if not p_garde then
    perform private.exclure(u, cible, u, 'refus_conversation', interval '30 days');
  end if;

  return private.declencher_focus_erreur(u, v_id);
end $$;;
