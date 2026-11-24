import { photoDemo } from './photos';
import type { DiscoveryEntry } from '../api/discovery';
import type { DemandeRecue } from '../types/conversations';
import type { CarteApprentissage, EtatSession, FinDeSession } from '../types/learning';
import type { ProfileHeader, ProfileSection } from '../types/rpc';
import { ORDRES_PAGES, PERSONNES, type Personne } from './personnes';

/**
 * Donnees de demonstration, derivees de `personnes.ts`.
 *
 * Un meme profil garde son prenom, son age et son visuel d'un onglet a
 * l'autre : c'est ce qui donne l'impression d'une application peuplee plutot
 * que d'ecrans juxtaposes.
 */

/* -------------------------------------------------------------------------- */
/*  Decouverte                                                                */
/* -------------------------------------------------------------------------- */

/**
 * Les quatre meilleurs scores passent derriere le voile premium.
 *
 * C'est la logique de la base : `au_dela_du_seuil` vaut
 * `score_global >= seuil_premium`. Ce sont donc les profils les plus
 * compatibles qui sont reserves, pas les moins bons — c'est ce qui donne sa
 * force a l'argument d'abonnement.
 *
 * Nuance par rapport au back-end actuel : `candidate_cards` met aujourd'hui
 * *tous* les champs a `null` au-dela du seuil, score compris. L'ecran a besoin
 * de conserver le pourcentage pour donner envie — il faudra que la fonction
 * continue d'exposer `score_global` meme masque.
 */
const MASQUES = new Set(
  [...PERSONNES].sort((a, b) => b.score - a.score).slice(0, 4).map((p) => p.id),
);

function versDecouverte(x: Personne): DiscoveryEntry {
  const masque = MASQUES.has(x.id);
  return {
    candidate_id: x.id,
    prenom: masque ? null : x.prenom,
    age: masque ? null : x.age,
    photo: masque ? null : photoDemo(x.id),
    verifie: x.verifie,
    score_global: x.score,
    score_physique: masque ? null : x.physique,
    score_valeurs: masque ? null : x.valeurs,
    score_mode_vie: masque ? null : x.modeVie,
    score_aller: masque ? null : x.aller,
    score_retour: masque ? null : x.retour,
    criteres_evalues: masque ? null : x.criteres,
    filtres_ok: true,
    affichable: !masque,
    au_dela_du_seuil: masque,
    highlights: masque
      ? []
      : [
          { groupe: 'valeurs', question: x.phrasesValeurs[0], reponse: 'En commun' },
          { groupe: 'mode_vie', question: x.phrasesModeVie[0], reponse: 'En commun' },
          {
            groupe: 'valeurs',
            question: x.phrasesValeurs[1] ?? x.phrasesModeVie[1] ?? '',
            reponse: 'Proche',
          },
        ],
    visible: !masque,
    hiddenReason: masque ? 'premium' : null,
  };
}

export const PREVIEW_DISCOVERY: DiscoveryEntry[] = PERSONNES.map(versDecouverte).sort((a, b) => {
  if (a.visible !== b.visible) return a.visible ? -1 : 1;
  return (b.score_global ?? -1) - (a.score_global ?? -1);
});

/* -------------------------------------------------------------------------- */
/*  Mieux me connaitre                                                        */
/* -------------------------------------------------------------------------- */

export const PREVIEW_LEARNING: CarteApprentissage[] = PERSONNES.map((x, i) => ({
  presentation_id: 1000 + i,
  profil_id: x.id,
  prenom: x.prenom,
  age: x.age,
  photo_principale: photoDemo(x.id),
  profil_verifie: x.verifie,
  ordre_pages: ORDRES_PAGES[i % ORDRES_PAGES.length],
  criteres: {
    valeurs: x.phrasesValeurs.map((phrase, j) => ({ cle: `${x.id}-v${j}`, phrase })),
    mode_vie: x.phrasesModeVie.map((phrase, j) => ({ cle: `${x.id}-m${j}`, phrase })),
  },
  // Le moteur sait deja beaucoup sur les premiers, moins sur les suivants.
  besoin: Number((0.2 + ((i * 7) % 10) / 14).toFixed(2)),
  attendu: Number((0.35 + ((i * 5) % 11) / 20).toFixed(2)),
  motif: 'demonstration',
}));

export const PREVIEW_SESSION: EtatSession = {
  profils_vus: 6,
  quota: 40,
  restants: 34,
  illimite: false,
  niveau: 0.62,
};

export const PREVIEW_FIN_SESSION: FinDeSession = {
  message: 'Vous en avez vu assez pour aujourd’hui. Le moteur affine vos préférences.',
  niveau: 0.62,
  niveau_hier: 0.57,
  progression: 0.05,
  profils_vus: 40,
  illimite: false,
};

/* -------------------------------------------------------------------------- */
/*  Discussions                                                               */
/* -------------------------------------------------------------------------- */

const TYPES = ['amour', 'amitie', 'fun'] as const;

/** Cinq demandes : deux deja ouvertes avec leur delai, trois encore fermees. */
export const PREVIEW_INBOX: DemandeRecue[] = PERSONNES.slice(0, 5).map((x, i) => ({
  demande_id: `demande-${i}`,
  emetteur: x.id,
  prenom: x.prenom,
  age: x.age,
  photo_principale: photoDemo(x.id),
  profil_verifie: x.verifie,
  type_rencontre: TYPES[i % TYPES.length],
  compat_rate: x.score,
  ecran_ordre: ORDRES_PAGES[i % ORDRES_PAGES.length],
  ecran_vignette: ORDRES_PAGES[i % ORDRES_PAGES.length][0],
  distance: x.distance,
  statut: 'en_attente',
  // Une demande non ouverte n'a pas de compte a rebours : c'est l'ouverture
  // qui le declenche.
  secondes_restantes: i < 2 ? [7200, 129600][i] : null,
  reportable: i !== 1,
}));

/* -------------------------------------------------------------------------- */
/*  Profil                                                                    */
/* -------------------------------------------------------------------------- */

export const PREVIEW_PROFILE_HEADER: ProfileHeader = {
  age: 33,
  // Le profil de l'utilisateur lui-meme : sa photo suit la meme regle que
  // celle des autres, avec « moi » pour graine.
  photo_principale: photoDemo('moi'),
  profil_verifie: true,
  connaissance: 62,
  est_premium: false,
};

/* -------------------------------------------------------------------------- */
/*  Mon profil                                                                */
/* -------------------------------------------------------------------------- */

/**
 * Prenom et bio de l'utilisateur.
 *
 * Ni l'un ni l'autre n'existe aujourd'hui : `profiles` n'a pas de colonne de
 * biographie, et `profile_header()` ne renvoie pas le prenom du proprietaire
 * du compte. Ces deux valeurs sont propres a la demonstration — il faudra les
 * exposer cote base pour que l'ecran fonctionne en conditions reelles.
 */
export const PREVIEW_MON_PRENOM = 'Alex';

export const PREVIEW_BIO =
  'Je cuisine mieux que je ne range. Je marche beaucoup, je parle trop, et ' +
  'je préfère un long dîner à une soirée entière. Dites-moi ce qui vous ' +
  'tient à cœur, je saurai quoi en faire.';

/** Ce que le moteur a retenu de mes reponses, en phrases. */
export const PREVIEW_MES_SECTIONS: ProfileSection[] = [
  { section: 'valeurs', ord: 1, pair_key: 'v_loyaute', phrase: 'Place la loyauté au-dessus du reste' },
  { section: 'valeurs', ord: 2, pair_key: 'v_franchise', phrase: 'Préfère une vérité rugueuse à un silence confortable' },
  { section: 'valeurs', ord: 3, pair_key: 'v_temps', phrase: 'Croit que la confiance se construit lentement' },
  { section: 'mode_vie', ord: 1, pair_key: 'm_cuisine', phrase: 'Cuisine presque tous les soirs' },
  { section: 'mode_vie', ord: 2, pair_key: 'm_marche', phrase: 'Se déplace à pied dès que c’est possible' },
  { section: 'mode_vie', ord: 3, pair_key: 'm_matin', phrase: 'Se lève tôt, même le week-end' },
  { section: 'physique', ord: 1, pair_key: 'p_sport', phrase: 'Sportif sans être compétiteur' },
];

/** Centres d'interet, tels qu'ils s'afficheraient en pastilles. */
export const PREVIEW_INTERETS = [
  'Cuisine', 'Randonnée', 'Cinéma', 'Vin nature', 'Photographie', 'Marchés',
];

/**
 * Rayon de recherche affiche par l'ecran Parcourir.
 *
 * `profiles.search_radius_km` existe en base, mais `profile_header()` ne le
 * renvoie pas : l'application n'a aucun moyen de le lire aujourd'hui. Il
 * faudrait l'ajouter aux colonnes de cette fonction.
 */
export const PREVIEW_RAYON_KM = 25;
