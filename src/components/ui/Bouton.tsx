import {
  ActivityIndicator,
  Pressable,
  StyleSheet,
  Text,
  View,
  type StyleProp,
  type ViewStyle,
} from 'react-native';
import Animated, {
  Easing,
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';

import {
  colors,
  composants,
  elevation,
  marque,
  motion,
  opacity,
  radius,
  typography,
} from '../../theme';

/**
 * Le bouton du système — node Figma 2:117.
 *
 * Une pilule de 56 points, quatre variantes et une seule règle d'emploi :
 *
 * - `primaire` — l'action principale, **une seule par écran**. C'est la seule
 *   qui porte l'ombre corail ; en poser deux les annule toutes les deux.
 * - `sombre` — une alternative forte, quand l'écran est déjà porté par le
 *   corail (une photo, un dégradé) et qu'un second corail se perdrait.
 * - `secondaire` — une action neutre : blanc, contour discret.
 * - `fantome` — une action tertiaire, sans fond ni contour. C'est la variante
 *   du refus : refuser une demande est un choix ordinaire, pas une
 *   destruction, et ne se dit donc jamais en rouge.
 */

export type VarianteBouton = 'primaire' | 'secondaire' | 'sombre' | 'fantome';

interface BoutonProps {
  libelle: string;
  onPress: () => void;
  variante?: VarianteBouton;
  /** Remplace le libellé par un indicateur, et bloque l'appui. */
  chargement?: boolean;
  desactive?: boolean;
  /** Une icône posée avant le libellé. Reçoit la couleur du texte. */
  icone?: (couleur: string) => React.ReactNode;
  /** Vrai par défaut : le bouton occupe toute la largeur disponible. */
  pleineLargeur?: boolean;
  style?: StyleProp<ViewStyle>;
}

/** Couleur du texte — et donc de l'icône — pour chaque variante. */
const TEINTE: Record<VarianteBouton, string> = {
  primaire: colors.onAccent,
  sombre: colors.onPhoto,
  secondaire: colors.textPrimary,
  fantome: colors.textSecondary,
};

export function Bouton({
  libelle,
  onPress,
  variante = 'primaire',
  chargement = false,
  desactive = false,
  icone,
  pleineLargeur = true,
  style,
}: BoutonProps) {
  const inactif = desactive || chargement;
  const echelle = useSharedValue(1);
  const teinte = TEINTE[variante];

  const anime = useAnimatedStyle(() => ({ transform: [{ scale: echelle.value }] }));

  const appuyer = (vers: number) => {
    echelle.value = withTiming(vers, {
      duration: motion.press,
      easing: Easing.bezier(...motion.curve),
    });
  };

  return (
    <Animated.View style={[anime, pleineLargeur ? styles.pleineLargeur : null, style]}>
      <Pressable
        accessibilityRole="button"
        accessibilityState={{ disabled: inactif, busy: chargement }}
        onPress={onPress}
        onPressIn={() => !inactif && appuyer(motion.pressScale)}
        onPressOut={() => !inactif && appuyer(1)}
        disabled={inactif}
        style={[styles.base, styles[variante], inactif ? styles.inactif : null]}
      >
        {chargement ? (
          <ActivityIndicator color={teinte} />
        ) : (
          <View style={styles.contenu}>
            {icone ? icone(teinte) : null}
            <Text style={[styles.libelle, { color: teinte }]} allowFontScaling={false}>
              {libelle}
            </Text>
          </View>
        )}
      </Pressable>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  pleineLargeur: { alignSelf: 'stretch' },
  base: {
    height: composants.bouton.hauteur,
    paddingHorizontal: composants.bouton.paddingH,
    borderRadius: radius.bouton,
    alignItems: 'center',
    justifyContent: 'center',
  },
  contenu: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: composants.bouton.gap,
  },
  primaire: {
    backgroundColor: colors.accent,
    ...elevation.boutonAccent,
  },
  secondaire: {
    backgroundColor: colors.surface,
    borderWidth: composants.bouton.trait,
    borderColor: colors.rule,
  },
  sombre: {
    backgroundColor: marque.nuit,
  },
  fantome: {
    backgroundColor: 'transparent',
  },
  inactif: {
    opacity: opacity.disabled,
  },
  libelle: {
    ...typography.bouton,
    includeFontPadding: false,
  },
});
