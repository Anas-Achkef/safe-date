import { supabase } from '../lib/supabase';
import type { ProfileHeader, ProfileSection, VisiblePriority } from '../types/rpc';
import { toApiError } from './errors';

/**
 * Profil personnel de l'utilisateur courant.
 *
 * Aucune de ces fonctions ne prend d'identifiant : le back-end lit auth.uid().
 */

export async function fetchProfileHeader(): Promise<ProfileHeader | null> {
  const { data, error } = await supabase.rpc('profile_header');
  if (error) throw toApiError(error, 'En-tete du profil');
  const rows = (data ?? []) as ProfileHeader[];
  const row = rows[0];
  if (!row) return null;
  return { ...row, connaissance: Number(row.connaissance), age: Number(row.age) };
}

export async function fetchProfileSections(): Promise<ProfileSection[]> {
  const { data, error } = await supabase.rpc('profile_sections');
  if (error) throw toApiError(error, 'Sections du profil');
  return (data ?? []) as ProfileSection[];
}

/** Indice de connaissance du profil, en pourcentage. */
export async function fetchProfileKnowledge(): Promise<number> {
  const { data, error } = await supabase.rpc('profile_knowledge');
  if (error) throw toApiError(error, 'Connaissance du profil');
  return Number(data ?? 0);
}

export async function fetchVisiblePriorities(): Promise<VisiblePriority[]> {
  const { data, error } = await supabase.rpc('visible_priorities');
  if (error) throw toApiError(error, 'Priorites visibles');
  return (data ?? []) as VisiblePriority[];
}

/**
 * Reordonne les priorites. Reserve aux comptes premium : le back-end leve une
 * erreur pour les autres, que l'on remonte telle quelle.
 */
export async function reorderPriorities(ordre: string[]): Promise<void> {
  const { error } = await supabase.rpc('reorder_priorities', { ordre });
  if (error) throw toApiError(error, 'Reordonnancement des priorites');
}

export async function setPrimaryPhoto(photoId: string): Promise<void> {
  const { error } = await supabase.rpc('set_primary_photo', { photo_id: photoId });
  if (error) throw toApiError(error, 'Photo principale');
}

export async function isProximityAvailable(): Promise<boolean> {
  const { data, error } = await supabase.rpc('proximite_disponible');
  if (error) throw toApiError(error, 'Disponibilite de la proximite');
  return data === true;
}

export async function requestAccountDeletion(): Promise<void> {
  const { error } = await supabase.rpc('request_account_deletion');
  if (error) throw toApiError(error, 'Demande de suppression de compte');
}
