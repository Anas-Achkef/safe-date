import type { ColorValue } from 'react-native';
import Svg, { Circle, Path } from 'react-native-svg';

/**
 * Icônes d'onglets, dessinées plutôt qu'empruntées à une police.
 *
 * Trait de 1,5 px, style strictement linéaire, aucun remplissage. Une police
 * d'icônes non chargée affiche des rectangles ou des triangles, ce qui suffit
 * à trahir un prototype.
 */

const SIZE = 22;
const STROKE = 1.5;

interface IconProps {
  color: ColorValue;
}

function Frame({ children }: { children: React.ReactNode }) {
  return (
    <Svg width={SIZE} height={SIZE} viewBox="0 0 24 24" fill="none">
      {children}
    </Svg>
  );
}

/** Parcourir — une mosaïque : on voit beaucoup de monde d'un coup. */
export function LearningIcon({ color }: IconProps) {
  return (
    <Frame>
      <Path
        d="M4.2 4.2h6.1v6.1H4.2zM13.7 4.2h6.1v6.1h-6.1zM4.2 13.7h6.1v6.1H4.2zM13.7 13.7h6.1v6.1h-6.1z"
        stroke={color}
        strokeWidth={STROKE}
        strokeLinejoin="round"
      />
    </Frame>
  );
}

/** Découverte — un losange : la sélection, la pièce rare. */
export function DiscoveryIcon({ color }: IconProps) {
  return (
    <Frame>
      <Path
        d="M12 2.5 21.5 12 12 21.5 2.5 12 12 2.5Z"
        stroke={color}
        strokeWidth={STROKE}
        strokeLinejoin="round"
      />
    </Frame>
  );
}

/** Conversations — une bulle sobre. */
export function ConversationsIcon({ color }: IconProps) {
  return (
    <Frame>
      <Path
        d="M20.5 12.2c0 3.7-3.8 6.7-8.5 6.7-1 0-2-.14-2.9-.4L4 20.5l1.6-3.6C4.2 15.6 3.5 14 3.5 12.2c0-3.7 3.8-6.7 8.5-6.7s8.5 3 8.5 6.7Z"
        stroke={color}
        strokeWidth={STROKE}
        strokeLinejoin="round"
      />
    </Frame>
  );
}

/** Rendez-vous — un repère de lieu : tout le produit tient à la proximité. */
export function DatesIcon({ color }: IconProps) {
  return (
    <Frame>
      <Path
        d="M12 21.5s7-6.9 7-11.5a7 7 0 1 0-14 0c0 4.6 7 11.5 7 11.5Z"
        stroke={color}
        strokeWidth={STROKE}
        strokeLinejoin="round"
      />
      <Circle cx={12} cy={9.8} r={2.6} stroke={color} strokeWidth={STROKE} />
    </Frame>
  );
}

/** Profil — une silhouette. */
export function ProfileIcon({ color }: IconProps) {
  return (
    <Frame>
      <Circle cx={12} cy={8} r={4} stroke={color} strokeWidth={STROKE} />
      <Path
        d="M4.5 20.5c0-3.6 3.4-6 7.5-6s7.5 2.4 7.5 6"
        stroke={color}
        strokeWidth={STROKE}
        strokeLinecap="round"
      />
    </Frame>
  );
}
