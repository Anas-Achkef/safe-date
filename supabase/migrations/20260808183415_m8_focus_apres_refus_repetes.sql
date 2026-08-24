-- =========================================================
-- M8 - Affinage apres refus repetes
-- Au bout de N croix, le moteur cherche ce que les profils
-- ecartes avaient en commun et pose UNE question ciblee.
-- =========================================================

insert into public.engine_params (key, value, description) values
  ('focus_seuil_croix',   5, 'Nombre de refus consecutifs avant de poser une question d''affinage.'),
  ('focus_fenetre_max',  20, 'Nombre maximal de refus recents analyses pour trouver le point commun.'),
  ('focus_cooldown_h',   12, 'Delai minimal entre deux questions d''affinage, en heures.')
on conflict (key) do nothing;

-- ---------------------------------------------------------
-- 1. Le point commun des profils ecartes
-- ---------------------------------------------------------
create or replace function private.focus_candidat(u uuid)
returns table (pair_key text, commun integer, effectif integer)
language sql stable set search_path = public, private as $$
  with depuis as (
    select coalesce(max(created_at), '-infinity'::timestamptz) as t
    from public.focus_compatibilite
    where user_id = u and context = 'swipe'
  ),
  rejets as (
    select s.target_id
    from public.swipe_decisions s, depuis
    where s.user_id = u and s.decision = false and s.created_at > depuis.t
    order by s.created_at desc
    limit (select private.engine_param('focus_fenetre_max')::int)
  ),
  n_rejets as (select count(*)::int as n from rejets),
  moi as (select * from public.profile_vectors where user_id = u),
  agg as (
    select p.pair_key, p.slot, p.base_weight,
           bit_and(v.self_mask[p.slot + 1]) as commun,
           count(v.self_mask[p.slot + 1])::int as repondus
    from public.criterion_pairs p
    cross join rejets r
    join public.profile_vectors v on v.user_id = r.target_id
    where not p.is_absolute
      -- Jamais de question generee sur un critere sensible :
      -- l'apprentissage automatique en ferait un outil de tri discriminatoire.
      and not exists (
        select 1 from public.criteria c
        where c.pair_key = p.pair_key and c.sensitive_category is not null
      )
    group by p.pair_key, p.slot, p.base_weight
  )
  select a.pair_key, a.commun, a.repondus
  from agg a, moi, n_rejets
  where a.commun is not null
    and a.commun <> 0
    and a.repondus = n_rejets.n              -- tous les profils ecartes ont repondu
    and n_rejets.n >= private.engine_param('focus_seuil_croix')
    and moi.pref_mask[a.slot + 1] is null    -- et moi, je ne me suis pas prononce
  order by a.base_weight desc, a.pair_key
  limit 1;
$$;

comment on function private.focus_candidat is
  'Cherche un critere sur lequel les profils ecartes etaient unanimes ET sur lequel l''utilisateur n''a pas exprime de preference. C''est la que la question apporte quelque chose : elle ne redemande pas ce qui est deja connu. Les criteres sensibles sont exclus par construction.';

-- ---------------------------------------------------------
-- 2. Declenchement
-- ---------------------------------------------------------
create or replace function private.declencher_focus(u uuid)
returns uuid
language plpgsql set search_path = public, private as $$
declare
  v_cand    record;
  v_cle     text;
  v_question text;
  v_id      uuid;
begin
  -- Une seule question en attente a la fois
  if exists (select 1 from public.focus_compatibilite
             where user_id = u and answered_at is null) then
    return null;
  end if;

  -- Respect du delai entre deux sollicitations
  if exists (select 1 from public.focus_compatibilite
             where user_id = u and context = 'swipe'
               and created_at > now() - (private.engine_param('focus_cooldown_h') || ' hours')::interval) then
    return null;
  end if;

  select * into v_cand from private.focus_candidat(u);
  if not found then
    return null;
  end if;

  select c.key, c.question into v_cle, v_question
  from public.criteria c
  where c.pair_key = v_cand.pair_key and c.direction = 'pref'
  limit 1;

  if v_cle is null then
    return null;
  end if;

  insert into public.focus_compatibilite (user_id, context, question)
  values (u, 'swipe', v_cle || E'\n' || v_question)
  returning id into v_id;

  return v_id;
end $$;

comment on function private.declencher_focus is
  'Une seule question en attente a la fois, et un delai minimal entre deux. Sans ces deux garde-fous, un utilisateur difficile serait interroge en continu et abandonnerait.';

-- ---------------------------------------------------------
-- 3. Enregistrement d'un swipe
-- ---------------------------------------------------------
create or replace function private.enregistrer_swipe(
  u        uuid,
  cible    uuid,
  p_garde  boolean,
  p_fort   boolean default false,
  p_ecran  text default null,
  p_duree  integer default null
) returns uuid
language plpgsql set search_path = public, private as $$
begin
  if u = cible then
    raise exception 'Cible invalide' using errcode = 'check_violation';
  end if;

  insert into public.swipe_decisions (user_id, target_id, decision, signal_fort, ecran, duree_ms)
  values (u, cible, p_garde, p_fort, p_ecran, p_duree);

  -- Une croix ecarte le profil du fil, sans notification a l'autre
  if not p_garde then
    perform private.exclure(u, cible, u, 'refus_conversation', interval '30 days');
    return private.declencher_focus(u);
  end if;

  return null;
end $$;

comment on function private.enregistrer_swipe is
  'Une croix vaut refus : le trigger d''apprentissage ajuste les poids, le profil sort du fil 30 jours, et le seuil de questions d''affinage est reevalue. Retourne l''identifiant d''une question a poser, ou null.';

-- ---------------------------------------------------------
-- 4. Lecture et reponse
-- ---------------------------------------------------------
create or replace function private.focus_en_attente(u uuid)
returns table (focus_id uuid, criterion_key text, question text,
               multi boolean, options jsonb)
language sql stable set search_path = public, private as $$
  select f.id,
         split_part(f.question, E'\n', 1),
         split_part(f.question, E'\n', 2),
         c.multi_select,
         (select jsonb_agg(jsonb_build_object('idx', o.idx, 'label', o.label) order by o.idx)
            from public.criterion_options o
           where o.criterion_key = c.key)
  from public.focus_compatibilite f
  join public.criteria c on c.key = split_part(f.question, E'\n', 1)
  where f.user_id = u and f.answered_at is null
  order by f.created_at
  limit 1;
$$;

create or replace function private.repondre_focus(
  u uuid, p_focus uuid, p_options smallint[]
) returns void
language plpgsql set search_path = public, private as $$
declare v_cle text;
begin
  select split_part(question, E'\n', 1) into v_cle
  from public.focus_compatibilite
  where id = p_focus and user_id = u and answered_at is null;

  if v_cle is null then
    raise exception 'Question introuvable' using errcode = 'no_data_found';
  end if;

  if p_options is null or cardinality(p_options) = 0 then
    -- Refus de repondre : on l'enregistre sans rien deduire
    update public.focus_compatibilite
       set reponse = 'passe', answered_at = now()
     where id = p_focus;
    return;
  end if;

  insert into public.profile_answers (user_id, criterion_key, option_idx, answered_at)
  values (u, v_cle, p_options, now())
  on conflict (user_id, criterion_key) do update
    set option_idx = excluded.option_idx, answered_at = now();

  update public.focus_compatibilite
     set reponse = p_options::text, answered_at = now()
   where id = p_focus;

  -- La preference change : le vecteur est reconstruit, le cache invalide
  perform private.refresh_profile_vectors(u);
end $$;

comment on function private.repondre_focus is
  'La reponse alimente le profil comme une reponse d''onboarding : elle est reversible dans les reglages et n''a rien d''un reglage cache. Passer est une reponse valable dont le moteur ne deduit rien.';

-- ---------------------------------------------------------
-- 5. Wrappers publics
-- ---------------------------------------------------------
create or replace function public.enregistrer_swipe(
  cible uuid, garder boolean, signal_fort boolean default false,
  ecran text default null, duree_ms integer default null
) returns uuid
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.enregistrer_swipe(auth.uid(), cible, garder, signal_fort, ecran, duree_ms);
end $$;

create or replace function public.focus_en_attente()
returns table (focus_id uuid, criterion_key text, question text,
               multi boolean, options jsonb)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.focus_en_attente(auth.uid());
end $$;

create or replace function public.repondre_focus(focus uuid, options smallint[])
returns void
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  perform private.repondre_focus(auth.uid(), focus, options);
end $$;

revoke all on function public.enregistrer_swipe(uuid, boolean, boolean, text, integer) from public;
revoke all on function public.focus_en_attente() from public;
revoke all on function public.repondre_focus(uuid, smallint[]) from public;

grant execute on function public.enregistrer_swipe(uuid, boolean, boolean, text, integer) to authenticated;
grant execute on function public.focus_en_attente() to authenticated;
grant execute on function public.repondre_focus(uuid, smallint[]) to authenticated;;
