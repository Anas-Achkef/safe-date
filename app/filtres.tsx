import { router } from 'expo-router';
import { useCallback, useEffect, useState } from 'react';
import { StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { loadDiscoveryFeed, type DiscoveryEntry } from '../src/api/discovery';
import { PanneauFiltres } from '../src/components/PanneauFiltres';
import { usePremium } from '../src/hooks/usePremium';
import { useFiltres } from '../src/hooks/useFiltres';
import { filtrerProfils } from '../src/lib/filtrage';
import { isPreviewMode } from '../src/preview';
import { attributsDemo } from '../src/preview/attributs';
import { colors } from '../src/theme';
import type { Filtres } from '../src/types/filtres';

/**
 * Les filtres, en modale montant du bas.
 *
 * Une route à part et non une surcouche dans l'écran Parcourir : la maquette
 * les montre plein écran, barre d'onglets comprise, et seule une route du
 * `Stack` racine passe par-dessus le navigateur d'onglets.
 *
 * L'écran charge le vivier pour pouvoir annoncer, à chaque geste, combien de
 * profils le réglage en cours laisserait passer. C'est le même appel que
 * Parcourir — le comptage doit rester honnête, et un nombre figé au moment de
 * l'ouverture ne le serait plus dès le premier curseur déplacé.
 */
export default function Filtres() {
  const { filtres, enregistrer } = useFiltres();
  const { premium } = usePremium();
  const [profils, setProfils] = useState<DiscoveryEntry[]>([]);

  useEffect(() => {
    let vivant = true;
    // Un échec reste silencieux : le panneau se règle très bien sans compte,
    // et une erreur de réseau n'a rien à dire sur un choix de critères.
    void loadDiscoveryFeed()
      .then((liste) => {
        if (vivant) setProfils(liste);
      })
      .catch(() => undefined);
    return () => {
      vivant = false;
    };
  }, []);

  // Les attributs fins n'existent que dans le jeu de démonstration : en
  // conditions réelles le lecteur est absent et seuls âge, vérification et
  // score sont filtrés. Un critère non évaluable ne rejette jamais.
  const lecteur = isPreviewMode ? attributsDemo : undefined;

  const compter = useCallback(
    (f: Filtres) => filtrerProfils(profils, f, lecteur).length,
    [profils, lecteur],
  );

  return (
    <SafeAreaView style={styles.page} edges={['top', 'left', 'right', 'bottom']}>
      <PanneauFiltres
        valeur={filtres}
        compter={compter}
        premium={premium}
        onValider={(f) => {
          enregistrer(f);
          router.back();
        }}
        onFermer={() => router.back()}
        onPremium={() => router.replace('/premium')}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  page: { flex: 1, backgroundColor: colors.background },
});
