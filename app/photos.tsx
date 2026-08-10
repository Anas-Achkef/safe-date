import * as ImagePicker from 'expo-image-picker';
import { router } from 'expo-router';
import { useCallback, useEffect, useState } from 'react';
import { Image, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { userFacingMessage } from '../src/api/errors';
import { addPhoto, deletePhoto, fetchMyPhotos, setPrimaryPhoto, type UserPhoto } from '../src/api/photos';
import { MissingBucketError, PHOTO_BUCKET } from '../src/lib/storage';
import { Button } from '../src/components/Button';
import { StateView } from '../src/components/StateView';
import { colors, opacity, radius, spacing, typography } from '../src/theme';

const MODERATION_LABELS: Record<UserPhoto['moderation'], string> = {
  en_attente: 'En cours de vérification',
  approuvee: 'Validée',
  rejetee: 'Refusée',
};

/**
 * Gestion des photos de profil.
 *
 * Tant que le compartiment de stockage n'existe pas cote Supabase, l'ecran le
 * dit explicitement plutot que d'echouer avec un message technique.
 */
export default function Photos() {
  const [photos, setPhotos] = useState<UserPhoto[]>([]);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [bucketMissing, setBucketMissing] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setPhotos(await fetchMyPhotos());
    } catch (err) {
      setError(userFacingMessage(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const pick = useCallback(async () => {
    setError(null);

    const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!permission.granted) {
      setError('L’accès à vos photos est nécessaire pour en ajouter une.');
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsEditing: true,
      aspect: [4, 5],
      quality: 0.85,
    });
    if (result.canceled || !result.assets[0]) return;

    setBusy(true);
    try {
      await addPhoto(result.assets[0].uri);
      await load();
    } catch (err) {
      if (err instanceof MissingBucketError) {
        setBucketMissing(true);
        setError(err.message);
      } else {
        setError(userFacingMessage(err));
      }
    } finally {
      setBusy(false);
    }
  }, [load]);

  const makePrimary = useCallback(
    async (photo: UserPhoto) => {
      setBusy(true);
      setError(null);
      try {
        await setPrimaryPhoto(photo.id);
        await load();
      } catch (err) {
        setError(userFacingMessage(err));
      } finally {
        setBusy(false);
      }
    },
    [load],
  );

  const remove = useCallback(
    async (photo: UserPhoto) => {
      setBusy(true);
      setError(null);
      try {
        await deletePhoto(photo);
        await load();
      } catch (err) {
        setError(userFacingMessage(err));
      } finally {
        setBusy(false);
      }
    },
    [load],
  );

  if (loading) {
    return (
      <SafeAreaView style={styles.safe} edges={['top', 'left', 'right']}>
        <StateView variant="loading" title="Chargement" />
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safe} edges={['top', 'left', 'right']}>
      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <Pressable onPress={() => router.back()} style={styles.back}>
          <Text style={styles.backLabel} allowFontScaling={false}>
            Retour
          </Text>
        </Pressable>

        <Text style={styles.title} allowFontScaling={false}>
          Vos photos
        </Text>
        <Text style={styles.subtitle}>
          La première photo devient votre photo principale. C’est elle qui apparaît aux autres.
        </Text>

        {bucketMissing ? (
          <View style={styles.warning}>
            <Text style={styles.warningTitle}>Stockage non configuré</Text>
            <Text style={styles.warningBody}>
              Le compartiment « {PHOTO_BUCKET} » n’existe pas encore sur le projet Supabase.
              Créez-le en privé dans Storage, puis revenez : l’envoi fonctionnera sans autre
              changement.
            </Text>
          </View>
        ) : null}

        {photos.length === 0 ? (
          <View style={styles.empty}>
            <Text style={styles.emptyText}>
              Aucune photo pour le moment. Votre profil apparaît avec un aplat coloré.
            </Text>
          </View>
        ) : (
          <View style={styles.grid}>
            {photos.map((photo) => (
              <View key={photo.id} style={styles.tile}>
                {photo.url ? (
                  <Image source={{ uri: photo.url }} style={styles.image} resizeMode="cover" />
                ) : (
                  <View style={[styles.image, styles.imageMissing]} />
                )}

                <View style={styles.tileFooter}>
                  <Text style={styles.tileStatus} numberOfLines={1}>
                    {photo.isPrimary ? 'Principale' : MODERATION_LABELS[photo.moderation]}
                  </Text>
                  <View style={styles.tileActions}>
                    {!photo.isPrimary ? (
                      <Pressable
                        onPress={() => void makePrimary(photo)}
                        disabled={busy}
                        style={({ pressed }) => [styles.tileAction, pressed ? styles.pressed : null]}
                      >
                        <Text style={styles.tileActionLabel}>Choisir</Text>
                      </Pressable>
                    ) : null}
                    <Pressable
                      onPress={() => void remove(photo)}
                      disabled={busy}
                      style={({ pressed }) => [styles.tileAction, pressed ? styles.pressed : null]}
                    >
                      <Text style={[styles.tileActionLabel, styles.danger]}>Retirer</Text>
                    </Pressable>
                  </View>
                </View>
              </View>
            ))}
          </View>
        )}

        {error ? <Text style={styles.error}>{error}</Text> : null}

        <Button label="Ajouter une photo" onPress={() => void pick()} loading={busy} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    paddingHorizontal: spacing.gutter,
    paddingTop: spacing.md,
    paddingBottom: spacing.giant,
    gap: spacing.md,
  },
  back: {
    alignSelf: 'flex-start',
    paddingVertical: spacing.xs,
  },
  backLabel: {
    ...typography.label,
    color: colors.accent,
  },
  title: {
    ...typography.display,
    color: colors.textPrimary,
    includeFontPadding: false,
  },
  subtitle: {
    ...typography.caption,
    color: colors.textMuted,
    marginBottom: spacing.sm,
  },
  warning: {
    backgroundColor: colors.surfaceAlt,
    borderRadius: radius.sm,
    padding: spacing.lg,
    gap: spacing.xs,
  },
  warningTitle: {
    ...typography.label,
    color: colors.textPrimary,
  },
  warningBody: {
    ...typography.caption,
    color: colors.textSecondary,
  },
  empty: {
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    padding: spacing.xl,
  },
  emptyText: {
    ...typography.body,
    color: colors.textMuted,
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.md,
  },
  tile: {
    width: '47%',
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    overflow: 'hidden',
  },
  image: {
    width: '100%',
    aspectRatio: 4 / 5,
  },
  imageMissing: {
    backgroundColor: colors.surfaceAlt,
  },
  tileFooter: {
    padding: spacing.md,
    gap: spacing.sm,
  },
  tileStatus: {
    ...typography.caption,
    color: colors.textSecondary,
  },
  tileActions: {
    flexDirection: 'row',
    gap: spacing.md,
  },
  tileAction: {
    paddingVertical: spacing.xs,
  },
  tileActionLabel: {
    ...typography.caption,
    color: colors.accent,
  },
  danger: {
    color: colors.danger,
  },
  pressed: {
    opacity: opacity.pressed,
  },
  error: {
    ...typography.caption,
    color: colors.danger,
  },
});
