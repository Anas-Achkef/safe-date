import Svg, { Path } from 'react-native-svg';

import { composants } from '../../theme';

/**
 * Le jeu d'icônes du système, repris des nodes Figma 2:124, 2:143 et 2:314.
 *
 * Toutes sont tracées dans une grille de 24, en trait sans remplissage. Dans
 * Figma les variantes active et inactive d'un onglet ne diffèrent que par la
 * couleur du trait : une seule géométrie suffit donc ici, la couleur devient
 * une propriété.
 *
 * Elles sont dessinées plutôt qu'empruntées à une police : une police
 * d'icônes non chargée affiche des rectangles, ce qui suffit à trahir un
 * prototype.
 */

const GRILLE = 24;
const TRAIT = 1.5;

interface IconeProps {
  couleur: string;
  /** Côté en points. 24 par défaut, la taille des onglets. */
  taille?: number;
}

function Cadre({
  taille,
  children,
}: {
  taille: number;
  children: React.ReactNode;
}) {
  return (
    <Svg width={taille} height={taille} viewBox={`0 0 ${GRILLE} ${GRILLE}`} fill="none">
      {children}
    </Svg>
  );
}

/** Parcourir — une mosaïque : on voit beaucoup de monde d'un coup. */
export function IconeParcourir({ couleur, taille = composants.barreOnglets.icone }: IconeProps) {
  return (
    <Cadre taille={taille}>
      <Path
        d="M8.5 3H4.5C3.67157 3 3 3.67157 3 4.5V8.5C3 9.32843 3.67157 10 4.5 10H8.5C9.32843 10 10 9.32843 10 8.5V4.5C10 3.67157 9.32843 3 8.5 3Z"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M19.5 3H15.5C14.6716 3 14 3.67157 14 4.5V8.5C14 9.32843 14.6716 10 15.5 10H19.5C20.3284 10 21 9.32843 21 8.5V4.5C21 3.67157 20.3284 3 19.5 3Z"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M19.5 14H15.5C14.6716 14 14 14.6716 14 15.5V19.5C14 20.3284 14.6716 21 15.5 21H19.5C20.3284 21 21 20.3284 21 19.5V15.5C21 14.6716 20.3284 14 19.5 14Z"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M8.5 14H4.5C3.67157 14 3 14.6716 3 15.5V19.5C3 20.3284 3.67157 21 4.5 21H8.5C9.32843 21 10 20.3284 10 19.5V15.5C10 14.6716 9.32843 14 8.5 14Z"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Cadre>
  );
}

/** Découverte — une boussole : on part chercher, un profil à la fois. */
export function IconeDecouverte({ couleur, taille = composants.barreOnglets.icone }: IconeProps) {
  return (
    <Cadre taille={taille}>
      <Path
        d="M12 22C17.5228 22 22 17.5228 22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715 2 12C2 17.5228 6.47715 22 12 22Z"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M16.24 7.76L14.12 14.12L7.76 16.24L9.88 9.88L16.24 7.76Z"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Cadre>
  );
}

/** Discussions — une bulle. */
export function IconeDiscussions({ couleur, taille = composants.barreOnglets.icone }: IconeProps) {
  return (
    <Cadre taille={taille}>
      <Path
        d="M7.9 20C9.80858 20.9791 12.0041 21.2442 14.0909 20.7478C16.1777 20.2513 18.0186 19.0258 19.2818 17.2922C20.545 15.5585 21.1474 13.4307 20.9806 11.2922C20.8137 9.15361 19.8886 7.14497 18.3718 5.62819C16.855 4.11142 14.8464 3.18625 12.7078 3.01942C10.5693 2.85258 8.44147 3.45505 6.70782 4.71825C4.97417 5.98145 3.74869 7.82231 3.25222 9.90911C2.75575 11.9959 3.02094 14.1914 4 16.1L2 22L7.9 20Z"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Cadre>
  );
}

/** Rendez-vous — un repère de lieu : tout le produit tient à la proximité. */
export function IconeRendezVous({ couleur, taille = composants.barreOnglets.icone }: IconeProps) {
  return (
    <Cadre taille={taille}>
      <Path
        d="M12.601 21.799C14.461 20.193 20 14.993 20 10C20 7.87827 19.1571 5.84344 17.6569 4.34315C16.1566 2.84285 14.1217 2 12 2C9.87827 2 7.84344 2.84285 6.34315 4.34315C4.84285 5.84344 4 7.87827 4 10C4 14.993 9.539 20.193 11.399 21.799C11.5723 21.9293 11.7832 21.9998 12 21.9998C12.2168 21.9998 12.4277 21.9293 12.601 21.799Z"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M12 13C13.6569 13 15 11.6569 15 10C15 8.34315 13.6569 7 12 7C10.3431 7 9 8.34315 9 10C9 11.6569 10.3431 13 12 13Z"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Cadre>
  );
}

/** Profil — une silhouette. */
export function IconeProfil({ couleur, taille = composants.barreOnglets.icone }: IconeProps) {
  return (
    <Cadre taille={taille}>
      <Path
        d="M19 21V19C19 17.9391 18.5786 16.9217 17.8284 16.1716C17.0783 15.4214 16.0609 15 15 15H9C7.93913 15 6.92172 15.4214 6.17157 16.1716C5.42143 16.9217 5 17.9391 5 19V21"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M12 11C14.2091 11 16 9.20914 16 7C16 4.79086 14.2091 3 12 3C9.79086 3 8 4.79086 8 7C8 9.20914 9.79086 11 12 11Z"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Cadre>
  );
}

/** Coche du chip sélectionné — node 2:121, grille de 16,8. */
export function IconeValider({ couleur, taille = composants.chip.coche }: IconeProps) {
  return (
    <Svg width={taille} height={taille} viewBox="0 0 16.8 16.8" fill="none">
      <Path
        d="M14 4.2L6.3 11.9L2.8 8.4"
        stroke={couleur}
        strokeWidth={1.05}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

/** Bouclier coché du badge « Vérifié » — node 2:128, grille de 15. */
export function IconeVerifie({ couleur, taille = composants.badge.icone }: IconeProps) {
  return (
    <Svg width={taille} height={taille} viewBox="0 0 15 15" fill="none">
      <Path
        d="M12.5 8.125C12.5 11.25 10.3125 12.8125 7.7125 13.7188C7.57635 13.7649 7.42846 13.7627 7.29375 13.7125C4.6875 12.8125 2.5 11.25 2.5 8.125V3.75C2.5 3.58424 2.56585 3.42527 2.68306 3.30806C2.80027 3.19085 2.95924 3.125 3.125 3.125C4.375 3.125 5.9375 2.375 7.025 1.425C7.15741 1.31187 7.32585 1.24972 7.5 1.24972C7.67415 1.24972 7.84259 1.31187 7.975 1.425C9.06875 2.38125 10.625 3.125 11.875 3.125C12.0408 3.125 12.1997 3.19085 12.3169 3.30806C12.4342 3.42527 12.5 3.58424 12.5 3.75V8.125Z"
        stroke={couleur}
        strokeWidth={0.9375}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M5.625 7.5L6.875 8.75L9.375 6.25"
        stroke={couleur}
        strokeWidth={0.9375}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

/** Cœur du badge « Rencontre » — node 2:133, grille de 15. */
export function IconeCoeur({ couleur, taille = composants.badge.icone }: IconeProps) {
  return (
    <Svg width={taille} height={taille} viewBox="0 0 15 15" fill="none">
      <Path
        d="M11.875 8.75C12.8063 7.8375 13.75 6.74375 13.75 5.3125C13.75 4.40082 13.3878 3.52648 12.7432 2.88182C12.0985 2.23716 11.2242 1.875 10.3125 1.875C9.2125 1.875 8.4375 2.1875 7.5 3.125C6.5625 2.1875 5.7875 1.875 4.6875 1.875C3.77582 1.875 2.90148 2.23716 2.25682 2.88182C1.61216 3.52648 1.25 4.40082 1.25 5.3125C1.25 6.75 2.1875 7.84375 3.125 8.75L7.5 13.125L11.875 8.75Z"
        stroke={couleur}
        strokeWidth={0.9375}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

/** Horloge du badge « Délai » — node 2:137, grille de 15. */
export function IconeHorloge({ couleur, taille = composants.badge.icone }: IconeProps) {
  return (
    <Svg width={taille} height={taille} viewBox="0 0 15 15" fill="none">
      <Path
        d="M7.5 13.75C10.9518 13.75 13.75 10.9518 13.75 7.5C13.75 4.04822 10.9518 1.25 7.5 1.25C4.04822 1.25 1.25 4.04822 1.25 7.5C1.25 10.9518 4.04822 13.75 7.5 13.75Z"
        stroke={couleur}
        strokeWidth={0.9375}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M7.5 3.75V7.5L10 8.75"
        stroke={couleur}
        strokeWidth={0.9375}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

/** Réglages — node 3:98. Ouvre le panneau de filtres. */
export function IconeFiltres({ couleur, taille = composants.boutonRond.icone }: IconeProps) {
  return (
    <Cadre taille={taille}>
      <Path
        d="M21 4H14M10 4H3M21 12H12M8 12H3M21 20H16M12 20H3M14 2V6M8 10V14M16 18V22"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Cadre>
  );
}

/** Croix de fermeture — node 11:680. */
export function IconeFermer({ couleur, taille = composants.boutonRond.icone }: IconeProps) {
  return (
    <Cadre taille={taille}>
      <Path
        d="M18 6L6 18"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M6 6L18 18"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Cadre>
  );
}

/** Cadenas — node 3:131. Marque un profil que l'abonnement seul révèle. */
export function IconeCadenas({ couleur, taille = composants.barreOnglets.icone }: IconeProps) {
  return (
    <Cadre taille={taille}>
      <Path
        d="M19 11H5C3.89543 11 3 11.8954 3 13V20C3 21.1046 3.89543 22 5 22H19C20.1046 22 21 21.1046 21 20V13C21 11.8954 20.1046 11 19 11Z"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M7 11V7C7 5.67392 7.52678 4.40215 8.46447 3.46447C9.40215 2.52678 10.6739 2 12 2C13.3261 2 14.5979 2.52678 15.5355 3.46447C16.4732 4.40215 17 5.67392 17 7V11"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Cadre>
  );
}

/**
 * Appareil photo — node 3:106.
 *
 * Marque l'emplacement d'une photo absente. Il ne s'affiche jamais par-dessus
 * une vraie photographie : c'est un repli, pas une décoration.
 */
export function IconePhoto({ couleur, taille = 29 }: IconeProps) {
  return (
    <Svg width={taille} height={taille} viewBox="0 0 28.8 28.8" fill="none" opacity={0.7}>
      <Path
        d="M17.4 4.8H11.4L8.4 8.4H4.8C4.16348 8.4 3.55303 8.65286 3.10294 9.10294C2.65286 9.55303 2.4 10.1635 2.4 10.8V21.6C2.4 22.2365 2.65286 22.847 3.10294 23.2971C3.55303 23.7471 4.16348 24 4.8 24H24C24.6365 24 25.247 23.7471 25.6971 23.2971C26.1471 22.847 26.4 22.2365 26.4 21.6V10.8C26.4 10.1635 26.1471 9.55303 25.6971 9.10294C25.247 8.65286 24.6365 8.4 24 8.4H20.4L17.4 4.8Z"
        stroke={couleur}
        strokeWidth={1.8}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M14.4 19.2C16.3882 19.2 18 17.5882 18 15.6C18 13.6118 16.3882 12 14.4 12C12.4118 12 10.8 13.6118 10.8 15.6C10.8 17.5882 12.4118 19.2 14.4 19.2Z"
        stroke={couleur}
        strokeWidth={1.8}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

/** Étoile filante du badge Premium — node 11:736, grille de 14,4. */
export function IconePremium({ couleur, taille = 15 }: IconeProps) {
  return (
    <Svg width={taille} height={taille} viewBox="0 0 14.4 14.4" fill="none">
      <Path
        d="M6.9372 1.9596C6.9631 1.91256 7.00114 1.87334 7.04737 1.84602C7.0936 1.8187 7.14631 1.80429 7.2 1.80429C7.25369 1.80429 7.30641 1.8187 7.35263 1.84602C7.39886 1.87334 7.4369 1.91256 7.4628 1.9596L9.234 5.322C9.27624 5.39986 9.33519 5.4674 9.40663 5.51977C9.47806 5.57214 9.5602 5.60805 9.64716 5.62492C9.73412 5.64178 9.82373 5.63918 9.90956 5.61731C9.9954 5.59543 10.0753 5.55482 10.1436 5.4984L12.7098 3.3C12.7591 3.25993 12.8198 3.23653 12.8832 3.23316C12.9466 3.22979 13.0094 3.24663 13.0627 3.28125C13.1159 3.31587 13.1568 3.36649 13.1794 3.42581C13.202 3.48514 13.2053 3.55012 13.1886 3.6114L11.4882 9.759C11.4535 9.8848 11.3787 9.99585 11.2752 10.0753C11.1717 10.1548 11.0451 10.1984 10.9146 10.1994H3.486C3.3554 10.1985 3.22867 10.155 3.12504 10.0755C3.0214 9.99602 2.94654 9.8849 2.9118 9.759L1.212 3.612C1.19535 3.55072 1.19857 3.48574 1.2212 3.42641C1.24384 3.36709 1.28471 3.31647 1.33794 3.28185C1.39117 3.24723 1.45401 3.23039 1.51742 3.23376C1.58083 3.23713 1.64154 3.26053 1.6908 3.3006L4.2564 5.499C4.32468 5.55543 4.4046 5.59603 4.49044 5.61791C4.57627 5.63978 4.66588 5.64238 4.75284 5.62552C4.8398 5.60865 4.92194 5.57274 4.99338 5.52037C5.06481 5.468 5.12376 5.40046 5.166 5.3226L6.9372 1.9596Z"
        stroke={couleur}
        strokeWidth={0.9}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M3 12.6H11.4"
        stroke={couleur}
        strokeWidth={0.9}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

/** Chevron de retour — node 9:622. */
export function IconeRetour({ couleur, taille = composants.boutonRond.icone }: IconeProps) {
  return (
    <Cadre taille={taille}>
      <Path
        d="M15 18L9 12L15 6"
        stroke={couleur}
        strokeWidth={TRAIT}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Cadre>
  );
}

/**
 * Cœur plein — node 10:654.
 *
 * Distinct de `IconeCoeur`, qui n'est qu'un tracé : celui-ci est rempli, et
 * n'apparaît qu'au moment du coup de cœur réciproque. Un cœur plein ailleurs
 * banaliserait le seul écran qui le mérite.
 */
export function IconeCoeurPlein({ couleur, taille = 29 }: IconeProps) {
  return (
    <Svg width={taille} height={taille} viewBox="0 0 28.8 28.8" fill="none">
      <Path
        d="M22.8 16.8C24.588 15.048 26.4 12.948 26.4 10.2C26.4 8.44957 25.7046 6.77084 24.4669 5.5331C23.2292 4.29536 21.5504 3.6 19.8 3.6C17.688 3.6 16.2 4.2 14.4 6C12.6 4.2 11.112 3.6 9 3.6C7.24957 3.6 5.57084 4.29536 4.3331 5.5331C3.09536 6.77084 2.4 8.44957 2.4 10.2C2.4 12.96 4.2 15.06 6 16.8L14.4 25.2L22.8 16.8Z"
        fill={couleur}
        stroke={couleur}
        strokeWidth={1.8}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}
