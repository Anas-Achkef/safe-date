---
name: conventions
description: Vérifie les règles structurantes de Safe Date — accès aux données confiné à src/api/, valeurs visuelles confinées à theme.ts, absence de service_role, et pièges React Native déjà rencontrés. À lancer avant de terminer toute tâche qui touche au code, et après tout ajout de composant ou d'écran.
---

# Conventions Safe Date

Lancer la vérification :

    .claude/skills/conventions/verifier.sh

Le script ne modifie rien. Il sort `0` si tout passe, `1` sinon, et cite le
fichier et la ligne de chaque manquement.

## Ce qu'il contrôle

**Accès aux données** — aucun `supabase.rpc()` ni `supabase.from()` hors de
`src/api/`. Les écrans et composants passent par la couche d'accès, jamais
directement par le client.

**Clé de service** — aucune référence à `service_role` dans le code livré.
Elle contourne la RLS et serait extractible du binaire.

**Valeurs visuelles** — aucune couleur littérale hors de `src/theme.ts`.
`src/lib/webFrame.ts` est excepté : il produit du CSS pour le navigateur.

**Pièges déjà payés** — `crypto.randomUUID` (absent sur React Native), les
propriétés `shadow*` et `props.pointerEvents` (dépréciées), et le centrage par
`top: '50%'` en position absolue, qui aligne le bord supérieur et non le
centre.

**Schéma** — rappelle les propositions SQL en attente dans `db/`. Elles ne
s'appliquent jamais depuis une session : c'est le responsable du projet qui
les passe en migration.

## Les commentaires ne déclenchent rien

Une règle rappelée en prose n'est pas une infraction : les lignes débutant par
`*`, `//` ou `#` sont écartées. Sans ce filtre, le commentaire qui interdit
`service_role` se signalait lui-même.

## Ajouter une règle

Chaque contrôle est un bloc de trois lignes dans `verifier.sh` : un appel à
`chercher`, puis `signaler` ou `valider`. Une règle mérite d'y entrer quand
elle a coûté un aller-retour au moins une fois.
