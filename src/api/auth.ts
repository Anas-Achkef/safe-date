import type { Session, User } from '@supabase/supabase-js';

import { supabase } from '../lib/supabase';
import { ApiError, toApiError } from './errors';

export interface SignUpResult {
  user: User | null;
  session: Session | null;
  /**
   * Vrai quand le projet exige une confirmation d'e-mail : `signUp` reussit
   * mais ne renvoie pas de session tant que le lien n'est pas ouvert.
   */
  confirmationRequired: boolean;
}

export async function signUpWithEmail(email: string, password: string): Promise<SignUpResult> {
  const { data, error } = await supabase.auth.signUp({ email, password });
  if (error) throw toApiError(error, 'Inscription');

  return {
    user: data.user,
    session: data.session,
    confirmationRequired: data.session === null,
  };
}

export async function signInWithEmail(email: string, password: string): Promise<Session> {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) throw toApiError(error, 'Connexion');
  if (!data.session) {
    throw new ApiError('auth_required', 'Connexion refusee : aucune session renvoyee.', null);
  }
  return data.session;
}

export async function signOut(): Promise<void> {
  const { error } = await supabase.auth.signOut();
  if (error) throw toApiError(error, 'Deconnexion');
}

export async function getCurrentSession(): Promise<Session | null> {
  const { data, error } = await supabase.auth.getSession();
  if (error) throw toApiError(error, 'Lecture de la session');
  return data.session;
}

/** S'abonne aux changements de session. Renvoie la fonction de desabonnement. */
export function onAuthStateChange(callback: (session: Session | null) => void): () => void {
  const { data } = supabase.auth.onAuthStateChange((_event, session) => {
    callback(session);
  });
  return () => data.subscription.unsubscribe();
}
