import { StyleSheet, Text, View } from 'react-native';

import { colors, spacing, typography } from '../theme';
import type { ReponseFin } from '../types/conversations';
import { Bouton } from './ui';

/**
 * La question posee a la fin des 5 minutes.
 *
 * Affichage seul : l'ecran transmet la reponse. La reponse de l'autre n'est
 * jamais montree ; seul le resultat commun l'est, et il est le meme pour les
 * deux — on ne revele jamais qui a dit non.
 */
export function DecisionFin({
  decision,
  resultat,
  enCours,
  erreur,
  onDecider,
}: {
  decision: ReponseFin | null;
  resultat: 'reciproque' | 'pas_cette_fois' | null;
  enCours: boolean;
  erreur: string | null;
  onDecider(d: ReponseFin): void;
}) {
  return (
    <View style={styles.cadre}>
      <Text style={styles.titre}>Le temps est écoulé</Text>

      {decision === null ? (
        <>
          <Text style={styles.question}>Souhaitez-vous vous voir ?</Text>
          <View style={styles.boutons}>
            <Bouton
              libelle="Oui"
              variante="primaire"
              onPress={() => onDecider('oui')}
              chargement={enCours}
              desactive={enCours}
              pleineLargeur
            />
            <Bouton
              libelle="Non"
              variante="fantome"
              onPress={() => onDecider('non')}
              desactive={enCours}
              pleineLargeur
            />
          </View>
          {erreur ? <Text style={styles.erreur}>{erreur}</Text> : null}
        </>
      ) : (
        <>
          <Text style={styles.confirmation}>Votre réponse est enregistrée.</Text>
          {resultat === 'reciproque' ? (
            <Text style={styles.resultat}>C’est réciproque !</Text>
          ) : null}
          {resultat === 'pas_cette_fois' ? (
            <Text style={styles.resultat}>Ce ne sera pas pour cette fois.</Text>
          ) : null}
        </>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  cadre: {
    paddingHorizontal: spacing.gutter,
    paddingVertical: spacing.xxl,
    gap: spacing.lg,
    alignItems: 'center',
  },
  titre: { ...typography.heading, color: colors.textPrimary, textAlign: 'center' },
  question: { ...typography.serifTitre, color: colors.textPrimary, textAlign: 'center' },
  boutons: { alignSelf: 'stretch', gap: spacing.sm },
  erreur: { ...typography.caption, color: colors.danger, textAlign: 'center' },
  confirmation: { ...typography.body, color: colors.textSecondary, textAlign: 'center' },
  resultat: { ...typography.serifTitre, color: colors.accent, textAlign: 'center' },
});
