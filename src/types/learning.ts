/**
 * Signatures des fonctions RPC de l'onglet « Mieux me connaître ».
 *
 * À fusionner dans `src/types/rpc.ts` : ce fichier suit la même convention,
 * transcription exacte des signatures vérifiées dans le catalogue Postgres,
 * avec les commentaires de contrat que la génération automatique ne produit
 * pas.
 *
 * Rappel de la règle : aucune fonction ne prend l'identifiant de
 * l'utilisateur courant en paramètre, elle le lit dans auth.uid().
 */

import type { ScoreGroup } from './rpc';

/* -------------------------------------------------------------------------- */
/*  Enums Postgres                                                            */
/* -------------------------------------------------------------------------- */

/**
 * Contexte d'un swipe. La conséquence en dépend entièrement : en
 * apprentissage un refus n'écarte personne, en rencontre il écarte 30 jours.
 */
export type SwipeContexte = 'mieux_me_connaitre' | 'partir_en_date';

export type RencontreType = 'amour' | 'amitie' | 'fun';

export type FocusContext =
  | 'swipe'
  | 'profil'
  | 'conversation'
  | 'decision_date'
  | 'etablissement'
  | 'erreur_prediction'
  | 'question_intermediaire';

/* -------------------------------------------------------------------------- */
/*  Fil d'apprentissage                                                       */
/* -------------------------------------------------------------------------- */

/** Un critère retenu par le moteur pour cette présentation précise. */
export interface CritereAffiche {
  cle: string;
  phrase: string;
}

/**
 * `fil_apprentissage(taille integer DEFAULT 20) -> TABLE(...)`
 *
 * Ni distance, ni type de rencontre, ni disponibilité : un profil est retenu
 * pour ce qu'il apprend au moteur, pas parce qu'on pourrait le rencontrer.
 *
 * `presentation_id` doit impérativement être renvoyé au moment du swipe :
 * c'est lui qui fait foi sur ce qui a été montré. Sans lui, le moteur ne peut
 * ni déduire les critères exposés, ni calculer les pages ignorées.
 */
export interface CarteApprentissage {
  presentation_id: number;
  profil_id: string;
  prenom: string;
  age: number;
  /** Chemin de stockage, à signer avant affichage. */
  photo_principale: string | null;
  profil_verifie: boolean;
  /** Ordre décidé par le moteur, différent d'un profil à l'autre. */
  ordre_pages: ScoreGroup[];
  /** Clés « valeurs » et « mode_vie ». La page photos n'a pas de texte. */
  criteres: Partial<Record<Exclude<ScoreGroup, 'physique'>, CritereAffiche[]>>;
  /** Ce que le moteur ignore encore sur les critères portés par ce profil. */
  besoin: number | null;
  /** Probabilité d'acceptation estimée. 0,5 signifie « je ne sais pas ». */
  attendu: number | null;
  /** Raison de la sélection, à usage de mise au point uniquement. */
  motif: string;
}

/* -------------------------------------------------------------------------- */
/*  Swipe                                                                     */
/* -------------------------------------------------------------------------- */

/** Détail par page, transmis avec la décision. */
export interface DureeEcran {
  ecran: ScoreGroup;
  duree_ms: number;
  consultations: number;
}

/**
 * `enregistrer_swipe(...) -> uuid`
 *
 * Renvoie l'identifiant d'une sollicitation si le moteur décide d'en poser
 * une, sinon `null`. Le détail comportemental est facultatif : sans lui le
 * swipe reste valide, simplement moins informatif. Ne jamais transmettre de
 * zéros à la place de mesures absentes — zéro signifierait « aucune
 * attention », ce qui est faux : on ne sait pas.
 */
export interface EnregistrerSwipeArgs {
  cible: string;
  garder: boolean;
  contexte: SwipeContexte;
  signal_fort?: boolean;
  ecran?: ScoreGroup | null;
  duree_ms?: number | null;
  ecrans?: DureeEcran[] | null;
  ordre_consultation?: ScoreGroup[] | null;
  retours?: number;
  criteres_exposes?: string[] | null;
  criteres_consultes?: string[] | null;
  type_rencontre?: RencontreType | null;
  presentation_id?: number | null;
}

/* -------------------------------------------------------------------------- */
/*  Sollicitations                                                            */
/* -------------------------------------------------------------------------- */

/**
 * Une option de réponse. Les questions du questionnaire portent un `idx`
 * numérique ; les Focus sur erreur de prédiction portent une `cle` textuelle
 * de catégorie.
 */
export type OptionFocus =
  | { idx: number; label: string }
  | { cle: string; label: string };

/**
 * `focus_en_attente() -> TABLE(...)`
 *
 * Une seule sollicitation à la fois, jamais deux.
 *
 * `direction` distingue les deux natures de question : « self » porte sur
 * l'utilisateur, « pref » sur ce qu'il recherche. Les deux sont totalement
 * indépendantes — ne pas fumer et accepter un fumeur n'a rien de
 * contradictoire — et aucune correction croisée ne doit être faite.
 */
export interface Sollicitation {
  focus_id: string;
  contexte: FocusContext;
  criterion_key: string | null;
  direction: 'self' | 'pref' | null;
  question: string;
  intitule: string;
  multi: boolean;
  options: OptionFocus[] | null;
}

/* -------------------------------------------------------------------------- */
/*  Session                                                                   */
/* -------------------------------------------------------------------------- */

/** `etat_session() -> TABLE(...)` */
export interface EtatSession {
  profils_vus: number;
  quota: number;
  /** Nul lorsque l'utilisateur n'a aucune limite. */
  restants: number | null;
  illimite: boolean;
  /** Confiance globale du moteur, entre 0 et 1. */
  niveau: number;
}

/**
 * `cloturer_session() -> TABLE(...)`
 *
 * `niveau` n'est ni un score de qualité ni un compteur de réponses : c'est la
 * confiance du moteur. Une baisse n'est pas une régression, elle signifie
 * qu'il doit revérifier certaines préférences.
 */
export interface FinDeSession {
  message: string;
  niveau: number;
  niveau_hier: number | null;
  progression: number | null;
  profils_vus: number;
  illimite: boolean;
}
