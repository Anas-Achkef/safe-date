import { LinearGradient } from 'expo-linear-gradient';
import { Image, StyleSheet, Text, View } from 'react-native';
import type { StyleProp, ViewStyle } from 'react-native';

import { avatarBlobs, avatarGradient, colors, fonts, radius } from '../theme';

interface AvatarProps {
  /** Identifiant du profil : le visuel en découle et reste stable. */
  seed: string;
  firstName: string | null;
  /** Photographie du profil. Le dégradé sert de repli quand elle est absente. */
  photo?: string | null;
  /** Côté du carré, ou `fill` pour occuper le parent. */
  size?: number | 'fill';
  rounded?: keyof typeof radius;
  style?: StyleProp<ViewStyle>;
}

/**
 * Visuel de profil sans photographie.
 *
 * Aucune image de personne réelle n'est employée : un visage emprunté à une
 * banque d'images et posé sur un faux profil de rencontre poserait un problème
 * de droit à l'image. Chaque profil reçoit à la place un dégradé chaud et
 * quelques formes organiques, dérivés de son identifiant — le rendu varie d'un
 * profil à l'autre et ne change jamais pour un même profil.
 *
 * Dès qu'une photographie existe, elle se substitue à ce visuel sans modifier
 * l'appelant. En démonstration, `src/preview/photos.ts` en fournit — voir
 * l'avertissement qui y figure sur le droit à l'image.
 */
export function Avatar({
  seed,
  firstName,
  photo = null,
  size = 'fill',
  rounded = 'lg',
  style,
}: AvatarProps) {
  const teintes = avatarGradient(seed);
  const formes = avatarBlobs(seed);
  const initiale = firstName?.trim().charAt(0).toUpperCase() ?? null;
  const carre = size === 'fill' ? null : { width: size, height: size };
  const cote = size === 'fill' ? 320 : size;

  if (photo) {
    return (
      <View style={[styles.cadre, { borderRadius: radius[rounded] }, carre, style]}>
        <Image source={{ uri: photo }} style={styles.fond} resizeMode="cover" />
      </View>
    );
  }

  return (
    <View style={[styles.cadre, { borderRadius: radius[rounded] }, carre, style]}>
      <LinearGradient
        colors={[teintes[0], teintes[1], teintes[2]]}
        start={{ x: 0.1, y: 0 }}
        end={{ x: 0.9, y: 1 }}
        style={styles.fond}
      >
        {/* Formes organiques : elles donnent de la matière au dégradé, sans
            jamais suggérer une silhouette. */}
        {formes.map((f, i) => (
          <View
            key={i}
            style={[
              styles.forme,
              {
                left: `${f.x * 100 - f.r * 50}%`,
                top: `${f.y * 100 - f.r * 50}%`,
                width: cote * f.r,
                height: cote * f.r,
                borderRadius: cote * f.r,
                opacity: f.o,
              },
            ]}
          />
        ))}

        {initiale ? (
          <Text style={[styles.initiale, { fontSize: cote * 0.34 }]} allowFontScaling={false}>
            {initiale}
          </Text>
        ) : null}
      </LinearGradient>
    </View>
  );
}

const styles = StyleSheet.create({
  cadre: {
    overflow: 'hidden',
    backgroundColor: colors.surfaceAlt,
  },
  fond: {
    width: '100%',
    height: '100%',
    alignItems: 'center',
    justifyContent: 'center',
  },
  forme: {
    position: 'absolute',
    backgroundColor: colors.onPhoto,
  },
  initiale: {
    fontFamily: fonts.displayLight,
    color: colors.onPhoto,
    opacity: 0.9,
    includeFontPadding: false,
  },
});
