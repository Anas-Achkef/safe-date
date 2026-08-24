#!/usr/bin/env bash
# Lance l'application dans le navigateur et n'ouvre la page qu'une fois le
# bundle réellement servi.
#
#   lancer.sh [route] [--clear]
#
# Exemples :  lancer.sh            lancer.sh learning --clear
set -uo pipefail
cd "$(dirname "$0")/../../.." || exit 2

PORT=8081
ROUTE=""
CLEAR=""
for arg in "$@"; do
  case "$arg" in
    --clear) CLEAR="--clear" ;;
    *) ROUTE="${arg#/}" ;;
  esac
done
JOURNAL="/tmp/safe-date-metro.log"

repond() { curl -s -o /dev/null --max-time 2 "http://localhost:$PORT/status" 2>/dev/null; }

if repond; then
  echo "Metro répond déjà sur le port $PORT."
else
  if lsof -ti:"$PORT" >/dev/null 2>&1; then
    echo "Port $PORT occupé par un processus qui ne répond pas — libération."
    lsof -ti:"$PORT" | xargs kill -9 2>/dev/null
    sleep 1
  fi
  echo "Démarrage de Metro${CLEAR:+ (cache vidé)}…"
  nohup npx expo start --web --port "$PORT" $CLEAR > "$JOURNAL" 2>&1 &
  # Une reconstruction complète du cache dépasse largement la minute :
  # on attend que le port réponde, pas qu'une ligne apparaisse au journal.
  for _ in $(seq 1 180); do repond && break; sleep 2; done
  if ! repond; then
    echo "Metro n'a pas démarré. Fin du journal :"
    tail -20 "$JOURNAL"
    exit 1
  fi
  echo "Metro répond."
fi

echo "Construction du bundle…"
paquet=$(mktemp)
code=$(curl -s -o "$paquet" -w '%{http_code}' --max-time 300 \
  "http://localhost:$PORT/.expo/.virtual-metro-entry.bundle?platform=web&dev=true&minify=false")
if [ ! -s "$paquet" ]; then
  echo "Aucun contenu reçu (HTTP $code)."; exit 1
fi
# Metro renvoie l'erreur en JSON : un bundle valide commence par du script.
if head -c 1 "$paquet" | grep -q '{'; then
  echo "Erreur de bundling :"; head -c 1000 "$paquet"; echo; exit 1
fi
printf 'Bundle servi : %s octets (HTTP %s)\n' "$(wc -c < "$paquet" | tr -d ' ')" "$code"
rm -f "$paquet"

# Le navigateur conserve la feuille de style injectée : un paramètre d'URL
# distinct force un chargement neuf sans vider le cache à la main.
URL="http://localhost:$PORT/${ROUTE}?r=$(date +%s)"
open "$URL" 2>/dev/null && echo "Ouvert : $URL"

echo
echo "Journal : $JOURNAL"
grep -icE "error|unable to resolve" "$JOURNAL" | sed 's/^/Erreurs au journal : /'
