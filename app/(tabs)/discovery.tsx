import { router } from 'expo-router';
import { useCallback, useEffect, useRef, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { reciprociteAvec } from '../../src/api/decisions';
import { loadSessionState } from '../../src/api/learning';
import CarteSwipe from '../../src/components/CarteSwipe';
import { StateView } from '../../src/components/StateView';
import {
  Badge,
  Bouton,
  BoutonRond,
  CartePhoto,
  IconeCoeur,
  IconeFermer,
  IconePhoto,
  IndicateurPhotos,
  LogoHorizontal,
} from '../../src/components/ui';
import { useDiscovery } from '../../src/hooks/useDiscovery';
import { poser } from '../../src/lib/coupDeCoeur';
import { colors, composants, decor, radius, spacing, typography } from '../../src/theme';
import type { EtatSession } from '../../src/types/learning';

/**
 * Découverte — un profil à la fois. Node Figma 3:350.
 *
 * La carte occupe presque tout l'écran : une photo, le prénom, le lieu, deux
 * badges et une phrase en commun. Toucher la carte ouvre la fiche complète ;
 * le geste horizontal ou les deux boutons décident.
 *
 * « Ça m'intéresse » interroge ensuite la réciprocité. Si la personne s'était
 * déjà prononcée favorablement, l'application montre le coup de cœur — sinon
 * elle enchaîne en silence sur le profil suivant. Tant que la fonction
 * `reciprocite_avec` n'est pas déployée (voir `db/004-reciprocite.sql`), la
 * réponse est toujours « pas de réciprocité » et rien ne change.
 */
export default function Decouverte() {
  const { entries, loading, error, deciding, refresh, decide } = useDiscovery();
  const [session, setSession] = useState<EtatSession | null>(null);

  useEffect(() => {
    let vivant = true;
    // Le quota est un agrément : son absence ne doit pas empêcher de découvrir.
    void loadSessionState()
      .then((e) => {
        if (vivant) setSession(e);
      })
      .catch(() => undefined);
    return () => {
      vivant = false;
    };
  }, [entries.length]);

  /** Instant d'arrivée sur le profil courant, pour mesurer le temps de choix. */
  const vuA = useRef(Date.now());
  const courant = entries[0];

  const trancher = useCallback(
    (interesse: boolean) => {
      if (!courant) return;
      const cible = courant.candidate_id;
      decide(cible, interesse, Date.now() - vuA.current);
      vuA.current = Date.now();

      if (!interesse) return;
      // Le profil vient de quitter le vivier : on le dépose pour que l'écran
      // de coup de cœur puisse encore le nommer.
      poser(courant);

      // L'écran n'attend pas la réponse pour passer au suivant : la question
      // est posée en parallèle, et l'écran de coup de cœur se pose par-dessus
      // s'il y a lieu. Un échec reste muet — ce n'est pas à l'utilisateur de
      // réparer une fonction absente.
      void reciprociteAvec(cible)
        .then((reciproque) => {
          if (reciproque) router.push(`/coup-de-coeur/${cible}`);
        })
        .catch(() => undefined);
    },
    [courant, decide],
  );

  const enTete = (
    <View style={styles.enTete}>
      <LogoHorizontal />
      {session && !session.illimite ? (
        <View style={styles.quota}>
          <IconeCoeur couleur={colors.accent} taille={composants.chip.coche} />
          <Text style={styles.quotaTexte} allowFontScaling={false}>
            {session.profils_vus} sur {session.quota} aujourd’hui
          </Text>
        </View>
      ) : null}
    </View>
  );

  if (loading) {
    return (
      <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
        {enTete}
        <StateView variant="loading" title="Sélection en cours" />
      </SafeAreaView>
    );
  }

  if (error) {
    return (
      <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
        {enTete}
        <StateView
          variant="error"
          title="Chargement impossible"
          message={error}
          actionLabel="Réessayer"
          onAction={refresh}
        />
      </SafeAreaView>
    );
  }

  if (!courant) {
    return (
      <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
        {enTete}
        <StateView
          variant="empty"
          title="C’est tout pour ce soir"
          message="Vous vous êtes prononcé sur toutes les personnes proposées. La sélection est volontairement courte."
          actionLabel="Actualiser"
          onAction={refresh}
        />
      </SafeAreaView>
    );
  }

  // Dans `CandidateHighlight`, `reponse` porte le lien — « En commun »,
  // « Proche » — et `question` la phrase que le moteur a retenue. Les noms de
  // champs disent l'inverse de leur contenu, mais c'est ce que renvoie la vue
  // et ce que la maquette compose : un surtitre court, puis une citation.
  const enCommun = courant.highlights?.[0] ?? null;
  const score = courant.score_global;

  return (
    <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
      {enTete}

      <View style={styles.scene}>
        <CarteSwipe
          cle={courant.candidate_id}
          onOui={() => trancher(true)}
          onNon={() => trancher(false)}
        >
          <Pressable
            accessibilityRole="button"
            accessibilityLabel={`Voir la fiche de ${courant.prenom ?? 'ce profil'}`}
            onPress={() => router.push(`/profil/${courant.candidate_id}`)}
            style={styles.carte}
          >
            <CartePhoto
              photo={courant.photo}
              seed={courant.candidate_id}
              prenom={courant.prenom}
              rapport={null}
              rayon={radius.photo}
              style={styles.photo}
            >
              {courant.photo === null ? (
                <View style={styles.emplacement}>
                  <IconePhoto couleur={colors.onPhoto} taille={composants.boutonRond.icone * 2} />
                </View>
              ) : null}

              {/* `candidate_cards` ne renvoie qu'une photo : l'indicateur ne
                  s'affiche donc pas encore. Il apparaîtra de lui-même le jour
                  où la vue en renverra plusieurs. */}
              <IndicateurPhotos
                nombre={courant.photo === null ? 0 : 1}
                courante={0}
                style={styles.indicateur}
              />

              {score !== null ? (
                <Badge
                  libelle={`${Math.round(score)} % compatibles`}
                  type="compatibilite"
                  style={styles.score}
                />
              ) : null}

              <View style={styles.infos}>
                <Text style={styles.prenom} numberOfLines={1} allowFontScaling={false}>
                  {courant.prenom ?? 'Profil masqué'}
                  {courant.age !== null ? (
                    <Text style={styles.age}>, {courant.age}</Text>
                  ) : null}
                </Text>

                <View style={styles.badges}>
                  {courant.verifie ? <Badge libelle="Profil vérifié" type="verifie" /> : null}
                </View>

                {enCommun ? (
                  <View style={styles.incise}>
                    <Text
                      style={styles.inciseTitre}
                      numberOfLines={1}
                      allowFontScaling={false}
                    >
                      {enCommun.reponse}
                    </Text>
                    <Text style={styles.inciseTexte} numberOfLines={1}>
                      « {enCommun.question} »
                    </Text>
                  </View>
                ) : null}
              </View>
            </CartePhoto>
          </Pressable>
        </CarteSwipe>
      </View>

      {/* Les boutons restent : tout le monde ne fait pas glisser, et sur
          navigateur le geste demande une souris maintenue. */}
      <View style={styles.actions}>
        <BoutonRond
          onPress={() => trancher(false)}
          icone={(couleur) => <IconeFermer couleur={couleur} />}
          libelle="Passer"
          taille="action"
        />
        <Bouton
          libelle="Ça m’intéresse"
          onPress={() => trancher(true)}
          chargement={deciding === courant.candidate_id}
          icone={(couleur) => (
            <IconeCoeur couleur={couleur} taille={composants.boutonRond.icone} />
          )}
          style={styles.interesse}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  page: { flex: 1, backgroundColor: colors.background },

  enTete: {
    height: composants.boutonRond.cote,
    marginHorizontal: spacing.gutter,
    marginTop: spacing.sm,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: spacing.sm,
  },
  quota: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: composants.badge.gap,
    paddingLeft: composants.badge.paddingH,
    paddingRight: composants.badge.paddingH + spacing.demi,
    paddingVertical: spacing.sm,
    borderRadius: radius.pill,
    backgroundColor: colors.surface,
    borderWidth: composants.chip.trait,
    borderColor: colors.rule,
  },
  quotaTexte: { ...typography.label, color: colors.textPrimary },

  scene: {
    flex: 1,
    marginHorizontal: composants.decouverte.marge,
    marginTop: spacing.lg,
  },
  carte: { flex: 1 },
  photo: { flex: 1 },

  emplacement: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    alignItems: 'center',
    justifyContent: 'center',
    pointerEvents: 'none',
  },
  indicateur: {
    position: 'absolute',
    top: spacing.lg - spacing.demi,
    left: composants.decouverte.marge,
    right: composants.decouverte.marge,
  },
  score: {
    position: 'absolute',
    top: spacing.xxxl - spacing.demi,
    right: composants.decouverte.marge,
  },

  infos: {
    position: 'absolute',
    left: spacing.xl,
    right: spacing.xl,
    bottom: spacing.xxl,
    gap: spacing.sm + spacing.demi,
    alignItems: 'flex-start',
  },
  prenom: {
    ...typography.displayXL,
    color: colors.onPhoto,
    includeFontPadding: false,
  },
  age: { color: colors.onPhoto, opacity: 0.7 },
  badges: { flexDirection: 'row', gap: spacing.sm, flexWrap: 'wrap' },

  incise: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
    paddingHorizontal: composants.decouverte.incisePaddingH,
    paddingVertical: composants.decouverte.incisePaddingV,
    borderRadius: composants.decouverte.inciseRayon,
    backgroundColor: decor.voileSurPhoto,
    maxWidth: '100%',
  },
  inciseTitre: { ...typography.label, color: colors.onPhoto, flexShrink: 0 },
  inciseTexte: {
    ...typography.serifIncise,
    color: colors.onPhoto,
    includeFontPadding: false,
    flexShrink: 1,
  },

  actions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
    paddingHorizontal: composants.decouverte.marge,
    paddingTop: spacing.lg,
    paddingBottom: spacing.lg,
  },
  interesse: { flex: 1 },
});
