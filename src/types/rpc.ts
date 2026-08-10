/**
 * Signatures des fonctions RPC exposees par le back-end.
 *
 * Ces types sont la transcription exacte des signatures verifiees dans le
 * catalogue Postgres (pg_get_function_arguments / pg_get_function_result).
 * Ils doublent volontairement `database.ts`, qui est genere et regenere :
 * ce fichier-ci est la reference lisible cote metier, et il porte les
 * commentaires de contrat que la generation automatique ne peut pas produire.
 *
 * Regle structurante du back-end : aucune fonction ne prend l'identifiant de
 * l'utilisateur courant en parametre. Elle le lit dans auth.uid(). Un
 * parametre `user_id` quelque part signalerait une erreur d'aiguillage.
 */

/* -------------------------------------------------------------------------- */
/*  Enums Postgres                                                            */
/* -------------------------------------------------------------------------- */

export type CollectionMoment = 'onboarding' | 'quiz' | 'backend';

export type ScoreGroup = 'physique' | 'valeurs' | 'mode_vie';

export type SensitiveCategory =
  | 'origine_ethnique'
  | 'convictions_religieuses'
  | 'opinions_politiques'
  | 'orientation_sexuelle'
  | 'sante'
  | 'biometrie'
  | 'geolocalisation'
  | 'identite_genre';

export type DateStatus =
  | 'en_preparation'
  | 'confirme'
  | 'en_cours'
  | 'termine'
  | 'annule';

/* -------------------------------------------------------------------------- */
/*  Parcours d'inscription (9 etapes)                                         */
/* -------------------------------------------------------------------------- */

/** `verify_account_code(code text) -> boolean` */
export type VerifyAccountCodeResult = boolean;

/** `consentements_requis_questionnaire() -> TABLE(...)` */
export interface ConsentementRequis {
  categorie: SensitiveCategory;
  criteres: number;
  accorde: boolean;
}

/** `next_questions(n integer DEFAULT 3) -> TABLE(...)` */
export interface NextQuestion {
  criterion_key: string;
  question: string;
  moment: CollectionMoment;
  grp: ScoreGroup;
  priorite: number;
  motif: string;
}

/**
 * `submit_answer(k text, idx smallint[]) -> void`
 *
 * Seule voie d'ecriture des reponses : `profile_answers` est en select seul,
 * un insert direct echoue sur la RLS.
 */
export interface SubmitAnswerArgs {
  k: string;
  idx: number[];
}

/** `answer_progress() -> TABLE(...)` */
export interface AnswerProgress {
  onboarding_repondus: number;
  onboarding_total: number;
  quiz_repondus: number;
  quiz_total: number;
  paires_completes: number;
  criteres_evaluables: number;
}

/** `user_activation_checklist() -> TABLE(...)` */
export interface ActivationChecklistItem {
  rang: number;
  condition: string;
  satisfaite: boolean;
}

/** `set_geolocation_choice(autorise bool, precise bool, p_code text, p_version text) -> void` */
export interface GeolocationChoiceArgs {
  autorise: boolean;
  precise: boolean;
  p_code: string;
  p_version: string;
}

/** `user_progress() -> TABLE(...)` */
export interface UserProgress {
  etape_courante: number;
  etapes_total: number;
  secondes_restantes: number;
  compte_actif: boolean;
}

/* -------------------------------------------------------------------------- */
/*  Decouverte et compatibilite                                               */
/* -------------------------------------------------------------------------- */

/** `eligible_candidates() -> TABLE(candidate_id uuid)` */
export interface EligibleCandidate {
  candidate_id: string;
}

/**
 * Un des trois criteres qui expliquent le score.
 *
 * `question` porte encore la formulation brute du questionnaire : les 896
 * formulations naturelles restent a fournir. On affiche donc le libelle tel
 * quel, sans tenter de le reecrire cote client.
 */
export interface CandidateHighlight {
  groupe: ScoreGroup;
  question: string;
  reponse: string;
}

/**
 * `candidate_cards() -> TABLE(...)`
 *
 * Appel unique qui remplace l'enchainement `eligible_candidates` puis
 * `compat_score` : une seule requete rapporte tout ce dont l'ecran a besoin.
 *
 * Le voile premium est applique en base : quand `au_dela_du_seuil` vaut vrai
 * et que l'utilisateur n'est pas abonne, `prenom`, `photo` et l'ensemble des
 * scores arrivent a `null`. Tous ces champs sont donc typés nullables, et
 * aucun code d'affichage ne doit supposer qu'un score est present.
 */
export interface CandidateCardRow {
  candidate_id: string;
  prenom: string | null;
  age: number | null;
  photo: string | null;
  verifie: boolean;
  score_global: number | null;
  score_physique: number | null;
  score_valeurs: number | null;
  score_mode_vie: number | null;
  score_aller: number | null;
  score_retour: number | null;
  criteres_evalues: number | null;
  filtres_ok: boolean;
  affichable: boolean;
  au_dela_du_seuil: boolean;
  highlights: CandidateHighlight[] | null;
}

/**
 * `compat_score(autre uuid) -> TABLE(...)`
 *
 * Conserve pour un calcul ponctuel entre deux profils. La decouverte passe
 * desormais par `candidate_cards`.
 *
 * Leve une erreur si `autre` ne figure pas dans `eligible_candidates()`.
 * C'est une protection deliberee, pas un defaut : ne jamais la contourner.
 */
export interface CompatScore {
  filtres_ok: boolean;
  score_global: number;
  score_physique: number;
  score_valeurs: number;
  score_mode_vie: number;
  score_a_vers_b: number;
  score_b_vers_a: number;
  criteres_evalues: number;
  affichable: boolean;
}

/* -------------------------------------------------------------------------- */
/*  Profil personnel                                                          */
/* -------------------------------------------------------------------------- */

/** `profile_header() -> TABLE(...)` — sans parametre : c'est mon propre profil. */
export interface ProfileHeader {
  age: number;
  photo_principale: string | null;
  profil_verifie: boolean;
  connaissance: number;
  est_premium: boolean;
}

/** `profile_sections() -> TABLE(...)` */
export interface ProfileSection {
  section: ScoreGroup;
  ord: number;
  pair_key: string;
  phrase: string;
}

/** `visible_priorities() -> TABLE(...)` */
export interface VisiblePriority {
  rang: number;
  pair_key: string;
  phrase: string;
  verrouille: boolean;
}

/* -------------------------------------------------------------------------- */
/*  Rendez-vous                                                               */
/* -------------------------------------------------------------------------- */

/**
 * `reveal_establishment(d_id uuid, position_actuelle geography) -> TABLE(...)`
 *
 * Leve une erreur tant que l'utilisateur est a plus de 25 m de son point de
 * rendez-vous. C'est le mecanisme central du produit.
 */
export interface Establishment {
  nom: string;
  adresse: string;
  code_postal: string;
  ville: string;
}

