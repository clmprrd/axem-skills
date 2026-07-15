#!/bin/bash
# Régénère le catalogue public depuis le vault et le pousse sur GitHub SI quelque chose a changé.
# Headless-safe (git push via gh token, aucun navigateur requis) → appelable par une tâche programmée.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

bash build-public-plugin.sh >/dev/null 2>&1

# Garde-fou anti-fuite : si un marqueur sensible réapparaît, on N'ENVOIE PAS et on signale.
if grep -rniqE "jokabi|carrefour|rothschild|tikehau|odedis|carlylle|kone|anniksha|intothetribe|siret|iban|zeitoun|@gmail|whatsapp|\+336|0636232535|cal\.com/clement|app\.indy|referentiel-decision|13-Comptabilite|14-CRM|memory/" plugins/ 2>/dev/null; then
  echo "STOP: marqueur sensible detecte dans la copie publique - push annule, a verifier a la main."
  exit 2
fi

if [ -z "$(git status --porcelain)" ]; then
  echo "Rien a publier (catalogue public deja a jour)."
  exit 0
fi

git add -A
git -c user.name="Clement Predo" -c user.email="clem.pred@gmail.com" \
    commit -q -m "sync auto: mise a jour des skills publics depuis le vault"
git push -q origin main && echo "Catalogue public mis a jour et pousse sur GitHub."
