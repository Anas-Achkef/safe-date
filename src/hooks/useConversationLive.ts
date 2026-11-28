import { useFocusEffect } from 'expo-router';
import { useCallback, useEffect, useRef, useState } from 'react';
import { AppState } from 'react-native';

import {
  decideConversation,
  joinConversation,
  loadConversationState,
  loadMessages,
  sendMessage,
  signalPresence,
} from '../api/conversations';
import { userFacingMessage } from '../api/errors';
import {
  decompteDepuisServeur,
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

  // Le dernier message connu et le statut, lus par les relectures sans les recreer.
  const filRef = useRef<Message[]>([]);
  filRef.current = fil;
  const statutRef = useRef<EtatConversation['statut'] | null>(null);
  statutRef.current = etat?.statut ?? null;
  // Numero de la derniere lecture lancee : une reponse plus ancienne qu'une
  // autre deja appliquee est ignoree, sinon un etat « prete » perime pourrait
  // ecraser « active » juste apres le demarrage.
  const sequence = useRef(0);

  const relire = useCallback(async () => {
    if (!id) return;
    const numero = (sequence.current += 1);
    try {
      const dernier = filRef.current[filRef.current.length - 1]?.created_at;
      const [e, nouveaux] = await Promise.all([
        loadConversationState(id),
        loadMessages(id, dernier),
      ]);
      if (numero !== sequence.current) return;
      const t = Date.now();
      setEtat(e);
      setRecuA(t);
      setMaintenant(t);
      // Les deux personnes voient le meme 3, 2, 1, y compris celle qui attendait.
      const fin = decompteDepuisServeur(e?.secondes_restantes ?? null, t);
      if (fin !== null) setDecompteJusqua(fin);
      setFil((actuels) => fusionnerMessages(actuels, nouveaux));
      setErreur(null);
    } catch (e) {
      // On garde ce qui est affiche : une coupure ne doit rien effacer.
      if (numero === sequence.current) setErreur(userFacingMessage(e));
    } finally {
      setChargement(false);
    }
  }, [id]);

  const signaler = useCallback(async () => {
    if (!id) return;
    // `rejoindre_conversation` ne met pas a jour la presence lue par
    // `etat_conversation` : sans ce signal, chacun verrait l'autre « Hors
    // ligne » apres 45 s, meme en pleine conversation.
    signalPresence().catch(() => {});
    try {
      const r = await joinConversation(id);
      if (r?.demarree) {
        setDecompteJusqua(Date.now() + r.decompte_s * 1000);
        void relire();
      } else if (r?.statut === 'active' && statutRef.current === 'prete') {
        // L'autre vient de faire partir le chrono : on le lit tout de suite.
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
  const autreEnLigne = etat?.autre_en_ligne ?? false;

  // Presence et premiere lecture, des que l'ecran est au premier plan.
  useEffect(() => {
    if (!actif) return;
    // L'horloge d'affichage a pu dormir : on la remet a l'heure avant tout.
    setMaintenant(Date.now());
    void signaler();
    void relire();
    const presence = setInterval(() => void signaler(), INTERVALLE_PRESENCE_MS);
    return () => clearInterval(presence);
  }, [actif, signaler, relire]);

  // Relecture, plus frequente pendant les 5 minutes.
  useEffect(() => {
    if (!actif) return;
    const lecture = setInterval(
      () => void relire(),
      intervalleRafraichissement(statut, autreEnLigne),
    );
    return () => clearInterval(lecture);
  }, [actif, statut, autreEnLigne, relire]);

  // Horloge d'affichage du chrono et du decompte. Un quart de seconde : avec un
  // tic par seconde, son retard variable sur les lectures faisait sauter des
  // secondes au chrono et durer le « 3 » du decompte.
  useEffect(() => {
    if (!actif) return;
    const tic = setInterval(() => setMaintenant(Date.now()), 250);
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
