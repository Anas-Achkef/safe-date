import { useCallback, useEffect, useRef, useState } from 'react';
import { AppState, type AppStateStatus } from 'react-native';
import type { ScoreGroup } from '../types/rpc';
import type { CritereAffiche, DureeEcran } from '../types/learning';

type CriteresParPage = Partial<Record<Exclude<ScoreGroup, 'physique'>, CritereAffiche[]>>;

export interface ReleveConsultation {
  ecrans: DureeEcran[];
  ordre_consultation: ScoreGroup[];
  retours: number;
  duree_ms: number;
  ecran: ScoreGroup;
  criteres_exposes: string[];
  criteres_consultes: string[];
}

/**
 * Mesure comment un profil a été consulté.
 *
 * Le moteur ne se contente pas du sens du swipe : il pondère le signal par
 * l'attention réellement accordée à chaque page. Un « oui » donné après
 * trente secondes sur la photo ne dit pas la même chose qu'un « oui » donné
 * sans l'avoir regardée, et un profil balayé en deux secondes ne prouve rien
 * du tout — le serveur assortit d'ailleurs la répartition d'une fiabilité.
 *
 * Aucune mesure n'est inventée : une page jamais ouverte n'apparaît pas dans
 * le relevé, elle sera calculée côté serveur comme page ignorée par
 * différence avec l'ordre servi.
 */
function clesDe(criteres: CriteresParPage, page: ScoreGroup): string[] {
  if (page === 'physique') return [];
  return (criteres[page] ?? []).map((c) => c.cle);
}

export function useConsultation(pages: ScoreGroup[], criteres: CriteresParPage = {}) {
  const [index, setIndex] = useState(0);
  const cumul = useRef<Map<ScoreGroup, { duree: number; vues: number }>>(new Map());
  const ordre = useRef<ScoreGroup[]>([]);
  const retours = useRef(0);
  const dernier = useRef(Date.now());
  const debut = useRef(Date.now());
  // Le temps passé hors de l'application n'est pas du temps de lecture : le
  // compter fausserait la fiabilité que le serveur associe à la répartition.
  const horsApp = useRef(0);
  const sortie = useRef<number | null>(null);

  useEffect(() => {
    const onChange = (etat: AppStateStatus) => {
      if (etat === 'active') {
        if (sortie.current !== null) {
          const absence = Date.now() - sortie.current;
          horsApp.current += absence;
          dernier.current += absence;
          sortie.current = null;
        }
      } else if (sortie.current === null) {
        sortie.current = Date.now();
      }
    };
    const sub = AppState.addEventListener('change', onChange);
    return () => sub.remove();
  }, []);

  const cloturerPage = useCallback(
    (i: number) => {
      const page = pages[i];
      if (!page) return;
      const ecoule = Date.now() - dernier.current;
      const actuel = cumul.current.get(page) ?? { duree: 0, vues: 0 };
      cumul.current.set(page, { duree: actuel.duree + ecoule, vues: actuel.vues });
      dernier.current = Date.now();
    },
    [pages],
  );

  const entrerPage = useCallback(
    (i: number) => {
      const page = pages[i];
      if (!page) return;
      const actuel = cumul.current.get(page) ?? { duree: 0, vues: 0 };
      // Revenir sur une page déjà vue est un acte volontaire : le serveur en
      // fait un signal d'attention plus fort qu'une simple durée.
      if (actuel.vues > 0) retours.current += 1;
      cumul.current.set(page, { duree: actuel.duree, vues: actuel.vues + 1 });
      if (!ordre.current.includes(page)) ordre.current.push(page);
    },
    [pages],
  );

  const allerA = useCallback(
    (i: number) => {
      if (i < 0 || i >= pages.length) return;
      setIndex((courant) => {
        if (i === courant) return courant;
        cloturerPage(courant);
        entrerPage(i);
        return i;
      });
    },
    [cloturerPage, entrerPage, pages.length],
  );

  /** Fige les mesures au moment de la décision. */
  const releve = useCallback((): ReleveConsultation => {
    cloturerPage(index);
    return {
      ecrans: [...cumul.current.entries()].map(([ecran, { duree, vues }]) => ({
        ecran,
        duree_ms: Math.round(duree),
        consultations: vues,
      })),
      ordre_consultation: [...ordre.current],
      // Ouvrir une page vaut consultation de ses critères : c'est la maille la
      // plus fine que l'interface permette aujourd'hui d'observer honnêtement.
      criteres_exposes: pages.flatMap((pg) => clesDe(criteres, pg)),
      criteres_consultes: ordre.current.flatMap((pg) => clesDe(criteres, pg)),
      retours: retours.current,
      duree_ms: Date.now() - debut.current - horsApp.current,
      ecran: pages[index],
    };
  }, [cloturerPage, criteres, index, pages]);

  /** Remise à zéro entre deux profils. */
  const reinitialiser = useCallback(() => {
    cumul.current = new Map();
    ordre.current = [];
    retours.current = 0;
    debut.current = Date.now();
    dernier.current = Date.now();
    horsApp.current = 0;
    sortie.current = null;
    setIndex(0);
    entrerPage(0);
  }, [entrerPage]);

  return { index, allerA, releve, reinitialiser };
}
