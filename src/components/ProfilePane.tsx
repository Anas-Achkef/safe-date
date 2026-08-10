import { useEffect, useRef } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import type { DiscoveryEntry, HiddenReason } from '../api/discovery';
import { colors, layout, radius, spacing, typography } from '../theme';
import { DecisionBar } from './DecisionBar';
import { Highlights } from './Highlights';
import { PhotoCard } from './PhotoCard';
import { Rise } from './Rise';
import { ScoreTable } from './ScoreTable';

interface ProfilePaneProps {
  entry: DiscoveryEntry;
  /** Hauteur exacte disponible : un profil occupe un écran, jamais moins. */
  height: number;
  focused: boolean;
  animate: boolean;
  busy: boolean;
  /** `durationMs` mesure le temps passé sur le profil avant la décision. */
  onDecide: (candidateId: string, interested: boolean, durationMs: number) => void;
}

const HIDDEN_NOTES: Record<HiddenReason, string> = {
  premium: 'Ce profil fait partie de vos meilleures compatibilités. Son détail est réservé aux membres.',
  filters: 'Ce profil sort de vos critères d’âge ou de distance.',
  no_data: 'Répondez à quelques questions de plus pour découvrir ce profil.',
  unreadable: 'Ce profil n’a pas pu être évalué.',
};

/**
 * Un profil, un écran.
 *
 * Le visage passe avant le chiffre : le score se réduit à une pastille posée
 * sur la photo. Aucun champ n'est supposé présent — au-delà du seuil premium,
 * le back-end renvoie prénom, photo et scores à `null`.
 */
export function ProfilePane({
  entry,
  height,
  focused,
  animate,
  busy,
  onDecide,
}: ProfilePaneProps) {
  const { prenom, age, photo, score_global, visible, hiddenReason, highlights } = entry;
  const photoHeight = Math.round((height - spacing.gutter) * layout.photoRatio);

  /** Instant d'arrivée sur le profil, pour mesurer le temps de décision. */
  const shownAt = useRef<number>(Date.now());
  useEffect(() => {
    if (focused) shownAt.current = Date.now();
  }, [focused, entry.candidate_id]);

  const decide = (interested: boolean) =>
    onDecide(entry.candidate_id, interested, Date.now() - shownAt.current);

  return (
    <View style={[styles.pane, { height }]}>
      <Rise step={0} active={focused} trigger={entry.candidate_id + String(animate)}>
        <PhotoCard
          photo={photo}
          firstName={prenom}
          age={age}
          score={visible ? score_global : null}
          seed={entry.candidate_id}
          height={photoHeight}
        />
      </Rise>

      <ScrollView
        style={styles.details}
        contentContainerStyle={styles.detailsContent}
        showsVerticalScrollIndicator={false}
      >
        {visible ? (
          <>
            <Rise step={1} active={focused} trigger={entry.candidate_id}>
              <ScoreTable
                valeurs={entry.score_valeurs}
                modeVie={entry.score_mode_vie}
                physique={entry.score_physique}
              />
            </Rise>

            <Rise step={2} active={focused} trigger={entry.candidate_id}>
              <Highlights items={highlights ?? []} />
            </Rise>
          </>
        ) : (
          <Rise step={1} active={focused} trigger={entry.candidate_id}>
            <View style={styles.note}>
              <Text style={styles.noteText}>{HIDDEN_NOTES[hiddenReason ?? 'unreadable']}</Text>
            </View>
          </Rise>
        )}
      </ScrollView>

      <DecisionBar
        onPass={() => decide(false)}
        onInterested={() => decide(true)}
        busy={busy}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  pane: {
    paddingHorizontal: spacing.gutter,
    paddingTop: spacing.md,
    paddingBottom: spacing.md,
  },
  details: {
    flex: 1,
  },
  detailsContent: {
    paddingTop: spacing.lg,
    paddingBottom: spacing.md,
    gap: spacing.lg,
  },
  note: {
    backgroundColor: colors.surfaceAlt,
    borderRadius: radius.sm,
    padding: spacing.lg,
  },
  noteText: {
    ...typography.body,
    color: colors.textSecondary,
  },
});
