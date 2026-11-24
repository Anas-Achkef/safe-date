import { useCallback, useMemo, useState } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import type { NativeScrollEvent, NativeSyntheticEvent } from 'react-native';

import type { DiscoveryEntry, HiddenReason } from '../api/discovery';
import { snapChildProps, snapContainerProps } from '../lib/webFrame';
import { colors, hairline, radius, spacing, typography } from '../theme';
import type { ScoreGroup } from '../types/rpc';
import { Highlights } from './Highlights';
import { PhotoCard } from './PhotoCard';

/**
 * L'ordre des pages.
 *
 * Le portrait ouvre, puis les trois dimensions dans l'ordre où le produit les
 * raconte : ce qu'on croit, comment on vit, ce qu'on voit. Le physique arrive
 * en dernier — c'est le parti pris de Safe Date, il doit se lire dans le geste.
 */
const PAGES: ScoreGroup[] = ['valeurs', 'mode_vie', 'physique'];

const TITRES: Record<ScoreGroup, string> = {
  valeurs: 'Valeurs',
  mode_vie: 'Mode de vie',
  physique: 'Physique',
};

const SOUS_TITRES: Record<ScoreGroup, string> = {
  valeurs: 'Ce sur quoi vous vous rejoignez',
  mode_vie: 'Vos rythmes et vos habitudes',
  physique: 'Vos préférences déclarées',
};

const NOTES_MASQUEES: Record<HiddenReason, string> = {
  premium:
    'Ce profil fait partie de vos meilleures compatibilités. Son détail est réservé aux membres.',
  filters: 'Ce profil sort de vos critères d’âge ou de distance.',
  no_data: 'Répondez à quelques questions de plus pour découvrir ce profil.',
  unreadable: 'Ce profil n’a pas pu être évalué.',
};

interface Props {
  entry: DiscoveryEntry;
  /** Hauteur d'une page : une page occupe exactement l'écran. */
  hauteur: number;
}

/**
 * Un profil, quatre pages, un seul geste vertical.
 *
 * On ne survole plus un résumé : on traverse le profil. Chaque dimension a sa
 * page, son score et ses points d'accord — il faut faire défiler pour
 * l'atteindre, donc il faut avoir lu la précédente.
 *
 * Le geste horizontal, lui, décide. Il est porté par `CarteSwipe` au-dessus :
 * les deux axes ne se marchent jamais dessus.
 */
export function ProfilDefilant({ entry, hauteur }: Props) {
  const [page, setPage] = useState(0);

  const parGroupe = useMemo(() => {
    const m = new Map<ScoreGroup, typeof entry.highlights>();
    for (const h of entry.highlights ?? []) {
      const liste = m.get(h.groupe) ?? [];
      liste.push(h);
      m.set(h.groupe, liste);
    }
    return m;
  }, [entry.highlights]);

  const scores: Record<ScoreGroup, number | null> = {
    valeurs: entry.score_valeurs,
    mode_vie: entry.score_mode_vie,
    physique: entry.score_physique,
  };

  const suivrePage = useCallback(
    (e: NativeSyntheticEvent<NativeScrollEvent>) => {
      const i = Math.round(e.nativeEvent.contentOffset.y / hauteur);
      setPage((p) => (p === i ? p : i));
    },
    [hauteur],
  );

  return (
    <View style={styles.zone}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        pagingEnabled
        snapToInterval={hauteur}
        snapToAlignment="start"
        decelerationRate="fast"
        disableIntervalMomentum
        onScroll={suivrePage}
        scrollEventThrottle={32}
        {...snapContainerProps}
      >
        {/* Page d'ouverture : le visage, le prénom, le chiffre global. */}
        <View style={[styles.page, { height: hauteur }]} {...snapChildProps}>
          <PhotoCard
            photo={entry.photo}
            firstName={entry.prenom}
            age={entry.age}
            score={entry.visible ? entry.score_global : null}
            seed={entry.candidate_id}
            height={hauteur - spacing.xxxl}
          />
          <Text style={styles.invite} allowFontScaling={false}>
            Faites défiler pour lire le profil
          </Text>
        </View>

        {PAGES.map((groupe) => (
          <View key={groupe} style={[styles.page, { height: hauteur }]} {...snapChildProps}>
            <ScrollView
              style={styles.feuille}
              contentContainerStyle={styles.feuilleContenu}
              showsVerticalScrollIndicator={false}
            >
              <Text style={styles.surtitre} allowFontScaling={false}>
                {TITRES[groupe].toUpperCase()}
              </Text>

              {entry.visible && scores[groupe] !== null ? (
                <>
                  <Text style={styles.chiffre} allowFontScaling={false}>
                    {Math.round(scores[groupe] as number)}
                    <Text style={styles.pourcent}> %</Text>
                  </Text>
                  <Text style={styles.legende}>{SOUS_TITRES[groupe]}</Text>

                  <View style={styles.filet} />

                  {(parGroupe.get(groupe) ?? []).length > 0 ? (
                    <Highlights items={parGroupe.get(groupe) ?? []} />
                  ) : (
                    <Text style={styles.rien}>
                      Aucun point d’accord relevé sur cette dimension pour l’instant.
                    </Text>
                  )}
                </>
              ) : (
                <Text style={styles.rien}>
                  {NOTES_MASQUEES[entry.hiddenReason ?? 'unreadable']}
                </Text>
              )}
            </ScrollView>
          </View>
        ))}
      </ScrollView>

      {/* Repères de progression : on doit savoir combien il reste à lire. */}
      <View style={styles.reperes}>
        {[0, ...PAGES.map((_, i) => i + 1)].map((i) => (
          <View key={i} style={[styles.repere, i === page && styles.repereActif]} />
        ))}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  zone: { flex: 1 },
  page: { paddingHorizontal: spacing.gutter, paddingTop: spacing.md },
  invite: {
    ...typography.caption,
    color: colors.textMuted,
    textAlign: 'center',
    marginTop: spacing.md,
  },

  feuille: { flex: 1 },
  feuilleContenu: { paddingTop: spacing.xxl, paddingBottom: spacing.xxl, gap: spacing.sm },
  surtitre: { ...typography.overline, color: colors.textMuted },
  chiffre: { ...typography.display, color: colors.accent, includeFontPadding: false },
  pourcent: { ...typography.heading, color: colors.accent },
  legende: { ...typography.body, color: colors.textSecondary },
  filet: {
    height: hairline,
    backgroundColor: colors.rule,
    marginVertical: spacing.lg,
  },
  rien: {
    ...typography.body,
    color: colors.textMuted,
    backgroundColor: colors.surfaceAlt,
    borderRadius: radius.sm,
    padding: spacing.lg,
  },

  reperes: {
    position: 'absolute',
    right: spacing.sm,
    top: 0,
    bottom: 0,
    justifyContent: 'center',
    gap: spacing.sm,
    pointerEvents: 'none',
  },
  repere: {
    width: 4,
    height: 4,
    borderRadius: radius.pill,
    backgroundColor: colors.rule,
  },
  repereActif: { height: 18, backgroundColor: colors.accent },
});
