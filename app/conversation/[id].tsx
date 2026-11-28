import { router, useLocalSearchParams } from 'expo-router';
import { useCallback, useRef, useState } from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { Avatar } from '../../src/components/Avatar';
import { DecisionFin } from '../../src/components/DecisionFin';
import { StateView } from '../../src/components/StateView';
import { useConversationLive } from '../../src/hooks/useConversationLive';
import { useSession } from '../../src/hooks/useSession';
import { formaterChrono } from '../../src/lib/conversationLive';
import { demo, isPreviewMode } from '../../src/preview';
import { colors, hairline, radius, spacing, typography } from '../../src/theme';

/**
 * Le fil d'une conversation de 5 minutes.
 *
 * Le temps restant vient du serveur et n'est que decompte ici entre deux
 * lectures : une conversation qui expire le fait pour les deux au meme
 * instant. Le chrono ne part que lorsque les deux sont sur cet ecran.
 */

function heure(iso: string): string {
  const d = new Date(iso);
  return `${d.getHours()}:${String(d.getMinutes()).padStart(2, '0')}`;
}

export default function Conversation() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { session } = useSession();
  const live = useConversationLive(id ?? '');
  const [brouillon, setBrouillon] = useState('');
  const defilement = useRef<ScrollView>(null);

  const moi = isPreviewMode ? demo.MOI : (session?.user.id ?? '');
  const { etat, fil, etape, restant } = live;
  const saisieOuverte = etape === 'active' || etape === 'illimitee';
  const finie = etape === 'temps_ecoule' || etape === 'decision_envoyee';

  const envoyer = useCallback(async () => {
    const corps = brouillon.trim();
    if (!corps || !saisieOuverte) return;
    setBrouillon('');
    const ok = await live.envoyer(corps);
    if (ok) {
      // Le nouveau message doit etre visible sans geste supplementaire.
      requestAnimationFrame(() => defilement.current?.scrollToEnd({ animated: true }));
    } else {
      setBrouillon(corps);
    }
  }, [brouillon, live, saisieOuverte]);

  if (live.chargement && !etat) {
    return (
      <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
        <StateView variant="loading" title="Chargement" />
      </SafeAreaView>
    );
  }

  if (!etat) {
    return (
      <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
        <StateView
          variant="error"
          title="Conversation introuvable"
          message={live.erreur ?? 'Ce fil n’existe plus.'}
          actionLabel="Retour"
          onAction={() => router.back()}
        />
      </SafeAreaView>
    );
  }

  const decompte =
    etape === 'decompte' && live.decompteJusqua !== null
      ? Math.max(1, Math.ceil((live.decompteJusqua - Date.now()) / 1000))
      : null;

  // En apercu, l'autre dit toujours oui : le resultat suit ma reponse.
  const resultat =
    isPreviewMode && live.decision !== null && id
      ? demo.decisionDe(id) === 'oui'
        ? ('reciproque' as const)
        : ('pas_cette_fois' as const)
      : null;

  const consigne =
    etape === 'attente' ? etat.message : etape === 'close' ? 'Conversation close.' : null;

  return (
    <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
      <View style={styles.entete}>
        <Pressable onPress={() => router.back()} hitSlop={12}>
          <Text style={styles.retour}>‹</Text>
        </Pressable>
        <Avatar seed={etat.autre} firstName={etat.prenom_autre} size={40} rounded="pill" />
        <View style={styles.identite}>
          <Text style={styles.prenom} numberOfLines={1}>
            {etat.prenom_autre}
          </Text>
          <Text style={styles.statut}>{etat.autre_en_ligne ? 'En ligne' : 'Hors ligne'}</Text>
        </View>
        {etape === 'active' && restant !== null ? (
          <Text style={styles.chrono}>{formaterChrono(restant)}</Text>
        ) : null}
      </View>

      {consigne ? (
        <View style={styles.consigne}>
          <Text style={styles.consigneTexte}>{consigne}</Text>
        </View>
      ) : null}

      {decompte !== null ? (
        <View style={styles.decompte}>
          <Text style={styles.decompteChiffre}>{decompte}</Text>
        </View>
      ) : (
        <KeyboardAvoidingView
          style={styles.corps}
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        >
          <ScrollView
            ref={defilement}
            contentContainerStyle={styles.fil}
            showsVerticalScrollIndicator={false}
            onContentSizeChange={() => defilement.current?.scrollToEnd({ animated: false })}
          >
            {fil.map((m) => {
              const demoi = m.sender_id === moi;
              return (
                <View key={m.id} style={[styles.bulleRangee, demoi && styles.bulleRangeeMoi]}>
                  <View style={[styles.bulle, demoi ? styles.bulleMoi : styles.bulleAutre]}>
                    <Text style={[styles.texte, demoi && styles.texteMoi]}>{m.body}</Text>
                    <Text style={[styles.heure, demoi && styles.heureMoi]}>
                      {heure(m.created_at)}
                    </Text>
                  </View>
                </View>
              );
            })}

            {finie ? (
              <DecisionFin
                decision={live.decision}
                resultat={resultat}
                enCours={live.decisionEnCours}
                erreur={live.erreurDecision}
                onDecider={(d) => void live.decider(d)}
              />
            ) : null}
          </ScrollView>

          {live.erreur ? <Text style={styles.erreur}>{live.erreur}</Text> : null}

          {saisieOuverte ? (
            <View style={styles.saisie}>
              <TextInput
                value={brouillon}
                onChangeText={setBrouillon}
                placeholder="Écrire un message"
                placeholderTextColor={colors.textMuted}
                style={styles.champ}
                multiline
                onSubmitEditing={() => void envoyer()}
              />
              <Pressable
                onPress={() => void envoyer()}
                disabled={brouillon.trim().length === 0}
                style={[styles.envoi, brouillon.trim().length === 0 && styles.envoiInactif]}
              >
                <Text style={styles.envoiTexte}>↑</Text>
              </Pressable>
            </View>
          ) : null}
        </KeyboardAvoidingView>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  page: { flex: 1, backgroundColor: colors.background },
  entete: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
    paddingHorizontal: spacing.gutter,
    paddingBottom: spacing.md,
    borderBottomWidth: hairline,
    borderBottomColor: colors.rule,
  },
  retour: { ...typography.display, color: colors.accent, includeFontPadding: false },
  identite: { flex: 1 },
  prenom: { ...typography.heading, color: colors.textPrimary },
  statut: { ...typography.caption, color: colors.textMuted },
  chrono: { ...typography.chiffreMoyen, color: colors.accent },

  decompte: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  decompteChiffre: { ...typography.chiffre, color: colors.accent },

  consigne: {
    margin: spacing.gutter,
    marginBottom: 0,
    backgroundColor: colors.accentSoft,
    borderRadius: radius.sm,
    padding: spacing.lg,
  },
  consigneTexte: { ...typography.caption, color: colors.textSecondary },

  corps: { flex: 1 },
  fil: { padding: spacing.gutter, gap: spacing.md },

  bulleRangee: { flexDirection: 'row' },
  bulleRangeeMoi: { justifyContent: 'flex-end' },
  bulle: { maxWidth: '78%', borderRadius: radius.md, padding: spacing.lg, gap: spacing.xs },
  bulleAutre: { backgroundColor: colors.surface, borderTopLeftRadius: radius.sm },
  bulleMoi: { backgroundColor: colors.accent, borderTopRightRadius: radius.sm },
  texte: { ...typography.body, color: colors.textPrimary },
  texteMoi: { color: colors.onAccent },
  heure: { ...typography.caption, color: colors.textMuted, alignSelf: 'flex-end' },
  heureMoi: { color: colors.onAccent, opacity: 0.75 },

  erreur: { ...typography.caption, color: colors.danger, paddingHorizontal: spacing.gutter },

  saisie: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    gap: spacing.md,
    paddingHorizontal: spacing.gutter,
    paddingTop: spacing.md,
    paddingBottom: spacing.lg,
    borderTopWidth: hairline,
    borderTopColor: colors.rule,
  },
  champ: {
    ...typography.body,
    flex: 1,
    maxHeight: 120,
    color: colors.textPrimary,
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
  },
  envoi: {
    width: 44,
    height: 44,
    borderRadius: radius.pill,
    backgroundColor: colors.accent,
    alignItems: 'center',
    justifyContent: 'center',
  },
  envoiInactif: { opacity: 0.35 },
  envoiTexte: { ...typography.heading, color: colors.onAccent },
});
