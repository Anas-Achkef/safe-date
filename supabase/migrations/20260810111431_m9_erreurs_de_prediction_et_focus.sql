-- =========================================================
-- M9.6 - Erreurs de prediction et Focus Compatibilite
-- =========================================================

alter table public.swipe_decisions
  add column if not exists score_predit      numeric(6,2),
  add column if not exists seuil_predit      numeric(4,3),
  add column if not exists erreur_prediction numeric(5,4);

comment on column public.swipe_decisions.score_predit is
  'Compatibilite annoncee par le moteur au moment du swipe, dans le contexte de recherche actif. Sans elle, aucune erreur ne peut etre imputee.';
comment on column public.swipe_decisions.erreur_prediction is
  'Ecart entre prediction et decision reelle, de 0 a 1. Une prediction elevee suivie d''un refus, ou l''inverse, produit une erreur proche de 1.';

alter table public.focus_compatibilite
  add column if not exists swipe_id bigint references public.swipe_decisions(id) on delete set null,
  add column if not exists options jsonb;

insert into public.engine_params (key, value, description) values
  ('focus_seuil_erreur', 0.45, 'Ecart entre prediction et decision au-dela duquel un Focus devient pertinent.'),
  ('focus_proba_serie',  0.65, 'Probabilite qu''une serie homogene declenche effectivement une question. Inferieure a 1 pour que la regle reste indevinable.'),
  ('focus_proba_erreur', 0.80, 'Probabilite qu''une erreur de prediction marquee declenche une question. Plus haute : c''est la que le moteur a le plus a apprendre.')
on conflict (key) do nothing;

-- 1. Focus sur erreur de prediction
create or replace function private.declencher_focus_erreur(u uuid, p_swipe bigint)
returns uuid
language plpgsql set search_path = public, private as $$
declare d public.swipe_decisions; v_id uuid;
begin
  select * into d from public.swipe_decisions where id = p_swipe;
  if d.erreur_prediction is null
     or d.erreur_prediction < private.engine_param('focus_seuil_erreur') then return null; end if;

  if exists (select 1 from public.focus_compatibilite
             where user_id = u and answered_at is null) then return null; end if;

  if exists (select 1 from public.focus_compatibilite
             where user_id = u
               and created_at > now() - (private.engine_param('focus_cooldown_h') || ' hours')::interval)
  then return null; end if;

  if random() > private.engine_param('focus_proba_erreur') then return null; end if;

  insert into public.focus_compatibilite
    (user_id, context, target_user_id, swipe_id, sens, question, options)
  values (u, 'erreur_prediction', d.target_id, p_swipe, d.decision,
          case when d.decision
               then 'Qu''est-ce qui t''a particulièrement attiré dans ce profil ?'
               else 'Qu''est-ce qui correspondait le moins à tes goûts ?' end,
          '[{"cle":"physique","label":"Son apparence"},
            {"cle":"mode_vie","label":"Son mode de vie"},
            {"cle":"valeurs","label":"Ses valeurs"},
            {"cle":"personnalite","label":"Sa personnalité"},
            {"cle":"indefini","label":"Difficile à dire"}]'::jsonb)
  returning id into v_id;
  return v_id;
end $$;

comment on function private.declencher_focus_erreur is
  'Declenche apres un ecart marque entre prediction et comportement. La question porte sur la categorie qui a emporte la decision, pas sur un critere precis : quand le modele se trompe, il ignore justement lequel interroger.';

-- 2. Enregistrement du swipe avec prediction
create or replace function private.enregistrer_swipe(
  u uuid, cible uuid, p_garde boolean,
  p_contexte public.swipe_contexte default 'partir_en_date',
  p_fort boolean default false, p_ecran text default null, p_duree integer default null,
  p_ecrans jsonb default null, p_ordre public.score_group[] default null,
  p_retours integer default 0, p_exposes text[] default null,
  p_consultes text[] default null, p_type public.rencontre_type default null
) returns uuid
language plpgsql set search_path = public, private as $$
declare v_id bigint; v_sc record; v_err numeric;
begin
  if u = cible then
    raise exception 'Cible invalide' using errcode = 'check_violation';
  end if;

  if p_contexte = 'partir_en_date' and p_type is not null then
    select * into v_sc from private.score_contextuel(u, cible, p_type);
    if v_sc.score is not null then
      v_err := greatest(0, least(1,
        round(abs((case when p_garde then 1 else 0 end) - v_sc.score / 100.0), 4)));
    end if;
  end if;

  insert into public.swipe_decisions
    (user_id, target_id, decision, contexte, type_rencontre, signal_fort, ecran, duree_ms,
     duree_totale_ms, ordre_consultation, retours, criteres_exposes, criteres_consultes,
     score_predit, seuil_predit, erreur_prediction, snapshot)
  values
    (u, cible, p_garde, p_contexte, p_type, p_fort, p_ecran, p_duree,
     p_duree, p_ordre, coalesce(p_retours, 0)::smallint, p_exposes, p_consultes,
     v_sc.score, v_sc.seuil, v_err,
     jsonb_build_object(
       'age',        (select h.age from private.profile_header(cible) h),
       'verifie',    (select h.profil_verifie from private.profile_header(cible) h),
       'vecteur_le', (select v.refreshed_at from public.profile_vectors v where v.user_id = cible)))
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
  end if;

  if p_contexte = 'mieux_me_connaitre' then
    return private.declencher_focus(u);
  end if;

  if not p_garde then
    perform private.exclure(u, cible, u, 'refus_conversation', interval '30 days');
  end if;

  return private.declencher_focus_erreur(u, v_id);
end $$;

-- 3. Part d'aleatoire sur les series
create or replace function private.declencher_focus(u uuid)
returns uuid
language plpgsql set search_path = public, private as $$
declare v_cand record; v_cle text; v_question text; v_id uuid;
begin
  if exists (select 1 from public.focus_compatibilite
             where user_id = u and answered_at is null) then return null; end if;
  if exists (select 1 from public.focus_compatibilite
             where user_id = u
               and created_at > now() - (private.engine_param('focus_cooldown_h') || ' hours')::interval)
  then return null; end if;

  select * into v_cand from private.focus_candidat(u);
  if not found then return null; end if;

  -- Cinq refus consecutifs sont un declencheur potentiel, pas une regle.
  if random() > private.engine_param('focus_proba_serie') then return null; end if;

  select c.key, c.question into v_cle, v_question
  from public.criteria c where c.pair_key = v_cand.pair_key and c.direction = 'pref' limit 1;
  if v_cle is null then return null; end if;

  insert into public.focus_compatibilite (user_id, context, criterion_key, sens, question)
  values (u, 'swipe', v_cle, v_cand.sens, v_question)
  returning id into v_id;
  return v_id;
end $$;

-- 4. Lecture unifiee
create function private.focus_en_attente(u uuid)
returns table (focus_id uuid, contexte public.focus_context, criterion_key text,
               question text, intitule text, multi boolean, options jsonb)
language sql stable set search_path = public, private as $$
  select f.id, f.context, f.criterion_key, f.question,
         case when f.sens then 'Qu''est-ce qui t''a particulièrement attiré ?'
                          else 'Qu''est-ce qui te plaît moins ?' end,
         coalesce(c.multi_select, false),
         coalesce(f.options,
           (select jsonb_agg(jsonb_build_object('idx', o.idx, 'label', o.label) order by o.idx)
              from public.criterion_options o where o.criterion_key = c.key))
  from public.focus_compatibilite f
  left join public.criteria c on c.key = f.criterion_key
  where f.user_id = u and f.answered_at is null
  order by f.created_at limit 1;
$$;

create function private.repondre_focus(u uuid, p_focus uuid, p_options smallint[],
                                       p_categorie text default null)
returns void
language plpgsql set search_path = public, private as $$
declare f public.focus_compatibilite;
begin
  select * into f from public.focus_compatibilite
  where id = p_focus and user_id = u and answered_at is null;
  if f.id is null then
    raise exception 'Question introuvable' using errcode = 'no_data_found';
  end if;

  if (p_options is null or cardinality(p_options) = 0) and p_categorie is null then
    update public.focus_compatibilite set reponse = 'passe', answered_at = now() where id = p_focus;
    return;
  end if;

  -- Question de categorie : enregistree telle quelle, sans rien deduire du profil
  if f.criterion_key is null then
    update public.focus_compatibilite
       set reponse = p_categorie, answered_at = now() where id = p_focus;
    return;
  end if;

  insert into public.profile_answers (user_id, criterion_key, option_idx, answered_at)
  values (u, f.criterion_key, p_options, now())
  on conflict (user_id, criterion_key) do update
    set option_idx = excluded.option_idx, answered_at = now();

  update public.focus_compatibilite
     set reponse = p_options::text, answered_at = now() where id = p_focus;

  perform private.refresh_profile_vectors(u);
end $$;

-- 5. Qualite du moteur (§4.79)
create or replace function private.qualite_moteur(u uuid default null)
returns table (type_rencontre public.rencontre_type, predictions integer,
               erreur_moyenne numeric, faux_positifs integer, faux_negatifs integer,
               justes integer, taux_justesse numeric)
language sql stable set search_path = public, private as $$
  select d.type_rencontre, count(*)::int,
         round(avg(d.erreur_prediction), 4),
         count(*) filter (where d.score_predit >= d.seuil_predit * 100 and not d.decision)::int,
         count(*) filter (where d.score_predit <  d.seuil_predit * 100 and     d.decision)::int,
         count(*) filter (where (d.score_predit >= d.seuil_predit * 100) = d.decision)::int,
         round(count(*) filter (where (d.score_predit >= d.seuil_predit * 100) = d.decision)::numeric
               / nullif(count(*), 0), 4)
  from public.swipe_decisions d
  where d.contexte = 'partir_en_date' and d.score_predit is not null
    and (u is null or d.user_id = u)
  group by d.type_rencontre;
$$;

comment on function private.qualite_moteur is
  'Mesure si le moteur s''ameliore reellement. Un faux positif est une rencontre annoncee compatible puis refusee ; un faux negatif une compatibilite sous-estimee et pourtant acceptee. Les seconds coutent plus cher : ce sont des occasions jamais proposees.';

-- 6. Wrappers
drop function if exists public.enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer, jsonb, public.score_group[], integer, text[], text[]);

create function public.enregistrer_swipe(
  cible uuid, garder boolean,
  contexte public.swipe_contexte default 'partir_en_date',
  signal_fort boolean default false, ecran text default null, duree_ms integer default null,
  ecrans jsonb default null, ordre_consultation public.score_group[] default null,
  retours integer default 0, criteres_exposes text[] default null,
  criteres_consultes text[] default null, type_rencontre public.rencontre_type default null
) returns uuid
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.enregistrer_swipe(auth.uid(), cible, garder, contexte, signal_fort,
    ecran, duree_ms, ecrans, ordre_consultation, retours, criteres_exposes,
    criteres_consultes, type_rencontre);
end $$;

create function public.focus_en_attente()
returns table (focus_id uuid, contexte public.focus_context, criterion_key text,
               question text, intitule text, multi boolean, options jsonb)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.focus_en_attente(auth.uid());
end $$;

create function public.repondre_focus(focus uuid, options smallint[] default null,
                                      categorie text default null)
returns void
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  perform private.repondre_focus(auth.uid(), focus, options, categorie);
end $$;

revoke all on function public.enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer, jsonb, public.score_group[], integer, text[], text[], public.rencontre_type) from public;
revoke all on function public.focus_en_attente() from public;
revoke all on function public.repondre_focus(uuid, smallint[], text) from public;

grant execute on function public.enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer, jsonb, public.score_group[], integer, text[], text[], public.rencontre_type) to authenticated;
grant execute on function public.focus_en_attente() to authenticated;
grant execute on function public.repondre_focus(uuid, smallint[], text) to authenticated;;
