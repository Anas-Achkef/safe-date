-- =========================================================
-- M14 - Profils fictifs de mise au point
--
-- Ces profils vivent dans la base de production : sans marqueur,
-- ils deviennent en quelques mois indiscernables des vrais, et
-- plus personne n'ose les supprimer.
--
-- Le marqueur permet de les compter, de les exclure d'une
-- statistique, et de tout effacer d'une seule instruction.
-- =========================================================

alter table public.profiles
  add column if not exists is_fictif boolean not null default false;

comment on column public.profiles.is_fictif is
  'Profil genere pour la mise au point du moteur. A exclure de toute mesure d''usage reel, et a supprimer avant ouverture au public.';

create index if not exists profiles_fictifs on public.profiles (is_fictif) where is_fictif;

-- Archetypes : des personnes coherentes, pas du bruit.
--
-- Des reponses tirees au hasard produiraient des scores convergeant vers une
-- moyenne, et l'on conclurait a tort que le moteur ne discrimine rien. Les
-- correlations que le moteur cherche doivent exister dans les donnees.
create table if not exists public.test_archetypes (
  id          smallint generated always as identity primary key,
  nom         text not null,
  genre       smallint not null,            -- 0 homme, 1 femme, 2 non-binaire
  recherche   smallint[] not null,          -- options de genre_rech
  age_min     smallint not null,
  age_max     smallint not null,
  intentions  public.rencontre_type[] not null default array['amour']::public.rencontre_type[],
  -- Reponses caracteristiques : {clé_critère: [options]}. Les critères
  -- absents seront tires au sort, ce qui produit la variation individuelle.
  reponses    jsonb not null default '{}'::jsonb,
  poids       smallint not null default 1   -- frequence relative dans la population
);

comment on table public.test_archetypes is
  'Personnes types dont les profils fictifs sont declines. Chaque archetype fixe une poignee de reponses structurantes ; le reste varie, ce qui cree des individus distincts partageant une coherence.';;
