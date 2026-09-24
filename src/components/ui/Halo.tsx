import { StyleSheet, View } from 'react-native';
import Svg, { Defs, Ellipse, RadialGradient, Stop } from 'react-native-svg';

import { composants, decor } from '../../theme';

/**
 * Le halo de l'écran Parcourir — node Figma 3:82.
 *
 * Une ellipse rose très diffuse, posée en débord par le haut, qui réchauffe
 * le crème du fond sans rien signifier. Elle est dessinée en `react-native-svg`
 * parce que `expo-linear-gradient` ne fait que du linéaire — et un dégradé
 * linéaire à cet endroit donnerait une bande, pas une lueur.
 *
 * Purement décorative, donc masquée aux lecteurs d'écran et neutre aux
 * gestes : elle recouvre l'en-tête, elle ne doit pas en avaler les appuis.
 */
export function Halo() {
  return (
    <View
      style={styles.halo}
      accessibilityElementsHidden
      importantForAccessibility="no-hide-descendants"
    >
      <Svg
        width={composants.parcourir.haloLargeur}
        height={composants.parcourir.haloHauteur}
        viewBox={`0 0 ${composants.parcourir.haloLargeur} ${composants.parcourir.haloHauteur}`}
        fill="none"
      >
        <Defs>
          <RadialGradient id="halo" cx="50%" cy="50%" r="50%">
            <Stop offset="0" stopColor={decor.haloCentre} stopOpacity={decor.haloOpaciteCentre} />
            <Stop offset="1" stopColor={decor.haloBord} stopOpacity={0} />
          </RadialGradient>
        </Defs>
        <Ellipse
          cx={composants.parcourir.haloLargeur / 2}
          cy={composants.parcourir.haloHauteur / 2}
          rx={composants.parcourir.haloLargeur / 2}
          ry={composants.parcourir.haloHauteur / 2}
          fill="url(#halo)"
          opacity={decor.haloOpacite}
        />
      </Svg>
    </View>
  );
}

const styles = StyleSheet.create({
  halo: {
    position: 'absolute',
    left: composants.parcourir.haloGauche,
    top: composants.parcourir.haloHaut,
    pointerEvents: 'none',
  },
});
