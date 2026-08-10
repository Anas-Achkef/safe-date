import { supabase } from '../lib/supabase';
import { toApiError } from './errors';

/**
 * Decisions prises sur les profils.
 *
 * `swipe_decisions` est ecrivable directement par son proprietaire — sa policy
 * est `ALL ... with check (user_id = auth.uid())` — il n'y a donc pas de RPC a
 * passer ici, contrairement au reste du back-end.
 *
 * A noter : `candidate_cards` ne filtre pas les profils deja traites. Sans le
 * filtrage applique ci-dessous, un profil ecarte reviendrait au rechargement
 * suivant.
 */

export interface DecisionInput {
  targetId: string;
  /** Vrai pour « ça m'intéresse », faux pour « passer ». */
  interested: boolean;
  /** Marque un interet appuye. Reserve a un usage ulterieur. */
  strongSignal?: boolean;
  /** Temps passe sur le profil, en millisecondes. */
  durationMs?: number;
}

/** Identifiants des profils sur lesquels l'utilisateur s'est deja prononce. */
export async function fetchDecidedIds(): Promise<Set<string>> {
  const { data, error } = await supabase.from('swipe_decisions').select('target_id');
  if (error) throw toApiError(error, 'Lecture de vos choix');
  return new Set((data ?? []).map((row) => row.target_id as string));
}

export async function recordDecision(input: DecisionInput): Promise<void> {
  const { data: session } = await supabase.auth.getSession();
  const userId = session.session?.user.id;
  if (!userId) throw toApiError(new Error('Authentification requise'), 'Enregistrement du choix');

  const { error } = await supabase.from('swipe_decisions').insert({
    user_id: userId,
    target_id: input.targetId,
    decision: input.interested,
    signal_fort: input.strongSignal ?? false,
    ecran: 'decouverte',
    duree_ms: input.durationMs ?? null,
  });

  if (error) throw toApiError(error, 'Enregistrement du choix');
}
