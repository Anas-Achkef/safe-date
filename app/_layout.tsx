import { useFonts } from 'expo-font';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useEffect } from 'react';
import { StyleSheet, View } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { SessionProvider } from '../src/hooks/useSession';
import { installWebFrame } from '../src/lib/webFrame';
import { colors } from '../src/theme';

export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    'CabinetGrotesk-Light': require('../assets/fonts/CabinetGrotesk-Light.ttf'),
    'CabinetGrotesk-Regular': require('../assets/fonts/CabinetGrotesk-Regular.ttf'),
    'Switzer-Regular': require('../assets/fonts/Switzer-Regular.ttf'),
    'Switzer-Medium': require('../assets/fonts/Switzer-Medium.ttf'),
  });

  useEffect(() => {
    installWebFrame();
  }, []);

  // Rien n'est rendu avant que les polices soient prêtes : afficher d'abord la
  // police système puis basculer produirait un saut de composition visible.
  if (!fontsLoaded) {
    return <View style={styles.blank} />;
  }

  return (
    <GestureHandlerRootView style={styles.root}>
      <SafeAreaProvider>
        <SessionProvider>
          <StatusBar style="dark" />
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
});
