import { LinearGradient } from 'expo-linear-gradient';
import { router, useLocalSearchParams } from 'expo-router';
import { useCallback, useEffect, useState } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { createRequest } from '../../src/api/conversations';
import { loadDiscoveryFeed, type DiscoveryEntry } from '../../src/api/discovery';
import { userFacingMessage } from '../../src/api/errors';
import { StateView } from '../../src/components/StateView';
import {
  Badge,
  Bouton,
  BoutonRond,
  CarteDimension,
  CarteEnCommun,
  CartePhoto,
  IconeFermer,
  IconePhoto,
  IconeRetour,
  IndicateurPhotos,
} from '../../src/components/ui';
import { colors, composants, decor, spacing, typography } from '../../src/theme';

/**
 * La fiche d'un profil — node Figma 9:605.
 *
 * Une photo pleine largeur qui porte l'identité, puis le détail au fil du
 * défilement : les trois dimensions d'affinité, ce qui rapproche, et enfin
 * l'affinité croisée — deux nombres qui disent que l'accord n'est jamais
 * symétrique.
 *
 * Aucun champ n'est supposé présent. Au-delà du seuil premium le back-end
 * renvoie prénom, photo et scores à `null` : la fiche le dit, et n'affiche
 * jamais de zéro à la place d'une mesure absente.
 */
export default function FicheProfil() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const marges = useSafeAreaInsets();
  const [profil, setProfil] = useState<DiscoveryEntry | null>(null);
  const [chargement, setChargement] = useState(true);
  const [erreur, setErreur] = useState<string | null>(null);
  const [envoyee, setEnvoyee] = useState(false);
  const [envoi, setEnvoi] = useState(false);

  const charger = useCallback(async () => {
    try {
      const tous = await loadDiscoveryFeed();
      setProfil(tous.find((p) => p.candidate_id === id) ?? null);
    } catch (e) {
      setErreur(userFacingMessage(e));
    } finally {
      setChargement(false);
    }
  }, [id]);

  useEffect(() => {
    void charger();
  }, [charger]);

  const demander = useCallback(async () => {
    if (!profil) return;
    setEnvoi(true);
    try {
      await createRequest(profil.candidate_id);
      setEnvoyee(true);
    } catch (e) {
      setErreur(userFacingMessage(e));
    } finally {
      setEnvoi(false);
    }
  }, [profil]);

  if (chargement) {
    return (
      <View style={styles.page}>
        <StateView variant="loading" title="Chargement" />
      </View>
    );
  }

  if (!profil) {
    return (
      <View style={styles.page}>
        <StateView
          variant="error"
          title="Profil introuvable"
          message={erreur ?? 'Ce profil ne vous est plus proposé.'}
          actionLabel="Retour"
          onAction={() => router.back()}
        />
      </View>
    );
  }

  const score = profil.score_global;
  // `reponse` porte le lien — « En commun », « Proche » — et `question` la
  // phrase retenue par le moteur. Les noms de champs disent l'inverse de leur
  // contenu ; c'est la vue qui en décide, et la maquette suit ce contenu.
  const communs = profil.highlights ?? [];

  return (
    <View style={styles.page}>
      <ScrollView
        contentContainerStyle={[styles.contenu, { paddingBottom: HAUTEUR_BARRE + marges.bottom }]}
        showsVerticalScrollIndicator={false}
      >
        <CartePhoto
          photo={profil.photo}
          seed={profil.candidate_id}
          prenom={profil.prenom}
          hauteur={composants.fiche.photoHauteur}
          rayon={null}
          style={styles.portrait}
        >
          {profil.photo === null ? (
            <View style={styles.emplacement}>
              <IconePhoto couleur={colors.onPhoto} taille={composants.boutonRond.icone * 2} />
            </View>
          ) : null}

          <IndicateurPhotos
            nombre={profil.photo === null ? 0 : 1}
            courante={0}
            style={[styles.indicateur, { top: marges.top + composants.boutonRond.cote }]}
          />

          {/* Les commandes se posent sur la photo et défilent avec elle : une
              barre fixe en haut couperait le portrait en deux. */}
          <View style={[styles.retour, { top: marges.top + spacing.sm }]}>
            <BoutonRond
              onPress={() => router.back()}
              icone={(couleur) => <IconeRetour couleur={couleur} />}
              libelle="Retour"
            />
          </View>

          {score !== null ? (
            <View style={[styles.scorePose, { top: marges.top + spacing.md }]}>
              <Badge libelle={`${Math.round(score)} % compatibles`} type="compatibilite" />
            </View>
          ) : null}

          <View style={styles.identite}>
            <Text style={styles.prenom} numberOfLines={1} allowFontScaling={false}>
              {profil.prenom ?? 'Profil masqué'}
              {profil.age !== null ? <Text style={styles.age}>, {profil.age}</Text> : null}
            </Text>
            {profil.verifie ? (
              <View style={styles.badges}>
                <Badge libelle="Profil vérifié" type="verifie" />
              </View>
            ) : null}
          </View>
        </CartePhoto>

        {profil.visible ? (
          <View style={styles.corps}>
            <Text style={styles.section} allowFontScaling={false}>
              Vos affinités
            </Text>
            <View style={styles.dimensions}>
              <CarteDimension valeur={profil.score_valeurs} libelle="Valeurs" />
              <CarteDimension valeur={profil.score_mode_vie} libelle="Mode de vie" />
              <CarteDimension valeur={profil.score_physique} libelle="Physique" />
            </View>

            {communs.length > 0 ? (
              <>
                <Text style={styles.section} allowFontScaling={false}>
                  Ce qui vous rapproche
                </Text>
                {communs.map((item, i) => (
                  <CarteEnCommun
                    key={`${item.question}-${i}`}
                    surtitre={item.reponse}
                    texte={item.question}
                  />
                ))}
              </>
            ) : null}

            {profil.score_aller !== null && profil.score_retour !== null ? (
              <Text style={styles.croisee}>
                Affinité croisée : {Math.round(profil.score_aller)} % vers{' '}
                {profil.prenom ?? 'l’autre'} · {Math.round(profil.score_retour)} % vers vous
              </Text>
            ) : null}
          </View>
        ) : (
          <View style={styles.corps}>
            <CarteEnCommun
              surtitre="Réservé aux membres"
              texte="Ce profil fait partie de vos meilleures compatibilités. Son détail se dévoile avec l’abonnement."
              forme="reponse"
            />
          </View>
        )}

        {erreur ? <Text style={styles.erreur}>{erreur}</Text> : null}
      </ScrollView>

      <LinearGradient
        colors={[decor.fondTransparent, colors.background, colors.background]}
        locations={[0, 0.35, 1]}
        style={[styles.barre, { paddingBottom: marges.bottom + spacing.lg }]}
      >
        <BoutonRond
          onPress={() => router.back()}
          icone={(couleur) => <IconeFermer couleur={couleur} />}
          libelle="Passer"
          taille="action"
        />
        <Bouton
          libelle={envoyee ? 'Demande envoyée' : 'Envoyer une demande'}
          onPress={() => void demander()}
          chargement={envoi}
          desactive={envoyee}
          pleineLargeur={false}
          style={styles.demande}
        />
      </LinearGradient>
    </View>
  );
}

/** Hauteur de la barre d'actions, réservée en bas du défilement. */
const HAUTEUR_BARRE = composants.bouton.hauteur + spacing.xxl + spacing.giant;

const styles = StyleSheet.create({
  page: { flex: 1, backgroundColor: colors.background },
  contenu: { gap: spacing.lg },

  // Seuls les coins bas sont arrondis : la photo monte jusqu'au bord haut de
  // l'écran, sous la barre d'état du téléphone.
  portrait: {
    borderBottomLeftRadius: composants.fiche.photoRayon,
    borderBottomRightRadius: composants.fiche.photoRayon,
  },
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
    left: composants.fiche.photoRayon * 2,
    right: composants.fiche.photoRayon * 2,
  },
  identite: {
    position: 'absolute',
    left: spacing.gutter,
    right: spacing.gutter,
    bottom: spacing.giant,
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

  retour: { position: 'absolute', left: composants.decouverte.marge },
  scorePose: { position: 'absolute', right: composants.decouverte.marge },

  corps: {
    paddingHorizontal: composants.decouverte.marge,
    gap: spacing.lg,
  },
  section: {
    ...typography.h2,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
  dimensions: { flexDirection: 'row', gap: composants.parcourir.grilleGapX },
  croisee: { ...typography.caption, color: colors.textMuted, textAlign: 'center' },
  erreur: {
    ...typography.caption,
    color: colors.danger,
    paddingHorizontal: composants.decouverte.marge,
  },

  // La barre flotte au-dessus du contenu, adossée à un fondu vers le fond :
  // sans lui, le texte qui passe dessous viendrait buter contre les boutons.
  barre: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    paddingTop: spacing.xxl,
    paddingHorizontal: composants.decouverte.marge,
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
  },
  demande: { flex: 1 },
});
