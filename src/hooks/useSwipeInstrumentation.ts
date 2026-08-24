import { useCallback, useEffect, useRef } from 'react';
import { AppState, type AppStateStatus } from 'react-native';

/**
 * Mesure brute de la consultation d'un profil.
 *
 * Ce hook ne calcule AUCUN champ dérivé : ni attention_*, ni
 * fiabilite_attention, ni vitesse_ms_page, ni erreur_prediction.
 * Ces valeurs dépendent de engine_params et sont produites par la
 * RPC enregistrer_swipe. Les recalculer ici imposerait une release
 * à chaque retouche de pondération et rendrait incomparables les
 * swipes d'avant et d'après.
 */

export type ScoreGroup = 'physique' | 'valeurs' | 'mode_vie';
export type Contexte = 'mieux_me_connaitre' | 'partir_en_date';
export type TypeRencontre = 'amour' | 'amitie' | 'fun';

export type EcranMesure = {
  ecran: ScoreGroup;
  duree_ms: number;
  consultations: number;
};

export type SwipePayload = {
  p_presentation_id: number;
  p_target_id: string;
  p_contexte: Contexte;
  p_decision: boolean;
  p_signal_fort: boolean;
  p_type_rencontre: TypeRencontre | null;
  p_score_predit: number | null;
  p_seuil_predit: number | null;
  p_ordre_consultation: ScoreGroup[];
  p_ecrans: EcranMesure[];
  p_criteres_exposes: string[];
  p_criteres_consultes: string[];
  p_snapshot: unknown;
};

type Options = {
  /** id de la ligne profile_presentations servie pour ce profil. */
  presentationId: number;
  targetId: string;
  contexte: Contexte;
  /** ordre_pages tel que décidé par le moteur, jamais réordonné côté client. */
  ordrePages: ScoreGroup[];
  /** criteres de la présentation, par page. */
  criteresParPage: Partial<Record<ScoreGroup, string[]>>;
  /** Nul en apprentissage : Mieux me connaître ignore ce que l'utilisateur cherche. */
  typeRencontre?: TypeRencontre | null;
  scorePredit?: number | null;
  seuilPredit?: number | null;
  snapshot?: unknown;
};

export function useSwipeInstrumentation(opts: Options) {
  const {
    presentationId,
    targetId,
    contexte,
    ordrePages,
    criteresParPage,
    typeRencontre = null,
    scorePredit = null,
    seuilPredit = null,
    snapshot = null,
  } = opts;

  // Refs uniquement : la mesure ne doit jamais provoquer de rendu,
  // sinon elle modifie la durée qu'elle prétend observer.
  const durees = useRef<Partial<Record<ScoreGroup, number>>>({});
  const consultations = useRef<Partial<Record<ScoreGroup, number>>>({});
  const ordre = useRef<ScoreGroup[]>([]);
  const consultes = useRef<Set<string>>(new Set());
  const courante = useRef<ScoreGroup | null>(null);
  const debutPage = useRef<number>(0);
  const enPause = useRef<boolean>(false);

  /* -------- Remise à zéro à chaque nouveau profil -------- */
  useEffect(() => {
    durees.current = {};
    consultations.current = {};
    ordre.current = [];
    consultes.current = new Set();
    courante.current = null;
    debutPage.current = 0;
    enPause.current = false;
  }, [presentationId]);

  /* -------- Le temps en arrière-plan n'est pas du temps de lecture -------- */
  const cloreSegment = useCallback(() => {
    const sec = courante.current;
    if (!sec || enPause.current || !debutPage.current) return;
    durees.current[sec] = (durees.current[sec] ?? 0) + (Date.now() - debutPage.current);
    debutPage.current = 0;
  }, []);

  useEffect(() => {
    const onChange = (state: AppStateStatus) => {
      if (state === 'active') {
        if (enPause.current && courante.current) {
          enPause.current = false;
          debutPage.current = Date.now();
        }
      } else {
        cloreSegment();
        enPause.current = true;
      }
    };
    const sub = AppState.addEventListener('change', onChange);
    return () => sub.remove();
  }, [cloreSegment]);

  /* -------- API -------- */

  /** À appeler dès qu'une page devient visible. Idempotent. */
  const entrerPage = useCallback((sec: ScoreGroup) => {
    if (courante.current === sec) return;
    cloreSegment();
    courante.current = sec;
    debutPage.current = Date.now();
    enPause.current = false;
    consultations.current[sec] = (consultations.current[sec] ?? 0) + 1;
    if (!ordre.current.includes(sec)) ordre.current.push(sec);
    // Une page ouverte vaut consultation de ses critères. Affiner via
    // noterCritereConsulte si un jour tu mesures la visibilité réelle.
    (criteresParPage[sec] ?? []).forEach(k => consultes.current.add(k));
  }, [cloreSegment, criteresParPage]);

  /** Optionnel : marquage plus fin qu'à la page. */
  const noterCritereConsulte = useCallback((key: string) => {
    consultes.current.add(key);
  }, []);

  /**
   * Produit le payload au moment de la décision.
   * decision : true = oui, false = non.
   */
  const construire = useCallback(
    (decision: boolean, o?: { signalFort?: boolean }): SwipePayload => {
      cloreSegment();

      const exposes = ordrePages.flatMap(p => criteresParPage[p] ?? []);

      const ecrans: EcranMesure[] = ordre.current.map(sec => ({
        ecran: sec,
        duree_ms: Math.round(durees.current[sec] ?? 0),
        consultations: consultations.current[sec] ?? 1,
      }));

      return {
        p_presentation_id: presentationId,
        p_target_id: targetId,
        p_contexte: contexte,
        p_decision: decision,
        p_signal_fort: o?.signalFort ?? false,
        p_type_rencontre: contexte === 'mieux_me_connaitre' ? null : typeRencontre,
        p_score_predit: scorePredit,
        p_seuil_predit: seuilPredit,
        p_ordre_consultation: [...ordre.current],
        p_ecrans: ecrans,
        p_criteres_exposes: exposes,
        p_criteres_consultes: [...consultes.current],
        p_snapshot: snapshot,
      };
    },
    [
      cloreSegment, presentationId, targetId, contexte, ordrePages,
      criteresParPage, typeRencontre, scorePredit, seuilPredit, snapshot,
    ],
  );

  return { entrerPage, noterCritereConsulte, construire };
}
