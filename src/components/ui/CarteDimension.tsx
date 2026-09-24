import { StyleSheet, Text, View } from 'react-native';

import { colors, composants, elevation, radius, spacing, typography } from '../../theme';

/**
 * Une dimension d'affinité — node Figma 9:650.
 *
 * Le chiffre, son nom, et une barre qui le redit. La barre n'est pas une
 * redondance décorative : un pourcentage isolé ne se compare pas d'un coup
 * d'œil, trois barres côte à côte oui.
 *
 * Un score absent ne s'écrit jamais `0 %` — ce serait affirmer une
 * incompatibilité qui n'a pas été mesurée. Il se rend en glyphes de même
 * chasse, et la barre reste vide.
 */

interface CarteDimensionProps {
  /** Score en pourcentage. `null` quand le back-end ne le renvoie pas. */
  valeur: number | null;
  libelle: string;
}

/** Ce qui s'écrit à la place d'un score non mesuré. */
const SANS_VALEUR = '—— %';

export function CarteDimension({ valeur, libelle }: CarteDimensionProps) {
  const part = valeur === null ? 0 : Math.min(100, Math.max(0, valeur));

  return (
    <View style={styles.carte}>
      <Text style={styles.valeur} allowFontScaling={false}>
        {valeur === null ? SANS_VALEUR : `${Math.round(valeur)} %`}
      </Text>
      <Text style={styles.libelle} numberOfLines={1}>
        {libelle}
      </Text>
      <View style={styles.rail}>
        <View style={[styles.remplissage, { width: `${part}%` }]} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  carte: {
    flex: 1,
    minWidth: 0,
    gap: spacing.sm,
    paddingHorizontal: composants.fiche.dimensionPaddingH,
    paddingVertical: composants.fiche.dimensionPaddingV,
    borderRadius: radius.md,
    backgroundColor: colors.surface,
    overflow: 'hidden',
    ...elevation.card,
  },
  valeur: {
    ...typography.chiffreMoyen,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
  libelle: { ...typography.caption, color: colors.textSecondary },
  rail: {
    height: composants.fiche.barre,
    borderRadius: composants.fiche.barre,
    backgroundColor: colors.surfaceAlt,
    overflow: 'hidden',
  },
  remplissage: {
    height: composants.fiche.barre,
    borderRadius: composants.fiche.barre,
    backgroundColor: colors.accent,
  },
});
