#!/usr/bin/env bash
#
# Publie l'aperçu Safe Date sur Vercel.
#
# `expo export` vide `dist/`, y compris le lien Vercel qui s'y trouve : on le
# garde à la racine dans `.vercel/` et on le replace après chaque export.
#
#   ./deployer.sh            publie en production
#   ./deployer.sh --apercu   publie une URL de test, sans toucher à la prod
#
# Deux pièges, tous deux corrigés ci-dessous :
#
# 1. Vercel **écarte de l'envoi tout fichier dont le chemin traverse un
#    dossier `node_modules`**. Or `expo export` range les polices et les images
#    sous `dist/assets/node_modules/…`, en miroir de leurs chemins source :
#    sans traitement, il ne monte que sept fichiers et l'application s'ouvre
#    sur un écran vide, faute de polices. On renomme donc ce dossier et on
#    rétablit les anciennes adresses par une réécriture.
#
# 2. Le `vercel.json` de la racine porte un `buildCommand` : recopié tel quel
#    dans `dist/`, il demande à Vercel de **rebâtir** un dossier qui n'a ni
#    `package.json` ni sources, et le déploiement échoue. Celui écrit ici ne
#    décrit que le service de fichiers déjà construits.
set -euo pipefail
cd "$(dirname "$0")"

echo "› Export web…"
npx expo export --platform web

echo "› Sortie des assets du chemin node_modules…"
if [ -d dist/assets/node_modules ]; then
  rm -rf dist/assets/paquets
  mv dist/assets/node_modules dist/assets/paquets
fi

echo "› Configuration du service statique…"
cat > dist/vercel.json <<'JSON'
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "rewrites": [
    { "source": "/assets/node_modules/:chemin*", "destination": "/assets/paquets/:chemin*" },
    { "source": "/(.*)", "destination": "/index.html" }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Robots-Tag", "value": "noindex, nofollow, noarchive, noimageindex" }
      ]
    }
  ]
}
JSON
mkdir -p dist/.vercel
cp .vercel/project.json dist/.vercel/project.json

echo "› Publication…"
cd dist
if [ "${1:-}" = "--apercu" ]; then
  npx vercel deploy --yes --scope safedate
else
  npx vercel deploy --prod --yes --scope safedate
fi
