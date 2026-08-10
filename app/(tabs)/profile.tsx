import { router } from 'expo-router';
import { useCallback, useEffect, useState } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import { userFacingMessage } from '../../src/api/errors';
import { fetchAnswerProgress } from '../../src/api/onboarding';
import { fetchProfileHeader } from '../../src/api/profile';
import { Button } from '../../src/components/Button';
import { Screen } from '../../src/components/Screen';
import { StateView } from '../../src/components/StateView';
import { useSession } from '../../src/hooks/useSession';
import { isPreviewMode, PREVIEW_PROFILE_HEADER } from '../../src/preview';
import { colors, radius, spacing, typography } from '../../src/theme';
import type { AnswerProgress, ProfileHeader } from '../../src/types/rpc';

export default function Profile() {
  const { session, signOut } = useSession();
  const [header, setHeader] = useState<ProfileHeader | null>(null);
  const [answers, setAnswers] = useState<AnswerProgress | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (isPreviewMode) {
      setHeader(PREVIEW_PROFILE_HEADER);
      setLoading(false);
      return;
    }

    setLoading(true);
    setError(null);
    try {
      const [head, progress] = await Promise.all([fetchProfileHeader(), fetchAnswerProgress()]);
      setHeader(head);
      setAnswers(progress);
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
      <Screen title="Profil">
        <StateView variant="loading" title="Chargement" />
      </Screen>
    );
  }

  const total = answers ? answers.onboarding_total + answers.quiz_total : 0;
  const done = answers ? answers.onboarding_repondus + answers.quiz_repondus : 0;

  return (
    <Screen title="Profil">
      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Votre questionnaire</Text>
          <Text style={styles.cardBody}>
            Vos réponses alimentent le calcul de compatibilité. En modifier une met aussitôt tous
            vos pourcentages à jour.
          </Text>

          {answers ? (
            <>
              <View style={styles.bar}>
                <View
                  style={[
                    styles.barFill,
                    { width: `${total > 0 ? Math.min(100, (done / total) * 100) : 0}%` },
                  ]}
                />
              </View>
              <Text style={styles.progressText}>
                {done} réponses sur {total} · {answers.paires_completes} paires complètes
              </Text>
            </>
          ) : null}

          <View style={styles.action}>
            <Button label="Répondre aux questions" onPress={() => router.push('/questionnaire')} />
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Vos photos</Text>
          <Text style={styles.cardBody}>
            C’est votre photo principale que les autres voient en premier.
          </Text>
          <View style={styles.action}>
            <Button
              label="Gérer mes photos"
              variant="secondary"
              onPress={() => router.push('/photos')}
            />
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Activation du compte</Text>
          <Text style={styles.cardBody}>
            Dix conditions décident de l’activation. Les documents contractuels s’acceptent
            directement depuis l’application.
          </Text>
          <View style={styles.action}>
            <Button
              label="Voir les conditions"
              variant="secondary"
              onPress={() => router.push('/activation')}
            />
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Compte</Text>
          <Row label="Adresse e-mail" value={session?.user.email ?? '—'} />
          {header ? (
            <>
              <Row label="Âge" value={`${header.age} ans`} />
              <Row label="Profil vérifié" value={header.profil_verifie ? 'Oui' : 'Non'} />
              <Row label="Connaissance du profil" value={`${Math.round(header.connaissance)} %`} />
              <Row label="Offre" value={header.est_premium ? 'Premium' : 'Standard'} />
            </>
          ) : (
            <Text style={styles.cardBody}>En-tête de profil indisponible.</Text>
          )}
        </View>

        {error ? <Text style={styles.error}>{error}</Text> : null}

        <Button label="Se déconnecter" variant="secondary" onPress={() => void signOut()} />
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
    paddingBottom: spacing.giant,
  },
  card: {
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    padding: spacing.xl,
    gap: spacing.md,
  },
  cardTitle: {
    ...typography.heading,
    color: colors.textPrimary,
  },
  cardBody: {
    ...typography.body,
    color: colors.textSecondary,
  },
  bar: {
    height: spacing.xs,
    borderRadius: radius.pill,
    backgroundColor: colors.surfaceAlt,
    overflow: 'hidden',
  },
  barFill: {
    height: '100%',
    borderRadius: radius.pill,
    backgroundColor: colors.accent,
  },
  progressText: {
    ...typography.caption,
    color: colors.textMuted,
  },
  action: {
    marginTop: spacing.sm,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: spacing.lg,
  },
  rowLabel: {
    ...typography.body,
    color: colors.textMuted,
  },
  rowValue: {
    ...typography.body,
    color: colors.textPrimary,
    flexShrink: 1,
    textAlign: 'right',
  },
  error: {
    ...typography.caption,
    color: colors.danger,
  },
});
