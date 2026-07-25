# Conseil d'agents — garde-fous & outils (détail)

Chargé à la demande. Le SKILL.md garde les résumés ; ici le détail complet.
**Honnêteté sur la nature de ces garde-fous** (audit du 24/07/2026) : sauf mention contraire, ce sont des **consignes
de prompt**, pas des blocages techniques. Un sous-agent garde tous ses outils : seule sa docilité opère. Les traiter
comme des gates est une erreur de lecture qui donne un faux sentiment de contrôle.

## 1. Garde-fou coût (anti-Apify payant)

**Le problème observé le 24/07** : en sandbox, les routes Reddit gratuites tombent (reddit.com refusé par la policy
navigateur, CAPTCHA DuckDuckGo sur le DDG-hop, WebSearch qui filtre le domaine). Les agents cascadent alors **en
silence** vers des actors Apify **facturés** (`trudax/reddit-scraper-lite`, `rag-web-browser`) jusqu'à épuisement des
crédits, sans jamais demander. Clément l'a découvert par un mail « crédits épuisés ».

**La règle** (injectée dans chaque prompt d'agent web par le Workflow) : routes gratuites uniquement (skill
`reddit-fetch` en DDG-hop, `old.reddit.com/.json`, `adhx-twitter-reader`, `youtube-transcript`, WebSearch). Si elles
échouent → **signaler explicitement « route gratuite bloquée, terrain partiel »** dans le rapport et **dégrader**
proprement. Aucune dépense de crédits sans feu vert explicite.

**Ce que ça ne fait PAS** : empêcher techniquement l'appel. Si l'incident se reproduit, la vraie réponse est un hook
`PreToolUse` sur le modèle de `~/.claude/hooks/block-git-axem-vault.py`, qui refuse `mcp__Apify__*` sauf feu vert.
⚠️ Avertissement du steelman (24/07) : un hook calibré trop large bloquera un usage légitime, sera désactivé par
agacement, et restera désactivé en silence. Si hook il y a : **avertir/logger par défaut, bloquer en dur seulement**
pour les catégories déjà prohibées ailleurs (financier, destructif).

**À savoir** : les skills `reddit-fetch`, `adhx-twitter-reader`, `youtube-transcript` sont des dossiers locaux **sans
`.git`**, figés au 07/07/2026, sans auto-update ni cron. Un skill à jour se cognerait aux mêmes murs : le blocage est
**environnemental**, pas une question de version. Pour du terrain gratuit fiable : cookie de session Reddit (compte
secondaire dédié) ou collecte depuis le Mac mini serveur.

Voir [[apify-fallback-payant-quand-reddit-gratuit-bloque]].

## 2. Hook `/find-skill` (Phases 1 et 3)

Quand la recherche (Phase 1) ou un fix (Phase 3) fait apparaître qu'une tâche gagnerait à un **skill qui existe déjà**,
invoque `/find-skill` plutôt que réinventer. Il scanne skills.sh (classé par installs réels) + GitHub/Reddit/X, score
sur 100, et auto-installe le #1. Mode choisi par Clément le 24/07 : *auto-install + applique*.

**Barrière de sécurité (non négociable, code tiers)** — l'auto-install télécharge du code depuis GitHub :
- **Install** autorisée uniquement dans les garde-fous natifs de find-skill : score ≥ 70, **licence MIT/Apache/BSD**,
  source officielle (`anthropics/*`, `obra/*`) **OU** install-count ≥ 1k, **pas d'outil destructeur**, pas de secrets,
  max 2 installs/session, jamais d'overwrite silencieux. En dessous → présenter le TOP 3 et **attendre le go**.
- **Exécution** d'un skill fraîchement installé : toujours soumise à la règle du pipeline, **jamais d'action
  irréversible ou externe (envoi, publication, delete, push) sans go**. Installer n'est pas exécuter à l'aveugle.
- **Surfacer** systématiquement le skill installé (nom + source + score) dans le livrable, jamais en douce.

⚠️ Ces vérifications sont faites par le modèle lui-même (il s'auto-note et s'auto-audite), pas par un script. C'est le
garde-fou le plus faible du lot : le traiter comme tel.

## 3. Anti-oubli de la Phase 4

Le batch final a déjà sauté silencieusement une fois (17/07/2026, session longue avec enchaînement de sujets). Le
correctif actuel est une consigne de relecture (« ai-je appelé AskUserQuestion ? »), donc **le même mécanisme qui a
déjà échoué**. Assumé sciemment après l'audit du 24/07 : le steelman a montré qu'un incident isolé (n=1, sans taux de
base connu) ne justifie pas une machine à états dont la maintenance retomberait sur Clément à chaque édition de prose.

**Signal à surveiller** : si le batch saute une deuxième fois, le taux de base cesse d'être n=1 et la mécanisation
devient justifiée. Dans ce cas, la bonne forme est un **artefact concret** (le texte réel du batch) et non un booléen
« phase cochée » : une case cochée à vide inspire une fausse confiance, alors qu'une phase visiblement sautée
s'auto-dénonce.
