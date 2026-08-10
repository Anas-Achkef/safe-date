import { supabase } from './supabase';

/**
 * Stockage des photos de profil.
 *
 * `user_photos.storage_path` contient un chemin, pas une URL : c'est ce que
 * renvoie `candidate_cards.photo`. Il faut donc signer ce chemin avant de le
 * passer a un composant Image.
 *
 * Le compartiment doit rester prive : ces photos sont des donnees
 * personnelles, elles ne doivent pas etre accessibles par URL devinable.
 */
export const PHOTO_BUCKET = 'user-photos';

/** Duree de validite des URLs signees, en secondes. */
const SIGNED_URL_TTL = 60 * 60;

export class MissingBucketError extends Error {
  constructor() {
    super(
      `Le compartiment de stockage « ${PHOTO_BUCKET} » n'existe pas encore sur le projet Supabase.`,
    );
    this.name = 'MissingBucketError';
  }
}

function isMissingBucket(message: string): boolean {
  return /bucket not found|does not exist/i.test(message);
}

/**
 * Nom de fichier unique.
 *
 * `crypto.randomUUID` n'est pas garanti sur React Native : s'y fier ferait
 * fonctionner le navigateur et echouer le telephone. L'unicite n'a besoin
 * d'etre vraie que dans le dossier d'un utilisateur.
 */
function uniqueName(): string {
  const time = Date.now().toString(36);
  const noise = Math.random().toString(36).slice(2, 10);
  return `${time}-${noise}`;
}

/**
 * Signe un lot de chemins en une fois.
 *
 * Renvoie une table chemin -> URL. Un chemin qui echoue est simplement absent
 * de la table : l'appelant retombe alors sur le visuel de substitution plutot
 * que d'afficher une image cassee.
 */
export async function signPhotoPaths(paths: string[]): Promise<Map<string, string>> {
  const unique = [...new Set(paths.filter(Boolean))];
  const resolved = new Map<string, string>();
  if (unique.length === 0) return resolved;

  const { data, error } = await supabase.storage
    .from(PHOTO_BUCKET)
    .createSignedUrls(unique, SIGNED_URL_TTL);

  if (error) {
    if (isMissingBucket(error.message)) return resolved;
    return resolved;
  }

  for (const item of data ?? []) {
    if (item.signedUrl && item.path) resolved.set(item.path, item.signedUrl);
  }
  return resolved;
}

export async function signPhotoPath(path: string | null): Promise<string | null> {
  if (!path) return null;
  const map = await signPhotoPaths([path]);
  return map.get(path) ?? null;
}

/**
 * Televerse une image locale et renvoie son chemin de stockage.
 *
 * Les fichiers sont ranges sous l'identifiant de l'utilisateur, ce qui permet
 * d'ecrire des regles de securite simples cote compartiment.
 */
export async function uploadPhoto(userId: string, localUri: string): Promise<string> {
  const response = await fetch(localUri);
  const bytes = await response.arrayBuffer();

  const extension = localUri.split('.').pop()?.split('?')[0]?.toLowerCase() ?? 'jpg';
  const safeExtension = /^(jpg|jpeg|png|webp|heic)$/.test(extension) ? extension : 'jpg';
  const path = `${userId}/${uniqueName()}.${safeExtension}`;

  const contentType =
    safeExtension === 'png'
      ? 'image/png'
      : safeExtension === 'webp'
        ? 'image/webp'
        : safeExtension === 'heic'
          ? 'image/heic'
          : 'image/jpeg';

  const { error } = await supabase.storage
    .from(PHOTO_BUCKET)
    .upload(path, bytes, { contentType, upsert: false });

  if (error) {
    if (isMissingBucket(error.message)) throw new MissingBucketError();
    throw error;
  }

  return path;
}

export async function removePhotoObject(path: string): Promise<void> {
  await supabase.storage.from(PHOTO_BUCKET).remove([path]);
}
