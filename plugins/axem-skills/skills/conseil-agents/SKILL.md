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
          ↳ SAUTÉE en régime 🔍 Recherche : une question de fait n'a rien à arbitrer
Phase 3   Boucle de correction    (fixers + reviewer)    → applique l'actionnable · plancher : au moins 1 check
Phase 4   Arbitrage askuser-batch (AskUserQuestion ≤4)   → ★ SORTIE GARANTIE : options « (Recommandé) »
Phase 5   Boucle fermée           (vault + mémoire)      → persiste le verdict pour le prochain conseil
```

**Le régime est un VARIATEUR d'intensité, pas un interrupteur.** Une seule exception, explicite : le régime
🔍 Recherche saute les Phases 2 et 3, parce qu'une question de fait n'a rien à arbitrer. Partout ailleurs, on
allège, on ne supprime pas. Tu déroules sans demander
« je continue ? ». Seules pauses : **Phase 0.5**, **Phase 4**, et toute action irréversible (push, delete, envoi externe,
install d'un skill tiers).

**Les DEUX batches sont la colonne vertébrale** : 0.5 cadre AVANT de dépenser, 4 fait décider APRÈS le débat. Les deux
avec l'option **« (Recommandé) » en premier**. C'est ce qui évite à Clément de taper.

**Tiering** : orchestrateur = toi = `opus` · workers recherche/débat/fix = `sonnet` (effort `high` sur la triangulation
et les angles durs) · `haiku` réservé au fetch/lookup pur lancé à la main (le Workflow est 100 % sonnet). **Jamais
d'Opus en sous-agent.** Détail + discipline de tokens + table des régimes : [`references/regimes-et-discipline.md`](references/regimes-et-discipline.md).

**Régimes** : 🔍 Recherche (collecte seule, aucun débat) · ⚡ Éclair (3-4 agents, 3 lentilles) · ⚖️ Standard
(défaut ; 6-8 agents, 5 lentilles) · 🏛️ Plénier (10-15 agents, 5 lentilles + steelman). Dans le doute, prends le
régime au-dessus : le sous-dimensionnement est le mode d'échec *silencieux*.

⏱️ **Le vrai plafond est l'attention de Clément, pas l'argent.** Tout le dispositif est gratuit et open source,
c'est une contrainte non négociable et elle est tenue : aucune route payante, aucun crédit consommé. Ce qui ne se
compresse pas, en revanche, ce sont les **15 à 20 minutes** qu'il passe à lire un plénier et à arbitrer ses deux
batches. Plus d'agents produit plus de texte à vérifier, pas moins de minutes, et environ 80 % de la valeur d'une
analyse vient de ses premiers 20 %. Réserve donc le plénier aux décisions structurantes ; pour tout le reste,
régime Éclair, régime Recherche, ou simplement les règles déjà écrites en mémoire. Un plénier sur une question
qui n'en méritait pas coûte à Clément la seule ressource qu'il ne peut pas racheter.

🔍 **Régime Recherche, celui qui absorbe `/deepsearch`.** Clément ne doit plus avoir à choisir sa commande : quand
sa demande est **une question de fait** (« cherche », « qui parle de », « qu'est-ce qui se dit sur », « trouve les
meilleurs », « résume cette vidéo », « monitore »), il n'y a **rien à arbitrer**, donc pas de conseil à convoquer.
Tu déroules Phase 1 et 1.5, tu rends la synthèse, **et tu sautes le débat des Phases 2 et 3**. Le batch amont tombe
à une seule question, et le batch aval porte sur ce qu'on fait de ce qui a été trouvé.

Le signal qui distingue les deux : une demande de recherche appelle **un état des lieux**, une demande de conseil
appelle **une décision**. « Qu'est-ce qui se dit sur X » est du premier type ; « est-ce qu'on devrait faire X » est
du second. En cas d'ambiguïté réelle, la question du batch amont porte là-dessus, en une ligne.

⚠️ `/deepsearch` reste invocable, **uniquement pour tester la collecte isolément** quand quelque chose cloche. Ce
n'est plus la porte d'entrée : c'est le banc d'essai. Sans lui, une dérive de la collecte passerait des mois sans
être vue, faute de pouvoir l'exercer seule.

---

## Avant d'écrire : qui d'autre travaille là-dessus ?

Jusqu'à douze sessions tournent en parallèle. Le 22/08, deux d'entre elles ont produit quatre offres
contradictoires pour le même client, avec un écart de 4 000 à 25 000 euros sur le premier palier.

**Un appel au démarrage** : `list_sessions(limit: 10)` montre les titres de ce qui tourne.
**Avant d'écrire sur un dossier client nommé** : `search_session_transcripts(query: "<client>")`, et ne
retiens que les sessions actives depuis **moins de deux heures**, seul filtre qui sépare une vraie collision
d'une coïncidence de vocabulaire. Puis `SendMessage` à celle qui est concernée, avant d'écrire.

Procédure complète, usages et garde-fous : skill [`sessions`](../sessions/SKILL.md).

## Phase 0 — Triage & cadrage (toi, en contexte, pas d'agent)

**Commence par classer la décision, avant tout le reste.** C'est le filtre qui décide de ce que le conseil a le
droit de faire, et il passe avant le régime.

- **Type 2, porte à double battant** : réversible, fréquente, mesurable. Le conseil peut trancher et exécuter.
  Exemples : formulation d'un post, ordre de priorité d'une semaine, choix d'un angle de contenu.
- **Type 1, porte à sens unique** : le conseil produit **un briefing et une recommandation, jamais une
  décision**. Marqueurs, alignés mot pour mot sur le régime du 22/08 : **un montant, un prix, un engagement
  contractuel ou une rupture de relation actée**. Rien d'autre.

⚠️ **Ne pas élargir cette liste.** Y ajouter « un envoi qui engage l'image » ou « tout ce qui touche à un
client nommé » réintroduirait en silence la file de validation humaine que Clément a explicitement abolie le
22/08, dans un skill censé l'accélérer. La frontière est l'argent, elle l'a toujours été.

⚠️ Sur une décision de type 1, la sortie doit **forcer la revérification de la source primaire au moment de
l'action**, pas au moment de l'analyse. Un conseil rendu ce matin repose sur un état de ce matin. C'est la
seule parade au mode d'échec réel documenté : les dégâts passés viennent tous d'un état périmé pris pour vrai,
jamais d'un raisonnement fautif. Aucune quantité d'agents ne referme ce trou.

Tu as déjà le contexte ; un agent isolé coûterait un aller-retour pour rien. Reformule la cible en 1 phrase, puis fixe :

- **enjeu, en euros, AVANT le régime.** Combien cette décision met-elle en jeu : chiffre d'affaires
  possible, coût évité, montant risqué ? Un ordre de grandeur suffit. **C'est lui qui fixe le régime**, pas
  l'intuition : sous 500 euros → ⚡ Éclair, de 500 à 5 000 → ⚖️ Standard, au-delà de 5 000 → 🏛️ Plénier.
  Un conseil plénier sur une décision à 200 euros est une perte sèche ; le même sur un dossier à 25 000
  euros est le meilleur investissement de la journée. Écris l'enjeu dans la note de Phase 5, il alimente
  le registre.
  ⚠️ Si tu ne peux pas chiffrer l'enjeu, dis-le et prends Standard. Un enjeu inconnu n'est pas un enjeu nul.
- **régime** · **angles** : 3 à 15 selon régime, distincts et non-chevauchants, une consigne courte chacun
- **besoin_web** : faits à vérifier en ligne, ou pur sujet interne (code/process/fichier) ? ⚠️ `true` **arme
  automatiquement le terrain + la triangulation**
- **cadrage terrain** (si `besoin_web`) : **ne devine plus, mesure**. Lance
  `python3 ~/.claude/scrapling/cadrage_terrain.py "<le sujet>"`, qui rend les communautés Reddit réelles
  triées par pertinence, les fils Hacker News les plus commentés, les projets actifs et des formulations de
  requête tirées du vocabulaire du terrain. C'était le maillon le plus faible du dispositif : un cadrage
  deviné à côté fait revenir le terrain vide, et ce vide se lit à tort comme un silence du sujet.
  ⚠️ La liste des subreddits est un point de départ, pas un inventaire : la recherche se fait par début de
  nom, donc une communauté comme `r/webscraping` échappe au préfixe « scrapi ». Complète à la main avec les
  évidences que tu connais.
- **déjà_traité** : lis **`08-Idees-et-veille/_INDEX-CONSEILS.md`**, et lui seul. Il compile les verdicts de
  tous les conseils passés en un fichier, avec l'âge de chacun. Sans lui tu ne relirais rien : il y a plus de
  trente notes de cinquante lignes, et c'est exactement pour ça que les mêmes sujets se re-cherchaient. Si le
  sujet y figure, pars du verdict et allège le régime. **Respecte les marqueurs de péremption** : 🔴 signifie
  que la conclusion ne vaut plus, seulement la question. Régénère l'index avant de le lire :
  `python3 ~/.claude/scrapling/index_conseils.py`

- **ce qui a marché** : si **`08-Idees-et-veille/_RESULTATS-CONSEILS.md`** contient au moins un verdict
  renseigné, lis-le ; sinon passe, il n'a rien à t'apprendre. C'est le registre de ce que les conseils passés
  ont réellement donné. C'est le **seul signal extérieur** du dispositif : sans lui, un conseil
  qui se juge lui-même devient plus confiant sans devenir plus juste. Deux lectures à en tirer. Si un conseil
  proche est marqué `rate`, ne répète pas sa méthode. Si le motif `non-suivi` revient, le conseil recommande des
  choses que Clément ne fera jamais, et c'est un défaut du conseil, pas de Clément.
  Régénère-le d'abord : `python3 ~/.claude/scrapling/resultats_conseils.py`
- **outils_déjà_repérés** : lis **`08-Idees-et-veille/_INDEX-PROJETS-OSS.md`**, la sortie de la veille GitHub
  hebdomadaire. Vingt projets au plus, avec pour chacun ce qu'il fait, son nombre d'étoiles, la date de son
  dernier commit et où on en est. **Si l'un d'eux répond directement au sujet, cite-le nommément dans le
  livrable**, avec ce qu'il apporterait. Sinon n'en parle pas : une mention forcée à chaque conseil est du
  remplissage, et c'est ce qui fait qu'on cesse de lire un fichier. Régénère avant de lire :
  `python3 ~/.claude/scrapling/index_projets_oss.py`
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

🧪 **Choix technique ? On teste, on ne débat pas.** Dès que la question devient « quelle méthode, quel
outil, quelle route », invoque **`/test-and-learn`** plutôt que de faire trancher Clément sur des arguments.
Il l'a posé en règle le 22/08 : « je veux juste que tu testes sur le terrain, je suis plus pratique que
théorie ». Le skill liste tous les candidats, les exécute réellement, et rend un tableau de résultats mesurés.
Le batch qui suit porte alors sur la décision business, jamais sur la technique. Journal des tests déjà
tranchés, à lire avant d'en relancer un : `08-Idees-et-veille/_TESTS-TERRAIN.md`.

🎯 **Question obligatoire quand la sortie est un ARTEFACT : la barre à atteindre.** Si ce conseil doit
déboucher sur quelque chose de produit et de montrable (une page, un deck, un visuel, un prototype, une refonte),
une question porte sur **la référence réelle à battre**, jamais sur un niveau d'exigence en adjectif. « Du propre »,
« du niveau pro », « du AAA » ne sont pas des barres : rien ne peut les déclarer atteintes, donc la Phase 3 s'arrête
au hasard. Une barre utile nomme un objet qui existe : la charte du client, le site du concurrent, le post qui a
cartonné, la photo de référence. Quand plusieurs références sont plausibles, **elles sont les options de la question**.

Méthode complète, gabarits et pièges : [`/gauntlet-loop`](../gauntlet-loop/SKILL.md).

⚠️ **Le piège que cette question évite.** Une boucle de correction optimise *à la perfection* vers la cible
qu'on lui a donnée. Sans référence validée en amont, elle produit un objet superbe et hors sujet, après des heures
de calcul. Le mode d'échec n'est pas le raisonnement, c'est la prémisse. Cette question est ce qui la valide.

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

🧰 **Collecte terrain** : X, Reddit, GitHub et YouTube passent par `collect.py`, un module gratuit dont chaque
route a été testée en réel. Le Workflow injecte déjà son mode d'emploi dans les prompts terrain. Deux choses à
savoir au moment du cadrage Phase 0 : une collecte X de 6 requêtes prend une demi-minute (rate-limit), et
**cadrer un subreddit précis est obligatoire** sinon le repli Reddit ne peut pas jouer. Routes, fragilités et
liste de ce qui est mort : [`references/collecte.md`](references/collecte.md).

⚠️ **Une collecte vide n'est pas un silence du terrain.** `collect.py` rend `fiable: false` quand une route est
cassée. Un rapport terrain qui conclut « personne n'en parle » sans avoir vérifié ce drapeau est un faux verdict,
exactement le mode d'échec qui a déjà produit des diagnostics erronés.

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

🧠 **Une MÉTHODE de raisonnement par lentille, pas seulement une posture.** C'est le correctif le mieux
étayé contre la convergence, et il vient du conseil du 22/08 sur l'idée d'Alexis. Changer l'étiquette d'un
agent ne change pas son raisonnement : mesuré sur 162 personas et 2 410 questions, l'effet est nul. Ce qui
casse vraiment le raisonnement en ornière, c'est d'imposer des **procédures de pensée différentes** :

- 🗡️ **Sceptique** : raisonne par **réfutation**. Cherche le fait unique qui invaliderait la reco, et dis ce
  qu'il faudrait observer pour te faire changer d'avis.
- 🎯 **Stratège** : raisonne par **chiffrage**. Aucune affirmation sans un ordre de grandeur en euros ou en
  heures. Ce qui ne se chiffre pas, tu le déclares hors sujet.
- 🎨 **Directeur artistique** : raisonne par **comparaison**. Confronte à ce qui existe de meilleur ailleurs,
  jamais dans l'absolu.
- 🔧 **Pragmatique** : raisonne par **décomposition**. Découpe en étapes livrables et signale la première qui
  ne tient pas dans une session.
- 🔮 **Contrarian** : raisonne par **inversion**. Pars de la conclusion opposée et construis ce qui la rendrait
  vraie.

⚠️ **DIVERGENCE IMPOSÉE — le fix le plus important de cette phase.** Des personas du même modèle **convergent** au lieu
de s'opposer : un panel qui s'accorde poliment ne vaut rien. Donne à chaque lentille une **contrainte de posture opposée
et non négociable** (« tu dois défendre que X ne vaut pas son coût », « tu n'as le droit à AUCUN ajout, seulement des
suppressions », « tu ne parles que de ce qui est livrable ce soir »). Sans ça, le débat est du théâtre.

En Éclair : Sceptique + Stratège + Pragmatique. Chacun rend : position, ce qu'il approuve/rejette, top 3 reco.
Si la triangulation a signalé un doute de transposabilité FR, chaque lentille en tient compte.

**🥊 Steelman + pre-mortem (Plénier)** : un dernier agent construit le **meilleur argument ADVERSE** à la reco qui se
dégage (pas un homme de paille) et un **pre-mortem** (« on est dans 6 mois, ça a échoué : pourquoi ? »). Le président
doit répondre aux deux avant de trancher.

**📐 Dis si le débat a changé ta conclusion**, en une ligne du livrable : `débat_a_changé : oui / non / nuancé`.

C'est ce qui reste d'une consigne plus longue, retirée le 23/08 parce qu'elle demandait d'écrire sa position
avant de lire, sans que rien ne puisse le vérifier. Une consigne qu'aucun capteur ne mesure ne s'améliore
jamais : elle se contente d'exister.

Cette ligne-ci, elle, se mesure. **Si elle vaut `non` trois conseils de suite, le panel ne sert à rien et
c'est le débat qu'il faut réformer, pas le sujet.** C'est une information bien plus utile qu'un verdict de
plus, et elle coûte cinq mots.

🔨 **Contrainte d'exécution, règle dure.** Toute recommandation doit tenir **en une session de travail**, ou
être découpée en un premier pas réalisable immédiatement. C'est mesuré, pas théorique : sur les conseils passés,
les recommandations qui commencent par « d'abord construire le socle » n'ont presque jamais été exécutées.
PostForge s'est arrêté au scaffold, le verrou de fichier LinkedIn n'était toujours pas codé trois semaines après
avoir été posé en prérequis, et le vault a recassé après chacun des trois conseils sur sa fiabilité. Un plan juste
que personne n'exécute vaut moins qu'un premier pas imparfait qui part.

Corollaire : **quand la recommandation est technique et réversible, ne la recommande pas, fais-la** dans la foulée
du conseil, en Phase 3. Le facteur limitant du dispositif n'est pas la qualité des conseils, c'est leur exécution.

🔴 **Durci le 27/08/2026 : une recommandation dont le premier pas est un prérequis est REFUSÉE, pas nuancée.**

La contrainte ci-dessus était trop molle. Elle demandait que la recommandation « tienne en une session »,
ce qui laissait passer « d'abord le socle, ensuite le reste » en le découpant sur le papier. Trois cas
mesurés disent que ce découpage ne survit jamais au contact : le verrou de fichier LinkedIn, posé en
prérequis, n'était pas codé trois semaines plus tard et trois sessions ont tourné en parallèle sur le
même compte le 17/08, exactement le risque annoncé ; les deux fichiers `PROPOSITION-*` du 10/07 étaient
des socles à appliquer plus tard, ils sont morts dans `patches/` et n'ont été ouverts que le 27/08, l'un
d'eux pour découvrir en cinq minutes qu'il disait vrai depuis 48 jours.

Concrètement : si le premier pas d'une recommandation consiste à construire, câbler ou sécuriser quelque
chose avant de pouvoir faire la chose demandée, **on la reformule pour que le premier pas soit la chose
elle-même, en version réduite**, et le prérequis devient la première écriture de ce travail, pas son
préalable. Une recommandation qui ne survit pas à cette reformulation n'est pas mûre.

🔴 **Durci le 27/08/2026 : un conseil de FREINAGE doit porter le chiffre de ce que freiner rapporte.**

Trois occurrences, toutes ignorées, et Clément a fait l'inverse dans les jours qui ont suivi : borner le
sponsoring à 2 posts par mois (le lendemain, décision d'accélérer sans plafond), gater les appels
découverte gratuits avant tout le reste (jamais fait, c'est le sponsoring qui a avancé), adoucir la
cadence des DM (l'envoi est passé en automatique le 21/08).

Le correctif n'est pas d'arrêter de conseiller la prudence, c'est d'arrêter de la conseiller à vide.
**Tout conseil qui propose de plafonner, ralentir, filtrer ou reporter doit chiffrer ce que la retenue
rapporte**, en euros ou en heures, contre ce qu'elle coûte en opportunités. Sans ce chiffre, il ne passe
pas le filtre de Phase 2 : l'expérience dit qu'il ne sera pas suivi, donc l'écrire est du bruit.

⚠️ Ces deux règles se mesurent au registre `_RESULTATS-CONSEILS.md`. Si le taux de `non-suivi` ne bouge
pas d'ici trois conseils, ce sont ces règles qu'il faudra retirer, pas en ajouter d'autres.

Puis toi (président) : synthétise, **tranche les désaccords**, réponds au steelman, produis la liste ordonnée des
améliorations à plus forte valeur (garder / jeter / prioriser). **Préserve la dissidence** : une lentille isolée
qui maintient sa position figure au verdict avec son argument, elle ne se lisse pas en consensus. La précision
d'un débat décroît avec les rounds quand on cherche l'accord ; le désaccord conservé vaut mieux qu'un accord
fabriqué.

## Phase 3 — Boucle de correction (plancher : au moins 1 check)

S'il n'y a rien de lourd, tu fais quand même un check rapide et tu le dis en une ligne. Sinon :
- 🔪 **Budget de lignes net à zéro, durci le 27/08/2026.** Ajouter N lignes à un skill oblige à en retirer N.
  Au-delà de **500 lignes**, seules les modifications qui réduisent passent. Ce n'est pas une préférence de
  style : 13 skills du vault dépassent déjà ce seuil, le plus gros à 870 lignes, et un modèle suit moins bien
  le milieu d'un document long, donc une règle ajoutée à un skill obèse peut dégrader ses décisions au lieu
  de les améliorer. Le 22/08, le skill a reçu treize ajouts et zéro retrait, trois ont été retirés le lendemain.
  Une exigence que personne ne réclame nommément est la première candidate au retrait, avec les références à
  des fichiers déplacés et les mentions d'outils abandonnés.
  ✅ Vérifié en vrai le 27/08 : `github-radar` a reçu 27 lignes et en a rendu 9, ce qui l'a ramené à 500 pile.
  La compensation a supprimé au passage toutes les mentions de Cowork, migré depuis le 19/07, et trois renvois
  vers des patchs archivés le jour même. **Chercher quoi couper trouve de vraies erreurs, pas juste du volume.**
- **Code** : fixers `sonnet` en **worktree**, build vert, puis un **reviewer adversarial** qui essaie de casser chaque fix.
- **Process / contenu / skill** : applique directement + un reviewer.
- **Email** : invoque le skill `/email`, jamais de rédaction à la main (sinon tu sautes voix, anti-em-dash, threading, PJ).
- **Outil manquant** : `/find-skill` plutôt que réinventer, mêmes garde-fous qu'en Phase 1.
- 🥊 **Gauntlet : le critique est apparié 1 pour 1 au fixer, et il est AVEUGLE.** Pas un reviewer unique en bout
  de chaîne : un juge global note un ensemble et laisse passer les morceaux faibles. Chaque fixer a son critique,
  qui reçoit le rendu ET la référence de Phase 0.5 **sans étiquette**, et rend `{ gagnant, écart, ce_qui_manque }`.
  L'aveuglement n'est pas un détail de forme : c'est la seule parade au biais d'auto-complaisance, qui est
  précisément le défaut que l'évaluateur est censé corriger (Anthropic, *Building effective agents*, 2024).
- 🎯 **La condition d'arrêt appartient au critique, pas au compteur.** Quand une barre a été fixée en Phase 0.5,
  on ne s'arrête pas « après 2 rounds » : on s'arrête quand **le critique aveugle préfère notre version**. Un
  compteur de rounds n'est pas une barre, c'est un budget. **Plafond dur quand même** : 3 rounds sans progrès sur
  le même morceau, on stoppe et on remonte ce morceau au batch de Phase 4. Une boucle qui n'avance plus sur trois
  rounds n'avance plus du tout, elle consomme.
- 👁️ **Sur un objet visuel, le verdict exige une capture réelle.** Un agent qui écrit « c'est superbe » sans avoir
  screenshoté n'a rien vérifié : c'est le mode d'échec numéro un du dispositif, et il est déjà documenté chez
  Clément (🔴 jamais-computer-use-pour-vérifier-un-livrable vaut pour l'inverse aussi : on vérifie, mais avec la
  bonne route). Rapport côte à côte, référence à gauche, notre rendu à droite, verdict et round sous chaque paire.
- **Loop-until-dry**, quand AUCUNE barre n'a été fixée (process, code, contenu non visuel) : stop après 2 rounds
  sans nouveau problème, ou budget atteint. Loggue corrigé / restant.
- Autonomie sur les fixes évidents, vraies questions gardées pour la Phase 4. **Jamais d'irréversible sans go.**

## Phase 4 — Batch AVAL (★ sortie garantie, jamais sautée)

**C'est LE but du skill** : après le débat, ça finit **toujours** par un batch d'options **« (Recommandé) »**. Questions
fermées, chaque recommandation **sourcée sur le débat / la triangulation / le vault**, jamais une supposition, l'option
recommandée en premier. Porte sur ce que le conseil n'a pas tranché + les next steps.

⚠️ **Anti-rubber-stamping** : le « (Recommandé) » est une aide à la décision, pas un pilote automatique. Les options
concurrentes doivent rester de vraies options défendues, pas des repoussoirs. Si le conseil est réellement partagé,
dis-le au lieu de fabriquer une recommandation de confort.

🚨 **LE FILTRE À APPLIQUER AVANT D'ÉCRIRE CHAQUE QUESTION** (Clément, 22/08/2026, à ses mots) :
« moi je fais que cliquer sur recommander, donc autant que tu prennes directement les réponses recommandées […]
j'ai l'impression que parfois je clique sur recommander mais en fait tu aurais pu prendre la décision tout seul. »

Clément clique **systématiquement** sur l'option recommandée. Donc, avant chaque question, se demander :
**« s'il clique sur Recommandé, est-ce que j'apprends quelque chose ? »**

- **Non** → ce n'est pas une question, c'est une demande de permission déguisée. **Tranche, fais, et annonce-le
  en une ligne dans la réponse.** Un aller-retour qui ne mesure rien coûte plus qu'il ne protège.
- **Oui** → c'est une vraie question, elle a sa place dans le batch.

Ce qui reste au batch : un débat réellement partagé au sein du conseil, un choix dont Clément assume les
conséquences, un arbitrage où plusieurs options sont également défendables, **et tout engagement d'argent**
(prix, devis, TJM, montant), qui reste bloquant sans exception.

Ce qui n'y va plus : les réglages techniques évidents, les choix où une option domine clairement, les
confirmations de ce qu'il vient lui-même de demander.

⚠️ Ceci ne supprime PAS le plancher de questions par régime : il le **rend plus dur à atteindre**. Si après ce
filtre il ne reste plus assez de vraies questions pour remplir le plancher, c'est le signal que le sujet est
déjà tranché : dis-le, et ne complète pas avec des questions de remplissage.

## Phase 5 — Boucle fermée (après le batch, une fois Clément décidé)

Écris la décision pour qu'elle soit **réutilisée** au lieu d'être re-cherchée : note courte dans `08-Idees-et-veille/`
(cible, verdict, certain/contesté, décision, sources) que la Phase 0 relira en `déjà_traité` ; plus un fichier `(mémoire interne)`
+ ligne d'index si la décision est stable et réutilisable. Vault git-tracké → **ne pas committer sans go**.

**Puis ferme la boucle de mesure**, c'est ce qui distingue une amélioration réelle d'une auto-congratulation :
lance `python3 ~/.claude/scrapling/resultats_conseils.py` pour créer l'entrée du conseil dans le registre, et
**renseigne toi-même le champ `decision`** avec ce que Clément vient de trancher. Les champs `verdict` et
`ce qui s'est passe` restent à `?` : ils ne se remplissent que plus tard, quand le résultat est connu. Ne les
devine jamais. Un `?` honnête vaut mieux qu'un verdict inventé, qui empoisonnerait la mesure au lieu de la
nourrir.

**Écris une prédiction falsifiable**, sauf en régime 🔍 Recherche, qui rend un état des lieux et n'a donc
aucun verdict à falsifier. Sur le point le plus engageant du verdict, formule une affirmation qui
pourra être déclarée vraie ou fausse, avec une date de vérité tirée du cycle réel (trois semaines pour un envoi
ou un post, six semaines pour un deal). « Si on envoie X, on aura une réponse sous 7 jours » se vérifie ; « c'est
la bonne approche » ne se vérifie jamais et ne vaut rien comme trace. Sans prédiction datée, le registre
n'enregistre que des opinions.

⚠️ **La règle des 3, garde-fou contre le surapprentissage.** Le SKILL.md ne se réécrit **que lorsque trois
post-mortems pointent le même axe fautif**. Jamais sur un échec isolé. C'est la même règle des 3 qui a multiplié
par 7 le taux de carton sur LinkedIn, et elle vaut ici pour la raison inverse : un conseil qui se corrige après
chaque revers apprend le bruit, pas le signal.

Enfin, à chaque conseil, jette un œil au bilan : `python3 ~/.claude/scrapling/resultats_conseils.py --bilan`.
S'il annonce qu'aucun résultat n'est renseigné, dis-le à Clément en une ligne : tant que ce message s'affiche,
la boucle d'amélioration ne mesure rien.

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
