import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * Stockage local typé.
 *
 * Sert aux réglages qui appartiennent à l'appareil — filtres de recherche,
 * état d'abonnement en attendant le serveur. Rien de sensible n'y va : c'est
 * du texte en clair, lisible par qui a accès au téléphone déverrouillé.
 *
 * Toute lecture qui échoue rend la valeur par défaut. Un réglage illisible ne
 * doit jamais empêcher l'écran de s'afficher.
 */

const PREFIXE = 'safedate.';

export async function lire<T>(cle: string, defaut: T): Promise<T> {
  try {
    const brut = await AsyncStorage.getItem(PREFIXE + cle);
    if (brut === null) return defaut;
    const valeur = JSON.parse(brut) as unknown;
    // Un réglage écrit par une version antérieure peut avoir perdu des champs :
    // on complète avec les valeurs par défaut plutôt que de rendre l'objet tel
    // quel, sinon un champ absent devient `undefined` au milieu du code.
    if (
      typeof defaut === 'object' &&
      defaut !== null &&
      !Array.isArray(defaut) &&
      typeof valeur === 'object' &&
      valeur !== null
    ) {
      return { ...defaut, ...(valeur as object) } as T;
    }
    return valeur as T;
  } catch {
    return defaut;
  }
}

export async function ecrire<T>(cle: string, valeur: T): Promise<void> {
  try {
    await AsyncStorage.setItem(PREFIXE + cle, JSON.stringify(valeur));
  } catch {
    // Quota plein, mode privé : le réglage vaudra pour la session seulement.
  }
}

export async function effacer(cle: string): Promise<void> {
  try {
    await AsyncStorage.removeItem(PREFIXE + cle);
  } catch {
    // Sans effet observable : la valeur sera simplement réécrite.
  }
}
