import { supabase } from '../lib/supabase';
import { estErreurAbsenceFonction } from './errors';

/**
 * Appelle une RPC qui n'existe pas encore dans le schéma.
 *
 * Les types de `supabase-js` sont générés depuis la base réelle : appeler une
 * fonction non déployée est une erreur de compilation, et c'est une bonne
 * chose. Ce point de passage unique assume la conversion, une seule fois, avec
 * la raison écrite — plutôt que de disséminer des `as any` dans la couche API.
 *
 * Rend `null` quand la fonction est absente, ce qui n'est pas une panne mais
 * l'état connu du back-end. Toute autre erreur est relancée.
 *
 * Chaque appel ici correspond à une proposition SQL dans `db/`. Le jour où
 * elle est appliquée, il suffit de régénérer les types et de remplacer l'appel
 * par un `supabase.rpc` ordinaire.
 */
export async function rpcAVenir<T>(
  nom: string,
  args?: Record<string, unknown>,
): Promise<T[] | null> {
  const appel = supabase.rpc as unknown as (
    n: string,
    a?: Record<string, unknown>,
  ) => Promise<{ data: unknown; error: unknown }>;

  try {
    const { data, error } = await appel(nom, args);
    if (error) throw error;
    return (data ?? []) as T[];
  } catch (e) {
    if (estErreurAbsenceFonction(e)) return null;
    throw e;
  }
}
