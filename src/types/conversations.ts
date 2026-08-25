/**
 * Module « Conversations ».
 *
 * Transcription des signatures verifiees dans le catalogue Postgres. Comme
 * ailleurs, aucune fonction ne prend l'identifiant de l'utilisateur courant :
 * le back-end le lit dans auth.uid().
 *
 * Le parcours tient en deux machines a etats. Une demande va de `en_attente`
 * vers `acceptee`, `refusee`, `reportee` ou `expiree` ; la conversation qui en
 * nait va de `prete` a `active`, puis `verrouillee` et `cloturee`. Les deux
 * portent un compte a rebours servi par le serveur : rien n'attend
 * indefiniment.
 */

import type { RencontreType } from './learning';
import type { ScoreGroup } from './rpc';

/* -------------------------------------------------------------------------- */
/*  Enums Postgres                                                            */
/* -------------------------------------------------------------------------- */

export type ChatRequestStatus =
  | 'en_attente'
  | 'acceptee'
  | 'refusee'
  | 'reportee'
  | 'expiree';

export type ConversationStatus = 'prete' | 'active' | 'verrouillee' | 'cloturee';

/** Reponse a une demande. `plus_tard` reporte sans fermer la porte. */
export type DateIntent = 'oui' | 'non' | 'plus_tard';

export type MessageKind = 'texte' | 'vocal' | 'photo';

/* -------------------------------------------------------------------------- */
/*  boite_reception()                                                         */
/* -------------------------------------------------------------------------- */

/**
 * Une demande recue, telle que servie par la boite de reception.
 *
 * `ecran_vignette` designe la page a montrer en apercu : le moteur choisit ce
 * qui distingue le mieux ce profil, ce n'est pas toujours la photo.
 */
export interface DemandeRecue {
  demande_id: string;
  emetteur: string;
  prenom: string;
  age: number | null;
  photo_principale: string | null;
  profil_verifie: boolean;
  type_rencontre: RencontreType;
  /** Taux de compatibilite, en pourcentage. `numeric` cote Postgres. */
  compat_rate: number | null;
  ecran_ordre: ScoreGroup[];
  ecran_vignette: ScoreGroup;
  /** Deja formatee par le serveur : « a moins de 5 km », jamais un nombre brut. */
  distance: string | null;
  statut: ChatRequestStatus;
  /** Null quand la demande n'expire plus (deja tranchee). */
  secondes_restantes: number | null;
  reportable: boolean;
}

/* -------------------------------------------------------------------------- */
/*  etat_conversation(conversation uuid)                                      */
/* -------------------------------------------------------------------------- */

export interface EtatConversation {
  statut: ConversationStatus;
  /** Identifiant de l'autre participant. */
  autre: string;
  prenom_autre: string;
  autre_en_ligne: boolean;
  secondes_restantes: number | null;
  /** Consigne du serveur a afficher tel quel, ou `null`. */
  message: string | null;
}

/* -------------------------------------------------------------------------- */
/*  public.messages                                                           */
/* -------------------------------------------------------------------------- */

/**
 * Un message du fil. La table est lue directement : la policy `p_msg_partie`
 * n'expose que les conversations dont on est partie. L'ecriture, elle, passe
 * obligatoirement par `envoyer_message` — `p_msg_envoi` en est le seul point
 * d'entree.
 */
export interface Message {
  id: string;
  conversation_id: string;
  sender_id: string;
  kind: MessageKind;
  body: string | null;
  /** Chemin de stockage, a signer avant lecture. */
  audio_path: string | null;
  duration_ms: number | null;
  created_at: string;
}

/** Arguments d'envoi. `body` pour le texte, `audio_path` + duree pour le vocal. */
export interface EnvoyerMessageArgs {
  conversation_id: string;
  kind?: MessageKind;
  body?: string | null;
  media?: string | null;
  duree_ms?: number | null;
}
