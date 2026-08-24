# Safe Date — conventions du projet

Application mobile de rencontre. Expo (React Native) + TypeScript strict,
expo-router, Supabase. Client : Prom'us.

## Expo a changé

Lire la documentation versionnée : https://docs.expo.dev/versions/v57.0.0/
Le SDK est en 57 — les réponses trouvées en ligne visent souvent des versions
antérieures et ne s'appliquent pas.

## Le back-end est déployé et fermé

**Ne jamais modifier le schéma de la base, ne créer aucune migration
appliquée depuis une session.** Le back-end a été audité et chaque contrainte
a une raison. Les propositions de schéma vont dans `db/`, en SQL relu, et
c'est le responsable du projet qui les applique.

- La quasi-totalité des tables est en lecture seule ou fermée par RLS.
- Les écritures passent par des RPC qui lisent l'identité dans `auth.uid()`.
  Aucune fonction publique ne prend d'identifiant utilisateur en paramètre :
  si on est tenté de passer un `user_id`, c'est qu'on se trompe de fonction.
- Exceptions vérifiées, écrivables directement par leur propriétaire :
  `swipe_decisions`, `user_acceptances`, `user_photos`.
- **Jamais la clé `service_role` côté application** : elle contourne la RLS et
  serait extractible du binaire.
- Une erreur `42501` n'est pas un défaut à contourner : c'est une session
  absente ou un appel à la mauvaise fonction. Voir `src/api/errors.ts`.

## Règles d'architecture

1. **Aucun appel `.rpc()` ou `.from()` hors de `src/api/`.** Les écrans et les
   composants ne parlent jamais à Supabase directement.
2. **Aucune valeur visuelle hors de `src/theme.ts`** — couleur, taille,
   espacement, rayon, durée. La direction artistique doit rester remplaçable
   en changeant ce seul fichier.
3. **Aucun champ n'est supposé présent.** `candidate_cards` renvoie `null` sur
   le prénom, la photo et tous les scores au-delà du seuil premium. Un champ
   absent se rend en glyphes de même chasse, jamais en `0`.
4. Code et identifiants en anglais, **interface en français** — accents
   compris dans les chaînes affichées.

## Pièges déjà rencontrés

- **`onLayout` ne se déclenche pas toujours en web.** Ne jamais conditionner
  l'affichage d'un écran à une mesure : partir d'une hauteur calculée et
  affiner ensuite. Un écran noir est presque toujours ça.
- **`pagingEnabled` et `snapToInterval` ne sont pas honorés par
  react-native-web.** Le `scroll-snap` CSS injecté par `src/lib/webFrame.ts`
  prend le relais.
- **`crypto.randomUUID()` n'est pas garanti sur React Native.** Il fonctionne
  dans le navigateur et échoue sur téléphone.
- **`now()` est interdit dans un prédicat d'index Postgres** et rend une
  fonction `stable`, jamais `immutable`.
- **`candidate_cards.photo` renvoie un chemin de stockage, pas une URL.** Il
  faut le signer avant de le passer à un composant `Image`.
- Les propriétés `shadow*` et `props.pointerEvents` sont dépréciées :
  utiliser `boxShadow` et `style.pointerEvents`.

## Développement

Pas de Xcode complet ni de SDK Android sur la machine : **aucun simulateur**.
L'itération se fait dans le navigateur, la validation sur Expo Go.

    npm run web     # navigateur, cadre 390 × 844 forcé
    npm start       # Expo Go

`EXPO_PUBLIC_PREVIEW=1` ouvre l'application sans authentification, avec des
données de démonstration. Compte de développement : `dev@safedate.test`.

Les variables `EXPO_PUBLIC_*` sont lues au démarrage du bundler : après toute
modification du `.env`, relancer avec `--clear`.

Le navigateur garde la feuille de style injectée en cache : si une
modification de `webFrame.ts` ne se voit pas, rouvrir avec un paramètre
d'URL différent plutôt que de rafraîchir.

## Vérifier avant de terminer

    npx tsc --noEmit
    .claude/skills/conventions/verifier.sh
