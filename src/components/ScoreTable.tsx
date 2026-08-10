import { StyleSheet, Text, View } from 'react-native';

import { colors, radius, spacing, typography } from '../theme';

interface ScoreTableProps {
  valeurs: number | null;
  modeVie: number | null;
  physique: number | null;
}

/**
 * Les trois dimensions du score, en pastilles douces.
 *
 * Elles restent secondaires : le prénom et le visage passent avant. Aucune
 * couleur n'est conditionnée par la valeur — un accord de 18 % sur le physique
 * n'est pas un échec, c'est une information.
 */
export function ScoreTable({ valeurs, modeVie, physique }: ScoreTableProps) {
  const columns = [
    { label: 'Valeurs', value: valeurs },
    { label: 'Mode de vie', value: modeVie },
    { label: 'Physique', value: physique },
  ];

  if (columns.every((column) => column.value === null)) return null;

  return (
    <View style={styles.row}>
      {columns.map((column) => (
        <View key={column.label} style={styles.cell}>
          <Text style={styles.value} allowFontScaling={false}>
            {column.value === null ? '—' : Math.round(column.value)}
          </Text>
          <Text style={styles.label} allowFontScaling={false}>
            {column.label}
          </Text>
        </View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    gap: spacing.sm,
  },
  cell: {
    flex: 1,
    backgroundColor: colors.surfaceAlt,
    borderRadius: radius.sm,
    paddingVertical: spacing.md,
    alignItems: 'center',
    gap: spacing.xs,
  },
  value: {
    ...typography.subscoreValue,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
  label: {
    ...typography.caption,
    color: colors.textMuted,
  },
});
