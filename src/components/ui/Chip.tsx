import { Pressable, StyleSheet, Text, type StyleProp, type ViewStyle } from 'react-native';

import { IconeValider } from './Icones';
import { colors, composants, marque, opacity, radius, typography } from '../../theme';

/**
 * Le chip du système — node Figma 2:124.
 *
 * Sert aux critères, aux filtres et aux centres d'intérêt. Sélectionné, il
 * change trois choses à la fois : fond poudre, contour corail, coche. C'est
 * volontairement redondant — un seul de ces signaux ne se voit pas d'un coup
 * d'œil dans une grille de vingt.
 *
 * Le contour passe de 1 à 1,5 point à la sélection : la hauteur reste à 40,
 * c'est le rembourrage intérieur qui absorbe la différence.
 */

interface ChipProps {
  libelle: string;
  selectionne?: boolean;
  onPress?: () => void;
  desactive?: boolean;
  style?: StyleProp<ViewStyle>;
}

export function Chip({
  libelle,
  selectionne = false,
  onPress,
  desactive = false,
  style,
}: ChipProps) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected: selectionne, disabled: desactive }}
      onPress={onPress}
      disabled={desactive || !onPress}
      style={({ pressed }) => [
        styles.base,
        selectionne ? styles.selectionne : styles.defaut,
        pressed ? styles.appuye : null,
        desactive ? styles.inactif : null,
        style,
      ]}
    >
      {selectionne ? <IconeValider couleur={colors.accent} /> : null}
      <Text
        style={[styles.libelle, selectionne ? styles.libelleSelectionne : null]}
        allowFontScaling={false}
        numberOfLines={1}
      >
        {libelle}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    height: composants.chip.hauteur,
    paddingHorizontal: composants.chip.paddingH,
    borderRadius: radius.badge,
    flexDirection: 'row',
    alignItems: 'center',
    gap: composants.chip.gap,
    borderStyle: 'solid',
  },
  defaut: {
    backgroundColor: colors.surface,
    borderWidth: composants.chip.trait,
    borderColor: colors.rule,
  },
  selectionne: {
    backgroundColor: marque.poudreClair,
    borderWidth: composants.chip.traitSelection,
    borderColor: colors.accent,
  },
  appuye: {
    opacity: opacity.pressed,
  },
  inactif: {
    opacity: opacity.disabled,
  },
  libelle: {
    ...typography.chip,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
  libelleSelectionne: {
    color: colors.accent,
  },
});
