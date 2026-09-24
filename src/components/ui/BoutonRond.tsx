import { Pressable, StyleSheet, Text, View, type StyleProp, type ViewStyle } from 'react-native';

import { colors, composants, hairline, opacity, radius, spacing, typography } from '../../theme';

/**
 * Le bouton rond d'en-tête — nodes Figma 3:97 (filtres) et 11:679 (fermer).
 *
 * Un disque blanc de 44 points, contour discret, une icône au centre. Il ne
 * porte jamais de libellé : c'est une action d'écran, pas une action de
 * contenu — celles-là passent par `Bouton`.
 *
 * La pastille de compte se pose en débord sur le coin haut droit, pour dire
 * qu'un réglage est déjà en place sans ouvrir le panneau.
 */

interface BoutonRondProps {
  onPress: () => void;
  /** L'icône, qui reçoit la couleur du glyphe. */
  icone: (couleur: string) => React.ReactNode;
  /** Ce que fait le bouton, pour les lecteurs d'écran. */
  libelle: string;
  /** Nombre affiché en pastille. `0` ou absent : pas de pastille. */
  compte?: number;
  /**
   * Côté du disque. 44 en en-tête d'écran, 56 pour une action de décision —
   * qui porte alors un contour plus épais, à la mesure de son poids.
   */
  taille?: 'entete' | 'action';
  style?: StyleProp<ViewStyle>;
}

export function BoutonRond({
  onPress,
  icone,
  libelle,
  compte = 0,
  taille = 'entete',
  style,
}: BoutonRondProps) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={compte > 0 ? `${libelle} (${compte} actifs)` : libelle}
      onPress={onPress}
      style={({ pressed }) => [
        styles.bouton,
        taille === 'action' ? styles.action : null,
        pressed ? styles.appuye : null,
        style,
      ]}
    >
      {icone(colors.textPrimary)}
      {compte > 0 ? (
        <View style={styles.pastille}>
          <Text style={styles.compte} allowFontScaling={false}>
            {compte}
          </Text>
        </View>
      ) : null}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  bouton: {
    width: composants.boutonRond.cote,
    height: composants.boutonRond.cote,
    borderRadius: radius.pill,
    backgroundColor: colors.surface,
    borderWidth: hairline,
    borderColor: colors.rule,
    alignItems: 'center',
    justifyContent: 'center',
  },
  action: {
    width: composants.decouverte.actionCote,
    height: composants.decouverte.actionCote,
    borderWidth: composants.bouton.trait,
  },
  appuye: { opacity: opacity.pressed },
  pastille: {
    position: 'absolute',
    top: 0,
    right: 0,
    minWidth: composants.badge.icone,
    height: composants.badge.icone,
    paddingHorizontal: spacing.xs,
    borderRadius: radius.pill,
    backgroundColor: colors.accent,
    alignItems: 'center',
    justifyContent: 'center',
  },
  compte: {
    ...typography.caption,
    color: colors.onAccent,
    includeFontPadding: false,
  },
});
