import { useEffect, useRef, useState } from 'react';
import { Animated, Easing, View } from 'react-native';
import Svg, { Circle, Path } from 'react-native-svg';

import { colors } from '../theme';

/**
 * Indicateur de chargement.
 *
 * Le rond parcourt la barre jusqu'au point de rendez-vous, s'y loge le temps
 * d'une onde, puis revient a sa place. C'est le trajet que raconte
 * l'application, pas une rotation : un pin qui tournoie dirait le contraire
 * de ce que la marque promet.
 *
 * Les geometries sont recalculees a chaque image plutot que confiees a des
 * composants animes : sur react-native-web, `createAnimatedComponent` ne
 * propage pas les proprietes de transformation propres a react-native-svg, et
 * les formes ainsi animees levaient une erreur au rendu.
 *
 * Purement decoratif, donc masque aux lecteurs d'ecran — c'est le texte qui
 * l'accompagne qui porte l'information.
 */

/** Du centre du rond (30, 26) au centre du pin (70, 57). */
const TRAJET_X = 40;
const TRAJET_Y = 31;

/** Interpolation lineaire par morceaux, sur des paliers ordonnes. */
function palier(t: number, entrees: number[], sorties: number[]): number {
  for (let i = 1; i < entrees.length; i += 1) {
    if (t <= entrees[i]) {
      const etendue = entrees[i] - entrees[i - 1];
      const part = etendue === 0 ? 0 : (t - entrees[i - 1]) / etendue;
      return sorties[i - 1] + (sorties[i] - sorties[i - 1]) * part;
    }
  }
  return sorties[sorties.length - 1];
}

/** L'etat complet du glyphe a l'avancement `t`. */
function etatA(t: number, petit: boolean) {
  const trait = petit ? 9 : 7;
  const rayon = petit ? 14 : 13;

  const avanceX = palier(t, [0, 0.08, 0.36, 0.68, 0.94, 1], [0, 0, TRAJET_X, TRAJET_X, 0, 0]);
  const avanceY = palier(t, [0, 0.08, 0.36, 0.68, 0.94, 1], [0, 0, TRAJET_Y, TRAJET_Y, 0, 0]);
  // A l'arrivee il se retracte pour se loger dans le creux du pin, dont il
  // devient le point central. Sans cela les deux formes se chevauchent.
  const retrait = palier(t, [0, 0.36, 0.44, 0.6, 0.68, 1], [1, 1, 0.32, 0.32, 1, 1]);

  const pinOpacite = palier(t, [0, 0.38, 0.46, 0.62, 0.7, 1], [0, 0, 1, 1, 0, 0]);
  const pose = palier(t, [0, 0.38, 0.46, 0.52, 1], [0.7, 0.7, 1.08, 1, 1]);

  const ondeOpacite = palier(t, [0, 0.44, 0.54, 0.76, 1], [0, 0, 0.4, 0, 0]);
  const expansion = palier(t, [0, 0.44, 0.76, 1], [1, 1, 2.5, 2.5]);

  return {
    rond: {
      cx: 30 + avanceX,
      cy: 26 + avanceY,
      r: rayon * retrait,
      trait: trait * retrait,
    },
    onde: { r: 15 * expansion, opacite: ondeOpacite },
    pin: {
      opacite: pinOpacite,
      // La mise a l'echelle s'entoure de deux translations, sinon elle se
      // ferait autour de l'origine du cadre.
      transform: `translate(70 66) scale(${pose}) translate(-70 -66)`,
    },
  };
}

interface LoaderProps {
  /** Cote du glyphe en points. 96 par defaut, 32 pour un usage en ligne. */
  size?: number;
  color?: string;
}

export function Loader({ size = 96, color = colors.textPrimary }: LoaderProps) {
  // Le creux du pin se bouche au rendu sous 32 points : version pleine alors.
  const petit = size < 32;
  const progression = useRef(new Animated.Value(0)).current;
  const [forme, setForme] = useState(() => etatA(0, petit));

  useEffect(() => {
    const abonnement = progression.addListener(({ value }) => setForme(etatA(value, petit)));
    const boucle = Animated.loop(
      Animated.timing(progression, {
        toValue: 1,
        duration: 2600,
        easing: Easing.bezier(0.65, 0, 0.35, 1),
        useNativeDriver: false,
      }),
    );
    boucle.start();
    return () => {
      boucle.stop();
      progression.removeListener(abonnement);
    };
  }, [progression, petit]);

  return (
    <View accessibilityElementsHidden importantForAccessibility="no-hide-descendants">
      <Svg width={size} height={size} viewBox="0 0 100 100">
        <Path
          d="M20 82 L80 14"
          stroke={color}
          strokeWidth={petit ? 9 : 7}
          strokeLinecap="round"
          fill="none"
        />

        <Circle
          cx={70}
          cy={57}
          r={forme.onde.r}
          stroke={color}
          strokeWidth={3}
          fill="none"
          opacity={forme.onde.opacite}
        />

        <Path
          d={
            petit
              ? 'M70 90 L56 66 A 16 16 0 1 1 84 66 Z'
              : 'M70 88 L57 66 A 15 15 0 1 1 83 66 Z M75.5 57 A 5.5 5.5 0 1 1 64.5 57 A 5.5 5.5 0 1 1 75.5 57 Z'
          }
          fill={color}
          fillRule="evenodd"
          opacity={forme.pin.opacite}
          transform={forme.pin.transform}
        />

        <Circle
          cx={forme.rond.cx}
          cy={forme.rond.cy}
          r={forme.rond.r}
          stroke={color}
          strokeWidth={forme.rond.trait}
          fill="none"
        />
      </Svg>
    </View>
  );
}
