import { Redirect } from 'expo-router';
import { useState } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';

import {
  Badge,
  BarreOnglets,
  Bouton,
  CartePhoto,
  Chip,
  LogoHorizontal,
  LogoSymbole,
  LogoSymboleBlanc,
  type OngletId,
} from '../src/components/ui';
import { colors, degradeImmersif, spacing, typography } from '../src/theme';
import { LinearGradient } from 'expo-linear-gradient';

/**
 * Planche de contrôle des composants du système.
 *
 * Elle n'est pas destinée aux personnes qui utilisent l'application : elle
 * sert à comparer le rendu réel aux nodes Figma, côte à côte, sans avoir à
 * naviguer dans un écran complet. Hors développement la route existe encore —
 * `expo-router` la déduit du fichier — mais elle ne mène nulle part.
 */
export default function Galerie() {
  const [onglet, setOnglet] = useState<OngletId>('parcourir');
  const [choisis, setChoisis] = useState<string[]>(['Cuisine']);

  const basculer = (mot: string) =>
    setChoisis((liste) =>
      liste.includes(mot) ? liste.filter((m) => m !== mot) : [...liste, mot],
    );

  if (!__DEV__) return <Redirect href="/" />;

  return (
    <View style={styles.page}>
      <ScrollView contentContainerStyle={styles.contenu}>
        <Text style={styles.surtitre}>Safe Date · Design System</Text>

        <Text style={styles.titre}>Logo</Text>
        <View style={styles.rangee}>
          <LogoSymbole taille={72} />
          <LogoHorizontal />
        </View>
        <LinearGradient
          colors={[...degradeImmersif.colors]}
          locations={[...degradeImmersif.locations]}
          start={degradeImmersif.start}
          end={degradeImmersif.end}
          style={styles.immersif}
        >
          <LogoSymboleBlanc taille={64} />
          <LogoHorizontal blanc />
        </LinearGradient>

        <Text style={styles.titre}>Bouton</Text>
        <Bouton libelle="Envoyer une demande" onPress={() => {}} variante="primaire" />
        <Bouton libelle="Envoyer une demande" onPress={() => {}} variante="secondaire" />
        <Bouton libelle="Envoyer une demande" onPress={() => {}} variante="sombre" />
        <Bouton libelle="Envoyer une demande" onPress={() => {}} variante="fantome" />

        <Text style={styles.titre}>Chip</Text>
        <View style={styles.rangee}>
          {['Cuisine', 'Randonnée', 'Cinéma'].map((mot) => (
            <Chip
              key={mot}
              libelle={mot}
              selectionne={choisis.includes(mot)}
              onPress={() => basculer(mot)}
            />
          ))}
        </View>

        <Text style={styles.titre}>Badge</Text>
        <View style={styles.rangee}>
          <Badge libelle="92 %" type="compatibilite" />
          <Badge libelle="Profil vérifié" type="verifie" />
          <Badge libelle="Amour" type="rencontre" />
          <Badge libelle="2 jours" type="delai" />
          <Badge libelle="à 3 km" type="neutre" />
        </View>

        <Text style={styles.titre}>Carte photo</Text>
        <CartePhoto photo={null} seed="sacha-33" prenom="Sacha" hauteur={280}>
          <View style={styles.surPhoto}>
            <Badge libelle="92 %" type="compatibilite" />
            <Text style={styles.prenom}>Sacha, 33</Text>
          </View>
        </CartePhoto>
      </ScrollView>

      <BarreOnglets actif={onglet} onChoisir={setOnglet} />
    </View>
  );
}

const styles = StyleSheet.create({
  page: { flex: 1, backgroundColor: colors.background },
  contenu: { padding: spacing.gutter, gap: spacing.md, paddingBottom: spacing.giant },
  surtitre: { ...typography.overline, color: colors.accent },
  titre: { ...typography.h2, color: colors.textPrimary, marginTop: spacing.lg },
  rangee: { flexDirection: 'row', flexWrap: 'wrap', alignItems: 'center', gap: spacing.sm },
  immersif: {
    borderRadius: spacing.xxl,
    padding: spacing.xxl,
    alignItems: 'center',
    gap: spacing.lg,
  },
  surPhoto: {
    position: 'absolute',
    left: spacing.xl,
    right: spacing.xl,
    bottom: spacing.xl,
    alignItems: 'flex-start',
    gap: spacing.sm,
  },
  prenom: { ...typography.h2, color: colors.onPhoto },
});
