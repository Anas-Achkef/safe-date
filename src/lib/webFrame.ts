import { Platform } from 'react-native';

import { colors, deviceFrame } from '../theme';

/**
 * Contraintes propres au rendu navigateur.
 *
 * Sur grand écran, aucun design mobile ne résiste à un étirement sur 2400 px :
 * on présente donc l'application dans un cadre d'appareil de 390 × 844, centré,
 * le reste de la page en noir.
 *
 * Sur un vrai téléphone, ce cadre est un défaut, pas une aide : 390 px de large
 * dépassent d'un écran de 360, et une hauteur de 844 forcée dans une fenêtre de
 * 667 rogne la barre d'onglets. En dessous des seuils ci-dessous, l'application
 * occupe donc toute la fenêtre, sans coins arrondis ni ombre.
 *
 * On en profite pour installer l'accrochage magnétique du défilement :
 * `pagingEnabled` et `snapToInterval` ne sont pas honorés par
 * react-native-web, alors que `scroll-snap` l'est nativement par le navigateur.
 * Les deux mécanismes coexistent, chacun sur sa plateforme.
 */
/**
 * Seuils d'affichage du cadre d'appareil.
 *
 * 700 px : au-dessus, aucun téléphone — les plus larges plafonnent vers 440 px
 * en points CSS. En dessous, l'application prend tout l'écran. Le seuil ne
 * porte que sur la largeur : une fenêtre de bureau basse doit garder le cadre,
 * quitte à le raccourcir, plutôt que d'étirer l'application sur 1440 px.
 *
 * `hauteurUtile` reprend ce seuil : la règle CSS et le calcul de mise en page
 * doivent dire la même chose, sinon les hauteurs divergent.
 */
export const SEUIL_CADRE_LARGEUR = 700;

const CSS = `
  html, body {
    background: ${colors.backdrop};
    margin: 0;
    height: 100%;
    overflow: hidden;
    /* Empêche le rebond élastique d'iOS, qui décolle l'application du bas. */
    overscroll-behavior: none;
  }
  #root {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100vw;
    /*
     * Hauteur du viewport, barres du navigateur déduites.
     *
     * Safari sur iPhone compte sa barre d'adresse flottante comme de la place
     * disponible : avec « 100vh », le bas de l'application passe dessous et
     * les libellés de la barre d'onglets se retrouvent coupés. « svh » — small
     * viewport height — mesure la fenêtre barres visibles, donc la plus petite
     * qu'elle atteindra. Rien ne peut plus se cacher derrière.
     *
     * « 100vh » reste en repli pour les navigateurs qui ignorent l'unité.
     */
    height: 100vh;
    height: 100svh;
  }
  /*
   * Seul le PREMIER enfant de #root porte l'application.
   *
   * Les suivants sont des surcouches injectees par l'outillage de
   * developpement — menu Expo, indicateur de rechargement. Avec un selecteur
   * « #root > div », elles recevaient elles aussi le cadre d'appareil et,
   * #root etant centre en flex, s'affichaient comme un second telephone noir
   * a cote du vrai, apparaissant et disparaissant au gre des rechargements.
   *
   * L'application n'utilise ni Modal ni portail : rien de fonctionnel ne
   * transite par ces noeuds, on peut donc les masquer.
   *
   * CETTE REGLE EST UN CONTRAT. Une feuille modale doit se rendre dans
   * l'arbre, en position absolue — voir FeuilleFiltres.tsx. Passer par un
   * composant Modal la ferait disparaitre ici, ou s'etaler hors du cadre
   * d'appareil : le portail sort du premier enfant de #root.
   */
  /*
   * Par défaut — téléphone — l'application occupe toute la fenêtre. C'est le
   * cas le plus contraint, donc celui qu'on écrit en premier : une règle qui
   * ne s'appliquerait pas laisserait un écran utilisable, pas un écran rogné.
   */
  #root > div:first-child {
    width: 100% !important;
    height: 100% !important;
    flex: none !important;
    overflow: hidden;
    position: relative;
  }
  /* Grand écran : on retrouve le cadre d'appareil. */
  @media (min-width: ${SEUIL_CADRE_LARGEUR}px) {
    #root > div:first-child {
      width: ${deviceFrame.width}px !important;
      /* Une fenêtre plus basse que le cadre le raccourcit au lieu de le
         laisser déborder : l'application est en flex, elle s'y adapte. */
      height: min(${deviceFrame.height}px, 100vh) !important;
      border-radius: 20px;
      box-shadow: 0 24px 60px rgba(0,0,0,0.18);
    }
  }
  #root > div:not(:first-child) {
    display: none !important;
  }
  [data-snap="container"] {
    scroll-snap-type: y mandatory;
    scrollbar-width: none;
  }
  [data-snap="container"]::-webkit-scrollbar {
    display: none;
  }
  [data-snap="child"] {
    scroll-snap-align: start;
    scroll-snap-stop: always;
  }
  /*
   * Chrome impose un fond bleu-blanc sur les champs auto-remplis, qui ruine
   * un fond sombre. Aucune propriete de style React Native ne peut l'annuler :
   * il faut neutraliser -webkit-autofill directement.
   */
  input:-webkit-autofill,
  input:-webkit-autofill:hover,
  input:-webkit-autofill:focus,
  input:-webkit-autofill:active {
    -webkit-text-fill-color: ${colors.textPrimary} !important;
    -webkit-box-shadow: 0 0 0 1000px ${colors.background} inset !important;
    box-shadow: 0 0 0 1000px ${colors.background} inset !important;
    caret-color: ${colors.textPrimary};
    transition: background-color 9999s ease-in-out 0s;
  }
  input:focus, textarea:focus {
    outline: none;
  }
`;

let installed = false;

export function installWebFrame(): void {
  if (Platform.OS !== 'web' || installed) return;
  if (typeof document === 'undefined') return;

  const style = document.createElement('style');
  style.setAttribute('data-safe-date', 'frame');
  style.textContent = CSS;
  document.head.appendChild(style);
  installed = true;
}

/**
 * Hauteur réellement disponible pour l'application.
 *
 * Les écrans qui calculent une hauteur de repli ne peuvent pas se contenter de
 * `deviceFrame.height` : hors du cadre, c'est la fenêtre qui commande. Cette
 * fonction reproduit exactement la condition de la règle CSS ci-dessus, pour
 * que la mise en page et le rendu ne se contredisent jamais.
 */
export function hauteurUtile(largeurFenetre: number, hauteurFenetre: number): number {
  if (Platform.OS !== 'web') return hauteurFenetre;
  if (largeurFenetre < SEUIL_CADRE_LARGEUR) return hauteurFenetre;
  return Math.min(deviceFrame.height, hauteurFenetre);
}

/** Marqueurs consommés par les règles CSS ci-dessus. Sans effet hors web. */
export const snapContainerProps =
  Platform.OS === 'web' ? ({ dataSet: { snap: 'container' } } as object) : {};

export const snapChildProps =
  Platform.OS === 'web' ? ({ dataSet: { snap: 'child' } } as object) : {};
