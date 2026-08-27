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
    # 27/08/2026 : '*.bak' ne matchait AUCUN fichier reel. Les sauvegardes s'appellent
    # SKILL.md.bak-22aout, SKILL.md.bak-avant-degraissage : il faut '*.bak*'. Ce caractere
    # manquant a laisse passer 3 sauvegardes dans le build public et bloque le push depuis
    # le 23/08 (le garde-fou anti-fuite les detectait a l'etage suivant, correctement).
    find "$DEST/$skill" \( -name '.DS_Store' -o -name '*.old*' -o -name '*superseded*' -o -name '*.bak*' -o -name '*~' \) -delete 2>/dev/null || true
    # 27/08/2026 : masquage des donnees personnelles sur TOUS les fichiers, pas seulement
    # les .md. Le scrub ne couvrait que '*.md', donc les .sh passaient intacts : c'est ainsi
    # que le numero de telephone de Clement s'est retrouve dans la copie de build de derame
    # (verifier-planificateur.sh et claude-session-guard.sh). Rien n'a jamais ete pousse,
    # le garde-fou a bloque, mais la source du build n'etait pas protegee.
    # Filet de defense en profondeur : meme si le vault est propre aujourd'hui, un numero
    # peut y revenir. On masque a la sortie, pas seulement a l'entree.
    find "$DEST/$skill" -type f \( -name '*.sh' -o -name '*.py' -o -name '*.md' -o -name '*.txt' -o -name '*.json' \) -print0 | while IFS= read -r -d '' f; do
      LC_ALL=C sed -i '' -E \
        -e 's#(\+33|0)[1-9]([ .-]?[0-9]{2}){4}#<NUMERO_MASQUE>#g' \
        -e 's#[A-Za-z0-9._%+-]+@(gmail|outlook|hotmail|yahoo)\.[a-z]{2,}#<EMAIL_MASQUE>#g' \
        "$f" 2>/dev/null || true
    done

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
