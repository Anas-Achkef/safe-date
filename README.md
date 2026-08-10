# Safe Date — application mobile

Application Expo (React Native) branchée sur le back-end Supabase existant.
Le schéma de la base n'est ni créé ni modifié par ce dépôt.

## Démarrer

```sh
npm install
cp .env.example .env   # puis renseigner la clé anon
npm run web            # itération dans le navigateur, http://localhost:8081
npm start              # puis « i » pour iOS, « a » pour Android, ou scan Expo Go
```

**Le mode web est un outil de développement, pas une cible de livraison.**
`react-native-web` permet d'itérer sur l'interface avec rechargement à chaud,
mais gestes, animations natives et permissions se comportent différemment :
toute évolution doit être revalidée dans Expo Go avant livraison.

Les variables `EXPO_PUBLIC_*` sont lues au démarrage du bundler : après toute
modification du `.env`, relancer avec `npx expo start --clear`.

## Architecture

| Dossier | Rôle |
|---|---|
| `app/` | Routes expo-router. Un fichier = un écran. |
| `src/api/` | Seul endroit où `supabase.rpc()` est appelé. Un module par domaine. |
| `src/types/rpc.ts` | Signatures des 21 RPC, transcrites du catalogue Postgres. |
| `src/types/database.ts` | Types générés (`supabase gen types typescript`). |
| `src/theme.ts` | **Seule** source de valeurs visuelles. |
| `src/hooks/` | Session partagée, chargement de la découverte. |
| `src/components/` | Composants d'affichage, sans appel réseau. |

Deux règles structurantes :

1. Aucun appel `.rpc()` en dehors de `src/api/`.
2. Aucune couleur, taille, espacement ou rayon en dehors de `src/theme.ts`.
   La direction artistique n'étant pas arrêtée, ce fichier est remplaçable seul.

## Contraintes du back-end

La quasi-totalité des tables est en lecture seule ou fermée par RLS. Les
écritures passent par des fonctions RPC qui lisent l'identité dans `auth.uid()` :
aucune ne prend d'identifiant utilisateur en paramètre.

- `profile_answers` est en select seul — on écrit par `submit_answer`.
- `engine_params` et `option_mappings` sont inaccessibles depuis l'application.
- `compat_score` refuse de calculer pour un profil absent d'`eligible_candidates`.
- `reveal_establishment` échoue au-delà de 25 m du point de rendez-vous.

Une erreur `42501` n'est pas un défaut à contourner : c'est soit une session
absente, soit un appel à la mauvaise fonction. Voir `src/api/errors.ts`.

## Contrats en attente côté base

### `candidate_age(autre uuid) -> integer`

Le produit est anonyme avant le rendez-vous : `profiles` ne contient ni nom ni
prénom, et sa RLS est restreinte à `id = auth.uid()`. L'écran Découverte ne peut
donc afficher qu'un identifiant court dérivé de l'uuid et les scores.

Seul l'âge est attendu. `src/api/discovery.ts` appelle déjà cette fonction et
retombe silencieusement sur `null` tant qu'elle n'existe pas (`PGRST202`) :
l'écran fonctionne dans les deux cas, et se remplira sans changement de code.

Si la fonction porte finalement un autre nom, ajuster la constante
`CANDIDATE_AGE_FUNCTION` dans `src/types/rpc.ts`.

### Création de la ligne `profiles`

Il n'existe aucun déclencheur sur `auth.users` : un compte fraîchement inscrit
n'a pas de ligne dans `profiles`, et `user_progress()` renvoie zéro ligne. Cet
état est traité comme « compte incomplet » et redirige vers `(onboarding)`.
La saisie de la date de naissance et des préférences de recherche n'est couverte
par aucune RPC publique à ce jour.

## Dette assumée

`eligible_candidates()` ne renvoie que des identifiants : la découverte fait donc
un appel `compat_score` par candidat, par lots de 8. Indolore sur les volumes
actuels, à remplacer par une RPC de scoring par lot avant la mise en production.
