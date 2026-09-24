import { StyleSheet, Text, View } from 'react-native';

import { colors, elevation, marque, radius, spacing, typography } from '../../theme';

/**
 * Ce qui rapproche deux personnes — nodes Figma 9:666 et 9:675.
 *
 * Deux formes pour deux natures d'information :
 *
 * - `commun` — fond poudre, surtitre corail, réponse en serif italique entre
 *   guillemets. C'est une **citation** : la phrase vient de la personne, elle
 *   se compose donc comme une parole rapportée, pas comme une donnée.
 * - `reponse` — carte blanche, surtitre gris, texte en gras. C'est une
 *   **réponse à une question**, qui reste de l'information.
 *
 * Les libellés sont encore les questions brutes du questionnaire : les
 * formulations naturelles restent à fournir. On les présente le plus
 * doucement possible plutôt que de tenter une réécriture côté client qui
 * serait à défaire ensuite.
 */

interface CarteEnCommunProps {
  /** Le surtitre : « En commun », « Très proche », ou la question posée. */
  surtitre: string;
  texte: string;
  /** `commun` cite, `reponse` informe. */
  forme?: 'commun' | 'reponse';
}

export function CarteEnCommun({ surtitre, texte, forme = 'commun' }: CarteEnCommunProps) {
  const cite = forme === 'commun';

  return (
    <View style={[styles.carte, cite ? styles.carteCommun : styles.carteReponse]}>
      <Text
        style={[styles.surtitre, cite ? styles.surtitreCommun : styles.surtitreReponse]}
        allowFontScaling={false}
      >
        {surtitre}
      </Text>
      <Text style={cite ? styles.citation : styles.reponse}>
        {cite ? `« ${texte} »` : texte}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  carte: {
    borderRadius: radius.carte,
    paddingHorizontal: spacing.xl,
    paddingVertical: spacing.lg,
  },
  carteCommun: {
    backgroundColor: marque.poudreClair,
    gap: spacing.xs,
  },
  carteReponse: {
    backgroundColor: colors.surface,
    gap: spacing.sm + spacing.demi,
    ...elevation.card,
  },
  surtitre: { ...typography.overline },
  surtitreCommun: { color: colors.accent },
  surtitreReponse: { color: colors.textMuted },
  citation: {
    ...typography.serifCitation,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
  reponse: {
    ...typography.h3,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
});
