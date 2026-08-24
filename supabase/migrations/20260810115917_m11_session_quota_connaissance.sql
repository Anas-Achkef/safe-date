-- =========================================================
-- M11.4 - Session, quota quotidien et niveau de connaissance
--
-- Le pourcentage affiche n'est pas un compteur de reponses :
-- c'est la confiance globale du moteur. Il peut donc baisser,
-- et une baisse n'est pas une regression.
-- =========================================================

insert into public.engine_params (key, value, description) values
  ('session_quota_gratuit', 40, 'Nombre de profils consultables par jour en version gratuite. Zero signifie aucune limite.'),
  ('session_duree_cible_min', 7, 'Duree moyenne visee pour une session d''apprentissage, en minutes.')
on conflict (key) do nothing;

-- Messages de cloture, tires au sort pour eviter la repetition
create table if not exists public.session_messages (
  id       smallint generated always as identity primary key,
  message  text not null,
  actif    boolean not null default true
);

insert into public.session_messages (message)
select m from (values
  ('Votre profil est encore plus précis qu''hier.'),
  ('Safe Date comprend désormais encore mieux vos préférences.'),
  ('Votre moteur de compatibilité continue de gagner en précision.'),
  ('Vos futures recommandations seront encore plus personnalisées.'),
  ('Nous découvrons progressivement ce qui vous correspond vraiment.'),
  ('Votre profil évolue à chaque session.'),
  ('Nous affinons progressivement votre profil.'),
  ('Votre profil devient de plus en plus fidèle à votre personnalité.'),
  ('Nous avons identifié de nouvelles préférences aujourd''hui.'),
  ('Chaque session améliore la qualité de vos futures recommandations.')
) v(m)
where not exists (select 1 from public.session_messages);

-- Historique quotidien, pour situer la progression
create table if not exists public.user_knowledge_history (
  user_id uuid not null references public.profiles(id) on delete cascade,
  jour    date not null,
  niveau  numeric(5,4) not null,
  primary key (user_id, jour)
);
alter table public.user_knowledge_history enable row level security;

comment on table public.user_knowledge_history is
  'Un releve par jour, pour pouvoir dire a l''utilisateur ou il en est par rapport a hier sans recalculer le passe.';

-- ---------------------------------------------------------
-- 1. Niveau de connaissance (§4.15)
-- ---------------------------------------------------------
create or replace function private.niveau_connaissance(u uuid)
returns numeric
language sql stable set search_path = public, private as $$
  -- Moyenne des confiances sur TOUS les criteres, y compris ceux
  -- jamais observes : ne compter que les criteres connus donnerait
  -- cent pour cent des la premiere reponse.
  select round(coalesce(
    sum(coalesce(case when coalesce(p.derive, false)
                      then p.confiance * 0.5   -- une derive detectee fait reculer la confiance
                      else p.confiance end, 0) * cp.base_weight)
    / nullif(sum(cp.base_weight), 0), 0), 4)
  from public.criteria c
  join public.criterion_pairs cp on cp.pair_key = c.pair_key
  left join public.user_criterion_profile p on p.user_id = u and p.criterion_key = c.key
  where c.direction = 'self'
    and (private.engine_param('appr_criteres_sensibles') >= 1 or c.sensitive_category is null);
$$;

comment on function private.niveau_connaissance is
  'Confiance globale ponderee par l''importance des criteres, calculee sur l''ensemble du referentiel. Une derive detectee reduit de moitie la confiance du critere concerne : l''indicateur peut donc baisser, ce qui signifie que le moteur doit reverifier, pas qu''il a perdu des donnees.';

-- ---------------------------------------------------------
-- 2. Etat de la session
-- ---------------------------------------------------------
create or replace function private.etat_session(u uuid)
returns table (profils_vus integer, quota integer, restants integer,
               illimite boolean, niveau numeric)
language sql stable set search_path = public, private as $$
  with prem as (select coalesce(is_premium, false) as p from public.profiles where id = u),
       q as (select private.engine_param('session_quota_gratuit')::int as v),
       vus as (
         select count(*)::int as n from public.swipe_decisions
         where user_id = u and contexte = 'mieux_me_connaitre'
           and created_at >= date_trunc('day', now())
       )
  select vus.n, q.v,
         case when prem.p or q.v = 0 then null else greatest(0, q.v - vus.n) end,
         (prem.p or q.v = 0),
         private.niveau_connaissance(u)
  from prem, q, vus;
$$;

-- ---------------------------------------------------------
-- 3. Cloture de session (§4.13)
-- ---------------------------------------------------------
create or replace function private.cloturer_session(u uuid)
returns table (message text, niveau numeric, niveau_hier numeric,
               progression numeric, profils_vus integer, illimite boolean)
language plpgsql set search_path = public, private as $$
declare
  v_niveau numeric := private.niveau_connaissance(u);
  v_hier   numeric;
begin
  select h.niveau into v_hier
  from public.user_knowledge_history h
  where h.user_id = u and h.jour < current_date
  order by h.jour desc limit 1;

  insert into public.user_knowledge_history (user_id, jour, niveau)
  values (u, current_date, v_niveau)
  on conflict (user_id, jour) do update set niveau = excluded.niveau;

  return query
  select (select m.message from public.session_messages m where m.actif order by random() limit 1),
         v_niveau, v_hier,
         case when v_hier is not null then round(v_niveau - v_hier, 4) end,
         (select s.profils_vus from private.etat_session(u) s),
         (select s.illimite from private.etat_session(u) s);
end $$;

comment on function private.cloturer_session is
  'Cloture positivement la session. Le message varie d''une fois sur l''autre pour ne pas devenir mecanique, et la progression est donnee par rapport au dernier releve, pas depuis le debut.';

-- ---------------------------------------------------------
-- 4. Le quota s'applique a la source
-- ---------------------------------------------------------
create or replace function private.quota_atteint(u uuid)
returns boolean
language sql stable set search_path = public, private as $$
  select not s.illimite and coalesce(s.restants, 1) <= 0
  from private.etat_session(u) s;
$$;

create or replace function private.fil_apprentissage(u uuid, p_taille integer default 20)
returns table (presentation_id bigint, profil_id uuid, prenom text, age integer,
               photo_principale text, profil_verifie boolean,
               ordre_pages public.score_group[], criteres jsonb,
               besoin numeric, attendu numeric, motif text)
language plpgsql set search_path = public, private as $$
declare
  v_eps      numeric := private.taux_exploration(u);
  v_plancher numeric := private.engine_param('expl_plancher_attendu');
  v_retest   numeric := private.engine_param('expl_proba_retest');
  v_mature   boolean := v_eps <= private.engine_param('expl_taux_plancher') + 0.001;
  v_reste    integer;
  v_pool     uuid[];
  r          record;
  v_pid      bigint;
begin
  -- La session s'arrete d'elle-meme : le fil ne sert plus rien
  select s.restants into v_reste from private.etat_session(u) s;
  if v_reste is not null then
    if v_reste <= 0 then return; end if;
    p_taille := least(p_taille, v_reste);
  end if;

  select array_agg(x.id) into v_pool
  from (
    select c.id from public.profiles c
    where c.id <> u and c.is_active
      and exists (select 1 from public.profile_vectors v where v.user_id = c.id)
      and not public.are_blocked(u, c.id)
      and not exists (select 1 from public.swipe_decisions s
                      where s.user_id = u and s.target_id = c.id
                        and s.contexte = 'mieux_me_connaitre')
    order by random() limit greatest(p_taille * 10, 200)
  ) x;

  if v_pool is null then return; end if;

  for r in
    select p.id, p.prenom, h.age, h.photo_principale, h.profil_verifie,
           e.besoin, e.attendu, e.inedit
    from private.evaluer_candidats(u, v_pool) e
    join public.profiles p on p.id = e.profil_id
    cross join lateral private.profile_header(p.id) h
    where not (v_mature and e.attendu < v_plancher and random() > v_retest)
    order by v_eps * (e.besoin + e.inedit) / 2 + (1 - v_eps) * e.attendu + random() * 0.12 desc
    limit p_taille
  loop
    v_pid := private.preparer_presentation(u, r.id, 'mieux_me_connaitre');
    return query
      select v_pid, r.id, r.prenom, r.age, r.photo_principale, r.profil_verifie,
             pp.ordre_pages, pp.criteres, r.besoin, r.attendu,
             case when r.inedit > 0.3 then 'criteres inedits'
                  when r.besoin  > 0.6 then 'critere mal connu'
                  when r.attendu > 0.7 then 'forte affinite attendue'
                  else 'equilibrage' end
      from public.profile_presentations pp where pp.id = v_pid;
  end loop;
end $$;

-- ---------------------------------------------------------
-- 5. Wrappers publics
-- ---------------------------------------------------------
create or replace function public.etat_session()
returns table (profils_vus integer, quota integer, restants integer,
               illimite boolean, niveau numeric)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.etat_session(auth.uid());
end $$;

create or replace function public.cloturer_session()
returns table (message text, niveau numeric, niveau_hier numeric,
               progression numeric, profils_vus integer, illimite boolean)
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.cloturer_session(auth.uid());
end $$;

revoke all on function public.etat_session() from public;
revoke all on function public.cloturer_session() from public;
grant execute on function public.etat_session() to authenticated;
grant execute on function public.cloturer_session() to authenticated;;
