import { Pressable, StyleSheet, View } from 'react-native';

import { colors, composants, opacity, radius } from '../../theme';

/**
 * L'interrupteur — node Figma 11:730.
 *
 * Deux états seulement, sans libellé propre : c'est la ligne qui le porte qui
 * dit ce qu'il commande. Éteint, il reprend la surface secondaire plutôt
 * qu'un gris : sur un fond crème un gris neutre jure.
 */

interface InterrupteurProps {
  actif: boolean;
  onBascule: () => void;
  /** Décrit ce que l'interrupteur commande, pour les lecteurs d'écran. */
  libelle: string;
  desactive?: boolean;
}

export function Interrupteur({ actif, onBascule, libelle, desactive = false }: InterrupteurProps) {
  const course =
    composants.interrupteur.largeur -
    composants.interrupteur.pastille -
    composants.interrupteur.marge * 2;

  return (
    <Pressable
      accessibilityRole="switch"
      accessibilityLabel={libelle}
      accessibilityState={{ checked: actif, disabled: desactive }}
      onPress={onBascule}
      disabled={desactive}
      style={({ pressed }) => [
        styles.piste,
        actif ? styles.pisteActive : styles.pisteEteinte,
        pressed ? styles.appuye : null,
        desactive ? styles.inactif : null,
      ]}
    >
      <View style={[styles.pastille, { marginLeft: actif ? course : 0 }]} />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  piste: {
    width: composants.interrupteur.largeur,
    height: composants.interrupteur.hauteur,
    borderRadius: radius.pill,
    padding: composants.interrupteur.marge,
    justifyContent: 'center',
  },
  pisteActive: { backgroundColor: colors.accent },
  pisteEteinte: { backgroundColor: colors.surfaceAlt },
  appuye: { opacity: opacity.pressed },
  inactif: { opacity: opacity.disabled },
  pastille: {
    width: composants.interrupteur.pastille,
    height: composants.interrupteur.pastille,
    borderRadius: composants.interrupteur.pastille / 2,
    backgroundColor: colors.surface,
  },
});
