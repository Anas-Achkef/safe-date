import type { PostgrestError } from '@supabase/supabase-js';

/**
 * Traduction des erreurs du back-end en categories exploitables par l'interface.
 *
 * Le point important : une erreur `permission_denied` n'est presque jamais un
 * defaut a contourner. Elle signale soit une session absente, soit un appel a
 * la mauvaise fonction. On la remonte telle quelle plutot que de la masquer.
 */
export type ApiErrorKind =
  | 'auth_required' // session absente ou expiree
  | 'forbidden' // regle metier : candidat hors perimetre, premium requis, distance
  | 'missing_function' // la fonction RPC n'existe pas encore cote base
  | 'network'
  | 'unknown';

export class ApiError extends Error {
  readonly kind: ApiErrorKind;
  readonly code: string | null;
  readonly cause: unknown;

  constructor(kind: ApiErrorKind, message: string, code: string | null, cause?: unknown) {
    super(message);
    this.name = 'ApiError';
    this.kind = kind;
    this.code = code;
    this.cause = cause;
  }
}

/** `42501` = insufficient_privilege, leve par les gardes RPC du back-end. */
const PG_INSUFFICIENT_PRIVILEGE = '42501';
/** PostgREST : fonction absente du cache de schema. */
const PGRST_MISSING_FUNCTION = 'PGRST202';
/** PostgREST : JWT invalide ou expire. */
const PGRST_INVALID_JWT = 'PGRST301';

export function toApiError(error: PostgrestError | Error, context: string): ApiError {
  const code = 'code' in error && error.code ? String(error.code) : null;
  const message = error.message ?? 'Erreur inconnue';

  if (code === PGRST_MISSING_FUNCTION) {
    return new ApiError('missing_function', `${context} : fonction absente du back-end.`, code, error);
  }

  if (code === PGRST_INVALID_JWT) {
    return new ApiError('auth_required', 'Session expirée, reconnexion nécessaire.', code, error);
  }

  if (code === PG_INSUFFICIENT_PRIVILEGE) {
    // Le back-end distingue « pas de session » de « hors perimetre » par le
    // texte du message, les deux partageant le meme SQLSTATE.
    const kind: ApiErrorKind = /authentification/i.test(message) ? 'auth_required' : 'forbidden';
    return new ApiError(kind, message, code, error);
  }

  if (/network|fetch|timeout/i.test(message)) {
    return new ApiError('network', 'Connexion au serveur impossible.', code, error);
  }

  return new ApiError('unknown', `${context} : ${message}`, code, error);
}

/** Message court, affichable tel quel dans l'interface. */
export function userFacingMessage(error: unknown): string {
  if (error instanceof ApiError) {
    switch (error.kind) {
      case 'auth_required':
        return 'Ta session a expiré. Reconnecte-toi.';
      case 'forbidden':
        return error.message;
      case 'missing_function':
        return 'Cette fonctionnalité n’est pas encore disponible côté serveur.';
      case 'network':
        return 'Pas de connexion au serveur.';
      default:
        return error.message;
    }
  }
  return error instanceof Error ? error.message : 'Erreur inconnue.';
}
