-- =========================================================
-- M9.1 - Separation des deux contextes de swipe
-- "Mieux me connaitre" : apprentissage pur, aucune exclusion.
-- "Partir en date"     : rencontre reelle, un refus ecarte.
-- =========================================================

do $$ begin
  create type public.swipe_contexte as enum ('mieux_me_connaitre','partir_en_date');
exception when duplicate_object then null; end $$;

alter table public.swipe_decisions
  add column if not exists contexte public.swipe_contexte not null default 'partir_en_date';

comment on column public.swipe_decisions.contexte is
  'Un swipe d''apprentissage et un swipe de rencontre ne veulent pas dire la meme chose. Le premier signifie "ce profil me plait", le second "je considere reellement cette personne". Leur poids et leurs consequences different.';

create index if not exists swipe_decisions_contexte
  on public.swipe_decisions (user_id, contexte, created_at desc);

insert into public.engine_params (key, value, description) values
  ('poids_swipe_apprentissage', 1.0, 'Poids d''un swipe realise dans Mieux me connaitre : simple signal d''interet general.'),
  ('poids_swipe_rencontre',     2.5, 'Poids d''un swipe realise dans Partir en date : l''utilisateur envisage reellement la personne, le signal est plus fort.'),
  ('focus_seuil_oui',           5,   'Longueur d''une serie de oui consecutifs pouvant declencher une question.')
on conflict (key) do nothing;

alter table public.focus_compatibilite
  add column if not exists criterion_key text,
  add column if not exists sens boolean;

comment on column public.focus_compatibilite.sens is
  'Sens de la serie ayant declenche la question : vrai apres une serie de oui, faux apres une serie de non.';

-- 1. Point commun d'une serie, dans les deux sens
create function private.focus_candidat(u uuid)
returns table (pair_key text, commun integer, effectif integer, sens boolean)
language sql stable set search_path = public, private as $$
  with depuis as (
    select coalesce(max(created_at), '-infinity'::timestamptz) as t
    from public.focus_compatibilite where user_id = u and context = 'swipe'
  ),
  recents as (
    select s.target_id, s.decision,
           row_number() over (order by s.created_at desc) as rn
    from public.swipe_decisions s, depuis
    where s.user_id = u and s.contexte = 'mieux_me_connaitre' and s.created_at > depuis.t
  ),
  tete as (select decision from recents where rn = 1),
  rupture as (
    select coalesce(min(r.rn), 2147483647) as rn
    from recents r, tete where r.decision <> tete.decision
  ),
  serie as (
    select r.target_id, r.decision from recents r, rupture where r.rn < rupture.rn
  ),
  taille as (select count(*)::int as n, bool_and(decision) as sens from serie),
  moi as (select * from public.profile_vectors where user_id = u),
  agg as (
    select p.pair_key, p.slot, p.base_weight,
           bit_and(v.self_mask[p.slot + 1]) as commun,
           count(v.self_mask[p.slot + 1])::int as repondus
    from public.criterion_pairs p
    cross join serie s
    join public.profile_vectors v on v.user_id = s.target_id
    where not exists (
      select 1 from public.criteria c
      where c.pair_key = p.pair_key and c.sensitive_category is not null
    )
    group by p.pair_key, p.slot, p.base_weight
  )
  select a.pair_key, a.commun, a.repondus, t.sens
  from agg a, moi, taille t
  where a.commun is not null and a.commun <> 0
    and a.repondus = t.n
    and t.n >= case when t.sens
                    then private.engine_param('focus_seuil_oui')
                    else private.engine_param('focus_seuil_croix') end
    and moi.pref_mask[a.slot + 1] is null
  order by a.base_weight desc, a.pair_key
  limit 1;
$$;

comment on function private.focus_candidat is
  'Analyse la derniere serie homogene de swipes d''apprentissage, dans les deux sens. N''etudier que les refus serait incomplet : comprendre pourquoi un utilisateur accepte vaut autant. Le critere retenu doit etre commun a toute la serie et non renseigne par l''utilisateur. Les criteres sensibles sont exclus par construction.';

-- 2. Declenchement
create or replace function private.declencher_focus(u uuid)
returns uuid
language plpgsql set search_path = public, private as $$
declare v_cand record; v_cle text; v_question text; v_id uuid;
begin
  if exists (select 1 from public.focus_compatibilite
             where user_id = u and answered_at is null) then return null; end if;

  if exists (select 1 from public.focus_compatibilite
             where user_id = u and context = 'swipe'
               and created_at > now() - (private.engine_param('focus_cooldown_h') || ' hours')::interval)
  then return null; end if;

  select * into v_cand from private.focus_candidat(u);
  if not found then return null; end if;

  select c.key, c.question into v_cle, v_question
  from public.criteria c
  where c.pair_key = v_cand.pair_key and c.direction = 'pref' limit 1;
  if v_cle is null then return null; end if;

  insert into public.focus_compatibilite (user_id, context, criterion_key, sens, question)
  values (u, 'swipe', v_cle, v_cand.sens, v_question)
  returning id into v_id;
  return v_id;
end $$;

-- 3. Enregistrement selon le contexte
create function private.enregistrer_swipe(
  u uuid, cible uuid, p_garde boolean,
  p_contexte public.swipe_contexte default 'partir_en_date',
  p_fort boolean default false, p_ecran text default null, p_duree integer default null
) returns uuid
language plpgsql set search_path = public, private as $$
begin
  if u = cible then
    raise exception 'Cible invalide' using errcode = 'check_violation';
  end if;

  insert into public.swipe_decisions
    (user_id, target_id, decision, contexte, signal_fort, ecran, duree_ms)
  values (u, cible, p_garde, p_contexte, p_fort, p_ecran, p_duree);

  if p_contexte = 'mieux_me_connaitre' then
    -- Aucune exclusion : le profil est une observation, pas une personne
    -- a rencontrer. L'ecarter du vivier briserait l'apprentissage.
    return private.declencher_focus(u);
  end if;

  if not p_garde then
    perform private.exclure(u, cible, u, 'refus_conversation', interval '30 days');
  end if;
  return null;
end $$;

comment on function private.enregistrer_swipe is
  'La consequence depend entierement du contexte. En apprentissage, un refus n''exclut personne et peut declencher une question. En rencontre reelle, un refus ecarte le profil 30 jours.';

-- 4. Lecture d'un focus
create function private.focus_en_attente(u uuid)
returns table (focus_id uuid, criterion_key text, question text,
               intitule text, multi boolean, options jsonb)
language sql stable set search_path = public, private as $$
  select f.id, f.criterion_key, f.question,
         case when f.sens then 'Qu''est-ce qui t''a particulièrement attiré ?'
                          else 'Qu''est-ce qui te plaît moins ?' end,
         c.multi_select,
         (select jsonb_agg(jsonb_build_object('idx', o.idx, 'label', o.label) order by o.idx)
            from public.criterion_options o where o.criterion_key = c.key)
  from public.focus_compatibilite f
  join public.criteria c on c.key = f.criterion_key
  where f.user_id = u and f.answered_at is null
  order by f.created_at limit 1;
$$;

create or replace function private.repondre_focus(u uuid, p_focus uuid, p_options smallint[])
returns void
language plpgsql set search_path = public, private as $$
declare v_cle text;
begin
  select criterion_key into v_cle from public.focus_compatibilite
  where id = p_focus and user_id = u and answered_at is null;
  if v_cle is null then
    raise exception 'Question introuvable' using errcode = 'no_data_found';
  end if;

  if p_options is null or cardinality(p_options) = 0 then
    update public.focus_compatibilite set reponse = 'passe', answered_at = now() where id = p_focus;
    return;
  end if;

  insert into public.profile_answers (user_id, criterion_key, option_idx, answered_at)
  values (u, v_cle, p_options, now())
  on conflict (user_id, criterion_key) do update
    set option_idx = excluded.option_idx, answered_at = now();

  update public.focus_compatibilite
     set reponse = p_options::text, answered_at = now() where id = p_focus;

  perform private.refresh_profile_vectors(u);
end $$;

-- 5. Fil d'apprentissage
create or replace function private.fil_apprentissage(u uuid, p_taille integer default 20)
returns table (profil_id uuid, prenom text, age integer,
               photo_principale text, profil_verifie boolean)
language sql stable set search_path = public, private as $$
  select c.id, c.prenom, h.age, h.photo_principale, h.profil_verifie
  from public.profiles c
  cross join lateral private.profile_header(c.id) h
  where c.id <> u and c.is_active
    and exists (select 1 from public.profile_vectors v where v.user_id = c.id)
    and not public.are_blocked(u, c.id)
    and not exists (
      select 1 from public.swipe_decisions s
      where s.user_id = u and s.target_id = c.id and s.contexte = 'mieux_me_connaitre'
    )
  order by random()
  limit p_taille;
$$;

comment on function private.fil_apprentissage is
  'Aucun filtre de distance, de disponibilite ni de type de rencontre : un utilisateur suisse peut voir un profil situe a l''autre bout du monde, et c''est voulu. Seul le blocage subsiste, pour raison de securite. L''ordre aleatoire est provisoire, il sera remplace par une selection pilotee par la couverture des criteres.';

-- 6. Wrappers publics
create function public.enregistrer_swipe(
  cible uuid, garder boolean,
  contexte public.swipe_contexte default 'partir_en_date',
  signal_fort boolean default false, ecran text default null, duree_ms integer default null
) returns uuid
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.enregistrer_swipe(auth.uid(), cible, garder, contexte, signal_fort, ecran, duree_ms);
end $$;

create or replace function public.fil_apprentissage(taille integer default 20)
returns table (profil_id uuid, prenom text, age integer,
               photo_principale text, profil_verifie boolean)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.fil_apprentissage(auth.uid(), taille);
end $$;

create function public.focus_en_attente()
returns table (focus_id uuid, criterion_key text, question text,
               intitule text, multi boolean, options jsonb)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.focus_en_attente(auth.uid());
end $$;

revoke all on function public.enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer) from public;
revoke all on function public.fil_apprentissage(integer) from public;
revoke all on function public.focus_en_attente() from public;

grant execute on function public.enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer) to authenticated;
grant execute on function public.fil_apprentissage(integer) to authenticated;
grant execute on function public.focus_en_attente() to authenticated;;
