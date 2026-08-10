import { supabase } from '../lib/supabase';
import type { CollectionMoment, SensitiveCategory } from '../types/rpc';
import { toApiError } from './errors';

/**
 * Le questionnaire.
 *
 * `criteria` et `criterion_options` sont lisibles directement par un compte
 * authentifie ; `profile_answers` est en select seul, et toute ecriture passe
 * par `submit_answer`. Un declencheur recalcule les vecteurs a chaque reponse :
 * modifier une reponse suffit a faire bouger tous les scores.
 */

export interface QuestionOption {
  idx: number;
  label: string;
}

export interface QuestionnaireItem {
  key: string;
  question: string;
  multiSelect: boolean;
  moment: CollectionMoment;
  category: string;
  subcategory: string;
  sensitiveCategory: SensitiveCategory | null;
  options: QuestionOption[];
  /** Indices actuellement enregistres, `null` si le critere n'a pas ete traite. */
  answer: number[] | null;
}

interface CriteriaRow {
  key: string;
  ord: number;
  question: string;
  multi_select: boolean;
  moment: CollectionMoment;
  category: string;
  subcategory: string;
  sensitive_category: SensitiveCategory | null;
}

/**
 * Charge le questionnaire complet, options et reponses comprises.
 *
 * Les criteres `backend` sont ecartes : ils sont calcules, jamais demandes.
 * L'ordre reprend celui du back-end — inscription d'abord, puis quiz.
 */
export async function loadQuestionnaire(): Promise<QuestionnaireItem[]> {
  const [criteria, options, answers] = await Promise.all([
    supabase
      .from('criteria')
      .select('key, ord, question, multi_select, moment, category, subcategory, sensitive_category')
      .neq('moment', 'backend')
      .order('ord'),
    supabase.from('criterion_options').select('criterion_key, idx, label').order('idx'),
    supabase.from('profile_answers').select('criterion_key, option_idx'),
  ]);

  if (criteria.error) throw toApiError(criteria.error, 'Chargement des questions');
  if (options.error) throw toApiError(options.error, 'Chargement des options');
  if (answers.error) throw toApiError(answers.error, 'Chargement de vos reponses');

  const optionsByKey = new Map<string, QuestionOption[]>();
  for (const row of options.data ?? []) {
    const list = optionsByKey.get(row.criterion_key) ?? [];
    list.push({ idx: Number(row.idx), label: row.label });
    optionsByKey.set(row.criterion_key, list);
  }

  const answersByKey = new Map<string, number[]>();
  for (const row of answers.data ?? []) {
    answersByKey.set(row.criterion_key, (row.option_idx ?? []).map(Number));
  }

  const rows = (criteria.data ?? []) as CriteriaRow[];

  return rows
    .map((row) => ({
      key: row.key,
      question: row.question,
      multiSelect: row.multi_select === true,
      moment: row.moment,
      category: row.category,
      subcategory: row.subcategory,
      sensitiveCategory: row.sensitive_category,
      options: optionsByKey.get(row.key) ?? [],
      answer: answersByKey.get(row.key) ?? null,
    }))
    // Un critere sans option ne peut pas etre pose : on ne l'affiche pas.
    .filter((item) => item.options.length > 0)
    .sort((a, b) => {
      // L'inscription passe avant le quiz, l'ordre du back-end fait foi ensuite.
      const rank = (moment: CollectionMoment) => (moment === 'onboarding' ? 0 : 1);
      return rank(a.moment) - rank(b.moment);
    });
}

/**
 * Enregistre une reponse.
 *
 * Le back-end fait un upsert : reposter un critere deja traite remplace la
 * reponse precedente et declenche le recalcul des vecteurs. Il valide aussi
 * les bornes et le caractere unique ou multiple du choix, et refuse un critere
 * sensible dont le consentement n'a pas ete accorde.
 */
export async function submitAnswer(criterionKey: string, optionIndexes: number[]): Promise<void> {
  const { error } = await supabase.rpc('submit_answer', {
    k: criterionKey,
    idx: optionIndexes,
  });
  if (error) throw toApiError(error, 'Enregistrement de la reponse');
}
