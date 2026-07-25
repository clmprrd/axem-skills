---
name: conseil-agents
description: >
  Conseil d'agents autonome et ultra-critique. Challenge SANS PITIÉ le fonctionnement / le livrable / l'approche en cours,
  trouve les billes à plus forte valeur, corrige en sous-agents, et rend un arbitrage. PIPELINE AUTOMATIQUE en une seule
  invocation : (0) triage en contexte, (0.5) BATCH AMONT askuser qui cadre le scope + l'intensité AVANT toute recherche,
  (1) deepsearch 2 axes (angles + terrain Reddit/X) via le Workflow conseil-agents-recherche [+ /find-skill si besoin
  d'outil], (1.5) triangulation terrain vs institutionnel + transposabilité FR, (2) un CONSEIL à lentilles opposées qui
  DÉBAT (+ steelman/pre-mortem), (3) une BOUCLE de correction, (4) un askuser-question-batch final avec options
  recommandées, (5) persistance du verdict au vault+mémoire.
  À DÉCLENCHER quand Clément dit : "/conseil-agents", "challenge notre fonctionnement", "conseil d'agents", "débat d'agents",
  "critique sans pitié", "trouve les billes", "boucle autonome d'amélioration", "réunis un conseil", "challenge tout ça sans pitié".
argument-hint: "<le sujet / le livrable / le fonctionnement à challenger>"
user-invocable: true
---

# Conseil d'agents — pipeline critique auto-suffisant

Une invocation enchaîne tout : Clément n'a jamais à taper `/deepsearch`, `/find-skill` ni `/askuser-question-batch`.
Ton : lucide, direct, zéro complaisance.

```
Phase 0   Triage en contexte      (toi, Opus, 0 agent)   → régime + besoin_web + cadrage terrain, réutilise le vault
Phase 0.5 Cadrage askuser-batch   (AskUserQuestion 1→4)  → ★ BATCH AMONT : cadre le scope + fait choisir l'INTENSITÉ
Phase 1   Deepsearch 2 axes       (Workflow → Sonnet)    → ANGLES adversariaux + TERRAIN (Reddit/X vécu réel)
   ↳ /find-skill si un besoin d'outil émerge
Phase 1.5 Triangulation           (Workflow → 1 Sonnet)  → terrain vs institutionnel + transposabilité FR + anti-hallu
Phase 2   Le conseil débat        (lentilles Sonnet)     → postures OPPOSÉES imposées + steelman → président tranche
Phase 3   Boucle de correction    (fixers + reviewer)    → applique l'actionnable · plancher : au moins 1 check
Phase 4   Arbitrage askuser-batch (AskUserQuestion ≤4)   → ★ SORTIE GARANTIE : options « (Recommandé) »
Phase 5   Boucle fermée           (vault + mémoire)      → persiste le verdict pour le prochain conseil
```

**Aucune phase ne se saute : le régime est un VARIATEUR d'intensité, pas un interrupteur.** Tu déroules sans demander
« je continue ? ». Seules pauses : **Phase 0.5**, **Phase 4**, et toute action irréversible (push, delete, envoi externe,
install d'un skill tiers).

**Les DEUX batches sont la colonne vertébrale** : 0.5 cadre AVANT de dépenser, 4 fait décider APRÈS le débat. Les deux
avec l'option **« (Recommandé) » en premier**. C'est ce qui évite à Clément de taper.

**Tiering** : orchestrateur = toi = `opus` · workers recherche/débat/fix = `sonnet` (effort `high` sur la triangulation
et les angles durs) · `haiku` réservé au fetch/lookup pur lancé à la main (le Workflow est 100 % sonnet). **Jamais
d'Opus en sous-agent.** Détail + discipline de tokens + table des régimes : [`references/regimes-et-discipline.md`](references/regimes-et-discipline.md).

**Régimes** : ⚡ Éclair (3-4 agents, 3 lentilles) · ⚖️ Standard (défaut ; 6-8 agents, 5 lentilles) · 🏛️ Plénier
(10-15 agents, 5 lentilles + steelman). Dans le doute, prends le régime au-dessus : le sous-dimensionnement est le
mode d'échec *silencieux*.

---

## Phase 0 — Triage & cadrage (toi, en contexte, pas d'agent)

Tu as déjà le contexte ; un agent isolé coûterait un aller-retour pour rien. Reformule la cible en 1 phrase, puis fixe :

- **régime** · **angles** : 3 à 15 selon régime, distincts et non-chevauchants, une consigne courte chacun
- **besoin_web** : faits à vérifier en ligne, ou pur sujet interne (code/process/fichier) ? ⚠️ `true` **arme
  automatiquement le terrain + la triangulation**
- **cadrage terrain** (si `besoin_web`) : `subreddits` (niches expertes, pas les évidents), `comptes_x`, `requetes`
  (formulations « vécu réel »). Un bon cadrage vaut mieux qu'un collecteur à l'aveugle.
- **déjà_traité** : un verdict existe-t-il dans `(mémoire interne)` ou `08-Idees-et-veille` ? Si oui, pars de là et allège.
- **code_a_corriger** / **irreversible_en_jeu** : pour cadrer la Phase 3.

## Phase 0.5 — Batch AMONT (★ avant toute recherche)

Règle globale `CLAUDE.md` : sur tout sujet complexe, les questions passent **en premier**, avant le moindre agent ou
web search. Une recherche mal orientée coûte bien plus cher qu'une question posée.

Questions fermées, option **« (Recommandé) » en premier**, sourcée sur le triage/le vault. On cadre : le **scope réel**,
le **critère de succès**, les **contraintes non négociables** connues de lui seul, et le **régime** si tu hésites.

⚡ **Question obligatoire : l'intensité.** Une question porte TOUJOURS sur « on fait tourner à fond ou pas ? », avec
**ta recommandation déjà pré-évaluée** en option 1. Clément arbitre le curseur, tu ne le décides pas seul. Objectif :
jamais d'overkill, jamais de main légère.

**Plancher** : ⚡ Éclair → 1 question · ⚖️ Standard → 2-3 · 🏛️ Plénier → 4. Jamais zéro. Si Clément a déjà tout cadré
ET que le vault a la réponse, une seule question de confirmation.

⚠️ Ne jamais enchaîner deux batches d'affilée : si l'amont a tout tranché, la Phase 4 porte alors sur les décisions
issues du débat et les next steps.

## Phase 1 — Deepsearch 2 axes (Workflow `conseil-agents-recherche`)

Passe **par le Workflow** : les rapports bruts restent hors de ton contexte, le harness gère concurrence et budget.

- **Axe ANGLES** — un Sonnet par angle adversarial : ce qui cloche, ce que fait le TOP, anti-patterns, benchmark, risques.
- **Axe TERRAIN** — collecteurs Reddit/X du **vécu réel** (opinions brutes, frustrations, contre-narratifs que les blogs
  SEO ne disent jamais). Armé dès que `besoin_web: true`, calibré : **Éclair 1 · Standard 3 · Plénier 6**.

```
Workflow({ name: 'conseil-agents-recherche', args: {
  cible, besoin_web, regime,
  angles: [ { key: "sceptique", prompt: "<consigne>" }, … ],
  terrain: { subreddits: [...], comptes_x: [...], requetes: [...] }
}})
```

Rend `{ findings, terrain, triangulation, taux_exploitable, taux_rendus, terrain_vide }`.

⚠️ `besoin_web: false` → terrain et triangulation désactivés, les angles lisent le code et raisonnent.
**N'invoque JAMAIS `/deepsearch` en entier** (doublonnerait ce pipeline).

🔒 **Garde-fou coût** et 🔧 **hook `/find-skill`** (install de code tiers sous conditions strictes) : règles complètes
dans [`references/gardes-fous-et-outils.md`](references/gardes-fous-et-outils.md). ⚠️ Ce sont des **consignes de prompt,
pas des blocages techniques** (audit 24/07).

*Fallback* : Workflow indisponible → agents `general-purpose` en `sonnet`, un seul message, « ne lance AUCUN sous-agent »
+ le garde-fou coût dans chaque prompt.

## Phase 1.5 — Triangulation (responsable qualité)

**La recherche nourrit tout, donc on sécurise la recherche avant d'en débattre.** 1 agent Sonnet effort `high` challenge
chaque affirmation terrain contre l'institutionnel et rend : `confiance_globale` (X/10), `verdicts` (corroboré ✅ /
partiel 🟡 / contredit 🔴 / non_verifiable ⚪), `contradictions`, `fraicheur_biais`, et **`transposabilite_fr`** (les
preuves, souvent US, tiennent-elles sur le marché FR ?). Elle chasse aussi les **hallucinations de tes propres agents**
(chiffres trop précis, citations mal appliquées).

**Plancher** : gatée sur l'intention (`besoin_web`), pas sur le succès du terrain. Si tout le terrain échoue, elle tourne
**en mode dégradé** (confiance plafonnée à 5/10, audit des angles entre eux) au lieu de disparaître pile quand la matière
est la plus fragile.

## Phase 2 — Le conseil débat (un seul message)

Vérifie d'abord la matière : `taux_exploitable` < ~0,5 → relance UNE vague ciblée, puis **dégrade explicitement la
confiance** plutôt que de synthétiser du vide. Sinon produis une **synthèse compacte pondérée par la triangulation**
(un take 🔴 ou ⚪ ne pèse pas comme un ✅) et convoque le panel en `sonnet`, chacun recevant la synthèse, pas les bruts :

- 🗡️ **Sceptique** — qu'est-ce qui est faux/gadget/sur-vendu ? refuse par défaut
- 🎯 **Stratège** — qu'est-ce qui a le plus d'impact business ?
- 🎨 **Directeur artistique** — qu'est-ce qui a du goût, du craft ?   *(Standard & Plénier)*
- 🔧 **Pragmatique** — qu'est-ce qu'on livre vite et bien, sans sur-ingénierie ?
- 🔮 **Contrarian** — et si tout le monde a tort ?   *(Standard & Plénier)*

⚠️ **DIVERGENCE IMPOSÉE — le fix le plus important de cette phase.** Des personas du même modèle **convergent** au lieu
de s'opposer : un panel qui s'accorde poliment ne vaut rien. Donne à chaque lentille une **contrainte de posture opposée
et non négociable** (« tu dois défendre que X ne vaut pas son coût », « tu n'as le droit à AUCUN ajout, seulement des
suppressions », « tu ne parles que de ce qui est livrable ce soir »). Sans ça, le débat est du théâtre.

En Éclair : Sceptique + Stratège + Pragmatique. Chacun rend : position, ce qu'il approuve/rejette, top 3 reco.
Si la triangulation a signalé un doute de transposabilité FR, chaque lentille en tient compte.

**🥊 Steelman + pre-mortem (Plénier)** : un dernier agent construit le **meilleur argument ADVERSE** à la reco qui se
dégage (pas un homme de paille) et un **pre-mortem** (« on est dans 6 mois, ça a échoué : pourquoi ? »). Le président
doit répondre aux deux avant de trancher.

Puis toi (président) : synthétise, **tranche les désaccords**, réponds au steelman, produis la liste ordonnée des
améliorations à plus forte valeur (garder / jeter / prioriser).

## Phase 3 — Boucle de correction (plancher : au moins 1 check)

S'il n'y a rien de lourd, tu fais quand même un check rapide et tu le dis en une ligne. Sinon :
- **Code** : fixers `sonnet` en **worktree**, build vert, puis un **reviewer adversarial** qui essaie de casser chaque fix.
- **Process / contenu / skill** : applique directement + un reviewer.
- **Email** : invoque le skill `/email`, jamais de rédaction à la main (sinon tu sautes voix, anti-em-dash, threading, PJ).
- **Outil manquant** : `/find-skill` plutôt que réinventer, mêmes garde-fous qu'en Phase 1.
- **Loop-until-dry** : stop après 2 rounds sans nouveau problème, ou budget atteint. Loggue corrigé / restant.
- Autonomie sur les fixes évidents, vraies questions gardées pour la Phase 4. **Jamais d'irréversible sans go.**

## Phase 4 — Batch AVAL (★ sortie garantie, jamais sautée)

**C'est LE but du skill** : après le débat, ça finit **toujours** par un batch d'options **« (Recommandé) »**. Questions
fermées, chaque recommandation **sourcée sur le débat / la triangulation / le vault**, jamais une supposition, l'option
recommandée en premier. Porte sur ce que le conseil n'a pas tranché + les next steps.

⚠️ **Anti-rubber-stamping** : le « (Recommandé) » est une aide à la décision, pas un pilote automatique. Les options
concurrentes doivent rester de vraies options défendues, pas des repoussoirs. Si le conseil est réellement partagé,
dis-le au lieu de fabriquer une recommandation de confort.

## Phase 5 — Boucle fermée (après le batch, une fois Clément décidé)

Écris la décision pour qu'elle soit **réutilisée** au lieu d'être re-cherchée : note courte dans `08-Idees-et-veille/`
(cible, verdict, certain/contesté, décision, sources) que la Phase 0 relira en `déjà_traité` ; plus un fichier `(mémoire interne)`
+ ligne d'index si la décision est stable et réutilisable. Vault git-tracké → **ne pas committer sans go**.

---

## Livrable final (avant le batch)

```
🏛️ CONSEIL D'AGENTS — <cible>
   Régime : <…> · <n> agents · confiance triangulation <X/10>
   Phase 1 : verdicts clés · terrain <complet / partiel (raison)>
   Débat : <désaccords tranchés> · steelman : <réponse>
   ✅ Corrigé : <liste> · 🔧 skills installés : <nom/score ou aucun>
   ⏳ À arbitrer : <renvoyé au batch>
   📊 Coût : <n agents · ~k tokens> · dégradations : <ce qui a été partiel, ou aucune>
```

## Garde-fous

- Pipeline auto-suffisant : une invocation → toutes les phases, sans faire taper les sous-skills à Clément.
- Read-only en recherche, worktrees pour le code, **jamais d'irréversible sans go**.
- Zéro complaisance : si le conseil conclut que la cible est à jeter, le dire franchement.
- **Zéro tiret cadratin** dans tout livrable texte produit par ce pipeline. Scanner avant de livrer.
- **Vérifie les DEUX batches avant de clore** : *ai-je fait la Phase 0.5 avant de dépenser ?* et *ai-je appelé
  `AskUserQuestion` en Phase 4 ?* La Phase 4 a déjà sauté silencieusement une fois (17/07) sur une session longue :
  un livrable produit ne veut pas dire conseil terminé. Détail et signal d'escalade :
  [`references/gardes-fous-et-outils.md`](references/gardes-fous-et-outils.md).
- Historique des audits et décisions de design : `08-Idees-et-veille/2026-07-24-audit-conseil-agents-par-lui-meme.md`.
- Voir [[clement-collaboration-style]], [[askuser-batch-before-after-complex-tasks]], [[conseil-agents-skill]].
