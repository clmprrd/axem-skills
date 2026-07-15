---
name: derame
description: >
  Déramer le Mac de Clément à la demande — RAM, CPU ET espace disque. À utiliser
  dès que Clément dit "mon ordi rame", "déramе", "/derame", "ça bug", "libère la
  RAM", "allège mon mac", "mon mac est lent", "nettoie la mémoire", "ça lag",
  "j'ai plus de place", "vide mes Go", "espace disque", "mon disque est plein".
  Le skill diagnostique RAM/CPU/disque en live sur la VRAIE machine de Clément
  via l'outil Mole (57k⭐ GitHub, brew install mole), propose un nettoyage
  détaillé par catégorie — et ne supprime/ferme jamais rien sans validation
  explicite.
---

# 🧠 Skill `/derame` — Déramage Mac à la demande (mode doux, propulsé par Mole)

## Objectif
Quand le Mac de Clément rame, bug, ou manque de place : (1) diagnostiquer RAM +
CPU + disque en un coup d'œil, (2) purger sans risque ce qui peut l'être
automatiquement, (3) identifier précisément ce qui bouffe la RAM/le CPU/le
disque, puis (4) proposer un nettoyage détaillé — **uniquement exécuté après
son OK**.

## ⚙️ Moteur : Mole (`mo`)
Depuis le 07/07/2026, ce skill s'appuie sur **Mole** (tw93/Mole, 57 400⭐ sur
GitHub, GPL-3.0, `brew install mole`) au lieu d'un script maison. Mole
remplace CleanMyMac/AppCleaner/DaisyDisk/iStat Menus par un seul binaire CLI.
Installé sur le Mac de Clément le 07/07/2026 (v1.44.1).

Si `mo` n'est pas installé sur la machine (ex : Mac d'Alexis) :
```bash
brew install mole
```
Si Homebrew indisponible, fallback sur l'ancien script maison :
`bash "/Users/clementpredo/Downloads/Axem-IA-Hub/06-Skills-Claude/derame/derame.sh"`
(diagnostic RAM only, sans le volet disque/CPU/Mole).

## ⚠️ Règle d'or (inchangée, non négociable)
- **Mode DOUX** : diagnostic et `mo status`/`mo analyze` sont des lectures seules,
  sans risque. Toute commande destructrice (`mo clean`, `mo purge`, `mo uninstall`,
  `kill`, `quit app`) se fait **d'abord en `--dry-run`**, puis **seulement après
  confirmation explicite de Clément** en vrai.
- **NE JAMAIS** kill/quitter un process, supprimer un fichier, désinstaller une
  app ou lancer `mo clean --force`/`mo purge`/`mo uninstall` sans son accord.
- Tout s'exécute sur la **VRAIE machine de Clément** via `desktop-commander`
  (`mcp__desktop-commander__start_process` / `mcp__Desktop_Commander__start_process`),
  **jamais** dans le sandbox `mcp__workspace__bash` (ça mesurerait le Linux du
  sandbox, pas le Mac de Clément).

## Procédure d'exécution

### Étape 1 — Diagnostic global (RAM + CPU + disque + santé)
```bash
mo status --json
```
Donne en une commande : health_score /100, RAM (used/free/avail), CPU (usage
global + par cœur), disque (used/free/%), uptime, nb de process. C'est le
nouveau point d'entrée par défaut (remplace le script `derame.sh` pour le volet
RAM/CPU).

Si Clément parle spécifiquement d'espace disque manquant ("j'ai plus de
place", "vide mes Go") → enchaîne directement sur l'Étape 3.

### Étape 2 — Restituer le diagnostic RAM/CPU
Présente à Clément, en français, concis :
- Health score et son interprétation (🟢 ≥85 / 🟠 60-84 / 🔴 <60)
- RAM libre/utilisée, CPU global (et signale si un load/usage anormalement haut
  suggère un process en particulier à investiguer — croiser avec `ps` si besoin)
- Espace disque libre en Go

### Étape 3 — Analyse disque (si pertinent ou demandé)
```bash
mo analyze --json
```
Donne l'arborescence des plus gros dossiers (avec âge `>6mo` etc.). Pour cibler
un point précis (ex: Downloads, Application Support) :
```bash
mo analyze --json ~/Downloads
```
Présente les 5-10 plus gros postes avec leur taille, en signalant ceux qui sont
clairement des caches/logs re-générables (🟢 sûr) vs des vrais fichiers perso
(🔴 à laisser, demander avant tout).

### Étape 4 — Preview du nettoyage (JAMAIS d'exécution directe)
```bash
mo clean --dry-run --debug
```
Liste ce qui serait nettoyé (cache app/navigateur, dev tools Xcode/npm/Homebrew,
logs système, trash) et l'espace récupérable, **sans rien supprimer**.

Pour des artefacts de projets dev oubliés (node_modules, target, .build) :
```bash
mo purge --dry-run
```

Pour des apps désinstallées dont il reste des résidus, ou des apps à
désinstaller proprement :
```bash
mo uninstall --dry-run
```

### Étape 5 — Présenter le choix à Clément
Résume par catégorie avec taille (ex: "Cache Chrome 760 Mo 🟢 sûr", "Google AI
Edge Eloquent 8,8 Go 🟡 à confirmer si utilisé"), puis **demande explicitement**
lesquelles exécuter réellement — via `AskUserQuestion` si plusieurs choix sont
proposés (comme pour un vrai nettoyage disque : multiSelect sur les catégories).

### Étape 6 — Exécuter SEULEMENT les catégories validées
```bash
mo clean --force        # si Clément valide le nettoyage cache/logs
mo purge                # si Clément valide les artefacts de projets
mo uninstall            # app par app, seulement celles cochées par Clément
```
Toute opération est loguée dans `~/Library/Logs/mole/operations.log`,
consultable avec `mo history`. Mentionne ce log si Clément veut vérifier après
coup ce qui a été fait.

### Étape 7 — Process gourmands en RAM (comme avant)
Si un process dépasse ~1,5 Go (Chrome, Slack, Spotify, un onglet lourd),
propose-le à la fermeture, jamais automatique :
> « Chrome bouffe 4,2 Go (28 onglets). Je le ferme ? (oui = je quitte proprement) »

Après OK uniquement :
```bash
osascript -e 'quit app "Google Chrome"'
```
Pour un PID orphelin après validation :
```bash
kill <PID>
```

## Notes de vérité (à dire si Clément demande pourquoi ça « revient »)
- macOS regère sa mémoire en continu : la mémoire « inactive » n'est PAS un bug,
  c'est du cache réutilisable qui se remplit à nouveau après une purge.
- La vraie cause d'un Mac qui rame = trop d'apps/onglets ouverts + un process
  glouton (CPU ou RAM), pas un manque de « nettoyage » magique.
- Un load average CPU anormalement haut (>10-15 sur un Mac 8 cœurs) pointe
  souvent vers de l'indexation Spotlight (`spotlightknowledged`) ou un process
  système qui tourne fort temporairement — ça se résorbe seul en général.
- L'espace disque qui fond vient très souvent de : caches d'apps IA locales
  (modèles on-device, plusieurs Go chacun), profils de navigateurs multiples
  (Chrome + Comet + autres), et le propre dossier de Claude Desktop
  (`~/Library/Application Support/Claude/`, vm_bundles + sessions passées) —
  à vérifier mais avec prudence, ne pas toucher aux données de session actives.

## Variante "ça rame souvent"
Si Clément veut un suivi automatique (ex : tous les matins), proposer une
scheduled task qui lance `mo status --json`, et lui envoie le health_score +
les 3 métriques (RAM/CPU/disque) + alerte si franchissement de seuil.

## Historique
- 17/05/2026 → v1 : script maison RAM only.
- 07/07/2026 → v2 : adoption de Mole (57k⭐) comme moteur, extension au CPU et
  au disque. Décision suite à une session où le script maison RAM-only ne
  couvrait ni le CPU (load avg 23) ni le disque (22 Go dispo, nettoyage manuel
  fastidieux via `du -sh`/`rm -rf`). Voir `memory/outils/2026-07-07-mole-mac-cleaner.md`.
