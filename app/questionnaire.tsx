import { router } from 'expo-router';
import { useCallback, useEffect, useMemo, useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { userFacingMessage } from '../src/api/errors';
import { completeQuestionnaireStep, fetchAnswerProgress } from '../src/api/onboarding';
import { loadQuestionnaire, submitAnswer, type QuestionnaireItem } from '../src/api/questionnaire';
import { Button } from '../src/components/Button';
import { QuestionCard } from '../src/components/QuestionCard';
import { StateView } from '../src/components/StateView';
import { colors, opacity, radius, spacing, typography } from '../src/theme';
import type { AnswerProgress } from '../src/types/rpc';

type Filter = 'todo' | 'all';

/**
 * Le questionnaire.
 *
 * Chaque reponse est enregistree immediatement par `submit_answer`, et le
 * back-end recalcule les vecteurs dans la foulee : les pourcentages de l'ecran
 * Decouverte bougent des le retour. On applique le changement a l'ecran avant
 * la reponse du serveur, et on le defait si l'ecriture echoue.
 */
export default function Questionnaire() {
  const [items, setItems] = useState<QuestionnaireItem[]>([]);
  const [progress, setProgress] = useState<AnswerProgress | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<Filter>('todo');
  const [saving, setSaving] = useState<Set<string>>(new Set());
  const [rowErrors, setRowErrors] = useState<Record<string, string>>({});
  const [finishing, setFinishing] = useState(false);
  const [finishError, setFinishError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [list, prog] = await Promise.all([loadQuestionnaire(), fetchAnswerProgress()]);
      setItems(list);
      setProgress(prog);
    } catch (err) {
      setError(userFacingMessage(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const onSelect = useCallback(
    async (item: QuestionnaireItem, optionIdx: number) => {
      const current = item.answer ?? [];

      // Choix unique : on remplace. Choix multiple : on bascule, sans jamais
      // aboutir a une selection vide, que le back-end refuse.
      let next: number[];
      if (item.multiSelect) {
        next = current.includes(optionIdx)
          ? current.filter((i) => i !== optionIdx)
          : [...current, optionIdx].sort((a, b) => a - b);
        if (next.length === 0) return;
      } else {
        if (current.length === 1 && current[0] === optionIdx) return;
        next = [optionIdx];
      }

      setItems((previous) =>
        previous.map((row) => (row.key === item.key ? { ...row, answer: next } : row)),
      );
      setSaving((previous) => new Set(previous).add(item.key));
      setRowErrors((previous) => {
        const { [item.key]: _removed, ...rest } = previous;
        return rest;
      });

      try {
        await submitAnswer(item.key, next);
        setProgress(await fetchAnswerProgress());
      } catch (err) {
        // L'ecriture a echoue : on remet la reponse precedente a l'ecran.
        setItems((previous) =>
          previous.map((row) => (row.key === item.key ? { ...row, answer: item.answer } : row)),
        );
        setRowErrors((previous) => ({ ...previous, [item.key]: userFacingMessage(err) }));
      } finally {
        setSaving((previous) => {
          const next2 = new Set(previous);
          next2.delete(item.key);
          return next2;
        });
      }
    },
    [],
  );

  const visible = useMemo(
    () => (filter === 'todo' ? items.filter((item) => item.answer === null) : items),
    [filter, items],
  );

  const answered = items.filter((item) => item.answer !== null).length;
  const remaining = items.length - answered;

  /**
   * Fin du questionnaire.
   *
   * Valide l'étape auprès du back-end puis renvoie vers la Découverte, où les
   * scores ont déjà été recalculés. Si la validation échoue — un consentement
   * manquant, un critère obligatoire non traité — le message du back-end est
   * affiché et la navigation n'a pas lieu.
   */
  const finish = useCallback(async () => {
    setFinishing(true);
    setFinishError(null);
    try {
      await completeQuestionnaireStep();
      router.replace('/(tabs)/discovery');
    } catch (err) {
      setFinishError(userFacingMessage(err));
    } finally {
      setFinishing(false);
    }
  }, []);

  const footer = (
    <View style={styles.footer}>
      {remaining > 0 ? (
        <>
          <Text style={styles.footerTitle} allowFontScaling={false}>
            Encore {remaining} question{remaining > 1 ? 's' : ''}
          </Text>
          <Text style={styles.footerBody}>
            Chaque réponse affine vos compatibilités. Vous pouvez vous arrêter et reprendre plus
            tard : tout est enregistré au fur et à mesure.
          </Text>
        </>
      ) : (
        <>
          <Text style={styles.footerTitle} allowFontScaling={false}>
            Questionnaire complet
          </Text>
          <Text style={styles.footerBody}>
            Vos {answered} réponses sont enregistrées et vos compatibilités ont été recalculées.
          </Text>
        </>
      )}

      {finishError ? <Text style={styles.footerError}>{finishError}</Text> : null}

      <View style={styles.footerAction}>
        <Button
          label="Voir mes compatibilités"
          onPress={() => void finish()}
          loading={finishing}
        />
      </View>
    </View>
  );

  if (loading) {
    return (
      <SafeAreaView style={styles.safe} edges={['top', 'left', 'right']}>
        <StateView variant="loading" title="Chargement du questionnaire" />
      </SafeAreaView>
    );
  }

  if (error) {
    return (
      <SafeAreaView style={styles.safe} edges={['top', 'left', 'right']}>
        <StateView
          variant="error"
          title="Chargement impossible"
          message={error}
          actionLabel="Réessayer"
          onAction={() => void load()}
        />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safe} edges={['top', 'left', 'right']}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} style={styles.back}>
          <Text style={styles.backLabel} allowFontScaling={false}>
            Retour
          </Text>
        </Pressable>

        <Text style={styles.title} allowFontScaling={false}>
          Vos réponses
        </Text>
        <Text style={styles.subtitle}>
          {answered} sur {items.length} · chaque réponse ajuste vos compatibilités
        </Text>

        {progress ? (
          <View style={styles.bar}>
            <View
              style={[
                styles.barFill,
                { width: `${Math.min(100, (answered / Math.max(items.length, 1)) * 100)}%` },
              ]}
            />
          </View>
        ) : null}

        <View style={styles.filters}>
          {(
            [
              ['todo', `À répondre (${items.filter((i) => i.answer === null).length})`],
              ['all', `Toutes (${items.length})`],
            ] as [Filter, string][]
          ).map(([value, label]) => (
            <Pressable
              key={value}
              onPress={() => setFilter(value)}
              style={[styles.filter, filter === value ? styles.filterActive : null]}
            >
              <Text
                style={[
                  styles.filterLabel,
                  filter === value ? styles.filterLabelActive : null,
                ]}
                allowFontScaling={false}
              >
                {label}
              </Text>
            </Pressable>
          ))}
        </View>
      </View>

      <FlatList
        data={visible}
        keyExtractor={(item) => item.key}
        renderItem={({ item }) => (
          <QuestionCard
            item={item}
            saving={saving.has(item.key)}
            error={rowErrors[item.key] ?? null}
            onSelect={(target, idx) => void onSelect(target, idx)}
          />
        )}
        contentContainerStyle={styles.list}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
        showsVerticalScrollIndicator={false}
        initialNumToRender={8}
        windowSize={7}
        // Le pied de liste est toujours présent : après la dernière question,
        // l'écran doit dire où l'on va, jamais s'arrêter dans le vide.
        ListFooterComponent={footer}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Text style={styles.footerBody}>
              Toutes les questions sont renseignées. Basculez sur « Toutes » pour en modifier une.
            </Text>
          </View>
        }
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: colors.background,
  },
  header: {
    paddingHorizontal: spacing.gutter,
    paddingTop: spacing.md,
    paddingBottom: spacing.lg,
    gap: spacing.sm,
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
  },
  bar: {
    height: spacing.xs,
    borderRadius: radius.pill,
    backgroundColor: colors.surfaceAlt,
    overflow: 'hidden',
    marginTop: spacing.xs,
  },
  barFill: {
    height: '100%',
    borderRadius: radius.pill,
    backgroundColor: colors.accent,
  },
  filters: {
    flexDirection: 'row',
    gap: spacing.sm,
    marginTop: spacing.sm,
  },
  filter: {
    borderRadius: radius.pill,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    backgroundColor: colors.surfaceAlt,
  },
  filterActive: {
    backgroundColor: colors.accent,
  },
  filterLabel: {
    ...typography.caption,
    color: colors.textSecondary,
  },
  filterLabelActive: {
    color: colors.onAccent,
  },
  list: {
    paddingHorizontal: spacing.gutter,
    paddingBottom: spacing.giant,
  },
  separator: {
    height: spacing.md,
  },
  footer: {
    marginTop: spacing.xl,
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    padding: spacing.xl,
    gap: spacing.sm,
  },
  footerTitle: {
    ...typography.heading,
    color: colors.textPrimary,
  },
  footerBody: {
    ...typography.body,
    color: colors.textSecondary,
  },
  footerError: {
    ...typography.caption,
    color: colors.danger,
  },
  footerAction: {
    marginTop: spacing.sm,
  },
  empty: {
    paddingHorizontal: spacing.xs,
  },
});
