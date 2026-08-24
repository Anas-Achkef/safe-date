#!/usr/bin/env bash
# Vérifie les règles structurantes de Safe Date.
# Sort 0 si tout passe, 1 sinon. Aucune modification de fichier.
set -uo pipefail
cd "$(dirname "$0")/../../.." || exit 2

manquements=0
titre() { printf '\n\033[1m%s\033[0m\n' "$1"; }
signaler() {
  printf '  \033[31m✗\033[0m %s\n' "$1"
  shift
  printf '%s\n' "$@" | sed 's/^/      /'
  manquements=$((manquements + 1))
}
valider() { printf '  \033[32m✓\033[0m %s\n' "$1"; }

# Recherche filtrant les commentaires : une règle rappelée en prose n'est pas
# une infraction. Écarte les lignes dont le contenu débute par *, // ou #.
chercher() {
  grep -rnE "$@" 2>/dev/null | grep -vE ':[0-9]+:[[:space:]]*(\*|//|#)' || true
}

SRC=(src app)

titre "Accès aux données"
# Le client Supabase ne se manipule que dans la couche d'accès.
hits=$(chercher "supabase\.(rpc|from)\(" "${SRC[@]}" --include="*.ts" --include="*.tsx" \
  | grep -v "^src/api/" || true)
if [ -n "$hits" ]; then
  signaler "appel Supabase hors de src/api/" "$hits"
else
  valider "aucun appel Supabase hors de src/api/"
fi

titre "Clé de service"
hits=$(chercher "service_role" "${SRC[@]}" .env.example)
if [ -n "$hits" ]; then
  signaler "référence à la clé service_role" "$hits"
else
  valider "aucune référence à service_role"
fi

titre "Valeurs visuelles"
# Couleurs littérales hors du thème : le seul fichier autorisé est src/theme.ts.
hits=$(chercher "(#[0-9a-fA-F]{3,8}\b|rgba?\([0-9])" "${SRC[@]}" --include="*.ts" --include="*.tsx" \
  | grep -v "^src/theme.ts:" | grep -v "^src/lib/webFrame.ts:" || true)
if [ -n "$hits" ]; then
  signaler "couleur écrite en dur hors de src/theme.ts" "$hits"
else
  valider "toutes les couleurs viennent du thème"
fi

titre "Pièges connus"
hits=$(chercher "crypto\.randomUUID" "${SRC[@]}" --include="*.ts" --include="*.tsx")
[ -n "$hits" ] && signaler "crypto.randomUUID n'est pas garanti sur React Native" "$hits" \
                || valider "pas de crypto.randomUUID"

hits=$(chercher "^[[:space:]]*(shadowColor|shadowOffset|shadowOpacity|shadowRadius):" "${SRC[@]}" --include="*.tsx" --include="*.ts")
[ -n "$hits" ] && signaler "propriétés shadow* dépréciées — utiliser boxShadow" "$hits" \
                || valider "pas de propriété shadow* dépréciée"

hits=$(chercher "pointerEvents=" "${SRC[@]}" --include="*.tsx")
[ -n "$hits" ] && signaler "props.pointerEvents dépréciée — utiliser style.pointerEvents" "$hits" \
                || valider "pas de props.pointerEvents"

hits=$(chercher "top:[[:space:]]*'50%'" "${SRC[@]}" --include="*.tsx" --include="*.ts")
[ -n "$hits" ] && signaler "top:'50%' en position absolue aligne le BORD, pas le centre" "$hits" \
                || valider "pas de centrage par top:'50%'"

titre "Schéma de base"
# Les propositions SQL restent dans db/, jamais appliquées depuis une session.
if [ -d db ] && ls db/*.sql >/dev/null 2>&1; then
  valider "$(ls db/*.sql | wc -l | tr -d ' ') proposition(s) SQL dans db/ — à appliquer hors session"
else
  valider "aucune proposition SQL en attente"
fi

printf '\n'
if [ "$manquements" -eq 0 ]; then
  printf '\033[32mToutes les conventions sont respectées.\033[0m\n'
else
  printf '\033[31m%d manquement(s).\033[0m\n' "$manquements"
fi
exit $(( manquements > 0 ? 1 : 0 ))
