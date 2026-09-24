import { BlurView } from 'expo-blur';
import { StyleSheet, Text, View, type StyleProp, type ViewStyle } from 'react-native';

import { IconeCoeur, IconeHorloge, IconeVerifie } from './Icones';
import { colors, composants, etats, marque, radius, typography } from '../../theme';

/**
 * Le badge du système — node Figma 2:143.
 *
 * Cinq types, et chacun dit une chose précise :
 *
 * - `compatibilite` — le pourcentage d'affinité. Le seul qui se pose **sur une
 *   photo** : d'où le blanc translucide flouté, qui tient sur une image claire
 *   comme sur une image sombre.
 * - `verifie` — la sécurité : profil vérifié, lieu partenaire.
 * - `rencontre` — le type de rencontre cherché (Amour, Amitié, Fun).
 * - `delai` — le temps qu'il reste pour répondre.
 * - `neutre` — tout le reste : une distance, un quartier, un métier.
 *
 * Aucun type ne prend le rouge `etats.danger` : un badge décrit un état, il
 * ne signale pas une erreur.
 */

export type TypeBadge = 'compatibilite' | 'verifie' | 'rencontre' | 'delai' | 'neutre';

interface BadgeProps {
  libelle: string;
  type?: TypeBadge;
  style?: StyleProp<ViewStyle>;
}

/** Fond, teinte du texte et icône de chaque type. */
const TYPES: Record<
  TypeBadge,
  { fond: string; teinte: string; icone?: (couleur: string) => React.ReactNode }
> = {
  compatibilite: {
    fond: colors.surfaceTranslucide,
    teinte: colors.textPrimary,
  },
  verifie: {
    fond: etats.securiteClair,
    teinte: etats.securite,
    icone: (couleur) => <IconeVerifie couleur={couleur} />,
  },
  rencontre: {
    fond: marque.poudreClair,
    teinte: marque.corail,
    icone: (couleur) => <IconeCoeur couleur={couleur} />,
  },
  delai: {
    fond: etats.alerteClair,
    teinte: etats.alerte,
    icone: (couleur) => <IconeHorloge couleur={couleur} />,
  },
  neutre: {
    fond: colors.surfaceAlt,
    teinte: colors.textSecondary,
  },
};

/** Intensité du flou derrière le badge posé sur photo. */
const FLOU = 20;

export function Badge({ libelle, type = 'neutre', style }: BadgeProps) {
  const { fond, teinte, icone } = TYPES[type];

  const contenu = (
    <>
      {icone ? icone(teinte) : null}
      <Text style={[styles.libelle, { color: teinte }]} allowFontScaling={false} numberOfLines={1}>
        {libelle}
      </Text>
    </>
  );

  // Le badge de compatibilité est le seul à se poser sur une photo : il lui
  // faut un vrai flou, un aplat translucide laisserait passer les contrastes
  // de l'image sous le chiffre.
  if (type === 'compatibilite') {
    return (
      <BlurView intensity={FLOU} tint="light" style={[styles.base, styles.flou, style]}>
        {contenu}
      </BlurView>
    );
  }

  return <View style={[styles.base, { backgroundColor: fond }, style]}>{contenu}</View>;
}

const styles = StyleSheet.create({
  base: {
    paddingHorizontal: composants.badge.paddingH,
    paddingVertical: composants.badge.paddingV,
    borderRadius: radius.badge,
    flexDirection: 'row',
    alignItems: 'center',
    gap: composants.badge.gap,
    alignSelf: 'flex-start',
  },
  flou: {
    backgroundColor: colors.surfaceTranslucide,
    overflow: 'hidden',
  },
  libelle: {
    ...typography.label,
    includeFontPadding: false,
  },
});
