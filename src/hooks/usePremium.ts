import { useEffect, useState } from 'react';

import {
  chargerAbonnement,
  enregistrerAbonnement,
  oublierAbonnement,
  SANS_ABONNEMENT,
  type Abonnement,
} from '../api/abonnement';

/**
 * L'abonnement, partagé par tous les écrans.
 *
 * Un magasin unique plutôt qu'un état par écran : prendre l'abonnement depuis
 * la feuille de filtres doit débloquer la grille derrière, sans rechargement.
 * Il est relu au démarrage depuis le stockage, donc il survit à une fermeture
 * de l'application.
 */
let etat: Abonnement = SANS_ABONNEMENT;
let charge = false;
const ecouteurs = new Set<(a: Abonnement) => void>();

function diffuser(a: Abonnement) {
  etat = a;
  for (const e of ecouteurs) e(a);
}

export async function activerPremium(formule: string): Promise<void> {
  diffuser(await enregistrerAbonnement(formule));
}

export async function desactiverPremium(): Promise<void> {
  await oublierAbonnement();
  diffuser(SANS_ABONNEMENT);
}

export function usePremium(): { premium: boolean; abonnement: Abonnement } {
  const [a, setA] = useState<Abonnement>(etat);

  useEffect(() => {
    ecouteurs.add(setA);
    if (!charge) {
      charge = true;
      void chargerAbonnement().then(diffuser);
    }
    return () => {
      ecouteurs.delete(setA);
    };
  }, []);

  return { premium: a.actif, abonnement: a };
}
