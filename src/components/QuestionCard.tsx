import { memo } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import type { QuestionnaireItem } from '../api/questionnaire';
import { colors, opacity, radius, spacing, typography } from '../theme';

interface QuestionCardProps {
  item: QuestionnaireItem;
  /** Vrai pendant l'enregistrement de cette question. */
  saving: boolean;
  error: string | null;
  onSelect: (item: QuestionnaireItem, optionIdx: number) => void;
}

/**
 * Une question et ses reponses possibles.
 *
 * Le choix s'enregistre immediatement : pas de bouton « valider », qui
 * transformerait le questionnaire en formulaire administratif. Un critere a
 * choix multiple bascule chaque option independamment.
 */
export const QuestionCard = memo(function QuestionCard({
  item,
  saving,
  error,
  onSelect,
}: QuestionCardProps) {
  const selected = new Set(item.answer ?? []);
  const answered = selected.size > 0;

  return (
    <View style={styles.card}>
      <View style={styles.head}>
        <Text style={styles.category} allowFontScaling={false}>
          {item.category}
          {item.multiSelect ? ' · PLUSIEURS CHOIX' : ''}
        </Text>
        {answered ? <View style={styles.done} /> : null}
      </View>

      <Text style={styles.question}>{item.question.replace(/\s*:\s*$/, '')}</Text>

      <View style={styles.options}>
        {item.options.map((option) => {
          const active = selected.has(option.idx);
          return (
            <Pressable
              key={option.idx}
              onPress={() => onSelect(item, option.idx)}
              disabled={saving}
              style={({ pressed }) => [
                styles.option,
                active ? styles.optionActive : null,
                pressed && !saving ? styles.optionPressed : null,
              ]}
            >
              <Text
                style={[styles.optionLabel, active ? styles.optionLabelActive : null]}
                allowFontScaling={false}
              >
                {option.label}
              </Text>
            </Pressable>
          );
        })}
      </View>

      {error ? <Text style={styles.error}>{error}</Text> : null}
    </View>
  );
});

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    padding: spacing.xl,
    gap: spacing.md,
  },
  head: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  category: {
    ...typography.overline,
    color: colors.textMuted,
  },
  done: {
    width: spacing.sm,
    height: spacing.sm,
    borderRadius: radius.pill,
    backgroundColor: colors.accent,
  },
  question: {
    ...typography.heading,
    color: colors.textPrimary,
  },
  options: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.sm,
  },
  option: {
    borderRadius: radius.pill,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    backgroundColor: colors.surfaceAlt,
  },
  optionActive: {
    backgroundColor: colors.accent,
  },
  optionPressed: {
    opacity: opacity.pressed,
  },
  optionLabel: {
    ...typography.label,
    color: colors.textSecondary,
  },
  optionLabelActive: {
    color: colors.onAccent,
  },
  error: {
    ...typography.caption,
    color: colors.danger,
  },
});
