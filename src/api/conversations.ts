import { signPhotoPaths } from '../lib/storage';
import { supabase } from '../lib/supabase';
import type {
  ResumeConversation,
  ChatRequestStatus,
  DateIntent,
  DemandeRecue,
  EnvoyerMessageArgs,
  EtatConversation,
  Message,
  MessageKind,
} from '../types/conversations';
import type { RencontreType } from '../types/learning';
import type { ScoreGroup } from '../types/rpc';
import { toApiError } from './errors';
import { demo, isPreviewMode } from '../preview';

/**
 * Onglet « Conversations ».
 *
 * Une demande precede toujours un echange : personne n'ecrit a quelqu'un qui
 * ne l'a pas accepte. Le serveur tient les etats et les delais ; l'application
 * se contente de les afficher et de transmettre les gestes de l'utilisateur.
 */

/** Postgres renvoie des `numeric` : on normalise sans ecraser les `null`. */
function num(value: number | null | undefined): number | null {
  if (value === null || value === undefined) return null;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

/* -------------------------------------------------------------------------- */
/*  Boite de reception                                                        */
/* -------------------------------------------------------------------------- */

/**
 * Charge les demandes recues et signe les photos.
 *
 * Les demandes expirees restent servies un temps : c'est au serveur de decider
 * quand elles disparaissent, pas a l'ecran de les filtrer.
 */
export async function loadInbox(): Promise<DemandeRecue[]> {
  if (isPreviewMode) return demo.boiteReception();
  const { data, error } = await (supabase.rpc as any)('boite_reception');
  if (error) throw toApiError(error, 'Chargement des demandes');

  const rows = (data ?? []) as DemandeRecue[];
  if (rows.length === 0) return [];

  const signed = await signPhotoPaths(
    rows
      .map((row) => row.photo_principale)
      .filter((path): path is string => Boolean(path)),
  );

  return rows.map((row) => ({
    ...row,
    compat_rate: num(row.compat_rate),
    photo_principale: row.photo_principale
      ? (signed.get(row.photo_principale) ?? null)
      : null,
  }));
}

/* -------------------------------------------------------------------------- */
/*  Cycle de vie d'une demande                                                */
/* -------------------------------------------------------------------------- */

/** Emet une demande vers un profil. Renvoie son identifiant. */
export async function createRequest(cible: string): Promise<string> {
  if (isPreviewMode) return `demande-${cible}`;
  const { data, error } = await (supabase.rpc as any)('creer_demande', { cible });
  if (error) throw toApiError(error, 'Envoi de la demande');
  return data as string;
}

/**
 * Marque une demande comme ouverte et renvoie son statut a jour.
 *
 * L'ouverture est un acte enregistre : c'est elle qui declenche le compte a
 * rebours de reponse. Ne l'appeler qu'au moment ou l'utilisateur consulte
 * vraiment la demande.
 */
export async function openRequest(demande: string): Promise<ChatRequestStatus> {
  if (isPreviewMode) return demo.ouvrirDemande(demande);
  const { data, error } = await (supabase.rpc as any)('ouvrir_demande', { demande });
  if (error) throw toApiError(error, 'Ouverture de la demande');
  return data as ChatRequestStatus;
}

/**
 * Repond a une demande.
 *
 * Un `oui` cree la conversation et renvoie son identifiant. Un `non` ou un
 * `plus_tard` renvoie `null` : il n'y a rien a ouvrir.
 */
export async function answerRequest(
  demande: string,
  reponse: DateIntent,
): Promise<string | null> {
  if (isPreviewMode) return demo.repondreDemande(demande, reponse);
  const { data, error } = await (supabase.rpc as any)('repondre_demande', {
    demande,
    reponse,
  });
  if (error) throw toApiError(error, 'Reponse a la demande');
  return (data as string | null) ?? null;
}

/* -------------------------------------------------------------------------- */
/*  Conversation                                                              */
/* -------------------------------------------------------------------------- */

/**
 * Propose une conversation directement, sans passer par une demande recue.
 *
 * `ordre_ecrans` reprend l'ordre servi par le moteur pour ce profil. Le laisser
 * a sa valeur par defaut revient a imposer un ordre que le moteur n'a pas
 * choisi : le passer explicitement des qu'on le connait.
 */
export async function proposeConversation(
  cible: string,
  typeRencontre: RencontreType,
  ordreEcrans?: ScoreGroup[],
): Promise<string> {
  const { data, error } = await (supabase.rpc as any)('proposer_conversation', {
    cible,
    type_rencontre: typeRencontre,
    ...(ordreEcrans ? { ordre_ecrans: ordreEcrans } : {}),
  });
  if (error) throw toApiError(error, 'Proposition de conversation');
  return data as string;
}

/** Signale que l'utilisateur entre dans la conversation. */
export async function joinConversation(conversation: string): Promise<void> {
  const { error } = await (supabase.rpc as any)('rejoindre_conversation', {
    conversation,
  });
  if (error) throw toApiError(error, 'Entree dans la conversation');
}

/**
 * Etat courant : statut, prenom de l'autre, presence, temps restant.
 *
 * A relire regulierement tant que l'ecran est ouvert — le statut change sans
 * que l'utilisateur fasse quoi que ce soit, par expiration ou verrouillage.
 */
export async function loadConversationState(
  conversation: string,
): Promise<EtatConversation | null> {
  if (isPreviewMode) return demo.etatConversation(conversation);
  const { data, error } = await (supabase.rpc as any)('etat_conversation', {
    conversation,
  });
  if (error) throw toApiError(error, 'Etat de la conversation');

  const rows = (data ?? []) as EtatConversation[];
  return rows[0] ?? null;
}

/* -------------------------------------------------------------------------- */
/*  Messages                                                                  */
/* -------------------------------------------------------------------------- */

/**
 * Lit le fil, du plus ancien au plus recent.
 *
 * La table est lue directement : la policy `p_msg_partie` garantit qu'on ne
 * voit que ses propres conversations. `depuis` permet de ne demander que la
 * suite, en passant le `created_at` du dernier message connu.
 */
export async function loadMessages(
  conversation: string,
  depuis?: string,
): Promise<Message[]> {
  if (isPreviewMode) return demo.messages(conversation);
  // `messages` n'est pas encore dans les types generes : meme cast que pour
  // les RPC, a retirer a la prochaine regeneration de database.ts.
  let requete = (supabase.from as any)('messages')
    .select('id, conversation_id, sender_id, kind, body, audio_path, duration_ms, created_at')
    .eq('conversation_id', conversation)
    .order('created_at', { ascending: true });

  if (depuis) requete = requete.gt('created_at', depuis);

  const { data, error } = await requete;
  if (error) throw toApiError(error, 'Chargement des messages');
  return (data ?? []) as unknown as Message[];
}

/**
 * Envoie un message et renvoie son identifiant.
 *
 * L'insertion directe est fermee : `envoyer_message` verifie le statut de la
 * conversation et les regles de contenu avant d'ecrire.
 */
export async function sendMessage(args: EnvoyerMessageArgs): Promise<string> {
  if (isPreviewMode) return demo.envoyerMessage(args.conversation_id, args.body ?? '');
  const { data, error } = await (supabase.rpc as any)('envoyer_message', {
    conv: args.conversation_id,
    p_kind: (args.kind ?? 'texte') as MessageKind,
    p_body: args.body ?? null,
    p_media: args.media ?? null,
    p_duree: args.duree_ms ?? null,
  });
  if (error) throw toApiError(error, 'Envoi du message');
  return data as string;
}

/**
 * Liste mes conversations.
 *
 * Aucune RPC ne rend ce service aujourd'hui : `boite_reception` ne sert que
 * les demandes et `etat_conversation` exige de connaitre l'identifiant a
 * l'avance. Il manque une fonction `mes_conversations()` cote base — voir
 * `ResumeConversation` dans `src/types/conversations.ts`.
 *
 * En attendant, l'ecran affiche une liste vide en conditions reelles plutot
 * que de tomber en erreur : le manque se voit, il ne casse rien.
 */
export async function listConversations(): Promise<ResumeConversation[]> {
  if (isPreviewMode) return demo.mesConversations();
  return [];
}

/** Marque un fil comme lu a son ouverture. */
export async function markConversationRead(conversation: string): Promise<void> {
  if (isPreviewMode) return demo.marquerLu(conversation);
}
