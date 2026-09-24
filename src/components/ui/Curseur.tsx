import { useState } from 'react';
import {
  StyleSheet,
  Text,
  View,
  type GestureResponderEvent,
  type LayoutChangeEvent,
} from 'react-native';

import { colors, composants, deviceFrame, elevation, spacing, typography } from '../../theme';

/**
 * Le curseur de réglage — nodes Figma 11:704 (une valeur) et 11:744 (une
 * fourchette).
 *
 * Aucune bibliothèque : elles ne se comportent pas pareil sur téléphone et
 * dans le navigateur. Le geste passe par le système de responder de React
 * Native, qui donne `locationX` relatif au rail des deux côtés.
 *
 * La largeur du rail est **calculée d'abord et mesurée ensuite**. Conditionner
 * l'affichage à `onLayout` est le piège qui donne un écran noir en web, où
 * l'événement peut ne jamais se déclencher : on part donc de la largeur de
 * contenu du cadre — celle que Figma dessine, 342 points — et on n'affine que
 * si la mesure arrive.
 */

/** Largeur de repli : le cadre moins ses deux gouttières. */
const LARGEUR_SECOURS = deviceFrame.width - spacing.gutter * 2;

/** Arrondi du rail : la moitié de son épaisseur, donc un demi-cercle. */
const RAYON_RAIL = composants.curseur.rail / 2;

/**
 * Demi-poignée.
 *
 * La poignée ne se déplace pas de 0 à la largeur du rail mais d'un rayon à la
 * largeur moins un rayon : sinon, aux deux extrêmes, la moitié du disque sort
 * de la gouttière de l'écran. Le remplissage s'arrête toujours exactement au
 * centre de la poignée, ce qui garde les deux solidaires.
 */
const RAYON_POIGNEE = composants.curseur.poignee / 2;

/** Abscisse du centre de la poignée pour une part de 0 à 1. */
function centre(part: number, largeur: number): number {
  return RAYON_POIGNEE + part * Math.max(0, largeur - composants.curseur.poignee);
}

function useLargeurRail() {
  const [mesure, setMesure] = useState(0);
  const largeur = mesure > 0 ? mesure : LARGEUR_SECOURS;

  const mesurer = (e: LayoutChangeEvent) => {
    const l = Math.round(e.nativeEvent.layout.width);
    if (l > 0 && l !== mesure) setMesure(l);
  };

  return { largeur, mesurer };
}

/** Ramène une abscisse de geste à une valeur du domaine, alignée sur le pas. */
function valeurAu(x: number, largeur: number, bas: number, haut: number, pas: number): number {
  const course = Math.max(1, largeur - composants.curseur.poignee);
  const part = Math.min(1, Math.max(0, (x - RAYON_POIGNEE) / course));
  const brute = bas + part * (haut - bas);
  return Math.min(haut, Math.max(bas, Math.round(brute / pas) * pas));
}

function Rail({
  debut,
  fin,
  mesurer,
  gerer,
  children,
}: {
  /** Abscisses, en points, des deux bouts du remplissage. */
  debut: number;
  fin: number;
  mesurer: (e: LayoutChangeEvent) => void;
  gerer: (x: number) => void;
  children: React.ReactNode;
}) {
  const suivre = (e: GestureResponderEvent) => gerer(e.nativeEvent.locationX);

  return (
    <View
      style={styles.piste}
      onLayout={mesurer}
      onStartShouldSetResponder={() => true}
      onMoveShouldSetResponder={() => true}
      onResponderGrant={suivre}
      onResponderMove={suivre}
    >
      <View style={styles.rail} />
      <View style={[styles.railRempli, { left: debut, width: Math.max(0, fin - debut) }]} />
      {children}
    </View>
  );
}

function Poignee({ x }: { x: number }) {
  return <View style={[styles.poignee, { left: x - RAYON_POIGNEE }]} />;
}

interface Bornes {
  /** Légende sous le bord gauche du rail. */
  legendeBas: string;
  /** Légende sous le bord droit. */
  legendeHaut: string;
}

interface CurseurProps extends Bornes {
  valeur: number;
  bas: number;
  haut: number;
  pas: number;
  /** Ce qui s'écrit en gros au-dessus du rail. */
  resume: string;
  onChange: (v: number) => void;
  /** Description lue par les lecteurs d'écran. */
  libelle: string;
}

/** Un réglage à une valeur — distance, compatibilité minimale. */
export function Curseur({
  valeur,
  bas,
  haut,
  pas,
  resume,
  legendeBas,
  legendeHaut,
  onChange,
  libelle,
}: CurseurProps) {
  const { largeur, mesurer } = useLargeurRail();
  const part = (valeur - bas) / (haut - bas);

  return (
    <View
      style={styles.bloc}
      accessibilityRole="adjustable"
      accessibilityLabel={libelle}
      accessibilityValue={{ min: bas, max: haut, now: valeur }}
    >
      <Text style={styles.resume} allowFontScaling={false}>
        {resume}
      </Text>
      <Rail
        debut={0}
        fin={centre(part, largeur)}
        mesurer={mesurer}
        gerer={(x) => onChange(valeurAu(x, largeur, bas, haut, pas))}
      >
        <Poignee x={centre(part, largeur)} />
      </Rail>
      <Legendes gauche={legendeBas} droite={legendeHaut} />
    </View>
  );
}

interface FourchetteProps extends Bornes {
  min: number;
  max: number;
  bas: number;
  haut: number;
  pas: number;
  resume: string;
  onChange: (min: number, max: number) => void;
  libelle: string;
}

/** Un réglage à deux valeurs — âge, taille. */
export function CurseurFourchette({
  min,
  max,
  bas,
  haut,
  pas,
  resume,
  legendeBas,
  legendeHaut,
  onChange,
  libelle,
}: FourchetteProps) {
  const { largeur, mesurer } = useLargeurRail();
  const partMin = (min - bas) / (haut - bas);
  const partMax = (max - bas) / (haut - bas);

  // La poignée saisie est la plus proche du doigt, jamais une poignée
  // désignée d'avance : sinon les deux se croisent et le réglage se bloque.
  const gerer = (x: number) => {
    const v = valeurAu(x, largeur, bas, haut, pas);
    const versMin = Math.abs(v - min) <= Math.abs(v - max);
    if (versMin) onChange(Math.min(v, max), max);
    else onChange(min, Math.max(v, min));
  };

  return (
    <View
      style={styles.bloc}
      accessibilityRole="adjustable"
      accessibilityLabel={libelle}
      accessibilityValue={{ min: bas, max: haut, text: resume }}
    >
      <Text style={styles.resume} allowFontScaling={false}>
        {resume}
      </Text>
      <Rail debut={centre(partMin, largeur)} fin={centre(partMax, largeur)} mesurer={mesurer} gerer={gerer}>
        <Poignee x={centre(partMin, largeur)} />
        <Poignee x={centre(partMax, largeur)} />
      </Rail>
      <Legendes gauche={legendeBas} droite={legendeHaut} />
    </View>
  );
}

function Legendes({ gauche, droite }: { gauche: string; droite: string }) {
  return (
    <View style={styles.legendes}>
      <Text style={styles.legende} allowFontScaling={false}>
        {gauche}
      </Text>
      <Text style={styles.legende} allowFontScaling={false}>
        {droite}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  bloc: { gap: spacing.sm, alignSelf: 'stretch' },
  resume: {
    ...typography.h3,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
  piste: {
    height: composants.curseur.hauteur,
    justifyContent: 'center',
  },
  rail: {
    height: composants.curseur.rail,
    borderRadius: RAYON_RAIL,
    backgroundColor: colors.surfaceAlt,
  },
  railRempli: {
    position: 'absolute',
    height: composants.curseur.rail,
    borderRadius: RAYON_RAIL,
    backgroundColor: colors.accent,
  },
  poignee: {
    position: 'absolute',
    width: composants.curseur.poignee,
    height: composants.curseur.poignee,
    borderRadius: composants.curseur.poignee / 2,
    backgroundColor: colors.surface,
    borderWidth: composants.curseur.anneau,
    borderColor: colors.accent,
    ...elevation.card,
  },
  legendes: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  legende: {
    ...typography.caption,
    color: colors.textMuted,
  },
});
