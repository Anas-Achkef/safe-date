import { Redirect } from 'expo-router';
// `Tabs` exporté par « expo-router » est déprécié au profit de cette entrée,
// la seule qui expose aussi le type des propriétés passées à `tabBar`.
import Tabs, { type BottomTabBarProps } from 'expo-router/js-tabs';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { Screen } from '../../src/components/Screen';
import { StateView } from '../../src/components/StateView';
import { BarreOnglets, ONGLETS, type OngletId } from '../../src/components/ui';
import { useSession } from '../../src/hooks/useSession';
import { colors } from '../../src/theme';

/**
 * Les cinq onglets.
 *
 * La barre est dessinée par `BarreOnglets`, qui ne connaît ni `expo-router`
 * ni son état : elle reçoit l'onglet actif et rend un choix. Tout le
 * branchement tient dans l'adaptateur ci-dessous — c'est ce qui permet de la
 * montrer seule dans la planche de contrôle, et de la remplacer sans toucher
 * aux écrans.
 */

/** Les routes, dans l'ordre des onglets du système de design. */
const ROUTES: Record<OngletId, string> = {
  parcourir: 'learning',
  decouverte: 'discovery',
  discussions: 'conversations',
  rendezVous: 'dates',
  profil: 'profile',
};

function Adaptateur({ state, navigation }: BottomTabBarProps) {
  const marges = useSafeAreaInsets();
  const routeActive = state.routes[state.index].name;
  const actif =
    (Object.keys(ROUTES) as OngletId[]).find((id) => ROUTES[id] === routeActive) ?? 'parcourir';

  return (
    <BarreOnglets
      actif={actif}
      basSur={marges.bottom}
      onChoisir={(id) => {
        const cible = ROUTES[id];
        // `navigate` plutôt que `jumpTo` : il replace l'onglet sur sa racine
        // quand on le retouche, ce qu'on attend d'une barre d'onglets.
        if (cible !== routeActive) navigation.navigate(cible);
      }}
    />
  );
}

export default function TabsLayout() {
  const { accountState } = useSession();

  if (accountState === 'loading') {
    return (
      <Screen>
        <StateView variant="loading" title="Chargement" />
      </Screen>
    );
  }

  if (accountState === 'signedOut') {
    return <Redirect href="/(auth)/sign-in" />;
  }

  if (accountState === 'incomplete') {
    return <Redirect href="/(onboarding)" />;
  }

  return (
    <Tabs
      tabBar={(props) => <Adaptateur {...props} />}
      screenOptions={{
        headerShown: false,
        sceneStyle: { backgroundColor: colors.background },
      }}
    >
      {ONGLETS.map((onglet) => (
        <Tabs.Screen
          key={onglet.id}
          name={ROUTES[onglet.id]}
          options={{ title: onglet.libelle }}
        />
      ))}
    </Tabs>
  );
}
