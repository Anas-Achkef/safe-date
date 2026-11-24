import { Redirect } from 'expo-router';

import { Screen } from '../src/components/Screen';
import { StateView } from '../src/components/StateView';
import { useSession } from '../src/hooks/useSession';

/**
 * Aiguillage d'entrée.
 *
 * La séquence d'ouverture est portée par le layout racine : elle doit jouer
 * quelle que soit l'adresse par laquelle on entre, pas seulement par « / ».
 */
export default function Index() {
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

  return <Redirect href="/(tabs)/discovery" />;
}
