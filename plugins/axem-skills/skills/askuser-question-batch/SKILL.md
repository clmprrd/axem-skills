---
name: askuser-question-batch
description: "Pousse Clément à l'action par lots de questions fermées (AskUserQuestion) avec options « (Recommandé) ». À invoquer À LA FIN DE TOUT TOUR qui laisse une décision ouverte, un choix à faire, ou une suite à trancher — pas seulement pour valider un document. Déclencheurs typiques : fin d'audit, fin de diagnostic, fin de livrable, options présentées, arbitrage nécessaire, ou Clément qui dit \"pose-moi des questions en batch\". Le test : si la réponse se termine par une question en prose ou par \"dis-moi ce que tu veux faire\", c'est que ce skill aurait dû être appelé."
---

# AskUser Question Batch — pousser à l'action, pas seulement valider

## 🔴 LA RÈGLE, avant tout le reste

**Toute réponse qui laisse une décision ouverte se termine par un appel `AskUserQuestion`. Jamais par une question en prose.**

Le test à faire avant de conclure un tour, systématiquement :

> *Est-ce que j'attends quoi que ce soit de Clément ?*
> Si oui → `AskUserQuestion`. Si non → une phrase qui ferme, jamais une question ouverte.

Formulations qui prouvent qu'on a raté le déclenchement, et qu'il faut remplacer par un batch :
« dis-moi si tu veux », « tu préfères que je… ? », « je te laisse voir », « veux-tu qu'on ouvre ce chantier ? »,
« par quoi tu veux commencer ? », « tu me dis », « à toi de voir ».

**Pourquoi c'est dur, pas cosmétique** (Clément, 29/07/2026) : il pilote en cliquant, pas en rédigeant. Un tour qui
se termine par une question en prose n'appelle pas à l'action, le sujet dort, et il perd le fil entre ses sessions.
Cas réel du 29/07 : un audit des skills en doublon s'est terminé par « dis-moi si on l'ouvre », donc rien ne s'est
passé, alors qu'un batch aurait fait trancher les trois points en un clic.

## Quand l'utiliser

**Le cas large, celui qui manquait :** à la fin de **tout tour qui laisse quelque chose à décider**. Fin d'audit,
fin de diagnostic, fin de livrable, plusieurs options possibles, un chantier à ouvrir ou non, une priorité à choisir.
C'est le cas le plus fréquent, et c'est celui qui était absent des versions précédentes de ce skill.

**Les cas historiques, toujours valables :**
- Un mail ou document à fort enjeu part vers un tiers et contient des chiffres, engagements ou décisions non validés.
- Un audit de complétude révèle des sections manquantes ou vagues.
- Clément dit « pose-moi des questions en batch », « challenge avec l'Obsidian », « affine encore ».

**Les deux moments d'un gros sujet** : un batch AVANT de dépenser (cadrer le scope et l'intensité), un batch APRÈS
(décider de la suite). Voir la règle #0.3 du `CLAUDE.md` du vault.

Ne PAS l'utiliser pour du purement mécanique et sans enjeu : une correction de typo, une lecture de fichier, une
commande shell. **En cas de doute, poser le batch** : le coût d'un batch de trop est nul, celui d'un sujet qui dort
faute d'appel à l'action est réel.

## Principe

Ne jamais deviner un chiffre, un engagement ou une clause qui engage Clément vis-à-vis d'un tiers. Décomposer les inconnues en lots de questions fermées (AskUserQuestion, max 4 questions par appel), avec pour chaque question une option "Recommandé" pré-remplie à partir de données réelles du vault/CRM/mémoire — jamais une pure supposition non sourcée.

## Processus

### 1. Cartographier les inconnues
Avant de poser une seule question, lire ce qui existe déjà :
- Le document/brief reçu du tiers (ex: questionnaire, brief, cahier des charges) — lister EXHAUSTIVEMENT chaque sous-question, pas juste les titres de section.
- Le vault Obsidian (vos notes internes (mémoire, CRM, compta)) pour toute donnée déjà écrite qui répond à une sous-question.
- Les transcripts Fathom pertinents, au cas où Clément aurait déjà donné une réponse à l'oral.

Croiser les deux : chaque sous-question devient soit "déjà répondu, à réutiliser tel quel" (ne pas re-demander), soit "à trancher avec Clément" (va dans un lot).

### 2. Détecter les incohérences avant de demander
Si une donnée trouvée contredit une autre (ex: un statut "signé" dans un fichier mais "pas payé" dans un autre plus récent), NE PAS choisir silencieusement laquelle croire — remonter l'incohérence explicitement dans la question, avec les deux sources citées, et laisser Clément trancher.

### 3. Grouper par thème, poser en lots de 4
Organiser les inconnues en lots thématiques cohérents (ex: "prix et marge", "mécanique contractuelle", "preuves/références citables", "logistique"). Un lot = un appel `AskUserQuestion` avec jusqu'à 4 questions. Pour chaque question :
- **Toujours donner une option "Recommandé"** basée sur une donnée trouvée à l'étape 1 (jamais une pure invention) — précise la source en une phrase courte dans la description de l'option.
- Ajouter une option de repli explicite quand pertinent ("À trancher au call, pas par mail", "Reste vague", "Autre — tu me donnes le chiffre").
- Ne pas mélanger dans un même lot des sujets trop différents (ex: pas de prix et de logistique dans le même lot) — un lot doit se lire comme une décision cohérente.

Enchaîner les lots un par un (pas tous en parallèle) : chaque lot peut être informé par la réponse au lot précédent.

### 4. Intégrer les réponses sans réinterprétation
Une fois un lot répondu, reporter les réponses telles quelles dans le document — ne pas les édulcorer ni les étendre. Si une réponse de Clément est elle-même dictée/ambiguë (fautes de frappe, formulation orale imprécise typique de la dictée vocale), la reformuler clairement mais vérifier le sens avec lui si un doute réel subsiste plutôt que de deviner.

### 5. Auditer la complétude avant de considérer le document prêt
Une fois tous les lots traités, refaire une passe de croisement complet (comme l'étape 1) entre le document final et le brief/questionnaire d'origine, sous-question par sous-question, avec un statut ✅/🟡/❌ pour chacune. Ne déclarer le document "prêt" que si le taux de complétude est explicitement communiqué à Clément (pas juste "c'est fait") — s'il reste des 🟡/❌, les remonter avant de proposer l'envoi.

## Règles de forme pour les questions

- **Option « (Recommandé) » en premier**, toujours, avec sa justification sourcée dans la description.
- **Les options concurrentes doivent rester de vraies options**, défendues honnêtement, pas des repoussoirs fabriqués
  pour valider la recommandation. Si le choix est réellement ouvert, le dire au lieu d'inventer une reco de confort.
- **Le maximum d'information DANS la question** : les faits, chiffres, dates, ce qui bloque. Clément doit pouvoir
  trancher sans aller lire ailleurs.
- **`multiSelect: true`** dès que les choix ne s'excluent pas.

- 4 questions maximum par appel `AskUserQuestion` (limite de l'outil).
- Chaque question doit être fermée et actionnable (pas de question ouverte type "que penses-tu de X ?" — proposer des options concrètes).
- Toujours inclure, quand c'est pertinent, une option qui reporte la décision (call, plus tard) plutôt que de forcer un choix immédiat sur un point que Clément préfère garder ouvert.
- Ne jamais reformuler une réponse déjà donnée dans un lot précédent en la faisant passer pour une nouvelle question — si un point est tranché, il est tranché.

## La barre à atteindre : le troisième bloc de toute question qui ouvre un chantier

Intégré le 26/08/2026, méthode « gauntlet loop » (Matt Shumer, vidéo `youtu.be/BNjzXcEXmg4`). Skill dédié : `/gauntlet-loop`.

Un prompt qui produit vraiment quelque chose tient en trois blocs, pas un seul :

1. **LA TÂCHE** : quoi. C'est ce que le batch cadre déjà bien.
2. **LA MÉTHODE** : comment. Combien d'agents, quel découpage, qui vérifie le travail.
3. **LA BARRE** : quand on s'arrête. **C'est celui qui manquait, et c'est celui qui coûte le plus cher quand il manque.**

**La règle.** Dès qu'une question ouvre un chantier de production (un livrable, un build, un run long, une série
de posts, une page, un deck, un visuel), **l'option recommandée dit contre quoi on se compare et à quoi on
reconnaîtra que c'est fini**. Pas « on y va ? », mais « on y va, la référence à battre est X, on s'arrête quand
un critique aveugle préfère la nôtre ».

**Pourquoi c'est dur, pas cosmétique.** Une barre exprimée en adjectif (« du propre », « du niveau pro »,
« du AAA ») n'est pas une barre : rien ne peut jamais la déclarer atteinte, donc soit on livre trop tôt, soit la
boucle ne s'arrête jamais. Une barre utile nomme **un objet réel qui existe déjà** : la charte du client, le site
du concurrent, le post qui a fait 400 likes, le deck de la dernière formation, la photo de référence. Un objet
réel se compare côte à côte ; un adjectif ne se compare pas.

**Le corollaire, et il coûte des heures.** Un « oui vas-y » sur une tâche floue lance un run qui optimise *à la
perfection* vers la mauvaise cible. Cas source de la méthode : une page produit visuellement superbe, générée en
1 h 19 de calcul, et entièrement hors de la charte réelle de la marque. Le système n'avait rien raté, c'est la
prémisse qui était fausse. Exactement le mode d'échec déjà documenté partout ailleurs ici : le raisonnement est
rarement fautif, **c'est presque toujours la prémisse qui est périmée ou à côté**.

**Ce que ça change dans la forme des questions :**

- Une question qui lance un run long porte sur **la barre**, pas sur la permission. « Contre quoi on se
  compare ? » apprend quelque chose. « Je lance ? » n'apprend rien : ce n'est donc pas une question, c'est une
  décision à prendre seul et à annoncer en une ligne (filtre du 22/08).
- **Quand plusieurs références sont plausibles, elles deviennent les options de la question.** C'est le cas où le
  batch a le plus de valeur : Clément est le seul à savoir laquelle compte réellement pour lui.
- Sur un run long, ajouter une option d'**intensité** (une passe rapide / la boucle complète jusqu'à ce que le
  critique préfère la nôtre), avec le coût en temps annoncé dans la description de l'option. Une boucle complète
  se compte en heures, ça se dit avant, pas après.

**Où ça ne s'applique pas** : un arbitrage, un choix de priorité, une validation de chiffre, un envoi. Ces
questions ne produisent pas d'artefact, elles n'ont donc aucune référence à battre. Ne pas fabriquer une barre
pour la forme.

## Exemple de séquencement (mail de réponse à un questionnaire partenaire)

1. Lot 1 — Positionnement & chiffres d'activité (statut juridique, clients citables, volume d'activité)
2. Lot 2 — Prix (planchers, remises)
3. Lot 3 — Modalités du partenariat (commissions, exclusivité)
4. Lot 4 — Mécanique de suivi (jalons, propriété client, clauses)
5. Audit de complétude vs le questionnaire d'origine, section par section
6. Si des trous substantiels apparaissent (offres détaillées, preuves chiffrées, mécanique contractuelle, logistique formateurs, certifications) → nouveaux lots ciblés sur CES trous précis, en réutilisant en priorité les données déjà trouvées dans le vault (ex: cas clients chiffrés déjà documentés) avant de redemander à Clément.
