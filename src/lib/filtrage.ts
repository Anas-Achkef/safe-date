import type { DiscoveryEntry } from '../api/discovery';
import type { Enfants, Filtres, Frequence, Genre, Intention } from '../types/filtres';

/**
 * Les attributs qu'un profil doit porter pour être filtré finement.
 *
 * `candidate_cards` n'en renvoie aucun aujourd'hui. La fonction est passée en
 * paramètre plutôt qu'importée pour que cette couche ne dépende ni du mode
 * démonstration, ni d'une future RPC : elle filtre ce qu'on lui donne.
 */
export interface AttributsProfil {
  genre: Genre;
  intention: Intention;
  tailleCm: number;
  tabac: Frequence;
  alcool: Frequence;
  enfants: Enfants;
  distanceKm: number;
}

export type LecteurAttributs = (candidateId: string) => AttributsProfil | null;

/**
 * Applique les filtres à une liste de profils.
 *
 * Le filtrage devrait se faire en base : c'est elle qui sait tout, et elle
 * évite de rapatrier des profils pour les jeter. Tant que la RPC
 * `update_search_preferences` n'existe pas, on filtre ici ce que les données
 * permettent — âge, vérification, score — et le reste via `lecteur`.
 *
 * Un critère qu'on ne peut pas évaluer ne rejette jamais : mieux vaut montrer
 * un profil de trop que prétendre un filtre appliqué qui ne l'est pas.
 */
export function filtrerProfils(
  profils: DiscoveryEntry[],
  f: Filtres,
  lecteur?: LecteurAttributs,
): DiscoveryEntry[] {
  return profils.filter((p) => {
    if (p.age !== null && (p.age < f.ageMin || p.age > f.ageMax)) return false;
    if (f.verifiesSeulement && !p.verifie) return false;
    if (f.scoreMin > 0 && (p.score_global ?? 0) < f.scoreMin) return false;

    const a = lecteur?.(p.candidate_id);
    if (!a) return true;

    if (a.distanceKm > f.rayonKm) return false;
    if (f.genres.length > 0 && !f.genres.includes(a.genre)) return false;
    if (f.intentions.length > 0 && !f.intentions.includes(a.intention)) return false;
    if (a.tailleCm < f.tailleMin || a.tailleCm > f.tailleMax) return false;
    if (f.tabac.length > 0 && !f.tabac.includes(a.tabac)) return false;
    if (f.alcool.length > 0 && !f.alcool.includes(a.alcool)) return false;
    if (f.enfants.length > 0 && !f.enfants.includes(a.enfants)) return false;

    return true;
  });
}
