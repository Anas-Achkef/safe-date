import { supabase } from '../lib/supabase';
import { toApiError } from './errors';

/**
 * Documents contractuels et acceptations.
 *
 * `policy_documents` est lisible par tous ; `user_acceptances` est ecrivable
 * directement par son proprietaire. La cle primaire est
 * `(user_id, policy_code)` et une cle etrangere lie `(policy_code,
 * policy_version)` au document : accepter une nouvelle version remplace donc
 * l'acceptation precedente plutot que d'en creer une seconde.
 */

export interface PolicyDocument {
  code: string;
  version: string;
  body: string;
  publishedAt: string;
}

/** Libelles d'affichage. Les codes viennent de la base, pas les titres. */
const POLICY_LABELS: Record<string, string> = {
  cgu: 'Conditions générales d’utilisation',
  confidentialite: 'Politique de confidentialité',
  donnees_personnelles: 'Traitement des données personnelles',
};

export function policyLabel(code: string): string {
  return POLICY_LABELS[code] ?? code;
}

/** Documents actuellement en vigueur. */
export async function fetchPolicyDocuments(): Promise<PolicyDocument[]> {
  const { data, error } = await supabase
    .from('policy_documents')
    .select('code, version, body, published_at')
    .eq('is_current', true)
    .order('code');

  if (error) throw toApiError(error, 'Chargement des documents');

  return (data ?? []).map((row) => ({
    code: row.code as string,
    version: row.version as string,
    body: (row.body as string) ?? '',
    publishedAt: row.published_at as string,
  }));
}

/** Versions acceptees, par code de document. */
export async function fetchMyAcceptances(): Promise<Map<string, string>> {
  const { data, error } = await supabase
    .from('user_acceptances')
    .select('policy_code, policy_version');

  if (error) throw toApiError(error, 'Chargement de vos acceptations');

  const map = new Map<string, string>();
  for (const row of data ?? []) {
    map.set(row.policy_code as string, row.policy_version as string);
  }
  return map;
}

export async function acceptPolicy(code: string, version: string): Promise<void> {
  const { data: session } = await supabase.auth.getSession();
  const userId = session.session?.user.id;
  if (!userId) throw toApiError(new Error('Authentification requise'), 'Acceptation');

  const { error } = await supabase
    .from('user_acceptances')
    .upsert(
      { user_id: userId, policy_code: code, policy_version: version },
      { onConflict: 'user_id,policy_code' },
    );

  if (error) throw toApiError(error, 'Acceptation du document');
}
