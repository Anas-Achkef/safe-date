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

export function intervalleRafraichissement(statut: ConversationStatus): number {
  return statut === 'active' ? 3_000 : 10_000;
}

export function restantSecondes(
  serveur: number | null,
  recuA: number,
  maintenant: number,
): number | null {
  if (serveur === null) return null;
  return Math.max(0, serveur - Math.floor((maintenant - recuA) / 1000));
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
