/**
 * Source unique de vérité visuelle.
 *
 * Registre « corail » : crème chaude, corail de marque, nuit bleutée. Il vient
 * de la page « 🎨 Design System » du fichier Figma — chaque valeur ci-dessous
 * correspond à une variable Figma, et rien n'est inventé ici.
 *
 * Aucune couleur, taille, espacement ou rayon ne doit être écrit ailleurs.
 */

export type PaletteName =
  | 'corail'
  | 'nuit'
  | 'ambre'
  | 'azur'
  | 'braise'
  | 'serein'
  | 'aube'
  | 'brume';

/** Registre affiché. Seule ligne à modifier pour décliner. */
export const ACTIVE_PALETTE: PaletteName = 'corail';

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
  photoVoile: [string, string];
  surfaceTranslucide: string;
}

/**
 * États du système.
 *
 * Ils ne dépendent pas du registre : un point de rencontre vérifié se dit en
 * vert quelle que soit la déclinaison, sinon le code couleur ne s'apprend pas.
 */
export const etats = {
  securite: '#2B9E72',
  securiteClair: '#E3F4EC',
  alerte: '#D9861F',
  alerteClair: '#FCF0DF',
  /**
   * Rouge d'erreur, distinct du corail de marque.
   *
   * Réservé aux erreurs de saisie et aux actions destructrices — supprimer,
   * signaler. Refuser une demande n'en fait pas partie : c'est un choix
   * ordinaire, il se dit en bouton neutre (Fantôme ou Secondaire).
   */
  danger: '#B42318',
  dangerClair: '#FDECEA',
} as const;

const PALETTES: Record<PaletteName, Palette> = {
  /**
   * Corail — crème chaude, corail de marque, nuit bleutée.
   *
   * Le fond n'est jamais blanc : c'est la crème `fond/base` qui porte l'écran,
   * et le blanc est réservé aux cartes, ce qui les fait lever sans ombre
   * appuyée. Le corail ne sert qu'à l'action et à l'affinité — jamais pour
   * décorer, sinon il ne veut plus rien dire.
   */
  corail: {
    background: '#FAF4EE',
    surface: '#FFFFFF',
    surfaceAlt: '#F3ECE6',
    rule: '#ECE4DE',
    textPrimary: '#06102A',
    textSecondary: '#5E6478',
    textMuted: '#A3A7B5',
    accent: '#E6526C',
    accentSoft: '#FBE9EB',
    onAccent: '#FFFFFF',
    onPhoto: '#FFFFFF',
    danger: etats.danger,
    shadow: 'rgba(6, 16, 42, 0.06)',
    backdrop: '#E7DCD3',
    placeholderFrom: '#F4A7B0',
    placeholderTo: '#B04E86',
    photoVoile: ['rgba(6, 16, 42, 0)', 'rgba(6, 16, 42, 0.72)'],
    surfaceTranslucide: 'rgba(255, 255, 255, 0.92)',
  },

  /**
   * Nuit — noir profond et vert jade.
   *
   * Le vert est la couleur de l'accord : feu vert, validation, voie libre. Sur
   * un pourcentage il se lit comme une reponse, sur un rendez-vous comme une
   * assurance. C'est le seul ton colore de l'interface — tout le reste est
   * noir, gris et blanc, ce qui lui donne toute sa portee.
   */
  nuit: {
    background: '#0A0B0D',
    surface: '#141619',
    surfaceAlt: '#1D2024',
    rule: 'rgba(242, 243, 245, 0.10)',
    textPrimary: '#F2F3F5',
    textSecondary: 'rgba(242, 243, 245, 0.68)',
    textMuted: 'rgba(242, 243, 245, 0.44)',
    accent: '#3ED598',
    accentSoft: 'rgba(62, 213, 152, 0.14)',
    onAccent: '#06231A',
    onPhoto: '#FFFFFF',
    danger: '#E4695E',
    shadow: 'rgba(0, 0, 0, 0.55)',
    backdrop: '#050506',
    placeholderFrom: '#1E3A31',
    placeholderTo: '#12181C',
    photoVoile: ['rgba(10, 11, 13, 0)', 'rgba(10, 11, 13, 0.78)'],
    surfaceTranslucide: 'rgba(20, 22, 25, 0.88)',
  },

  /** Ambre — noir et or mat. Le registre de la rarete et de la selection. */
  ambre: {
    background: '#0B0A08',
    surface: '#16140F',
    surfaceAlt: '#211E17',
    rule: 'rgba(245, 240, 230, 0.10)',
    textPrimary: '#F5F0E6',
    textSecondary: 'rgba(245, 240, 230, 0.68)',
    textMuted: 'rgba(245, 240, 230, 0.44)',
    accent: '#D9A441',
    accentSoft: 'rgba(217, 164, 65, 0.14)',
    onAccent: '#231803',
    onPhoto: '#FFFFFF',
    danger: '#E4695E',
    shadow: 'rgba(0, 0, 0, 0.55)',
    backdrop: '#060504',
    placeholderFrom: '#3A2E17',
    placeholderTo: '#1A1610',
    photoVoile: ['rgba(11, 10, 8, 0)', 'rgba(11, 10, 8, 0.78)'],
    surfaceTranslucide: 'rgba(22, 20, 15, 0.88)',
  },

  /** Azur — noir et bleu electrique. Le registre de la confiance technique. */
  azur: {
    background: '#080A0E',
    surface: '#111520',
    surfaceAlt: '#1A1F2B',
    rule: 'rgba(238, 242, 248, 0.10)',
    textPrimary: '#EEF2F8',
    textSecondary: 'rgba(238, 242, 248, 0.68)',
    textMuted: 'rgba(238, 242, 248, 0.44)',
    accent: '#4C9AFF',
    accentSoft: 'rgba(76, 154, 255, 0.14)',
    onAccent: '#04162E',
    onPhoto: '#FFFFFF',
    danger: '#E4695E',
    shadow: 'rgba(0, 0, 0, 0.55)',
    backdrop: '#040507',
    placeholderFrom: '#17293F',
    placeholderTo: '#101520',
    photoVoile: ['rgba(8, 10, 14, 0)', 'rgba(8, 10, 14, 0.78)'],
    surfaceTranslucide: 'rgba(17, 21, 32, 0.88)',
  },

  /**
   * Braise — corail, ambre et creme chaude.
   *
   * Le registre d'une application de rencontre : chaleureux, vivant, un accent
   * qui appelle le geste. Les bruns remplacent les gris — aucun neutre froid
   * dans cette palette, c'est ce qui fait la difference a l'oeil.
   */
  braise: {
    background: '#FFF8F3',
    surface: '#FFFFFF',
    surfaceAlt: '#FCEDE3',
    rule: 'rgba(70, 40, 30, 0.10)',
    textPrimary: '#2E1F1A',
    textSecondary: '#6E5348',
    textMuted: '#A98D7E',
    accent: '#E4633F',
    accentSoft: '#FDE5DB',
    onAccent: '#FFFFFF',
    onPhoto: '#FFFFFF',
    danger: '#C4553F',
    shadow: 'rgba(120, 60, 40, 0.14)',
    backdrop: '#E7D3C6',
    placeholderFrom: '#F6C9A8',
    placeholderTo: '#F3A38A',
    photoVoile: ['rgba(46, 24, 16, 0)', 'rgba(46, 24, 16, 0.62)'],
    surfaceTranslucide: 'rgba(255, 255, 255, 0.94)',
  },

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
    photoVoile: ['rgba(0, 0, 0, 0)', 'rgba(0, 0, 0, 0.55)'],
    surfaceTranslucide: 'rgba(255, 255, 255, 0.92)',
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
    photoVoile: ['rgba(0, 0, 0, 0)', 'rgba(0, 0, 0, 0.55)'],
    surfaceTranslucide: 'rgba(255, 255, 255, 0.92)',
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
    photoVoile: ['rgba(0, 0, 0, 0)', 'rgba(0, 0, 0, 0.55)'],
    surfaceTranslucide: 'rgba(255, 255, 255, 0.92)',
  },
};

export const colors = PALETTES[ACTIVE_PALETTE];

/**
 * Décors.
 *
 * Des formes posées derrière le contenu, jamais devant : elles réchauffent un
 * fond crème sans rien signifier. Le halo de l'écran Parcourir en est le seul
 * exemple pour l'instant — un dégradé radial rose qui déborde par le haut.
 */
export const decor = {
  haloCentre: '#FFDBDB',
  haloBord: '#FAF5ED',
  /** Opacité de la forme entière, puis du seul arrêt central. */
  haloOpacite: 0.6,
  haloOpaciteCentre: 0.9,
} as const;

/**
 * Dégradé immersif — accueil, coup de cœur réciproque, rendez-vous confirmé.
 *
 * Figma le pose à 161°, ce qui en coordonnées de `expo-linear-gradient` donne
 * une descente presque verticale, légèrement inclinée vers la droite. Les
 * arrêts s'arrêtent à 74 % : le dernier quart reste en nuit pleine, ce qui
 * laisse la place au texte posé en bas.
 */
export const degradeImmersif = {
  colors: ['#F4A7B0', '#B04E86', '#1A2150'] as const,
  locations: [0, 0.37, 0.74] as const,
  start: { x: 0.33, y: 0 } as const,
  end: { x: 0.67, y: 1 } as const,
} as const;

/**
 * Degrades des avatars.
 *
 * Aucune photographie de personne reelle n'est utilisee : un visage emprunte
 * sur une banque d'images, place sur un faux profil de rencontre, poserait un
 * probleme de droit a l'image. Chaque profil recoit donc un degrade chaud,
 * choisi de facon deterministe a partir de son identifiant — deux profils
 * voisins ne se ressemblent jamais, et le meme profil garde son visuel.
 */
export const avatarGradients: readonly (readonly [string, string, string])[] = [
  ['#F4A7B0', '#D4507A', '#8E3A6E'],
  ['#F1CDD1', '#E6526C', '#B04E86'],
  ['#C9D8F0', '#7E86C4', '#1A2150'],
  ['#F6D9BE', '#E08E6A', '#9E4A63'],
  ['#CDE7DC', '#68B79B', '#22604E'],
  ['#E7D6F0', '#A878C4', '#4A2F6E'],
  ['#FBE9EB', '#E68AA0', '#8E3A5A'],
  ['#D6E0EE', '#5E6478', '#06102A'],
] as const;

/** Degrade stable d'un profil, derive de son identifiant. */
export function avatarGradient(seed: string): readonly [string, string, string] {
  let somme = 0;
  for (let i = 0; i < seed.length; i += 1) somme = (somme + seed.charCodeAt(i) * (i + 1)) % 9973;
  return avatarGradients[somme % avatarGradients.length];
}

/** Cercles decoratifs superposes au degrade, eux aussi derives du profil. */
export function avatarBlobs(seed: string): { x: number; y: number; r: number; o: number }[] {
  let h = 7;
  for (let i = 0; i < seed.length; i += 1) h = (h * 31 + seed.charCodeAt(i)) % 100003;
  const suite = () => ((h = (h * 1103515245 + 12345) % 2147483648) / 2147483648);
  return Array.from({ length: 3 }, () => ({
    x: 0.1 + suite() * 0.8,
    y: 0.1 + suite() * 0.8,
    r: 0.18 + suite() * 0.26,
    o: 0.10 + suite() * 0.16,
  }));
}

/**
 * Échelle en multiples de 4.
 *
 * `demi` est la seule exception : c'est l'écart entre un libellé et sa
 * légende, qui doivent se lire comme un seul bloc. À 4 points ils se séparent.
 */
export const spacing = {
  demi: 2,
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

/**
 * Rayons.
 *
 * Trois valeurs portent le dessin : la carte à 24, la photo à 32, et la
 * pilule pour tout ce qui se clique ou s'étiquette. Les autres ne sont là que
 * pour les éléments internes.
 */
export const radius = {
  sm: 12,
  /** Carte interne — un encart pose dans un ecran, pas une carte de profil. */
  md: 20,
  /** Carte. */
  lg: 24,
  /** Photo. */
  xl: 32,
  /** Bouton et badge. */
  pill: 999,
  carte: 24,
  photo: 32,
  bouton: 999,
  badge: 999,
} as const;

export const hairline = 1;

/**
 * Mesures des composants du système, relevées sur les nodes Figma.
 *
 * Elles vivent ici et non dans les composants : la règle vaut pour les
 * tailles autant que pour les couleurs, sinon une refonte oblige à rouvrir
 * chaque fichier.
 */
export const composants = {
  /** Bouton — node 2:117. Pilule de 56, contour de 1,5 sur la variante claire. */
  bouton: {
    hauteur: 56,
    paddingH: 24,
    trait: 1.5,
    gap: 8,
    icone: 20,
  },
  /** Chip — node 2:124. */
  chip: {
    hauteur: 40,
    paddingH: 16,
    gap: 6,
    trait: 1,
    traitSelection: 1.5,
    coche: 17,
  },
  /** Badge Premium des filtres avancés — node 11:735. */
  badgePremium: {
    paddingH: 10,
    paddingV: 5,
    gap: 10,
  },
  /** Badge — node 2:143. */
  badge: {
    paddingH: 12,
    paddingV: 6,
    gap: 6,
    icone: 15,
  },
  /** Barre d'onglets — node 2:314. */
  barreOnglets: {
    hauteur: 90,
    paddingTop: 8,
    paddingH: 8,
    onglet: 72,
    pastilleLargeur: 56,
    pastilleHauteur: 32,
    icone: 24,
    gap: 4,
    flou: 10,
  },
  /** Curseur de reglage — nodes 11:704, 11:744. */
  curseur: {
    hauteur: 24,
    rail: 6,
    poignee: 24,
    /** Contour corail de la poignee. */
    anneau: 2,
  },
  /** Interrupteur — node 11:730. */
  interrupteur: {
    largeur: 52,
    hauteur: 32,
    pastille: 26,
    marge: 3,
  },
  /** Bouton rond d'en-tete — nodes 3:97, 11:679. */
  boutonRond: {
    cote: 44,
    icone: 24,
  },
  /** Ecran Parcourir — node 3:81. */
  parcourir: {
    /** Carte du carrousel d'affinites. */
    affiniteLargeur: 148,
    affiniteHauteur: 200,
    /** Vignette de la grille de proximite. */
    vignetteLargeur: 166,
    vignetteHauteur: 212,
    grilleGapX: 10,
    grilleGapY: 18,
    /** Debord du badge de score dans le coin de la photo. */
    badgeDecalage: 10,
    /** Retrait du prenom pose sur la photo — il suit la courbe du coin. */
    prenomGauche: 14,
    /** Entre la vignette et la ligne d'identite. */
    vignetteGap: 10,
    /** Halo decoratif pose derriere l'en-tete. */
    haloLargeur: 520,
    haloHauteur: 420,
    haloGauche: 80,
    haloHaut: -220,
    /** Flou pose sur une carte verrouillee. */
    flouPremium: 9,
  },
  /** Logo — grille Figma de 120 × 124 pour le symbole. */
  logo: {
    largeur: 120,
    hauteur: 124,
    gap: 8,
  },
} as const;

/**
 * Familles.
 *
 * Les noms sont ceux sous lesquels `expo-font` enregistre les fichiers dans
 * `app/_layout.tsx` — les changer d'un côté sans l'autre donne une police
 * système silencieusement substituée.
 *
 * Instrument Serif n'existe qu'en italique dans notre usage : le fichier est
 * déjà italique, il ne faut donc jamais y ajouter `fontStyle: 'italic'`, qui
 * ferait pencher une seconde fois la lettre sur Android.
 */
export const fonts = {
  /** Plus Jakarta Sans — titres et chiffres. */
  titreExtraBold: 'PlusJakartaSans_800ExtraBold',
  titreBold: 'PlusJakartaSans_700Bold',
  /** Le seul usage : le mot « SafeDate » du logo horizontal. */
  titreSemiBold: 'PlusJakartaSans_600SemiBold',
  /** Instrument Serif Italic — les mots d'émotion, jamais une phrase entière. */
  serifItalique: 'InstrumentSerif_400Regular_Italic',
  /** Inter — tout le texte courant. */
  corpsRegular: 'Inter_400Regular',
  corpsMedium: 'Inter_500Medium',
  corpsSemiBold: 'Inter_600SemiBold',

  // Anciens noms, conservés le temps que les écrans passent au nouveau jeu.
  displayLight: 'PlusJakartaSans_700Bold',
  displayRegular: 'PlusJakartaSans_700Bold',
  bodyRegular: 'Inter_400Regular',
  bodyMedium: 'Inter_500Medium',
} as const;

/**
 * Échelle typographique.
 *
 * Reprise telle quelle des styles Figma. Les interlettrages y sont exprimés en
 * pourcentage de la taille ; ils sont convertis en points ici, seule unité que
 * React Native comprend.
 */
export const typography = {
  /** Titre/Display — 40/42, −3 %. Le grand titre d'un écran d'accueil. */
  displayXL: {
    fontFamily: fonts.titreExtraBold,
    fontSize: 40,
    lineHeight: 42,
    letterSpacing: -1.2,
  },
  /** Titre/H1 — 32/36, −2,5 %. Le titre d'un onglet. */
  h1: {
    fontFamily: fonts.titreExtraBold,
    fontSize: 32,
    lineHeight: 36,
    letterSpacing: -0.8,
  },
  /** Titre/H2 — 24/30, −1,5 %. Un prénom et son âge. */
  h2: {
    fontFamily: fonts.titreBold,
    fontSize: 24,
    lineHeight: 30,
    letterSpacing: -0.36,
  },
  /** Titre/H3 — 18/24, −1 %. Un intertitre de section. */
  h3: {
    fontFamily: fonts.titreBold,
    fontSize: 18,
    lineHeight: 24,
    letterSpacing: -0.18,
  },
  /** Accent/Serif — 36/40, −1 %. Deux ou trois mots, pas davantage. */
  serif: {
    fontFamily: fonts.serifItalique,
    fontSize: 36,
    lineHeight: 40,
    letterSpacing: -0.36,
  },
  /**
   * Le mot d'émotion posé en fin de titre — node 3:102.
   *
   * Plus gros que le H1 qu'il prolonge, mais sur la même interligne : les deux
   * lignes doivent se toucher, sinon le titre se casse en deux.
   */
  serifTitre: {
    fontFamily: fonts.serifItalique,
    fontSize: 40,
    lineHeight: 36,
    letterSpacing: -1,
  },
  /** Chiffre/Grand — 44/46, −3 %. Le pourcentage d'affinité, seul sur sa ligne. */
  chiffre: {
    fontFamily: fonts.titreExtraBold,
    fontSize: 44,
    lineHeight: 46,
    letterSpacing: -1.32,
  },
  /** Texte/Corps — 15/22. */
  body: {
    fontFamily: fonts.corpsRegular,
    fontSize: 15,
    lineHeight: 22,
  },
  /** Texte/Corps fort — 15/22. Le titre d'une ligne de reglage. */
  bodyFort: {
    fontFamily: fonts.corpsMedium,
    fontSize: 15,
    lineHeight: 22,
  },
  /** Texte/Bouton — 16/20. */
  bouton: {
    fontFamily: fonts.corpsSemiBold,
    fontSize: 16,
    lineHeight: 20,
  },
  /** Texte/Label — 13/18. */
  label: {
    fontFamily: fonts.corpsSemiBold,
    fontSize: 13,
    lineHeight: 18,
  },
  /** Texte/Legende — 12/16. */
  caption: {
    fontFamily: fonts.corpsMedium,
    fontSize: 12,
    lineHeight: 16,
  },
  /** Texte/Surtitre — 11/14, +8 %, toujours en capitales. */
  overline: {
    fontFamily: fonts.corpsSemiBold,
    fontSize: 11,
    lineHeight: 14,
    letterSpacing: 0.88,
    textTransform: 'uppercase',
  },

  /** Chip — 14/20. Ni un label ni un corps : sa propre taille. */
  chip: {
    fontFamily: fonts.corpsMedium,
    fontSize: 14,
    lineHeight: 20,
  },
  /** Le mot « SafeDate » du logo horizontal — 20, −0,4. */
  motMarque: {
    fontFamily: fonts.titreSemiBold,
    fontSize: 20,
    letterSpacing: -0.4,
  },
  /** Onglet actif : la graisse change en même temps que la couleur. */
  tabLabelActif: {
    fontFamily: fonts.corpsSemiBold,
    fontSize: 11,
    lineHeight: 14,
  },

  // Anciens noms, conservés le temps que les écrans passent au nouveau jeu.
  name: {
    fontFamily: fonts.titreBold,
    fontSize: 24,
    lineHeight: 30,
    letterSpacing: -0.36,
  },
  display: {
    fontFamily: fonts.titreExtraBold,
    fontSize: 32,
    lineHeight: 36,
    letterSpacing: -0.8,
  },
  heading: {
    fontFamily: fonts.titreBold,
    fontSize: 18,
    lineHeight: 24,
    letterSpacing: -0.18,
  },
  scoreValue: {
    fontFamily: fonts.titreBold,
    fontSize: 15,
    letterSpacing: -0.2,
  },
  subscoreValue: {
    fontFamily: fonts.titreExtraBold,
    fontSize: 20,
    letterSpacing: -0.4,
  },
  tabLabel: {
    fontFamily: fonts.corpsMedium,
    fontSize: 11,
    lineHeight: 14,
  },
} as const;

/**
 * Ombres portées.
 *
 * Deux couches pour la carte : un filet à 1 px qui la décolle du fond, et une
 * nappe large à 24 px qui lui donne son poids. Une seule des deux ne suffit
 * pas — le filet seul fait autocollant, la nappe seule fait flotter.
 *
 * `boxShadow` remplace les anciennes propriétés `shadow*`, dépréciées depuis
 * React Native 0.76 et sans effet sur le web.
 */
const OMBRES: Record<PaletteName, { carte: string; boutonAccent: string }> = {
  corail: {
    carte: '0 1px 2px rgba(6, 16, 42, 0.04), 0 8px 24px rgba(6, 16, 42, 0.06)',
    boutonAccent: '0 8px 20px rgba(230, 82, 108, 0.30)',
  },
  nuit: {
    carte: '0 8px 24px rgba(0, 0, 0, 0.55)',
    boutonAccent: '0 8px 20px rgba(62, 213, 152, 0.30)',
  },
  ambre: {
    carte: '0 8px 24px rgba(0, 0, 0, 0.55)',
    boutonAccent: '0 8px 20px rgba(217, 164, 65, 0.30)',
  },
  azur: {
    carte: '0 8px 24px rgba(0, 0, 0, 0.55)',
    boutonAccent: '0 8px 20px rgba(76, 154, 255, 0.30)',
  },
  braise: {
    carte: '0 8px 24px rgba(120, 60, 40, 0.14)',
    boutonAccent: '0 8px 20px rgba(228, 99, 63, 0.30)',
  },
  serein: {
    carte: '0 8px 24px rgba(42, 39, 36, 0.10)',
    boutonAccent: '0 8px 20px rgba(124, 144, 112, 0.30)',
  },
  aube: {
    carte: '0 8px 24px rgba(48, 38, 34, 0.10)',
    boutonAccent: '0 8px 20px rgba(192, 129, 99, 0.30)',
  },
  brume: {
    carte: '0 8px 24px rgba(32, 40, 48, 0.10)',
    boutonAccent: '0 8px 20px rgba(110, 139, 166, 0.30)',
  },
};

export const elevation = {
  card: {
    boxShadow: OMBRES[ACTIVE_PALETTE].carte,
  },
  soft: {
    boxShadow: `0 2px 8px ${colors.shadow}`,
  },
  /** Le seul bouton plein de l'écran, celui qui appelle le geste. */
  boutonAccent: {
    boxShadow: OMBRES[ACTIVE_PALETTE].boutonAccent,
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
  /** Doit suivre `composants.barreOnglets.hauteur`. */
  tabBarHeight: 90,
  /** Hauteur de la barre de marque, en tête de chaque écran. */
  barreNavHeight: 62,
  /** Hauteur de la barre de décision, en bas de la découverte. */
  decisionBarHeight: 84,
  /** Part de la hauteur occupée par la photo. */
  photoRatio: 0.56,
  /** Hauteur du bouton pilule. */
  boutonHeight: 56,
} as const;

/**
 * Couleurs de marque.
 *
 * Elles ne suivent pas la palette : un logo garde ses couleurs quel que soit
 * le thème, sinon ce n'est plus une marque. Seule la cloche s'adapte, parce
 * qu'un bleu nuit posé sur un fond noir disparaîtrait.
 */
export const marque = {
  corail: '#E6526C',
  framboise: '#D4507A',
  poudre: '#F1CDD1',
  poudreClair: '#FBE9EB',
  nuit: '#06102A',

  coeurDebut: '#E6526C',
  coeurFin: '#D4507A',
  clocheClaire: '#06102A',
  clocheSombre: '#FAF4EE',
  mot: '#E6526C',
} as const;

/** Carte du point de rendez-vous. */
export const carte = {
  hauteur: 188,
  /** Opacité du voile posé sur des tuiles claires pour les accorder au thème. */
  voileTuiles: 0.58,
  /** Saturation retirée aux tuiles pour ne pas concurrencer l'accent. */
  tuileOpacite: 0.72,
  pointRayon: 8,
  pointAnneau: 3,
  moiRayon: 6,
  moiAnneau: 2.5,
  halo: 26,
  trait: 1.5,
} as const;

export const theme = {
  colors,
  etats,
  decor,
  degradeImmersif,
  spacing,
  radius,
  hairline,
  composants,
  fonts,
  typography,
  elevation,
  motion,
  opacity,
  deviceFrame,
  layout,
  carte,
  marque,
} as const;

export type Theme = typeof theme;
