import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';
import Animated, {
  Easing,
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';

import { colors, elevation, motion, opacity, radius, spacing, typography } from '../theme';

interface DecisionBarProps {
  onPass: () => void;
  onInterested: () => void;
  busy: boolean;
}

/**
 * Les deux seules actions possibles sur un profil.
 *
 * Pas de balayage : le produit propose peu de personnes, longuement
 * selectionnees. Un geste de rejet rapide irait contre ce parti pris ; deux
 * boutons explicites demandent un choix conscient.
 */
export function DecisionBar({ onPass, onInterested, busy }: DecisionBarProps) {
  return (
    <View style={styles.bar}>
      <ActionButton label="Passer" onPress={onPass} disabled={busy} tone="neutral" />
      <ActionButton
        label="Ça m’intéresse"
        onPress={onInterested}
        disabled={busy}
        tone="accent"
        busy={busy}
      />
    </View>
  );
}

function ActionButton({
  label,
  onPress,
  disabled,
  tone,
  busy = false,
}: {
  label: string;
  onPress: () => void;
  disabled: boolean;
  tone: 'neutral' | 'accent';
  busy?: boolean;
}) {
  const scale = useSharedValue(1);
  const animatedStyle = useAnimatedStyle(() => ({ transform: [{ scale: scale.value }] }));

  const press = (to: number) =>
    (scale.value = withTiming(to, {
      duration: motion.press,
      easing: Easing.bezier(...motion.curve),
    }));

  return (
    <Animated.View style={[styles.slot, animatedStyle]}>
      <Pressable
        onPress={onPress}
        onPressIn={() => !disabled && press(motion.pressScale)}
        onPressOut={() => !disabled && press(1)}
        disabled={disabled}
        style={[
          styles.button,
          tone === 'accent' ? styles.accent : styles.neutral,
          disabled ? styles.disabled : null,
        ]}
      >
        {busy ? (
          <ActivityIndicator color={colors.onAccent} />
        ) : (
          <Text
            style={[styles.label, tone === 'accent' ? styles.labelAccent : styles.labelNeutral]}
            allowFontScaling={false}
          >
            {label}
          </Text>
        )}
      </Pressable>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  bar: {
    flexDirection: 'row',
    gap: spacing.md,
    paddingTop: spacing.md,
  },
  slot: {
    flex: 1,
  },
  button: {
    borderRadius: radius.pill,
    paddingVertical: spacing.lg,
    alignItems: 'center',
    justifyContent: 'center',
  },
  neutral: {
    backgroundColor: colors.surfaceAlt,
  },
  accent: {
    backgroundColor: colors.accent,
    ...elevation.soft,
  },
  disabled: {
    opacity: opacity.disabled,
  },
  label: {
    ...typography.label,
  },
  labelNeutral: {
    color: colors.textSecondary,
  },
  labelAccent: {
    color: colors.onAccent,
  },
});
