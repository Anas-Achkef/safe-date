import type { ScoreGroup } from '../types/rpc';

/**
 * Le jeu de personnes de la demonstration.
 *
 * Source unique : les ecrans Decouverte, Apprendre et Discussions derivent
 * tous de cette liste, si bien qu'un profil croise dans un onglet se retrouve
 * dans un autre avec le meme prenom, le meme age et le meme visuel.
 *
 * Les scores respectent la distribution reelle du moteur — de 32 a 77, mediane
 * autour de 49. Une demonstration bâtie sur des 90 % donnerait une fausse idee
 * de ce que l'application affiche au quotidien.
 *
 * Aucune photographie : chaque profil recoit un degrade derive de son
 * identifiant. Voir `src/components/Avatar.tsx`.
 */

export interface Personne {
  id: string;
  prenom: string;
  age: number;
  verifie: boolean;
  /** Score global, en pourcentage. */
  score: number;
  physique: number;
  valeurs: number;
  modeVie: number;
  aller: number;
  retour: number;
  criteres: number;
  /** Ce que le moteur a retenu, en phrases — jamais les questions brutes. */
  phrasesValeurs: string[];
  phrasesModeVie: string[];
  distance: string;
}

function p(
  id: string, prenom: string, age: number, verifie: boolean,
  score: number, physique: number, valeurs: number, modeVie: number,
  aller: number, retour: number, criteres: number,
  phrasesValeurs: string[], phrasesModeVie: string[], distance: string,
): Personne {
  return {
    id, prenom, age, verifie, score, physique, valeurs, modeVie,
    aller, retour, criteres, phrasesValeurs, phrasesModeVie, distance,
  };
}

export const PERSONNES: Personne[] = [
  p('a1000000-0000-4000-8000-000000000001', 'Camille', 33, true, 71.4, 68, 74, 72, 73.1, 69.7, 46,
    ['Accorde beaucoup d’importance à la loyauté', 'Préfère dire les choses franchement'],
    ['Cuisine presque tous les soirs', 'Se lève tôt, même le week-end'], 'à moins de 2 km'),
  p('a1000000-0000-4000-8000-000000000002', 'Théo', 28, true, 64.8, 59, 67, 68, 66.2, 63.4, 41,
    ['Attaché à l’indépendance de chacun', 'Peu porté sur les conventions'],
    ['Sort souvent en semaine', 'Économe sans être avare'], 'à moins de 5 km'),
  p('a1000000-0000-4000-8000-000000000003', 'Inès', 31, true, 58.2, 61, 55, 59, 60.4, 56.0, 44,
    ['Sensible à la justesse plus qu’à la performance', 'Curieuse des trajectoires différentes'],
    ['Voyage dès qu’elle le peut', 'Vit avec un chat'], 'à moins de 3 km'),
  p('a1000000-0000-4000-8000-000000000004', 'Marius', 35, false, 54.6, 49, 58, 56, 57.8, 51.4, 39,
    ['Tient à ses convictions sans les imposer', 'Prend le temps de décider'],
    ['Court trois fois par semaine', 'Ne regarde presque jamais la télévision'], 'à moins de 8 km'),
  p('a1000000-0000-4000-8000-000000000005', 'Léa', 29, true, 52.9, 57, 50, 51, 54.2, 51.6, 42,
    ['Recherche la douceur dans les rapports', 'N’aime pas les non-dits'],
    ['Lit beaucoup, tard le soir', 'Cuisine peu, sort souvent'], 'à moins de 4 km'),
  p('a1000000-0000-4000-8000-000000000006', 'Adrien', 37, true, 51.3, 44, 55, 54, 52.7, 49.9, 38,
    ['Pense que le respect prime sur l’accord', 'Aime les débats sans enjeu'],
    ['Bricole le week-end', 'Se couche tôt'], 'à moins de 6 km'),
  p('a1000000-0000-4000-8000-000000000007', 'Nour', 26, true, 49.7, 53, 47, 49, 51.0, 48.4, 40,
    ['Attentive aux autres, parfois trop', 'Déteste les rapports de force'],
    ['Danse depuis l’enfance', 'Végétarienne'], 'à moins de 2 km'),
  p('a1000000-0000-4000-8000-000000000008', 'Rémi', 34, false, 48.1, 46, 50, 48, 49.6, 46.6, 36,
    ['Fidèle en amitié comme ailleurs', 'Se méfie des grandes déclarations'],
    ['Joue de la guitare', 'Travaille souvent le soir'], 'à moins de 12 km'),
  p('a1000000-0000-4000-8000-000000000009', 'Salomé', 30, true, 46.5, 51, 44, 45, 48.0, 45.0, 43,
    ['Aime que les choses soient dites', 'Croit aux secondes chances'],
    ['Nage tous les matins', 'Peu portée sur les écrans'], 'à moins de 7 km'),
  p('a1000000-0000-4000-8000-00000000000b', 'Yanis', 32, true, 44.9, 40, 48, 46, 46.3, 43.5, 37,
    ['Discret sur ses convictions', 'Sensible à la générosité'],
    ['Fait du vélo pour tout', 'Cuisine le dimanche'], 'à moins de 5 km'),
  p('a1000000-0000-4000-8000-00000000000c', 'Jeanne', 38, true, 43.2, 47, 41, 42, 44.8, 41.6, 45,
    ['Ne supporte pas l’à-peu-près', 'Croit à l’effort partagé'],
    ['Jardine', 'Se lève très tôt'], 'à moins de 9 km'),
  p('a1000000-0000-4000-8000-00000000000d', 'Malo', 27, false, 41.8, 38, 44, 43, 43.1, 40.5, 34,
    ['Aime la spontanéité', 'Peu attaché aux traditions'],
    ['Sort le week-end', 'Dépensier assumé'], 'à moins de 3 km'),
  p('a1000000-0000-4000-8000-00000000000e', 'Aya', 25, true, 40.4, 44, 38, 39, 41.9, 38.9, 33,
    ['Franche, parfois trop', 'Attachée à sa famille'],
    ['Étudie encore', 'Ne boit pas'], 'à moins de 4 km'),
  p('a1000000-0000-4000-8000-00000000000f', 'Basile', 41, true, 38.7, 35, 41, 40, 40.2, 37.2, 41,
    ['Patient, presque trop', 'N’aime pas trancher vite'],
    ['Randonne beaucoup', 'Vit à la campagne'], 'à moins de 18 km'),
  p('a1000000-0000-4000-8000-000000000010', 'Elsa', 36, true, 36.9, 39, 35, 36, 38.4, 35.4, 38,
    ['Réservée au premier abord', 'Loyale une fois la confiance là'],
    ['Photographie', 'Se couche tard'], 'à moins de 6 km'),
  p('a1000000-0000-4000-8000-000000000011', 'Tom', 30, false, 34.2, 31, 36, 35, 35.6, 32.8, 32,
    ['Indépendant avant tout', 'Peu bavard sur lui-même'],
    ['Escalade', 'Mange souvent dehors'], 'à moins de 11 km'),
  p('a1000000-0000-4000-8000-000000000012', 'Farah', 34, true, 32.5, 36, 30, 32, 33.9, 31.1, 35,
    ['Attachée aux rituels', 'Sensible aux petites attentions'],
    ['Chante en chorale', 'Ne conduit pas'], 'à moins de 5 km'),
  p('a1000000-0000-4000-8000-000000000013', 'Gaspard', 39, true, 76.8, 74, 79, 77, 78.2, 75.4, 48,
    ['Place l’honnêteté au-dessus du reste', 'Aime construire dans la durée'],
    ['Cuisine pour les autres', 'Marche partout'], 'à moins de 1 km'),
  p('a1000000-0000-4000-8000-000000000014', 'Lou', 28, true, 68.3, 65, 71, 69, 70.1, 66.5, 45,
    ['Directe et chaleureuse', 'Ne garde pas rancune'],
    ['Fait du théâtre', 'Se lève tôt'], 'à moins de 2 km'),
  p('a1000000-0000-4000-8000-000000000015', 'Sacha', 33, true, 61.5, 58, 64, 62, 63.0, 60.0, 43,
    ['Tient à l’équilibre entre les deux', 'Curieux de tout'],
    ['Cuisine mal mais essaie', 'Voyage léger'], 'à moins de 4 km'),
  p('a1000000-0000-4000-8000-000000000016', 'Manon', 31, false, 56.7, 60, 54, 56, 58.1, 55.3, 40,
    ['Sensible aux silences', 'N’aime pas les promesses vagues'],
    ['Peint le week-end', 'Se couche tôt'], 'à moins de 7 km'),
  p('a1000000-0000-4000-8000-000000000017', 'Nathan', 29, true, 50.8, 48, 53, 51, 52.4, 49.2, 39,
    ['Fiable, sans en faire une vertu', 'Aime écouter'],
    ['Joue au foot le samedi', 'Cuisine tous les jours'], 'à moins de 3 km'),
  p('a1000000-0000-4000-8000-000000000018', 'Chloé', 27, true, 45.6, 49, 43, 45, 47.0, 44.2, 37,
    ['Franche sans être brusque', 'Attachée à ses amis'],
    ['Fait du yoga', 'Sort peu en semaine'], 'à moins de 6 km'),
  p('a1000000-0000-4000-8000-000000000019', 'Victor', 42, true, 39.4, 37, 41, 40, 40.8, 38.0, 42,
    ['Prudent dans ses engagements', 'Tient parole'],
    ['Pêche', 'Vit seul depuis longtemps'], 'à moins de 15 km'),
];

/** Ordre des pages, varié pour montrer que le moteur choisit. */
export const ORDRES_PAGES: ScoreGroup[][] = [
  ['physique', 'valeurs', 'mode_vie'],
  ['valeurs', 'physique', 'mode_vie'],
  ['mode_vie', 'valeurs', 'physique'],
  ['valeurs', 'mode_vie', 'physique'],
];
