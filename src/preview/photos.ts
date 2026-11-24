import { attributsDemo } from './attributs';

/**
 * Les photographies de la démonstration.
 *
 * ⚠ USAGE STRICTEMENT INTERNE. Ce sont des portraits de personnes réelles
 * servis par une banque d'images de substitution. Ils conviennent à une
 * maquette montrée à un client ; ils ne doivent apparaître ni dans une version
 * publiée, ni dans une capture de la fiche App Store ou Play Store. Un visage
 * emprunté et posé sur un profil de rencontre engage le droit à l'image de la
 * personne, qui n'a évidemment pas consenti à figurer là.
 *
 * Le module ne sert qu'en mode démonstration. En conditions réelles les photos
 * viennent de `user_photos`, signées par `signPhotoPaths`.
 *
 * La banque n'expose que du 256 × 256 : agrandie sur une carte de découverte,
 * l'image est un peu douce. Le voile dégradé posé par `PhotoCard` l'absorbe,
 * et le sujet est de toute façon provisoire.
 */

/** Nombre de portraits disponibles par genre chez le fournisseur. */
const DISPONIBLES = 78;

function graine(id: string): number {
  let h = 2_166_136_261;
  for (let i = 0; i < id.length; i += 1) {
    h ^= id.charCodeAt(i);
    h = Math.imul(h, 16_777_619) >>> 0;
  }
  return h;
}

/**
 * La photo d'un profil de démonstration.
 *
 * Le genre suit celui déclaré dans `attributs.ts` : un prénom masculin sur un
 * portrait féminin ruinerait la crédibilité de la maquette avant même qu'on
 * regarde le reste. Les profils non binaires piochent dans les deux jeux.
 */
export function photoDemo(id: string): string {
  const a = attributsDemo(id);
  const h = graine(id);
  const dossier =
    a?.genre === 'homme'
      ? 'male'
      : a?.genre === 'femme'
        ? 'female'
        : h % 2 === 0
          ? 'male'
          : 'female';

  return `https://xsgames.co/randomusers/assets/avatars/${dossier}/${h % DISPONIBLES}.jpg`;
}
