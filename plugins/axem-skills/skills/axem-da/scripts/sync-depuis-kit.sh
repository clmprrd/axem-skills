#!/bin/zsh
# Recopie le socle du kit de marque dans les assets du skill (le kit du vault fait foi).
# À relancer après toute modification dans Marque-DA-2026/kit/_src ou kit/logo.
set -e
KIT=${AXEM_KIT:-${0:A:h:h:h:h}/01-Axem-IA/Marque-DA-2026/kit}
DST=${0:A:h:h}/assets
mkdir -p $DST/gabarits $DST/logo $DST/fonts
# Pas de photos ni de noms de famille dans le skill : il doit rester partageable tel quel.
rm -rf $DST/img
cp $KIT/_src/axem-kit.css $KIT/_src/render.py $KIT/_src/gen_proposition.py $KIT/_src/habiller_devis.py $DST/gabarits/
cp $KIT/_src/{logo,fond-visio,reserver-30min,proposition,charte,carrousel,banniere-entreprise,carte-visite}.html $DST/gabarits/
cp $KIT/_src/fonts/*.woff2 $DST/fonts/
cp $KIT/logo/*.png $KIT/signature/logo-bleu-320.png $DST/logo/
python3 - "$KIT/commercial/exemple-proposition.json" "$DST/gabarits/exemple-proposition.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
d['equipe'] = [{"nom": "Prénom Nom", "lettres": l, "role": "Cofondateur, AXEM IA", "photo": ""} for l in ("AX", "EM")]
json.dump(d, open(sys.argv[2], 'w'), ensure_ascii=False, indent=2)
PY
# Les gabarits cherchent fonts/ à côté d'eux : lien relatif dans le skill
ln -sfn ../fonts $DST/gabarits/fonts; rm -f $DST/gabarits/img
echo "assets synchronisés depuis $KIT"
