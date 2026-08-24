---
name: demarrer
description: Lance Safe Date dans le navigateur et vérifie que le bundle est réellement servi avant d'ouvrir la page. À utiliser dès qu'il faut voir l'application tourner, montrer un écran, ou vérifier qu'une modification s'affiche.
---

# Démarrer Safe Date

    .claude/skills/demarrer/lancer.sh [route] [--clear]

Exemples :

    .claude/skills/demarrer/lancer.sh
    .claude/skills/demarrer/lancer.sh learning
    .claude/skills/demarrer/lancer.sh --clear

Le script réutilise Metro s'il tourne déjà, libère le port s'il est occupé par
un processus muet, attend que le serveur réponde vraiment, construit le bundle,
et n'ouvre le navigateur qu'ensuite.

## Ce qu'il évite

**Attendre le journal plutôt que le port.** La ligne « Waiting on http »
apparaît avant que le serveur ne réponde ; avec `--clear`, la reconstruction du
cache prend plusieurs minutes. Le script interroge `/status` en boucle.

**Prendre une erreur pour un bundle.** Metro renvoie ses erreurs en JSON avec
un code 200. Le script regarde le premier caractère : une accolade signale un
échec de bundling, pas du code.

**Le cache du navigateur.** La feuille de style du cadre d'appareil est
injectée une seule fois par chargement de page ; un rafraîchissement ordinaire
peut resservir l'ancienne. Le script ouvre une URL horodatée, ce qui contourne
le cache sans manipulation.

## Après

`EXPO_PUBLIC_PREVIEW=0` mène à l'écran de connexion — compte de développement
`dev@safedate.test`. Passer le drapeau à `1` ouvre l'application directement,
avec des données de démonstration.

Toute modification du `.env` impose un redémarrage avec `--clear` : les
variables `EXPO_PUBLIC_*` sont lues au démarrage du bundler.
