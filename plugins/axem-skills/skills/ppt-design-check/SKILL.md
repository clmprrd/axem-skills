---
name: ppt-design-check
description: Garde-fou design anti-"AI slop" pour toute présentation PowerPoint. À invoquer AVANT de créer un deck (direction artistique) OU quand un deck existant est moche/générique (diagnostic + correction ciblée). Fonctionne aussi bien pour une génération from-scratch (skill pptx / Cowork) que pour une édition dans le plugin officiel Claude for PowerPoint. Déclencheurs : "/ppt-design-check", "ce PPT est moche", "améliore le design de ce deck", "avant de créer les slides, check le design", "cette présentation fait trop IA".
sources: recherche sourcée juillet 2026 (support.claude.com, Claude Cookbook Anthropic, github.com/anthropics/skills/pptx, superdesign.dev, winningpresentations.com)
last_updated: 2026-07-02
---

# ppt-design-check — anti-slop pour PowerPoint

## Quand l'utiliser

1. **AVANT de générer un deck** (peu importe l'outil : skill `pptx` de Cowork, ou plugin **Claude for PowerPoint** dans l'app) → charge ce fichier en entier et applique la Phase A (direction artistique) avant d'écrire le moindre prompt de contenu.
2. **APRÈS coup**, quand un deck existant (généré par toi ou reçu d'un tiers) a l'air générique/IA/plat → applique la Phase B (diagnostic) puis corrige avec les prompts de la Phase C.

Ne jamais sauter la Phase A sous prétexte "je sais déjà ce que je veux" — c'est justement l'étape que tout le monde saute et qui produit le slop.

---

## Phase A — Direction artistique (AVANT de créer le deck)

Ne demande jamais directement "fais-moi un deck sur X". Fixe d'abord 4 paramètres, en une phrase chacun, AVANT le prompt de contenu :

1. **Référence de style forte** (pas un adjectif comme "moderne" ou "pro" — une vraie référence) : Stripe / Linear / The Economist / Monocle magazine / McKinsey dense / Apple Keynote minimal. Une référence forte force le modèle à converger sur UNE direction cohérente au lieu de deviner parmi trop d'options.
2. **Palette imposée** (pas "bleu corporate") : une couleur dominante à 60-70 % du poids visuel, 1-2 tons secondaires, 1 accent tranchant. Donne les codes hex si tu les as (charte Axem IA ou charte client).
3. **Typographie imposée** : jamais Arial / Inter / Roboto / police système par défaut. Pour du premium éditorial : Georgia, Playfair Display, Fraunces. Pour du tech/startup : Clash Display, Satoshi, Cabinet Grotesk.
4. **Un seul motif visuel** répété sur tout le deck (ex : cadres arrondis + icônes en cercles colorés, OU bordure épaisse sur un seul côté — jamais les deux, jamais varié slide par slide).

### Bloc à coller tel quel dans ton prompt (source : Claude Cookbook Anthropic, adapté slides)

```
<frontend_aesthetics>
Tu as tendance à converger vers des sorties génériques et "sur la distribution".
Typographie : choisis des polices élégantes, uniques, intéressantes. Jamais Arial,
Inter, Roboto, Open Sans, Lato ou police système par défaut.
Couleur & thème : engage-toi sur une esthétique cohérente. Une couleur dominante
avec un accent tranchant surpasse toujours une palette timide et uniformément
répartie. Inspire-toi de thèmes d'IDE ou d'esthétiques culturelles fortes.
Fonds : crée de l'atmosphère et de la profondeur plutôt que des aplats de couleur
par défaut.
À bannir absolument : Inter/Roboto/Arial/police système, dégradé violet sur fond
blanc, layout hero centré + 3 cartes, ombres à 0.1 d'opacité, coins arrondis
partout, icônes stock génériques, accroches clichées ("dans un monde en
constante évolution...").
</frontend_aesthetics>
```

### Règle d'or pptx (déjà dans le skill `pptx` standard — à rappeler quand même)
**"NEVER use accent lines under titles — c'est la signature visuelle n°1 d'un deck généré par IA."**

---

## Phase B — Diagnostic (deck déjà créé, moche)

Passe le deck en revue avec cette checklist (les 10 erreurs les plus documentées mi-2026) :

| # | Symptôme | Cause |
|---|---|---|
| 1 | Tout le texte a la même taille/poids visuel | Hiérarchie plate — max 4 tailles de police/slide, 6/deck |
| 2 | Dégradé bleu-violet, cartes arrondies, hero centré | Convergence distributionnelle du LLM (pattern le plus probable statistiquement) |
| 3 | Chaque slide a exactement le même nombre de puces / même longueur de titre | Normalisation excessive — une vraie présentation humaine varie |
| 4 | Icônes stock, images IA glossy/3D, accroches clichées | "Tells" reconnaissables d'un deck IA |
| 5 | Palette bleu corporate par défaut au lieu de la charte réelle | Palette outil, pas palette marque — imposer 60/30/10 |
| 6 | Texte bon mais mise en page plate (surtout si généré par Claude/ChatGPT sans étape design séparée) | Absence de couche design dédiée |
| 7 | Texte français tronqué ou en police minuscule | Le français fait 15-20 % de mots en plus que l'anglais — prévoir la marge |
| 8 | Structure "4-5 puces + image" identique sur chaque slide | Pas de variation de composition (plein écran / split-screen / full-bleed) |
| 9 | Ligne d'accent sous chaque titre | Signature classique "deck généré par IA" |
| 10 | Prompt de départ vague ("fais un deck sur X") | Moins de spécificité = sortie plus proche de la moyenne statistique |

---

## Phase C — Prompts de correction ciblée

**Dans le plugin Claude for PowerPoint** (édition d'un deck déjà ouvert — cible une slide précise, jamais tout le deck d'un coup) :
```
Simplifie le texte de la slide 3, il est trop dense.
Remplace le dégradé violet du fond par [couleur de la charte].
Retire la ligne d'accent sous le titre de la slide 5, garde juste la hiérarchie
par la taille de police.
Recompose la slide 7 en split-screen au lieu de la disposition centrée actuelle.
```
Bonne pratique officielle : applique d'abord ton template de marque, PUIS demande à Claude de générer le contenu — jamais l'inverse.

**Pour une génération from scratch (skill `pptx` / Cowork)** :
```
Crée un deck de [N] slides sur [sujet], style [référence forte imposée en Phase A].
Palette : [couleur dominante hex] à 60-70 %, [couleur secondaire hex], accent
[couleur hex] utilisé avec parcimonie. Typo : [police titre] / [police corps],
jamais Arial/Inter. Un seul motif visuel répété : [motif choisi]. Zéro ligne
d'accent sous les titres. Varie la composition entre slides (pas 4-5 puces +
image partout). Fais une passe de QA visuelle avant de me le livrer : rends
chaque slide en image et vérifie chevauchements, débordements de texte,
contrastes faibles, marges insuffisantes.
```

**QA finale à toujours lancer avant de livrer** (le skill `pptx` le prévoit déjà — ne pas sauter cette étape même si ça semble bon au premier rendu) :
```
Convertis chaque slide en image et inspecte-la avec un regard neuf : y a-t-il
un chevauchement de texte, un débordement, un contraste insuffisant, une marge
trop faible, une ligne d'accent sous un titre, une police système par défaut ?
Si oui, corrige et relance le rendu.
```

---

## Sources
- [Use Claude for PowerPoint](https://support.claude.com/en/articles/13521390-use-claude-for-powerpoint) — 27/05/2026, officiel
- [Claude for Microsoft 365](https://claude.com/claude-for-microsoft-365) — officiel
- [pptx/SKILL.md — anthropics/skills](https://github.com/anthropics/skills/blob/main/skills/pptx/SKILL.md) — officiel
- [Prompting for frontend aesthetics — Claude Cookbook](https://platform.claude.com/cookbook/coding-prompting-for-frontend-aesthetics) — officiel, 21/10/2025
- [Why AI Design Looks Generic — superdesign.dev](https://superdesign.dev/blog/why-ai-design-looks-generic) — 15/06/2026
- [AI-generated slides look generic — winningpresentations.com](https://winningpresentations.com/ai-generated-slides-look-generic/)
- [Why AI slides look fake — 2Slides](https://2slides.com/fr/blog/why-ai-slides-look-fake-and-how-to-fix)
