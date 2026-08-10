import { useCallback, useEffect, useState } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import { userFacingMessage } from '../../src/api/errors';
import { fetchActivationChecklist, fetchAnswerProgress } from '../../src/api/onboarding';
import { Button } from '../../src/components/Button';
import { Screen } from '../../src/components/Screen';
import { StateView } from '../../src/components/StateView';
import { useSession } from '../../src/hooks/useSession';
import { colors, radius, spacing, typography } from '../../src/theme';
import type { ActivationChecklistItem, AnswerProgress } from '../../src/types/rpc';

/**
 * Coquille du parcours d'inscription.
 *
 * Les 9 etapes ne sont pas encore implementees, mais l'ecran lit deja l'etat
 * reel du compte : c'est ce qui permettra de brancher chaque etape sur la
 * bonne RPC sans redecouvrir l'etat a chaque fois.
 */
export default function Onboarding() {
  const { progress, progressError, refreshProgress, signOut } = useSession();
  const [checklist, setChecklist] = useState<ActivationChecklistItem[]>([]);
  const [answers, setAnswers] = useState<AnswerProgress | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [items, answerProgress] = await Promise.all([
        fetchActivationChecklist(),
        fetchAnswerProgress(),
      ]);
      setChecklist(items);
      setAnswers(answerProgress);
    } catch (err) {
      setError(userFacingMessage(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  if (loading) {
    return (
      <Screen title="Ton inscription">
        <StateView variant="loading" title="Lecture de ton avancement…" />
      </Screen>
    );
  }

  const hasProfileRow = progress !== null;

  return (
    <Screen
      title="Ton inscription"
      subtitle={
        progress
          ? `Étape ${progress.etape_courante} sur ${progress.etapes_total}`
          : 'Ton profil n’est pas encore initialisé.'
      }
    >
      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        {!hasProfileRow ? (
          <View style={styles.card}>
            <Text style={styles.cardTitle}>Profil à créer</Text>
            <Text style={styles.cardBody}>
              Ton compte existe, mais aucune ligne de profil ne lui est encore associée : la date de
              naissance et les préférences de recherche restent à saisir. Cette étape n’est pas
              couverte par les fonctions RPC actuelles.
            </Text>
          </View>
        ) : null}

        {answers ? (
          <View style={styles.card}>
            <Text style={styles.cardTitle}>Questionnaire</Text>
            <Row label="Onboarding" value={`${answers.onboarding_repondus} / ${answers.onboarding_total}`} />
            <Row label="Quiz" value={`${answers.quiz_repondus} / ${answers.quiz_total}`} />
            <Row label="Paires complètes" value={String(answers.paires_completes)} />
            <Row label="Critères évaluables" value={String(answers.criteres_evaluables)} />
          </View>
        ) : null}

        {checklist.length > 0 ? (
          <View style={styles.card}>
            <Text style={styles.cardTitle}>Conditions d’activation</Text>
            {checklist.map((item) => (
              <View key={item.rang} style={styles.checkRow}>
                <View style={[styles.marker, item.satisfaite ? styles.markerDone : styles.markerTodo]} />
                <Text style={[styles.checkLabel, item.satisfaite ? styles.checkLabelDone : null]}>
                  {item.condition}
                </Text>
              </View>
            ))}
          </View>
        ) : null}

        {error ? <Text style={styles.error}>{error}</Text> : null}
        {progressError ? <Text style={styles.error}>{progressError}</Text> : null}

        <View style={styles.actions}>
          <Button
            label="Actualiser"
            variant="secondary"
            onPress={() => {
              void load();
              void refreshProgress();
            }}
          />
          <Button label="Se déconnecter" variant="secondary" onPress={() => void signOut()} />
        </View>
      </ScrollView>
    </Screen>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.row}>
      <Text style={styles.rowLabel}>{label}</Text>
      <Text style={styles.rowValue}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  content: {
    gap: spacing.lg,
    paddingBottom: spacing.xxl,
  },
  card: {
    backgroundColor: colors.surface,
    borderRadius: radius.lg,
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: colors.rule,
    padding: spacing.lg,
    gap: spacing.sm,
  },
  cardTitle: {
    ...typography.heading,
    color: colors.textPrimary,
    marginBottom: spacing.xs,
  },
  cardBody: {
    ...typography.body,
    color: colors.textMuted,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  rowLabel: {
    ...typography.body,
    color: colors.textMuted,
  },
  rowValue: {
    ...typography.body,
    color: colors.textPrimary,
  },
  checkRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
  },
  marker: {
    width: spacing.sm,
    height: spacing.sm,
    borderRadius: radius.pill,
  },
  markerDone: {
    backgroundColor: colors.accent,
  },
  markerTodo: {
    backgroundColor: colors.textMuted,
  },
  checkLabel: {
    ...typography.body,
    color: colors.textSecondary,
    flex: 1,
  },
  checkLabelDone: {
    color: colors.textMuted,
  },
  error: {
    ...typography.caption,
    color: colors.danger,
  },
  actions: {
    gap: spacing.md,
  },
});
