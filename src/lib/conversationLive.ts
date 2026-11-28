import type { ConversationStatus, Message } from '../types/conversations';

/**
 * Temps et etapes d'une conversation de 5 minutes.
 *
 * Module pur, sans dependance d'execution : il est teste par `node --test`.
 * Le temps restant vient toujours du serveur ; on ne fait que le decompter
 * entre deux lectures, et chaque lecture le resynchronise.
 */

export type EtapeConversation =
  | 'attente'
  | 'decompte'
  | 'active'
  | 'temps_ecoule'
  | 'decision_envoyee'
  | 'illimitee'
  | 'close';

/** Le serveur ne compte une presence que 45 s : on la renouvelle bien avant. */
export const INTERVALLE_PRESENCE_MS = 15_000;

/**
 * Plus frequent pendant les 5 minutes, et des que l'autre est la : c'est le
 * moment ou le chrono peut partir, et la personne qui attendait doit le voir
 * aussitot.
 */
export function intervalleRafraichissement(
  statut: ConversationStatus,
  autreEnLigne = false,
): number {
  return statut === 'active' || (statut === 'prete' && autreEnLigne) ? 3_000 : 10_000;
}

export function restantSecondes(
  serveur: number | null,
  recuA: number,
  maintenant: number,
): number | null {
  if (serveur === null) return null;
  // Une lecture peut arriver juste avant le tic d'affichage : le temps ecoule
  // ne devient jamais negatif, sinon le chrono remonterait d'une seconde.
  const ecoule = Math.max(0, maintenant - recuA);
  return Math.max(0, serveur - Math.floor(ecoule / 1000));
}

export function formaterChrono(secondes: number): string {
  const s = Math.max(0, Math.floor(secondes));
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;
}

export function etapeDe(
  e: {
    statut: ConversationStatus;
    illimitee: boolean;
    restant: number | null;
    decompteJusqua: number | null;
    decisionEnvoyee: boolean;
  },
  maintenant: number,
): EtapeConversation {
  if (e.illimitee) return 'illimitee';
  if (e.statut === 'cloturee') return 'close';
  if (e.decisionEnvoyee) return 'decision_envoyee';
  // Le verrouillage serveur peut arriver jusqu'a 60 s apres la fin :
  // a 0, le temps est ecoule pour l'ecran sans attendre le statut.
  if (e.statut === 'verrouillee' || (e.statut === 'active' && e.restant === 0)) {
    return 'temps_ecoule';
  }
  if (e.decompteJusqua !== null && maintenant < e.decompteJusqua) return 'decompte';
  if (e.statut === 'active') return 'active';
  return 'attente';
}

/** Deux lectures qui se chevauchent ne doivent jamais dupliquer une bulle. */
export function fusionnerMessages(actuels: Message[], nouveaux: Message[]): Message[] {
  if (nouveaux.length === 0) return actuels;
  const parId = new Map<string, Message>();
  for (const m of actuels) parId.set(m.id, m);
  for (const m of nouveaux) parId.set(m.id, m);
  return [...parId.values()].sort((a, b) => a.created_at.localeCompare(b.created_at));
}

/** Duree des 5 minutes cote serveur (`conversation_duree_s`). */
export const DUREE_CONVERSATION_S = 300;

/**
 * Fin du decompte 3, 2, 1, deduite du temps servi par le serveur.
 *
 * Le serveur fait partir les 5 minutes quelques secondes apres le demarrage :
 * tant qu'il reste plus de 300 s, on est dans le decompte. C'est ce qui donne
 * le meme 3, 2, 1 aux deux personnes, y compris a celle qui attendait.
 */
export function decompteDepuisServeur(secondes: number | null, recuA: number): number | null {
  if (secondes === null || secondes <= DUREE_CONVERSATION_S) return null;
  return recuA + (secondes - DUREE_CONVERSATION_S) * 1000;
}
