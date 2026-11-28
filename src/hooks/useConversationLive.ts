import { useFocusEffect } from 'expo-router';
import { useCallback, useEffect, useRef, useState } from 'react';
import { AppState } from 'react-native';

import {
  decideConversation,
  joinConversation,
  loadConversationState,
  loadMessages,
  sendMessage,
} from '../api/conversations';
import { userFacingMessage } from '../api/errors';
import {
  etapeDe,
  fusionnerMessages,
  INTERVALLE_PRESENCE_MS,
  intervalleRafraichissement,
  restantSecondes,
  type EtapeConversation,
} from '../lib/conversationLive';
import type { EtatConversation, Message, ReponseFin } from '../types/conversations';

/**
 * Fait vivre une conversation tant que son ecran est au premier plan.
 *
 * Trois horloges : la presence (le serveur oublie quelqu'un au bout de 45 s),
 * la relecture de l'etat et des messages, et une seconde d'affichage pour le
 * chrono. Toutes s'arretent quand l'ecran perd le focus ou que l'application
 * passe en arriere-plan : rester « present » apres etre parti tromperait
 * l'autre. Au retour, tout est relu immediatement.
 */
export function useConversationLive(id: string): {
  etat: EtatConversation | null;
  fil: Message[];
  etape: EtapeConversation;
  restant: number | null;
  decompteJusqua: number | null;
  chargement: boolean;
  erreur: string | null;
  envoyer(corps: string): Promise<boolean>;
  decider(d: ReponseFin): Promise<void>;
  decision: ReponseFin | null;
  decisionEnCours: boolean;
  erreurDecision: string | null;
} {
  const [etat, setEtat] = useState<EtatConversation | null>(null);
  const [fil, setFil] = useState<Message[]>([]);
  const [recuA, setRecuA] = useState(0);
  const [decompteJusqua, setDecompteJusqua] = useState<number | null>(null);
  const [maintenant, setMaintenant] = useState(() => Date.now());
  const [chargement, setChargement] = useState(true);
  const [erreur, setErreur] = useState<string | null>(null);
  const [decision, setDecision] = useState<ReponseFin | null>(null);
  const [decisionEnCours, setDecisionEnCours] = useState(false);
  const [erreurDecision, setErreurDecision] = useState<string | null>(null);
  const [premierPlan, setPremierPlan] = useState(AppState.currentState === 'active');
  const [focus, setFocus] = useState(false);

  // Le dernier message connu, lu par les relectures sans les recreer.
  const filRef = useRef<Message[]>([]);
  filRef.current = fil;

  const relire = useCallback(async () => {
    if (!id) return;
    try {
      const dernier = filRef.current[filRef.current.length - 1]?.created_at;
      const [e, nouveaux] = await Promise.all([
        loadConversationState(id),
        loadMessages(id, dernier),
      ]);
      setEtat(e);
      setRecuA(Date.now());
      setFil((actuels) => fusionnerMessages(actuels, nouveaux));
      setErreur(null);
    } catch (e) {
      // On garde ce qui est affiche : une coupure ne doit rien effacer.
      setErreur(userFacingMessage(e));
    } finally {
      setChargement(false);
    }
  }, [id]);

  const signaler = useCallback(async () => {
    if (!id) return;
    try {
      const r = await joinConversation(id);
      if (r?.demarree) {
        setDecompteJusqua(Date.now() + r.decompte_s * 1000);
        void relire();
      }
    } catch {
      // La presence est retentee au prochain intervalle.
    }
  }, [id, relire]);

  useFocusEffect(
    useCallback(() => {
      setFocus(true);
      return () => setFocus(false);
    }, []),
  );

  useEffect(() => {
    const abonnement = AppState.addEventListener('change', (e) => setPremierPlan(e === 'active'));
    return () => abonnement.remove();
  }, []);

  const actif = focus && premierPlan;
  const statut = etat?.statut ?? 'prete';

  // Presence et premiere lecture, des que l'ecran est au premier plan.
  useEffect(() => {
    if (!actif) return;
    void signaler();
    void relire();
    const presence = setInterval(() => void signaler(), INTERVALLE_PRESENCE_MS);
    return () => clearInterval(presence);
  }, [actif, signaler, relire]);

  // Relecture, plus frequente pendant les 5 minutes.
  useEffect(() => {
    if (!actif) return;
    const lecture = setInterval(() => void relire(), intervalleRafraichissement(statut));
    return () => clearInterval(lecture);
  }, [actif, statut, relire]);

  // Une seconde d'affichage pour le chrono et le decompte.
  useEffect(() => {
    if (!actif) return;
    const tic = setInterval(() => setMaintenant(Date.now()), 1000);
    return () => clearInterval(tic);
  }, [actif]);

  const restant = restantSecondes(etat?.secondes_restantes ?? null, recuA, maintenant);
  const etape = etapeDe(
    {
      statut,
      illimitee: etat?.illimitee ?? false,
      restant,
      decompteJusqua,
      decisionEnvoyee: decision !== null,
    },
    maintenant,
  );

  const envoyer = useCallback(
    async (corps: string) => {
      try {
        await sendMessage({ conversation_id: id, kind: 'texte', body: corps });
        await relire();
        return true;
      } catch (e) {
        setErreur(userFacingMessage(e));
        return false;
      }
    },
    [id, relire],
  );

  const decider = useCallback(
    async (d: ReponseFin) => {
      setDecisionEnCours(true);
      setErreurDecision(null);
      try {
        await decideConversation(id, d);
        setDecision(d);
      } catch (e) {
        setErreurDecision(userFacingMessage(e));
      } finally {
        setDecisionEnCours(false);
      }
    },
    [id],
  );

  return {
    etat,
    fil,
    etape,
    restant,
    decompteJusqua,
    chargement,
    erreur,
    envoyer,
    decider,
    decision,
    decisionEnCours,
    erreurDecision,
  };
}
