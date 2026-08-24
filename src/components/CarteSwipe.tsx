import { useEffect, type ReactNode } from 'react';
import { StyleSheet, Text, View, useWindowDimensions } from 'react-native';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import Animated, {
  interpolate,
  runOnJS,
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withTiming,
} from 'react-native-reanimated';
import { colors, radius, spacing, typography } from '../theme';

/** Distance de glissement au-delà de laquelle le geste vaut décision. */
const SEUIL = 96;

interface Props {
  children: ReactNode;
  /** Change à chaque profil : remet la carte au centre. */
  cle: string | number;
  onOui: () => void;
  onNon: () => void;
  /** Neutralise le côté droit sans masquer le profil. */
  ouiPossible?: boolean;
}

/**
 * L'horizontal décide, le vertical lit.
 *
 * Les deux gestes ne peuvent pas partager un axe : décider ferait défiler les
 * pages, ou l'inverse. Comme décider fait passer au profil suivant, aucun
 * geste de navigation supplémentaire n'est nécessaire.
 *
 * Le tampon apparaît progressivement pendant le glissement : on doit pouvoir
 * voir sa décision avant de la lâcher, et se raviser.
 */
export default function CarteSwipe({
  children,
  cle,
  onOui,
  onNon,
  ouiPossible = true,
}: Props) {
  const { width } = useWindowDimensions();
  const dx = useSharedValue(0);
  const sortie = useSharedValue(0);

  useEffect(() => {
    dx.value = 0;
    sortie.value = 0;
  }, [cle, dx, sortie]);

  const partir = (sens: 1 | -1, action: () => void) => {
    'worklet';
    sortie.value = 1;
    dx.value = withTiming(sens * (width + 120), { duration: 240 }, (fini) => {
      if (fini) runOnJS(action)();
    });
  };

  const geste = Gesture.Pan()
    .activeOffsetX([-14, 14])
    .failOffsetY([-18, 18])
    .onUpdate((e) => {
      dx.value = e.translationX;
    })
    .onEnd(() => {
      if (dx.value > SEUIL && ouiPossible) partir(1, onOui);
      else if (dx.value < -SEUIL) partir(-1, onNon);
      else dx.value = withSpring(0, { damping: 18, stiffness: 180 });
    });

  const carte = useAnimatedStyle(() => ({
    transform: [
      { translateX: dx.value },
      { rotate: `${interpolate(dx.value, [-width, 0, width], [-11, 0, 11])}deg` },
    ],
    opacity: sortie.value === 1 ? withTiming(0, { duration: 240 }) : 1,
  }));

  const tamponOui = useAnimatedStyle(() => ({
    opacity: interpolate(dx.value, [0, SEUIL], [0, 1], 'clamp'),
  }));
  const tamponNon = useAnimatedStyle(() => ({
    opacity: interpolate(dx.value, [-SEUIL, 0], [1, 0], 'clamp'),
  }));

  return (
    <GestureDetector gesture={geste}>
      <Animated.View style={[styles.zone, carte]}>
        {children}

        <Animated.View
          style={[styles.tampon, styles.tamponGauche, tamponOui, { pointerEvents: 'none' }]}
        >
          <Text style={[styles.tamponTexte, { color: colors.accent }]}>OUI</Text>
        </Animated.View>

        <Animated.View
          style={[styles.tampon, styles.tamponDroite, tamponNon, { pointerEvents: 'none' }]}
        >
          <Text style={[styles.tamponTexte, { color: colors.danger }]}>NON</Text>
        </Animated.View>
      </Animated.View>
    </GestureDetector>
  );
}

const styles = StyleSheet.create({
  zone: {
    flex: 1,
  },
  tampon: {
    position: 'absolute',
    top: spacing.xxl,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: radius.sm,
    borderWidth: 2.5,
    backgroundColor: colors.surface,
  },
  tamponGauche: {
    left: spacing.xl,
    transform: [{ rotate: '-12deg' }],
    borderColor: colors.accent,
  },
  tamponDroite: {
    right: spacing.xl,
    transform: [{ rotate: '12deg' }],
    borderColor: colors.danger,
  },
  tamponTexte: {
    ...typography.display,
    fontSize: 22,
    letterSpacing: 1,
  },
});
