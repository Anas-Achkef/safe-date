import { useEffect, useRef, useState } from 'react';
import { Animated, Easing, View } from 'react-native';
import type { StyleProp, ViewStyle } from 'react-native';
import Svg, {
  Circle,
  Defs,
  LinearGradient,
  Path,
  Rect,
  Stop,
  Text as SvgText,
} from 'react-native-svg';

import { colors, fonts, marque } from '../theme';

/**
 * Le logo Safe Date, et sa séquence d'ouverture.
 *
 * Le cœur se trace d'un trait, les deux personnes montent à leur place, la
 * cloche se pose devant, le mot arrive en dernier. L'ordre raconte le produit :
 * la rencontre d'abord, le lieu ensuite.
 *
 * Toutes les géométries sont recalculées à chaque image plutôt que confiées à
 * des composants animés. Sur react-native-web, `createAnimatedComponent` ne
 * propage pas les propriétés de transformation propres à react-native-svg —
 * les formes animées de cette manière levaient une erreur au rendu. Le coût
 * d'un recalcul par image, sur deux secondes et demie, est sans conséquence.
 */

const CADRE = { largeur: 200, hauteur: 190 } as const;

/**
 * Longueur du tracé du cœur, en unités de la grille.
 *
 * Mesurée segment par segment sur les six courbes : `getTotalLength()` n'existe
 * pas dans react-native-svg, et une valeur trop grande ferait finir le tracé
 * avant la fin de son intervalle.
 */
const LONGUEUR_COEUR = 251;

const COEUR =
  'M50 92 C50 92 11 60 11 37 C11 22 22 13 33 13 C41 13 47 18 50 24 ' +
  'C53 18 59 13 67 13 C78 13 89 22 89 37 C89 60 50 92 50 92 Z';

const entre = (a: number, b: number, t: number) => a + (b - a) * t;

/** Ramène `t` sur l'intervalle [debut, fin], borné à [0, 1] en dehors. */
function palier(t: number, debut: number, fin: number): number {
  if (t <= debut) return 0;
  if (t >= fin) return 1;
  const x = (t - debut) / (fin - debut);
  // Adoucissement aux deux bouts : chaque élément arrive sans à-coup, même
  // quand son intervalle chevauche celui du précédent.
  return x * x * (3 - 2 * x);
}

/** L'ensemble des valeurs géométriques à l'avancement `t`. */
function compositionA(t: number) {
  const trace = palier(t, 0, 0.55);
  const gens = palier(t, 0.38, 0.68);
  const service = palier(t, 0.55, 0.82);
  const mot = palier(t, 0.45, 0.75);

  return {
    // Le trait se révèle en repoussant le décalage du pointillé : c'est le
    // dessin qui se fait, pas une forme qui apparaît.
    coeurOffset: entre(LONGUEUR_COEUR, 0, trace),
    gensOpacite: gens,
    // Les personnes montent de huit unités : elles se posent, elles
    // n'apparaissent pas.
    gensY: entre(8, 0, gens),
    serviceOpacite: service,
    serviceEchelle: entre(0.7, 1, service),
    serviceY: entre(10, 0, service),
    motOpacite: mot,
    motY: entre(10, 0, mot),
  };
}

interface LogoSafeDateProps {
  color?: string;
  /** Appelée une fois la séquence terminée, pour enchaîner. */
  onFinish?: () => void;
  /** Rend directement la composition finale, sans animation. */
  statique?: boolean;
  style?: StyleProp<ViewStyle>;
}

export function LogoSafeDate({
  color = colors.textPrimary,
  onFinish,
  statique = false,
  style,
}: LogoSafeDateProps) {
  const depart = statique ? 1 : 0;
  const progression = useRef(new Animated.Value(depart)).current;
  const [forme, setForme] = useState(() => compositionA(depart));

  useEffect(() => {
    if (statique) {
      setForme(compositionA(1));
      return;
    }

    const abonnement = progression.addListener(({ value }) => setForme(compositionA(value)));

    const sequence = Animated.timing(progression, {
      toValue: 1,
      duration: 1900,
      delay: 150,
      easing: Easing.linear,
      useNativeDriver: false,
    });
    sequence.start(({ finished }) => {
      if (finished) onFinish?.();
    });

    return () => {
      sequence.stop();
      progression.removeListener(abonnement);
    };
    // `onFinish` est volontairement hors des dépendances : une identité
    // changeante relancerait la séquence à chaque rendu du parent.
  }, [progression, statique]);

  // La cloche reprend la couleur du texte : sur le fond sombre de l'ouverture,
  // le bleu nuit de la marque disparaîtrait.
  const cloche = color;

  return (
    <View
      accessible
      accessibilityRole="image"
      accessibilityLabel="Safe Date"
      style={[styles.cadre, style]}
    >
      <Svg
        width="100%"
        height="100%"
        viewBox={`0 0 ${CADRE.largeur} ${CADRE.hauteur}`}
        fill="none"
      >
        <Defs>
          <LinearGradient id="ouverture" x1="0" y1="0" x2="1" y2="1">
            <Stop offset="0" stopColor={marque.coeurDebut} />
            <Stop offset="1" stopColor={marque.coeurFin} />
          </LinearGradient>
        </Defs>

        {/* Le contour au repos : il tient l'écran dès la première image pour
            que l'ouverture ne soit jamais un écran noir. Le tracé vient le
            remplir par-dessus. */}
        <Path
          d={COEUR}
          transform="translate(50 8)"
          stroke={color}
          strokeWidth={8}
          strokeLinejoin="round"
          strokeLinecap="round"
          fill="none"
          opacity={0.1}
        />
        <Path
          d={COEUR}
          transform="translate(50 8)"
          stroke="url(#ouverture)"
          strokeWidth={8}
          strokeLinejoin="round"
          strokeLinecap="round"
          strokeDasharray={LONGUEUR_COEUR}
          strokeDashoffset={forme.coeurOffset}
          fill="none"
        />

        <Circle
          cx={86}
          cy={48 + forme.gensY}
          r={6.5}
          fill="url(#ouverture)"
          opacity={forme.gensOpacite}
        />
        <Path
          d="M79 74 v-6 a7 7 0 0 1 14 0 v6 z"
          transform={`translate(0 ${forme.gensY})`}
          fill="url(#ouverture)"
          opacity={forme.gensOpacite}
        />
        <Circle
          cx={114}
          cy={48 + forme.gensY}
          r={6.5}
          fill="url(#ouverture)"
          opacity={forme.gensOpacite}
        />
        <Path
          d="M107 74 v-6 a7 7 0 0 1 14 0 v6 z"
          transform={`translate(0 ${forme.gensY})`}
          fill="url(#ouverture)"
          opacity={forme.gensOpacite}
        />

        {/* La cloche se pose : elle monte et grandit depuis le plateau. */}
        <Circle
          cx={100}
          cy={58}
          r={2.4}
          fill={cloche}
          opacity={forme.serviceOpacite}
          transform={`translate(0 ${forme.serviceY}) translate(100 74) scale(${forme.serviceEchelle}) translate(-100 -74)`}
        />
        <Path
          d="M87 74 a13 13 0 0 1 26 0 z"
          fill={cloche}
          opacity={forme.serviceOpacite}
          transform={`translate(0 ${forme.serviceY}) translate(100 74) scale(${forme.serviceEchelle}) translate(-100 -74)`}
        />
        <Rect
          x={78}
          y={73.5}
          width={44}
          height={5}
          rx={2.5}
          fill={cloche}
          opacity={forme.serviceOpacite}
          transform={`translate(0 ${forme.serviceY}) translate(100 74) scale(${forme.serviceEchelle}) translate(-100 -74)`}
        />

        <SvgText
          x={100}
          y={155}
          fontSize={34}
          fontFamily={fonts.displayRegular}
          fill={color}
          textAnchor="end"
          opacity={forme.motOpacite}
          transform={`translate(0 ${forme.motY})`}
        >
          Safe
        </SvgText>
        <SvgText
          x={100}
          y={155}
          fontSize={34}
          fontFamily={fonts.displayRegular}
          fill={marque.mot}
          textAnchor="start"
          opacity={forme.motOpacite}
          transform={`translate(0 ${forme.motY})`}
        >
          Date
        </SvgText>
      </Svg>
    </View>
  );
}

const styles = {
  cadre: {
    aspectRatio: CADRE.largeur / CADRE.hauteur,
    width: '100%',
  },
} as const;
