import { StyleSheet, Text, View } from 'react-native';

import type { CandidateHighlight } from '../types/rpc';
import { colors, radius, spacing, typography } from '../theme';

/**
 * Ce que vous avez en commun.
 *
 * Les libellés sont encore les questions brutes du questionnaire : les 896
 * formulations naturelles restent à fournir. On les présente donc le plus
 * doucement possible — réponse mise en avant, question en appui — sans tenter
 * une réécriture côté client qui serait à défaire ensuite.
 */
export function Highlights({ items }: { items: CandidateHighlight[] }) {
  if (items.length === 0) return null;

  return (
    <View style={styles.block}>
      <View style={styles.list}>
        {items.map((item, index) => (
          <View key={`${item.question}-${index}`} style={styles.item}>
            <Text style={styles.answer} numberOfLines={1} allowFontScaling={false}>
              {item.reponse}
            </Text>
            <Text style={styles.question} numberOfLines={2}>
              {item.question.replace(/\s*:\s*$/, '')}
            </Text>
          </View>
        ))}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  block: {
    gap: spacing.md,
  },
  list: {
    gap: spacing.sm,
  },
  item: {
    backgroundColor: colors.accentSoft,
    borderRadius: radius.sm,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    gap: spacing.xs,
  },
  answer: {
    ...typography.label,
    color: colors.textPrimary,
  },
  question: {
    ...typography.caption,
    color: colors.textSecondary,
  },
});
