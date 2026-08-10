import { Image, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import {
  colors,
  elevation,
  hairline,
  radius,
  spacing,
  typography,
} from '../theme';
import type { ScoreGroup } from '../types/rpc';
import type { CritereAffiche } from '../types/learning';

const TITRES: Record<ScoreGroup, string> = {
  physique: 'Photos',
  valeurs: 'Mes valeurs',
  mode_vie: 'Mon mode de vie',
};

interface Props {
  pages: ScoreGroup[];
  index: number;
  photo: string | null;
  prenom: string;
  criteres: Partial<Record<Exclude<ScoreGroup, 'physique'>, CritereAffiche[]>>;
  onAller: (i: number) => void;
}

/**
 * Les trois pages vivent dans la carte : ce n'est pas un écran de détail
 * qu'on ouvrirait, c'est le profil lui-même.
 *
 * L'ordre vient du moteur et change à chaque profil. Ce n'est pas un choix
 * d'interface : c'est ce qui permet ensuite de distinguer une page évitée
 * d'une page simplement placée en dernier.
 *
 * Les phrases sont générées côté serveur à partir des critères. Les questions
 * du questionnaire ne doivent jamais apparaître ici.
 */
export default function PagesProfil({
  pages,
  index,
  photo,
  prenom,
  criteres,
  onAller,
}: Props) {
  const page = pages[index];
  const lignes = page === 'physique' ? [] : (criteres[page] ?? []);

  return (
    <View style={styles.carte}>
      {page === 'physique' ? (
        <View style={styles.photoZone}>
          {photo ? (
            <Image source={{ uri: photo }} style={styles.photo} resizeMode="cover" />
          ) : (
            <LinearGradient
              colors={[colors.placeholderFrom, colors.placeholderTo]}
              style={styles.photo}
            />
          )}
        </View>
      ) : (
        <ScrollView
          style={styles.texte}
          contentContainerStyle={styles.texteContenu}
          showsVerticalScrollIndicator={false}
        >
          <Text style={styles.titre}>{TITRES[page]}</Text>
          <Text style={styles.compte}>
            {lignes.length} {lignes.length > 1 ? 'critères retenus' : 'critère retenu'}
          </Text>

          {lignes.map((c, i) => (
            <View key={c.cle} style={[styles.ligne, i === 0 && styles.ligneSansFilet]}>
              <View style={styles.puce} />
              <Text style={styles.phrase}>{c.phrase}</Text>
            </View>
          ))}
        </ScrollView>
      )}

      {/* Repères de pagination : cliquables, et surtout lisibles. Ils rendent
          visible que l'ordre change d'un profil à l'autre. */}
      <View style={styles.reperes} pointerEvents="box-none">
        {pages.map((p, i) => (
          <Pressable
            key={p}
            accessibilityRole="button"
            accessibilityLabel={TITRES[p]}
            onPress={() => onAller(i)}
            hitSlop={10}
            style={[styles.repere, i === index && styles.repereActif]}
          />
        ))}
      </View>

      {/* Bandes de navigation verticale, en dehors de l'axe du geste. */}
      <Pressable
        accessibilityLabel="Page précédente"
        onPress={() => onAller(index - 1)}
        disabled={index === 0}
        style={[styles.bande, styles.bandeHaut]}
      />
      <Pressable
        accessibilityLabel="Page suivante"
        onPress={() => onAller(index + 1)}
        disabled={index === pages.length - 1}
        style={[styles.bande, styles.bandeBas]}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  carte: {
    flex: 1,
    borderRadius: radius.lg,
    backgroundColor: colors.surface,
    overflow: 'hidden',
    ...elevation.card,
  },
  photoZone: { flex: 1 },
  photo: { width: '100%', height: '100%' },

  texte: { flex: 1 },
  texteContenu: {
    padding: spacing.xxl,
    paddingRight: spacing.xxxl,
  },
  titre: {
    ...typography.display,
    color: colors.textPrimary,
  },
  compte: {
    ...typography.overline,
    color: colors.textMuted,
    textTransform: 'uppercase',
    marginTop: spacing.xs,
    marginBottom: spacing.xl,
  },
  ligne: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: spacing.md,
    paddingVertical: spacing.md,
    borderTopWidth: hairline,
    borderTopColor: colors.rule,
  },
  ligneSansFilet: { borderTopWidth: 0 },
  puce: {
    width: 6,
    height: 6,
    borderRadius: radius.pill,
    backgroundColor: colors.accent,
    marginTop: 8,
  },
  phrase: {
    ...typography.body,
    color: colors.textPrimary,
    flex: 1,
  },

  reperes: {
    position: 'absolute',
    right: spacing.lg,
    top: '50%',
    gap: spacing.sm,
  },
  repere: {
    width: 6,
    height: 6,
    borderRadius: radius.pill,
    backgroundColor: colors.rule,
  },
  repereActif: {
    height: 18,
    backgroundColor: colors.accent,
  },

  bande: {
    position: 'absolute',
    left: 0,
    right: spacing.xxxl,
    height: 56,
  },
  bandeHaut: { top: 0 },
  bandeBas: { bottom: 0 },
});
