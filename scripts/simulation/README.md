# Simulation du moteur de compatibilité sur 15 000 profils fictifs

Cette simulation fabrique une population fictive, la fait noter par le moteur
de compatibilité de Safe Date, et compare les notes à une vérité connue
d'avance. Elle a tourné le 24 novembre 2026 sur les 95 migrations de
`supabase/migrations/`, sans aucune des propositions du dossier `db/`.

Tout se passe sur la machine : aucune connexion à Supabase, aucune clé,
aucune variable d'environnement secrète.

## Résultats en bref

| Mesure | Valeur |
|---|---|
| Profils fictifs | 15 000 (3 180 000 réponses, 212 par profil) |
| Couples notés | 556 043 |
| Score moyen | 42,1 sur 100 (écart-type 7,5) |
| Score médian | 41,9 |
| Score maximum | 78,2 |
| Couples à 85 ou plus (`seuil_premium`) | 0 |
| Couples à 70 ou plus | 85, soit 0,015 % |

Les 556 043 couples sont un échantillon, pas toutes les paires possibles :
200 profils « observateurs », et pour chacun jusqu'à 3 000 candidats tirés au
hasard parmi ceux que le genre rend possibles dans les deux sens. Un couple
est orienté : (A, B) et (B, A) comptent pour deux s'ils sont tirés tous les
deux, et reçoivent le même score global.

Le détail est dans la section [Résultats](#résultats).

## Lancer la simulation

Il faut Node.js (testé avec la version 26.13) et environ 2 Go de disque pour
15 000 profils. Les commandes se lancent depuis ce dossier.

```bash
cd scripts/simulation
npm install

# 1. Rejouer les migrations du dépôt dans une base Postgres embarquée.
#    Attention : le dossier de données indiqué est effacé puis recréé.
node charger.mjs ../.. donnees/vierge

# 2. Partir d'une copie de la base vierge, pour pouvoir recommencer.
cp -r donnees/vierge donnees/sim-15000

# 3. Générer 15 000 profils et faire calculer leurs vecteurs par le moteur.
node generer.mjs donnees/sim-15000 15000

# 4. Faire noter 200 observateurs × 3 000 candidats, et mesurer.
node evaluer.mjs donnees/sim-15000 200 3000 donnees/resultat-15000.json

# 5. Moyenne, maximum et décomptes par seuil, lus dans la base.
node q.mjs donnees/sim-15000 resume.sql
```

Durées relevées pour 15 000 profils : 88 s de génération, 488 s de calcul des
vecteurs, 458 s de notation. Pour un essai rapide, `node generer.mjs
donnees/essai 2000` puis `node evaluer.mjs donnees/essai 150 1000` prennent
trois minutes en tout.

Le tirage est fixé par une graine (`20261124` par défaut, troisième argument
de `generer.mjs`). Relancée depuis ce dossier avec 2 000 profils, la
simulation redonne exactement `resultats/resultat-base.json`.

Le dossier `donnees/` est ignoré par git. N'importe quel autre chemin
convient.

### Changer les hypothèses

`generer.mjs` lit ses paramètres dans la variable d'environnement
`SIM_PARAMS`, au format JSON. Ce n'est pas un secret, seulement un réglage.

```bash
SIM_PARAMS='{"bruitReponse":0.2,"reponsesAuHasard":0.01}' node generer.mjs donnees/sim-precis 2000
```

| Paramètre | Défaut | Sens |
|---|---|---|
| `dimensions` | 6 | Nombre de traits latents par personne. |
| `homophilie` | 0.5 | Part de l'idéal recherché qui ressemble à soi-même. 0 : sans rapport. |
| `bruitReponse` | 0.6 | Bruit ajouté à chaque réponse « moi ». |
| `reponsesAuHasard` | 0.05 | Part des réponses tirées au hasard, dans les deux sens. |
| `indifferenceRedhibitoires` | `null` | Sur un critère rédhibitoire, probabilité de répondre « peu importe » quand l'option existe. `null` : tirage égal entre toutes les options qui conviennent. |

### Les fichiers

| Fichier | Rôle |
|---|---|
| `charger.mjs` | Rejoue les migrations dans la base embarquée. |
| `correctifs.json` | Trois valeurs d'énumération que la base réelle possède et que les migrations du dépôt ne créent pas. |
| `generer.mjs` | Fabrique la population et fait calculer les vecteurs. |
| `cles-repondues.json` | Les 213 questions auxquelles les profils réels de `supabase/seed.sql` ont répondu. |
| `evaluer.mjs` | Fait noter les couples et calcule les mesures. |
| `resume.sql` | Moyenne, maximum et décomptes par seuil sur une évaluation faite. |
| `q.mjs` | Exécute une requête ou un fichier SQL sur une base locale. |
| `reels.mjs` | Charge les quatre profils réels de `supabase/seed.sql` et note leurs paires. |
| `comparer.mjs` | Compare le référentiel de la base locale à celui de `supabase/seed.sql`. |
| `dump.mjs` | Lit les blocs `COPY` de `supabase/seed.sql`. |
| `resultats/` | Sorties de la simulation du 24 novembre 2026. |

## Comment sont générées les réponses « moi »

Ni au hasard, ni par archétype : par **traits latents**. Les archétypes de la
migration M14 (`test_archetypes`) ne sont pas utilisés.

1. Chaque personne reçoit un vecteur `z` de 6 traits, tirés indépendamment
   selon une loi normale centrée réduite. C'est « qui elle est ».
2. Chaque paire de critères reçoit, une fois pour toute la population, un
   vecteur de poids sur ces 6 traits : 0,9 sur un trait principal tiré au
   hasard, un petit poids aléatoire (0,15 × une normale) sur les autres, le
   tout ramené à une norme de 1.
3. La réponse d'une personne à une question « moi » se calcule ainsi : on
   projette `z` sur les poids de la paire, on ajoute un bruit normal
   d'amplitude 0,6, et on convertit la valeur obtenue en rang d'option par la
   fonction de répartition de la loi normale. Les options d'une question sont
   donc toutes à peu près aussi fréquentes dans la population.
4. L'ordre des options suit leur index quand le moteur les traite comme
   ordonnées (paire de type `echelle`, ou paire dont une correspondance porte
   un opérateur relatif). Sinon l'ordre est mélangé une fois par paire, parce
   que l'index n'y veut rien dire.
5. 5 % des réponses sont tirées au hasard parmi les options de la question.

Deux questions échappent à ce mécanisme et suivent une répartition fixée dans
`generer.mjs` (tableau `DEMO`) :

| Part | Genre | Recherche | Orientation |
|---|---|---|---|
| 44 % | Homme | Femme | Hétérosexuel |
| 44 % | Femme | Homme | Hétérosexuelle |
| 3 % | Homme | Homme | Homosexuel |
| 3 % | Femme | Femme | Homosexuelle |
| 2 % | Homme | Peu importe | Bisexuel |
| 2 % | Femme | Peu importe | Bisexuelle |
| 2 % | Non-binaire | Peu importe | Bisexuel(le) |

Chaque profil répond à **106 paires de critères sur les 133** du référentiel :
celles dont les deux questions ont reçu une réponse d'au moins un des quatre
profils réels de `supabase/seed.sql`. Elles se répartissent en 15 paires
« physique », 55 « valeurs » et 36 « mode de vie ». Les 27 autres paires
restent sans réponse et sortent du calcul. Chaque réponse porte une seule
option, comme les 849 réponses réelles du dump.

Le reste du profil est tiré simplement : âge de 19 à 60 ans (médiane 29 ans,
95 % des profils ont 41 ans ou moins), tranche d'âge recherchée de ± 8 ans, position dans Paris et sa
proche banlieue, intention « amour ». Le score de compatibilité ne lit aucune
de ces valeurs.

## Comment sont générées les préférences « je recherche »

1. Chaque personne reçoit un second vecteur, `ideal` : « qui elle cherche ».
   Il vaut `0,5 × z + 0,87 × bruit normal`. La moitié de l'idéal ressemble
   donc à la personne elle-même (`homophilie` = 0,5).
2. Pour chaque paire, on calcule la **réponse idéale** : celle qu'une
   personne de traits `ideal` donnerait à la question « moi », sans bruit.
3. On cherche ensuite, dans la table `option_mappings` du moteur, les options
   « je recherche » qui acceptent cette réponse idéale :
   - cas général : l'option dont `accepted_self_idx` contient la réponse
     idéale ;
   - paire `echelle` : l'option dont la `tolerance` couvre l'écart entre la
     réponse idéale et la propre réponse de la personne ;
   - opérateur relatif (`sup`, `inf`, `egal`) : l'option qui correspond à la
     comparaison entre la réponse idéale et la propre réponse.
4. Si plusieurs options conviennent, l'une est tirée au hasard, option « peu
   importe » comprise. Si aucune ne convient, une option de la paire est
   tirée au hasard.
5. 5 % des préférences sont tirées au hasard parmi les options de la question.

Pour l'orientation recherchée, 60 % des profils répondent « Peu importe » et
40 % leur propre orientation.

La simulation s'appuie donc sur les correspondances du moteur pour traduire
un idéal en préférence : une personne fictive choisit toujours une option que
le moteur sait interpréter. Elle ne teste pas si ces correspondances sont
justes.

## Comment le score est calculé

**Le score n'est pas réécrit.** C'est la fonction `private.compat_score` du
dépôt qui note chaque couple, et la fonction `private.refresh_profile_vectors`
du dépôt qui transforme les réponses en vecteurs. Les deux s'exécutent dans un
Postgres embarqué (PGlite, Postgres compilé en WebAssembly) où `charger.mjs`
rejoue, dans l'ordre, les 95 fichiers de `supabase/migrations/`.

Les critères, les options, les paires et les correspondances viennent donc
des migrations elles-mêmes : 266 critères, 918 options, 133 paires, 485
correspondances. `comparer.mjs` les confronte au dump de la base réelle
(`supabase/seed.sql`) : aucun écart sur les paires ni sur les
correspondances.

Ce que `charger.mjs` ajoute ou retire pour que les migrations passent hors de
Supabase :

- des rôles Postgres vides `anon`, `authenticated` et `service_role`, un
  schéma `auth` avec une table `users` et une fonction `auth.uid()`, et une
  fausse fonction `cron.schedule`. Ce sont des coquilles locales, pas des
  accès ;
- l'extension `pg_cron`, retirée ;
- trois valeurs d'énumération absentes des migrations (`correctifs.json`) ;
- les anciennes versions de fonctions que certaines migrations recréent avec
  une autre signature sans les supprimer.

Deux paramètres du moteur diffèrent entre les migrations et la base réelle.
`generer.mjs` applique les valeurs de la base réelle, relevées dans le dump :
`min_criteres_affiches` = 15 (60 dans les migrations) et
`plancher_directionnel` = 25 (40 dans les migrations).

### Ce que fait `private.compat_score`

Pour un couple (A, B), sur chaque paire de critères :

- le critère est **évalué** de A vers B si A a une préférence et B une
  réponse « moi » ; il est **satisfait** si la réponse de B fait partie des
  options que la préférence de A accepte. Même chose de B vers A ;
- son poids est `base_weight` × le multiplicateur de l'option choisie
  (`weight_multiplier` : 0 pour « peu importe », sinon 0,5, 1 ou 2). Toutes
  les paires ont un `base_weight` de 1.

Pour chacun des trois groupes (physique, valeurs, mode de vie), hors critères
rédhibitoires :

- score de A vers B = 100 × poids des critères satisfaits ÷ poids des
  critères évalués ;
- score du groupe = moyenne des deux sens.

Le **score global** est la moyenne des trois groupes pondérée par
`poids_physique` (0,25), `poids_valeurs` (0,40) et `poids_mode_vie` (0,35).

Deux indicateurs accompagnent le score :

- `filtres_ok` : aucun des critères rédhibitoires n'est insatisfait, dans
  aucun sens. Il y en a 7 : genre, religion, type de relation, mariage,
  enfants, régime alimentaire, orientation ;
- `affichable` : `filtres_ok`, plus un score d'au moins 25 dans chaque sens,
  plus au moins 15 critères évalués.

Le score global est calculé même quand `filtres_ok` est faux.

### Ce que la simulation ajoute autour du score

Deux mesures sont écrites par la simulation. Elles servent à juger le moteur,
elles ne changent pas sa note.

- **La vérité.** Pour un couple, c'est la proximité entre les traits de l'un
  et l'idéal de l'autre, dans les deux sens : `−‖z(B) − ideal(A)‖² − ‖z(A) −
  ideal(B)‖²`. Elle ne dépend ni des correspondances ni des poids du moteur.
- **L'étalon brut** (`sim.brut` dans `evaluer.mjs`). C'est la part des
  critères satisfaits, tous comptés pareil, sans poids ni groupes. Il montre
  ce que la pondération du moteur apporte par rapport à un simple décompte.

## Résultats

Fichiers : `resultats/resultat-15000.json` (mesures), `resultats/journal-15000.txt`
(sortie complète), `resultats/resume-15000.txt` (moyenne, maximum, décomptes).

### Niveau des scores, 15 000 profils

| Mesure | Valeur |
|---|---|
| Couples notés | 556 043 |
| Score moyen | 42,12 |
| Écart-type | 7,53 |
| Minimum | 13,3 |
| 1er décile | 32,6 |
| Médiane | 41,9 |
| 9e décile | 52,0 |
| 99e centile | 60,3 |
| Maximum | 78,2 |
| Couples à 60 ou plus | 6 370 (1,1 %) |
| Couples à 70 ou plus | 85 (0,015 %) |
| Couples à 85 ou plus | 0 |
| Critères évalués par couple | 99 |

Sous-scores moyens : physique 28,0, valeurs 45,7, mode de vie 48,2. Dans un
seul sens, le score le plus haut est de 86,1. L'étalon brut vaut 44,3 % en
moyenne et 76,2 % au maximum.

### Critères rédhibitoires

| Couples | Nombre | Part | Score moyen | Maximum |
|---|---|---|---|---|
| Bloqués par un critère rédhibitoire | 526 789 | 94,7 % | 42,00 | 78,2 |
| Non bloqués, mais non affichables | 1 304 | 0,2 % | 31,81 | 50,7 |
| Affichables | 27 950 | 5,0 % | 44,73 | 74,1 |

Le genre est déjà assorti quand les candidats sont tirés : ce sont les six
autres critères rédhibitoires qui écartent 94,7 % des couples. Les couples
écartés ne sont pas moins bons que les autres selon la vérité : leur centile
moyen est de 0,495, et 9,6 % d'entre eux sont dans le meilleur dixième.

Le couple au score le plus haut, 78,2, est bloqué. Parmi les couples
affichables, 12 atteignent 70.

### Le classement suit-il la vérité ?

| Mesure | Moteur | Étalon brut | Hasard |
|---|---|---|---|
| Corrélation de rang avec la vérité (médiane par observateur) | 0,609 | 0,646 | 0 |
| Part des 20 premiers qui sont dans le meilleur dixième réel | 51,1 % | 52,3 % | 10 % |

Le moteur classe bien mieux que le hasard, et pas mieux qu'un décompte sans
pondération. Par groupe, la corrélation de rang est de 0,593 pour les
valeurs, 0,407 pour le mode de vie et 0,327 pour le physique.

### Variantes, 2 000 profils chacune

150 observateurs, jusqu'à 1 000 candidats chacun.

| Variante | Hypothèse changée | Couples | Médiane | Maximum | À 85 ou plus | Non bloqués |
|---|---|---|---|---|---|---|
| `base` | aucune | 126 274 | 42,0 | 78,1 | 0 | 5,0 % |
| `precis` | bruit 0,2, hasard 1 % | 129 273 | 41,7 | 88,7 | 1 | 6,3 % |
| `souples` | « peu importe » à 80 % sur les rédhibitoires | 129 964 | 41,8 | 77,4 | 0 | 32,1 % |
| `exigeants` | jamais « peu importe » sur les rédhibitoires | 129 964 | 41,8 | 77,4 | 0 | 0,3 % |
| `ideal` | bruit 0,2, hasard 1 %, homophilie 0,9, « peu importe » à 80 % | 128 445 | 41,7 | 90,1 | 2 | 36,3 % |

Le seul couple à 85 ou plus de la variante `precis` est bloqué par un critère
rédhibitoire. Les deux de la variante `ideal` ne le sont pas. Même avec les
hypothèses les plus favorables, 2 couples sur 128 445 atteignent le seuil.

### Profils réels

`reels.mjs` note les six paires que forment les quatre questionnaires réels
de `supabase/seed.sql`. Leurs scores globaux vont de 32,9 à 44,7 : le même
niveau que la population fictive. Quatre de ces six paires sont bloquées par
un critère rédhibitoire.

## Limites

- **La population est inventée.** Le niveau des scores dépend des hypothèses
  de `generer.mjs`. La médiane autour de 42 résiste à toutes les variantes
  essayées et se retrouve sur les quatre profils réels, mais quatre profils
  ne font pas une preuve.
- **Toutes les options sont à peu près aussi fréquentes.** Dans la réalité,
  certaines réponses dominent, ce qui peut rapprocher ou éloigner les gens
  plus que la simulation ne le montre.
- **Les critères sont presque indépendants entre eux.** Six traits pour 106
  paires : deux personnes proches sur un trait ne s'accordent que sur une
  partie des critères. Des critères plus liés entre eux donneraient des
  scores plus étalés, donc plus de scores hauts et plus de scores bas.
- **Les préférences découlent des correspondances du moteur.** La simulation
  ne dit pas si ces correspondances reflètent ce que les gens veulent.
- **Le filtrage par âge et par distance n'est pas simulé.** Seule la fonction
  de score est appelée, pas la sélection des candidats.
- **Aucun apprentissage.** Les coefficients appris sur les décisions
  (`learned_coef`) et les priorités d'utilisateur valent 1 : personne n'a
  encore swipé.
- **L'échantillon ne couvre pas toutes les paires.** Un couple à 85 peut
  exister hors des 556 043 notés. Avec une moyenne de 42 et un écart-type de
  7,5, il serait très rare.

## Défaut du moteur rencontré en route

Cinq options « je recherche » portent un opérateur relatif : « Plus grand(e)
que moi » et « Plus petit(e) que moi » pour la taille, « Un niveau supérieur
au mien », « inférieur au mien » et « identique au mien » pour les études. Dans les migrations,
`private.refresh_profile_vectors` ne lit pas cet opérateur. Leur liste
d'options acceptées étant vide, ces cinq préférences ne sont jamais
satisfaites, quel que soit le candidat. La simulation a tourné avec ce
défaut. Une correction a été écrite (`db/005-options-relatives.sql`), mais elle
n'est pas encore publiée sur GitHub : elle n'est ni dans cette branche ni
dans les résultats ci-dessus.
