import * as Location from 'expo-location';
import { useCallback, useEffect, useRef, useState } from 'react';

import type { Coordonnees } from '../lib/geo';

/**
 * - `inactif`      : rien n'a encore ete demande a l'utilisateur.
 * - `demande`      : la boite de dialogue systeme est ouverte, ou le premier
 *                    point n'est pas encore arrive.
 * - `active`       : la position est suivie.
 * - `refusee`      : l'utilisateur a dit non. On ne redemande pas.
 * - `indisponible` : materiel ou navigateur sans geolocalisation.
 */
export type EtatPosition = 'inactif' | 'demande' | 'active' | 'refusee' | 'indisponible';

interface Position {
  etat: EtatPosition;
  position: Coordonnees | null;
  /** Precision annoncee par le capteur, en metres. */
  precision: number | null;
  demander: () => Promise<void>;
}

/**
 * Suit la position de l'utilisateur, en premier plan uniquement.
 *
 * Le suivi ne demarre jamais tout seul : `demander()` doit etre appele depuis
 * un geste explicite. C'est ce qui permet d'expliquer l'usage avant que le
 * systeme ne pose sa question, et de ne pas geolocaliser qui ne l'a pas voulu.
 */
export function usePosition(): Position {
  const [etat, setEtat] = useState<EtatPosition>('inactif');
  const [position, setPosition] = useState<Coordonnees | null>(null);
  const [precision, setPrecision] = useState<number | null>(null);

  const abonnement = useRef<Location.LocationSubscription | null>(null);
  const monte = useRef(true);

  useEffect(() => {
    monte.current = true;
    return () => {
      monte.current = false;
      abonnement.current?.remove();
      abonnement.current = null;
    };
  }, []);

  const demander = useCallback(async () => {
    if (abonnement.current) return;
    setEtat('demande');

    try {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (!monte.current) return;
      if (status !== 'granted') {
        setEtat('refusee');
        return;
      }

      // Un suivi continu plutot qu'un point unique : l'ecran doit montrer la
      // distance fondre pendant l'approche, c'est tout l'interet.
      const sub = await Location.watchPositionAsync(
        {
          accuracy: Location.Accuracy.High,
          distanceInterval: 5,
          timeInterval: 4_000,
        },
        ({ coords }) => {
          if (!monte.current) return;
          setPosition({ lat: coords.latitude, lon: coords.longitude });
          setPrecision(typeof coords.accuracy === 'number' ? coords.accuracy : null);
          setEtat('active');
        },
      );

      if (!monte.current) {
        sub.remove();
        return;
      }
      abonnement.current = sub;
    } catch {
      // Emulateur sans service de localisation, navigateur en contexte non
      // securise, materiel absent : rien a corriger cote utilisateur.
      if (monte.current) setEtat('indisponible');
    }
  }, []);

  return { etat, position, precision, demander };
}
