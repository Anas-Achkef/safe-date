import { signPhotoPaths } from '../lib/storage';
import { supabase } from '../lib/supabase';
import type {
  ResumeConversation,
  ChatRequestStatus,
  ConversationStatus,
  RejoindreResultat,
  ReponseFin,
  DateIntent,
  DemandeRecue,
  EnvoyerMessageArgs,
  EtatConversation,
  Message,
  MessageKind,
} from '../types/conversations';
import type { RencontreType } from '../types/learning';
import type { ScoreGroup } from '../types/rpc';
import { ApiError, toApiError } from './errors';
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

/**
 * Signale que l'utilisateur est sur l'ecran de la conversation.
 *
 * A rappeler tant que l'ecran est ouvert : le serveur ne compte une presence
 * que quelques dizaines de secondes, et c'est la presence simultanee des deux
 * qui fait partir le chrono.
 */
export async function joinConversation(
  conversation: string,
): Promise<RejoindreResultat | null> {
  if (isPreviewMode) return demo.rejoindreConversation(conversation);
  const { data, error } = await (supabase.rpc as any)('rejoindre_conversation', {
    conversation,
  });
  if (error) throw toApiError(error, 'Entree dans la conversation');
  const rows = (data ?? []) as RejoindreResultat[];
  return rows[0] ?? null;
}

/** Signe de vie de l'application, a chaque retour au premier plan. */
export async function signalPresence(): Promise<void> {
  if (isPreviewMode) return;
  const { error } = await (supabase.rpc as any)('signaler_presence');
  if (error) throw toApiError(error, 'Signal de presence');
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
  const [etat, ligne] = await Promise.all([
    (supabase.rpc as any)('etat_conversation', { conversation }),
    (supabase.from as any)('conversations')
      .select('illimitee')
      .eq('id', conversation)
      .maybeSingle(),
  ]);
  if (etat.error) throw toApiError(etat.error, 'Etat de la conversation');
  if (ligne.error) throw toApiError(ligne.error, 'Etat de la conversation');

  const rows = (etat.data ?? []) as Omit<EtatConversation, 'illimitee'>[];
  if (!rows[0]) return null;
  return { ...rows[0], illimitee: Boolean(ligne.data?.illimitee) };
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
  if (isPreviewMode) {
    return demo.messages(conversation).filter((m) => !depuis || m.created_at > depuis);
  }
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
 * Liste mes conversations, la plus recente d'abord.
 *
 * Aucune fonction serveur ne sert cette liste : on lit directement
 * `conversations` (policy `p_conv_partie` : seulement les miennes), on
 * complete chaque ligne par `etat_conversation` pour le prenom et la presence
 * de l'autre, et on prend le dernier message de chacune en une seule lecture.
 */
export async function listConversations(): Promise<ResumeConversation[]> {
  if (isPreviewMode) return demo.mesConversations();

  const { data, error } = await (supabase.from as any)('conversations')
    .select('id, status, illimitee, prete_at, started_at');
  if (error) throw toApiError(error, 'Chargement des conversations');

  const lignes = ((data ?? []) as {
    id: string;
    status: ConversationStatus;
    illimitee: boolean;
    prete_at: string;
    started_at: string | null;
  }[]).sort((a, b) => (b.started_at ?? b.prete_at).localeCompare(a.started_at ?? a.prete_at));
  if (lignes.length === 0) return [];

  const ids = lignes.map((l) => l.id);
  const [etats, derniers] = await Promise.all([
    Promise.all(
      ids.map(async (id) => {
        const r = await (supabase.rpc as any)('etat_conversation', { conversation: id });
        if (r.error) throw toApiError(r.error, 'Chargement des conversations');
        return ((r.data ?? []) as Omit<EtatConversation, 'illimitee'>[])[0] ?? null;
      }),
    ),
    (supabase.from as any)('messages')
      .select('conversation_id, body, created_at')
      .in('conversation_id', ids)
      .order('created_at', { ascending: false }),
  ]);
  if (derniers.error) throw toApiError(derniers.error, 'Chargement des conversations');

  const dernierPar = new Map<string, { body: string | null; created_at: string }>();
  for (const m of (derniers.data ?? []) as { conversation_id: string; body: string | null; created_at: string }[]) {
    if (!dernierPar.has(m.conversation_id)) dernierPar.set(m.conversation_id, m);
  }

  return lignes.flatMap((l, i) => {
    const e = etats[i];
    if (!e) return [];
    const dernier = dernierPar.get(l.id);
    return [
      {
        conversation_id: l.id,
        autre: e.autre,
        prenom_autre: e.prenom_autre,
        age_autre: null,
        photo_autre: null,
        autre_en_ligne: e.autre_en_ligne,
        statut: l.status,
        dernier_message: dernier?.body ?? null,
        dernier_au: dernier?.created_at ?? null,
        illimitee: Boolean(l.illimitee),
        secondes_restantes: e.secondes_restantes,
      },
    ];
  });
}

/**
 * Reponse a « Souhaitez-vous vous voir ? ».
 *
 * La fonction serveur qui l'enregistre arrive a l'etape 2 : hors apercu, on
 * le dit plutot que d'ecrire directement dans `conversation_decisions`, qui
 * n'est pas une table ouverte a l'ecriture selon les regles du projet.
 */
export async function decideConversation(
  conversation: string,
  decision: ReponseFin,
): Promise<void> {
  if (isPreviewMode) return demo.deciderConversation(conversation, decision);
  throw new ApiError('missing_function', 'Enregistrement de la décision', null);
}
