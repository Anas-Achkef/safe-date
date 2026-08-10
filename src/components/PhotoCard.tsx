import { LinearGradient } from 'expo-linear-gradient';
import { Image, StyleSheet, Text, View } from 'react-native';

import { colors, radius, spacing, typography } from '../theme';

interface PhotoCardProps {
  /** URL de la photo. `null` tant que le back-end n'en fournit pas. */
  photo: string | null;
  firstName: string | null;
  age: number | null;
  /** Score global, affiché en pastille discrète. `null` si masqué. */
  score: number | null;
  /** Identifiant, utilisé pour varier le visuel de substitution. */
  seed: string;
  height: number;
}

/**
 * La photo du profil, et ce qui se pose dessus.
 *
 * `user_photos` est encore vide et `candidate_cards.photo` renvoie `null` :
 * en attendant, on affiche un aplat dégradé dérivé de l'identifiant, avec
 * l'initiale du prénom. Aucun visage inventé, aucune image d'emprunt — dès que
 * `photo` sera renseigné, l'image prend simplement la place du dégradé.
 */
export function PhotoCard({ photo, firstName, age, score, seed, height }: PhotoCardProps) {
  const initial = firstName?.trim().charAt(0).toUpperCase() ?? null;

  // Le dégradé pivote légèrement selon le profil : deux cartes voisines ne se
  // ressemblent pas tout à fait.
  const tilt = (seed.charCodeAt(0) + seed.charCodeAt(seed.length - 1)) % 3;
  const starts: [number, number][] = [
    [0, 0],
    [1, 0],
    [0.3, 0],
  ];

  return (
    <View style={[styles.card, { height }]}>
      {photo ? (
        <Image source={{ uri: photo }} style={styles.image} resizeMode="cover" />
      ) : (
        <LinearGradient
          colors={[colors.placeholderFrom, colors.placeholderTo]}
          start={{ x: starts[tilt][0], y: starts[tilt][1] }}
          end={{ x: 1, y: 1 }}
          style={styles.image}
        >
          {initial ? (
            <View style={styles.initialWrap}>
              <Text style={styles.initial} allowFontScaling={false}>
                {initial}
              </Text>
            </View>
          ) : null}
        </LinearGradient>
      )}

      {/* Voile bas : garantit la lisibilité du prénom quelle que soit l'image. */}
      <LinearGradient
        colors={['rgba(0,0,0,0)', 'rgba(0,0,0,0.55)']}
        style={styles.scrim}
      />

      <View style={styles.footer}>
        <View style={styles.identity}>
          <Text style={styles.name} numberOfLines={1} allowFontScaling={false}>
            {firstName ?? 'Profil masqué'}
          </Text>
          {age !== null ? (
            <Text style={styles.age} allowFontScaling={false}>
              {age} ans
            </Text>
          ) : null}
        </View>

        {score !== null ? (
          <View style={styles.badge}>
            <Text style={styles.badgeValue} allowFontScaling={false}>
              {Math.round(score)} %
            </Text>
          </View>
        ) : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: radius.lg,
    overflow: 'hidden',
    backgroundColor: colors.surfaceAlt,
  },
  image: {
    width: '100%',
    height: '100%',
    alignItems: 'center',
    justifyContent: 'center',
  },
  initialWrap: {
    opacity: 0.35,
  },
  initial: {
    fontFamily: typography.name.fontFamily,
    fontSize: 96,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
  scrim: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    height: '45%',
    pointerEvents: 'none',
  },
  footer: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    padding: spacing.xl,
    gap: spacing.md,
  },
  identity: {
    flex: 1,
  },
  name: {
    ...typography.name,
    color: colors.onPhoto,
    includeFontPadding: false,
  },
  age: {
    ...typography.body,
    color: colors.onPhoto,
    opacity: 0.85,
    marginTop: spacing.xs,
  },
  badge: {
    backgroundColor: 'rgba(255,255,255,0.92)',
    borderRadius: radius.pill,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
  },
  badgeValue: {
    ...typography.scoreValue,
    color: colors.textPrimary,
  },
});
