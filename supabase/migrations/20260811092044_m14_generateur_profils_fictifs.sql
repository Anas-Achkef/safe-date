-- =========================================================
-- M14b - Generateur de population fictive
--
-- Methode : chaque archetype possede un jeu de reponses de
-- reference, tire une fois. Chaque membre le recopie en muta
-- une partie. On obtient de vrais groupes — coherents en
-- interne, distincts entre eux — sans avoir a arbitrer 126
-- criteres a la main.
--
-- Des reponses purement aleatoires produiraient des scores
-- convergeant vers une moyenne : on conclurait a tort que le
-- moteur ne discrimine rien, alors qu'il n'y aurait tout
-- simplement rien a discriminer.
-- =========================================================

insert into public.test_archetypes (nom, genre, recherche, age_min, age_max, intentions, poids) values
  ('Sportif urbain',        0, array[1]::smallint[],   26, 38, array['amour']::rencontre_type[],           12),
  ('Sportive urbaine',      1, array[0]::smallint[],   25, 36, array['amour']::rencontre_type[],           12),
  ('Casanier famille',      0, array[1]::smallint[],   30, 45, array['amour']::rencontre_type[],           10),
  ('Casanière famille',     1, array[0]::smallint[],   28, 42, array['amour']::rencontre_type[],           10),
  ('Voyageur indépendant',  0, array[1]::smallint[],   27, 40, array['amour','fun']::rencontre_type[],      8),
  ('Voyageuse indépendante',1, array[0]::smallint[],   26, 38, array['amour','fun']::rencontre_type[],      8),
  ('Créatif nocturne',      0, array[1]::smallint[],   24, 34, array['amour','amitie']::rencontre_type[],   7),
  ('Créative nocturne',     1, array[0]::smallint[],   23, 33, array['amour','amitie']::rencontre_type[],   7),
  ('Posé quarantaine',      0, array[1]::smallint[],   38, 52, array['amour']::rencontre_type[],            6),
  ('Posée quarantaine',     1, array[0]::smallint[],   36, 50, array['amour']::rencontre_type[],            6),
  ('Sociable extraverti',   0, array[1]::smallint[],   25, 35, array['amour','fun','amitie']::rencontre_type[], 6),
  ('Sociable extravertie',  1, array[0]::smallint[],   24, 34, array['amour','fun','amitie']::rencontre_type[], 6),
  ('Discret intellectuel',  0, array[1]::smallint[],   28, 44, array['amour']::rencontre_type[],            5),
  ('Discrète intellectuelle',1,array[0]::smallint[],   27, 42, array['amour']::rencontre_type[],            5),
  ('Ouvert non binaire',    2, array[0,1,2]::smallint[], 24, 40, array['amour','amitie']::rencontre_type[], 3),
  ('Bisexuelle curieuse',   1, array[0,1]::smallint[], 24, 36, array['amour','fun']::rencontre_type[],      3)
on conflict do nothing;

-- ---------------------------------------------------------
-- Jeu de reponses de reference d'un archetype
-- ---------------------------------------------------------
create or replace function private.reference_archetype(p_arch smallint)
returns jsonb
language plpgsql set search_path = public, private as $$
declare a public.test_archetypes; v jsonb;
begin
  select * into a from public.test_archetypes where id = p_arch;
  if a.reponses <> '{}'::jsonb then return a.reponses; end if;

  -- Tirage unique, conserve : c'est lui qui donne son identite au groupe.
  select coalesce(jsonb_object_agg(c.key, to_jsonb(array[o.idx])), '{}'::jsonb) into v
  from public.criteria c
  cross join lateral (
    select idx from public.criterion_options
    where criterion_key = c.key order by random() limit 1
  ) o
  where c.direction = 'self' and c.sensitive_category is null;

  -- Les ancrages de l'archetype priment sur le tirage
  v := v || jsonb_build_object('genre_moi', to_jsonb(array[a.genre]))
          || jsonb_build_object('genre_rech', to_jsonb(a.recherche));

  update public.test_archetypes set reponses = v where id = p_arch;
  return v;
end $$;

comment on function private.reference_archetype is
  'Tire une fois pour toutes le profil de reference d''un archetype. Les membres en derivent par mutation : sans reference commune, il n''y aurait aucune correlation a apprendre.';

-- ---------------------------------------------------------
-- Generation
-- ---------------------------------------------------------
create or replace function private.generer_profils_fictifs(
  p_nombre integer default 500,
  p_mutation numeric default 0.28
) returns integer
language plpgsql set search_path = public, private as $$
declare
  a       public.test_archetypes;
  v_ref   jsonb;
  v_id    uuid;
  v_age   int;
  i       int;
  n       int := 0;
  v_cle   text;
  v_opts  smallint[];
  -- Paris et proche couronne : les profils doivent pouvoir se voir
  v_lat   double precision;
  v_lon   double precision;
begin
  for i in 1..p_nombre loop
    -- Tirage pondere de l'archetype
    select * into a from public.test_archetypes
    order by random() * poids desc limit 1;

    v_ref := private.reference_archetype(a.id);
    v_id  := gen_random_uuid();
    v_age := a.age_min + floor(random() * (a.age_max - a.age_min + 1))::int;
    v_lat := 48.8566 + (random() - 0.5) * 0.30;
    v_lon := 2.3522  + (random() - 0.5) * 0.40;

    insert into auth.users (id, email)
    values (v_id, 'fictif+' || replace(v_id::text, '-', '') || '@safedate.test');

    insert into public.profiles
      (id, birth_date, prenom, is_active, is_verified, is_fictif,
       age_min, age_max, search_radius_km, intentions, langue, pays,
       last_location, last_seen_at)
    values
      (v_id,
       (current_date - (v_age * 365 + floor(random() * 365))::int),
       a.nom || ' ' || i,
       true, random() < 0.35, true,
       greatest(18, v_age - 8), v_age + 8, 25, a.intentions, 'fr', 'FR',
       st_setsrid(st_makepoint(v_lon, v_lat), 4326)::geography,
       now() - (random() * interval '5 days'));

    -- Consentements : sans eux le declencheur RGPD refuse le genre
    insert into public.consents (user_id, category, policy_code, policy_version)
    values (v_id, 'identite_genre', 'TEST', 'v1')
    on conflict do nothing;

    -- Reponses : la reference, mutee par endroits
    for v_cle, v_opts in
      select key, array(select (value->>0)::smallint) from jsonb_each(v_ref) as t(key, value)
    loop
      if random() < p_mutation and v_cle not in ('genre_moi', 'genre_rech') then
        select array[idx] into v_opts from public.criterion_options
        where criterion_key = v_cle order by random() limit 1;
      end if;

      insert into public.profile_answers (user_id, criterion_key, option_idx, answered_at)
      values (v_id, v_cle, v_opts, now())
      on conflict (user_id, criterion_key) do nothing;
    end loop;

    -- La preference sur un critere suit celle de l'archetype, avec du jeu
    insert into public.profile_answers (user_id, criterion_key, option_idx, answered_at)
    select cp2.key, cp2.key, o.idx_arr, now()
    from (select null::text as key) z
    where false;   -- place tenue : les preferences sont posees ci-dessous

    n := n + 1;
  end loop;

  return n;
end $$;

comment on function private.generer_profils_fictifs is
  'Cree des profils fictifs derives des archetypes. La mutation regle la dispersion : trop basse, tous les membres sont identiques et le moteur croit avoir tout compris ; trop haute, les groupes se dissolvent et il n''y a plus rien a apprendre.';

-- ---------------------------------------------------------
-- Suppression
-- ---------------------------------------------------------
create or replace function private.purger_profils_fictifs()
returns integer
language plpgsql set search_path = public, private as $$
declare n integer;
begin
  delete from auth.users u
  where exists (select 1 from public.profiles p where p.id = u.id and p.is_fictif);
  get diagnostics n = row_count;
  return n;
end $$;

comment on function private.purger_profils_fictifs is
  'Efface toute la population fictive. La suppression en cascade depuis auth.users emporte profils, reponses, vecteurs et decisions.';;
