import { useFocusEffect } from 'expo-router';
import { useCallback, useState } from 'react';

import { chargerFiltres, enregistrerFiltres } from '../api/preferences';
import { FILTRES_PAR_DEFAUT, type Filtres } from '../types/filtres';

/**
 * Les filtres de recherche du compte.
 *
 * Ils sont relus **à chaque prise de focus** et non au seul montage : le
 * panneau de filtres est une route à part, et l'écran qui l'a ouverte reste
 * monté derrière. Sans cette relecture, revenir du panneau afficherait encore
 * les anciens critères.
 *
 * L'enregistrement met l'état à jour tout de suite et confie la persistance à
 * `src/api/preferences.ts` — qui écrit sur l'appareil puis tente le serveur,
 * sans jamais faire remonter un échec distant à l'écran.
 */
export function useFiltres() {
  const [filtres, setFiltres] = useState<Filtres>(FILTRES_PAR_DEFAUT);

  useFocusEffect(
    useCallback(() => {
      let vivant = true;
      void chargerFiltres().then((f) => {
        if (vivant) setFiltres(f);
      });
      return () => {
        vivant = false;
      };
    }, []),
  );

  const enregistrer = useCallback((f: Filtres) => {
    setFiltres(f);
    void enregistrerFiltres(f);
  }, []);

  return { filtres, enregistrer };
}
