import { Redirect } from 'expo-router';

import { Screen } from '../src/components/Screen';
import { StateView } from '../src/components/StateView';
import { useSession } from '../src/hooks/useSession';

/**
 * Aiguillage d'entree.
 *
 * Trois etats possibles apres relecture de la session persistee :
 * pas de session, compte non active, compte actif.
 */
export default function Index() {
  const { accountState } = useSession();

  if (accountState === 'loading') {
    return (
      <Screen>
        <StateView variant="loading" title="Chargement…" />
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
