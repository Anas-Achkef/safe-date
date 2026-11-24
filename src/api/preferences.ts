import { ecrire, lire } from '../lib/stockage';
import { FILTRES_PAR_DEFAUT, type Filtres } from '../types/filtres';
import { rpcAVenir } from './rpcAVenir';

const CLE = 'filtres';

/**
 * Les préférences de recherche.
 *
 * Elles ont vocation à vivre en base : c'est elle qui filtre, et un réglage
 * qui ne suit pas d'un appareil à l'autre n'est pas un réglage de compte.
 * Ni la table `search_preferences` ni ses deux fonctions n'existent — voir
 * `db/002-preferences-recherche.sql`.
 *
 * En attendant, l'appareil fait foi. Le jour où les fonctions existent, elles
 * prennent la main sans que les écrans changent d'une ligne : c'est l'intérêt
 * de passer par ici plutôt que d'appeler le stockage depuis un composant.
 */
export async function chargerFiltres(): Promise<Filtres> {
  const local = await lire<Filtres>(CLE, FILTRES_PAR_DEFAUT);

  try {
    const lignes = await rpcAVenir<Partial<Filtres>>('mes_preferences_recherche');
    const distant = lignes?.[0];
    if (distant) {
      const fusion = { ...FILTRES_PAR_DEFAUT, ...distant };
      // Le compte fait autorité : on aligne l'appareil sur lui.
      await ecrire(CLE, fusion);
      return fusion;
    }
  } catch {
    // Hors ligne ou serveur muet : les filtres locaux font le travail, il n'y
    // a rien à réparer côté utilisateur.
  }

  return local;
}

/**
 * Enregistre les filtres.
 *
 * L'appareil d'abord, le serveur ensuite : le réglage doit tenir même hors
 * ligne. L'échec distant ne remonte pas à l'écran — le filtre est appliqué,
 * l'utilisateur n'a rien à réparer.
 */
export async function enregistrerFiltres(f: Filtres): Promise<void> {
  await ecrire(CLE, f);

  try {
    await rpcAVenir('enregistrer_preferences_recherche', { preferences: f });
  } catch {
    // Le réglage reste sur l'appareil et repartira au prochain enregistrement.
  }
}
