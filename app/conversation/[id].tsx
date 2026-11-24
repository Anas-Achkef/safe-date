import { router, useLocalSearchParams } from 'expo-router';
import { useCallback, useEffect, useRef, useState } from 'react';
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

import {
  loadConversationState,
  loadMessages,
  markConversationRead,
  sendMessage,
} from '../../src/api/conversations';
import { userFacingMessage } from '../../src/api/errors';
import { Avatar } from '../../src/components/Avatar';
import { StateView } from '../../src/components/StateView';
import { useSession } from '../../src/hooks/useSession';
import { demo, isPreviewMode } from '../../src/preview';
import { colors, hairline, radius, spacing, typography } from '../../src/theme';
import type { EtatConversation, Message } from '../../src/types/conversations';

/**
 * Le fil d'une conversation.
 *
 * Le compte a rebours vient du serveur et n'est jamais recalcule ici : une
 * conversation qui expire le fait pour tout le monde au meme instant.
 */

function heure(iso: string): string {
  const d = new Date(iso);
  return `${d.getHours()}:${String(d.getMinutes()).padStart(2, '0')}`;
}

function delai(secondes: number | null): string | null {
  if (secondes === null) return null;
  if (secondes <= 0) return 'Conversation expirée';
  const h = Math.floor(secondes / 3600);
  if (h >= 24) return `${Math.floor(h / 24)} j restants`;
  if (h >= 1) return `${h} h restantes`;
  return `${Math.max(1, Math.floor(secondes / 60))} min restantes`;
}

export default function Conversation() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { session } = useSession();
  const [etat, setEtat] = useState<EtatConversation | null>(null);
  const [fil, setFil] = useState<Message[]>([]);
  const [brouillon, setBrouillon] = useState('');
  const [chargement, setChargement] = useState(true);
  const [erreur, setErreur] = useState<string | null>(null);
  const defilement = useRef<ScrollView>(null);

  const moi = isPreviewMode ? demo.MOI : (session?.user.id ?? '');

  const charger = useCallback(async () => {
    if (!id) return;
    try {
      const [e, m] = await Promise.all([loadConversationState(id), loadMessages(id)]);
      setEtat(e);
      setFil(m);
      await markConversationRead(id);
    } catch (e) {
      setErreur(userFacingMessage(e));
    } finally {
      setChargement(false);
    }
  }, [id]);

  useEffect(() => {
    void charger();
  }, [charger]);

  const envoyer = useCallback(async () => {
    const corps = brouillon.trim();
    if (!corps || !id) return;
    setBrouillon('');
    try {
      await sendMessage({ conversation_id: id, kind: 'texte', body: corps });
      await charger();
      // Le nouveau message doit etre visible sans geste supplementaire.
      requestAnimationFrame(() => defilement.current?.scrollToEnd({ animated: true }));
    } catch (e) {
      setErreur(userFacingMessage(e));
      setBrouillon(corps);
    }
  }, [brouillon, charger, id]);

  if (chargement) {
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
          message={erreur ?? 'Ce fil n’existe plus.'}
          actionLabel="Retour"
          onAction={() => router.back()}
        />
      </SafeAreaView>
    );
  }

  const restant = delai(etat.secondes_restantes);

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
          <Text style={styles.statut}>
            {etat.autre_en_ligne ? 'En ligne' : (restant ?? 'Hors ligne')}
          </Text>
        </View>
      </View>

      {etat.message ? (
        <View style={styles.consigne}>
          <Text style={styles.consigneTexte}>{etat.message}</Text>
        </View>
      ) : null}

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
        </ScrollView>

        {erreur ? <Text style={styles.erreur}>{erreur}</Text> : null}

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
      </KeyboardAvoidingView>
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
