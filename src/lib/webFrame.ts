import { Platform } from 'react-native';

import { colors, deviceFrame } from '../theme';

/**
 * Contraintes propres au rendu navigateur.
 *
 * Le navigateur n'est qu'un outil d'itération : aucun design mobile ne résiste
 * à un étirement sur 2400 px de large. On force donc un cadre d'appareil de
 * 390 × 844, centré, le reste de la page en noir.
 *
 * On en profite pour installer l'accrochage magnétique du défilement :
 * `pagingEnabled` et `snapToInterval` ne sont pas honorés par
 * react-native-web, alors que `scroll-snap` l'est nativement par le navigateur.
 * Les deux mécanismes coexistent, chacun sur sa plateforme.
 */
const CSS = `
  html, body {
    background: ${colors.backdrop};
    margin: 0;
    height: 100%;
    overflow: hidden;
  }
  #root {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100vh;
    width: 100vw;
  }
  #root > div {
    width: ${deviceFrame.width}px !important;
    height: ${deviceFrame.height}px !important;
    max-height: 100vh;
    flex: none !important;
    overflow: hidden;
    position: relative;
    border-radius: 20px;
    box-shadow: 0 24px 60px rgba(0,0,0,0.18);
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

/** Marqueurs consommés par les règles CSS ci-dessus. Sans effet hors web. */
export const snapContainerProps =
  Platform.OS === 'web' ? ({ dataSet: { snap: 'container' } } as object) : {};

export const snapChildProps =
  Platform.OS === 'web' ? ({ dataSet: { snap: 'child' } } as object) : {};
