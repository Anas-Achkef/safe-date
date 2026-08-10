import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import {
  colors,
  elevation,
  radius,
  spacing,
  typography,
} from '../theme';
import type { OptionFocus, Sollicitation } from '../types/learning';

interface Props {
  sollicitation: Sollicitation;
  onRepondre: (options: number[] | null, categorie?: string) => void;
}

/**
 * Question intermédiaire ou Focus Compatibilité.
 *
 * Deux natures de question cohabitent, et il ne faut surtout pas les
 * confondre. « Fumez-vous ? » décrit l'utilisateur ; « accepteriez-vous
 * quelqu'un qui fume ? » décrit ce qu'il recherche. Les deux réponses sont
 * indépendantes : une divergence n'est jamais une incohérence et n'entraîne
 * aucune correction automatique.
 *
 * Le Focus, lui, surgit après un swipe et porte sur ce qui a emporté la
 * décision. Fermer sans répondre est une réponse valable — le moteur retient
 * que la sollicitation a été déclinée et en proposera moins.
 */
export default function CarteSollicitation({ sollicitation, onRepondre }: Props) {
  const [choisis, setChoisis] = useState<number[]>([]);
  const focus = sollicitation.contexte === 'erreur_prediction';
  const options = sollicitation.options ?? [];

  const basculer = (idx: number) => {
    setChoisis((c) =>
      sollicitation.multi
        ? c.includes(idx)
          ? c.filter((x) => x !== idx)
          : [...c, idx]
        : [idx],
    );
  };

  const cleDe = (o: OptionFocus) => ('idx' in o ? String(o.idx) : o.cle);

  return (
    <View style={styles.zone}>
      <View style={styles.carte}>
        {focus ? (
          <View style={styles.enTeteFocus}>
            <Text style={styles.etincelle}>✦</Text>
            <Text style={styles.titreFocus}>Focus Compatibilité</Text>
            <Text style={styles.sousTitre}>{sollicitation.question}</Text>
          </View>
        ) : (
          <>
            <Text style={styles.intitule}>{sollicitation.intitule}</Text>
            <Text style={styles.question}>{sollicitation.question}</Text>
          </>
        )}

        <ScrollView
          style={styles.liste}
          contentContainerStyle={focus ? styles.grille : undefined}
          showsVerticalScrollIndicator={false}
        >
          {options.map((o) => {
            const actif = 'idx' in o && choisis.includes(o.idx);
            return (
              <Pressable
                key={cleDe(o)}
                onPress={() =>
                  'cle' in o ? onRepondre(null, o.cle) : basculer(o.idx)
                }
                style={[
                  focus ? styles.pastille : styles.option,
                  actif && styles.optionActive,
                ]}
              >
                <Text style={[styles.optionTexte, actif && styles.optionTexteActif]}>
                  {o.label}
                </Text>
              </Pressable>
            );
          })}
        </ScrollView>

        {choisis.length > 0 && (
          <Pressable style={styles.valider} onPress={() => onRepondre(choisis)}>
            <Text style={styles.validerTexte}>Valider</Text>
          </Pressable>
        )}

        <Pressable style={styles.passer} onPress={() => onRepondre(null)}>
          <Text style={styles.passerTexte}>{focus ? 'Fermer' : 'Passer'}</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  zone: { flex: 1, padding: spacing.gutter, justifyContent: 'center' },
  carte: {
    borderRadius: radius.lg,
    backgroundColor: colors.surface,
    padding: spacing.xxl,
    maxHeight: '90%',
    ...elevation.card,
  },
  enTeteFocus: { alignItems: 'center', marginBottom: spacing.xl },
  etincelle: { ...typography.display, color: colors.accent, marginBottom: spacing.xs },
  titreFocus: { ...typography.heading, color: colors.textPrimary },
  sousTitre: {
    ...typography.caption,
    color: colors.textSecondary,
    marginTop: spacing.xs,
    textAlign: 'center',
  },
  intitule: {
    ...typography.overline,
    color: colors.accent,
    textTransform: 'uppercase',
    marginBottom: spacing.sm,
  },
  question: {
    ...typography.display,
    fontSize: 22,
    color: colors.textPrimary,
    marginBottom: spacing.xl,
  },
  liste: { flexGrow: 0 },
  grille: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },
  option: {
    borderRadius: radius.md,
    backgroundColor: colors.surfaceAlt,
    paddingVertical: spacing.lg,
    paddingHorizontal: spacing.lg,
    marginBottom: spacing.sm,
  },
  pastille: {
    borderRadius: radius.pill,
    backgroundColor: colors.surfaceAlt,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
  },
  optionActive: { backgroundColor: colors.accentSoft },
  optionTexte: { ...typography.body, color: colors.textPrimary },
  optionTexteActif: { color: colors.textPrimary },
  valider: {
    marginTop: spacing.lg,
    borderRadius: radius.md,
    backgroundColor: colors.accent,
    paddingVertical: spacing.lg,
    alignItems: 'center',
  },
  validerTexte: { ...typography.label, color: colors.onAccent },
  passer: { marginTop: spacing.lg, alignItems: 'center' },
  passerTexte: {
    ...typography.caption,
    color: colors.textMuted,
    textDecorationLine: 'underline',
  },
});
