import { StyleSheet, View, type StyleProp, type ViewStyle } from 'react-native';

import { colors, composants, spacing } from '../../theme';

/**
 * L'indicateur de photos — nodes Figma 3:384 et 9:626.
 *
 * Un segment par photo, le segment courant en blanc plein, les autres
 * effacés. Il ne s'affiche qu'à partir de deux photos : un unique segment
 * plein largeur ne dit rien et ajoute un trait sur le visage.
 *
 * Décoratif au sens strict — la navigation entre photos se fait ailleurs —
 * donc masqué aux lecteurs d'écran et neutre aux gestes.
 */

interface IndicateurPhotosProps {
  nombre: number;
  /** Index de la photo affichée, à partir de 0. */
  courante: number;
  style?: StyleProp<ViewStyle>;
}

/** Opacité d'un segment que l'on n'est pas en train de regarder. */
const EFFACE = 0.4;

export function IndicateurPhotos({ nombre, courante, style }: IndicateurPhotosProps) {
  if (nombre < 2) return null;

  return (
    <View
      style={[styles.rangee, style]}
      accessibilityElementsHidden
      importantForAccessibility="no-hide-descendants"
    >
      {Array.from({ length: nombre }, (_, i) => (
        <View
          key={i}
          style={[styles.segment, i === courante ? styles.courant : styles.efface]}
        />
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  rangee: {
    flexDirection: 'row',
    gap: composants.decouverte.segmentGap,
    pointerEvents: 'none',
  },
  segment: {
    flex: 1,
    height: composants.decouverte.segment,
    borderRadius: spacing.demi,
    backgroundColor: colors.onPhoto,
  },
  courant: { opacity: 1 },
  efface: { opacity: EFFACE },
});
