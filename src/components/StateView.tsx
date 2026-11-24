import { Pressable, StyleSheet, Text, View } from 'react-native';

import { colors, opacity, radius, spacing, typography } from '../theme';
import { Loader } from './Loader';

interface StateViewProps {
  variant: 'loading' | 'empty' | 'error';
  title: string;
  message?: string;
  actionLabel?: string;
  onAction?: () => void;
}

export function StateView({ variant, title, message, actionLabel, onAction }: StateViewProps) {
  return (
    <View style={styles.container}>
      {variant === 'loading' ? <Loader /> : null}

      <Text style={styles.title} allowFontScaling={false}>
        {title}
      </Text>
      {message ? <Text style={styles.message}>{message}</Text> : null}

      {actionLabel && onAction ? (
        <Pressable
          onPress={onAction}
          style={({ pressed }) => [styles.action, pressed ? styles.actionPressed : null]}
        >
          <Text style={styles.actionLabel} allowFontScaling={false}>
            {actionLabel}
          </Text>
        </Pressable>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: spacing.gutter,
    gap: spacing.lg,
  },
  title: {
    ...typography.heading,
    color: colors.textPrimary,
    textAlign: 'center',
  },
  message: {
    ...typography.body,
    color: colors.textMuted,
    textAlign: 'center',
  },
  action: {
    marginTop: spacing.sm,
    paddingHorizontal: spacing.xxl,
    paddingVertical: spacing.md,
    borderRadius: radius.pill,
    backgroundColor: colors.accentSoft,
  },
  actionPressed: {
    opacity: opacity.pressed,
  },
  actionLabel: {
    ...typography.label,
    color: colors.accent,
  },
});
