import { supabase } from '../lib/supabase';
import { removePhotoObject, signPhotoPath, uploadPhoto } from '../lib/storage';
import { toApiError } from './errors';

/**
 * Photos de profil.
 *
 * `user_photos` est ecrivable directement par son proprietaire ; seule la
 * designation de la photo principale passe par la RPC `set_primary_photo`,
 * qui garantit l'unicite du drapeau.
 *
 * La moderation vaut `en_attente` a la creation. `candidate_cards` accepte
 * tout ce qui n'est pas `rejetee` : une photo est donc visible immediatement,
 * puis retiree si elle est rejetee.
 */

export interface UserPhoto {
  id: string;
  storagePath: string;
  /** URL signee, prete a etre affichee. `null` si la signature a echoue. */
  url: string | null;
  position: number;
  isPrimary: boolean;
  moderation: 'en_attente' | 'approuvee' | 'rejetee';
}

export async function fetchMyPhotos(): Promise<UserPhoto[]> {
  const { data, error } = await supabase
    .from('user_photos')
    .select('id, storage_path, position, is_primary, moderation')
    .order('position');

  if (error) throw toApiError(error, 'Chargement de vos photos');

  const rows = data ?? [];
  return Promise.all(
    rows.map(async (row) => ({
      id: row.id as string,
      storagePath: row.storage_path as string,
      url: await signPhotoPath(row.storage_path as string),
      position: Number(row.position ?? 0),
      isPrimary: row.is_primary === true,
      moderation: row.moderation as UserPhoto['moderation'],
    })),
  );
}

/**
 * Televerse une image et l'enregistre.
 *
 * La premiere photo devient automatiquement la photo principale : un profil
 * sans photo principale n'apparait nulle part.
 */
export async function addPhoto(localUri: string): Promise<void> {
  const { data: session } = await supabase.auth.getSession();
  const userId = session.session?.user.id;
  if (!userId) throw toApiError(new Error('Authentification requise'), 'Ajout de photo');

  const storagePath = await uploadPhoto(userId, localUri);

  const { count } = await supabase
    .from('user_photos')
    .select('id', { count: 'exact', head: true });
  const isFirst = (count ?? 0) === 0;

  const { data, error } = await supabase
    .from('user_photos')
    .insert({
      user_id: userId,
      storage_path: storagePath,
      position: count ?? 0,
    })
    .select('id')
    .single();

  if (error) {
    // L'objet a ete televerse mais la ligne n'a pas pu etre creee : on ne
    // laisse pas de fichier orphelin dans le compartiment.
    await removePhotoObject(storagePath);
    throw toApiError(error, 'Enregistrement de la photo');
  }

  if (isFirst && data?.id) {
    await setPrimaryPhoto(data.id as string);
  }
}

export async function setPrimaryPhoto(photoId: string): Promise<void> {
  const { error } = await supabase.rpc('set_primary_photo', { photo_id: photoId });
  if (error) throw toApiError(error, 'Photo principale');
}

export async function deletePhoto(photo: UserPhoto): Promise<void> {
  const { error } = await supabase.from('user_photos').delete().eq('id', photo.id);
  if (error) throw toApiError(error, 'Suppression de la photo');
  await removePhotoObject(photo.storagePath);
}
