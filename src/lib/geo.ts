/**
 * Geometrie terrestre et projection Web Mercator.
 *
 * Aucune dependance : ces calculs servent a la fois a mesurer l'approche du
 * point de rendez-vous et a placer les tuiles de la carte.
 */

/**
 * Distance sous laquelle le back-end accepte de reveler l'etablissement.
 *
 * Ce n'est pas un reglage d'affichage : `reveal_establishment` refuse au-dela.
 * La valeur est reprise ici pour n'appeler la RPC que lorsqu'elle peut aboutir.
 */
export const SEUIL_REVELATION_M = 25;

/** Taille d'une tuile Web Mercator, constante du protocole et non un reglage. */
export const TAILLE_TUILE = 256;

const RAYON_TERRE_M = 6_371_008.8;

export interface Coordonnees {
  lat: number;
  lon: number;
}

const enRadians = (deg: number) => (deg * Math.PI) / 180;

/**
 * Distance orthodromique en metres (formule de haversine).
 *
 * Precise a mieux que 0,5 % sur toutes les distances qui nous concernent, la
 * Terre etant traitee comme une sphere.
 */
export function distanceMetres(a: Coordonnees, b: Coordonnees): number {
  const dLat = enRadians(b.lat - a.lat);
  const dLon = enRadians(b.lon - a.lon);
  const lat1 = enRadians(a.lat);
  const lat2 = enRadians(b.lat);

  const h =
    Math.sin(dLat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2;
  return 2 * RAYON_TERRE_M * Math.asin(Math.min(1, Math.sqrt(h)));
}

/** Cap initial de `a` vers `b`, en degres depuis le nord, dans [0, 360[. */
export function capDegres(a: Coordonnees, b: Coordonnees): number {
  const lat1 = enRadians(a.lat);
  const lat2 = enRadians(b.lat);
  const dLon = enRadians(b.lon - a.lon);

  const y = Math.sin(dLon) * Math.cos(lat2);
  const x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);
  return (Math.atan2(y, x) * (180 / Math.PI) + 360) % 360;
}

/** Position en tuiles fractionnaires au niveau de zoom donne. */
export function versTuile({ lat, lon }: Coordonnees, zoom: number): { x: number; y: number } {
  const n = 2 ** zoom;
  const latRad = enRadians(Math.max(-85.05112878, Math.min(85.05112878, lat)));
  return {
    x: ((lon + 180) / 360) * n,
    y: ((1 - Math.log(Math.tan(latRad) + 1 / Math.cos(latRad)) / Math.PI) / 2) * n,
  };
}

/**
 * Niveau de zoom qui cadre confortablement une distance donnee.
 *
 * Choisi par paliers plutot que calcule : les niveaux intermediaires n'ont pas
 * de tuiles distinctes et un zoom fractionnaire les rendrait flous.
 */
export function zoomPourDistance(metres: number | null): number {
  if (metres === null) return 15;
  if (metres < 150) return 17;
  if (metres < 400) return 16;
  if (metres < 1_200) return 15;
  if (metres < 3_000) return 14;
  if (metres < 9_000) return 12;
  if (metres < 30_000) return 11;
  return 9;
}

/**
 * Plus grand zoom auquel `a` et `b` tiennent tous deux dans la vue.
 *
 * Se calcule au lieu de se choisir par paliers : deux points peuvent etre
 * proches en distance et mal cadres si la vue est plus large que haute.
 */
export function zoomPourCadrer(
  a: Coordonnees,
  b: Coordonnees,
  largeur: number,
  hauteur: number,
  marge: number,
): number {
  const p0 = versTuile(a, 0);
  const p1 = versTuile(b, 0);
  const dx = Math.abs(p1.x - p0.x) * TAILLE_TUILE;
  const dy = Math.abs(p1.y - p0.y) * TAILLE_TUILE;

  const utileX = Math.max(1, largeur - marge * 2);
  const utileY = Math.max(1, hauteur - marge * 2);

  // Deux points confondus n'imposent aucune contrainte : on garde le zoom max.
  const zx = dx > 0 ? Math.log2(utileX / dx) : Infinity;
  const zy = dy > 0 ? Math.log2(utileY / dy) : Infinity;

  return Math.max(3, Math.min(17, Math.floor(Math.min(zx, zy))));
}

export interface Tuile {
  cle: string;
  x: number;
  y: number;
  zoom: number;
  /** Position du coin superieur gauche de la tuile dans la vue, en points. */
  gauche: number;
  haut: number;
}

export interface Cadrage {
  zoom: number;
  tuiles: Tuile[];
  /** Projette des coordonnees en position dans la vue, en points. */
  projeter: (point: Coordonnees) => { x: number; y: number };
}

/**
 * Calcule les tuiles a poser pour couvrir une vue de `largeur` x `hauteur`
 * centree sur `centre`, et la fonction qui y projette n'importe quel point.
 */
export function cadrer(
  centre: Coordonnees,
  zoom: number,
  largeur: number,
  hauteur: number,
): Cadrage {
  const n = 2 ** zoom;
  const c = versTuile(centre, zoom);

  // Coin superieur gauche de la vue, exprime en pixels de la pyramide.
  const originX = c.x * TAILLE_TUILE - largeur / 2;
  const originY = c.y * TAILLE_TUILE - hauteur / 2;

  const premierX = Math.floor(originX / TAILLE_TUILE);
  const premierY = Math.floor(originY / TAILLE_TUILE);
  const dernierX = Math.floor((originX + largeur) / TAILLE_TUILE);
  const dernierY = Math.floor((originY + hauteur) / TAILLE_TUILE);

  const tuiles: Tuile[] = [];
  for (let ty = premierY; ty <= dernierY; ty += 1) {
    // Hors des poles il n'existe aucune tuile : on saute plutot que de
    // demander une image qui reviendra en 404.
    if (ty < 0 || ty >= n) continue;
    for (let tx = premierX; tx <= dernierX; tx += 1) {
      // La longitude s'enroule, elle : -1 devient la derniere colonne.
      const enroule = ((tx % n) + n) % n;
      tuiles.push({
        cle: `${zoom}/${tx}/${ty}`,
        x: enroule,
        y: ty,
        zoom,
        gauche: tx * TAILLE_TUILE - originX,
        haut: ty * TAILLE_TUILE - originY,
      });
    }
  }

  return {
    zoom,
    tuiles,
    projeter: (point) => {
      const p = versTuile(point, zoom);
      return { x: p.x * TAILLE_TUILE - originX, y: p.y * TAILLE_TUILE - originY };
    },
  };
}

/** Distance lisible : metres sous le kilometre, puis kilometres. */
export function formaterMetres(metres: number | null): string {
  if (metres === null) return '—';
  if (metres < SEUIL_REVELATION_M) return 'Vous y êtes';
  if (metres < 1_000) return `${Math.round(metres / 5) * 5} m`;
  if (metres < 10_000) return `${(metres / 1_000).toFixed(1).replace('.', ',')} km`;
  return `${Math.round(metres / 1_000)} km`;
}
