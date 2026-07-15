---
name: deepsearch
description: "Skill unique de recherche multi-plateformes (Reddit, X, YouTube, Instagram, TikTok, LinkedIn, sources fiables) avec sous-agents parallèles et 7 modes auto-détectés : YouTube Research, Reddit Deep Dive, X Pulse, Instagram Trends, Social Listening, Creator Shortlist, Viral Pattern Analysis. Responsables qualité qui challengent les takes terrain vs sources fiables. À utiliser OBLIGATOIREMENT dès que Clément demande de chercher, vérifier, fouiller, monitorer, identifier des créateurs ou comprendre un sujet. Triggers : cherche, deep search, reddit, twitter, X, youtube, instagram, tiktok, fouille, vrais users, qui parle de, monitor, meilleurs créateurs, shortlist, pourquoi ce post marche, tendances, viral, résume cette vidéo, comparatif, avis, risques, analyse, podcast, créateurs, mentions. S'active sur /deepsearch."
---

# DeepSearch — Skill Unique de Recherche Multi-Sources avec Modes Spécialisés

Clément ne vérifie pas les sources lui-même. C'est ta responsabilité absolue.
Quand ce skill s'active, tu lances une recherche exhaustive **en parallèle** sur un maximum
de plateformes (Reddit, X, YouTube, Instagram, TikTok, LinkedIn, presse, officiel),
**détectes automatiquement le ou les modes spécialisés à activer** selon la question, puis
synthétises avec une couche **responsable qualité** qui challenge les opinions terrain
contre les sources fiables.

## Vision : un seul skill qui fait tout

Plutôt que 7 skills séparés, ce skill UNIQUE absorbe toutes les recherches sociales et
factuelles. Il détecte automatiquement les **modes** activés par la question :

- 🎬 **Mode YouTube Research** — vidéos, podcasts, transcripts
- 👁️ **Mode Reddit Deep Dive** — fouille profonde de communautés
- 🐦 **Mode X Pulse** — discours en temps réel sur X
- 📸 **Mode Instagram Trends** — carrousels, reels, créateurs IG
- 🎯 **Mode Social Listening** — monitoring de marque/personne/concurrent
- 🌟 **Mode Creator Shortlist** — top créateurs/experts d'un domaine
- 🧬 **Mode Viral Pattern Analysis** — pourquoi un contenu marche

**Plusieurs modes peuvent s'activer simultanément.** Si Clément demande "trouve les meilleurs
créateurs LinkedIn sur l'IA, monitore ce qui se dit sur Axem IA et fouille Reddit", les
modes Creator Shortlist + Social Listening + Reddit Deep Dive s'activent en parallèle dans
un même appel.

## Pourquoi Reddit, X, YouTube, IG sont prioritaires

Sur ces plateformes on trouve les opinions, retours d'expérience non polis, frustrations
réelles, hacks, contre-narratifs, signaux faibles que les blogs SEO ne diront jamais.
**Matière brute = créativité**. Mais ces opinions doivent être **systématiquement
challengées** par les sources institutionnelles avant d'être servies à Clément.

---

## Pipeline en 4 étages

```
[ÉTAGE 0 — Triage & Mode Detection] (1 agent rapide < 30s)
  └─ Détecte la profondeur (Lite/Standard/Heavy)
     + le ou les modes spécialisés à activer
     + scout les subreddits/comptes/chaînes pertinents

           ↓

[ÉTAGE 1 — Collecte massive parallèle] (TOUS dans un seul message)
  ├─ 12 agents sources fiables (Standard/Heavy)
  ├─ 3 agents Reddit standards
  ├─ 3 agents X standards
  └─ Agents conditionnels selon modes :
     ├─ Mode YouTube → 3 agents YT
     ├─ Mode Reddit Deep Dive → 3 agents RDD
     ├─ Mode X Pulse → 3 agents XP
     ├─ Mode Instagram → 3 agents IG
     ├─ Mode TikTok → 1 agent TT
     ├─ Mode Social Listening → 3 agents SL
     ├─ Mode Creator Shortlist → 3 agents CS
     └─ Mode Viral Pattern → 3 agents VP

           ↓

[ÉTAGE 2 — Responsables qualité parallèles] (3 agents, single message)
  ├─ QR-A : challenge takes terrain vs sources fiables
  ├─ QR-B : détecte contradictions inter-sources
  └─ QR-C : note fraîcheur, biais, représentativité

           ↓

[ÉTAGE 3 — Synthèse finale]
  Format adapté avec sections additionnelles selon les modes activés.
```

---

## Model-tiering & discipline de tokens (pour l'invoquer souvent sans exploser)

Chaque rôle tourne sur le modèle le moins cher qui fait bien le job — passe `model` à chaque appel `Agent` :

| Rôle | `model` | Pourquoi |
|---|---|---|
| **Orchestrateur = toi (main loop)** | `opus` | triage des priorités, synthèse finale, arbitrage qualité |
| **Étage 0 — triage** | `haiku` | JSON de cadrage en <30s, purement mécanique |
| **Étage 1 — agents collecteurs (recherche + verdict)** | `sonnet` | raisonnement + web, meilleur rapport qualité/coût |
| **Fetch pur / lookup (transcript, .json Reddit, métadonnées)** | `haiku` | récupérer, pas raisonner |
| **Étage 2 — responsables qualité** | `sonnet` | triangulation & fact-check argumentés |
| **Étage 3 — synthèse** | `opus` (toi) | c'est le livrable, tu le fais toi-même |

Règle d'or : **jamais d'Opus en sous-agent**. Opus, c'est toi, une fois.

**Discipline de tokens — le levier n°1 :** chaque sous-agent rend le **format structuré imposé** (ci-dessous),
JAMAIS un dump du contenu des pages. Ajoute dans chaque prompt : « ne recopie pas les pages, synthétise ;
citations courtes seulement ». Un agent qui renvoie 60k tokens de verbatim, c'est 95 % de gaspillage.

Autres leviers : (1) le triage calibre le nombre d'agents au sujet — `lite` = 3-5 agents sans QR, ne PAS
sur-dimensionner ; (2) réutilise `(mémoire interne)` + le vault avant de chercher un sujet déjà traité ; (3) un seul tour
de collecte par défaut, pas de vague 2 « pour être sûr » ; (4) zéro chevauchement d'angles entre agents.

## ÉTAGE 0 — Triage automatique (1 agent, AVANT tout le reste)

Lance un seul agent `general-purpose` léger qui retourne en < 30 secondes :

**Prompt** :
```
Tu es l'agent triage de DeepSearch. Analyse cette question et retourne un JSON :

QUESTION : [QUESTION DE CLÉMENT]

Retourne strictement :
{
  "depth": "lite" | "standard" | "heavy",
  "modes_actives": ["youtube_research", "reddit_deep_dive", "x_pulse", "instagram_trends", "tiktok", "social_listening", "creator_shortlist", "viral_pattern"],
  "subreddits_pertinents": ["r/...", "r/..."],
  "comptes_x_pertinents": ["@...", "@..."],
  "chaines_youtube_pertinentes": ["...", "..."],
  "comptes_ig_pertinents": ["@...", "@..."],
  "sites_presse_pertinents": ["...", "..."],
  "hashtags_cles": ["#..."],
  "langues_prioritaires": ["fr", "en"],
  "marque_a_monitorer": "string ou null",
  "creator_a_analyser": "string ou null",
  "post_a_analyser": "URL ou null"
}

Règles :
- depth "lite" : factuel simple → 3-5 agents max, pas de QR
- depth "standard" : analyse/comparaison → pipeline complet base
- depth "heavy" : sujet stratégique → pipeline complet + tous modes pertinents

Modes :
- youtube_research si "vidéo", "podcast", "youtube", "résume", "regarder"
- reddit_deep_dive si "fouille reddit", "vrais users", "communauté", "subreddit"
- x_pulse si "se dit en ce moment", "monitor x", "twitter actuel", "discours"
- instagram_trends si "instagram", "ig", "carrousels", "reels"
- tiktok si "tiktok"
- social_listening si "qui parle de [marque]", "monitor", "mentions", "veille concurrentielle"
- creator_shortlist si "meilleurs créateurs", "shortlist", "top influenceurs", "experts"
- viral_pattern si "pourquoi ce post marche", "pattern viral", "analyse ce post"

Plusieurs modes peuvent être activés simultanément.
```

---

## Les 7 modes spécialisés

### 🎬 Mode YouTube Research
**Triggers** : "youtube", "vidéo", "podcast", "résume cette vidéo", "youtuber", "chaîne"

**Agents** :
- **YT-1** — Top vidéos pertinentes (15) via WebSearch + `site:youtube.com [sujet]`. Note titre, chaîne, vues, durée, date.
- **YT-2** — Transcripts complets pour les 5-8 meilleures via Apify YouTube Transcript actor. Extrait insights, frameworks, contre-arguments.
- **YT-3** — 5 chaînes de référence (taille audience, fréquence, qualité éditoriale).

**Livrable additionnel** : Section 🎬 "À regarder" — 10 timestamps précis + 5 chaînes à follow.

### 👁️ Mode Reddit Deep Dive
**Triggers** : "fouille reddit à fond", "vrais users de", "communauté reddit", "subreddit"

**Agents** (en plus des 3 Reddit standards) :
- **RDD-1** — Cartographie : 5-10 subreddits ultra-pertinents (au-delà de la liste statique).
- **RDD-2** — Top all-time + top année + hot now via `.json` endpoint.
- **RDD-3** — Pattern extraction (pain points récurrents, hacks répétés, "always recommended").

**Livrable additionnel** : Section 👁️ "Carte d'opinions Reddit" — majoritaires/minoritaires/contrariennes + top 20 citations + 5 redditors experts.

### 🐦 Mode X Pulse
**Triggers** : "se dit en ce moment sur X", "monitor x", "discours twitter", "voix qui montent"

**Agents** (en plus des 3 X standards) :
- **XP-1** — Scrape récent (7 jours) via Apify Twitter scraper sur keywords + hashtags.
- **XP-2** — Top accounts par engagement réel (likes, RT, replies).
- **XP-3** — Threads viraux + analyse des quote tweets.

**Livrable additionnel** : Section 🐦 "Pulse X (7 derniers jours)" — briefing actuel + 10 comptes + 3 threads must-read.

### 📸 Mode Instagram Trends
**Triggers** : "instagram", "ig", "carrousels", "reels", "créateurs ig", "que se passe-t-il sur ig"

**Agents** :
- **IG-1** — Comptes business du domaine via Apify Instagram scraper.
- **IG-2** — Carrousels viraux & extraction des hooks (slide 1) des top comptes.
- **IG-3** — Reels & hashtags qui convertissent.

**Livrable additionnel** : Section 📸 "Instagram radar" — top 15 comptes + top 10 carrousels avec hooks + 5 angles trendy.

### 🎬 Mode TikTok (bonus)
**Triggers** : "tiktok", "tiktok dit", "tiktoks viraux"

**Agent** : **TT-1** via Apify TikTok scraper — vidéos qui buzzent, créateurs émergents, sons utilisés.

### 🎯 Mode Social Listening
**Triggers** : "qui parle de [marque/personne]", "monitor [X]", "mentions de", "veille concurrentielle", "que dit-on de"

**Cible** : la `marque_a_monitorer` du triage (ex: "Axem IA", une marque concurrente).

**Agents** :
- **SL-1** — Mentions cross-plateformes (Reddit + X + YouTube comments + LinkedIn + presse) sur 30 derniers jours.
- **SL-2** — Sentiment & ton (positif / neutre / négatif avec exemples).
- **SL-3** — Opportunités (questions non répondues, critiques à adresser, fans à activer).

**Livrable additionnel** : Section 🎯 "Social Listening — [Marque]" — volume/sentiment + top 5 mentions positives + top 5 négatives avec URL + opportunités RP priorisées.

### 🌟 Mode Creator Shortlist
**Triggers** : "meilleurs créateurs sur", "shortlist d'experts", "top influenceurs", "qui sont les références"

**Agents** :
- **CS-1** — Cross-platform scan (YouTube, X, IG, LinkedIn, podcasts FR).
- **CS-2** — Scoring (taille audience, qualité, fréquence, alignement, accessibilité).
- **CS-3** — Contact (email/site web) + 3 angles de collab adaptés à Clément (formation, podcast, post LinkedIn collab).

**Livrable additionnel** : Section 🌟 "Top créateurs" — tableau de 10 créateurs avec scoring + contact + 3 angles de collab.

### 🧬 Mode Viral Pattern Analysis
**Triggers** : "pourquoi ce post marche", "analyse ce pattern", "qu'est-ce qui rend [X] viral"

**Input requis** : URL d'un post / vidéo / créateur (capté au triage).

**Agents** :
- **VP-1** — Décomposition (hook, corps, CTA, format, longueur, timing, sujet, visuels).
- **VP-2** — Comparaison historique (10 autres posts du créateur : tops + flops).
- **VP-3** — Framework reproductible + 3 adaptations Clément-ready.

**Livrable additionnel** : Section 🧬 "Pattern viral identifié" — framework copiable + 3 adaptations.

---

## Hacks d'accès aux plateformes (CRITIQUE — à utiliser systématiquement)

WebFetch standard rate beaucoup de plateformes (login walls, JS-heavy, bots blocked).
Utilise ces routes alternatives :

> 🆓 **Si `agent-reach` est installé** (CLI, `github.com/Panniantong/agent-reach`, MIT,
> gratuit — installé sur le Mac mini serveur, à vérifier ailleurs via `agent-reach doctor`) :
> c'est la **méthode à essayer en premier pour Web/YouTube/RSS/GitHub/Web Search**, avant tout
> le reste ci-dessous — une seule commande `agent-reach fetch <url>` route automatiquement vers
> le bon outil (yt-dlp, Jina Reader, feedparser, gh CLI, Exa) avec fallback auto en cas d'échec.
> Pour Reddit/X/Twitter, agent-reach nécessite une config de compte (cookies via Cookie-Editor,
> idéalement un compte secondaire dédié, pas le compte principal) — si pas configuré, retombe
> sur les skills dédiés `reddit-fetch`/`adhx-twitter-reader` ci-dessous.

### Reddit
- 🆓 **EN PREMIER : skill `reddit-fetch`** (installé 07/07/2026, gratuit) — technique du
  "DDG-hop" : naviguer une fois vers `html.duckduckgo.com/html/?q=site:reddit.com/r/SUB+requête`
  via Claude-in-Chrome, cliquer le 1er résultat (pose le cookie de session Reddit), puis
  naviguer directement vers n'importe quelle URL `.json` pour le reste de la session. Marche
  pour 1-3 threads ciblés sans dépendre d'Apify.
- **Toujours** préférer `old.reddit.com` à `reddit.com` si fallback WebFetch/curl direct.
- **Endpoint JSON public** : ajouter `.json` à toute URL.
  - Thread : `https://old.reddit.com/r/[sub]/comments/[id]/.json` → post + arbre de commentaires complet avec scores
  - Top d'un sub : `https://old.reddit.com/r/[sub]/top/.json?t=year` (ou `month`, `week`, `all`)
  - Hot : `https://old.reddit.com/r/[sub]/hot/.json`
- Si le skill `reddit-fetch` échoue/rate-limite ou qu'il faut du vrai volume (dizaines de
  threads), passer à un Actor Apify (`trudax/reddit-scraper-lite`, payant à l'usage).

### X / Twitter
- 🆓 **EN PREMIER : skill `adhx-twitter-reader`** (installé 07/07/2026, gratuit, sans auth, sans
  rate-limit en lecture) — colle une URL x.com/twitter.com, récupère le post en JSON structuré
  (contenu complet, auteur, engagement). Idéal pour lire un tweet/thread précis déjà identifié.
- **WebFetch sur x.com / twitter.com échoue presque toujours** (login wall) — ne pas insister,
  passer direct au skill ADHX ou aux routes ci-dessous.
- **Routes de secours (recherche large / volume, ADHX ne fait que lire un post donné)** :
  - **Nitter** : `nitter.net/[user]` ou miroirs (`xcancel.com`, `nitter.privacydev.net`) — tester en cascade
  - **Apify Twitter scraper** (préféré gros volume) : `apidojo/twitter-scraper-lite` ou `quacker/twitter-scraper`
  - **Wayback Machine** : `web.archive.org/web/[URL twitter]`

### YouTube
- **Recherche** : WebSearch fonctionne.
- **Transcripts** : 🆓 **EN PREMIER : skill `youtube-transcript`** (installé 07/07/2026, gratuit,
  `uv run scripts/get_transcript.py <url>`) — récupère les sous-titres (auto ou manuels)
  directement, sans Apify. NE PAS faire WebFetch sur youtube.com pour le contenu.
  - Si la vidéo n'a pas de sous-titres ou que le skill échoue → fallback Apify
    (`streamers/youtube-scraper` ou `apify/youtube-transcripts-scraper`) ou
    `youtubetranscript.com/?server_vid=[VIDEO_ID]`.
- **Métadonnées** : WebFetch sur la page de la vidéo OK pour vues/date/durée.

### Instagram
- **Quasi tout fermé** sans login.
- **Apify** : `apify/instagram-scraper` (posts), `apify/instagram-profile-scraper` (comptes), `apify/instagram-hashtag-scraper`.

### TikTok
- **Apify** : `clockworks/tiktok-scraper` ou `apify/tiktok-scraper`.

### LinkedIn
- **Login wall** sur la plupart.
- WebSearch + `site:linkedin.com/posts` ou `site:linkedin.com/pulse` capte les publics indexés.
- Apify `apify/linkedin-scraper` (avec parcimonie).

### Web générique (sites d'entreprise, SPA, JS-heavy)
Seul vrai trou identifié dans cette liste (conseil d'agents du 15/07/2026, voir
`08-Idees-et-veille/2026-07-15-crawl4ai-ecarte.md`) : les 12 agents "sources fiables"
ne reposaient que sur WebSearch/WebFetch, sans solution robuste et gratuite pour du
contenu chargé en JS (dashboards, pages produit dynamiques, sites en React/Vue,
anti-bot léger type Cloudflare).
- 🆓 **EN PREMIER (à tester)** : connecteur navigateur déjà connecté (Claude-in-Chrome
  / Control_Chrome) — rendu JS réel, zéro quota, zéro nouvel outil. Naviguer vers
  l'URL, lire le texte/DOM rendu.
- Si le connecteur navigateur échoue ou n'est pas dispo : **Bright Data**
  (`mcp__brightdata-plugin__scrape` ou skill `brightdata-plugin:scrape`) — gratuit
  jusqu'à 5000 requêtes/mois, gère rendu JS + anti-bot, sortie markdown propre.
- **Apify** (RAG Web Browser actor ou scraper générique) seulement en dernier recours
  si les deux précédents échouent — payant à l'usage.
- ❌ Ne pas installer crawl4ai — évalué et écarté (incompatible avec l'environnement
  sandboxé Claude Code, redondant avec Bright Data déjà connecté). Détail complet dans
  la note vault ci-dessus.

### Toujours
- Si une plateforme refuse, **passer à la route alternative** sans insister.
- Mentionner explicitement dans le rapport quand un fetch a échoué.

---

## ÉTAGE 1 — Lancer TOUS les agents en parallèle (un seul message)

⚠️ **Tous les agents (toujours actifs + conditionnels) doivent être lancés dans un SEUL
message avec plusieurs tool_use Agent**. Pas de séquentiel.

Utilise le subagent_type `general-purpose` pour chaque sous-agent.

### Agents toujours actifs — Pilier Reddit (3)

**Agent Reddit-1 — Expériences brutes** : threads de gens qui ONT vécu le sujet.
Queries : `site:reddit.com [sujet] my experience`, `honest review`, `worth it`,
`after X months`, `what I learned`, `regret`. Utilise endpoint `.json`.

**Agent Reddit-2 — Débats & contre-narratifs** : positions impopulaires argumentées.
Queries : `unpopular opinion`, `overrated`, `underrated`, `hot take`, `change my mind`,
`vs [alt] debate`, `scam OR overhyped OR bullshit`. Fouille r/ChangeMyView,
r/unpopularopinion, threads avec ratio commentaires/upvotes élevé.

**Agent Reddit-3 — Niches expertes** : subreddits ultra-spécialisés.
Queries : `site:reddit.com/r/[niche]`, `professional`, `industry insider`, `what nobody
tells you`, `tips advanced`. Subreddits : r/ExperiencedDevs, r/devops, r/sales, r/marketing,
r/PPC, r/SEO, r/freelance, r/consulting, r/smallbusiness, r/startups, r/Entrepreneur,
r/AskAcademia, r/medicine, r/legaladvice, r/AskHistorians, r/AskScience.

### Agents toujours actifs — Pilier X (3)

**Agent X-1 — Threads d'experts** : analyse rapide originale des praticiens.
Queries : `site:x.com [sujet] thread`, `1/`, `expert`, `[nom expert] twitter`.
Fetch via Nitter ou Apify si X direct échoue.

**Agent X-2 — Hot takes** : positions clivantes.
Queries : `hot take`, `is wrong`, `is overrated`, `controversial`, `viral tweet`,
`twitter discourse`. Lis les **quote tweets**.

**Agent X-3 — Signaux faibles** : ce qui monte avant la presse.
Queries : `twitter early`, `new trend`, `emerging`, `before mainstream`, `indie hacker`.
Pour tech/IA : Indie Hackers, Build in Public, AI Twitter (Karpathy, Swyx, Eugene Yan).

### Agents toujours actifs — 12 sources fiables

**Agent 1 — Forums tech & GitHub** : HN, GitHub, Stack Overflow, Dev.to.
Queries : `site:news.ycombinator.com`, `site:github.com [sujet] issue`, `stackoverflow`.

**Agent 2 — Presse spécialisée & blogs experts** : presse sectorielle, newsletters, blogs.
Queries : `[sujet] 2025 guide expert`, `analysis blog`, `best [sujet] breakdown`.

**Agent 3 — Sources officielles & documentation** : sites officiels, docs, rapports.
Queries : `[sujet] official documentation`, `rapport officiel`, `étude`.

**Agent 4 — Données chiffrées & études** : Statista, scholar, sondages, INSEE, Eurostat.
Queries : `statistics 2025`, `market size report`, `study data`, `site:scholar.google.com`.

**Agent 5 — Cas concrets** : cas d'usage, témoignages, études de cas, before/after.
Queries : `case study`, `exemple concret`, `résultats réels`.

**Agent 6 — Critiques & points négatifs** : risques, pièges, échecs.
Queries : `problèmes risques`, `downside failure`, `avoid mistake`.

**Agent 7 — Actualité récente (6 mois)** : news, nouveautés, mises à jour.
Queries : `2025 news`, `update récent`, `latest change`.

**Agent 8 — Comparatifs & alternatives** : benchmarks, versus.
Queries : `vs alternatives`, `comparatif meilleur`, `best comparison`.

**Agent 9 — Opinions d'experts sectoriels** : LinkedIn thought leaders, podcasts, YouTube.
Queries : `expert opinion linkedin`, `podcast episode`, `avis professionnel`.

**Agent 10 — Questions connexes & contexte élargi**.
Queries : `impact implication`, `related questions`, `contexte global`.

**Agent 11 — Sources francophones** (si France/Europe) : presse FR, blogs FR, forums FR,
LinkedIn France, Frandroid, NextINpact, Numerama.
Queries : `france`, `europe réglementation`, `marché français`.

**Agent 12 — Contre-narratifs & fact-checking institutionnel** : AFP Factuel, Snopes.
Queries : `controversy debate`, `mythe réalité`, `fact check`.

### Agents conditionnels (selon modes activés au triage)

Si `youtube_research` → lance YT-1, YT-2, YT-3
Si `reddit_deep_dive` → lance RDD-1, RDD-2, RDD-3
Si `x_pulse` → lance XP-1, XP-2, XP-3
Si `instagram_trends` → lance IG-1, IG-2, IG-3
Si `tiktok` → lance TT-1
Si `social_listening` → lance SL-1, SL-2, SL-3 (cible = `marque_a_monitorer`)
Si `creator_shortlist` → lance CS-1, CS-2, CS-3
Si `viral_pattern` → lance VP-1, VP-2, VP-3 (sur `post_a_analyser` / `creator_a_analyser`)

**Cas typique** : "Trouve les meilleurs créateurs IA français, monitore Axem IA, fouille
Reddit". On active simultanément : 12 sources fiables + 3 Reddit + 3 X + 3 RDD + 3 SL +
3 CS = **24 agents en parallèle, un seul message**.

---

### Prompt à donner à chaque sous-agent de l'étage 1

```
Tu es un agent de recherche spécialisé sur l'angle : [NOM DE L'ANGLE].

Question principale : [QUESTION]
Ton angle spécifique : [DESCRIPTION DE L'ANGLE]
Plateforme prioritaire : [Reddit / X / YouTube / IG / Web / etc.]
Contexte triage : [JSON triage utile pour cet agent]

Instructions :
1. Lance 4 à 6 recherches WebSearch avec queries variées (FR + EN si pertinent)
2. Pour chaque recherche, fetch les 3 à 5 pages/threads les plus pertinents :
   - Reddit → endpoint `.json`
   - X → nitter.net puis Apify si échec
   - YouTube → Apify pour transcripts
   - IG/TikTok → Apify scrapers
   - Web → WebFetch standard
3. Note URL, date, infos clés
4. Si fetch échoue, mentionne-le et essaie une route alternative

Retourne (format obligatoire) :

## Sources consultées
[Liste URLs + date + plateforme + score qualité 1-5]

## Informations principales
[Regroupé par sous-thème]

## Citations marquantes
[3-10 citations courtes avec auteur + URL — surtout pour Reddit/X/YT/IG]

## Ce qui est certain (selon cet angle)

## Ce qui est incertain ou contesté

## Chiffres clés
[Avec source et date]

## Signaux faibles / contre-intuitifs
```

---

## ÉTAGE 2 — Responsables qualité (3 agents en parallèle)

Une fois TOUS les agents de l'étage 1 revenus, lance immédiatement **3 agents qualité en
parallèle** (single message). Leur job : challenger la matière brute, pas la collecter.

### Quality Reviewer A — Triangulation takes terrain vs sources fiables

```
Tu es un responsable qualité éditorial. Tu reçois :
1. Les takes / opinions / hacks issus des agents Reddit, X, YouTube, IG
2. Les findings des 12 agents sources fiables

Pour chaque take notable (au moins les 10-15 plus marquants) :
- Reformule clairement
- Cherche dans les findings des sources fiables s'il est confirmé / nuancé / contredit
- Si pas couvert, lance 1-2 WebSearch ciblés pour vérifier
- Verdict : ✅ Confirmé / 🟡 Partiellement / 🔴 Contredit / ⚪ Non vérifiable
- Justification 1-2 phrases avec source

Retourne tableau : Take | Source originale (plateforme + auteur) | Verdict | Justif | Source vérif
```

### Quality Reviewer B — Détection des contradictions inter-sources

```
Tu es fact-checker. Tu reçois les findings de tous les agents de l'étage 1.

Repère :
- Chiffres qui divergent entre sources
- Affirmations contradictoires
- Zones où le consensus est faible
- Sources qui se citent mutuellement (faux consensus)

Pour chaque contradiction :
- Le point en désaccord
- Les sources de chaque camp
- Ton hypothèse sur qui a probablement raison (et pourquoi)
- Si non tranchable : "à présenter comme contesté"
```

### Quality Reviewer C — Fraîcheur, biais, représentativité

```
Tu es méthodologue. Pour chaque grand groupe d'info :

1. FRAÎCHEUR : la source date de quand ? Le sujet a-t-il évolué ?
2. BIAIS : qui parle ? Avec quel intérêt ? (vendeur, concurrent, fan, hater)
3. REPRÉSENTATIVITÉ : cas isolé ou pattern ?
   - Reddit : combien de threads ? upvotes cumulés ?
   - X : combien de comptes ? reach cumulé ?
   - YouTube : combien de chaînes ? vues cumulées ?
   - IG : combien de comptes ? engagement moyen ?
   - Presse : combien de médias indépendants ?
4. INDÉPENDANCE : les sources se recopient-elles ?

Retourne pour chaque cluster : note /5 sur chaque dimension + reco
("à servir comme certain" / "à nuancer" / "à servir comme opinion seulement").
```

---

## ÉTAGE 3 — Synthèse finale

Tu disposes de :
- Le triage initial (étage 0) avec les modes activés
- N rapports d'agents collecteurs (étage 1)
- 3 rapports de responsables qualité (étage 2)

### Format de réponse obligatoire (sections universelles)

**Score de confiance globale** : X/10
- Couverture : N sources, M plateformes
- Convergence : nombre de contradictions notables
- Fraîcheur : % des sources < 6 mois
- Représentativité terrain : N threads Reddit, M comptes X, K vidéos YT, etc.

**TL;DR** (2-3 phrases, ce que Clément doit retenir)

**Analyse approfondie** (par thématique, jamais par source ni par agent)

**Ce qui est certain** ✅
Crossé par 2+ sources indépendantes ET validé par QR-A ou QR-B.

**Ce qui est incertain ou contesté** 🟡
Avec mention explicite du désaccord et des deux positions.

**Chiffres clés vérifiés** 📊
Avec source et date.

**🔥 Ce que les gens vivent vraiment (Reddit + X + YouTube + IG)**
**Section signature.** 5 à 10 takes terrain marquants avec :
- Citation ou résumé
- Auteur (u/pseudo, @handle, chaîne YT) + plateforme + date
- Verdict QR-A : ✅ confirmé / 🟡 nuancé / 🔴 contredit / ⚪ opinion non vérifiable
- Pourquoi c'est intéressant pour Clément

**Signaux faibles & contre-narratifs**

**À retenir / actions recommandées** (concret, actionnable)

**Sources** — liens markdown avec titre + date + plateforme.
Sépare en sections : Sources institutionnelles · Reddit · X · YouTube · Instagram · LinkedIn.

### Sections additionnelles selon les modes activés

→ Si **YouTube Research** activé : ajouter section **🎬 À regarder** (10 timestamps + 5 chaînes)

→ Si **Reddit Deep Dive** activé : ajouter section **👁️ Carte d'opinions Reddit** (majoritaires/minoritaires/contrariennes + top 20 citations + 5 redditors)

→ Si **X Pulse** activé : ajouter section **🐦 Pulse X (7 derniers jours)** (briefing actuel + 10 comptes + 3 threads)

→ Si **Instagram Trends** activé : ajouter section **📸 Instagram radar** (top 15 comptes + top 10 carrousels avec hooks + 5 angles)

→ Si **Social Listening** activé : ajouter section **🎯 Social Listening — [Marque]** (volume + sentiment + top mentions + opportunités RP priorisées)

→ Si **Creator Shortlist** activé : ajouter section **🌟 Top créateurs** (tableau de 10 avec scoring + contact + 3 angles de collab)

→ Si **Viral Pattern** activé : ajouter section **🧬 Pattern viral identifié** (framework copiable + 3 adaptations Clément-ready)

---

## Règles de qualité

- Ne jamais présenter une info terrain comme un fait sans le verdict QR-A
- Croiser au moins 2 sources indépendantes pour chaque affirmation présentée comme certaine
- Toujours indiquer la fraîcheur des données
- Signaler explicitement les contradictions entre sources
- Zéro hallucination — si introuvable, le dire explicitement
- Hiérarchie épistémique : études officielles > presse spécialisée indépendante > experts
  sectoriels reconnus > retours terrain Reddit/X/YT/IG > opinions générales
- **Mais** : un take terrain confirmé par les sources fiables vaut autant que la source
  fiable elle-même, et apporte la couleur terrain. Ne jamais l'écraser.
- Si terrain vs institutionnel divergent, **présenter les deux** et laisser Clément
  trancher (avec ton hypothèse explicite).

## Anti-patterns à éviter absolument

❌ **Réponse lisse 100% institutionnelle** — Clément veut la matière brute terrain EN PLUS
du factuel propre, pas à la place.

❌ **Reprendre un take terrain sans verdict QR-A** — toujours afficher le verdict.

❌ **Lancer les agents en séquentiel** — TOUT l'étage 1 dans un seul message (peu importe
le nombre, même 24 agents). TOUT l'étage 2 dans un seul message.

❌ **Skipper l'étage 0 (triage)** — sans triage, tu lances trop ou trop peu d'agents et tu
rates les modes spécialisés.

❌ **Faire WebFetch direct sur instagram.com / x.com / youtube.com pour le contenu** — ça
échoue. Toujours passer par les routes alternatives (Apify, Nitter, .json, transcript APIs).

❌ **Ne pas afficher le score de confiance** — Clément doit savoir d'un coup d'œil si la
synthèse est solide ou à challenger.

❌ **Oublier les sections additionnelles selon les modes activés** — si Creator Shortlist
était activé, la section "Top créateurs" est OBLIGATOIRE dans la synthèse.

❌ **Ne pas activer un mode quand un trigger évident est présent** — si Clément dit
"qui parle d'Axem IA", le mode Social Listening DOIT s'activer. Pas optionnel.
