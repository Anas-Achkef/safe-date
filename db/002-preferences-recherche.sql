-- =====================================================================
-- 002 — Préférences de recherche
--
-- PROPOSITION. Ne pas appliquer depuis une session d'assistance.
--
-- ⚠ AVERTISSEMENT À LIRE AVANT D'EXÉCUTER QUOI QUE CE SOIT ⚠
--
-- Ce fichier ajoute des colonnes à `profiles`, dont deux relèvent de
-- l'article 9 du RGPD — les données que l'on ne traite qu'à titre exceptionnel.
--
--   * `genre` et `genres_recherches` : croisés, ils révèlent l'orientation
--     sexuelle. Un homme qui déclare chercher des hommes a livré une donnée
--     de l'article 9, qu'il l'ait formulée ainsi ou non.
--   * `enfants` touche à la vie familiale ; `tabac` et `alcool` approchent la
--     donnée de santé.
--
-- Le schéma anticipe déjà ce problème : l'énumération `sensitive_category`
-- contient `orientation_sexuelle` et `identite_genre`, et la table
-- `sensitive_access_log` existe pour tracer les accès. Ces colonnes doivent
-- donc entrer dans cette mécanique — journalisation des lectures, base légale
-- documentée, minimisation — et non arriver comme des colonnes ordinaires.
--
-- La partie « filtres » de l'interface fonctionne sans elles : âge, distance
-- et vérification sont déjà en base. C'est le reste qui coûte cher
-- juridiquement, pour un gain produit qu'il faut peser.
--
-- Vérifié contre le schéma déployé — `profiles` porte DÉJÀ :
--   age_min, age_max, search_radius_km, is_verified, is_premium, prenom,
--   birth_date, last_location, geoloc_precise, langue, pays
-- Autrement dit, quatre des filtres de base n'ont besoin d'AUCUNE migration.
-- =====================================================================


-- ---------------------------------------------------------------------
-- ÉTAPE 1 — Ce qui ne demande aucune colonne nouvelle
--
-- Lire et écrire les préférences déjà présentes. À appliquer seul, si l'on
-- veut avancer sans ouvrir le dossier de l'article 9.
-- ---------------------------------------------------------------------
create or replace function public.mes_preferences_recherche()
returns table (
  "ageMin"             integer,
  "ageMax"             integer,
  "rayonKm"            integer,
  "verifiesSeulement"  boolean
)
language sql
stable
security invoker
set search_path = public
as $$
  select p.age_min, p.age_max, p.search_radius_km, false
  from public.profiles as p
  where p.id = auth.uid();
$$;

revoke all on function public.mes_preferences_recherche() from public;
grant execute on function public.mes_preferences_recherche() to authenticated;


-- L'objet JSON reprend les noms du client pour éviter une table de
-- correspondance de plus. Les bornes sont contraintes ici ET par la table :
-- une valeur aberrante envoyée par un client modifié ne doit pas passer.
create or replace function public.enregistrer_preferences_recherche(preferences jsonb)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_age_min integer := coalesce((preferences ->> 'ageMin')::integer, 18);
  v_age_max integer := coalesce((preferences ->> 'ageMax')::integer, 99);
  v_rayon   integer := coalesce((preferences ->> 'rayonKm')::integer, 25);
begin
  if v_age_min < 18 then
    raise exception 'age_min ne peut pas descendre sous 18 ans'
      using errcode = 'check_violation';
  end if;

  if v_age_max < v_age_min then
    raise exception 'age_max doit être supérieur ou égal à age_min'
      using errcode = 'check_violation';
  end if;

  update public.profiles
     set age_min          = v_age_min,
         age_max          = least(v_age_max, 120),
         search_radius_km = greatest(1, least(v_rayon, 300))
   where id = auth.uid();

  if not found then
    raise exception 'aucun profil pour la session en cours'
      using errcode = 'insufficient_privilege';
  end if;
end;
$$;

revoke all on function public.enregistrer_preferences_recherche(jsonb) from public;
grant execute on function public.enregistrer_preferences_recherche(jsonb) to authenticated;


-- ---------------------------------------------------------------------
-- ÉTAPE 2 — Les colonnes sensibles
--
-- À N'APPLIQUER qu'après décision explicite sur la base légale, et après
-- avoir branché la journalisation dans `sensitive_access_log`.
-- Laissé en commentaire volontairement : ce n'est pas à un assistant de
-- décider qu'une application collecte l'orientation sexuelle.
-- ---------------------------------------------------------------------
--
-- create type public.genre_profil     as enum ('femme', 'homme', 'non_binaire');
-- create type public.intention_profil as enum ('serieux', 'leger',
--                                              'sans_lendemain', 'amitie',
--                                              'indecis');
--
-- alter table public.profiles
--   add column genre               public.genre_profil,
--   add column genres_recherches   public.genre_profil[]     not null default '{}',
--   add column intention           public.intention_profil,
--   add column intentions_cherchees public.intention_profil[] not null default '{}';
--
-- comment on column public.profiles.genres_recherches is
--   'DONNÉE ARTICLE 9 RGPD — révèle l''orientation sexuelle une fois croisée '
--   'avec genre. Toute lecture doit être tracée dans sensitive_access_log.';
