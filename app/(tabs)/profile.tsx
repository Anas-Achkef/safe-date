import { router } from 'expo-router';
import { useCallback, useEffect, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { userFacingMessage } from '../../src/api/errors';
import { fetchProfileHeader, fetchProfileSections } from '../../src/api/profile';
import { Avatar } from '../../src/components/Avatar';
import { MarqueSafeDate } from '../../src/components/MarqueSafeDate';
import { StateView } from '../../src/components/StateView';
import { useSession } from '../../src/hooks/useSession';
import {
  isPreviewMode,
  PREVIEW_BIO,
  PREVIEW_INTERETS,
  PREVIEW_MES_SECTIONS,
  PREVIEW_MON_PRENOM,
  PREVIEW_PROFILE_HEADER,
} from '../../src/preview';
import { colors, elevation, hairline, radius, spacing, typography } from '../../src/theme';
import type { ProfileHeader, ProfileSection, ScoreGroup } from '../../src/types/rpc';

/**
 * Mon profil, tel que les autres le verraient.
 *
 * C'est une fiche, pas un panneau de réglages : la photo, le prénom et ce que
 * le moteur a retenu passent devant. Les réglages existent toujours, relégués
 * en bas — on y va quand on les cherche.
 */

const TITRES: Record<ScoreGroup, string> = {
  valeurs: 'Ce qui me définit',
  mode_vie: 'Mon mode de vie',
  physique: 'Physique',
};

const ORDRE: ScoreGroup[] = ['valeurs', 'mode_vie', 'physique'];

export default function Profil() {
  const { session, signOut } = useSession();
  const [entete, setEntete] = useState<ProfileHeader | null>(null);
  const [sections, setSections] = useState<ProfileSection[]>([]);
  const [chargement, setChargement] = useState(true);
  const [erreur, setErreur] = useState<string | null>(null);

  const charger = useCallback(async () => {
    if (isPreviewMode) {
      setEntete(PREVIEW_PROFILE_HEADER);
      setSections(PREVIEW_MES_SECTIONS);
      setChargement(false);
      return;
    }
    setChargement(true);
    setErreur(null);
    try {
      const [tete, sect] = await Promise.all([fetchProfileHeader(), fetchProfileSections()]);
      setEntete(tete);
      setSections(sect);
    } catch (e) {
      setErreur(userFacingMessage(e));
    } finally {
      setChargement(false);
    }
  }, []);

  useEffect(() => {
    void charger();
  }, [charger]);

  if (chargement) {
    return (
      <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
        <StateView variant="loading" title="Chargement" />
      </SafeAreaView>
    );
  }

  const prenom = isPreviewMode ? PREVIEW_MON_PRENOM : (session?.user.email?.split('@')[0] ?? '');
  const bio = isPreviewMode ? PREVIEW_BIO : null;
  const interets = isPreviewMode ? PREVIEW_INTERETS : [];
  const connaissance = entete ? Math.round(entete.connaissance) : 0;

  return (
    <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
      <ScrollView contentContainerStyle={styles.contenu} showsVerticalScrollIndicator={false}>
        {/* La fiche commence par le visage, comme celle des autres. */}
        <View style={styles.carteHaute}>
          <Avatar seed={session?.user.id ?? 'moi'} firstName={prenom} style={styles.portrait} rounded="lg" />
          <View style={styles.identite}>
            <Text style={styles.prenom} allowFontScaling={false}>
              {prenom}
              {entete?.age ? <Text style={styles.age}>, {entete.age}</Text> : null}
            </Text>
            <View style={styles.badges}>
              {entete?.profil_verifie ? (
                <View style={styles.badge}>
                  <Text style={styles.badgeTexte}>Profil vérifié</Text>
                </View>
              ) : null}
              <View style={styles.badge}>
                <Text style={styles.badgeTexte}>
                  {entete?.est_premium ? 'Premium' : 'Membre'}
                </Text>
              </View>
            </View>
          </View>
        </View>

        {bio ? <Text style={styles.bio}>{bio}</Text> : null}

        {interets.length > 0 ? (
          <View style={styles.pastilles}>
            {interets.map((i) => (
              <View key={i} style={styles.pastille}>
                <Text style={styles.pastilleTexte}>{i}</Text>
              </View>
            ))}
          </View>
        ) : null}

        {ORDRE.map((groupe) => {
          const lignes = sections.filter((s) => s.section === groupe);
          if (lignes.length === 0) return null;
          return (
            <View key={groupe} style={styles.bloc}>
              <Text style={styles.blocTitre} allowFontScaling={false}>
                {TITRES[groupe].toUpperCase()}
              </Text>
              {lignes.map((l) => (
                <View key={l.pair_key} style={styles.ligne}>
                  <View style={styles.puce} />
                  <Text style={styles.phrase}>{l.phrase}</Text>
                </View>
              ))}
            </View>
          );
        })}

        {/* Le moteur ne sait de moi que ce que j'ai bien voulu lui dire. */}
        <View style={styles.bloc}>
          <View style={styles.jaugeEntete}>
            <Text style={styles.blocTitre} allowFontScaling={false}>
              PROFIL COMPLÉTÉ
            </Text>
            <Text style={styles.jaugeValeur}>{connaissance} %</Text>
          </View>
          <View style={styles.jauge}>
            <View style={[styles.jaugeRemplie, { width: `${Math.min(100, connaissance)}%` }]} />
          </View>
          <Text style={styles.jaugeNote}>
            Plus vous répondez, plus les profils proposés vous ressemblent.
          </Text>
        </View>

        {erreur ? <Text style={styles.erreur}>{erreur}</Text> : null}

        {/* Réglages : présents, jamais au premier plan. */}
        <View style={styles.reglages}>
          <Reglage libelle="Répondre aux questions" onPress={() => router.push('/questionnaire')} />
          <Reglage libelle="Gérer mes photos" onPress={() => router.push('/photos')} />
          <Reglage libelle="Conditions d’activation" onPress={() => router.push('/activation')} />
          <Reglage libelle="Se déconnecter" sobre onPress={() => void signOut()} />
        </View>

        <View style={styles.signature}>
          <MarqueSafeDate taille={22} />
          <Text style={styles.signatureTexte}>Safe Date</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

function Reglage({
  libelle,
  onPress,
  sobre = false,
}: {
  libelle: string;
  onPress: () => void;
  sobre?: boolean;
}) {
  return (
    <Pressable onPress={onPress} style={styles.reglage}>
      <Text style={[styles.reglageTexte, sobre && styles.reglageSobre]}>{libelle}</Text>
      {!sobre ? <Text style={styles.chevron}>›</Text> : null}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  page: { flex: 1, backgroundColor: colors.background },
  contenu: {
    paddingHorizontal: spacing.gutter,
    paddingTop: spacing.md,
    paddingBottom: spacing.giant,
    gap: spacing.xl,
  },

  carteHaute: {
    borderRadius: radius.lg,
    backgroundColor: colors.surface,
    overflow: 'hidden',
    ...elevation.card,
  },
  portrait: { width: '100%', aspectRatio: 4 / 5 },
  identite: { padding: spacing.xl, gap: spacing.md },
  prenom: { ...typography.name, color: colors.textPrimary, includeFontPadding: false },
  age: { ...typography.name, color: colors.textMuted },
  badges: { flexDirection: 'row', gap: spacing.sm, flexWrap: 'wrap' },
  badge: {
    backgroundColor: colors.accentSoft,
    borderRadius: radius.pill,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
  },
  badgeTexte: { ...typography.caption, color: colors.accent },

  bio: { ...typography.body, color: colors.textSecondary },

  pastilles: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },
  pastille: {
    backgroundColor: colors.surfaceAlt,
    borderRadius: radius.pill,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
  },
  pastilleTexte: { ...typography.caption, color: colors.textSecondary },

  bloc: {
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    padding: spacing.xl,
    gap: spacing.md,
  },
  blocTitre: { ...typography.overline, color: colors.textMuted },
  ligne: { flexDirection: 'row', alignItems: 'flex-start', gap: spacing.md },
  puce: {
    width: 6,
    height: 6,
    borderRadius: radius.pill,
    backgroundColor: colors.accent,
    marginTop: 8,
  },
  phrase: { ...typography.body, color: colors.textPrimary, flex: 1 },

  jaugeEntete: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'baseline' },
  jaugeValeur: { ...typography.subscoreValue, color: colors.accent },
  jauge: {
    height: spacing.xs,
    borderRadius: radius.pill,
    backgroundColor: colors.surfaceAlt,
    overflow: 'hidden',
  },
  jaugeRemplie: { height: '100%', borderRadius: radius.pill, backgroundColor: colors.accent },
  jaugeNote: { ...typography.caption, color: colors.textMuted },

  reglages: {
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    paddingHorizontal: spacing.xl,
  },
  reglage: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: spacing.lg,
    borderTopWidth: hairline,
    borderTopColor: colors.rule,
  },
  reglageTexte: { ...typography.body, color: colors.textPrimary },
  reglageSobre: { color: colors.textMuted },
  chevron: { ...typography.body, color: colors.textMuted },

  signature: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.sm,
    paddingTop: spacing.lg,
  },
  signatureTexte: { ...typography.overline, color: colors.textMuted },
  erreur: { ...typography.caption, color: colors.danger },
});
