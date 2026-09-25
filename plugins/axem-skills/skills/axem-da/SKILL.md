---
name: axem-da
description: "DA AXEM bleu électrique : à charger AVANT toute production visuelle AXEM (visuel LinkedIn, carrousel, deck, slides, PDF, proposition, devis, facture, fond Meet/Teams, signature mail, Skool, t-shirt, goodies, page web, charte). Logo, couleurs, polices, gabarits prêts."
---

# DA AXEM IA (version du 25/09/2026)

Tout support qui porte la marque AXEM part de ce skill. On ne réinvente ni les couleurs, ni les polices, ni le logo : on part des gabarits de `assets/gabarits/`, rendus en PNG ou PDF par `render.py`.

**Source qui fait foi : le kit du vault**, `Axem-IA-Hub/01-Axem-IA/Marque-DA-2026/kit/` (index dans `kit/README.md`, liste complète des supports dans `kit/CARTOGRAPHIE-SUPPORTS.md`). Les `assets/` de ce skill en sont une copie, rafraîchie par `scripts/sync-depuis-kit.sh`. Si le kit est accessible, travailler dans le kit.

## Le socle, à respecter sans exception

| Élément | Valeur |
|---|---|
| Bleu électrique (couleur de la marque) | `#2349FF` |
| Bleu profond (filigranes sur bleu) | `#1A38D6` |
| Crème (fonds clairs) | `#FAF6EA` |
| Encre (texte, fonds sombres) | `#0B0D12` |
| Gris (texte secondaire) | `#3A3D45` |
| Titres | Fraunces 900, `"SOFT" 100, "opsz" 144`, interlettrage -0,035em |
| Accent | Fraunces italique 400, sur UN mot, jamais une phrase entière |
| Texte et surtitres | Instrument Sans ; surtitre en capitales espacées 0,14em |
| En mail (polices web absentes) | Georgia pour les titres, Arial pour le texte |

- **Logo** : le mot « axem » en Fraunces 900 suivi de « IA » en exposant Instrument Sans 700 (classe `.wm` de `axem-kit.css`). Bleu sur clair, crème sur bleu ou encre. PNG prêts dans `assets/logo/`. Ce n'est PAS le masque PNG d'origine d'Alexis (décision du 24/09).
- **Accroche verrouillée** : « Votre partenaire IA, de A à Z. »
- **Le nom** : AX d'Alexis, EM de Clément, et IA. Titre des deux associés : « Cofondateur, AXEM IA ».
- **Motifs** : le A et le Z géants en filigrane, la grille fine sur crème.
- **Les deux carrés ne font plus partie de la DA** (décision de Clément, 25/09/2026) : ne jamais les réintroduire.
- **Proportions** : environ 60 % crème ou blanc, 30 % bleu, 10 % encre. Bleu en aplat, jamais de dégradé.

## Gabarits disponibles

| Besoin | Gabarit | Commande |
|---|---|---|
| Logo, carré, icône | `logo.html` (blocs `#logo-bleu`, `#carre-bleu`, `#icone-bleu`…) | `python3 render.py logo.html out.png --selector '#carre-bleu' --w 1200 --h 1200` |
| Fond Meet ou Teams | `fond-visio.html#v=bleu&nom=Prénom Nom` (`v` = bleu, creme, encre ; `nom` et `role` facultatifs, rôle par défaut « Cofondateur, AXEM IA ») | `python3 render.py 'fond-visio.html#v=creme&nom=Prénom Nom' out.png --w 1920 --h 1080` |
| Visuel « Réserver 30 min » | `reserver-30min.html#f=paysage` (paysage 1200x627, vertical 1080x1350, carre 1080x1080) | `python3 render.py 'reserver-30min.html#f=vertical' out.png --w 1080 --h 1350` |
| Carrousel LinkedIn 1080x1350 | `carrousel.html#p=page&t=Titre&a=mot en italique&x=texte&n=2&tot=6` (`p` = couv, page ou fin ; `auteur=` pour Alexis) | `python3 render.py 'carrousel.html#p=page&t=…' 02.png --w 1080 --h 1350` |
| Bannière page entreprise LinkedIn | `banniere-entreprise.html` | `python3 render.py banniere-entreprise.html out.png --w 1128 --h 191 --scale 2` |
| Proposition commerciale A4 | `proposition.html` + un JSON sur le modèle de `exemple-proposition.json` (champ `equipe` : nom, lettres, rôle, chemin de photo) | `python3 gen_proposition.py donnees.json sortie.pdf` |
| Couverture AXEM sur un devis ou une facture Qonto | `habiller_devis.py` (les pages Qonto restent intactes) | `python3 habiller_devis.py devis-qonto.pdf sortie.pdf --client "…" --objet "…" --ref D-2026-004` |
| Carte de visite 85 x 55 mm (+3 mm de fond perdu) | `carte-visite.html#nom=…&role=…&tel=…&mail=…` | `python3 render.py 'carte-visite.html#nom=…' carte.pdf --pdf` (voir le kit, `print/`) |
| Charte graphique A4 | `charte.html` (à rendre depuis le kit, elle affiche les visuels du kit) | `python3 render.py charte.html charte.pdf --pdf --format A4` |

Photos des associés : `kit/_src/img/` (jamais copiées dans le skill, qui reste partageable). Dans le kit, sans équivalent ici car trop lourds ou nominatifs : le deck de base (`kit/deck/`, PDF + PowerPoint), les t-shirts (`kit/textile/`), Skool (`kit/skool/`) et les signatures mail (`kit/signature/`).

Nouveau support sans gabarit : créer une page HTML qui charge `axem-kit.css`, utiliser ses classes (`.f`, `.i`, `.kicker`, `.wm`, `.bg-blue`, `.bg-cream`, `.bg-ink`), rendre avec `render.py`, puis ajouter le gabarit au kit et à la cartographie.

## Règles de production

1. **Regarder le rendu, toujours.** Ouvrir chaque PNG ou chaque page de PDF avant de le livrer : débordement, mot orphelin, accent cassé, texte coupé. Un gabarit qui compile n'est pas un visuel juste.
2. **Montrer les captures à Clément**, il ne dit que son désaccord (règle du site AXEM, étendue à toute la DA).
3. **Aucun chiffre non sourcé** sur un support. Pour « +200 entreprises accompagnées », « +3 000 collaborateurs formés » et le bandeau de logos clients, la source est `site-A/matiere/clients.md`, section 5 (décisions du 19/09/2026) : la relire avant de les reprendre. Le nombre d'abonnés LinkedIn se relit dans les `data-abo` du site, il bouge.
4. **Prix** : seuls les prix publics du site (coaching 250 / 1 100 / 2 000 € HT, audit dès 2 500 € HT, formation dès 200 € HT par personne). Tout autre montant se fait valider par Clément avant d'apparaître sur un support envoyé.
5. **Pas de numéro de version de modèle d'IA** sur un support, pas de certification qualité en propre (elle est portée par un partenaire).
6. **Zéro tiret cadratin** dans les textes, accents écrits en clair.
7. **Le Calendly 30 min est pris par des closers** : un visuel d'appel à réserver parle de « l'équipe AXEM », jamais d'un associé nommément.
