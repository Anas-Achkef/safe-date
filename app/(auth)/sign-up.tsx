import { Link } from 'expo-router';
import { useState } from 'react';
import { KeyboardAvoidingView, Platform, StyleSheet, Text, View } from 'react-native';

import { signUpWithEmail } from '../../src/api/auth';
import { userFacingMessage } from '../../src/api/errors';
import { Button } from '../../src/components/Button';
import { Screen } from '../../src/components/Screen';
import { TextField } from '../../src/components/TextField';
import { colors, spacing, typography } from '../../src/theme';

/** Longueur minimale imposee par defaut par Supabase Auth. */
const MIN_PASSWORD_LENGTH = 6;

export default function SignUp() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const submit = async () => {
    setLoading(true);
    setError(null);
    setNotice(null);
    try {
      const result = await signUpWithEmail(email.trim(), password);
      if (result.confirmationRequired) {
        setNotice(
          'Compte créé. Ouvre le lien de confirmation envoyé par e-mail, puis reviens te connecter.',
        );
      }
      // Si le projet n'exige pas de confirmation, la session arrive par
      // l'ecouteur et la navigation suit automatiquement.
    } catch (err) {
      setError(userFacingMessage(err));
    } finally {
      setLoading(false);
    }
  };

  const passwordTooShort = password.length > 0 && password.length < MIN_PASSWORD_LENGTH;

  return (
    <Screen title="Créer un compte" subtitle="Quelques secondes suffisent.">
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
          autoComplete="new-password"
          placeholder="Au moins 6 caractères"
          textContentType="newPassword"
          errorText={passwordTooShort ? `Au moins ${MIN_PASSWORD_LENGTH} caractères.` : null}
        />

        {error ? <Text style={styles.error}>{error}</Text> : null}
        {notice ? <Text style={styles.notice}>{notice}</Text> : null}

        <Button
          label="Créer mon compte"
          onPress={() => void submit()}
          loading={loading}
          disabled={email.length === 0 || password.length < MIN_PASSWORD_LENGTH}
        />

        <View style={styles.footer}>
          <Text style={styles.footerText}>Déjà inscrit ?</Text>
          <Link href="/(auth)/sign-in" style={styles.link}>
            Se connecter
          </Link>
        </View>
      </KeyboardAvoidingView>
    </Screen>
  );
}

const styles = StyleSheet.create({
  form: {
    gap: spacing.lg,
  },
  error: {
    ...typography.caption,
    color: colors.danger,
  },
  notice: {
    ...typography.caption,
    color: colors.accent,
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
