/**
 * Source unique de vérité visuelle.
 *
 * Registre : doux et rassurant. Clair plutôt que sombre, crème et sable,
 * accent végétal, rondeurs franches, ombres portées très légères. L'objectif
 * est le soin et la sécurité — cohérent avec le nom du produit — et non la
 * lecture analytique d'un score.
 *
 * Aucune couleur, taille, espacement ou rayon ne doit être écrit ailleurs.
 */

export type PaletteName = 'serein' | 'aube' | 'brume';

/** Registre affiché. Seule ligne à modifier pour décliner. */
export const ACTIVE_PALETTE: PaletteName = 'serein';

interface Palette {
  /** Fond de page. */
  background: string;
  /** Cartes et surfaces posées sur le fond. */
  surface: string;
  /** Surface secondaire, légèrement teintée. */
  surfaceAlt: string;
  /** Filet discret. */
  rule: string;
  textPrimary: string;
  textSecondary: string;
  textMuted: string;
  /** Ton d'accent du registre. */
  accent: string;
  /** Fond très pâle de l'accent, pour les pastilles. */
  accentSoft: string;
  /** Texte posé sur l'accent plein. */
  onAccent: string;
  /** Texte posé sur une photo. */
  onPhoto: string;
  danger: string;
  /** Ombre portée : toujours très douce. */
  shadow: string;
  /** Pourtour de la page en rendu navigateur, hors du cadre d'appareil. */
  backdrop: string;
  /** Les deux tons du visuel de substitution, en attendant les photos. */
  placeholderFrom: string;
  placeholderTo: string;
}

const PALETTES: Record<PaletteName, Palette> = {
  /** Serein — crème, sable et vert pâle. Le registre du soin. */
  serein: {
    background: '#FAF7F2',
    surface: '#FFFFFF',
    surfaceAlt: '#F1EDE4',
    rule: 'rgba(42, 39, 36, 0.09)',
    textPrimary: '#2A2724',
    textSecondary: '#6B6459',
    textMuted: '#9B9287',
    accent: '#7C9070',
    accentSoft: '#E9EFE5',
    onAccent: '#FFFFFF',
    onPhoto: '#FFFFFF',
    danger: '#B4685C',
    shadow: 'rgba(42, 39, 36, 0.10)',
    backdrop: '#DCD6CC',
    placeholderFrom: '#D9E2D2',
    placeholderTo: '#EFE7DA',
  },

  /** Aube — crème rosé et terracotta douce. */
  aube: {
    background: '#FBF6F2',
    surface: '#FFFFFF',
    surfaceAlt: '#F4EBE4',
    rule: 'rgba(48, 38, 34, 0.09)',
    textPrimary: '#302622',
    textSecondary: '#6F6158',
    textMuted: '#A0918A',
    accent: '#C08163',
    accentSoft: '#F6E7DE',
    onAccent: '#FFFFFF',
    onPhoto: '#FFFFFF',
    danger: '#B4685C',
    shadow: 'rgba(48, 38, 34, 0.10)',
    backdrop: '#E0D5CC',
    placeholderFrom: '#F0DCD0',
    placeholderTo: '#F7EFE7',
  },

  /** Brume — blanc froid et bleu pâle. */
  brume: {
    background: '#F6F8FA',
    surface: '#FFFFFF',
    surfaceAlt: '#EBEFF4',
    rule: 'rgba(32, 40, 48, 0.09)',
    textPrimary: '#202830',
    textSecondary: '#5C6670',
    textMuted: '#8D97A2',
    accent: '#6E8BA6',
    accentSoft: '#E4EBF2',
    onAccent: '#FFFFFF',
    onPhoto: '#FFFFFF',
    danger: '#B4685C',
    shadow: 'rgba(32, 40, 48, 0.10)',
    backdrop: '#D3DAE1',
    placeholderFrom: '#D6E1EA',
    placeholderTo: '#EDF1F5',
  },
};

export const colors = PALETTES[ACTIVE_PALETTE];

/** Échelle en multiples de 4. */
export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  gutter: 24,
  xxxl: 32,
  huge: 40,
  giant: 48,
} as const;

/** Rondeurs franches : le registre doux ne supporte pas les angles vifs. */
export const radius = {
  sm: 12,
  md: 20,
  lg: 28,
  xl: 36,
  pill: 999,
} as const;

export const hairline = 1;

export const fonts = {
  displayLight: 'CabinetGrotesk-Light',
  displayRegular: 'CabinetGrotesk-Regular',
  bodyRegular: 'Switzer-Regular',
  bodyMedium: 'Switzer-Medium',
} as const;

export const typography = {
  /** Prénom : c'est lui le héros de l'écran, plus le chiffre. */
  name: {
    fontFamily: fonts.displayRegular,
    fontSize: 30,
    letterSpacing: -0.4,
  },
  display: {
    fontFamily: fonts.displayRegular,
    fontSize: 26,
    letterSpacing: -0.3,
  },
  heading: {
    fontFamily: fonts.displayRegular,
    fontSize: 17,
  },
  /** Valeur du score, dans sa pastille. */
  scoreValue: {
    fontFamily: fonts.displayRegular,
    fontSize: 15,
    letterSpacing: -0.2,
  },
  subscoreValue: {
    fontFamily: fonts.displayRegular,
    fontSize: 19,
    letterSpacing: -0.2,
  },
  body: {
    fontFamily: fonts.bodyRegular,
    fontSize: 15,
    lineHeight: 23,
  },
  label: {
    fontFamily: fonts.bodyMedium,
    fontSize: 13,
  },
  caption: {
    fontFamily: fonts.bodyRegular,
    fontSize: 12.5,
    lineHeight: 18,
  },
  overline: {
    fontFamily: fonts.bodyMedium,
    fontSize: 10.5,
    letterSpacing: 1.1,
  },
  tabLabel: {
    fontFamily: fonts.bodyMedium,
    fontSize: 10.5,
  },
} as const;

/**
 * Ombres portées : présentes mais jamais lourdes.
 *
 * `boxShadow` remplace les anciennes propriétés `shadow*`, dépréciées depuis
 * React Native 0.76 et sans effet sur le web.
 */
export const elevation = {
  card: {
    boxShadow: `0 8px 24px ${colors.shadow}`,
  },
  soft: {
    boxShadow: `0 2px 8px ${colors.shadow}`,
  },
} as const;

export const motion = {
  curve: [0.16, 1, 0.3, 1] as const,
  reveal: 560,
  stagger: 70,
  rise: 14,
  press: 140,
  pressScale: 0.97,
} as const;

export const opacity = {
  disabled: 0.4,
  pressed: 0.7,
} as const;

/** Cadre d'appareil imposé au rendu navigateur. */
export const deviceFrame = {
  width: 390,
  height: 844,
} as const;

export const layout = {
  tabBarHeight: 76,
  /** Part de la hauteur occupée par la photo. */
  photoRatio: 0.56,
} as const;

export const theme = {
  colors,
  spacing,
  radius,
  hairline,
  fonts,
  typography,
  elevation,
  motion,
  opacity,
  deviceFrame,
  layout,
} as const;

export type Theme = typeof theme;
