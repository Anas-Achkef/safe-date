import { useCallback, useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useRouter } from 'expo-router';
import CarteSwipe from '../../src/components/CarteSwipe';
import PagesProfil from '../../src/components/PagesProfil';
import CarteSollicitation from '../../src/components/CarteSollicitation';
import FinDeSession from '../../src/components/FinDeSession';
import { Screen } from '../../src/components/Screen';
import { StateView } from '../../src/components/StateView';
import { useConsultation } from '../../src/hooks/useConsultation';
import {
  answerFocus,
  closeSession,
  loadLearningFeed,
  loadPendingFocus,
  loadSessionState,
  submitSwipe,
} from '../../src/api/learning';
import type {
  CarteApprentissage,
  EtatSession,
  FinDeSession as TFin,
  Sollicitation,
} from '../../src/types/learning';
import { colors, radius, spacing, typography } from '../../src/theme';

const ORDRE_DEFAUT = ['physique', 'valeurs', 'mode_vie'] as const;

/**
 * Onglet « Mieux me connaître ».
 *
 * Aucun match n'y est créé. Les profils servent exclusivement à entraîner le
 * moteur, et un « non » n'écarte personne : les retirer du vivier viderait
 * l'échantillon d'apprentissage en quelques sessions.
 *
 * L'écran ne montre donc ni score de compatibilité, ni distance, ni bouton de
 * conversation. Seuls le prénom et l'âge restent visibles. Tout ce qui
 * suggérerait une rencontre possible serait mensonger : le profil affiché
 * peut se trouver à l'autre bout du monde.
 */
export default function MieuxMeConnaitre() {
  const router = useRouter();
  const [file, setFile] = useState<CarteApprentissage[]>([]);
  const [session, setSession] = useState<EtatSession | null>(null);
  const [question, setQuestion] = useState<Sollicitation | null>(null);
  const [fin, setFin] = useState<TFin | null>(null);
  const [erreur, setErreur] = useState<string | null>(null);
  const [chargement, setChargement] = useState(true);

  const carte = file[0];
  const pages = carte?.ordre_pages ?? [...ORDRE_DEFAUT];
  const { index, allerA, releve, reinitialiser } = useConsultation(pages);

  const charger = useCallback(async () => {
    try {
      const [cartes, etat] = await Promise.all([loadLearningFeed(10), loadSessionState()]);
      setSession(etat);
      setFile(cartes);
      if (cartes.length === 0) setFin(await closeSession());
    } catch (e) {
      setErreur((e as Error).message);
    } finally {
      setChargement(false);
    }
  }, []);

  useEffect(() => {
    void charger();
  }, [charger]);

  // Chaque profil repart d'un relevé vierge : les mesures d'attention ne
  // doivent jamais déborder d'une carte sur la suivante.
  useEffect(() => {
    reinitialiser();
  }, [carte?.presentation_id, reinitialiser]);

  const decider = useCallback(
    async (garder: boolean) => {
      if (!carte) return;
      const mesures = releve();
      setFile((f) => f.slice(1));

      try {
        const sollicitation = await submitSwipe({
          cible: carte.profil_id,
          garder,
          contexte: 'mieux_me_connaitre',
          presentation_id: carte.presentation_id,
          ...mesures,
        });

        const etat = await loadSessionState();
        setSession(etat);

        // C'est le moteur qui décide s'il pose une question : la cadence suit
        // ce qu'il ignore encore, jamais un compteur tenu ici.
        if (sollicitation) setQuestion(await loadPendingFocus());

        if (!etat.illimite && (etat.restants ?? 0) <= 0) {
          setFin(await closeSession());
        } else if (file.length <= 3) {
          void charger();
        }
      } catch (e) {
        setErreur((e as Error).message);
      }
    },
    [carte, charger, file.length, releve],
  );

  const repondre = useCallback(
    async (options: number[] | null, categorie?: string) => {
      if (!question) return;
      try {
        await answerFocus(question.focus_id, options, categorie);
      } finally {
        setQuestion(null);
      }
    },
    [question],
  );

  if (erreur) {
    return (
      <Screen>
        <StateView variant="error" title="Impossible de charger" message={erreur} />
      </Screen>
    );
  }

  if (fin) {
    return (
      <Screen>
        <FinDeSession
          fin={fin}
          onPartirEnDate={() => router.replace('/(tabs)/discovery')}
          onPremium={() => {}}
        />
      </Screen>
    );
  }

  if (question) {
    return (
      <Screen>
        <CarteSollicitation sollicitation={question} onRepondre={repondre} />
      </Screen>
    );
  }

  if (chargement || !carte) {
    return (
      <Screen>
        <StateView variant="loading" title="Un instant" message="Nous choisissons les profils les plus utiles." />
      </Screen>
    );
  }

  return (
    <Screen>
      <View style={styles.zone}>
        <View style={styles.carte}>
          <CarteSwipe
            cle={carte.presentation_id}
            onOui={() => decider(true)}
            onNon={() => decider(false)}
          >
            <PagesProfil
              pages={pages}
              index={index}
              photo={carte.photo_principale}
              prenom={carte.prenom}
              criteres={carte.criteres}
              onAller={allerA}
            />
          </CarteSwipe>
        </View>

        <View style={styles.bas}>
          {/* Prénom et âge restent visibles sur les trois pages. Rien d'autre. */}
          <View style={styles.identite}>
            <Text style={styles.prenom}>{carte.prenom}</Text>
            <Text style={styles.age}>{carte.age} ans</Text>
          </View>

          <View style={styles.actions}>
            <Pressable style={[styles.bouton, styles.non]} onPress={() => decider(false)}>
              <Text style={[styles.boutonTexte, { color: colors.danger }]}>Non</Text>
            </Pressable>
            <Pressable style={[styles.bouton, styles.oui]} onPress={() => decider(true)}>
              <Text style={[styles.boutonTexte, { color: colors.onAccent }]}>Oui</Text>
            </Pressable>
          </View>

          {session && !session.illimite && session.restants !== null && (
            <Text style={styles.restants}>
              {session.restants} {session.restants > 1 ? 'profils restants' : 'profil restant'}{' '}
              aujourd&apos;hui
            </Text>
          )}
        </View>
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  zone: { flex: 1, paddingHorizontal: spacing.gutter },
  carte: { flex: 1, paddingBottom: spacing.xl },
  bas: { paddingBottom: spacing.xl },
  identite: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: spacing.md,
    marginBottom: spacing.lg,
  },
  prenom: { ...typography.name, color: colors.textPrimary },
  age: { ...typography.label, color: colors.textSecondary },
  actions: { flexDirection: 'row', gap: spacing.md },
  bouton: {
    flex: 1,
    borderRadius: radius.md,
    paddingVertical: spacing.lg,
    alignItems: 'center',
  },
  non: {
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.danger,
  },
  oui: { backgroundColor: colors.accent },
  boutonTexte: { ...typography.label },
  restants: {
    ...typography.caption,
    color: colors.textMuted,
    textAlign: 'center',
    marginTop: spacing.md,
  },
});
