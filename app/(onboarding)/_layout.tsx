import { Redirect, Stack } from 'expo-router';

import { Screen } from '../../src/components/Screen';
import { StateView } from '../../src/components/StateView';
import { useSession } from '../../src/hooks/useSession';

export default function OnboardingLayout() {
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

  if (accountState === 'active') {
    return <Redirect href="/(tabs)/discovery" />;
  }

  return <Stack screenOptions={{ headerShown: false }} />;
}
