import { useEffect } from 'react';
import type { ReactNode } from 'react';
import type { ViewStyle } from 'react-native';
import Animated, {
  Easing,
  useAnimatedStyle,
  useSharedValue,
  withDelay,
  withTiming,
} from 'react-native-reanimated';

import { motion } from '../theme';

interface RiseProps {
  children: ReactNode;
  /** Rang du palier : 0, 1, 2, 3. Le décalage est appliqué automatiquement. */
  step?: number;
  /** Rejoue l'apparition quand la valeur change. */
  trigger?: unknown;
  active?: boolean;
  style?: ViewStyle;
}

/**
 * Apparition par paliers décalés : translation de 12 px vers le haut et
 * opacité de 0 à 1, avec 60 ms d'écart entre deux rangs successifs.
 *
 * Toutes les courbes de l'application passent par `motion.curve`. Rien ne
 * claque, rien ne rebondit.
 */
export function Rise({ children, step = 0, trigger, active = true, style }: RiseProps) {
  const progress = useSharedValue(active ? 0 : 1);

  useEffect(() => {
    if (!active) {
      progress.value = 1;
      return;
    }
    progress.value = 0;
    progress.value = withDelay(
      step * motion.stagger,
      withTiming(1, { duration: motion.reveal, easing: Easing.bezier(...motion.curve) }),
    );
  }, [active, progress, step, trigger]);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: progress.value,
    transform: [{ translateY: (1 - progress.value) * motion.rise }],
  }));

  return <Animated.View style={[style, animatedStyle]}>{children}</Animated.View>;
}
