import { StyleSheet, Text, View, type StyleProp, type ViewStyle } from 'react-native';
import Svg, { Circle, Ellipse, Path, Rect } from 'react-native-svg';

import { colors, composants, marque, typography } from '../../theme';

/**
 * Le logo Safe Date, redessiné en `react-native-svg`.
 *
 * Les tracés sont repris à l'identique de l'export Figma conservé dans
 * `assets/marque/` (nodes 1:170, 1:180 et 1:202) : même grille de 120 × 124,
 * mêmes coordonnées. Passer par `react-native-svg` plutôt que par une image
 * garde le trait net à toute taille et permet la déclinaison blanche sans
 * second fichier — un SVG posé dans une balise `Image` n'est de toute façon
 * pas rendu sur React Native.
 *
 * Les couleurs viennent de `marque` : une marque ne change pas de couleur
 * avec l'humeur de l'interface, elles ne suivent donc pas la palette.
 */

/** Rapport largeur / hauteur du symbole, imposé par la grille Figma. */
const RAPPORT = composants.logo.largeur / composants.logo.hauteur;

interface SymboleProps {
  /** Hauteur du symbole en points. La largeur en découle. */
  taille?: number;
  style?: StyleProp<ViewStyle>;
}

/** Le symbole seul, en une seule couleur. */
function Symbole({
  taille,
  couleurCoeur,
  couleurPersonneDroite,
  couleurCloche,
  couleurOmbre,
  opaciteOmbre,
}: {
  taille: number;
  couleurCoeur: string;
  couleurPersonneDroite: string;
  couleurCloche: string;
  couleurOmbre: string;
  opaciteOmbre: number;
}) {
  return (
    <Svg width={taille * RAPPORT} height={taille} viewBox="0 0 120 124" fill="none">
      {/* L'ombre au sol : c'est elle qui pose le cœur sur une table. */}
      <Ellipse cx={60} cy={117.5} rx={32} ry={4.5} fill={couleurOmbre} opacity={opaciteOmbre} />

      {/* Le cœur, tracé et non rempli : il encadre la scène au lieu de la
          cacher. Sa pointe basse fait office de repère de lieu. */}
      <Path
        d="M60 106C60 106 7 72 7 36C7 17 21 5 37 5C48 5 55 11 60 19C65 11 72 5 83 5C99 5 113 17 113 36C113 72 60 106 60 106Z"
        stroke={couleurCoeur}
        strokeWidth={9}
        strokeLinejoin="round"
        fill="none"
      />

      {/* Les deux personnes, attablées. Elles ne portent pas la même couleur :
          c'est une rencontre, pas un reflet. */}
      <Circle cx={38} cy={37.5} r={8.5} fill={couleurCoeur} />
      <Path
        d="M28 59C28 53.4772 32.4772 49 38 49V49C43.5228 49 48 53.4772 48 59V70C48 71.6569 46.6569 73 45 73H31C29.3431 73 28 71.6569 28 70V59Z"
        fill={couleurCoeur}
      />
      <Circle cx={82} cy={37.5} r={8.5} fill={couleurPersonneDroite} />
      <Path
        d="M72 59C72 53.4772 76.4772 49 82 49V49C87.5228 49 92 53.4772 92 59V70C92 71.6569 90.6569 73 89 73H75C73.3431 73 72 71.6569 72 70V59Z"
        fill={couleurPersonneDroite}
      />

      {/* La cloche de service et son plateau, au premier plan. */}
      <Path
        d="M45 62C45 60.2928 45.388 58.6023 46.1418 57.0251C46.8956 55.4479 48.0005 54.0148 49.3934 52.8076C50.7863 51.6004 52.4399 50.6429 54.2598 49.9896C56.0796 49.3363 58.0302 49 60 49C61.9698 49 63.9204 49.3363 65.7403 49.9896C67.5601 50.6429 69.2137 51.6005 70.6066 52.8076C71.9995 54.0148 73.1044 55.4479 73.8582 57.0251C74.612 58.6024 75 60.2928 75 62L60 62L45 62Z"
        fill={couleurCloche}
      />
      <Circle cx={60} cy={48} r={3} fill={couleurCloche} />
      <Rect x={41} y={62.5} width={38} height={4} rx={2} fill={couleurCloche} />
    </Svg>
  );
}

/** Node 1:170 — le symbole en couleurs, pour les fonds clairs. */
export function LogoSymbole({ taille = composants.logo.hauteur, style }: SymboleProps) {
  return (
    <View style={style}>
      <Symbole
        taille={taille}
        couleurCoeur={marque.corail}
        couleurPersonneDroite={marque.framboise}
        couleurCloche={marque.nuit}
        couleurOmbre={marque.poudre}
        opaciteOmbre={0.8}
      />
    </View>
  );
}

/** Node 1:180 — le symbole entièrement blanc, pour les fonds immersifs. */
export function LogoSymboleBlanc({ taille = composants.logo.hauteur, style }: SymboleProps) {
  return (
    <View style={style}>
      <Symbole
        taille={taille}
        couleurCoeur={colors.onPhoto}
        couleurPersonneDroite={colors.onPhoto}
        couleurCloche={colors.onPhoto}
        couleurOmbre={colors.onPhoto}
        opaciteOmbre={0.35}
      />
    </View>
  );
}

interface HorizontalProps extends SymboleProps {
  /** Vrai sur fond immersif : symbole et mot passent en blanc. */
  blanc?: boolean;
}

/**
 * Node 1:202 — le symbole suivi du mot.
 *
 * Le mot se compose en deux couleurs : « Safe » en nuit, « Date » en corail.
 * Sur fond immersif les deux passent en blanc, sinon « Safe » disparaîtrait.
 */
export function LogoHorizontal({ taille = 33.48, blanc = false, style }: HorizontalProps) {
  return (
    <View style={[styles.ligne, style]}>
      {blanc ? <LogoSymboleBlanc taille={taille} /> : <LogoSymbole taille={taille} />}
      <Text style={[styles.mot, blanc ? styles.motBlanc : null]} allowFontScaling={false}>
        Safe
        <Text style={blanc ? styles.motBlanc : styles.motAccent}>Date</Text>
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  ligne: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: composants.logo.gap,
  },
  mot: {
    ...typography.motMarque,
    color: marque.nuit,
    includeFontPadding: false,
  },
  motAccent: { color: marque.corail },
  motBlanc: { color: colors.onPhoto },
});
