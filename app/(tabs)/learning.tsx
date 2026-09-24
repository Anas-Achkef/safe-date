import { router } from 'expo-router';
import { useCallback, useEffect, useMemo, useState } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { loadDiscoveryFeed, type DiscoveryEntry } from '../../src/api/discovery';
import { userFacingMessage } from '../../src/api/errors';
import { StateView } from '../../src/components/StateView';
import {
  BoutonRond,
  CarteAffinite,
  Halo,
  IconeFiltres,
  LogoHorizontal,
  VignetteProfil,
} from '../../src/components/ui';
import { useFiltres } from '../../src/hooks/useFiltres';
import { usePremium } from '../../src/hooks/usePremium';
import { filtrerProfils } from '../../src/lib/filtrage';
import { isPreviewMode } from '../../src/preview';
import { attributsDemo } from '../../src/preview/attributs';
import { colors, composants, layout, spacing, typography } from '../../src/theme';
import { compterFiltres, FILTRES_PAR_DEFAUT } from '../../src/types/filtres';

/**
 * Parcourir — la vue d'ensemble. Node Figma 3:81.
 *
 * L'écran est coupé en deux. En haut, un carrousel des meilleures affinités :
 * au-delà du seuil, la photo est floutée et le prénom remplacé par un cadenas
 * — le pourcentage, lui, reste net. C'est le score qui donne envie, pas la
 * personne qu'on ne voit pas encore. En bas, la grille de proximité, où tout
 * est visible et où l'on parcourt librement.
 *
 * Le filtrage par rayon et par âge est fait en base : `candidate_cards` ne
 * renvoie que des profils satisfaisant les filtres absolus.
 */
export default function Parcourir() {
  const [profils, setProfils] = useState<DiscoveryEntry[]>([]);
  const [chargement, setChargement] = useState(true);
  const [erreur, setErreur] = useState<string | null>(null);
  // Les filtres appartiennent au compte, pas à l'écran : le crochet les relit
  // à chaque prise de focus, donc au retour du panneau.
  const { filtres, enregistrer: enregistrerFiltres } = useFiltres();
  const { premium: abonne } = usePremium();

  const charger = useCallback(async () => {
    setChargement(true);
    setErreur(null);
    try {
      setProfils(await loadDiscoveryFeed());
    } catch (e) {
      setErreur(userFacingMessage(e));
    } finally {
      setChargement(false);
    }
  }, []);

  useEffect(() => {
    void charger();
  }, [charger]);

  // Les attributs fins n'existent que dans le jeu de démonstration : en
  // conditions réelles le lecteur est absent et seuls âge, vérification et
  // score sont filtrés. Un critère non évaluable ne rejette jamais.
  const lecteur = isPreviewMode ? attributsDemo : undefined;

  const retenus = useMemo(
    () => filtrerProfils(profils, filtres, lecteur),
    [profils, filtres, lecteur],
  );

  // Le carrousel montre les profils **au-dessus du seuil** — ceux dont le
  // back-end masque l'identité tant que l'abonnement n'est pas pris — et la
  // grille tout le reste. Ce n'est pas un classement par score : « au-dessus
  // de votre seuil » est une propriété du profil, que `candidate_cards`
  // renvoie, et le surtitre la reprend telle quelle.
  const { affinites, proximite } = useMemo(
    () => ({
      affinites: retenus
        .filter((x) => !x.visible)
        .sort((a, b) => (b.score_global ?? 0) - (a.score_global ?? 0)),
      proximite: retenus.filter((x) => x.visible),
    }),
    [retenus],
  );

  const nbFiltres = compterFiltres(filtres);

  const boutonFiltres = (
    <BoutonRond
      onPress={() => router.push('/filtres')}
      icone={(couleur) => <IconeFiltres couleur={couleur} />}
      libelle="Filtres"
      compte={nbFiltres}
    />
  );

  const enTete = (
    <View style={styles.enTete}>
      <LogoHorizontal />
      {boutonFiltres}
    </View>
  );

  if (chargement) {
    return (
      <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
        <Halo />
        <View style={styles.marge}>{enTete}</View>
        <StateView variant="loading" title="Recherche autour de vous" />
      </SafeAreaView>
    );
  }

  if (erreur || profils.length === 0) {
    return (
      <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
        <Halo />
        <View style={styles.marge}>{enTete}</View>
        <StateView
          variant={erreur ? 'error' : 'empty'}
          title={erreur ? 'Chargement impossible' : 'Personne dans votre rayon'}
          message={erreur ?? 'Élargissez votre zone de recherche ou revenez plus tard.'}
          actionLabel="Actualiser"
          onAction={() => void charger()}
        />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.page} edges={['top', 'left', 'right']}>
      <Halo />

      <ScrollView
        contentContainerStyle={styles.contenu}
        showsVerticalScrollIndicator={false}
        // Le carrousel déborde à droite : le remplissage vit sur les blocs,
        // jamais sur le conteneur, sinon les cartes seraient coupées.
      >
        <View style={styles.marge}>{enTete}</View>

        {affinites.length > 0 ? (
          <View style={[styles.marge, styles.titre]}>
            <Text style={styles.surtitre} allowFontScaling={false}>
              {affinites.length} profil{affinites.length > 1 ? 's' : ''} au-dessus de votre seuil
            </Text>
            <Text style={styles.titreTexte} allowFontScaling={false}>
              Vos plus belles
            </Text>
            <Text style={styles.titreAccent} allowFontScaling={false}>
              affinités
            </Text>
          </View>
        ) : null}

        {retenus.length === 0 ? (
          <View style={[styles.marge, styles.aucun]}>
            <Text style={styles.aucunTitre}>Aucun profil ne passe vos filtres</Text>
            <Text style={styles.aucunTexte}>
              {profils.length} personne{profils.length > 1 ? 's' : ''} autour de vous, écartée
              {profils.length > 1 ? 's' : ''} par vos critères.
            </Text>
            <Text
              style={styles.aucunLien}
              onPress={() => enregistrerFiltres(FILTRES_PAR_DEFAUT)}
              allowFontScaling={false}
            >
              Effacer les filtres
            </Text>
          </View>
        ) : null}

        {affinites.length > 0 ? (
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.carrousel}
          >
            {affinites.map((p) => (
              <CarteAffinite
                key={p.candidate_id}
                prenom={p.prenom}
                age={p.age}
                photo={p.photo}
                seed={p.candidate_id}
                score={p.score_global}
                verrouille={!abonne}
                onPress={() =>
                  router.push(abonne ? `/profil/${p.candidate_id}` : '/premium')
                }
              />
            ))}
          </ScrollView>
        ) : null}

        <View style={[styles.marge, styles.sectionProximite]}>
          <Text style={styles.sectionTitre} allowFontScaling={false}>
            Près de chez vous
          </Text>
          <Text style={styles.sectionCompte} allowFontScaling={false}>
            {proximite.length} à moins de {filtres.rayonKm} km
          </Text>
        </View>

        <View style={[styles.marge, styles.grille]}>
          {proximite.map((p) => (
            <VignetteProfil
              key={p.candidate_id}
              prenom={p.prenom}
              age={p.age}
              photo={p.photo}
              seed={p.candidate_id}
              score={p.score_global}
              verifie={p.verifie}
              onPress={() => router.push(`/profil/${p.candidate_id}`)}
            />
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  page: { flex: 1, backgroundColor: colors.background },
  marge: { paddingHorizontal: spacing.gutter },
  contenu: {
    paddingTop: spacing.sm,
    // La barre d'onglets est translucide et posée par-dessus : sans cette
    // réserve, la dernière rangée de la grille passe dessous.
    paddingBottom: layout.tabBarHeight + spacing.xxl,
    gap: spacing.xxl,
  },

  enTete: {
    height: composants.boutonRond.cote,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },

  titre: { gap: spacing.sm },
  surtitre: { ...typography.overline, color: colors.accent },
  titreTexte: {
    ...typography.h1,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
  // Le mot d'émotion passe au serif italique corail. Il est posé sur la même
  // interligne que la ligne au-dessus, sans quoi les deux se décolleraient.
  titreAccent: {
    ...typography.serifTitre,
    color: colors.accent,
    includeFontPadding: false,
  },

  carrousel: {
    flexDirection: 'row',
    gap: spacing.md,
    paddingHorizontal: spacing.gutter,
  },

  sectionProximite: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: spacing.sm,
  },
  sectionTitre: {
    ...typography.h2,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
  sectionCompte: { ...typography.label, color: colors.textSecondary },

  grille: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    columnGap: composants.parcourir.grilleGapX,
    rowGap: composants.parcourir.grilleGapY,
  },

  aucun: { gap: spacing.xs },
  aucunTitre: { ...typography.bodyFort, color: colors.textPrimary },
  aucunTexte: { ...typography.caption, color: colors.textSecondary },
  aucunLien: { ...typography.label, color: colors.accent, marginTop: spacing.sm },
});
