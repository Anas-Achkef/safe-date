import { Redirect, Stack } from 'expo-router';

import { Screen } from '../../src/components/Screen';
import { StateView } from '../../src/components/StateView';
import { useSession } from '../../src/hooks/useSession';

export default function AuthLayout() {
  const { accountState } = useSession();

  if (accountState === 'loading') {
    return (
      <Screen>
        <StateView variant="loading" title="Chargement…" />
      </Screen>
    );
  }

  // Une session valide n'a rien a faire sur les ecrans de connexion.
  if (accountState !== 'signedOut') {
    return <Redirect href="/" />;
  }

  return <Stack screenOptions={{ headerShown: false }} />;
}
