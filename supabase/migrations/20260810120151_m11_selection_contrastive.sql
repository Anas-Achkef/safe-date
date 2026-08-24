-- =========================================================
-- M11.5 - Selection contrastive
--
-- Pour savoir si un critere compte, il ne suffit pas
-- d'observer : il faut isoler. Le moteur presente alors des
-- profils aussi semblables que possible, ne differant que
-- sur le critere etudie. Ce n'est plus de l'observation,
-- c'est une experience.
-- =========================================================

alter table public.profile_presentations
  add column if not exists critere_isole text,
  add column if not exists serie_id uuid;

comment on column public.profile_presentations.critere_isole is
  'Critere que cette presentation cherche a isoler. Les profils d''une meme serie ne different volontairement que sur lui.';
comment on column public.profile_presentations.serie_id is
  'Regroupe les presentations d''une meme experience. Sans ce lien, les decisions ne peuvent pas etre comparees entre elles.';

create index if not exists presentations_serie on public.profile_presentations (serie_id)
  where serie_id is not null;

insert into public.engine_params (key, value, description) values
  ('contraste_proba',       0.30, 'Probabilite qu''une page de fil soit consacree a une serie contrastive plutot qu''au classement habituel.'),
  ('contraste_taille',         4, 'Nombre de profils composant une serie contrastive.'),
  ('contraste_conf_max',    0.70, 'Confiance au-dela de laquelle un critere ne merite plus d''etre isole.')
on conflict (key) do nothing;

-- ---------------------------------------------------------
-- 1. Quel critere merite d'etre isole
-- ---------------------------------------------------------
create or replace function private.critere_a_isoler(u uuid)
returns text
language sql stable set search_path = public, private as $$
  select c.key
  from public.criteria c
  join public.criterion_pairs cp on cp.pair_key = c.pair_key
  left join public.user_criterion_profile p on p.user_id = u and p.criterion_key = c.key
  where c.direction = 'self'
    and cp.affichable_apprentissage
    and (private.engine_param('appr_criteres_sensibles') >= 1 or c.sensitive_category is null)
    and coalesce(p.confiance, 0) < private.engine_param('contraste_conf_max')
    -- Il faut au moins deux valeurs distinctes dans le vivier pour contraster
    and (select count(distinct o.idx) from public.profile_answers pa,
                lateral unnest(pa.option_idx) o(idx)
          where pa.criterion_key = c.key) >= 2
  order by (1 - coalesce(p.confiance, 0)) * coalesce(cp.base_weight, 1) desc, random()
  limit 1;
$$;

comment on function private.critere_a_isoler is
  'Retient le critere le plus mal connu parmi les plus structurants, a condition que le vivier contienne au moins deux valeurs differentes : sans variation, aucun contraste n''est possible.';

-- ---------------------------------------------------------
-- 2. Construire la serie
-- ---------------------------------------------------------
create or replace function private.serie_contrastive(u uuid, p_critere text, p_taille integer default 4)
returns table (profil_id uuid, option_idx smallint, ressemblance integer)
language sql stable set search_path = public, private as $$
  with vivier as (
    select c.id
    from public.profiles c
    where c.id <> u and c.is_active
      and not public.are_blocked(u, c.id)
      and not exists (select 1 from public.swipe_decisions s
                      where s.user_id = u and s.target_id = c.id
                        and s.contexte = 'mieux_me_connaitre')
      and exists (select 1 from public.profile_answers pa
                  where pa.user_id = c.id and pa.criterion_key = p_critere)
  ),
  porteurs as (
    select v.id, o.idx
    from vivier v
    join public.profile_answers pa on pa.user_id = v.id and pa.criterion_key = p_critere
    cross join lateral unnest(pa.option_idx) o(idx)
  ),
  -- Un profil sert de reference : les autres sont choisis pour lui ressembler
  pivot as (select id, idx from porteurs order by random() limit 1),
  scores as (
    select p.id, p.idx,
           (select count(*)::int
              from public.profile_answers a
              join public.profile_answers b
                on b.criterion_key = a.criterion_key and b.option_idx && a.option_idx
             where a.user_id = (select id from pivot)
               and b.user_id = p.id
               and a.criterion_key <> p_critere) as ressemblance
    from porteurs p
  ),
  -- Le plus ressemblant pour chaque valeur du critere etudie
  meilleur as (
    select distinct on (idx) id, idx, ressemblance
    from scores order by idx, ressemblance desc, random()
  )
  select id, idx, ressemblance from meilleur
  order by ressemblance desc
  limit p_taille;
$$;

comment on function private.serie_contrastive is
  'Tire un profil de reference au hasard, puis retient pour chaque valeur du critere etudie le profil qui lui ressemble le plus par ailleurs. Les decisions de l''utilisateur deviennent alors attribuables a ce seul critere.';

-- ---------------------------------------------------------
-- 3. Le fil peut servir une serie plutot qu'un classement
-- ---------------------------------------------------------
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
  v_crit     text;
  v_serie    uuid;
  r          record;
  v_pid      bigint;
  v_n        int := 0;
begin
  select s.restants into v_reste from private.etat_session(u) s;
  if v_reste is not null then
    if v_reste <= 0 then return; end if;
    p_taille := least(p_taille, v_reste);
  end if;

  -- Serie contrastive : une experience plutot qu'une simple selection
  if random() < private.engine_param('contraste_proba') then
    v_crit := private.critere_a_isoler(u);
    if v_crit is not null then
      v_serie := gen_random_uuid();
      for r in
        select sc.profil_id as id, p.prenom, h.age, h.photo_principale, h.profil_verifie
        from private.serie_contrastive(u, v_crit,
               least(p_taille, private.engine_param('contraste_taille')::int)) sc
        join public.profiles p on p.id = sc.profil_id
        cross join lateral private.profile_header(p.id) h
      loop
        v_pid := private.preparer_presentation(u, r.id, 'mieux_me_connaitre');
        update public.profile_presentations
           set critere_isole = v_crit, serie_id = v_serie where id = v_pid;
        v_n := v_n + 1;
        return query
          select v_pid, r.id, r.prenom, r.age, r.photo_principale, r.profil_verifie,
                 pp.ordre_pages, pp.criteres, null::numeric, null::numeric,
                 'isolation d''un critère'
          from public.profile_presentations pp where pp.id = v_pid;
      end loop;
      if v_n > 0 then return; end if;
    end if;
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
-- 4. Lire le resultat d'une experience
-- ---------------------------------------------------------
create or replace function private.resultat_serie(p_serie uuid)
returns table (critere text, option_idx smallint, libelle text,
               presentes integer, decides integer, acceptes integer, taux numeric)
language sql stable set search_path = public, private as $$
  select pp.critere_isole, o.idx, co.label,
         count(*)::int,
         count(sd.id)::int,
         count(*) filter (where sd.decision)::int,
         round(count(*) filter (where sd.decision)::numeric / nullif(count(sd.id), 0), 4)
  from public.profile_presentations pp
  join public.profile_answers pa
    on pa.user_id = pp.target_id and pa.criterion_key = pp.critere_isole
  cross join lateral unnest(pa.option_idx) o(idx)
  left join public.criterion_options co
    on co.criterion_key = pp.critere_isole and co.idx = o.idx
  left join public.swipe_decisions sd on sd.presentation_id = pp.id
  where pp.serie_id = p_serie
  group by pp.critere_isole, o.idx, co.label
  order by o.idx;
$$;

comment on function private.resultat_serie is
  'Compare les decisions au sein d''une meme serie. Les profils ne differant que sur le critere isole, l''ecart de taux d''acceptation lui est directement imputable.';;
