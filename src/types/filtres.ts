/**
 * Les filtres de recherche.
 *
 * Le vocabulaire suit ce que font les grandes applications — genre, âge,
 * distance, vérification pour la base ; taille, tabac, alcool, enfants,
 * langues pour les filtres avancés, réservés aux abonnés comme chez Bumble.
 *
 * Deux ajouts propres à Safe Date : l'intention, qui dit ce qu'on cherche
 * vraiment, et la compatibilité minimale, qui n'a de sens que parce que le
 * produit calcule un score.
 */

export type Genre = 'femme' | 'homme' | 'non_binaire';

/**
 * Ce que la personne cherche.
 *
 * `sans_lendemain` est le libellé retenu pour ce que l'on nomme familièrement
 * autrement : c'est le terme employé par les applications francophones, il dit
 * la même chose sans être vulgaire dans une interface.
 */
export type Intention = 'serieux' | 'leger' | 'sans_lendemain' | 'amitie' | 'indecis';

export type Frequence = 'jamais' | 'occasionnel' | 'regulier';
export type Enfants = 'aucun' | 'en_a' | 'en_veut' | 'nen_veut_pas';

export interface Filtres {
  genres: Genre[];
  ageMin: number;
  ageMax: number;
  rayonKm: number;
  scoreMin: number;
  verifiesSeulement: boolean;
  intentions: Intention[];
  /** Filtres avancés — réservés aux abonnés. */
  tailleMin: number;
  tailleMax: number;
  tabac: Frequence[];
  alcool: Frequence[];
  enfants: Enfants[];
}

export const FILTRES_PAR_DEFAUT: Filtres = {
  genres: [],
  ageMin: 18,
  ageMax: 60,
  rayonKm: 25,
  scoreMin: 0,
  verifiesSeulement: false,
  intentions: [],
  tailleMin: 150,
  tailleMax: 200,
  tabac: [],
  alcool: [],
  enfants: [],
};

export const LIBELLE_GENRE: Record<Genre, string> = {
  femme: 'Femmes',
  homme: 'Hommes',
  non_binaire: 'Non-binaires',
};

export const LIBELLE_INTENTION: Record<Intention, string> = {
  serieux: 'Une relation sérieuse',
  leger: 'Une histoire légère',
  sans_lendemain: 'Sans lendemain',
  amitie: 'Une amitié',
  indecis: 'Je verrai bien',
};

export const LIBELLE_FREQUENCE: Record<Frequence, string> = {
  jamais: 'Jamais',
  occasionnel: 'Occasionnellement',
  regulier: 'Régulièrement',
};

export const LIBELLE_ENFANTS: Record<Enfants, string> = {
  aucun: 'Sans enfant',
  en_a: 'En a déjà',
  en_veut: 'En veut',
  nen_veut_pas: 'N’en veut pas',
};

/** Nombre de critères réellement posés, pour la pastille du bouton. */
export function compterFiltres(f: Filtres): number {
  const d = FILTRES_PAR_DEFAUT;
  let n = 0;
  if (f.genres.length) n += 1;
  if (f.ageMin !== d.ageMin || f.ageMax !== d.ageMax) n += 1;
  if (f.rayonKm !== d.rayonKm) n += 1;
  if (f.scoreMin !== d.scoreMin) n += 1;
  if (f.verifiesSeulement) n += 1;
  if (f.intentions.length) n += 1;
  if (f.tailleMin !== d.tailleMin || f.tailleMax !== d.tailleMax) n += 1;
  if (f.tabac.length) n += 1;
  if (f.alcool.length) n += 1;
  if (f.enfants.length) n += 1;
  return n;
}
