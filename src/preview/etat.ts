import type { DiscoveryEntry } from '../api/discovery';
import { distanceMetres, SEUIL_REVELATION_M, type Coordonnees } from '../lib/geo';
import type {
  ChatRequestStatus,
  DateIntent,
  DemandeRecue,
  EtatConversation,
  Message,
  ResumeConversation,
  ResumeRendezVous,
} from '../types/conversations';
import type { Establishment } from '../types/rpc';
import type {
  CarteApprentissage,
  EtatSession,
  FinDeSession,
  Sollicitation,
} from '../types/learning';
import { PERSONNES, type Personne } from './personnes';
import { photoDemo } from './photos';
import {
  PREVIEW_DISCOVERY,
  PREVIEW_FIN_SESSION,
  PREVIEW_INBOX,
  PREVIEW_LEARNING,
  PREVIEW_SESSION,
} from './fixtures';

/**
 * Etat mutable de la demonstration.
 *
 * Sans lui, le mode apercu servirait indefiniment les memes donnees : un
 * profil ecarte reviendrait au rechargement suivant, une demande acceptee
 * resterait en attente. Les gestes n'auraient aucune consequence, et cela se
 * verrait immediatement.
 *
 * L'etat vit en memoire, le temps de la session : recharger la page remet
 * tout a zero, ce qui est le comportement voulu pour une demonstration qu'on
 * rejoue plusieurs fois.
 *
 * Ce module n'est lu que lorsque `isPreviewMode` est vrai. En fonctionnement
 * normal, rien ici n'est atteint.
 */

/* -------------------------------------------------------------------------- */
/*  Decouverte                                                                */
/* -------------------------------------------------------------------------- */

const tranchees = new Set<string>();

export function decouverte(): DiscoveryEntry[] {
  return PREVIEW_DISCOVERY.filter((e) => !tranchees.has(e.candidate_id));
}

export function noterDecision(candidateId: string): void {
  tranchees.add(candidateId);
}

/**
 * Reciprocite d'un interet, en demonstration.
 *
 * Deterministe et volontairement rare : environ un profil sur trois. Un coup
 * de coeur a chaque geste ne dirait plus rien, et une demonstration ou il
 * n'arrive jamais ne montrerait pas l'ecran.
 */
export function reciprocite(candidateId: string): boolean {
  let somme = 0;
  for (let i = 0; i < candidateId.length; i += 1) {
    somme = (somme + candidateId.charCodeAt(i) * (i + 1)) % 9973;
  }
  return somme % 3 === 0;
}

/* -------------------------------------------------------------------------- */
/*  Mieux me connaitre                                                        */
/* -------------------------------------------------------------------------- */

const vus = new Set<string>();
let sollicitation: Sollicitation | null = null;

/**
 * Sollicitations posees au fil des swipes.
 *
 * Le moteur en pose une de temps en temps, pas a chaque geste : une question
 * a chaque profil transformerait le fil en questionnaire.
 */
const SOLLICITATIONS: Sollicitation[] = [
  {
    focus_id: 'focus-1',
    contexte: 'swipe',
    criterion_key: 'fin_comport_moi',
    direction: 'self',
    question: 'Avec mon argent, je suis plutôt :',
    intitule: 'Une question rapide',
    multi: false,
    options: [
      { idx: 0, label: 'Économe' },
      { idx: 1, label: 'Équilibré' },
      { idx: 2, label: 'Dépensier' },
    ],
  },
  {
    focus_id: 'focus-2',
    contexte: 'erreur_prediction',
    criterion_key: null,
    direction: null,
    question: 'Qu’est-ce qui vous a fait hésiter sur ce profil ?',
    intitule: 'Aidez le moteur',
    multi: false,
    options: [
      { cle: 'photo', label: 'Les photos' },
      { cle: 'valeurs', label: 'Les valeurs' },
      { cle: 'mode_vie', label: 'Le mode de vie' },
      { cle: 'rien', label: 'Rien de précis' },
    ],
  },
  {
    focus_id: 'focus-3',
    contexte: 'question_intermediaire',
    criterion_key: 'sorties_moi',
    direction: 'pref',
    question: 'Chez l’autre, je préfère :',
    intitule: 'Une question rapide',
    multi: false,
    options: [
      { idx: 0, label: 'Quelqu’un de casanier' },
      { idx: 1, label: 'Un juste milieu' },
      { idx: 2, label: 'Quelqu’un qui sort beaucoup' },
    ],
  },
];

export function filApprentissage(taille: number): CarteApprentissage[] {
  return PREVIEW_LEARNING.filter((c) => !vus.has(c.profil_id)).slice(0, taille);
}

/** Enregistre un swipe et decide s'il declenche une sollicitation. */
export function noterSwipe(profilId: string): string | null {
  vus.add(profilId);
  // Une sollicitation tous les trois profils, tant qu'il en reste.
  if (vus.size % 3 === 0 && !sollicitation) {
    const suivante = SOLLICITATIONS[Math.floor(vus.size / 3 - 1) % SOLLICITATIONS.length];
    sollicitation = suivante;
    return suivante.focus_id;
  }
  return null;
}

export function sollicitationEnAttente(): Sollicitation | null {
  return sollicitation;
}

export function repondreSollicitation(): void {
  sollicitation = null;
}

export function etatSession(): EtatSession {
  const restants = Math.max(0, PREVIEW_SESSION.quota - vus.size);
  return { ...PREVIEW_SESSION, profils_vus: vus.size, restants };
}

export function finDeSession(): FinDeSession {
  return { ...PREVIEW_FIN_SESSION, profils_vus: vus.size };
}

/* -------------------------------------------------------------------------- */
/*  Discussions                                                               */
/* -------------------------------------------------------------------------- */

let demandes: DemandeRecue[] = PREVIEW_INBOX.map((d) => ({ ...d }));

export function boiteReception(): DemandeRecue[] {
  // Une demande tranchee quitte la boite : c'est ce que fait le serveur.
  return demandes.filter((d) => d.statut === 'en_attente');
}

/**
 * Ouvrir une demande demarre son compte a rebours.
 *
 * C'est la regle du produit : tant qu'on n'a pas regarde, rien ne court.
 */
export function ouvrirDemande(demandeId: string): ChatRequestStatus {
  demandes = demandes.map((d) =>
    d.demande_id === demandeId && d.secondes_restantes === null
      ? { ...d, secondes_restantes: 172800 }
      : d,
  );
  return 'en_attente';
}

export function repondreDemande(demandeId: string, reponse: DateIntent): ChatRequestStatus {
  const statut: ChatRequestStatus =
    reponse === 'oui' ? 'acceptee' : reponse === 'non' ? 'refusee' : 'reportee';
  const cible = demandes.find((d) => d.demande_id === demandeId);
  demandes = demandes.map((d) => (d.demande_id === demandeId ? { ...d, statut } : d));
  if (statut === 'acceptee' && cible) ouvrirConversationDepuis(cible);
  return statut;
}

/** Nombre de demandes acceptees, pour un eventuel compteur d'ecran. */
export function acceptees(): number {
  return demandes.filter((d) => d.statut === 'acceptee').length;
}

/* -------------------------------------------------------------------------- */
/*  Conversations                                                             */
/* -------------------------------------------------------------------------- */

/** Identifiant de l'utilisateur en demonstration. */
export const MOI = 'moi';

interface Fil {
  resume: ResumeConversation;
  messages: Message[];
}

const horodatage = (minutesAvant: number) =>
  new Date(Date.now() - minutesAvant * 60_000).toISOString();

let compteur = 0;
const msg = (conv: string, de: string, corps: string, minutes: number): Message => ({
  id: `m-${(compteur += 1)}`,
  conversation_id: conv,
  sender_id: de,
  kind: 'texte',
  body: corps,
  audio_path: null,
  duration_ms: null,
  created_at: horodatage(minutes),
});

function fil(
  id: string,
  p: Personne,
  statut: ResumeConversation['statut'],
  enLigne: boolean,
  nonLus: number,
  secondes: number | null,
  echanges: [string, string, number][],
): Fil {
  const messages = echanges.map(([de, corps, min]) =>
    msg(id, de === 'moi' ? MOI : p.id, corps, min),
  );
  const dernier = messages[messages.length - 1];
  return {
    resume: {
      conversation_id: id,
      autre: p.id,
      prenom_autre: p.prenom,
      age_autre: p.age,
      photo_autre: photoDemo(p.id),
      autre_en_ligne: enLigne,
      statut,
      dernier_message: dernier?.body ?? null,
      dernier_au: dernier?.created_at ?? null,
      non_lus: nonLus,
      secondes_restantes: secondes,
    },
    messages,
  };
}

const P = (i: number) => PERSONNES[i];

let fils: Fil[] = [
  fil('conv-1', P(18), 'active', true, 2, 82800, [
    ['autre', 'Bonsoir Alex. Votre phrase sur la confiance qui se construit lentement m’a arrêté.', 240],
    ['moi', 'Merci. C’est une des rares choses dont je suis certain.', 232],
    ['autre', 'On m’a souvent reproché l’inverse — de décider trop vite.', 210],
    ['autre', 'Vous cuisinez vraiment tous les soirs ?', 12],
    ['moi', 'Presque. Ce soir c’était des pâtes, je ne vais pas mentir.', 9],
    ['autre', 'C’est déjà mieux que moi. Vous seriez libre jeudi ?', 4],
  ]),
  fil('conv-2', P(19), 'active', false, 0, 43200, [
    ['moi', 'Bonjour Lou. Le théâtre, c’est depuis longtemps ?', 1500],
    ['autre', 'Depuis mes douze ans. C’est ce qui m’a appris à écouter, bizarrement.', 1440],
    ['moi', 'Ça se voit dans vos réponses.', 1380],
  ]),
  fil('conv-3', P(2), 'prete', false, 1, 172800, [
    ['autre', 'Bonjour. On a le même rapport aux trajectoires différentes, apparemment.', 60],
  ]),
];

export function mesConversations(): ResumeConversation[] {
  return fils.map((f) => f.resume);
}

export function etatConversation(id: string): EtatConversation | null {
  const f = fils.find((x) => x.resume.conversation_id === id);
  if (!f) return null;
  return {
    statut: f.resume.statut,
    autre: f.resume.autre,
    prenom_autre: f.resume.prenom_autre,
    autre_en_ligne: f.resume.autre_en_ligne,
    secondes_restantes: f.resume.secondes_restantes,
    message:
      f.resume.statut === 'prete'
        ? 'La conversation est ouverte. À vous d’écrire le premier message.'
        : null,
  };
}

export function messages(id: string): Message[] {
  return fils.find((x) => x.resume.conversation_id === id)?.messages ?? [];
}

/** Ouvrir un fil marque ses messages comme lus. */
export function marquerLu(id: string): void {
  fils = fils.map((f) =>
    f.resume.conversation_id === id ? { ...f, resume: { ...f.resume, non_lus: 0 } } : f,
  );
}

export function envoyerMessage(id: string, corps: string): string {
  const envoye = msg(id, MOI, corps, 0);
  fils = fils.map((f) =>
    f.resume.conversation_id === id
      ? {
          ...f,
          messages: [...f.messages, envoye],
          resume: {
            ...f.resume,
            statut: 'active',
            dernier_message: corps,
            dernier_au: envoye.created_at,
            non_lus: 0,
          },
        }
      : f,
  );
  return envoye.id;
}

/**
 * Accepter une demande ouvre une conversation.
 *
 * C'est ce qui relie les deux moities de l'onglet : sans cela, une demande
 * acceptee disparaitrait sans rien produire.
 */
function ouvrirConversationDepuis(demande: DemandeRecue): void {
  const personne = PERSONNES.find((p) => p.id === demande.emetteur);
  if (!personne || fils.some((f) => f.resume.autre === demande.emetteur)) return;
  fils = [
    fil(`conv-${demande.demande_id}`, personne, 'prete', false, 0, 172800, [
      ['autre', 'Merci d’avoir accepté. Par quoi commence-t-on ?', 0],
    ]),
    ...fils,
  ];
}

/* -------------------------------------------------------------------------- */
/*  Rendez-vous                                                               */
/* -------------------------------------------------------------------------- */

const dansDesHeures = (h: number) => new Date(Date.now() + h * 3_600_000).toISOString();

/**
 * Les rendez-vous en cours.
 *
 * Aucune adresse n'y figure : le lieu ne se devoile qu'a moins de vingt-cinq
 * metres, c'est le mecanisme central du produit. La liste montre la ville, le
 * creneau et l'autre personne — rien de plus.
 */
let rendezvous: ResumeRendezVous[] = [
  {
    date_id: 'rdv-1',
    autre: PERSONNES[18].id,
    prenom_autre: PERSONNES[18].prenom,
    age_autre: PERSONNES[18].age,
    photo_autre: photoDemo(PERSONNES[18].id),
    statut: 'confirme',
    creneau_debut: dansDesHeures(26),
    ville: 'Genève',
    lieu_devoile: false,
    point_lat: 46.2044,
    point_lon: 6.1432,
    distance_m: 1840,
  },
  {
    date_id: 'rdv-2',
    autre: PERSONNES[19].id,
    prenom_autre: PERSONNES[19].prenom,
    age_autre: PERSONNES[19].age,
    photo_autre: photoDemo(PERSONNES[19].id),
    statut: 'en_preparation',
    creneau_debut: dansDesHeures(74),
    ville: 'Lausanne',
    lieu_devoile: false,
    point_lat: 46.5197,
    point_lon: 6.6323,
    distance_m: 62_000,
  },
];

export function mesRendezVous(): ResumeRendezVous[] {
  // Un rendez-vous annule ou termine quitte la liste des rendez-vous a venir.
  return rendezvous.filter((r) => r.statut !== 'annule' && r.statut !== 'termine');
}

/**
 * Les etablissements, tenus a part des rendez-vous.
 *
 * En conditions reelles ils ne descendent jamais dans l'application avant la
 * revelation : la demonstration reproduit cette separation plutot que de
 * poser l'adresse dans l'objet et de la masquer a l'affichage.
 */
const ETABLISSEMENTS: Record<string, Establishment> = {
  'rdv-1': {
    nom: 'Café des Bastions',
    adresse: '1 promenade des Bastions',
    code_postal: '1205',
    ville: 'Genève',
  },
  'rdv-2': {
    nom: 'Brasserie du Flon',
    adresse: "12 place de l'Europe",
    code_postal: '1003',
    ville: 'Lausanne',
  },
};

/**
 * Revele l'etablissement, en appliquant la meme regle que le back-end.
 *
 * `reveal_establishment` refuse au-dela de vingt-cinq metres : la
 * demonstration refuse aussi, sinon elle montrerait un produit qui n'existe
 * pas. Retourne `null` quand la condition n'est pas remplie.
 */
export function revelerEtablissement(
  dateId: string,
  position: Coordonnees,
): Establishment | null {
  const r = rendezvous.find((x) => x.date_id === dateId);
  if (!r || r.point_lat === null || r.point_lon === null) return null;

  const ecart = distanceMetres(position, { lat: r.point_lat, lon: r.point_lon });
  if (ecart > SEUIL_REVELATION_M) return null;

  rendezvous = rendezvous.map((x) =>
    x.date_id === dateId ? { ...x, lieu_devoile: true } : x,
  );
  return ETABLISSEMENTS[dateId] ?? null;
}

export function annulerRendezVous(dateId: string): void {
  rendezvous = rendezvous.map((r) => (r.date_id === dateId ? { ...r, statut: 'annule' } : r));
}
