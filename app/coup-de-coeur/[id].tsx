import { LinearGradient } from 'expo-linear-gradient';
import { router, useLocalSearchParams } from 'expo-router';
import { useCallback, useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { createRequest } from '../../src/api/conversations';
import { loadDiscoveryFeed, type DiscoveryEntry } from '../../src/api/discovery';
import { userFacingMessage } from '../../src/api/errors';
import { fetchMyPhotos } from '../../src/api/photos';
import { Avatar } from '../../src/components/Avatar';
import { Bouton, IconeCoeurPlein, LueurImmersive } from '../../src/components/ui';
import { useSession } from '../../src/hooks/useSession';
import { reprendre } from '../../src/lib/coupDeCoeur';
import {
  colors,
  composants,
  decor,
  degradeImmersif,
  marque,
  opacity,
  radius,
  spacing,
  typography,
} from '../../src/theme';

/**
 * Coup de cœur réciproque — node Figma 10:632.
 *
 * Le seul écran immersif du parcours de découverte, et le seul à porter un
 * cœur plein. Il n'apparaît que lorsque les deux personnes se sont prononcées
 * favorablement l'une sur l'autre : le réserver strictement à ce moment est
 * ce qui lui donne sa valeur.
 *
 * Deux issues, et l'ordre compte : la demande d'abord, en bouton plein, parce
 * que c'est ce que l'écran propose ; continuer à découvrir ensuite, en lien,
 * parce que c'est ce que l'on fait quand on ne saisit pas l'occasion.
 */
export default function CoupDeCoeur() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { session } = useSession();
  // Le profil déposé par Découverte est déjà là : l'écran s'affiche complet
  // dès la première image, sans attendre le réseau.
  const [profil, setProfil] = useState<DiscoveryEntry | null>(() =>
    id ? reprendre(id) : null,
  );
  const [maPhoto, setMaPhoto] = useState<string | null>(null);
  const [envoi, setEnvoi] = useState(false);
  const [erreur, setErreur] = useState<string | null>(null);

  useEffect(() => {
    let vivant = true;
    // Filet pour les entrées directes — lien partagé, rechargement de page.
    // Le profil vient d'être tranché, il a donc pu quitter le vivier : on ne
    // remplace jamais une entrée déjà déposée par un résultat vide.
    if (!profil) {
      void loadDiscoveryFeed()
        .then((tous) => {
          const trouve = tous.find((p) => p.candidate_id === id) ?? null;
          if (vivant && trouve) setProfil(trouve);
        })
        .catch(() => undefined);
    }
    void fetchMyPhotos()
      .then((photos) => {
        if (vivant) setMaPhoto(photos.find((p) => p.isPrimary)?.url ?? photos[0]?.url ?? null);
      })
      .catch(() => undefined);
    return () => {
      vivant = false;
    };
  }, [id, profil]);

  const demander = useCallback(async () => {
    if (!id) return;
    setEnvoi(true);
    try {
      await createRequest(id);
      router.replace('/(tabs)/conversations');
    } catch (e) {
      setErreur(userFacingMessage(e));
      setEnvoi(false);
    }
  }, [id]);

  const prenom = profil?.prenom ?? null;
  const score = profil?.score_global ?? null;
  const enCommun = profil?.highlights?.[0]?.question ?? null;

  // Le message se construit de ce qui est réellement connu. Rien n'est
  // inventé : sans score ni point commun, il reste juste et plus court.
  const phrase = [
    `${prenom ?? 'Cette personne'} et vous vous êtes choisis.`,
    score !== null ? `${Math.round(score)} % d’affinité.` : null,
    enCommun ? `Et en commun : « ${enCommun} ».` : null,
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <LinearGradient
      colors={[...degradeImmersif.colors]}
      locations={[...degradeImmersif.locations]}
      start={degradeImmersif.start}
      end={degradeImmersif.end}
      style={styles.fond}
    >
      <LueurImmersive />

      <SafeAreaView style={styles.page} edges={['top', 'left', 'right', 'bottom']}>
        <View style={styles.haut}>
          <View style={styles.scene}>
          <View style={styles.portraits}>
            <View style={[styles.portrait, styles.portraitGauche]}>
              <Avatar
                seed={session?.user.id ?? 'moi'}
                firstName={null}
                photo={maPhoto}
                rounded="pill"
                style={styles.visuel}
              />
            </View>
            <View style={[styles.portrait, styles.portraitDroite]}>
              <Avatar
                seed={id ?? 'autre'}
                firstName={prenom}
                photo={profil?.photo ?? null}
                rounded="pill"
                style={styles.visuel}
              />
            </View>
          </View>

            <View style={styles.pastille}>
              <IconeCoeurPlein couleur={marque.corail} />
            </View>
          </View>

          <View style={styles.message}>
          <Text style={styles.surtitre} allowFontScaling={false}>
            Coup de cœur
          </Text>
          <Text style={styles.titre} allowFontScaling={false}>
            C’est <Text style={styles.titreAccent}>réciproque</Text>
          </Text>
            <Text style={styles.texte}>{phrase}</Text>
            {erreur ? <Text style={styles.erreur}>{erreur}</Text> : null}
          </View>
        </View>

        <View style={styles.actions}>
          <Bouton
            libelle="Envoyer une demande"
            onPress={() => void demander()}
            variante="secondaire"
            chargement={envoi}
            style={styles.demande}
          />
          <Pressable
            accessibilityRole="button"
            onPress={() => router.back()}
            hitSlop={spacing.md}
            style={({ pressed }) => [pressed && styles.presse]}
          >
            <Text style={styles.continuer} allowFontScaling={false}>
              Continuer à découvrir
            </Text>
          </Pressable>
        </View>
      </SafeAreaView>
    </LinearGradient>
  );
}

/** Recouvrement des deux portraits, exprimé en marge négative. */
const CHEVAUCHEMENT = -composants.coupDeCoeur.chevauchement;

const styles = StyleSheet.create({
  fond: { flex: 1 },
  page: { flex: 1, paddingHorizontal: spacing.gutter },
  // Les portraits et le message occupent tout l'espace libre et s'y centrent ;
  // les deux issues restent posées en bas, là où se prend la décision.
  haut: { flex: 1, justifyContent: 'center' },

  scene: { alignItems: 'center' },
  portraits: { flexDirection: 'row', alignItems: 'center' },
  portrait: {
    width: composants.coupDeCoeur.portrait,
    height: composants.coupDeCoeur.portrait,
    borderRadius: radius.pill,
    borderWidth: composants.coupDeCoeur.contour,
    borderColor: colors.onPhoto,
    overflow: 'hidden',
    backgroundColor: colors.surfaceAlt,
    boxShadow: decor.ombrePortrait,
  },
  // Les deux portraits se penchent l'un vers l'autre : c'est ce mouvement,
  // plus que le cœur, qui dit la rencontre.
  portraitGauche: { transform: [{ rotate: `-${composants.coupDeCoeur.inclinaison}deg` }] },
  portraitDroite: {
    transform: [{ rotate: `${composants.coupDeCoeur.inclinaison}deg` }],
    marginLeft: CHEVAUCHEMENT,
  },
  visuel: { width: '100%', height: '100%' },

  pastille: {
    width: composants.coupDeCoeur.pastille,
    height: composants.coupDeCoeur.pastille,
    borderRadius: radius.pill,
    backgroundColor: colors.surface,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: -composants.coupDeCoeur.pastille / 2,
    boxShadow: decor.ombreCoeur,
  },

  message: {
    alignItems: 'center',
    gap: spacing.md,
    marginTop: spacing.giant,
  },
  surtitre: { ...typography.overline, color: colors.onPhoto, opacity: 0.85 },
  titre: {
    ...typography.chiffreEcran,
    color: colors.onPhoto,
    textAlign: 'center',
    includeFontPadding: false,
  },
  titreAccent: { ...typography.serifEcran, color: colors.onPhoto },
  texte: {
    ...typography.body,
    color: colors.onPhoto,
    opacity: 0.88,
    textAlign: 'center',
  },
  erreur: { ...typography.caption, color: colors.onPhoto },

  actions: { paddingBottom: spacing.xxl, gap: spacing.xl, alignItems: 'center' },
  demande: { alignSelf: 'stretch' },
  continuer: { ...typography.bouton, color: colors.onPhoto, opacity: 0.85 },
  presse: { opacity: opacity.pressed },
});
