import { ActivityIndicator, Pressable, StyleSheet, Text } from 'react-native';
import Animated, {
  Easing,
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';

import { colors, elevation, motion, opacity, radius, spacing, typography } from '../theme';

interface ButtonProps {
  label: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary';
  loading?: boolean;
  disabled?: boolean;
}

export function Button({
  label,
  onPress,
  variant = 'primary',
  loading = false,
  disabled = false,
}: ButtonProps) {
  const inactive = disabled || loading;
  const scale = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const press = (to: number) => {
    scale.value = withTiming(to, {
      duration: motion.press,
      easing: Easing.bezier(...motion.curve),
    });
  };

  return (
    <Animated.View style={animatedStyle}>
      <Pressable
        onPress={onPress}
        onPressIn={() => !inactive && press(motion.pressScale)}
        onPressOut={() => !inactive && press(1)}
        disabled={inactive}
        style={[
          styles.base,
          variant === 'primary' ? styles.primary : styles.secondary,
          inactive ? styles.disabled : null,
        ]}
      >
        {loading ? (
          <ActivityIndicator color={variant === 'primary' ? colors.onAccent : colors.textMuted} />
        ) : (
          <Text
            style={[
              styles.label,
              variant === 'primary' ? styles.labelPrimary : styles.labelSecondary,
            ]}
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
  base: {
    borderRadius: radius.pill,
    paddingVertical: spacing.lg,
    paddingHorizontal: spacing.xxl,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primary: {
    backgroundColor: colors.accent,
    ...elevation.soft,
  },
  secondary: {
    backgroundColor: colors.surfaceAlt,
  },
  disabled: {
    opacity: opacity.disabled,
  },
  label: {
    ...typography.label,
  },
  labelPrimary: {
    color: colors.onAccent,
  },
  labelSecondary: {
    color: colors.textSecondary,
  },
});
