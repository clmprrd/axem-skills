#!/bin/bash
# Régénère le plugin public depuis le vault, en ne copiant QUE les skills listés
# dans PUBLIC_SKILLS.txt (allowlist = garde-fou anti-fuite). Idempotent.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
VAULT="/Users/clementpredo/Downloads/Axem-IA-Hub/06-Skills-Claude"
DEST="$ROOT/plugins/axem-skills/skills"

rm -rf "$DEST"
mkdir -p "$DEST"

n=0
while IFS= read -r skill; do
  [ -z "$skill" ] && continue
  case "$skill" in \#*) continue;; esac
  src="$VAULT/$skill"
  if [ -f "$src/SKILL.md" ]; then
    cp -R "$src" "$DEST/$skill"
    # hygiène : pas de .DS_Store ni de sauvegardes/versions supersédées dans le repo public
    find "$DEST/$skill" \( -name '.DS_Store' -o -name '*.old*' -o -name '*superseded*' -o -name '*.bak' -o -name '*~' \) -delete 2>/dev/null || true
    # scrub confidentialité : masquer les chemins internes du vault dans la copie PUBLIQUE (le vault reste intact)
    find "$DEST/$skill" -name '*.md' -print0 | while IFS= read -r -d '' f; do
      LC_ALL=C sed -i '' -E \
        -e 's#`memory/`, `CRM/`, `13-Comptabilite/`, `referentiel-decision\.md`#vos notes internes (mémoire, CRM, compta)#g' \
        -e 's#`13-Comptabilite/[^`]*`#`(compta interne)`#g' \
        -e 's#`memory/[^`]*`#`(mémoire interne)`#g' \
        -e 's#`14-CRM/[^`]*`#`(CRM interne)`#g' \
        "$f" 2>/dev/null || true
    done
    echo "OK  $skill"
    n=$((n+1))
  else
    echo "SKIP (introuvable) $skill"
  fi
done < "$ROOT/PUBLIC_SKILLS.txt"

echo "→ $n skills publics régénérés dans $DEST"
