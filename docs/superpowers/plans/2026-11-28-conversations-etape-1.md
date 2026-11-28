# Conversations de 5 minutes, étape 1 — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Faire fonctionner une conversation de 5 minutes de bout en bout entre deux vrais comptes, sur le back-end actuel, sans aucun changement de base.

**Architecture:** La logique de temps et d'étapes vit dans un module pur (`src/lib/conversationLive.ts`), testé par `node --test`. Un hook (`useConversationLive`) orchestre présence, rafraîchissement et cycle de vie de l'écran ; l'écran et la liste ne font qu'afficher. Tous les appels Supabase restent dans `src/api/conversations.ts`.

**Tech Stack:** Expo SDK 57, expo-router, React Native 0.86, TypeScript strict, Supabase JS, `node --test` avec `--experimental-strip-types` (Node 22+).

**Spec:** `docs/superpowers/specs/2026-11-28-conversations-design.md` (section « Ordre de livraison », étape 1)

## Global Constraints

- Branche de travail : `conversations-5-minutes` (partie de `redesign`).
- **Aucun changement de base, aucun fichier `db/` dans ce plan.** Seules les fonctions déjà en base sont appelées : `rejoindre_conversation(conversation)`, `signaler_presence()`, `etat_conversation(conversation)`, `envoyer_message(conv, p_kind, p_body, p_media, p_duree)`, et les lectures directes de `conversations` et `messages` (policies `p_conv_partie`, `p_msg_partie`).
- Aucun `.rpc()` ni `.from()` hors de `src/api/`. Les composants ne font aucun appel réseau.
- Aucune couleur, taille, espacement, rayon ou durée d'animation hors de `src/theme.ts`. Les intervalles de rafraîchissement ne sont pas des valeurs visuelles : ils vivent dans `src/lib/conversationLive.ts`.
- Identifiants en anglais ou en français comme le code voisin ; **interface en français avec accents et apostrophes typographiques (’)**.
- Le temps restant vient du serveur (`secondes_restantes`) ; l'application ne fait que le décompter entre deux lectures et le resynchronise à chaque lecture.
- Présence : le serveur ne compte quelqu'un présent que 45 s (`presence_fraicheur_s`). Appel à `rejoindre_conversation` toutes les **15 s** tant que l'écran est au premier plan.
- Rafraîchissement : état et nouveaux messages toutes les **3 s** quand la conversation est `active`, toutes les **10 s** sinon.
- Décision de fin : **Oui ou Non uniquement**. Dans cette étape, l'envoi réel n'existe pas encore (RPC à l'étape 2) : hors aperçu, il lève une `ApiError` de type `missing_function`.
- Textes fixés par la spec : « Le temps est écoulé », « Souhaitez-vous vous voir ? », « Votre réponse est enregistrée. », « C’est réciproque ! », « Ce ne sera pas pour cette fois. ».
- Avant de terminer chaque tâche : `npx tsc --noEmit`, `.claude/skills/conventions/verifier.sh`, et `npm test` à partir de la tâche 1.

## Review Focus

1. **Application mise en arrière-plan pendant les 5 minutes** : présence et rafraîchissement s'arrêtent ; au retour, une lecture immédiate resynchronise le chrono et le fil (test : `useConversationLive` relit dès `AppState` = `active` — vérification manuelle tâche 4, étape 6).
2. **Le temps atteint 0 pendant la saisie** : la zone de saisie se ferme à 0 sans attendre le verrouillage serveur (jusqu'à 60 s de retard), et un refus du serveur à l'envoi garde le brouillon (test : `etapeDe` renvoie `temps_ecoule` quand le restant local vaut 0 et que le statut est encore `active`, tâche 1).
3. **Coupure réseau pendant un rafraîchissement** : le fil et le chrono déjà affichés restent, une erreur discrète s'affiche, le rafraîchissement continue (test : `fusionnerMessages` ne perd rien sur un lot vide, tâche 1 ; vérification manuelle tâche 4).
4. **Doublons de messages** : deux lectures successives qui se chevauchent ne dupliquent pas une bulle (test : `fusionnerMessages` dédoublonne par `id` et trie par `created_at`, tâche 1).
5. **Quitter l'écran** : plus aucun appel à `rejoindre_conversation` une fois l'écran quitté, sinon la personne paraît présente alors qu'elle est partie (vérification manuelle tâche 4, étape 6).

---

### Task 1: Logique pure du temps et des étapes

**Files:**
- Create: `src/lib/conversationLive.ts`
- Create: `tests/conversationLive.test.mjs`
- Modify: `package.json` (scripts)

**Interfaces:**
- Consumes: `EtatConversation`, `Message` de `src/types/conversations.ts` (en `import type` seulement : le module doit rester exécutable par Node sans dépendance).
- Produces:
  - `type EtapeConversation = 'attente' | 'decompte' | 'active' | 'temps_ecoule' | 'decision_envoyee' | 'illimitee' | 'close'`
  - `const INTERVALLE_PRESENCE_MS = 15_000`
  - `function intervalleRafraichissement(statut: ConversationStatus): number` → `3_000` si `'active'`, sinon `10_000`
  - `function restantSecondes(serveur: number | null, recuA: number, maintenant: number): number | null` → `null` si `serveur` est `null`, sinon `max(0, serveur - floor((maintenant - recuA) / 1000))`
  - `function formaterChrono(secondes: number): string` → `m:ss`
  - `function etapeDe(e: { statut: ConversationStatus; illimitee: boolean; restant: number | null; decompteJusqua: number | null; decisionEnvoyee: boolean }, maintenant: number): EtapeConversation`
  - `function fusionnerMessages(actuels: Message[], nouveaux: Message[]): Message[]`

- [ ] **Step 1: Write the failing tests** in `tests/conversationLive.test.mjs`, importing `../src/lib/conversationLive.ts`:

```js
import test from 'node:test';
import assert from 'node:assert/strict';
import { etapeDe, formaterChrono, fusionnerMessages, intervalleRafraichissement,
         restantSecondes, INTERVALLE_PRESENCE_MS } from '../src/lib/conversationLive.ts';

const base = { statut: 'active', illimitee: false, restant: 120, decompteJusqua: null, decisionEnvoyee: false };

test('formaterChrono', () => {
  assert.equal(formaterChrono(300), '5:00');
  assert.equal(formaterChrono(245), '4:05');
  assert.equal(formaterChrono(9), '0:09');
  assert.equal(formaterChrono(0), '0:00');
});

test('restantSecondes décompte depuis la dernière lecture serveur', () => {
  assert.equal(restantSecondes(null, 0, 5_000), null);
  assert.equal(restantSecondes(120, 1_000, 1_999), 120);
  assert.equal(restantSecondes(120, 1_000, 11_000), 110);
  assert.equal(restantSecondes(5, 0, 60_000), 0);
});

test('intervalles', () => {
  assert.equal(INTERVALLE_PRESENCE_MS, 15_000);
  assert.equal(intervalleRafraichissement('active'), 3_000);
  assert.equal(intervalleRafraichissement('prete'), 10_000);
  assert.equal(intervalleRafraichissement('verrouillee'), 10_000);
});

test('etapeDe', () => {
  assert.equal(etapeDe({ ...base, statut: 'prete', restant: null }, 0), 'attente');
  assert.equal(etapeDe({ ...base, decompteJusqua: 3_000 }, 1_000), 'decompte');
  assert.equal(etapeDe({ ...base, decompteJusqua: 3_000 }, 3_000), 'active');
  assert.equal(etapeDe(base, 0), 'active');
  // Le serveur verrouille jusqu'à 60 s après la fin : on n'attend pas son statut.
  assert.equal(etapeDe({ ...base, restant: 0 }, 0), 'temps_ecoule');
  assert.equal(etapeDe({ ...base, statut: 'verrouillee', restant: null }, 0), 'temps_ecoule');
  assert.equal(etapeDe({ ...base, statut: 'verrouillee', restant: null, decisionEnvoyee: true }, 0), 'decision_envoyee');
  assert.equal(etapeDe({ ...base, illimitee: true, restant: null }, 0), 'illimitee');
  assert.equal(etapeDe({ ...base, statut: 'cloturee', restant: null }, 0), 'close');
});

test('fusionnerMessages dédoublonne et trie', () => {
  const m = (id, t) => ({ id, conversation_id: 'c', sender_id: 's', kind: 'texte', body: id,
                          audio_path: null, duration_ms: null, created_at: t });
  const a = [m('1', '2026-11-28T10:00:00Z'), m('2', '2026-11-28T10:00:01Z')];
  assert.deepEqual(fusionnerMessages(a, []), a);
  const r = fusionnerMessages(a, [m('2', '2026-11-28T10:00:01Z'), m('3', '2026-11-28T10:00:02Z'), m('0', '2026-11-28T09:59:59Z')]);
  assert.deepEqual(r.map((x) => x.id), ['0', '1', '2', '3']);
});
```

- [ ] **Step 2: Add the test script** to `package.json`: `"test": "node --experimental-strip-types --test tests/"`, and make `verif` run `npm run typecheck && npm test && npm run conventions`.

- [ ] **Step 3: Run the tests to verify they fail**

Run: `npm test`
Expected: FAIL, module `src/lib/conversationLive.ts` not found.

- [ ] **Step 4: Implement `src/lib/conversationLive.ts`** with the signatures of the Interfaces block. `etapeDe` checks in this order: `illimitee` → `'illimitee'`; `statut === 'cloturee'` → `'close'`; `decisionEnvoyee` → `'decision_envoyee'`; `statut === 'verrouillee'` or (`statut === 'active'` and `restant === 0`) → `'temps_ecoule'`; `decompteJusqua !== null && maintenant < decompteJusqua` → `'decompte'`; `statut === 'active'` → `'active'`; otherwise `'attente'`. Only `import type` from `../types/conversations`.

- [ ] **Step 5: Run the tests to verify they pass**

Run: `npm test` then `npx tsc --noEmit`
Expected: `# pass 5`, `# fail 0` ; tsc sans erreur.

- [ ] **Step 6: Commit**

```bash
git add src/lib/conversationLive.ts tests/conversationLive.test.mjs package.json
git commit -m "Ajoute la logique de temps et d'etapes des conversations"
```

### Task 2: Accès serveur et données de démonstration

**Files:**
- Modify: `src/types/conversations.ts` (ajout `RejoindreResultat`, `illimitee` ; retrait de `non_lus`)
- Modify: `src/api/conversations.ts` (`joinConversation`, `signalPresence`, `listConversations`, `loadConversationState`, `loadMessages`, `decideConversation` ; retrait de `markConversationRead`)
- Modify: `src/preview/etat.ts` (fils de démonstration couvrant chaque étape)

**Interfaces:**
- Consumes: rien des autres tâches.
- Produces:
  - `interface RejoindreResultat { statut: ConversationStatus; demarree: boolean; attend_qui: string | null; decompte_s: number; secondes_restantes: number | null }`
  - `EtatConversation` gagne `illimitee: boolean`. `ResumeConversation` gagne `illimitee: boolean` et perd `non_lus`.
  - `joinConversation(conversation: string): Promise<RejoindreResultat | null>` — première ligne renvoyée par `rejoindre_conversation`.
  - `signalPresence(): Promise<void>` — appelle `signaler_presence()`.
  - `loadConversationState(conversation: string): Promise<EtatConversation | null>` — `etat_conversation` plus `illimitee` lu dans `conversations`.
  - `loadMessages(conversation: string, depuis?: string): Promise<Message[]>` — inchangé en vrai ; en aperçu, renvoie `demo.messages(id)` filtré sur `depuis`.
  - `listConversations(): Promise<ResumeConversation[]>` — hors aperçu : lit `conversations` (colonnes `id, status, illimitee, prete_at, started_at`), trie par `coalesce(started_at, prete_at)` décroissant, complète chaque ligne par `etat_conversation` (prénom, en ligne, secondes restantes) et par le dernier message lu dans `messages` (une seule requête pour toutes les conversations, `order created_at desc`, premier par conversation). `age_autre` et `photo_autre` valent `null`.
  - `decideConversation(conversation: string, decision: 'oui' | 'non'): Promise<void>` — aperçu : `demo.deciderConversation` ; sinon lève `new ApiError('missing_function', 'Enregistrement de la décision', null)`.
  - Démo (`src/preview/etat.ts`) : `rejoindreConversation(id): RejoindreResultat`, `deciderConversation(id, decision)`, et `decisionDe(id): 'oui' | 'non' | null`. Au moins un fil par cas : `prete` avec l'autre hors ligne ; `prete` qui démarre au premier `rejoindreConversation` (`demarree: true`, `decompte_s: 3`, `secondes_restantes: 300`) ; `active` à 47 s ; `verrouillee` ; `illimitee`.

- [ ] **Step 1: Update the types**, then run `npx tsc --noEmit`.
Expected: erreurs aux usages de `non_lus` et `markConversationRead` (liste, écran, démo) — elles disparaissent aux tâches 2 à 4.

- [ ] **Step 2: Implement the API functions** of the Interfaces block in `src/api/conversations.ts`, each wrapping errors with `toApiError(error, '<contexte en français>')` like its neighbors.

- [ ] **Step 3: Implement the demo functions and fixtures** in `src/preview/etat.ts`; remove `marquerLu` and every `non_lus`.

- [ ] **Step 4: Verify**

Run: `npm test && npx tsc --noEmit 2>&1 | grep -v "app/" ; .claude/skills/conventions/verifier.sh`
Expected: tests verts ; plus aucune erreur tsc hors de `app/` ; conventions respectées.

- [ ] **Step 5: Commit**

```bash
git add src/types/conversations.ts src/api/conversations.ts src/preview/etat.ts
git commit -m "Branche presence, liste et decision des conversations sur le serveur"
```

### Task 3: Présence au premier plan

**Files:**
- Modify: `app/_layout.tsx`

**Interfaces:**
- Consumes: `signalPresence()` (tâche 2).
- Produces: rien.

- [ ] **Step 1: Call `signalPresence()`** une fois au montage quand une session existe, puis à chaque passage d'`AppState` à `'active'`. Jamais en mode aperçu. Une erreur est ignorée en silence (c'est un signe de vie, pas une action de l'utilisateur).

- [ ] **Step 2: Verify**

Run: `npx tsc --noEmit 2>&1 | grep "_layout" ; .claude/skills/conventions/verifier.sh`
Expected: aucune erreur dans `app/_layout.tsx` ; conventions respectées.

- [ ] **Step 3: Commit**

```bash
git add app/_layout.tsx
git commit -m "Signale la presence au retour au premier plan"
```

### Task 4: Écran de conversation en direct

**Files:**
- Create: `src/hooks/useConversationLive.ts`
- Create: `src/components/DecisionFin.tsx`
- Modify: `app/conversation/[id].tsx`
- Modify: `src/theme.ts` (si un jeton manque pour le chrono ou la décision)

**Interfaces:**
- Consumes: tâche 1 (tout le module), tâche 2 (`joinConversation`, `loadConversationState`, `loadMessages`, `sendMessage`, `decideConversation`, `RejoindreResultat`).
- Produces:
  - `useConversationLive(id: string): { etat: EtatConversation | null; fil: Message[]; etape: EtapeConversation; restant: number | null; chargement: boolean; erreur: string | null; envoyer(corps: string): Promise<boolean>; decider(d: 'oui' | 'non'): Promise<void>; decision: 'oui' | 'non' | null }`
  - `DecisionFin({ decision, resultat, enCours, erreur, onDecider }: { decision: 'oui' | 'non' | null; resultat: 'reciproque' | 'pas_cette_fois' | null; enCours: boolean; erreur: string | null; onDecider(d: 'oui' | 'non'): void })` — affichage seul.

- [ ] **Step 1: Write `useConversationLive`.**
  - Au focus de l'écran (`useFocusEffect` d'expo-router) et tant qu'`AppState` vaut `'active'` : appelle `joinConversation` tout de suite puis toutes les `INTERVALLE_PRESENCE_MS` ; lit état et messages tout de suite puis toutes les `intervalleRafraichissement(etat.statut)` ; arrête tout à la perte du focus ou au passage en arrière-plan ; relit immédiatement au retour.
  - Si `joinConversation` renvoie `demarree: true`, retient `decompteJusqua = Date.now() + decompte_s * 1000`.
  - Retient `recuA = Date.now()` à chaque lecture d'état ; un minuteur d'une seconde met à jour `restant = restantSecondes(etat.secondes_restantes, recuA, Date.now())` et `etape = etapeDe(...)`.
  - Les nouveaux messages sont lus avec `depuis` = `created_at` du dernier connu et fusionnés par `fusionnerMessages`.
  - Une erreur de lecture garde l'état et le fil affichés et renseigne `erreur` ; la lecture suivante l'efface si elle réussit.
  - `envoyer` renvoie `false` et garde le brouillon chez l'appelant si le serveur refuse.

- [ ] **Step 2: Write `DecisionFin`** : titre « Le temps est écoulé », question « Souhaitez-vous vous voir ? », deux boutons « Oui » et « Non » (composant `Bouton` de `src/components/ui/`). Après la réponse : « Votre réponse est enregistrée. » ; si `resultat` vaut `'reciproque'` : « C’est réciproque ! » ; `'pas_cette_fois'` : « Ce ne sera pas pour cette fois. ». `erreur` s'affiche sous les boutons sans les masquer.

- [ ] **Step 3: Rewrite `app/conversation/[id].tsx`** on the hook. Par étape :

| `etape` | Affichage | Saisie |
|---|---|---|
| `attente` | `etat.message` du serveur dans le bandeau de consigne | fermée |
| `decompte` | « 3 », « 2 », « 1 » en grand, calculé depuis `decompteJusqua` | fermée |
| `active` | fil, chrono `formaterChrono(restant)` dans l'en-tête | ouverte |
| `temps_ecoule` / `decision_envoyee` | fil en lecture seule, puis `DecisionFin` | fermée |
| `illimitee` | fil, sans chrono | ouverte |
| `close` | fil en lecture seule, « Conversation close. » | fermée |

  `resultat` vaut `null` dans cette étape hors aperçu (aucune fonction ne le sert encore) ; en aperçu, `'reciproque'` si `demo.decisionDe` vaut `'oui'`. Retirer `delai()` et l'appel à `markConversationRead`.

- [ ] **Step 4: Verify types and conventions**

Run: `npm test && npx tsc --noEmit && .claude/skills/conventions/verifier.sh`
Expected: tout vert.

- [ ] **Step 5: Verify in the browser with the preview data** (skill `demarrer`, `EXPO_PUBLIC_PREVIEW=1`). Ouvrir chaque fil de démonstration et constater l'affichage du tableau de l'étape 3 : la conversation qui démarre montre 3, 2, 1 puis `5:00` qui décroît ; celle à 47 s passe à « Le temps est écoulé » et ferme la saisie à `0:00` ; la décision « Oui » affiche « Votre réponse est enregistrée. » puis « C’est réciproque ! ».

- [ ] **Step 6: Verify the lifecycle by hand.** Dans les outils réseau du navigateur : les appels `rejoindre_conversation` partent toutes les 15 s écran ouvert et **cessent** quand on revient à la liste ; onglet du navigateur masqué puis réaffiché → une lecture immédiate. Réseau coupé (mode hors ligne des outils) pendant une conversation active → le fil reste, un message d'erreur discret apparaît, il disparaît au retour du réseau.

- [ ] **Step 7: Commit**

```bash
git add src/hooks/useConversationLive.ts src/components/DecisionFin.tsx "app/conversation/[id].tsx" src/theme.ts
git commit -m "Fait vivre l'ecran de conversation : presence, chrono et decision"
```

### Task 5: Liste des conversations

**Files:**
- Modify: `app/(tabs)/conversations.tsx`

**Interfaces:**
- Consumes: `listConversations()`, `ResumeConversation` sans `non_lus` (tâche 2) ; `formaterChrono` (tâche 1).
- Produces: rien.

- [ ] **Step 1: Replace the unread badge** by a subtitle per conversation: `prete` → « Votre conversation vous attend » ; `active` et `secondes_restantes` non nul → « En cours · » suivi de `formaterChrono(secondes_restantes)` ; `verrouillee` → « Le temps est écoulé » ; `illimitee` → l'extrait du dernier message ; `cloturee` → « Conversation close ».

- [ ] **Step 2: Refresh the list** au focus de l'onglet (`useFocusEffect`), pour qu'un retour depuis une conversation montre son nouvel état.

- [ ] **Step 3: Verify**

Run: `npm test && npx tsc --noEmit && .claude/skills/conventions/verifier.sh`
Expected: tout vert, plus aucune erreur tsc dans le projet.
Puis dans le navigateur, en aperçu : chaque fil de démonstration montre le sous-titre attendu.

- [ ] **Step 4: Verify with two real accounts** (si deux comptes de test ont une conversation `prete` en base) : la liste n'est plus vide ; ouvrir la conversation sur les deux comptes, dans deux navigateurs, démarre le décompte sur les deux à quelques secondes près.

- [ ] **Step 5: Commit and update the spec**

Dans la spec, section « 1. Base de données », remplacer le paragraphe sur `mes_conversations()` par : « La liste est construite côté application à partir des lectures directes de `conversations` et `messages` (policies existantes) et d'`etat_conversation` ; `mes_conversations()` n'est plus nécessaire. »

```bash
git add "app/(tabs)/conversations.tsx" docs/superpowers/specs/2026-11-28-conversations-design.md
git commit -m "Affiche les vraies conversations et leur etape dans la liste"
```
