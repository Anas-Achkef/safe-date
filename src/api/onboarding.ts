import { supabase } from '../lib/supabase';
import type {
  ActivationChecklistItem,
  AnswerProgress,
  ConsentementRequis,
  NextQuestion,
  UserProgress,
} from '../types/rpc';
import { toApiError } from './errors';

/**
 * Parcours d'inscription en 9 etapes.
 *
 * Toutes les ecritures passent par des RPC : les tables sous-jacentes
 * (`profile_answers` en particulier) sont en select seul.
 */

/** Etape 1 — verification du code de compte. */
export async function verifyAccountCode(code: string): Promise<boolean> {
  const { data, error } = await supabase.rpc('verify_account_code', { code });
  if (error) throw toApiError(error, 'Verification du code');
  return data === true;
}

/** Consentements a recueillir avant le questionnaire (donnees sensibles RGPD). */
export async function fetchRequiredConsents(): Promise<ConsentementRequis[]> {
  const { data, error } = await supabase.rpc('consentements_requis_questionnaire');
  if (error) throw toApiError(error, 'Consentements requis');
  return (data ?? []) as ConsentementRequis[];
}

/** Prochaines questions a poser. Le back-end choisit selon sa propre priorite. */
export async function fetchNextQuestions(n = 3): Promise<NextQuestion[]> {
  const { data, error } = await supabase.rpc('next_questions', { n });
  if (error) throw toApiError(error, 'Questions suivantes');
  return ((data ?? []) as NextQuestion[]).map((q) => ({
    ...q,
    priorite: Number(q.priorite),
  }));
}

/**
 * Enregistre une reponse.
 *
 * `idx` est un tableau d'indices d'options (smallint[]), meme pour une reponse
 * unique. Seule voie d'ecriture : un insert direct dans `profile_answers`
 * echoue sur la RLS.
 */
export async function submitAnswer(criterionKey: string, optionIndexes: number[]): Promise<void> {
  const { error } = await supabase.rpc('submit_answer', { k: criterionKey, idx: optionIndexes });
  if (error) throw toApiError(error, 'Enregistrement de la reponse');
}

export async function fetchAnswerProgress(): Promise<AnswerProgress | null> {
  const { data, error } = await supabase.rpc('answer_progress');
  if (error) throw toApiError(error, 'Avancement des reponses');
  const rows = (data ?? []) as AnswerProgress[];
  return rows[0] ?? null;
}

export async function completeQuestionnaireStep(): Promise<void> {
  const { error } = await supabase.rpc('complete_questionnaire_step');
  if (error) throw toApiError(error, 'Validation du questionnaire');
}

export async function fetchActivationChecklist(): Promise<ActivationChecklistItem[]> {
  const { data, error } = await supabase.rpc('user_activation_checklist');
  if (error) throw toApiError(error, 'Checklist d’activation');
  return (data ?? []) as ActivationChecklistItem[];
}

export async function activateUser(): Promise<void> {
  const { error } = await supabase.rpc('activate_user');
  if (error) throw toApiError(error, 'Activation du compte');
}

export async function setGeolocationChoice(
  autorise: boolean,
  precise: boolean,
  policyCode: string,
  policyVersion: string,
): Promise<void> {
  const { error } = await supabase.rpc('set_geolocation_choice', {
    autorise,
    precise,
    p_code: policyCode,
    p_version: policyVersion,
  });
  if (error) throw toApiError(error, 'Choix de geolocalisation');
}

/**
 * Etat d'avancement global, utilise pour l'aiguillage de navigation.
 *
 * Renvoie `null` quand l'utilisateur authentifie n'a pas encore de ligne dans
 * `profiles` : il n'existe aucun declencheur sur `auth.users`, donc un compte
 * fraichement cree se trouve dans cet etat.
 */
export async function fetchUserProgress(): Promise<UserProgress | null> {
  const { data, error } = await supabase.rpc('user_progress');
  if (error) throw toApiError(error, 'Avancement du compte');
  const rows = (data ?? []) as UserProgress[];
  return rows[0] ?? null;
}
