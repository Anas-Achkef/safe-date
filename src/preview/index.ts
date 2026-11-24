/**
 * Mode prévisualisation.
 *
 * Active un rendu complet de l'application sans authentification, pour juger
 * l'interface pendant que la direction artistique se décide.
 *
 * Ce dossier est une couche par-dessus l'application : il n'est lu que par les
 * hooks et par `Screen`. La couche `src/api/` reste intacte et continue de
 * parler au vrai back-end. Retirer `EXPO_PUBLIC_PREVIEW` du `.env` suffit à
 * revenir au comportement réel ; supprimer ce dossier et ses quatre points
 * d'appel suffit à l'effacer définitivement.
 */
export const isPreviewMode = process.env.EXPO_PUBLIC_PREVIEW === '1';

export * from './fixtures';
export * as demo from './etat';
