import { signPhotoPaths } from '../lib/storage';
import { supabase } from '../lib/supabase';
import type { CandidateCardRow, CandidateHighlight } from '../types/rpc';
import { toApiError } from './errors';

/**
 * Raison pour laquelle le detail d'un profil n'est pas affichable.
 *
 * - `premium`   : au-dela du seuil, l'utilisateur n'est pas abonne. Le
 *                 back-end renvoie alors prenom, photo et scores a `null`.
 * - `filters`   : les filtres absolus (age, distance) ne sont pas satisfaits.
 * - `no_data`   : aucun critere commun evalue.
 * - `unreadable`: cas residuel.
 */
export type HiddenReason = 'premium' | 'filters' | 'no_data' | 'unreadable';

export interface DiscoveryEntry extends CandidateCardRow {
  visible: boolean;
  hiddenReason: HiddenReason | null;
}

/** Postgres renvoie des `numeric` : on normalise sans ecraser les `null`. */
function num(value: number | null | undefined): number | null {
  if (value === null || value === undefined) return null;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

/**
 * Les highlights arrivent en `jsonb`. Le pilote les livre deja decodes, mais
 * on ne fait aucune hypothese sur leur forme : une entree mal formee est
 * ecartee plutot que de faire tomber l'ecran.
 */
function parseHighlights(raw: unknown): CandidateHighlight[] {
  const list = typeof raw === 'string' ? safeParse(raw) : raw;
  if (!Array.isArray(list)) return [];

  return list.flatMap((item) => {
    if (typeof item !== 'object' || item === null) return [];
    const { groupe, question, reponse } = item as Record<string, unknown>;
    if (typeof question !== 'string' || typeof reponse !== 'string') return [];
    return [
      {
        groupe: (groupe as CandidateHighlight['groupe']) ?? 'valeurs',
        question,
        reponse,
      },
    ];
  });
}

function safeParse(raw: string): unknown {
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function classify(row: CandidateCardRow): {
  visible: boolean;
  hiddenReason: HiddenReason | null;
} {
  if (row.affichable) return { visible: true, hiddenReason: null };
  if (row.au_dela_du_seuil) return { visible: false, hiddenReason: 'premium' };
  if (!row.filtres_ok) return { visible: false, hiddenReason: 'filters' };
  if (!row.criteres_evalues) return { visible: false, hiddenReason: 'no_data' };
  return { visible: false, hiddenReason: 'unreadable' };
}

/**
 * Charge la liste de decouverte.
 *
 * Un seul appel RPC rapporte identite, scores, reciprocite et les trois
 * criteres qui expliquent le score. Le voile premium est decide en base : ici
 * on se contente de constater les champs absents.
 */
export async function loadDiscoveryFeed(): Promise<DiscoveryEntry[]> {
  const { data, error } = await supabase.rpc('candidate_cards');
  if (error) throw toApiError(error, 'Chargement des profils');

  const rows = (data ?? []) as CandidateCardRow[];

  const entries: DiscoveryEntry[] = rows.map((row) => {
    const normalised: CandidateCardRow = {
      candidate_id: row.candidate_id,
      prenom: row.prenom ?? null,
      age: num(row.age),
      photo: row.photo ?? null,
      verifie: row.verifie === true,
      score_global: num(row.score_global),
      score_physique: num(row.score_physique),
      score_valeurs: num(row.score_valeurs),
      score_mode_vie: num(row.score_mode_vie),
      score_aller: num(row.score_aller),
      score_retour: num(row.score_retour),
      criteres_evalues: num(row.criteres_evalues),
      filtres_ok: row.filtres_ok === true,
      affichable: row.affichable === true,
      au_dela_du_seuil: row.au_dela_du_seuil === true,
      highlights: parseHighlights(row.highlights),
    };
    return { ...normalised, ...classify(normalised) };
  });

  // `candidate_cards.photo` renvoie un chemin de stockage, pas une URL : il
  // faut le signer avant de pouvoir l'afficher. Un chemin qui ne se signe pas
  // redevient `null`, et la carte retombe sur son visuel de substitution.
  const signed = await signPhotoPaths(
    entries.map((entry) => entry.photo).filter((path): path is string => Boolean(path)),
  );
  for (const entry of entries) {
    entry.photo = entry.photo ? (signed.get(entry.photo) ?? null) : null;
  }

  // Profils lisibles d'abord, puis par compatibilite decroissante. Un score
  // absent passe systematiquement en fin de liste.
  return entries.sort((a, b) => {
    if (a.visible !== b.visible) return a.visible ? -1 : 1;
    return (b.score_global ?? -1) - (a.score_global ?? -1);
  });
}
