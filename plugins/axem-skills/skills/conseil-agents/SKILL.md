---
name: conseil-agents
description: >
  Conseil d'agents autonome et ultra-critique. Challenge SANS PITIÉ le fonctionnement / le livrable / l'approche en cours,
  trouve les billes à plus forte valeur, corrige en sous-agents, et rend un arbitrage. PIPELINE AUTOMATIQUE en une seule
  invocation : (0) triage en contexte, (1) deepsearch adversarial via le Workflow conseil-agents-recherche, (2) un CONSEIL
  à lentilles opposées qui DÉBAT, (3) une BOUCLE autonome de correction (worktree pour le code), (4) un askuser-question-batch
  final. Model+effort-tiering (Opus orchestre, Sonnet cherche/débat, Haiku fetch) + discipline de tokens pour l'invoquer souvent.
  À DÉCLENCHER quand Clément dit : "/conseil-agents", "challenge notre fonctionnement", "conseil d'agents", "débat d'agents",
  "critique sans pitié", "trouve les billes", "boucle autonome d'amélioration", "réunis un conseil", "challenge tout ça sans pitié".
argument-hint: "<le sujet / le livrable / le fonctionnement à challenger>"
user-invocable: true
---

# Conseil d'agents — pipeline critique auto-suffisant

Une seule invocation de `/conseil-agents` **enchaîne tout le pipeline** — Clément n'a JAMAIS à taper `/deepsearch`
ni `/askuser-question-batch` séparément, ils sont intégrés ci-dessous. Ton : lucide, direct, zéro complaisance.

## Le pipeline (obligatoire, dans cet ordre, sans redemander)

```
Phase 0  Triage en contexte          (toi, Opus, 0 agent)     → calibre régime + besoin_web, réutilise le vault
Phase 1  Deepsearch adversarial      (Workflow → agents Sonnet)→ démonte le sujet sous tous les angles
Phase 2  Le conseil débat            (lentilles Sonnet)        → panel qui s'oppose et vote
Phase 3  Boucle de correction        (fixers, conditionnel)    → applique l'actionnable, SKIP si rien à corriger
Phase 4  Arbitrage askuser-batch     (AskUserQuestion ≤4)      → Clément tranche le reste sur du concret
```

Tu déroules sans t'arrêter pour demander « je continue ? ». Seules pauses : Phase 4, et toute action irréversible
(push main, delete, envoi externe).

## Model + effort-tiering (résumé — détail dans `references/regimes-et-discipline.md`)

- **Orchestrateur = toi seul = `opus`.** Tu tranches et synthétises.
- **Workers de recherche / débat / fix = `sonnet`.** Effort `medium`, `high` seulement sur un angle dur.
- **Fetch pur / lookup vault = `haiku`, effort `low`.**
- **Règle d'or : jamais d'Opus en sous-agent** (sauf revue d'un fix critique).

## Discipline de tokens (résumé — 7 règles détaillées dans `references/regimes-et-discipline.md`)

Le levier n°1 n'est PAS le plafond de sortie : c'est **calibrer le nombre d'agents au sujet** (Phase 0). Ensuite :
sortie compacte par agent (`verdict ≤200 mots + reco + 3-5 sources`, références pas dumps, mais sans sur-compresser) ·
réutilise le vault avant de chercher · un seul tour par défaut · zéro chevauchement d'angles · skip ce qui ne
s'applique pas · le fan-out passe par le Workflow (rapports bruts hors de ton contexte).

## Les 3 régimes (résumé — table complète dans `references/regimes-et-discipline.md`)

**⚡ Éclair** (3-4 agents, 3 lentilles) — question cadrée / vault a déjà l'essentiel · **⚖️ Standard** (défaut ;
6-8 agents, 5 lentilles) — vraie question ouverte · **🏛️ Plénier** (10-15 agents, 5 lentilles + Contrarian round 2)
— décision structurante / « à fond ». En cas de doute → Standard, voire le régime au-dessus (le sous-dimensionnement
est le mode d'échec *silencieux*).

---

## Phase 0 — Triage & cadrage (TOI, Opus, en contexte — pas d'agent dédié)

Tu as déjà le contexte de la conversation ; un agent isolé ne l'aurait pas et coûterait un aller-retour pour rien.
Donc **tu tranches toi-même, en une passe**. Reformule la cible en 1 phrase (si `$ARGUMENTS` vide → le livrable/sujet
en cours), puis fixe :

- **régime** : eclair / standard / plenier
- **angles** : 3 à 8 (ou jusqu'à 15 en plénier) angles distincts et non-chevauchants, chacun avec une consigne courte
- **besoin_web** : le sujet a-t-il des faits à vérifier EN LIGNE (marché, concurrents, best practices, benchmark),
  OU est-ce un pur sujet interne (code, process, fichier local) ? ⚠️ **décisif pour la Phase 1.**
- **déjà_traité** : un verdict existe-t-il déjà dans `(mémoire interne)` ou le vault (`08-Idees-et-veille`) ? Si oui → pars de
  là, dis-le à Clément, allège. Rien ne coûte moins qu'une recherche évitée.
- **code_a_corriger** / **irreversible_en_jeu** : pour cadrer la Phase 3.

Seule exception qui justifie un agent ici : un scan mémoire/vault volumineux → 1 agent `haiku` de lookup pur.

---

## Phase 1 — Deepsearch adversarial (via le Workflow `conseil-agents-recherche`)

Lance le fan-out de recherche **par le Workflow sauvegardé** plutôt qu'à la main : les 6-15 rapports bruts restent
dans les variables du script (hors de ton contexte Opus), le harness gère la concurrence et le budget, et tu ne
récupères que les verdicts compacts structurés.

```
Workflow({ name: 'conseil-agents-recherche', args: {
  cible: "<phrase de cadrage>",
  besoin_web: true | false,
  angles: [ { key: "sceptique", prompt: "<consigne de l'angle>" }, … ]   // les angles du triage
}})
```

Le Workflow rend `{ findings: [{angle, verdict, reco, sources}], taux_exploitable }`. Chaque agent y tourne en
`model: sonnet` avec le format court imposé (schéma forcé). Couvre selon le régime, en piochant : (a) ce qui cloche
vraiment, (b) ce que fait le TOP du domaine, (c) tells & anti-patterns, (d) billes concrètes (`/find-skill` si utile),
(e) benchmark frais, (f) process qui fait converger, (g) angles contrariens & risques.

⚠️ **`besoin_web: false`** → le Workflow bascule ses agents en lecture de code / raisonnement, aucune recherche web.
**`besoin_web: true`** → routes d'accès de `/deepsearch` (connecteur navigateur → Bright Data → Apify ; skills dédiés
Reddit/X/YouTube). **N'invoque JAMAIS `/deepsearch` en entier** (doublonnerait ce pipeline).

*Fallback* : si le Workflow est indisponible, dispatch manuel d'agents `Explore`/`general-purpose` en `model: sonnet`,
un seul message, « ne lance AUCUN sous-agent » dans chaque prompt, même format court imposé.

---

## Phase 2 — Le conseil débat (lentilles Sonnet, un seul message)

Quand la Phase 1 est revenue, **vérifie d'abord la matière** : si `taux_exploitable` < ~0,5 (retours vides, échecs,
hors-sujet), relance UNE vague ciblée sur les angles manquants, puis **dégrade explicitement le score de confiance**
plutôt que de synthétiser du vide. Sinon, produis une **synthèse compacte** des findings (toi, Opus), puis convoque
le panel en **`model: sonnet`**, tous dans un seul message, chacun recevant la synthèse (pas les rapports bruts) :

- 🗡️ **Le Sceptique** — « qu'est-ce qui est faux/gadget/sur-vendu ? » ; refuse par défaut.
- 🎯 **Le Stratège** — « qu'est-ce qui a le plus d'impact business / conversion ? »
- 🎨 **Le Directeur artistique** — « qu'est-ce qui a du goût / du craft / une vraie idée ? »   *(Standard & Plénier)*
- 🔧 **Le Pragmatique** — « qu'est-ce qu'on livre VITE et bien, sans sur-ingénierie ? »
- 🔮 **Le Contrarian** — « et si tout le monde a tort ? l'option que personne n'ose. »   *(Standard & Plénier ; round 2 en Plénier)*

En Éclair : Sceptique + Stratège + Pragmatique seulement. Chaque conseiller rend : position, ce qu'il approuve/rejette,
**top 3 reco** — format court. Puis TOI (président, Opus) : synthétise le débat, **tranche les désaccords** (avec ton
hypothèse), produis la **liste ordonnée des améliorations à plus forte valeur** (garder / jeter / prioriser).

---

## Phase 3 — Boucle de correction (conditionnelle — SKIP si rien d'actionnable)

Pour les recos validées, actionnables maintenant :
- **Code** : fixers `model: sonnet` en **worktree** (un par lot cohérent), build vert obligatoire, push tôt. Puis un
  reviewer adversarial (`sonnet`, ou `opus` effort `high` si fix critique) qui essaie de casser chaque fix.
- **Process / contenu / skill** : applique directement (edit fichiers) + un reviewer.
- **Email** : si le livrable est un mail (relance, réponse, propal), invoque le skill `/email` (Skill tool) pour le
  rédiger — jamais de HTML rédigé à la main directement. `/email` garantit la voix Clément, l'anti-em-dash, le
  threading correct et la bonne PJ ; les rédiger à la main dans `/conseil-agents` fait sauter ces garde-fous.
- **Loop-until-dry** : relance un mini-round si un problème réel subsiste. Stop après **2 rounds sans nouveau problème**
  OU budget atteint. Loggue corrigé / restant.
- Autonomie sur les fixes évidents ; garde les vraies questions pour la Phase 4. **JAMAIS d'irréversible sans go.**

---

## Phase 4 — Arbitrage askuser-question-batch (OBLIGATOIRE, jamais sauté)

Termine TOUJOURS par un batch (skill `askuser-question-batch`, ou `AskUserQuestion` en lots de ≤4). Questions fermées,
chacune avec une option **« (Recommandé) »** sourcée sur le débat/le vault — jamais une pure supposition. Porte sur ce
que le conseil n'a pas pu trancher (direction, goût, priorités, budget) + les next steps. Si le débat a tout tranché →
1 seul lot orienté next steps.

---

## Livrable final (résumé en tête de réponse, avant le batch)

```
🏛️ CONSEIL D'AGENTS — <cible>
   Régime : <éclair/standard/plénier> · <n> agents
   Phase 1 : verdicts clés
   Débat : <désaccords tranchés>
   ✅ Corrigé en autonomie : <liste> (ou « rien à corriger »)
   ⏳ À arbitrer par toi : <renvoyé au batch>
```

## Garde-fous
- Pipeline auto-suffisant : une invocation → les 5 phases, sans faire taper les sous-skills à Clément.
- Triage en contexte (pas d'agent), fan-out via Workflow, model+effort-tiering, réutilise le vault — l'efficacité
  vient de ne PAS sur-dimensionner.
- Read-only en recherche, worktrees pour le code, push tôt, jamais d'irréversible sans go.
- Zéro complaisance : si le conseil conclut que la cible est à jeter, le dire franchement.
- **Piège observé (17/07/2026)** : sur une session longue où Clément enchaîne plusieurs sujets `/conseil-agents`
  d'affilée (ou interrompt avec une autre demande en cours de route), la Phase 4 se fait sauter silencieusement —
  on livre le résultat de la Phase 3 et on passe direct au sujet suivant sans le batch. Avant de considérer
  un `/conseil-agents` terminé, vérifie explicitement : *ai-je appelé `AskUserQuestion` en Phase 4 ?* Si non,
  ce n'est pas fini, même si un livrable concret (mail, doc, code) a déjà été produit.
- **Zéro tiret cadratin (—)** dans tout livrable texte produit par ce pipeline (mail, doc, synthèse) — même règle
  que `/email`. Scanner avant de livrer.
- Détail opérationnel : [`references/regimes-et-discipline.md`](references/regimes-et-discipline.md).
- Voir [[clement-collaboration-style]], [[askuser-batch-before-after-complex-tasks]], [[orchestrate-skill]] / [[design-fleet-skill]].
