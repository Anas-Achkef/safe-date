import { Redirect, Tabs } from 'expo-router';
import { StyleSheet } from 'react-native';

import { Screen } from '../../src/components/Screen';
import { StateView } from '../../src/components/StateView';
import {
  ConversationsIcon,
  DatesIcon,
  DiscoveryIcon,
  ProfileIcon,
} from '../../src/components/TabIcons';
import { useSession } from '../../src/hooks/useSession';
import { colors, hairline, layout, spacing, typography } from '../../src/theme';

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
      screenOptions={{
        headerShown: false,
        // L'onglet actif se signale par la couleur du trait, jamais par une
        // pastille ni un fond plein.
        tabBarActiveTintColor: colors.accent,
        tabBarInactiveTintColor: colors.textMuted,
        tabBarStyle: styles.tabBar,
        tabBarLabelStyle: styles.tabLabel,
        tabBarItemStyle: styles.tabItem,
        sceneStyle: { backgroundColor: colors.background },
      }}
    >
      <Tabs.Screen
        name="discovery"
        options={{
          title: 'Découverte',
          tabBarIcon: ({ color }) => <DiscoveryIcon color={color} />,
        }}
      />
      <Tabs.Screen
        name="conversations"
        options={{
          title: 'Conversations',
          tabBarIcon: ({ color }) => <ConversationsIcon color={color} />,
        }}
      />
      <Tabs.Screen
        name="dates"
        options={{
          title: 'Rendez-vous',
          tabBarIcon: ({ color }) => <DatesIcon color={color} />,
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profil',
          tabBarIcon: ({ color }) => <ProfileIcon color={color} />,
        }}
      />
    </Tabs>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    backgroundColor: colors.surface,
    borderTopColor: colors.rule,
    borderTopWidth: hairline,
    // La barre native pose une ombre par défaut : elle n'a rien à faire ici.
    elevation: 0,
    boxShadow: 'none',
    height: layout.tabBarHeight,
    paddingTop: spacing.sm,
  },
  tabItem: {
    paddingVertical: spacing.xs,
  },
  tabLabel: {
    ...typography.tabLabel,
    marginTop: spacing.xs,
  },
});
