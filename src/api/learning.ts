import { signPhotoPaths } from '../lib/storage';
import { demo, isPreviewMode } from '../preview';
import { supabase } from '../lib/supabase';
import type {
  CarteApprentissage,
  EnregistrerSwipeArgs,
  EtatSession,
  FinDeSession,
  Sollicitation,
} from '../types/learning';
import { toApiError } from './errors';

/**
 * Onglet « Mieux me connaître ».
 *
 * Aucun match n'y est créé, aucune conversation ouverte, aucun rendez-vous
 * proposé. Les profils servent exclusivement à entraîner le moteur : la
 * localisation et la disponibilité n'y ont aucune importance, et un profil
 * peut se trouver à l'autre bout du monde.
 */

/** Charge une page du fil et signe les photos. */
export async function loadLearningFeed(taille = 10): Promise<CarteApprentissage[]> {
  if (isPreviewMode) return demo.filApprentissage(taille);
  const { data, error } = await (supabase.rpc as any)('fil_apprentissage', { taille });
  if (error) throw toApiError(error, 'Chargement des profils');

  const rows = (data ?? []) as CarteApprentissage[];
  if (rows.length === 0) return [];

  const signed = await signPhotoPaths(
    rows
      .map((row) => row.photo_principale)
      .filter((path): path is string => Boolean(path)),
  );

  return rows.map((row) => ({
    ...row,
    photo_principale: row.photo_principale
      ? (signed.get(row.photo_principale) ?? null)
      : null,
    // Un profil sans page n'est pas affichable : on retombe sur l'ordre
    // par défaut plutôt que de laisser l'écran vide.
    ordre_pages:
      row.ordre_pages?.length === 3
        ? row.ordre_pages
        : ['physique', 'valeurs', 'mode_vie'],
    criteres: row.criteres ?? {},
  }));
}

/**
 * Enregistre la décision et son contexte comportemental.
 *
 * Renvoie l'identifiant d'une sollicitation si le moteur décide d'en poser
 * une. C'est lui qui choisit : la cadence dépend de ce qu'il ignore encore,
 * jamais d'un compteur tenu côté application.
 */
export async function submitSwipe(args: EnregistrerSwipeArgs): Promise<string | null> {
  if (isPreviewMode) return demo.noterSwipe(args.cible);
  const { data, error } = await (supabase.rpc as any)('enregistrer_swipe', {
    cible: args.cible,
    garder: args.garder,
    contexte: args.contexte,
    signal_fort: args.signal_fort ?? false,
    ecran: args.ecran ?? null,
    duree_ms: args.duree_ms ?? null,
    ecrans: args.ecrans ?? null,
    ordre_consultation: args.ordre_consultation ?? null,
    retours: args.retours ?? 0,
    criteres_exposes: args.criteres_exposes ?? null,
    criteres_consultes: args.criteres_consultes ?? null,
    type_rencontre: args.type_rencontre ?? null,
    presentation_id: args.presentation_id ?? null,
  });
  if (error) throw toApiError(error, 'Enregistrement de la décision');
  return (data as string | null) ?? null;
}

/** La sollicitation en attente, ou `null`. Jamais plus d'une à la fois. */
export async function loadPendingFocus(): Promise<Sollicitation | null> {
  if (isPreviewMode) return demo.sollicitationEnAttente();
  const { data, error } = await (supabase.rpc as any)('focus_en_attente');
  if (error) throw toApiError(error, 'Chargement de la question');
  const rows = (data ?? []) as Sollicitation[];
  return rows[0] ?? null;
}

/**
 * Répond à une sollicitation.
 *
 * Passer sans répondre est une réponse valable : le moteur n'en déduit rien
 * sur les préférences, mais retient que la sollicitation a été déclinée.
 */
export async function answerFocus(
  focus: string,
  options: number[] | null,
  categorie?: string,
): Promise<void> {
  if (isPreviewMode) return demo.repondreSollicitation();
  const { error } = await (supabase.rpc as any)('repondre_focus', {
    focus,
    options: options && options.length > 0 ? options : null,
    categorie: categorie ?? null,
  });
  if (error) throw toApiError(error, 'Enregistrement de la réponse');
}

export async function loadSessionState(): Promise<EtatSession> {
  if (isPreviewMode) return demo.etatSession();
  const { data, error } = await (supabase.rpc as any)('etat_session');
  if (error) throw toApiError(error, 'État de la session');
  const rows = (data ?? []) as EtatSession[];
  return rows[0] ?? { profils_vus: 0, quota: 0, restants: null, illimite: true, niveau: 0 };
}

/** Clôture la session et relève le niveau de connaissance du jour. */
export async function closeSession(): Promise<FinDeSession | null> {
  if (isPreviewMode) return demo.finDeSession();
  const { data, error } = await (supabase.rpc as any)('cloturer_session');
  if (error) throw toApiError(error, 'Clôture de la session');
  const rows = (data ?? []) as FinDeSession[];
  return rows[0] ?? null;
}
