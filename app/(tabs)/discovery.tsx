import { useCallback, useRef, useState } from 'react';
import { FlatList, Platform, StyleSheet, useWindowDimensions, View } from 'react-native';
import type { LayoutChangeEvent, NativeScrollEvent, NativeSyntheticEvent } from 'react-native';

import type { DiscoveryEntry } from '../../src/api/discovery';
import { ProfilePane } from '../../src/components/ProfilePane';
import { StateView } from '../../src/components/StateView';
import { useDiscovery } from '../../src/hooks/useDiscovery';
import { snapChildProps, snapContainerProps } from '../../src/lib/webFrame';
import { colors, deviceFrame, layout } from '../../src/theme';

/**
 * Découverte.
 *
 * Un profil occupe un écran, un seul. On fait défiler verticalement pour
 * passer au suivant, avec un accrochage magnétique. Le produit ne propose que
 * quelques personnes par soir : la rareté doit être sensible avant même qu'on
 * lise un mot.
 */
export default function Discovery() {
  const { entries, loading, error, deciding, refresh, decide } = useDiscovery();
  const { height: windowHeight } = useWindowDimensions();
  const [measured, setMeasured] = useState(0);
  const [focusedIndex, setFocusedIndex] = useState(0);

  /**
   * Hauteur d'un profil.
   *
   * La mesure par `onLayout` est la source la plus juste, mais elle arrive
   * après le premier rendu — et n'arrive pas du tout dans certains cas en web.
   * On part donc d'une hauteur calculée et on l'affine ensuite : l'écran ne
   * doit jamais dépendre d'une mesure pour exister.
   *
   * En web, la fenêtre du navigateur ne dit rien de la hauteur utile : c'est
   * le cadre d'appareil imposé qui fait foi.
   */
  const fallbackHeight =
    (Platform.OS === 'web' ? deviceFrame.height : windowHeight) - layout.tabBarHeight;
  const paneHeight = measured > 0 ? measured : Math.max(fallbackHeight, 1);

  const onLayout = useCallback((event: LayoutChangeEvent) => {
    const next = Math.round(event.nativeEvent.layout.height);
    if (next > 0) setMeasured((previous) => (previous === next ? previous : next));
  }, []);

  const onScroll = useCallback(
    (event: NativeSyntheticEvent<NativeScrollEvent>) => {
      const index = Math.round(event.nativeEvent.contentOffset.y / paneHeight);
      setFocusedIndex((previous) => (previous === index ? previous : index));
    },
    [paneHeight],
  );

  /** Profils dont le chiffre a déjà été décompté : il ne rejoue pas au retour. */
  const counted = useRef<Set<string>>(new Set());

  const renderItem = useCallback(
    ({ item, index }: { item: DiscoveryEntry; index: number }) => {
      const focused = index === focusedIndex;
      const firstTime = !counted.current.has(item.candidate_id);
      if (focused && firstTime) counted.current.add(item.candidate_id);

      return (
        <View {...snapChildProps}>
          <ProfilePane
            entry={item}
            height={paneHeight}
            focused={focused}
            animate={firstTime}
            busy={deciding === item.candidate_id}
            onDecide={decide}
          />
        </View>
      );
    },
    [decide, deciding, focusedIndex, paneHeight],
  );

  if (loading) {
    return (
      <View style={styles.screen}>
        <StateView variant="loading" title="Sélection en cours" />
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.screen}>
        <StateView
          variant="error"
          title="Chargement impossible"
          message={error}
          actionLabel="Réessayer"
          onAction={refresh}
        />
      </View>
    );
  }

  if (entries.length === 0) {
    return (
      <View style={styles.screen}>
        <StateView
          variant="empty"
          title="C’est tout pour ce soir"
          message="Vous vous êtes prononcé sur toutes les personnes proposées. La sélection est volontairement courte."
          actionLabel="Actualiser"
          onAction={refresh}
        />
      </View>
    );
  }

  return (
    <View style={styles.screen} onLayout={onLayout}>
      <FlatList
        data={entries}
        keyExtractor={(entry) => entry.candidate_id}
        renderItem={renderItem}
        pagingEnabled
        snapToInterval={paneHeight}
        snapToAlignment="start"
        decelerationRate="fast"
        disableIntervalMomentum
        showsVerticalScrollIndicator={false}
        onScroll={onScroll}
        scrollEventThrottle={32}
        getItemLayout={(_, index) => ({
          length: paneHeight,
          offset: paneHeight * index,
          index,
        })}
        {...snapContainerProps}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: colors.background,
  },
});
