---
name: upgrade-skill
description: Audite et améliore les skills Claude de Clément/Alexis — passe en revue toute la bibliothèque installée (vault + plugins) ou un skill précis, note chaque skill sur 3 dimensions (qualité de déclenchement/description, usage réel vs skills fantômes, sécurité/structure), et propose des corrections classées par priorité. Ne modifie jamais un fichier sans validation explicite. Inspiré du pattern GitHub "skill-doctor" (xigua-wang/skill-doctor, 321★) et du skill officiel skill-creator. Déclencheurs : "/upgrade-skill", "audit mes skills", "améliore ce skill", "ce skill est trop verbeux", "optimise ce skill", "check mes skills", "y'a des doublons dans mes skills ?".
version: 1.1
created: 2026-07-02
updated: 2026-07-02
status: active
---

# upgrade-skill — audit et amélioration de skills Claude

## Deux modes

### Mode batch (défaut, sans argument)
Audite **toute la bibliothèque** de skills accessibles : les skills du vault
(`06-Skills-Claude/*/SKILL.md`, éditables directement) ET les skills installés côté
plugin (visibles dans `<available_skills>`, lisibles mais **read-only** dans cette
session — cf. Phase 4).

### Mode ciblé (avec un nom de skill)
Ex. "/upgrade-skill ppt-design-check" — audite uniquement ce skill, en profondeur,
juste après sa création ou avant de le partager.

---

## Phase 1 — Inventaire

1. Liste tous les skills du vault : `Glob 06-Skills-Claude/**/SKILL.md`.
2. Liste tous les skills plugin visibles dans `<available_skills>` (nom, description
   affichée, `location`).
3. Croiser avec `(mémoire interne)` si une fiche existe déjà (ex.
   `2026-07-01-audit-tokens-mensuel.md`) pour ne pas repartir de zéro sur l'usage réel.
4. **Découpage en lots pour la lecture complète** : les 3 dimensions de la Phase 2
   nécessitent de lire le fichier SKILL.md **en entier** (la dimension sécurité ne peut
   pas être évaluée sur la description seule). Sur ~165 skills, lire tout d'un coup
   ferait exploser le contexte de l'orchestrateur — découper en lots de 15-20 skills et
   dispatcher **un sous-agent par lot** (`Agent`, type general-purpose), en parallèle
   (plusieurs lots dans le même message d'appels d'outils, comme les angles de
   `deepsearch`). Chaque sous-agent reçoit la liste de ses skills + leurs `location`,
   lit chaque fichier en entier, et retourne uniquement le scorecard compact (pas le
   contenu brut) — c'est ça qui évite de saturer le contexte principal.

---

## Phase 2 — Scorecard par skill (3 dimensions)

Pour chaque skill, noter 🟢/🟡/🔴 sur :

### A. Qualité de déclenchement & description
- Description > 1024 caractères → 🔴 (cassera l'install, cf. incident du 02/07/2026).
- Description > 600 caractères sans structure claire → 🟡 (verbeux, coûte du contexte
  à chaque chargement de la liste des skills).
- Triggers ambigus ou qui se chevauchent avec un autre skill (ex. deux skills qui
  matchent tous les deux "améliore ce document") → 🔴, à lister en paire.
- Nom du skill peu descriptif ou dupliqué → 🟡.

### B. Usage réel vs skill fantôme
- Skill jamais mentionné dans les 30 derniers jours de conversation/mémoire → 🟡
  (candidat à la désinstallation, pas une certitude).
- Deux skills qui font manifestement la même chose (doublon fonctionnel, ex. le cas
  déjà repéré `outreach-partenariat` en double le 01/07/2026) → 🔴.
- Skill jamais invoqué ET dont la fonction est déjà couverte par un skill plus général
  → 🟡, proposer une fusion ou une suppression.

### C. Sécurité & structure
- Secrets/API keys en dur dans le SKILL.md ou ses scripts → 🔴 (à corriger immédiatement).
- Scripts volumineux inline dans le SKILL.md au lieu d'un fichier externe référencé →
  🟡 (divulgation progressive à respecter : le SKILL.md doit rester un point d'entrée
  court, pas un pavé de 2000 lignes).
- Absence totale d'exemples de déclenchement ou de garde-fous ("ne pas utiliser pour...")
  → 🟡.

---

## Phase 3 — Rapport

Produire, dans cet ordre :

1. **Résumé en 3 lignes** : nombre de skills audités, répartition 🟢/🟡/🔴, les 3
   problèmes les plus urgents.
2. **Tableau classé par priorité** (🔴 d'abord) : skill | dimension concernée |
   problème | correction proposée.
3. **Doublons/fusions candidats** : paires de skills à regrouper, avec justification.
4. **Fichier livrable** : écrire le rapport complet dans
   `06-Skills-Claude/audits/<YYYY-MM-DD>-audit-skills.md`, et une fiche courte dans
   `(mémoire interne)` (frontmatter standard du vault).

Ne jamais improviser un score sans avoir réellement lu le fichier complet (via les
sous-agents en mode batch, directement en mode ciblé) — pas d'évaluation "à vue de nez"
sur la seule description.

---

## Phase 4 — Corriger (uniquement après validation explicite de Clément)

**Règle d'or : propose toujours, ne corrige jamais tout seul.** Présente la liste des
corrections, attends le go, puis :

### Skills du vault (`06-Skills-Claude/`) — corrigeables directement
`Read` puis `Edit` le fichier. C'est un fichier normal du vault, aucune contrainte
particulière.

### Skills plugin installés (visibles dans `<available_skills>`) — read-only dans cette session
Impossible d'éditer le fichier en place (cache en lecture seule). Procédure **groupée**,
pas skill par skill (sinon intraitable dès que plusieurs skills sont concernés) :
1. Pour CHAQUE skill plugin à corriger : copier son SKILL.md dans
   `outputs/upgrade-skill-fixes/<nom-skill>/SKILL.md`, appliquer les corrections
   validées, vérifier que `description` fait moins de 1024 caractères (`python3`/`wc -c`).
2. Zipper **chaque skill individuellement** en `<nom-skill>.skill` (le zip doit
   contenir un dossier `<nom-skill>/SKILL.md`, pas un fichier nu à la racine — un `.skill`
   = un skill, pas de bundle multi-skills).
3. Appeler `mcp__cowork__present_files` **une seule fois, avec la liste complète des
   `.skill` générés** — tous les boutons "Save skill" apparaissent ensemble, Clément les
   valide un par un à son rythme au lieu d'un aller-retour par skill.
4. Prévenir que ça peut créer un doublon plutôt que remplacer l'original si le skill fait
   partie d'un plugin groupé (cas vécu avec `deepsearch`, cf.
   `(mémoire interne)`).

---

## Complément externe (à mentionner, pas à installer automatiquement)
Pour un audit plus profond au niveau OS (précédence entre scopes projet/global/système,
conflits multi-agents Claude/Cursor/Codex/Copilot), l'outil externe le plus mature repéré
sur GitHub est **`xigua-wang/skill-doctor`** (321★, MIT, actif) — CLI+UI locale à lancer
par Clément lui-même sur son Mac (`npx @xiguawang/skill-doctor`), hors du cadre Cowork.
À proposer seulement si l'audit interne révèle des conflits de précédence complexes que
`upgrade-skill` ne peut pas résoudre depuis le sandbox Cowork.

---

## Changelog
- **v1.1 (2026-07-02)** : corrigé 3 trous repérés par Clément après relecture — (1) la
  dimension sécurité ne peut pas s'évaluer sur la description seule, donc lecture du
  fichier complet obligatoire même en batch ; (2) ajout du dispatch en sous-agents
  parallèles (lots de 15-20 skills) pour ne pas saturer le contexte sur ~165 skills ;
  (3) Phase 4 regroupée : tous les `.skill` de correction générés et présentés en un
  seul appel `present_files`, plus un aller-retour par skill.
- v1.0 : version initiale.

## Sources (recherche du 02/07/2026, étoiles vérifiées via api.github.com)
- `xigua-wang/skill-doctor` — 321★, MIT — [github.com/xigua-wang/skill-doctor](https://github.com/xigua-wang/skill-doctor)
- `naoralkobi/skill-doctor` — audit skills+CLAUDE.md+subagents+permissions+hooks
- `ncoevoet/claude-markdown-health-check` — 34★ — scan skills/commands/hooks pour refs mortes, triggers faibles, token bloat
- `marian2js/skill-doctor` — "help your agents create better skills"
- Skill officiel Anthropic déjà installé : `skill-creator` (création/édition/evals/optimisation de description)
