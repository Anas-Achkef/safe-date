import { demo, isPreviewMode } from '../preview';
import { supabase } from '../lib/supabase';
import { toApiError } from './errors';
import { rpcAVenir } from './rpcAVenir';

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

/**
 * La personne visée s'était-elle déjà prononcée favorablement ?
 *
 * Appelée juste après un « Ça m'intéresse » : si les deux sens existent, les
 * deux se sont choisis et l'application montre le coup de cœur réciproque.
 *
 * La fonction n'existe pas encore en base — voir `db/004-reciprocite.sql`.
 * Tant qu'elle est absente, `rpcAVenir` rend `null` et la réponse est « pas de
 * réciprocité » : l'écran de découverte enchaîne alors sur le profil suivant,
 * ce qui est exactement le comportement actuel. Rien ne casse en attendant.
 *
 * On ne lit pas `swipe_decisions` directement pour cela : sa policy ne montre
 * que ses propres lignes, et c'est délibéré — savoir qui s'est prononcé sur
 * vous ne doit sortir que lorsque la réciprocité est acquise des deux côtés.
 */
export async function reciprociteAvec(targetId: string): Promise<boolean> {
  if (isPreviewMode) return demo.reciprocite(targetId);

  const lignes = await rpcAVenir<{ reciproque: boolean }>('reciprocite_avec', {
    cible: targetId,
  });
  return lignes?.[0]?.reciproque === true;
}
