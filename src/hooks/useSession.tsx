import type { Session } from '@supabase/supabase-js';
import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';
import type { ReactNode } from 'react';

import { onAuthStateChange, signOut as apiSignOut } from '../api/auth';
import { fetchUserProgress } from '../api/onboarding';
import { supabase } from '../lib/supabase';
import { isPreviewMode } from '../preview';
import type { UserProgress } from '../types/rpc';

/**
 * Etat du compte, tel qu'il determine l'aiguillage de navigation.
 *
 * - `loading`    : la session persistee n'a pas fini d'etre relue.
 * - `signedOut`  : aucune session.
 * - `incomplete` : session valide, mais compte non active (ou sans ligne dans
 *                  `profiles` : il n'existe aucun declencheur sur auth.users,
 *                  donc un compte fraichement cree se trouve dans cet etat).
 * - `active`     : compte actif, acces a la decouverte.
 */
export type AccountState = 'loading' | 'signedOut' | 'incomplete' | 'active';

interface SessionContextValue {
  session: Session | null;
  progress: UserProgress | null;
  accountState: AccountState;
  /** Erreur non bloquante rencontree en lisant l'avancement du compte. */
  progressError: string | null;
  refreshProgress: () => Promise<void>;
  signOut: () => Promise<void>;
}

const SessionContext = createContext<SessionContextValue | null>(null);

export function SessionProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [progress, setProgress] = useState<UserProgress | null>(null);
  const [progressError, setProgressError] = useState<string | null>(null);
  const [sessionReady, setSessionReady] = useState(false);
  const [progressReady, setProgressReady] = useState(false);
  const mounted = useRef(true);

  useEffect(() => {
    mounted.current = true;
    return () => {
      mounted.current = false;
    };
  }, []);

  const loadProgress = useCallback(async (current: Session | null) => {
    if (!current) {
      if (!mounted.current) return;
      setProgress(null);
      setProgressError(null);
      setProgressReady(true);
      return;
    }

    try {
      const value = await fetchUserProgress();
      if (!mounted.current) return;
      setProgress(value);
      setProgressError(null);
    } catch (error) {
      if (!mounted.current) return;
      // Un echec de lecture ne doit pas bloquer l'application : on traite le
      // compte comme incomplet et on laisse l'utilisateur avancer ou se
      // deconnecter.
      setProgress(null);
      setProgressError(error instanceof Error ? error.message : 'Erreur inconnue');
    } finally {
      if (mounted.current) setProgressReady(true);
    }
  }, []);

  useEffect(() => {
    let cancelled = false;

    void supabase.auth.getSession().then(({ data }) => {
      if (cancelled) return;
      setSession(data.session);
      setSessionReady(true);
      void loadProgress(data.session);
    });

    const unsubscribe = onAuthStateChange((next) => {
      if (cancelled) return;
      setSession(next);
      setSessionReady(true);
      setProgressReady(false);
      void loadProgress(next);
    });

    return () => {
      cancelled = true;
      unsubscribe();
    };
  }, [loadProgress]);

  const refreshProgress = useCallback(async () => {
    await loadProgress(session);
  }, [loadProgress, session]);

  const signOut = useCallback(async () => {
    await apiSignOut();
  }, []);

  const accountState: AccountState = useMemo(() => {
    // En prévisualisation, l'application s'ouvre directement sur les onglets.
    if (isPreviewMode) return 'active';
    if (!sessionReady || (session && !progressReady)) return 'loading';
    if (!session) return 'signedOut';
    return progress?.compte_actif ? 'active' : 'incomplete';
  }, [progress, progressReady, session, sessionReady]);

  const value = useMemo(
    () => ({ session, progress, accountState, progressError, refreshProgress, signOut }),
    [accountState, progress, progressError, refreshProgress, session, signOut],
  );

  return <SessionContext.Provider value={value}>{children}</SessionContext.Provider>;
}

export function useSession(): SessionContextValue {
  const context = useContext(SessionContext);
  if (!context) {
    throw new Error('useSession doit etre utilise a l’interieur de SessionProvider.');
  }
  return context;
}
