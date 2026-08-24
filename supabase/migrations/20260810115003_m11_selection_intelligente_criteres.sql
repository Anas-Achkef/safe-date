-- =========================================================
-- M11.2 - Selection intelligente des criteres affiches
--
-- Un profil n'expose pas tout : entre 8 et 12 criteres,
-- choisis pour ce qu'ils apprennent a CET observateur.
-- Deux personnes voient donc le meme profil differemment.
-- =========================================================

alter table public.criterion_pairs
  add column if not exists affichable_apprentissage boolean not null default true;

comment on column public.criterion_pairs.affichable_apprentissage is
  'Faux pour les criteres exclus de l''onglet d''apprentissage : taille, poids, profession, religion, niveau d''etudes, opinions politiques. Ils restent exploitables par le moteur pour formuler des questions, et redeviennent visibles dans Partir en date, ou les profils sont presentes en entier.';

update public.criterion_pairs set affichable_apprentissage = false
where pair_key in ('phys_taille','phys_poids','val_etudes','val_religion','val_politique')
   or exists (select 1 from public.criteria c
              where c.pair_key = criterion_pairs.pair_key
                and c.sensitive_category in ('convictions_religieuses','opinions_politiques'));

insert into public.engine_params (key, value, description) values
  ('present_criteres_min',  8, 'Nombre minimal de criteres affiches sur un profil en apprentissage.'),
  ('present_criteres_max', 12, 'Nombre maximal de criteres affiches sur un profil en apprentissage. Au-dela, la lecture cesse d''etre rapide et le profil devient un formulaire.'),
  ('present_part_valeurs', 0.5, 'Part visee de criteres issus des valeurs, le reste venant du mode de vie.')
on conflict (key) do nothing;

-- ---------------------------------------------------------
-- Valeur d'apprentissage d'un critere pour un observateur
-- ---------------------------------------------------------
create or replace function private.interet_criteres(u uuid, cible uuid)
returns table (criterion_key text, pair_key text, grp public.score_group,
               phrase text, interet numeric)
language sql stable set search_path = public, private as $$
  select c.key, cp.pair_key, cp.grp,
         ps.phrase,
         round(
           -- Ce que le moteur ignore encore pese le plus
           (1 - coalesce(pr.confiance, 0)) * 0.6
           -- Une option jamais rencontree apporte une information neuve
           + (case when coalesce(os.observations, 0) = 0 then 1 else 0 end) * 0.25
           -- A ignorance egale, un critere structurant passe devant
           + coalesce(cp.base_weight, 0) / nullif((select max(base_weight) from public.criterion_pairs), 0) * 0.15
         , 4)
  from public.profile_answers pa
  join public.criteria c on c.key = pa.criterion_key and c.direction = 'self'
  join public.criterion_pairs cp on cp.pair_key = c.pair_key
  left join lateral private.profile_sections(cible) ps on ps.pair_key = cp.pair_key
  left join public.user_criterion_profile pr on pr.user_id = u and pr.criterion_key = c.key
  left join lateral (
    select min(coalesce(s.observations, 0)) as observations
    from unnest(pa.option_idx) o(idx)
    left join public.user_option_stats s
           on s.user_id = u and s.criterion_key = c.key and s.option_idx = o.idx
  ) os on true
  where pa.user_id = cible
    and cp.affichable_apprentissage          -- rubriques interdites en apprentissage
    and cp.grp <> 'physique'                 -- le physique se lit sur la photo
    and ps.phrase is not null;               -- rien a montrer sans phrase naturelle
$$;

comment on function private.interet_criteres is
  'Classe les criteres d''un profil selon ce qu''ils apprendraient a cet observateur precis. La selection n''est jamais aleatoire et n''est jamais la meme d''un observateur a l''autre.';

-- ---------------------------------------------------------
-- Preparation d'une presentation : 8 a 12 criteres retenus
-- ---------------------------------------------------------
create or replace function private.preparer_presentation(
  u uuid, cible uuid, p_contexte public.swipe_contexte default 'mieux_me_connaitre'
) returns bigint
language plpgsql set search_path = public, private as $$
declare
  v_ordre public.score_group[];
  v_min   int := private.engine_param('present_criteres_min')::int;
  v_max   int := private.engine_param('present_criteres_max')::int;
  v_part  numeric := private.engine_param('present_part_valeurs');
  v_n     int;
  v_nv    int;
  v_crit  jsonb;
  v_id    bigint;
begin
  select array_agg(g order by random()) into v_ordre
  from unnest(array['physique','valeurs','mode_vie']::public.score_group[]) g;

  -- Le nombre exact depend de ce qui reste a apprendre : un profil
  -- mal connu justifie d'en montrer davantage.
  select least(v_max, greatest(v_min,
           round(v_min + (v_max - v_min) * coalesce(avg(interet), 0.5))::int))
    into v_n
  from private.interet_criteres(u, cible);

  v_nv := round(v_n * v_part);

  with classe as (
    select ic.*, row_number() over (partition by ic.grp order by ic.interet desc, random()) as rang
    from private.interet_criteres(u, cible) ic
  ),
  retenus as (
    select * from classe
    where (grp = 'valeurs'  and rang <= v_nv)
       or (grp = 'mode_vie' and rang <= v_n - v_nv)
  )
  select coalesce(jsonb_object_agg(grp, items), '{}'::jsonb) into v_crit
  from (
    select grp::text as grp,
           jsonb_agg(jsonb_build_object('cle', criterion_key, 'phrase', phrase)
                     order by interet desc) as items
    from retenus group by grp
  ) x;

  insert into public.profile_presentations (observer_id, target_id, contexte, ordre_pages, criteres)
  values (u, cible, p_contexte, v_ordre, v_crit)
  returning id into v_id;

  return v_id;
end $$;

comment on function private.preparer_presentation is
  'Fige avant affichage l''ordre des pages et les criteres retenus. Les rubriques exclues de l''apprentissage ne sont jamais servies ici, meme si le profil les renseigne.';

-- ---------------------------------------------------------
-- Les criteres exposes se lisent desormais dans une structure
-- ---------------------------------------------------------
create or replace function private.cles_presentation(p_presentation bigint)
returns text[]
language sql stable set search_path = public, private as $$
  select array_agg(item->>'cle')
  from public.profile_presentations p,
       lateral jsonb_each(p.criteres) e,
       lateral jsonb_array_elements(e.value) item
  where p.id = p_presentation;
$$;;
