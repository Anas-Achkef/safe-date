import type { DiscoveryEntry } from '../api/discovery';
import type { ProfileHeader } from '../types/rpc';

/**
 * Jeu de données de prévisualisation.
 *
 * Il n'existe que pour juger l'interface sans authentification. Il couvre
 * volontairement le cas que la base ne produit pas encore avec le compte de
 * développement : un profil au-delà du seuil premium, dont le back-end renvoie
 * prénom, photo et scores à `null`.
 */

export const PREVIEW_DISCOVERY: DiscoveryEntry[] = [
  {
    candidate_id: 'd0000000-0000-4000-8000-000000000003',
    prenom: 'Inès',
    age: 31,
    photo: null,
    verifie: true,
    score_global: 43.8,
    score_physique: 18.2,
    score_valeurs: 50,
    score_mode_vie: 55,
    score_aller: 39.8,
    score_retour: 47.8,
    criteres_evalues: 21,
    filtres_ok: true,
    affichable: true,
    au_dela_du_seuil: false,
    highlights: [
      { groupe: 'valeurs', question: 'Je suis sensible aux critiques :', reponse: 'Non' },
      { groupe: 'mode_vie', question: 'Mon usage des écrans :', reponse: 'Intensif (Téléphone)' },
      { groupe: 'mode_vie', question: 'Avec mon argent, je suis :', reponse: 'Dépensier' },
    ],
    visible: true,
    hiddenReason: null,
  },
  {
    candidate_id: 'd0000000-0000-4000-8000-000000000001',
    prenom: 'Camille',
    age: 34,
    photo: null,
    verifie: true,
    score_global: 40.5,
    score_physique: 27.3,
    score_valeurs: 25,
    score_mode_vie: 67.5,
    score_aller: 33.1,
    score_retour: 47.8,
    criteres_evalues: 21,
    filtres_ok: true,
    affichable: true,
    au_dela_du_seuil: false,
    highlights: [
      { groupe: 'mode_vie', question: 'Mon usage des écrans :', reponse: 'Intensif (Téléphone)' },
      { groupe: 'mode_vie', question: 'Mon réseau pro est important :', reponse: 'Non' },
      { groupe: 'mode_vie', question: 'Avec mon argent, je suis :', reponse: 'Économe' },
    ],
    visible: true,
    hiddenReason: null,
  },
  {
    candidate_id: 'd0000000-0000-4000-8000-000000000002',
    prenom: 'Théo',
    age: 28,
    photo: null,
    verifie: true,
    score_global: 43.8,
    score_physique: 18.2,
    score_valeurs: 50,
    score_mode_vie: 55,
    score_aller: 42,
    score_retour: 45.5,
    criteres_evalues: 21,
    filtres_ok: false,
    affichable: false,
    au_dela_du_seuil: false,
    highlights: [],
    visible: false,
    hiddenReason: 'filters',
  },
  // Au-dela du seuil premium : le back-end masque tout en base.
  {
    candidate_id: 'e1000000-0000-4000-8000-000000000012',
    prenom: null,
    age: null,
    photo: null,
    verifie: true,
    score_global: null,
    score_physique: null,
    score_valeurs: null,
    score_mode_vie: null,
    score_aller: null,
    score_retour: null,
    criteres_evalues: null,
    filtres_ok: true,
    affichable: false,
    au_dela_du_seuil: true,
    highlights: [],
    visible: false,
    hiddenReason: 'premium',
  },
];

export const PREVIEW_PROFILE_HEADER: ProfileHeader = {
  age: 33,
  photo_principale: null,
  profil_verifie: true,
  connaissance: 62,
  est_premium: false,
};
