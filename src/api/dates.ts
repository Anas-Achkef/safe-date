import { supabase } from '../lib/supabase';
import type { Establishment } from '../types/rpc';
import { toApiError } from './errors';

/**
 * Reveler l'etablissement d'un rendez-vous.
 *
 * Le back-end leve une erreur tant que l'utilisateur est a plus de 25 m de son
 * point de rendez-vous : c'est le mecanisme central du produit, pas un defaut.
 *
 * `position_actuelle` est un `geography` : PostGIS accepte la representation
 * texte `SRID=4326;POINT(lon lat)`. L'ordre est bien longitude puis latitude.
 */
export async function revealEstablishment(
  dateId: string,
  longitude: number,
  latitude: number,
): Promise<Establishment | null> {
  const { data, error } = await supabase.rpc('reveal_establishment', {
    d_id: dateId,
    position_actuelle: `SRID=4326;POINT(${longitude} ${latitude})`,
  });
  if (error) throw toApiError(error, 'Revelation de l’etablissement');

  const rows = (data ?? []) as Establishment[];
  return rows[0] ?? null;
}
