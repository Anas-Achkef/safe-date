import 'react-native-url-polyfill/auto';

import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';
import { AppState } from 'react-native';

import type { Database } from '../types/database';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    "Variables d'environnement Supabase manquantes. Copier .env.example vers .env " +
      'puis relancer avec `npx expo start --clear` (les variables EXPO_PUBLIC_ sont ' +
      'lues au demarrage du bundler).',
  );
}

/**
 * Client unique de l'application.
 *
 * La cle utilisee est la cle anon publique : toute la securite repose sur la
 * RLS et sur des fonctions RPC qui lisent l'identite dans auth.uid(). Aucune
 * cle service_role ne doit apparaitre cote application.
 *
 * detectSessionInUrl est desactive : c'est un mecanisme web (OAuth par
 * redirection de navigateur) sans objet en React Native.
 */
export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

/**
 * Le rafraichissement automatique du jeton doit suivre le cycle de vie de
 * l'application : le laisser tourner en arriere-plan provoque des erreurs de
 * reseau inutiles et vide la batterie.
 */
AppState.addEventListener('change', (state) => {
  if (state === 'active') {
    void supabase.auth.startAutoRefresh();
  } else {
    void supabase.auth.stopAutoRefresh();
  }
});
