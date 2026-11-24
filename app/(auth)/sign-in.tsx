import { Link } from 'expo-router';
import { useState } from 'react';
import { KeyboardAvoidingView, Platform, StyleSheet, Text, View } from 'react-native';

import { signInWithEmail } from '../../src/api/auth';
import { userFacingMessage } from '../../src/api/errors';
import { Button } from '../../src/components/Button';
import { MarqueSafeDate } from '../../src/components/MarqueSafeDate';
import { Screen } from '../../src/components/Screen';
import { TextField } from '../../src/components/TextField';
import { colors, spacing, typography } from '../../src/theme';

export default function SignIn() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const submit = async () => {
    setLoading(true);
    setError(null);
    try {
      await signInWithEmail(email.trim(), password);
      // La redirection est prise en charge par l'ecouteur de session : il met
      // a jour accountState, et le layout d'authentification renvoie vers « / ».
    } catch (err) {
      setError(userFacingMessage(err));
    } finally {
      setLoading(false);
    }
  };

  return (
    <Screen>
      <View style={styles.marque}>
        <MarqueSafeDate taille={56} />
        <Text style={styles.marqueNom}>Safe Date</Text>
        <Text style={styles.marqueTitre}>Se connecter</Text>
        <Text style={styles.marqueSous}>Retrouve ton compte Safe Date.</Text>
      </View>

      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        style={styles.form}
      >
        <TextField
          label="Adresse e-mail"
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          autoComplete="email"
          keyboardType="email-address"
          placeholder="toi@exemple.fr"
          textContentType="emailAddress"
        />

        <TextField
          label="Mot de passe"
          value={password}
          onChangeText={setPassword}
          secureTextEntry
          autoCapitalize="none"
          autoComplete="current-password"
          placeholder="••••••••"
          textContentType="password"
        />

        {error ? <Text style={styles.error}>{error}</Text> : null}

        <Button
          label="Se connecter"
          onPress={() => void submit()}
          loading={loading}
          disabled={email.length === 0 || password.length === 0}
        />

        <View style={styles.footer}>
          <Text style={styles.footerText}>Pas encore de compte ?</Text>
          <Link href="/(auth)/sign-up" style={styles.link}>
            Créer un compte
          </Link>
        </View>
      </KeyboardAvoidingView>
    </Screen>
  );
}

const styles = StyleSheet.create({
  marque: { alignItems: 'center', gap: spacing.md, marginBottom: spacing.xxl },
  marqueNom: { ...typography.display, color: colors.textPrimary, includeFontPadding: false },
  marqueTitre: { ...typography.heading, color: colors.textPrimary, marginTop: spacing.md },
  marqueSous: { ...typography.caption, color: colors.textMuted, textAlign: 'center' },
  form: {
    gap: spacing.lg,
  },
  error: {
    ...typography.caption,
    color: colors.danger,
  },
  footer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.sm,
    marginTop: spacing.md,
  },
  footerText: {
    ...typography.body,
    color: colors.textMuted,
  },
  link: {
    ...typography.body,
    color: colors.accent,
  },
});
