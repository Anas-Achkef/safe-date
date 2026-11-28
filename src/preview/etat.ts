import type { DiscoveryEntry } from '../api/discovery';
import { distanceMetres, SEUIL_REVELATION_M, type Coordonnees } from '../lib/geo';
import type {
  ChatRequestStatus,
  ConversationStatus,
  DateIntent,
  DemandeRecue,
  EtatConversation,
  Message,
  RejoindreResultat,
  ReponseFin,
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

/**
 * Un fil de demonstration. Le temps y est reel : `finA` est l'instant ou les
 * 5 minutes s'achevent, et le statut en decoule a chaque lecture, comme le
 * ferait le serveur.
 */
interface Fil {
  id: string;
  personne: Personne;
  statut: ConversationStatus;
  enLigne: boolean;
  illimitee: boolean;
  /** Vrai si le prochain `rejoindreConversation` fait partir le chrono. */
  demarrable: boolean;
  finA: number | null;
  decision: ReponseFin | null;
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

const DECOMPTE_S = 3;
const DUREE_S = 300;

function fil(
  id: string,
  personne: Personne,
  etat: Partial<Omit<Fil, 'id' | 'personne' | 'messages'>>,
  echanges: [string, string, number][],
): Fil {
  return {
    id,
    personne,
    statut: 'prete',
    enLigne: false,
    illimitee: false,
    demarrable: false,
    finA: null,
    decision: null,
    ...etat,
    messages: echanges.map(([de, corps, min]) =>
      msg(id, de === 'moi' ? MOI : personne.id, corps, min),
    ),
  };
}

const P = (i: number) => PERSONNES[i];
const dans = (secondes: number) => Date.now() + secondes * 1000;

let fils: Fil[] = [
  // L'autre est la : entrer dans la conversation fait partir le chrono.
  fil('conv-5', P(3), { enLigne: true, demarrable: true }, []),
  fil('conv-1', P(18), { statut: 'active', enLigne: true, finA: dans(240) }, [
    ['autre', 'Bonsoir Alex. Votre phrase sur la confiance qui se construit lentement m’a arrêté.', 3],
    ['moi', 'Merci. C’est une des rares choses dont je suis certain.', 2],
    ['autre', 'Vous cuisinez vraiment tous les soirs ?', 1],
  ]),
  // Presque fini : de quoi voir le temps s'ecouler et la question de fin.
  fil('conv-4', P(5), { statut: 'active', enLigne: true, finA: dans(47) }, [
    ['autre', 'Il nous reste peu de temps, alors je me lance : vous aimez marcher ?', 4],
    ['moi', 'Beaucoup. Surtout le dimanche matin.', 3],
  ]),
  // L'autre n'est pas la : la conversation attend.
  fil('conv-3', P(2), {}, []),
  fil('conv-6', P(7), { statut: 'verrouillee' }, [
    ['moi', 'C’était court mais j’ai bien aimé.', 30],
    ['autre', 'Moi aussi. On verra ce que l’on répond !', 29],
  ]),
  // Rouverte apres un rendez-vous : ni chrono ni verrouillage.
  fil('conv-2', P(19), { statut: 'active', illimitee: true }, [
    ['moi', 'Merci pour hier soir, vraiment.', 1500],
    ['autre', 'Merci à vous. On remet ça la semaine prochaine ?', 1440],
  ]),
];

/** Fait avancer le temps : une conversation dont les 5 minutes sont passees se verrouille. */
function actualiser(f: Fil): Fil {
  if (f.statut === 'active' && !f.illimitee && f.finA !== null && f.finA <= Date.now()) {
    return { ...f, statut: 'verrouillee' };
  }
  return f;
}

function trouver(id: string): Fil | undefined {
  fils = fils.map(actualiser);
  return fils.find((x) => x.id === id);
}

function remplacer(id: string, maj: (f: Fil) => Fil): void {
  fils = fils.map((f) => (f.id === id ? maj(f) : f));
}

function secondesRestantes(f: Fil): number | null {
  if (f.statut !== 'active' || f.illimitee || f.finA === null) return null;
  return Math.max(0, Math.ceil((f.finA - Date.now()) / 1000));
}

const CONSIGNE: Record<ConversationStatus, string> = {
  prete: 'Votre conversation est prête. Nous attendons que vous soyez tous les deux disponibles.',
  active: 'Conversation en cours.',
  verrouillee: 'Le temps est écoulé.',
  cloturee: 'Conversation close.',
};

export function mesConversations(): ResumeConversation[] {
  fils = fils.map(actualiser);
  return fils.map((f) => {
    const dernier = f.messages[f.messages.length - 1];
    return {
      conversation_id: f.id,
      autre: f.personne.id,
      prenom_autre: f.personne.prenom,
      age_autre: f.personne.age,
      photo_autre: photoDemo(f.personne.id),
      autre_en_ligne: f.enLigne,
      statut: f.statut,
      dernier_message: dernier?.body ?? null,
      dernier_au: dernier?.created_at ?? null,
      illimitee: f.illimitee,
      secondes_restantes: secondesRestantes(f),
    };
  });
}

export function etatConversation(id: string): EtatConversation | null {
  const f = trouver(id);
  if (!f) return null;
  return {
    statut: f.statut,
    autre: f.personne.id,
    prenom_autre: f.personne.prenom,
    autre_en_ligne: f.enLigne,
    secondes_restantes: secondesRestantes(f),
    message: f.illimitee ? null : CONSIGNE[f.statut],
    illimitee: f.illimitee,
  };
}

export function rejoindreConversation(id: string): RejoindreResultat | null {
  const f = trouver(id);
  if (!f) return null;
  if (f.statut === 'prete' && f.demarrable) {
    remplacer(id, (x) => ({
      ...x,
      statut: 'active',
      demarrable: false,
      finA: dans(DECOMPTE_S + DUREE_S),
    }));
    return {
      statut: 'active',
      demarree: true,
      attend_qui: null,
      decompte_s: DECOMPTE_S,
      secondes_restantes: DUREE_S,
    };
  }
  return {
    statut: f.statut,
    demarree: false,
    attend_qui: f.statut === 'prete' ? f.personne.id : null,
    decompte_s: 0,
    secondes_restantes: secondesRestantes(f),
  };
}

export function messages(id: string): Message[] {
  return trouver(id)?.messages ?? [];
}

export function envoyerMessage(id: string, corps: string): string {
  const f = trouver(id);
  if (!f || f.statut !== 'active') {
    throw new Error('Cette conversation est verrouillée');
  }
  const envoye = msg(id, MOI, corps, 0);
  remplacer(id, (x) => ({ ...x, messages: [...x.messages, envoye] }));
  return envoye.id;
}

/** En demonstration, l'autre repond toujours « oui ». */
export function deciderConversation(id: string, decision: ReponseFin): void {
  remplacer(id, (x) => ({ ...x, decision }));
}

export function decisionDe(id: string): ReponseFin | null {
  return trouver(id)?.decision ?? null;
}

/**
 * Accepter une demande ouvre une conversation.
 *
 * C'est ce qui relie les deux moities de l'onglet : sans cela, une demande
 * acceptee disparaitrait sans rien produire. L'autre est la : entrer dans la
 * conversation fait partir le chrono.
 */
function ouvrirConversationDepuis(demande: DemandeRecue): void {
  const personne = PERSONNES.find((p) => p.id === demande.emetteur);
  if (!personne || fils.some((f) => f.personne.id === demande.emetteur)) return;
  fils = [fil(`conv-${demande.demande_id}`, personne, { enLigne: true, demarrable: true }, []), ...fils];
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
