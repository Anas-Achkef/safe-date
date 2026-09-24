import {
  InstrumentSerif_400Regular_Italic,
} from '@expo-google-fonts/instrument-serif';
import {
  Inter_400Regular,
  Inter_500Medium,
  Inter_600SemiBold,
} from '@expo-google-fonts/inter';
import {
  PlusJakartaSans_600SemiBold,
  PlusJakartaSans_700Bold,
  PlusJakartaSans_800ExtraBold,
} from '@expo-google-fonts/plus-jakarta-sans';
import { useFonts } from 'expo-font';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useEffect, useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { LogoSafeDate } from '../src/components/LogoSafeDate';
import { SessionProvider } from '../src/hooks/useSession';
import { installWebFrame } from '../src/lib/webFrame';
import { colors, spacing } from '../src/theme';

/**
 * Racine de l'application.
 *
 * La séquence d'ouverture vit ici, et non dans une route : elle doit jouer à
 * chaque lancement quelle que soit l'adresse d'entrée. Placée dans « / », elle
 * était ignorée dès qu'on rafraîchissait depuis un onglet interne — la route
 * n'était alors jamais montée.
 *
 * Elle attend que les polices soient prêtes : les clés passées à `useFonts`
 * sont exactement les noms de famille repris dans `src/theme.ts`. Afficher
 * d'abord en police système produirait un saut visible.
 */
export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    PlusJakartaSans_600SemiBold,
    PlusJakartaSans_700Bold,
    PlusJakartaSans_800ExtraBold,
    InstrumentSerif_400Regular_Italic,
    Inter_400Regular,
    Inter_500Medium,
    Inter_600SemiBold,
  });
  const [ouvertureFinie, setOuvertureFinie] = useState(false);

  useEffect(() => {
    installWebFrame();
  }, []);

  if (!fontsLoaded) {
    return <View style={styles.blank} />;
  }

  if (!ouvertureFinie) {
    return (
      <View style={styles.ouverture}>
        <StatusBar style="light" />
        <LogoSafeDate style={styles.logo} onFinish={() => setOuvertureFinie(true)} />
      </View>
    );
  }

  return (
    <GestureHandlerRootView style={styles.root}>
      <SafeAreaProvider>
        <SessionProvider>
          <StatusBar style="light" />
          <Stack
            screenOptions={{
              headerShown: false,
              contentStyle: { backgroundColor: colors.background },
            }}
          />
        </SessionProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: colors.background,
  },
  blank: {
    flex: 1,
    backgroundColor: colors.background,
  },
  ouverture: {
    flex: 1,
    backgroundColor: colors.background,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: spacing.md,
  },
  // Le rapport du cadre est de 480 sur 165 : la hauteur decoule de la largeur.
  // Occuper toute la largeur disponible est le seul levier de grandeur.
  logo: { maxWidth: 620 },
});
