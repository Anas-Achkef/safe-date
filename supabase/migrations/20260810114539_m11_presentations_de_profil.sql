-- =========================================================
-- M11.1 - La presentation : ce que le moteur a servi
--
-- Distinction essentielle : l'ordre des pages est DECIDE par
-- le moteur, l'ordre de consultation est SUBI par lui. Sans
-- enregistrer le premier, on ne peut pas savoir quelles pages
-- ont ete ignorees ni ce qui a reellement ete montre.
-- =========================================================

create table if not exists public.profile_presentations (
  id            bigint generated always as identity primary key,
  observer_id   uuid not null references public.profiles(id) on delete cascade,
  target_id     uuid not null references public.profiles(id) on delete cascade,
  contexte      public.swipe_contexte not null,
  ordre_pages   public.score_group[] not null,
  criteres      jsonb not null default '{}'::jsonb,
  created_at    timestamptz not null default now(),
  constraint presentations_trois_pages check (cardinality(ordre_pages) = 3),
  constraint presentations_pas_soi_meme check (observer_id <> target_id)
);
alter table public.profile_presentations enable row level security;

create index if not exists presentations_observateur
  on public.profile_presentations (observer_id, created_at desc);

comment on table public.profile_presentations is
  'Une ligne par profil servi. Le meme profil peut etre presente differemment a deux personnes : l''ordre des pages et les criteres retenus dependent de ce que le moteur cherche a apprendre de l''observateur.';
comment on column public.profile_presentations.ordre_pages is
  'Ordre decide par le moteur, jamais fixe. Faire varier l''ordre n''est pas un choix d''interface : c''est ce qui permet de distinguer une page ignoree d''une page simplement placee en dernier.';
comment on column public.profile_presentations.criteres is
  'Criteres retenus par page. Ce qui n''y figure pas n''a pas ete montre et ne peut donc pas avoir influence la decision.';

alter table public.swipe_decisions
  add column if not exists presentation_id  bigint references public.profile_presentations(id) on delete set null,
  add column if not exists pages_ignorees   public.score_group[],
  add column if not exists vitesse_ms_page  integer;

comment on column public.swipe_decisions.pages_ignorees is
  'Pages servies mais jamais ouvertes. Un refus prononce apres avoir seulement regarde les photos ne dit pas la meme chose qu''un refus apres avoir tout lu.';
comment on column public.swipe_decisions.vitesse_ms_page is
  'Temps moyen par page consultee. Une navigation tres rapide affaiblit la valeur de tout signal tire de cette consultation.';

-- ---------------------------------------------------------
-- Preparer une presentation
-- ---------------------------------------------------------
create or replace function private.preparer_presentation(
  u uuid, cible uuid, p_contexte public.swipe_contexte default 'mieux_me_connaitre'
) returns bigint
language plpgsql set search_path = public, private as $$
declare
  v_ordre public.score_group[];
  v_crit  jsonb;
  v_id    bigint;
begin
  -- Ordre tire au sort a chaque presentation (§4.4)
  select array_agg(g order by random()) into v_ordre
  from unnest(array['physique','valeurs','mode_vie']::public.score_group[]) g;

  -- Criteres portes par la cible, ranges par page.
  -- La selection intelligente et le plafond de 8 a 12 arrivent
  -- a l'etape suivante : ici on enregistre ce qui est montre.
  select coalesce(jsonb_object_agg(grp, cles), '{}'::jsonb) into v_crit
  from (
    select cp.grp::text as grp, jsonb_agg(pa.criterion_key order by pa.criterion_key) as cles
    from public.profile_answers pa
    join public.criteria c on c.key = pa.criterion_key and c.direction = 'self'
    join public.criterion_pairs cp on cp.pair_key = c.pair_key
    where pa.user_id = cible and cp.grp <> 'physique'
    group by cp.grp
  ) x;

  insert into public.profile_presentations (observer_id, target_id, contexte, ordre_pages, criteres)
  values (u, cible, p_contexte, v_ordre, v_crit)
  returning id into v_id;

  return v_id;
end $$;

comment on function private.preparer_presentation is
  'Fige ce qui va etre montre avant que l''utilisateur ne le voie. Sans cette trace prealable, une modification du profil cible rendrait la decision passee inexplicable.';

-- ---------------------------------------------------------
-- Le fil sert des presentations, plus seulement des profils
-- ---------------------------------------------------------
drop function if exists public.fil_apprentissage(integer);
drop function if exists private.fil_apprentissage(uuid, integer);

create function private.fil_apprentissage(u uuid, p_taille integer default 20)
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
  v_pool     uuid[];
  r          record;
  v_pid      bigint;
begin
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

comment on function private.fil_apprentissage is
  'Ni distance, ni type de rencontre, ni disponibilite : un profil est retenu pour ce qu''il apprend au moteur. Chaque profil servi produit une presentation, dont l''ordre des pages varie a dessein.';

create function public.fil_apprentissage(taille integer default 20)
returns table (presentation_id bigint, profil_id uuid, prenom text, age integer,
               photo_principale text, profil_verifie boolean,
               ordre_pages public.score_group[], criteres jsonb,
               besoin numeric, attendu numeric, motif text)
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.fil_apprentissage(auth.uid(), taille);
end $$;

revoke all on function public.fil_apprentissage(integer) from public;
grant execute on function public.fil_apprentissage(integer) to authenticated;;
