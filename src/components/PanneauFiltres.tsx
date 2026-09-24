import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import {
  Bouton,
  BoutonRond,
  Chip,
  Curseur,
  CurseurFourchette,
  IconeFermer,
  IconePremium,
  IconeVerifie,
  Interrupteur,
} from './ui';
import {
  colors,
  composants,
  elevation,
  etats,
  hairline,
  marque,
  opacity,
  radius,
  spacing,
  typography,
} from '../theme';
import {
  compterFiltres,
  FILTRES_PAR_DEFAUT,
  LIBELLE_ENFANTS,
  LIBELLE_FREQUENCE,
  LIBELLE_GENRE,
  LIBELLE_INTENTION,
  type Enfants,
  type Filtres,
  type Frequence,
  type Genre,
  type Intention,
} from '../types/filtres';

interface Props {
  /** Les filtres réellement appliqués, point de départ de la copie de travail. */
  valeur: Filtres;
  /** Fonction de comptage : combien de profils donnerait ce réglage. */
  compter: (f: Filtres) => number;
  /** Ouvre les filtres avancés. Faux tant que l'abonnement n'est pas pris. */
  premium: boolean;
  /** Valide : enregistre le réglage et referme. */
  onValider: (f: Filtres) => void;
  /** Annule : referme sans rien changer. */
  onFermer: () => void;
  onPremium: () => void;
}

/**
 * Le panneau de filtres — node Figma 11:666.
 *
 * Les critères de base restent gratuits — genre, âge, distance, vérification —
 * et les critères de style de vie sont réservés à l'abonnement, comme le font
 * les applications qui les proposent. L'intention échappe à cette règle : dire
 * ce qu'on cherche n'est pas un confort, c'est ce qui évite les malentendus.
 *
 * Le bouton du bas annonce le nombre de résultats avant de valider : on doit
 * pouvoir voir qu'on a trop filtré sans avoir à fermer le panneau. Le compte
 * est recalculé à chaque frappe sur la copie de travail, jamais sur les
 * filtres appliqués — c'est ce que le réglage *donnerait*, pas ce qu'il donne.
 *
 * Le composant ne connaît pas la navigation : il est monté par la route
 * `app/filtres.tsx`, qui le présente en modale par-dessus la barre d'onglets.
 */
export function PanneauFiltres({
  valeur,
  compter,
  premium,
  onValider,
  onFermer,
  onPremium,
}: Props) {
  // Le panneau travaille sur une copie : fermer sans valider ne doit rien
  // changer. La route le monte à l'ouverture et le démonte à la fermeture, il
  // n'y a donc qu'une seule mise en place — la copie part des filtres
  // réellement appliqués et suit ensuite ses propres modifications.
  const [f, setF] = useState<Filtres>(valeur);
  const resultats = compter(f);

  const maj = (partiel: Partial<Filtres>) => setF((p) => ({ ...p, ...partiel }));

  const bascule = <T,>(liste: T[], item: T): T[] =>
    liste.includes(item) ? liste.filter((x) => x !== item) : [...liste, item];

  return (
    <View style={styles.panneau}>
      <View style={styles.enTete}>
        <Text style={styles.titre} allowFontScaling={false}>
          Filtres
        </Text>
        <BoutonRond
          onPress={onFermer}
          icone={(couleur) => <IconeFermer couleur={couleur} />}
          libelle="Fermer les filtres"
        />
      </View>

      <ScrollView contentContainerStyle={styles.contenu} showsVerticalScrollIndicator={false}>
        <Section titre="Je recherche">
          <Puces
            options={Object.keys(LIBELLE_INTENTION) as Intention[]}
            libelle={(i) => LIBELLE_INTENTION[i]}
            actifs={f.intentions}
            onBascule={(i) => maj({ intentions: bascule(f.intentions, i) })}
          />
          <Text style={styles.aide}>
            Plusieurs réponses possibles. C’est ce qui évite les malentendus.
          </Text>
        </Section>

        <Section titre="Qui me montrer">
          <Puces
            options={Object.keys(LIBELLE_GENRE) as Genre[]}
            libelle={(g) => LIBELLE_GENRE[g]}
            actifs={f.genres}
            onBascule={(g) => maj({ genres: bascule(f.genres, g) })}
          />
          <Text style={styles.aide}>Aucun choix : tout le monde.</Text>
        </Section>

        <Section titre="Âge">
          <CurseurFourchette
            min={f.ageMin}
            max={f.ageMax}
            bas={18}
            haut={80}
            pas={1}
            resume={`${f.ageMin} – ${f.ageMax} ans`}
            legendeBas="18 ans"
            legendeHaut="80 ans"
            libelle="Âge recherché"
            onChange={(ageMin, ageMax) => maj({ ageMin, ageMax })}
          />
        </Section>

        <Section titre="Compatibilité minimale">
          <Curseur
            valeur={f.scoreMin}
            bas={0}
            haut={90}
            pas={5}
            resume={f.scoreMin === 0 ? 'Indifférent' : `${f.scoreMin} % et plus`}
            legendeBas="Indifférent"
            legendeHaut="90 %"
            libelle="Compatibilité minimale"
            onChange={(scoreMin) => maj({ scoreMin })}
          />
          <Text style={styles.aide}>
            Le score médian tourne autour de 50 %. Au-delà de 70 %, la liste se vide vite.
          </Text>
        </Section>

        <Section titre="Distance">
          <Curseur
            valeur={f.rayonKm}
            bas={1}
            haut={100}
            pas={1}
            resume={`Jusqu’à ${f.rayonKm} km`}
            legendeBas="1 km"
            legendeHaut="100 km"
            libelle="Distance maximale"
            onChange={(rayonKm) => maj({ rayonKm })}
          />
        </Section>

        <View style={styles.carte}>
          <IconeVerifie couleur={etats.securite} taille={composants.boutonRond.icone} />
          <View style={styles.carteTexte}>
            <Text style={styles.carteTitre} allowFontScaling={false}>
              Profils vérifiés uniquement
            </Text>
            <Text style={styles.carteAide}>
              Identité confirmée par vérification biométrique
            </Text>
          </View>
          <Interrupteur
            actif={f.verifiesSeulement}
            onBascule={() => maj({ verifiesSeulement: !f.verifiesSeulement })}
            libelle="Profils vérifiés uniquement"
          />
        </View>

        <View style={styles.avances}>
          <View style={styles.avancesEnTete}>
            <Text style={styles.avancesTitre} allowFontScaling={false}>
              Filtres avancés
            </Text>
            <View style={styles.badgePremium}>
              <IconePremium couleur={marque.poudre} />
              <Text style={styles.badgePremiumTexte} allowFontScaling={false}>
                Premium
              </Text>
            </View>
          </View>

          {premium ? (
            <>
              <Section titre="Taille">
                <CurseurFourchette
                  min={f.tailleMin}
                  max={f.tailleMax}
                  bas={140}
                  haut={210}
                  pas={1}
                  resume={`${f.tailleMin} – ${f.tailleMax} cm`}
                  legendeBas="140 cm"
                  legendeHaut="210 cm"
                  libelle="Taille recherchée"
                  onChange={(tailleMin, tailleMax) => maj({ tailleMin, tailleMax })}
                />
              </Section>

              <Section titre="Tabac">
                <Puces
                  options={Object.keys(LIBELLE_FREQUENCE) as Frequence[]}
                  libelle={(x) => LIBELLE_FREQUENCE[x]}
                  actifs={f.tabac}
                  onBascule={(x) => maj({ tabac: bascule(f.tabac, x) })}
                />
              </Section>

              <Section titre="Alcool">
                <Puces
                  options={Object.keys(LIBELLE_FREQUENCE) as Frequence[]}
                  libelle={(x) => LIBELLE_FREQUENCE[x]}
                  actifs={f.alcool}
                  onBascule={(x) => maj({ alcool: bascule(f.alcool, x) })}
                />
              </Section>

              <Section titre="Enfants">
                <Puces
                  options={Object.keys(LIBELLE_ENFANTS) as Enfants[]}
                  libelle={(x) => LIBELLE_ENFANTS[x]}
                  actifs={f.enfants}
                  onBascule={(x) => maj({ enfants: bascule(f.enfants, x) })}
                />
              </Section>
            </>
          ) : (
            <Pressable
              accessibilityRole="button"
              onPress={onPremium}
              style={({ pressed }) => [styles.carte, styles.verrou, pressed && styles.presse]}
            >
              <View style={styles.carteTexte}>
                <Text style={styles.carteTitre} allowFontScaling={false}>
                  Taille, tabac, alcool, enfants
                </Text>
                <Text style={styles.carteAide}>
                  Affinez sur le mode de vie et ne voyez que des profils qui vous vont.
                </Text>
                <Text style={styles.verrouLien} allowFontScaling={false}>
                  Passer à Premium →
                </Text>
              </View>
            </Pressable>
          )}
        </View>
      </ScrollView>

      <View style={styles.actions}>
        <Pressable
          accessibilityRole="button"
          onPress={() => setF(FILTRES_PAR_DEFAUT)}
          disabled={compterFiltres(f) === 0}
          hitSlop={spacing.md}
          style={({ pressed }) => [pressed && styles.presse]}
        >
          <Text
            style={[styles.reinitialiser, compterFiltres(f) === 0 && styles.eteint]}
            allowFontScaling={false}
          >
            Réinitialiser
          </Text>
        </Pressable>
        <Bouton
          libelle={
            resultats === 0
              ? 'Aucun profil — élargissez'
              : `Voir ${resultats} profil${resultats > 1 ? 's' : ''}`
          }
          onPress={() => onValider(f)}
          style={styles.validerLargeur}
        />
      </View>
    </View>
  );
}

function Section({ titre, children }: { titre: string; children: React.ReactNode }) {
  return (
    <View style={styles.section}>
      <Text style={styles.sectionTitre} allowFontScaling={false}>
        {titre}
      </Text>
      {children}
    </View>
  );
}

function Puces<T extends string>({
  options,
  libelle,
  actifs,
  onBascule,
}: {
  options: T[];
  libelle: (x: T) => string;
  actifs: T[];
  onBascule: (x: T) => void;
}) {
  return (
    <View style={styles.puces}>
      {options.map((o) => (
        <Chip
          key={o}
          libelle={libelle(o)}
          selectionne={actifs.includes(o)}
          onPress={() => onBascule(o)}
        />
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  panneau: { flex: 1, backgroundColor: colors.background },

  enTete: {
    height: composants.boutonRond.cote,
    marginTop: spacing.sm,
    marginHorizontal: spacing.gutter,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  titre: { ...typography.h1, color: colors.textPrimary, includeFontPadding: false },

  contenu: {
    paddingHorizontal: spacing.gutter,
    paddingTop: spacing.xxl,
    paddingBottom: spacing.xxl,
    gap: spacing.xxxl - spacing.xs,
  },

  section: { gap: spacing.md },
  sectionTitre: { ...typography.overline, color: colors.textMuted },
  aide: { ...typography.caption, color: colors.textSecondary },
  puces: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },

  carte: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
    padding: spacing.lg,
    borderRadius: radius.md,
    backgroundColor: colors.surface,
    ...elevation.card,
  },
  carteTexte: { flex: 1, gap: spacing.demi },
  carteTitre: { ...typography.bodyFort, color: colors.textPrimary },
  carteAide: { ...typography.caption, color: colors.textSecondary },

  avances: { gap: spacing.xxl },
  avancesEnTete: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: composants.badgePremium.gap,
  },
  avancesTitre: { ...typography.h2, color: colors.textPrimary, includeFontPadding: false },
  badgePremium: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: composants.badge.gap,
    paddingHorizontal: composants.badgePremium.paddingH,
    paddingVertical: composants.badgePremium.paddingV,
    borderRadius: radius.badge,
    backgroundColor: marque.nuit,
  },
  badgePremiumTexte: { ...typography.caption, color: marque.poudre },

  verrou: { alignItems: 'flex-start' },
  verrouLien: { ...typography.label, color: colors.accent, marginTop: spacing.sm },
  presse: { opacity: opacity.pressed },

  actions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
    paddingHorizontal: spacing.gutter,
    paddingTop: spacing.lg,
    paddingBottom: spacing.xxl,
    borderTopWidth: hairline,
    borderTopColor: colors.rule,
    backgroundColor: colors.background,
  },
  reinitialiser: { ...typography.bouton, color: colors.textSecondary },
  eteint: { color: colors.textMuted },
  validerLargeur: { flex: 1 },
});
