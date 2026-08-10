import { Pressable, StyleSheet, Text, View } from 'react-native';
import {
  colors,
  elevation,
  radius,
  spacing,
  typography,
} from '../theme';
import type { FinDeSession as TFin } from '../types/learning';

interface Props {
  fin: TFin;
  onPartirEnDate: () => void;
  onPremium: () => void;
}

/**
 * Clôture positive de la session.
 *
 * Le pourcentage n'est ni un score de qualité ni un compteur de réponses :
 * c'est la confiance du moteur. Il peut reculer, et un recul signifie qu'il
 * doit revérifier certaines préférences, pas qu'il a perdu des données. Le
 * texte doit le dire, sinon l'utilisateur le lira comme une régression.
 */
export default function FinDeSession({ fin, onPartirEnDate, onPremium }: Props) {
  const pct = Math.round(fin.niveau * 100);
  const recul = fin.progression !== null && fin.progression < 0;
  const points = fin.progression !== null ? Math.round(fin.progression * 100) : null;

  return (
    <View style={styles.zone}>
      <View style={styles.haut}>
        <Text style={styles.message}>{fin.message}</Text>

        <View style={styles.jauge}>
          <View style={[styles.jaugeRemplie, { width: `${pct}%` }]} />
        </View>

        <Text style={styles.pourcentage}>{pct} %</Text>
        <Text style={styles.detail}>
          Votre profil est désormais connu à {pct} %.
          {points !== null &&
            (recul
              ? '\nCertaines préférences semblent avoir évolué : nous les revérifions.'
              : `\n+${points} ${points > 1 ? 'points' : 'point'} depuis la dernière session.`)}
        </Text>
      </View>

      <View style={styles.bas}>
        <Pressable style={styles.principal} onPress={onPartirEnDate}>
          <Text style={styles.principalTexte}>Partir en date</Text>
        </Pressable>

        {!fin.illimite && (
          <Pressable style={styles.premium} onPress={onPremium}>
            <Text style={styles.premiumTexte}>
              Swipes illimités ? Passer à Safe Date Premium
            </Text>
          </Pressable>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  zone: { flex: 1, padding: spacing.gutter, justifyContent: 'space-between' },
  haut: {
    marginTop: 'auto',
    backgroundColor: colors.surface,
    borderRadius: radius.lg,
    padding: spacing.xxl,
    alignItems: 'center',
    ...elevation.card,
  },
  message: {
    ...typography.display,
    color: colors.textPrimary,
    textAlign: 'center',
    marginBottom: spacing.xl,
  },
  jauge: {
    width: '100%',
    height: 6,
    borderRadius: radius.pill,
    backgroundColor: colors.surfaceAlt,
    overflow: 'hidden',
    marginBottom: spacing.md,
  },
  jaugeRemplie: { height: '100%', borderRadius: radius.pill, backgroundColor: colors.accent },
  pourcentage: { ...typography.name, color: colors.textPrimary },
  detail: {
    ...typography.caption,
    color: colors.textSecondary,
    textAlign: 'center',
    marginTop: spacing.sm,
  },
  bas: { marginTop: 'auto', gap: spacing.sm, paddingTop: spacing.xxxl },
  principal: {
    borderRadius: radius.md,
    backgroundColor: colors.accent,
    paddingVertical: spacing.lg,
    alignItems: 'center',
  },
  principalTexte: { ...typography.label, color: colors.onAccent },
  premium: {
    borderRadius: radius.md,
    backgroundColor: colors.accentSoft,
    paddingVertical: spacing.lg,
    alignItems: 'center',
  },
  premiumTexte: { ...typography.label, color: colors.accent },
});
