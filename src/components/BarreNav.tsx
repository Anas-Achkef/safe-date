import type { ReactNode } from 'react';
import { StyleSheet, View } from 'react-native';

import { colors, hairline, spacing } from '../theme';
import { MarqueSafeDate } from './MarqueSafeDate';

interface Props {
  /** Ce qui se place à droite : filtre, réglages, rien. */
  droite?: ReactNode;
  /** Le mot « SafeDate » à côté du symbole. Coupé sur les écrans denses. */
  motMarque?: boolean;
}

/**
 * La barre de marque, en haut de chaque écran.
 *
 * Le logo est toujours à gauche, à la même place et à la même taille, d'un
 * écran à l'autre : c'est ce qui en fait un repère plutôt qu'une décoration.
 * La droite est laissée libre.
 */
export function BarreNav({ droite, motMarque = true }: Props) {
  return (
    <View style={styles.barre}>
      <MarqueSafeDate taille={30} motMarque={motMarque} />
      <View style={styles.droite}>{droite}</View>
    </View>
  );
}

const styles = StyleSheet.create({
  barre: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: spacing.gutter,
    paddingTop: spacing.sm,
    paddingBottom: spacing.sm,
    borderBottomWidth: hairline,
    borderBottomColor: colors.rule,
  },
  droite: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
});
