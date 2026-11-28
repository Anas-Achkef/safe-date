# Conversations de 5 minutes — conception

Date : 28 novembre 2026 · Branche de départ : `redesign` (commit `36938ed`)

## Intention

Safe Date propose une conversation chronométrée de 5 minutes entre deux
personnes qui se sont choisies. Elle sert à une seule chose : **décider si l'on
se voit en vrai**. Le cœur du produit étant ensuite le rendez-vous, une
conversation qui ne démarre jamais, ou dont l'un perd les minutes parce qu'il
n'était pas là, est une rencontre perdue.

Aujourd'hui, sur `redesign`, l'onglet Discussions et l'écran
`app/conversation/[id].tsx` existent, mais ne fonctionnent qu'en mode aperçu :

- le chrono ne démarre jamais : l'écran n'appelle ni `rejoindre_conversation`
  ni `signaler_presence` ;
- rien ne se rafraîchit : ni les messages de l'autre, ni la fin du temps ;
- la liste des conversations est vide hors aperçu (`listConversations()`
  renvoie `[]`, faute de fonction `mes_conversations`) ;
- le temps restant s'affiche en heures et en jours ;
- aucune décision n'est demandée à la fin.

## Le parcours voulu

Décidé avec le responsable du projet :

1. Deux « oui » créent une conversation **prête** (inchangé).
2. **A écrit un premier message**, sans chrono. A peut quitter l'application.
3. **B reçoit une notification** et répond quand il veut. Toujours pas de chrono.
4. **A reçoit une notification** « B a répondu ». Quand A ouvre la conversation,
   **B reçoit** « A est là, rejoins-la ».
5. **Les deux sont sur l'écran en même temps** : décompte 3, 2, 1, puis 5
   minutes d'échange en direct. C'est le mécanisme de présence conjointe déjà
   en base (`rejoindre_conversation`, migration M10).
6. À la fin, la conversation se **verrouille** pour les deux au même instant, et
   chacun répond à « Souhaitez-vous vous voir ? » : oui ou non.

Si l'un ne revient pas, rien n'est perdu : l'autre peut repartir et sera
prévenu au retour suivant. La limite reste la péremption de 48 h d'une
conversation prête (`conversation_prete_peremption_h`).

L'application demande l'autorisation des notifications ; sans elle, ce
parcours ne tient pas.

## Objectifs

- Une conversation peut aller de « prête » à « décision prise » avec deux
  vrais comptes, sans mode aperçu.
- Personne ne perd ses 5 minutes parce qu'il n'a pas vu une notification.
- Chacun est prévenu, application fermée, aux trois moments du parcours
  (premier message, réponse, retour de l'autre).

## Non-objectifs

- La suite d'un double « oui » final (choix du lieu, `venue_proposals`,
  création du rendez-vous) : parcours Rendez-vous, traité à part.
- Les messages vocaux et les photos : le texte suffit pour cette version.
  Le serveur refuse déjà les photos avant le rendez-vous.
- Une messagerie en temps réel par abonnement (Supabase Realtime) : le
  rafraîchissement périodique suffit pour des conversations de 5 minutes.
- Toute notification autre que les trois du parcours (marketing, rappels).

## Anti-objectifs

Ce qui ferait échouer le projet même si tout « marche » :

- **On ne passe jamais aux 5 minutes.** Les messages d'avant le chrono sont
  illimités (choix du responsable) : l'écran doit toujours montrer que la
  vraie rencontre se fait dans les 5 minutes en direct, et inviter à les
  lancer dès que les deux sont là.
- **Une notification révèle autre chose que le prénom.** Les notifications
  s'affichent sur l'écran verrouillé : ni contenu de message, ni photo, ni
  score.
- **L'adresse de notification d'un utilisateur atteint un autre téléphone.**
  Elle ne quitte jamais le serveur.
- **Une notification en rafale** parce que l'un ouvre et ferme l'application
  en boucle.

## Contraintes

- **Le back-end est fermé** (`AGENTS.md`) : aucune migration appliquée depuis
  une session. Tout changement de base est une proposition SQL dans `db/`,
  appliquée par le responsable. L'ordre de livraison en tient compte.
- **Aucun `.rpc()` ni `.from()` hors de `src/api/`**, aucune valeur visuelle
  hors de `src/theme.ts`, interface en français.
- **Notifications et Expo Go** : Expo Go ne reçoit plus les notifications à
  distance sur Android. Il faut une build de développement (EAS). Le
  comportement d'Expo Go sur iOS avec le SDK 57 est à vérifier dans la
  documentation versionnée avant le plan.
- **Aucun identifiant de projet EAS** dans `app.json` : il est obligatoire
  pour obtenir une adresse de notification Expo. Le créer demande le compte
  Expo du responsable.
- **Ta base n'a ni `pg_net` ni Edge Function.** Les activer et déployer sont
  des actions du responsable.
- La présence ne vaut que 45 s (`presence_fraicheur_s`) : l'écran ouvert doit
  redonner signe de vie plus souvent que ça.
- Le dépôt et la base divergent (constaté le 28 novembre : générateur de
  profils, colonne `famille`). Toute proposition SQL part des définitions
  **lues dans la base**, pas seulement des migrations du dépôt.

## Approches envisagées pour les notifications

| | Approche | Verdict |
|---|---|---|
| **A** | La base écrit chaque notification dans une **boîte d'envoi** ; un webhook Supabase déclenche une **Edge Function** qui l'envoie par le service Expo. | **Retenue.** L'adresse de notification reste sur le serveur ; envoi immédiat. Coût : activer `pg_net`, déployer une fonction. |
| B | Le téléphone de l'expéditeur envoie lui-même la notification à l'autre. | Écartée : l'application devrait connaître l'adresse de notification des autres, n'importe qui pourrait spammer un utilisateur. |
| C | Notifications seulement quand l'application est ouverte. | Écartée : personne n'est prévenu application fermée, ce qui va contre le parcours. |

Choix fait par Claude, le responsable ayant laissé la décision technique.

Pour le démarrage du chrono, deux options ont été discutées : à la réponse
de B (idée de départ du responsable) ou à la présence simultanée (retenue par
le responsable). La première faisait perdre ses minutes à celui qui ne voit
pas la notification à temps.

## Conception

### 1. Base de données — propositions dans `db/`

Trois fichiers, appliqués dans cet ordre par le responsable.

**`db/0xx-messages-avant-chrono.sql`**
- `private.envoyer_message` accepte un message quand la conversation est
  `prete`, dans la limite définie plus bas. En `active`, le comportement est
  inchangé ; en `verrouillee` ou `cloturee`, toujours refusé.
- Les règles de contenu (`motif_interdit`, pas de photo) s'appliquent aussi
  avant le chrono.
- `rejoindre_conversation` ne démarre le chrono que si **les deux** ont écrit
  au moins un message. Sans cette condition, deux personnes présentes par
  hasard démarreraient avant tout échange — le parcours voulu commence par
  un message.
- `etat_conversation` renvoie de quoi savoir où en est le parcours : nombre
  de messages de chacun avant le chrono, et à qui c'est le tour. Le libellé
  `message` suit les nouvelles étapes.
- Une fonction `mes_conversations()` remplace la liste vide : une ligne par
  conversation de l'appelant, aux champs de `ResumeConversation`
  (`src/types/conversations.ts`). Prénom, âge et photo de l'autre ne sont pas
  lisibles directement (RLS de `profiles`) : la fonction les sert.

**`db/0xx-notifications.sql`**
- Table `push_tokens` : une ligne par appareil (`user_id`, `token`, `plateforme`,
  `created_at`, `revoked_at`). Écriture par une RPC `enregistrer_appareil(token,
  plateforme)` qui lit `auth.uid()` ; aucune lecture côté application.
- Table `push_outbox` : `id`, `user_id` destinataire, `type`
  (`premier_message`, `reponse`, `nouveau_message`, `autre_arrive`), `conversation_id`,
  `created_at`, `sent_at`, `erreur`. Fermée par RLS.
- Écriture dans la boîte d'envoi par les fonctions du serveur, aux trois
  moments : premier message de A (→ B), premier message de B (→ A), et
  `rejoindre_conversation` quand l'autre est absent et que les deux ont écrit
  (→ l'autre).
- Les messages suivants, avant le chrono, déclenchent une notification
  `nouveau_message` (« Camille vous a écrit. ») seulement si le destinataire
  est absent, et au plus une par conversation toutes les 10 minutes : avec
  des messages illimités, une notification par message serait une rafale.
- **Anti-rafale** : au plus une notification `autre_arrive` par conversation
  et par destinataire toutes les 10 minutes (paramètre dans `engine_params`).
- Textes, prénom seul, jamais de contenu :
  - « Camille vous a écrit. »
  - « Théo vous a répondu. Ouvrez la conversation pour lancer vos 5 minutes. »
  - « Camille vous attend dans votre conversation. »

**`db/0xx-envoi-notifications.md`** (procédure, pas du SQL)
- Activer `pg_net`, créer le webhook sur l'insertion dans `push_outbox`,
  déployer l'Edge Function, enregistrer le jeton d'accès Expo comme secret de
  la fonction.

### 2. Edge Function `envoyer-notification`

Dans `supabase/functions/envoyer-notification/`. Reçoit la ligne insérée,
lit les jetons actifs du destinataire, appelle l'API d'envoi Expo, marque
`sent_at` ou `erreur`. Un jeton refusé par Expo comme invalide
(`DeviceNotRegistered`) est révoqué. Clé `service_role` côté fonction
seulement, jamais dans l'application.

### 3. Application

**`src/api/conversations.ts`** — seul point d'appel au serveur :
`listConversations` branché sur `mes_conversations()` ; `joinConversation` déjà
écrit ; `signalPresence()` ajouté ; `loadConversationState` lit les nouveaux
champs. **`src/api/notifications.ts`** (nouveau) : `registerDevice()`.

**Écran de conversation `app/conversation/[id].tsx`**, selon l'étape :

| Étape | Ce que voit la personne |
|---|---|
| Prête, personne n'a écrit | « Écrivez le premier message à Camille. » Zone de saisie ouverte. |
| J'ai écrit, l'autre non | Mon message, puis « Camille sera prévenue. Vous pouvez quitter l'application. » Saisie toujours ouverte. |
| L'autre a écrit, pas moi | Son message, saisie ouverte : « Répondez pour préparer vos 5 minutes. » |
| Les deux ont écrit, l'autre absent | Le fil, saisie ouverte, et « Vos 5 minutes démarreront quand vous serez là tous les deux. Camille sera prévenue. » |
| Les deux présents | Décompte 3, 2, 1. |
| Active | Fil en direct, compte à rebours en minutes et secondes, servi par le serveur. |
| Verrouillée | « Le temps est écoulé », puis la question « Souhaitez-vous vous voir ? » : Oui ou Non. |
| J'ai répondu, l'autre non | « Votre réponse est enregistrée. » Celle de l'autre n'est jamais montrée. |
| Oui et oui | « C'est réciproque ! », puis le parcours Rendez-vous (hors périmètre). |
| Réponses différentes ou non et non | « Ce ne sera pas pour cette fois. » Même message pour les deux : on ne révèle jamais qui a dit non. |

Tant que l'écran est ouvert : `rejoindre_conversation` toutes les 15 s
(présence), état et nouveaux messages toutes les 3 s en `active`, toutes les
10 s sinon. Arrêt quand l'écran perd le focus ou que l'application passe en
arrière-plan.

**Onglet Discussions** : la liste réelle, avec l'étape de chaque conversation
en sous-titre (« À vous d'écrire », « Camille vous attend »…).

**Notifications** : `expo-notifications`. Demande d'autorisation **au premier
double « oui »**, sur un écran qui explique pourquoi avant l'invite du
système. Un refus n'empêche rien : l'écran Discussions rappelle alors que les
notifications sont coupées. Appui sur une notification → ouvre la
conversation concernée. `signaler_presence` à chaque retour au premier plan.

**Mode aperçu** : les données de démonstration (`src/preview/`) couvrent
chaque étape du tableau, pour itérer dans le navigateur.

### 4. Décision de fin

Enregistrée dans `conversation_decisions`, dont la policy permet l'écriture
par son propriétaire. Ce n'est pas l'une des trois exceptions vérifiées de
`AGENTS.md` : à confirmer avec le responsable, ou passer par une RPC.

## Ordre de livraison

1. **Application seule, sur le back-end actuel** : présence, rafraîchissement,
   compte à rebours, décision de fin. Utile immédiatement : la conversation
   démarre quand les deux sont là.
2. Propositions SQL `messages-avant-chrono` et `mes_conversations`, puis
   l'application qui les utilise.
3. Notifications : SQL, Edge Function, build de développement, application.
   **Attend la création des comptes Expo et Apple.** D'ici là, les étapes de
   l'écran qui parlent de « sera prévenu(e) » disent seulement « Revenez plus
   tard, votre conversation vous attend ».

Chaque étape est livrable seule.

## Décisions de Claude, à vérifier par le responsable

- **Lecture de la base réelle autorisée** : les propositions SQL partent des
  définitions lues par des requêtes en lecture seule sur le projet Supabase
  (connecteur), jamais d'écriture.
- **Notification « X vous attend »** : une seule par arrivée (premier appel à
  `rejoindre_conversation` après une absence de plus de 45 s), et aucune si
  une notification « réponse » a été envoyée au même destinataire dans les
  2 dernières minutes. L'anti-rafale de 10 minutes reste en garde-fou.
- **Pas de compteur de messages non lus** dans cette version : rien en base ne
  sait ce qui a été lu. `non_lus` est retiré de `ResumeConversation`.
- **Conversations illimitées** (rouvertes après un rendez-vous,
  `illimitee = true`) : `mes_conversations()` expose le drapeau ; l'écran les
  affiche sans compte à rebours ni verrouillage.
- **Décision de fin par une RPC**, conformément à `AGENTS.md`, plutôt que par
  écriture directe dans `conversation_decisions` : elle rejoint l'étape 2 de
  livraison. L'étape 1 affiche la question mais l'envoi attend la RPC.
- **Fin du temps** : le verrouillage est fait par une tâche planifiée chaque
  minute, donc le statut peut changer jusqu'à 60 s après la fin. L'écran
  bascule sur « Le temps est écoulé » dès que le temps restant servi par le
  serveur atteint 0, sans attendre le statut. Le serveur refuse déjà tout
  message après `ends_at`.

## Laissé au constructeur

- Les intervalles exacts de rafraîchissement, dans les bornes ci-dessus.
- La mise en page de chaque étape, dans le système de `src/theme.ts` et
  `src/components/ui/`.
- Le nom exact des fichiers `db/`, à la suite de la numérotation existante.

## Points ouverts

- Comportement d'Expo Go sur iOS avec le SDK 57 pour les notifications.
- Comptes Expo (EAS) et développeur Apple : pas encore créés. L'étape 3 de
  livraison attend ces comptes.

## Réponses du responsable (28 novembre)

- **Messages avant le chrono : illimités.**
- **Question de fin : oui ou non**, « plus tard » est retiré. La RPC de
  décision refuse `plus_tard` même si l'énumération `date_intent` le contient.
- **Comptes Expo et Apple : pas encore.** Les étapes 1 et 2 se font sans
  eux ; l'étape 3 attend.
