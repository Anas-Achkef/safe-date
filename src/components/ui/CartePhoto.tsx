import { Image } from 'expo-image';
import { LinearGradient } from 'expo-linear-gradient';
import { StyleSheet, View, type StyleProp, type ViewStyle } from 'react-native';

import { Avatar } from '../Avatar';
import { colors, radius } from '../../theme';

/**
 * La photo d'un profil, et ce qui se pose dessus.
 *
 * Dans Figma les photos sont des emplacements dégradés nommés « Photo — … » :
 * ici, `photo` reçoit l'URL déjà signée par `src/api/`. `candidate_cards.photo`
 * ne renvoie qu'un chemin de stockage — il n'est jamais passé tel quel à ce
 * composant, la signature a lieu dans la couche d'accès.
 *
 * Quand la photo manque — profil sans image, ou photo masquée sous le seuil
 * premium — le dégradé de `Avatar`, dérivé de l'identifiant, prend sa place.
 * Aucun visage d'emprunt, et jamais de rectangle gris.
 *
 * Le voile bas n'est pas décoratif : sans lui un prénom blanc posé sur un ciel
 * clair devient illisible. Il est neutre aux gestes, sinon il avalerait les
 * appuis destinés au contenu.
 */

interface CartePhotoProps {
  /** URL signée de la photo. `null` déclenche le dégradé de repli. */
  photo: string | null;
  /** Identifiant du profil : il fixe le dégradé de repli. */
  seed: string;
  /** Sert à l'initiale du dégradé de repli et à la description. */
  prenom: string | null;
  /** Hauteur en points. À défaut, la carte suit son rapport. */
  hauteur?: number;
  /**
   * Rapport largeur / hauteur, quand la hauteur n'est pas imposée.
   * `null` laisse le parent décider — la carte remplit alors sa place.
   */
  rapport?: number | null;
  /**
   * Rayon des coins. 32 par défaut, le rayon photo du système.
   * `null` n'en pose aucun : à l'appelant de dessiner ses propres coins.
   */
  rayon?: number | null;
  /** Faux pour une photo sans rien posé dessus. */
  voile?: boolean;
  /** Ce qui se pose sur la photo : badges, prénom, actions. */
  children?: React.ReactNode;
  style?: StyleProp<ViewStyle>;
}

/** Part de la hauteur couverte par le voile. */
const VOILE = '52%';

export function CartePhoto({
  photo,
  seed,
  prenom,
  hauteur,
  rapport = 3 / 4,
  rayon = radius.photo,
  voile = true,
  children,
  style,
}: CartePhotoProps) {
  return (
    <View
      style={[
        styles.carte,
        rayon === null ? null : { borderRadius: rayon },
        hauteur !== undefined
          ? { height: hauteur }
          : rapport !== null
            ? { aspectRatio: rapport }
            : null,
        style,
      ]}
    >
      {photo ? (
        <Image
          source={{ uri: photo }}
          style={styles.image}
          contentFit="cover"
          transition={0}
          accessibilityLabel={prenom ? `Photo de ${prenom}` : 'Photo de profil'}
        />
      ) : (
        <Avatar seed={seed} firstName={prenom} style={styles.image} rounded="photo" />
      )}

      {voile ? <LinearGradient colors={colors.photoVoile} style={styles.voile} /> : null}

      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  carte: {
    overflow: 'hidden',
    backgroundColor: colors.surfaceAlt,
  },
  image: {
    width: '100%',
    height: '100%',
    alignItems: 'center',
    justifyContent: 'center',
  },
  voile: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    height: VOILE,
    pointerEvents: 'none',
  },
});
