import { ecrire, lire } from '../lib/stockage';
import { supabase } from '../lib/supabase';
import { isPreviewMode } from '../preview';
import { rpcAVenir } from './rpcAVenir';

const CLE = 'abonnement';

export interface Abonnement {
  actif: boolean;
  /** Identifiant de la formule achetée, tel que déclaré aux boutiques. */
  formule: string | null;
  /** Fin de la période payée, au format ISO. */
  expire_le: string | null;
}

export const SANS_ABONNEMENT: Abonnement = { actif: false, formule: null, expire_le: null };

/**
 * L'état d'abonnement.
 *
 * La source de vérité est `profiles.is_premium`, que `profile_header()` expose
 * déjà sous le nom `est_premium` : elle est en base, elle n'est pas
 * modifiable par le client, et elle vaut donc quoi qu'il arrive plus que le
 * booléen local.
 *
 * Ce que le back-end ne dit pas encore : la formule souscrite et l'échéance.
 * Il n'existe aucune table d'abonnements — voir `db/003-abonnements.sql`.
 * Le stockage local ne sert qu'à ces deux champs d'affichage, et de relais
 * hors ligne.
 */
export async function chargerAbonnement(): Promise<Abonnement> {
  const local = await lire<Abonnement>(CLE, SANS_ABONNEMENT);
  if (isPreviewMode) return local;

  try {
    const { data, error } = await supabase.rpc('profile_header');
    if (error) throw error;

    const entete = (data ?? [])[0];
    if (entete) {
      // Le serveur tranche sur l'actif ; le local ne complète que le décor.
      const a: Abonnement = {
        actif: entete.est_premium === true,
        formule: entete.est_premium ? local.formule : null,
        expire_le: entete.est_premium ? local.expire_le : null,
      };
      await ecrire(CLE, a);
      return a;
    }
  } catch {
    // Hors ligne ou session absente : on se rabat sur le dernier état connu.
  }

  return local;
}

/**
 * Enregistre un abonnement pris.
 *
 * Sur téléphone, cette fonction doit être appelée APRÈS un achat validé par
 * l'App Store ou Google Play, jamais à la place. Les abonnements numériques
 * passent obligatoirement par leurs achats intégrés : une application qui
 * encaisse autrement est refusée à la revue.
 *
 * Elle n'écrit pas `profiles.is_premium` : cette colonne ne doit basculer que
 * sur un reçu vérifié côté serveur. Tant que la RPC n'existe pas, l'effet est
 * local et disparaîtra au prochain `profile_header()` — c'est voulu, un
 * abonnement que le client s'accorde à lui-même n'en est pas un.
 */
export async function enregistrerAbonnement(formule: string): Promise<Abonnement> {
  const a: Abonnement = { actif: true, formule, expire_le: null };
  await ecrire(CLE, a);
  try {
    await rpcAVenir('enregistrer_abonnement', { formule });
  } catch {
    // Le reçu fera foi côté serveur ; l'appareil n'est qu'un cache.
  }
  return a;
}

export async function oublierAbonnement(): Promise<void> {
  await ecrire(CLE, SANS_ABONNEMENT);
}
