import type { Enfants, Frequence, Genre, Intention } from '../types/filtres';
import { PERSONNES } from './personnes';

/**
 * Les attributs de recherche des personnes de démonstration.
 *
 * Ils ne vivent pas dans `personnes.ts` : le constructeur y est positionnel et
 * l'ajout de six colonnes rendrait les vingt-quatre appels illisibles. Le
 * genre est déclaré, le reste se dérive de l'identifiant — comme les dégradés
 * d'avatar, de façon stable d'une session à l'autre.
 *
 * En conditions réelles, ces champs viendront de `profiles` : aucune colonne
 * de `candidate_cards` ne les porte aujourd'hui.
 */

const GENRES: Record<string, Genre> = {
  Camille: 'femme', Inès: 'femme', Léa: 'femme', Nour: 'femme', Salomé: 'femme',
  Jeanne: 'femme', Aya: 'femme', Elsa: 'femme', Farah: 'femme', Manon: 'femme',
  Chloé: 'femme',
  Théo: 'homme', Marius: 'homme', Adrien: 'homme', Rémi: 'homme', Yanis: 'homme',
  Malo: 'homme', Basile: 'homme', Tom: 'homme', Gaspard: 'homme', Nathan: 'homme',
  Victor: 'homme',
  Lou: 'non_binaire', Sacha: 'non_binaire',
};

const INTENTIONS: Intention[] = ['serieux', 'leger', 'sans_lendemain', 'amitie', 'indecis'];
const FREQUENCES: Frequence[] = ['jamais', 'occasionnel', 'regulier'];
const ENFANTS: Enfants[] = ['aucun', 'en_a', 'en_veut', 'nen_veut_pas'];

export interface AttributsRecherche {
  genre: Genre;
  intention: Intention;
  tailleCm: number;
  tabac: Frequence;
  alcool: Frequence;
  enfants: Enfants;
  distanceKm: number;
}

/** Entier stable tiré d'une chaîne, décalé pour varier d'un champ à l'autre. */
function graine(id: string, decalage: number): number {
  let h = decalage * 2_654_435_761;
  for (let i = 0; i < id.length; i += 1) h = (h * 31 + id.charCodeAt(i)) >>> 0;
  return h;
}

const table = new Map<string, AttributsRecherche>();

for (const p of PERSONNES) {
  const genre = GENRES[p.prenom] ?? 'non_binaire';
  // « à moins de 7 km » → 7. Le libellé reste la source, il n'y a pas de
  // colonne numérique dans le jeu de démonstration.
  const km = Number(p.distance.match(/(\d+)/)?.[1] ?? 25);

  table.set(p.id, {
    genre,
    intention: INTENTIONS[graine(p.id, 1) % INTENTIONS.length]!,
    // Fourchettes plausibles, centrées différemment selon le genre déclaré.
    tailleCm:
      (genre === 'homme' ? 168 : genre === 'femme' ? 155 : 160) + (graine(p.id, 2) % 26),
    tabac: FREQUENCES[graine(p.id, 3) % FREQUENCES.length]!,
    alcool: FREQUENCES[graine(p.id, 4) % FREQUENCES.length]!,
    enfants: ENFANTS[graine(p.id, 5) % ENFANTS.length]!,
    distanceKm: km,
  });
}

export function attributsDemo(id: string): AttributsRecherche | null {
  return table.get(id) ?? null;
}
