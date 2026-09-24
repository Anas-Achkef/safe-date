import type { DiscoveryEntry } from '../api/discovery';

/**
 * Passe-plat entre Découverte et l'écran de coup de cœur.
 *
 * Le problème : au moment où l'on se prononce, le profil quitte le vivier —
 * c'est le comportement voulu, on ne le reverra plus. L'écran de coup de cœur
 * s'ouvre juste après et ne peut donc plus le retrouver en rappelant
 * `loadDiscoveryFeed`. Il afficherait « Cette personne » au lieu du prénom.
 *
 * Les paramètres de route ne conviennent pas : `expo-router` ne transporte
 * que des chaînes, et une URL de photo signée n'a rien à faire dans une barre
 * d'adresse. On dépose donc l'entrée ici avant de naviguer, et l'écran la
 * reprend. Une seule entrée à la fois : il n'y a qu'un coup de cœur à
 * célébrer à la fois, et rien ne doit survivre à la fermeture de l'écran.
 */

let depose: DiscoveryEntry | null = null;

/** Dépose le profil avant de naviguer vers l'écran de coup de cœur. */
export function poser(entree: DiscoveryEntry): void {
  depose = entree;
}

/**
 * Reprend le profil déposé, s'il correspond bien à l'identifiant demandé.
 *
 * Rend `null` quand l'écran est atteint autrement — lien direct, retour
 * arrière, rechargement de page. L'appelant retombe alors sur le vivier, et
 * à défaut sur une formulation qui se passe du prénom.
 */
export function reprendre(id: string): DiscoveryEntry | null {
  return depose?.candidate_id === id ? depose : null;
}
