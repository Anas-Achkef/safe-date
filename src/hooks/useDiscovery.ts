import { useFocusEffect } from 'expo-router';
import { useCallback, useEffect, useRef, useState } from 'react';

import { loadDiscoveryFeed, type DiscoveryEntry } from '../api/discovery';
import { fetchDecidedIds, recordDecision } from '../api/decisions';
import { userFacingMessage } from '../api/errors';
import { isPreviewMode, PREVIEW_DISCOVERY } from '../preview';

interface DiscoveryState {
  entries: DiscoveryEntry[];
  loading: boolean;
  refreshing: boolean;
  error: string | null;
  /** Identifiant en cours d'enregistrement, pour neutraliser les boutons. */
  deciding: string | null;
  refresh: () => void;
  decide: (candidateId: string, interested: boolean, durationMs?: number) => void;
}

export function useDiscovery(): DiscoveryState {
  const [entries, setEntries] = useState<DiscoveryEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [deciding, setDeciding] = useState<string | null>(null);
  const mounted = useRef(true);
  /** Le premier focus suit immédiatement le chargement initial : on l'ignore. */
  const firstFocus = useRef(true);

  useEffect(() => {
    mounted.current = true;
    return () => {
      mounted.current = false;
    };
  }, []);

  const load = useCallback(async (isRefresh: boolean) => {
    if (isPreviewMode) {
      setEntries(PREVIEW_DISCOVERY);
      setLoading(false);
      setRefreshing(false);
      return;
    }

    if (isRefresh) setRefreshing(true);
    else setLoading(true);
    setError(null);

    try {
      // Le back-end ne retire pas les profils deja traites : on s'en charge.
      const [feed, decided] = await Promise.all([loadDiscoveryFeed(), fetchDecidedIds()]);
      if (!mounted.current) return;
      setEntries(feed.filter((entry) => !decided.has(entry.candidate_id)));
    } catch (err) {
      if (!mounted.current) return;
      setError(userFacingMessage(err));
      setEntries([]);
    } finally {
      if (!mounted.current) return;
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    void load(false);
  }, [load]);

  /**
   * Recharge quand l'écran reprend le focus.
   *
   * Une réponse modifiée dans le questionnaire déclenche le recalcul des
   * vecteurs côté base : sans ce rechargement, on reviendrait sur des scores
   * périmés sans le savoir.
   */
  useFocusEffect(
    useCallback(() => {
      if (firstFocus.current) {
        firstFocus.current = false;
        return;
      }
      void load(true);
    }, [load]),
  );

  /**
   * Enregistre un choix et retire le profil de la liste.
   *
   * Le retrait est applique avant la reponse du serveur : l'ecran doit suivre
   * le geste sans attendre. En cas d'echec, le profil revient a sa place.
   */
  const decide = useCallback(
    (candidateId: string, interested: boolean, durationMs?: number) => {
      const snapshot = entries;
      setDeciding(candidateId);
      setEntries((previous) => previous.filter((entry) => entry.candidate_id !== candidateId));

      void (async () => {
        try {
          if (!isPreviewMode) {
            await recordDecision({ targetId: candidateId, interested, durationMs });
          }
        } catch (err) {
          if (!mounted.current) return;
          setEntries(snapshot);
          setError(userFacingMessage(err));
        } finally {
          if (mounted.current) setDeciding(null);
        }
      })();
    },
    [entries],
  );

  const refresh = useCallback(() => {
    void load(true);
  }, [load]);

  return { entries, loading, refreshing, error, deciding, refresh, decide };
}
