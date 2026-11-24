import { BlurView } from 'expo-blur';
import { Pressable, StyleSheet, Text, View, type StyleProp, type ViewStyle } from 'react-native';

import {
  IconeDecouverte,
  IconeDiscussions,
  IconeParcourir,
  IconeProfil,
  IconeRendezVous,
} from './Icones';
import { colors, composants, hairline, marque, radius, typography } from '../../theme';

/**
 * La barre d'onglets — node Figma 2:314.
 *
 * Cinq onglets, fond blanc translucide flouté, et l'onglet actif signalé par
 * une pastille poudre sous son icône. La pastille est ce qui remplace le
 * soulignement : elle se voit à la périphérie du regard, ce qu'un trait de
 * deux points ne fait pas.
 *
 * La barre ne connaît pas la navigation : elle reçoit l'onglet actif et rend
 * un choix. C'est l'écran de mise en page qui la branche sur `expo-router`.
 *
 * Le trait de séparation supérieur est rendu par une bordure et non par une
 * ombre : sur un fond flouté une ombre se verrait comme une tache.
 */

export type OngletId = 'parcourir' | 'decouverte' | 'discussions' | 'rendezVous' | 'profil';

interface Onglet {
  id: OngletId;
  libelle: string;
  icone: (couleur: string) => React.ReactNode;
}

/** L'ordre va du large au précis : on parcourt, puis on découvre un à un. */
export const ONGLETS: readonly Onglet[] = [
  {
    id: 'parcourir',
    libelle: 'Parcourir',
    icone: (couleur) => <IconeParcourir couleur={couleur} />,
  },
  {
    id: 'decouverte',
    libelle: 'Découverte',
    icone: (couleur) => <IconeDecouverte couleur={couleur} />,
  },
  {
    id: 'discussions',
    libelle: 'Discussions',
    icone: (couleur) => <IconeDiscussions couleur={couleur} />,
  },
  {
    id: 'rendezVous',
    libelle: 'Rendez-vous',
    icone: (couleur) => <IconeRendezVous couleur={couleur} />,
  },
  { id: 'profil', libelle: 'Profil', icone: (couleur) => <IconeProfil couleur={couleur} /> },
] as const;

interface BarreOngletsProps {
  actif: OngletId;
  onChoisir: (id: OngletId) => void;
  /** Marge basse à réserver à l'indicateur d'accueil du téléphone. */
  basSur?: number;
  style?: StyleProp<ViewStyle>;
}

export function BarreOnglets({ actif, onChoisir, basSur = 0, style }: BarreOngletsProps) {
  return (
    <BlurView
      intensity={composants.barreOnglets.flou * 4}
      tint="light"
      style={[styles.barre, { paddingBottom: basSur }, style]}
    >
      <View style={styles.rangee}>
        {ONGLETS.map((onglet) => {
          const estActif = onglet.id === actif;
          const teinte = estActif ? colors.accent : colors.textMuted;

          return (
            <Pressable
              key={onglet.id}
              accessibilityRole="tab"
              accessibilityState={{ selected: estActif }}
              accessibilityLabel={onglet.libelle}
              onPress={() => onChoisir(onglet.id)}
              style={styles.onglet}
            >
              <View style={[styles.pastille, estActif ? styles.pastilleActive : null]}>
                {onglet.icone(teinte)}
              </View>
              <Text
                style={[styles.libelle, estActif ? styles.libelleActif : null]}
                allowFontScaling={false}
                numberOfLines={1}
              >
                {onglet.libelle}
              </Text>
            </Pressable>
          );
        })}
      </View>
    </BlurView>
  );
}

const styles = StyleSheet.create({
  barre: {
    // `minHeight` et non `height` : la marge de l'indicateur d'accueil
    // s'ajoute à la barre au lieu de rogner la rangée d'icônes, qui perdrait
    // ses libellés sur un iPhone.
    minHeight: composants.barreOnglets.hauteur,
    paddingTop: composants.barreOnglets.paddingTop,
    borderTopWidth: hairline,
    borderTopColor: colors.rule,
    backgroundColor: colors.surfaceTranslucide,
  },
  rangee: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: composants.barreOnglets.paddingH,
    overflow: 'hidden',
  },
  onglet: {
    width: composants.barreOnglets.onglet,
    alignItems: 'center',
    gap: composants.barreOnglets.gap,
    overflow: 'hidden',
  },
  pastille: {
    width: composants.barreOnglets.pastilleLargeur,
    height: composants.barreOnglets.pastilleHauteur,
    borderRadius: radius.pill,
    alignItems: 'center',
    justifyContent: 'center',
  },
  pastilleActive: {
    backgroundColor: marque.poudreClair,
  },
  libelle: {
    ...typography.tabLabel,
    color: colors.textMuted,
    includeFontPadding: false,
  },
  libelleActif: {
    ...typography.tabLabelActif,
    color: colors.accent,
  },
});
