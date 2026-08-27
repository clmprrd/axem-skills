#!/bin/bash
# Régénère le catalogue public depuis le vault et le pousse sur GitHub SI quelque chose a changé.
# Headless-safe (git push via gh token, aucun navigateur requis) → appelable par une tâche programmée.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

bash build-public-plugin.sh >/dev/null 2>&1

# Garde-fou anti-fuite : si un marqueur sensible réapparaît, on N'ENVOIE PAS et on signale.
# 27/08/2026 : liste elargie. Un audit a trouve "Comfluence" et deux dirigeants nommes
# (Vincent Lamkin, Jerome Ripoull) dans conseil-agents/references/collecte.md, cree le 26/08.
# La liste d'origine ne les couvrait pas : le garde-fou aurait laisse partir des personnes
# physiques identifiees sur un depot public indexe. Rien n'avait fuite (le fichier est
# posterieur au dernier push du 30/07), mais le trou etait reel.
# Regle : tout client ou prospect nomme dans le CRM a sa place ici. Le cout d'un marqueur
# de trop est un push bloque et une verification a la main. Le cout d'un marqueur manquant
# est une donnee de tiers publiee et indexee, qu'on ne retire jamais vraiment.
#
# ⚠️ Corollaire, appris le meme jour : un marqueur trop LARGE se paie aussi. Le mot
# "whatsapp" seul bloquait tout le push a cause d'une liste de produits SaaS dans
# deepsearch ("Google Workspace, LinkedIn, Notion, Stripe, WhatsApp, Fathom"). Un nom de
# produit dans une phrase n'est pas une fuite. Le marqueur vise desormais la DONNEE
# (@s.whatsapp.net, un export, un identifiant de conversation), pas le nom.
# Un garde-fou qui crie sur des faux positifs finit desactive par lassitude, et un filtre
# desactive ne protege rien du tout.
#
# 🔴 Deux trous trouves par contre-test le 27/08, et ils justifient a eux seuls de tester
# un filtre au lieu de le relire :
#   1. "whatsapp[^ ]*(conversation|export)" exigeait le mot-cle COLLE a "whatsapp".
#      "export whatsapp conversation" passait donc tranquillement. Corrige en .{0,40}
#      dans les deux sens.
#   2. Aucun motif ne couvrait un numero de telephone AUTRE que celui de Clement.
#      La liste avait "+336" et son numero en dur ; "0612345678" passait. Ajout d'un
#      motif generique mobile FR. Le scrub de build-public-plugin.sh masque deja les
#      numeros, ce filtre est la deuxieme couche au cas ou un format lui echappe.
if grep -rniqE "jokabi|carrefour|rothschild|tikehau|odedis|carlylle|kone|anniksha|intothetribe|comfluence|lamkin|ripoull|difenso|gojiberry|gyma|uriach|careismatic|kit.group|siret|iban|zeitoun|@gmail|@s.whatsapp.net|whatsapp.{0,40}(conversation|export|jid|chatdb)|(conversation|export|jid|chatdb).{0,40}whatsapp|\\b0[67]([ .-]?[0-9]{2}){4}\\b|\+336|0636232535|cal\.com/clement|app\.indy|referentiel-decision|13-Comptabilite|14-CRM|memory/" plugins/ 2>/dev/null; then
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
