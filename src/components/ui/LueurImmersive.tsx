import { StyleSheet, View } from 'react-native';
import Svg, { Circle, Defs, RadialGradient, Stop } from 'react-native-svg';

import { composants, decor } from '../../theme';

/**
 * La lueur de l'écran immersif — node Figma 10:633.
 *
 * Un disque rose très diffus posé sur le dégradé, derrière les portraits :
 * il éclaire le centre de l'écran et empêche le violet du milieu de dominer.
 * Dessinée en `react-native-svg` — `expo-linear-gradient` ne fait que du
 * linéaire, et un dégradé linéaire donnerait ici une bande, pas une lueur.
 *
 * Purement décorative : masquée aux lecteurs d'écran et neutre aux gestes.
 */
export function LueurImmersive() {
  const cote = composants.coupDeCoeur.lueur;

  return (
    <View
      style={styles.lueur}
      accessibilityElementsHidden
      importantForAccessibility="no-hide-descendants"
    >
      <Svg width={cote} height={cote} viewBox={`0 0 ${cote} ${cote}`} fill="none">
        <Defs>
          <RadialGradient id="lueur" cx="50%" cy="50%" r="50%">
            <Stop offset="0" stopColor={decor.lueurCentre} stopOpacity={decor.lueurOpaciteCentre} />
            <Stop offset="1" stopColor={decor.lueurCentre} stopOpacity={0} />
          </RadialGradient>
        </Defs>
        <Circle cx={cote / 2} cy={cote / 2} r={cote / 2} fill="url(#lueur)" />
      </Svg>
    </View>
  );
}

const styles = StyleSheet.create({
  lueur: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    alignItems: 'center',
    justifyContent: 'center',
    pointerEvents: 'none',
  },
});
