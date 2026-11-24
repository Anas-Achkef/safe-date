import { router } from 'expo-router';
import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { MarqueSafeDate } from '../src/components/MarqueSafeDate';
import { activerPremium, usePremium } from '../src/hooks/usePremium';
import { colors, hairline, opacity, radius, spacing, typography } from '../src/theme';

interface Formule {
  cle: string;
  duree: string;
  prix: string;
  parMois: string;
  economie: string | null;
}

/**
 * Les formules.
 *
 * Les montants sont en francs suisses : le produit s'adresse d'abord au
 * marché romand. Ils sont posés ici en attendant les vrais identifiants de
 * produit App Store et Play Console, qui porteront les prix réels — un prix
 * affiché par le client et un prix facturé par la boutique qui divergent, et
 * c'est un litige.
 */
const FORMULES: Formule[] = [
  { cle: 'm1', duree: '1 mois', prix: 'CHF 24.90', parMois: 'CHF 24.90 / mois', economie: null },
  { cle: 'm3', duree: '3 mois', prix: 'CHF 59.70', parMois: 'CHF 19.90 / mois', economie: '−20 %' },
  { cle: 'm12', duree: '12 mois', prix: 'CHF 154.80', parMois: 'CHF 12.90 / mois', economie: '−48 %' },
];

const AVANTAGES: { titre: string; texte: string }[] = [
  {
    titre: 'Vos meilleures compatibilités, révélées',
    texte: 'Les profils au-delà de votre seuil cessent d’être floutés.',
  },
  {
    titre: 'Filtres avancés',
    texte: 'Taille, tabac, alcool, enfants : affinez sur le mode de vie.',
  },
  {
    titre: 'Plus de rendez-vous par mois',
    texte: 'La sélection reste courte, mais elle se renouvelle plus souvent.',
  },
  {
    titre: 'Vous voyez qui s’intéresse à vous',
    texte: 'Sans attendre que la réciprocité se déclare d’elle-même.',
  },
];

/**
 * Abonnement.
 *
 * On arrive ici avec l'envie de payer, pas avec une liste de choses à faire :
 * l'écran montre ce qu'on obtient, ce que ça coûte, et un bouton. Les
 * conditions d'utilisation restent à accepter, mais à l'inscription — les
 * mélanger au paiement ferait fuir sans rien protéger.
 */
export default function Premium() {
  const { premium } = usePremium();
  const [choix, setChoix] = useState('m3');
  const [enCours, setEnCours] = useState(false);

  return (
    <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
      <View style={styles.barre}>
        <Pressable onPress={() => router.back()} hitSlop={12}>
          <Text style={styles.retour} allowFontScaling={false}>
            Fermer
          </Text>
        </Pressable>
        <MarqueSafeDate taille={26} />
        <View style={styles.equilibre} />
      </View>

      <ScrollView contentContainerStyle={styles.contenu} showsVerticalScrollIndicator={false}>
        <Text style={styles.titre} allowFontScaling={false}>
          Safe Date Premium
        </Text>
        <Text style={styles.chapeau}>
          Le calcul de compatibilité reste le même. Ce que l’abonnement change, c’est ce que
          vous avez le droit d’en voir.
        </Text>

        <View style={styles.avantages}>
          {AVANTAGES.map((a) => (
            <View key={a.titre} style={styles.avantage}>
              <View style={styles.coche} />
              <View style={styles.avantageTexte}>
                <Text style={styles.avantageTitre}>{a.titre}</Text>
                <Text style={styles.avantageNote}>{a.texte}</Text>
              </View>
            </View>
          ))}
        </View>

        <View style={styles.formules}>
          {FORMULES.map((f) => {
            const actif = f.cle === choix;
            return (
              <Pressable
                key={f.cle}
                onPress={() => setChoix(f.cle)}
                style={[styles.formule, actif && styles.formuleActive]}
              >
                <View style={styles.formuleGauche}>
                  <View style={[styles.radio, actif && styles.radioActif]} />
                  <View>
                    <Text style={styles.formuleDuree} allowFontScaling={false}>
                      {f.duree}
                    </Text>
                    <Text style={styles.formuleParMois}>{f.parMois}</Text>
                  </View>
                </View>
                <View style={styles.formuleDroite}>
                  <Text style={styles.formulePrix} allowFontScaling={false}>
                    {f.prix}
                  </Text>
                  {f.economie ? (
                    <Text style={styles.economie} allowFontScaling={false}>
                      {f.economie}
                    </Text>
                  ) : null}
                </View>
              </Pressable>
            );
          })}
        </View>

        {premium ? (
          <View style={styles.actif}>
            <Text style={styles.actifTexte}>Votre abonnement est actif.</Text>
          </View>
        ) : (
          <Pressable
            style={({ pressed }) => [styles.payer, pressed && styles.presse]}
            disabled={enCours}
            onPress={() => {
              setEnCours(true);
              void activerPremium(choix).then(() => router.back());
            }}
          >
            <Text style={styles.payerTexte} allowFontScaling={false}>
              {enCours ? 'Un instant…' : 'Continuer'}
            </Text>
          </Pressable>
        )}

        <Text style={styles.mentions}>
          Renouvellement automatique, résiliable à tout moment depuis les réglages de votre
          compte. Le paiement est prélevé par l’App Store ou Google Play.
        </Text>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  page: { flex: 1, backgroundColor: colors.background },
  barre: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: spacing.gutter,
    paddingVertical: spacing.sm,
    borderBottomWidth: hairline,
    borderBottomColor: colors.rule,
  },
  retour: { ...typography.label, color: colors.accent },
  equilibre: { width: 48 },

  contenu: {
    paddingHorizontal: spacing.gutter,
    paddingTop: spacing.xl,
    paddingBottom: spacing.giant,
    gap: spacing.lg,
  },
  titre: { ...typography.display, color: colors.textPrimary, includeFontPadding: false },
  chapeau: { ...typography.body, color: colors.textSecondary },

  avantages: { gap: spacing.md, marginTop: spacing.sm },
  avantage: { flexDirection: 'row', gap: spacing.md, alignItems: 'flex-start' },
  coche: {
    width: 8,
    height: 8,
    borderRadius: radius.pill,
    backgroundColor: colors.accent,
    marginTop: 7,
  },
  avantageTexte: { flex: 1, gap: 2 },
  avantageTitre: { ...typography.label, color: colors.textPrimary },
  avantageNote: { ...typography.caption, color: colors.textMuted },

  formules: { gap: spacing.sm, marginTop: spacing.md },
  formule: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: spacing.lg,
    borderRadius: radius.md,
    borderWidth: hairline,
    borderColor: colors.rule,
    backgroundColor: colors.surface,
  },
  formuleActive: { borderColor: colors.accent, backgroundColor: colors.accentSoft },
  formuleGauche: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  radio: {
    width: 20,
    height: 20,
    borderRadius: radius.pill,
    borderWidth: 2,
    borderColor: colors.rule,
  },
  radioActif: { borderColor: colors.accent, borderWidth: 6 },
  formuleDuree: { ...typography.label, color: colors.textPrimary },
  formuleParMois: { ...typography.caption, color: colors.textMuted },
  formuleDroite: { alignItems: 'flex-end', gap: 2 },
  formulePrix: { ...typography.label, color: colors.textPrimary },
  economie: {
    ...typography.overline,
    color: colors.onAccent,
    backgroundColor: colors.accent,
    borderRadius: radius.pill,
    paddingHorizontal: spacing.sm,
    overflow: 'hidden',
  },

  payer: {
    backgroundColor: colors.accent,
    borderRadius: radius.pill,
    paddingVertical: spacing.lg,
    alignItems: 'center',
    marginTop: spacing.md,
  },
  payerTexte: { ...typography.label, color: colors.onAccent },
  presse: { opacity: opacity.pressed },
  actif: {
    backgroundColor: colors.accentSoft,
    borderRadius: radius.md,
    padding: spacing.lg,
    alignItems: 'center',
    marginTop: spacing.md,
  },
  actifTexte: { ...typography.label, color: colors.accent },
  mentions: { ...typography.caption, color: colors.textMuted, textAlign: 'center' },
});
