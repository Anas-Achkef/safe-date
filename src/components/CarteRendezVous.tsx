import { useState } from 'react';
import { Image, StyleSheet, View, type LayoutChangeEvent, type StyleProp, type ViewStyle } from 'react-native';
import Svg, { Circle, Line } from 'react-native-svg';

import {
  cadrer,
  distanceMetres,
  zoomPourCadrer,
  zoomPourDistance,
  TAILLE_TUILE,
  type Coordonnees,
} from '../lib/geo';
import { carte, colors, deviceFrame, radius, spacing } from '../theme';

/**
 * Fond cartographique.
 *
 * Tuiles OpenStreetMap : aucune cle, aucun module natif, donc disponible dans
 * le navigateur comme dans Expo Go. Leur politique d'usage limite le trafic
 * automatise — un fournisseur avec cle (Maptiler, Mapbox) devra prendre le
 * relais avant la mise en production, en ne changeant que cette fonction.
 */
const tuileUrl = (z: number, x: number, y: number) =>
  `https://tile.openstreetmap.org/${z}/${x}/${y}.png`;

interface Props {
  /** Le point de rendez-vous de l'utilisateur, jamais celui de l'autre. */
  point: Coordonnees;
  /** Position de l'utilisateur, quand elle est connue. */
  moi?: Coordonnees | null;
  style?: StyleProp<ViewStyle>;
}

/**
 * Carte d'approche du point de rendez-vous.
 *
 * La geometrie est dessinee par-dessus les tuiles, pas par elles : si le
 * reseau ne rend aucune image, la carte reste lisible et montre toujours ou se
 * trouve le point par rapport a soi.
 */
export function CarteRendezVous({ point, moi, style }: Props) {
  // `onLayout` ne se declenche pas toujours en web : on part d'une largeur
  // deduite du cadre et on l'affine si la mesure arrive.
  const [largeur, setLargeur] = useState(
    deviceFrame.width - spacing.gutter * 2 - spacing.lg * 2,
  );
  const hauteur = carte.hauteur;

  const mesurer = (e: LayoutChangeEvent) => {
    const l = e.nativeEvent.layout.width;
    if (l > 0 && Math.abs(l - largeur) > 1) setLargeur(l);
  };

  const distance = moi ? distanceMetres(moi, point) : null;

  // Sans position connue, la carte se centre sur le point. Avec, elle cadre
  // les deux et se recentre sur leur milieu.
  const centre: Coordonnees = moi
    ? { lat: (moi.lat + point.lat) / 2, lon: (moi.lon + point.lon) / 2 }
    : point;
  const zoom = moi
    ? zoomPourCadrer(moi, point, largeur, hauteur, carte.halo)
    : zoomPourDistance(distance);

  const vue = cadrer(centre, zoom, largeur, hauteur);
  const p = vue.projeter(point);
  const m = moi ? vue.projeter(moi) : null;

  return (
    <View style={[styles.cadre, style]} onLayout={mesurer}>
      {vue.tuiles.map((t) => (
        <Image
          key={t.cle}
          source={{ uri: tuileUrl(t.zoom, t.x, t.y) }}
          style={[styles.tuile, { left: t.gauche, top: t.haut }]}
        />
      ))}

      {/* Les tuiles sont claires : ce voile les accorde au thème sombre. */}
      <View style={styles.voile} />

      <Svg width={largeur} height={hauteur} style={styles.calque}>
        {m ? (
          <Line
            x1={m.x}
            y1={m.y}
            x2={p.x}
            y2={p.y}
            stroke={colors.accent}
            strokeWidth={carte.trait}
            strokeDasharray="5 5"
            strokeLinecap="round"
            opacity={0.7}
          />
        ) : null}

        <Circle cx={p.x} cy={p.y} r={carte.halo} fill={colors.accent} opacity={0.16} />
        <Circle
          cx={p.x}
          cy={p.y}
          r={carte.pointRayon}
          fill={colors.accent}
          stroke={colors.background}
          strokeWidth={carte.pointAnneau}
        />

        {m ? (
          <Circle
            cx={m.x}
            cy={m.y}
            r={carte.moiRayon}
            fill={colors.textPrimary}
            stroke={colors.background}
            strokeWidth={carte.moiAnneau}
          />
        ) : null}
      </Svg>
    </View>
  );
}

const styles = StyleSheet.create({
  cadre: {
    height: carte.hauteur,
    borderRadius: radius.md,
    overflow: 'hidden',
    backgroundColor: colors.surfaceAlt,
  },
  tuile: {
    position: 'absolute',
    width: TAILLE_TUILE,
    height: TAILLE_TUILE,
    opacity: carte.tuileOpacite,
  },
  voile: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: colors.background,
    opacity: carte.voileTuiles,
    pointerEvents: 'none',
  },
  calque: {
    position: 'absolute',
    top: 0,
    left: 0,
    pointerEvents: 'none',
  },
});
