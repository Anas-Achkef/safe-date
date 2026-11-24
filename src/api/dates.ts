import { supabase } from '../lib/supabase';
import type { ResumeRendezVous } from '../types/conversations';
import type { Establishment } from '../types/rpc';
import { toApiError } from './errors';
import { rpcAVenir } from './rpcAVenir';
import { demo, isPreviewMode } from '../preview';

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
  if (isPreviewMode) return demo.revelerEtablissement(dateId, { lat: latitude, lon: longitude });

  const { data, error } = await supabase.rpc('reveal_establishment', {
    d_id: dateId,
    position_actuelle: `SRID=4326;POINT(${longitude} ${latitude})`,
  });
  if (error) throw toApiError(error, 'Revelation de l’etablissement');

  const rows = (data ?? []) as Establishment[];
  return rows[0] ?? null;
}

/**
 * Les rendez-vous a venir de l'utilisateur.
 *
 * `mes_rendezvous()` est proposee dans `db/001-point-rendezvous.sql` et n'est
 * pas encore appliquee. L'appel est deja en place : le jour ou la fonction
 * existe, cet ecran se remplit sans qu'on touche a une ligne de rendu.
 *
 * Tant qu'elle est absente, la liste est vide plutot qu'en erreur : le manque
 * se voit, il ne casse rien.
 */
export async function listUpcomingDates(): Promise<ResumeRendezVous[]> {
  if (isPreviewMode) return demo.mesRendezVous();

  const lignes = await rpcAVenir<ResumeRendezVous>('mes_rendezvous');
  if (!lignes) return [];

  // `mes_rendezvous` ne calcule pas la distance : elle depend de la position
  // de l'appareil, que le serveur n'a pas. L'ecran la mesure lui-meme.
  return lignes.map((r) => ({ ...r, distance_m: null }));
}

/**
 * Le point de rendez-vous de l'utilisateur pour un rendez-vous donne.
 *
 * `mon_point_rendezvous(d_id)` ne rend jamais le point de l'autre participant
 * — c'est la garantie centrale, elle tient a la clause `user_id = auth.uid()`
 * de la fonction. Voir `db/001-point-rendezvous.sql`.
 */
export async function loadMeetingPoint(
  dateId: string,
): Promise<{ lat: number; lon: number; expires_at: string | null } | null> {
  const lignes = await rpcAVenir<{ lat: number; lon: number; expires_at: string | null }>(
    'mon_point_rendezvous',
    { d_id: dateId },
  );
  return lignes?.[0] ?? null;
}
