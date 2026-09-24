import type { StyleProp, ViewStyle } from 'react-native';

import { LogoHorizontal, LogoSymbole, LogoSymboleBlanc } from './ui/Logo';

interface Props {
  /** Hauteur du symbole en points. */
  taille?: number;
  /** Ajoute le mot « SafeDate » à droite du symbole. */
  motMarque?: boolean;
  /** Vrai sur fond immersif : le symbole et le mot passent en blanc. */
  surSombre?: boolean;
  style?: StyleProp<ViewStyle>;
}

/**
 * Ancien point d'entrée du logo, conservé le temps que les écrans passent aux
 * composants de `src/components/ui/Logo.tsx`.
 *
 * Il ne dessine plus rien : le tracé approximatif qu'il portait a été remplacé
 * par l'export Figma exact, et ce fichier ne fait plus que rediriger.
 */
export function MarqueSafeDate({
  taille = 32,
  motMarque = false,
  surSombre = false,
  style,
}: Props) {
  if (motMarque) {
    return <LogoHorizontal taille={taille} blanc={surSombre} style={style} />;
  }

  return surSombre ? (
    <LogoSymboleBlanc taille={taille} style={style} />
  ) : (
    <LogoSymbole taille={taille} style={style} />
  );
}
