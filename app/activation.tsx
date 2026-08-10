import { router } from 'expo-router';
import { useCallback, useEffect, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { userFacingMessage } from '../src/api/errors';
import {
  acceptPolicy,
  fetchMyAcceptances,
  fetchPolicyDocuments,
  policyLabel,
  type PolicyDocument,
} from '../src/api/legal';
import { fetchActivationChecklist } from '../src/api/onboarding';
import { Button } from '../src/components/Button';
import { StateView } from '../src/components/StateView';
import { colors, opacity, radius, spacing, typography } from '../src/theme';
import type { ActivationChecklistItem } from '../src/types/rpc';

/**
 * Activation du compte.
 *
 * Reprend la checklist telle que le back-end la calcule — dix conditions — et
 * rend actionnables les trois qui dependent d'une acceptation de document. Les
 * autres (photo, verification biometrique, validation de l'e-mail) ne sont pas
 * encore couvertes : elles sont affichees, jamais simulees.
 */
export default function Activation() {
  const [checklist, setChecklist] = useState<ActivationChecklistItem[]>([]);
  const [documents, setDocuments] = useState<PolicyDocument[]>([]);
  const [accepted, setAccepted] = useState<Map<string, string>>(new Map());
  const [expanded, setExpanded] = useState<string | null>(null);
  const [busy, setBusy] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [list, docs, mine] = await Promise.all([
        fetchActivationChecklist(),
        fetchPolicyDocuments(),
        fetchMyAcceptances(),
      ]);
      setChecklist(list);
      setDocuments(docs);
      setAccepted(mine);
    } catch (err) {
      setError(userFacingMessage(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const accept = useCallback(
    async (doc: PolicyDocument) => {
      setBusy(doc.code);
      setError(null);
      try {
        await acceptPolicy(doc.code, doc.version);
        const [mine, list] = await Promise.all([fetchMyAcceptances(), fetchActivationChecklist()]);
        setAccepted(mine);
        setChecklist(list);
        setExpanded(null);
      } catch (err) {
        setError(userFacingMessage(err));
      } finally {
        setBusy(null);
      }
    },
    [],
  );

  if (loading) {
    return (
      <SafeAreaView style={styles.safe} edges={['top', 'left', 'right']}>
        <StateView variant="loading" title="Chargement" />
      </SafeAreaView>
    );
  }

  const satisfied = checklist.filter((item) => item.satisfaite).length;

  return (
    <SafeAreaView style={styles.safe} edges={['top', 'left', 'right']}>
      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <Pressable onPress={() => router.back()} style={styles.back}>
          <Text style={styles.backLabel} allowFontScaling={false}>
            Retour
          </Text>
        </Pressable>

        <Text style={styles.title} allowFontScaling={false}>
          Activation
        </Text>
        <Text style={styles.subtitle}>
          {satisfied} condition{satisfied > 1 ? 's' : ''} sur {checklist.length} remplie
          {satisfied > 1 ? 's' : ''}
        </Text>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Documents à accepter</Text>
          {documents.map((doc) => {
            const isAccepted = accepted.get(doc.code) === doc.version;
            const isOpen = expanded === doc.code;
            return (
              <View key={doc.code} style={styles.doc}>
                <Pressable
                  onPress={() => setExpanded(isOpen ? null : doc.code)}
                  style={({ pressed }) => [styles.docHead, pressed ? styles.pressed : null]}
                >
                  <View style={styles.docTitleWrap}>
                    <Text style={styles.docTitle}>{policyLabel(doc.code)}</Text>
                    <Text style={styles.docMeta}>
                      version {doc.version}
                      {isAccepted ? ' · acceptée' : ''}
                    </Text>
                  </View>
                  <View style={[styles.mark, isAccepted ? styles.markDone : styles.markTodo]} />
                </Pressable>

                {isOpen ? (
                  <View style={styles.docBody}>
                    <Text style={styles.docText}>{doc.body}</Text>
                    {!isAccepted ? (
                      <Button
                        label="J’accepte"
                        onPress={() => void accept(doc)}
                        loading={busy === doc.code}
                      />
                    ) : null}
                  </View>
                ) : null}
              </View>
            );
          })}
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Conditions d’activation</Text>
          {checklist.map((item) => (
            <View key={item.rang} style={styles.row}>
              <View style={[styles.mark, item.satisfaite ? styles.markDone : styles.markTodo]} />
              <Text style={[styles.rowLabel, item.satisfaite ? styles.rowLabelDone : null]}>
                {item.condition}
              </Text>
            </View>
          ))}
          <Text style={styles.note}>
            Les conditions restantes — photo, vérification d’identité, validation de l’e-mail —
            ne sont pas encore prises en charge par l’application.
          </Text>
        </View>

        {error ? <Text style={styles.error}>{error}</Text> : null}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    paddingHorizontal: spacing.gutter,
    paddingTop: spacing.md,
    paddingBottom: spacing.giant,
    gap: spacing.md,
  },
  back: {
    alignSelf: 'flex-start',
    paddingVertical: spacing.xs,
  },
  backLabel: {
    ...typography.label,
    color: colors.accent,
  },
  title: {
    ...typography.display,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
  subtitle: {
    ...typography.caption,
    color: colors.textMuted,
    marginBottom: spacing.sm,
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
  doc: {
    gap: spacing.md,
  },
  docHead: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: spacing.md,
  },
  pressed: {
    opacity: opacity.pressed,
  },
  docTitleWrap: {
    flex: 1,
    gap: spacing.xs,
  },
  docTitle: {
    ...typography.label,
    color: colors.textPrimary,
  },
  docMeta: {
    ...typography.caption,
    color: colors.textMuted,
  },
  docBody: {
    backgroundColor: colors.surfaceAlt,
    borderRadius: radius.sm,
    padding: spacing.lg,
    gap: spacing.lg,
  },
  docText: {
    ...typography.body,
    color: colors.textSecondary,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
  },
  mark: {
    width: spacing.md,
    height: spacing.md,
    borderRadius: radius.pill,
  },
  markDone: {
    backgroundColor: colors.accent,
  },
  markTodo: {
    backgroundColor: colors.surfaceAlt,
  },
  rowLabel: {
    ...typography.body,
    color: colors.textPrimary,
    flex: 1,
  },
  rowLabelDone: {
    color: colors.textMuted,
  },
  note: {
    ...typography.caption,
    color: colors.textMuted,
    marginTop: spacing.sm,
  },
  error: {
    ...typography.caption,
    color: colors.danger,
  },
});
