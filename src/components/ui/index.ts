/**
 * Les composants du système de design.
 *
 * Chacun correspond à un node du fichier Figma et n'existe que sous les
 * variantes qui y figurent. Ajouter une variante ici sans l'ajouter là-bas
 * fait diverger les deux en silence : c'est le fichier Figma qui décide.
 */

export { Badge, type TypeBadge } from './Badge';
export { BarreOnglets, ONGLETS, type OngletId } from './BarreOnglets';
export { Bouton, type VarianteBouton } from './Bouton';
export { BoutonRond } from './BoutonRond';
export { CarteDimension } from './CarteDimension';
export { CarteEnCommun } from './CarteEnCommun';
export { CartePhoto } from './CartePhoto';
export { CarteAffinite, VignetteProfil } from './CarteProfil';
export { Chip } from './Chip';
export { Curseur, CurseurFourchette } from './Curseur';
export { Halo } from './Halo';
export { IndicateurPhotos } from './IndicateurPhotos';
export { Interrupteur } from './Interrupteur';
export { LueurImmersive } from './LueurImmersive';
export {
  IconeCadenas,
  IconeCoeur,
  IconeCoeurPlein,
  IconeDecouverte,
  IconeDiscussions,
  IconeFermer,
  IconeFiltres,
  IconeHorloge,
  IconeParcourir,
  IconePhoto,
  IconePremium,
  IconeProfil,
  IconeRendezVous,
  IconeRetour,
  IconeValider,
  IconeVerifie,
} from './Icones';
export { LogoHorizontal, LogoSymbole, LogoSymboleBlanc } from './Logo';
