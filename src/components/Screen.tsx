import type { ReactNode } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { isPreviewMode } from '../preview';
import { colors, spacing, typography } from '../theme';

interface ScreenProps {
  title?: string;
  subtitle?: string;
  children: ReactNode;
  /** Supprime le rembourrage horizontal : la vue gère elle-même ses marges. */
  flush?: boolean;
}

export function Screen({ title, subtitle, children, flush = false }: ScreenProps) {
  return (
    <SafeAreaView style={styles.safe} edges={['top', 'left', 'right']}>
      {isPreviewMode ? (
        <View style={styles.previewBanner}>
          <Text style={styles.previewText} allowFontScaling={false}>
            APERÇU — DONNÉES DE DÉMONSTRATION
          </Text>
        </View>
      ) : null}

      {title || subtitle ? (
        <View style={styles.header}>
          {title ? (
            <Text style={styles.title} allowFontScaling={false}>
              {title}
            </Text>
          ) : null}
          {subtitle ? <Text style={styles.subtitle}>{subtitle}</Text> : null}
        </View>
      ) : null}

      <View style={[styles.body, flush ? null : styles.bodyPadded]}>{children}</View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: colors.background,
  },
  header: {
    paddingHorizontal: spacing.gutter,
    paddingTop: spacing.lg,
    paddingBottom: spacing.md,
  },
  title: {
    ...typography.display,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
  subtitle: {
    ...typography.body,
    color: colors.textMuted,
    marginTop: spacing.xs,
  },
  body: {
    flex: 1,
  },
  bodyPadded: {
    paddingHorizontal: spacing.gutter,
  },
  previewBanner: {
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.gutter,
    backgroundColor: colors.accentSoft,
  },
  previewText: {
    ...typography.overline,
    color: colors.textSecondary,
    textAlign: 'center',
  },
});
