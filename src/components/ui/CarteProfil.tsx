import { BlurView } from 'expo-blur';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { Badge } from './Badge';
import { CartePhoto } from './CartePhoto';
import { IconeCadenas, IconePhoto, IconeVerifie } from './Icones';
import { colors, composants, etats, opacity, radius, spacing, typography } from '../../theme';

/**
 * Les deux cartes de profil de l'écran Parcourir — nodes Figma 3:104 et 3:152.
 *
 * Elles ne diffèrent pas que par la taille : la carte d'affinité porte le
 * prénom **sur** la photo, la vignette de proximité le porte **dessous**. Ce
 * n'est pas un détail de mise en page — la première se lit comme une affiche,
 * la seconde comme une entrée de liste.
 *
 * Toutes deux affichent le score en badge translucide en haut à gauche, y
 * compris quand le profil est verrouillé : c'est le score qui donne envie
 * d'aller voir, pas le visage qu'on ne voit justement pas encore.
 */

interface Commun {
  prenom: string | null;
  age: number | null;
  /** URL déjà signée. `null` déclenche le dégradé de repli. */
  photo: string | null;
  seed: string;
  /** Score global, `null` s'il est masqué. */
  score: number | null;
  onPress: () => void;
}

/** Ce qui s'écrit quand le back-end ne renvoie pas le score. */
const SANS_SCORE = '——';

function texteScore(score: number | null): string {
  return score === null ? SANS_SCORE : `${Math.round(score)} %`;
}

/** L'emplacement d'une photo absente, repris du node 3:106. */
function Emplacement() {
  return (
    <View style={styles.emplacement}>
      <IconePhoto couleur={colors.onPhoto} />
    </View>
  );
}

interface CarteAffiniteProps extends Commun {
  /** Vrai quand seul l'abonnement révèle ce profil. */
  verrouille: boolean;
}

/** Node 3:104 — la carte du carrousel, 148 × 200. */
export function CarteAffinite({
  prenom,
  age,
  photo,
  seed,
  score,
  verrouille,
  onPress,
}: CarteAffiniteProps) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={
        verrouille
          ? `Profil à ${texteScore(score)} de compatibilité, révélable avec Premium`
          : `${prenom ?? 'Profil'}, ${texteScore(score)} de compatibilité`
      }
      onPress={onPress}
      style={({ pressed }) => [styles.affinite, pressed ? styles.appuye : null]}
    >
      <CartePhoto
        photo={verrouille ? null : photo}
        seed={seed}
        prenom={verrouille ? null : prenom}
        hauteur={composants.parcourir.affiniteHauteur}
        rayon={radius.carte}
      >
        {photo === null || verrouille ? <Emplacement /> : null}

        {/* Le flou se pose sur la photo, sous le badge : le score reste net. */}
        {verrouille ? (
          <BlurView
            intensity={composants.parcourir.flouPremium * 4}
            tint="dark"
            style={styles.flou}
          />
        ) : null}

        <Badge libelle={texteScore(score)} type="compatibilite" style={styles.badge} />

        {verrouille ? (
          <View style={styles.verrou}>
            <IconeCadenas couleur={colors.onPhoto} />
            <Text style={styles.verrouTexte} allowFontScaling={false}>
              Révéler avec Premium
            </Text>
          </View>
        ) : (
          <Text style={styles.affinitePrenom} numberOfLines={1} allowFontScaling={false}>
            {prenom ?? 'Profil masqué'}
            {age !== null ? `, ${age}` : ''}
          </Text>
        )}
      </CartePhoto>
    </Pressable>
  );
}

interface VignetteProps extends Commun {
  verifie: boolean;
}

/** Node 3:152 — la vignette de la grille de proximité, 166 × 212. */
export function VignetteProfil({
  prenom,
  age,
  photo,
  seed,
  score,
  verifie,
  onPress,
}: VignetteProps) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={`${prenom ?? 'Profil'}${age !== null ? `, ${age} ans` : ''}${
        verifie ? ', profil vérifié' : ''
      }`}
      onPress={onPress}
      style={({ pressed }) => [styles.vignette, pressed ? styles.appuye : null]}
    >
      <CartePhoto
        photo={photo}
        seed={seed}
        prenom={prenom}
        hauteur={composants.parcourir.vignetteHauteur}
        rayon={radius.carte}
        voile={false}
      >
        {photo === null ? <Emplacement /> : null}
        <Badge libelle={texteScore(score)} type="compatibilite" style={styles.badge} />
      </CartePhoto>

      <View style={styles.identite}>
        <Text style={styles.prenom} numberOfLines={1} allowFontScaling={false}>
          {prenom ?? 'Profil masqué'}
        </Text>
        {age !== null ? (
          <Text style={styles.age} allowFontScaling={false}>
            {age}
          </Text>
        ) : null}
        {verifie ? <IconeVerifie couleur={etats.securite} taille={composants.chip.coche} /> : null}
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  appuye: { opacity: opacity.pressed },

  affinite: { width: composants.parcourir.affiniteLargeur },
  affinitePrenom: {
    position: 'absolute',
    left: composants.parcourir.prenomGauche,
    right: spacing.sm,
    bottom: spacing.md,
    ...typography.h3,
    color: colors.onPhoto,
    includeFontPadding: false,
  },

  vignette: {
    width: composants.parcourir.vignetteLargeur,
    gap: composants.parcourir.vignetteGap,
  },
  identite: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: composants.badge.gap,
  },
  prenom: {
    ...typography.h3,
    color: colors.textPrimary,
    includeFontPadding: false,
    flexShrink: 1,
  },
  age: {
    ...typography.h3,
    color: colors.textMuted,
    includeFontPadding: false,
  },

  badge: {
    position: 'absolute',
    top: composants.parcourir.badgeDecalage,
    left: composants.parcourir.badgeDecalage,
  },
  flou: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  emplacement: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    alignItems: 'center',
    justifyContent: 'center',
    pointerEvents: 'none',
  },
  verrou: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: spacing.md,
    alignItems: 'center',
    gap: composants.badge.gap,
  },
  verrouTexte: {
    ...typography.caption,
    color: colors.onPhoto,
    includeFontPadding: false,
  },
});
