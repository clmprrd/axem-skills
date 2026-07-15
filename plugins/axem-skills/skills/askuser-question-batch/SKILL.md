---
name: askuser-question-batch
description: Valide par lots de questions (AskUserQuestion) le contenu d'un document à fort enjeu (mail important, proposition, contrat, réponse à un questionnaire partenaire) avant de le finaliser/envoyer. À invoquer dès que Clément demande de "poser des questions en batch", "challenger avec l'Obsidian", "affiner par lots", ou dès qu'un document a des points ouverts/incertains qui méritent son arbitrage explicite plutôt qu'une hypothèse de Claude. Se déclenche aussi automatiquement quand un audit de complétude (ex: vs un questionnaire reçu) révèle des trous substantiels à combler avec des décisions du utilisateur.
---

# AskUser Question Batch — Valider un document par lots de questions ciblées

## Quand l'utiliser

- Un mail/document important part vers un tiers externe (partenaire, client, prospect) et contient des chiffres, engagements ou décisions qui n'ont pas encore été explicitement validés par Clément.
- Un audit de complétude (relecture du document vs un questionnaire/brief reçu) révèle des sections manquantes ou vagues.
- Clément dit explicitement "pose-moi des questions en batch", "challenge avec l'Obsidian", "affine encore", ou équivalent.

Ne PAS l'utiliser pour des micro-décisions triviales (formulation, ton) — réservé aux points qui engagent réellement (prix, engagements contractuels, chiffres cités à un tiers).

## Principe

Ne jamais deviner un chiffre, un engagement ou une clause qui engage Clément vis-à-vis d'un tiers. Décomposer les inconnues en lots de questions fermées (AskUserQuestion, max 4 questions par appel), avec pour chaque question une option "Recommandé" pré-remplie à partir de données réelles du vault/CRM/mémoire — jamais une pure supposition non sourcée.

## Processus

### 1. Cartographier les inconnues
Avant de poser une seule question, lire ce qui existe déjà :
- Le document/brief reçu du tiers (ex: questionnaire, brief, cahier des charges) — lister EXHAUSTIVEMENT chaque sous-question, pas juste les titres de section.
- Le vault Obsidian (`memory/`, `CRM/`, `13-Comptabilite/`, `referentiel-decision.md`) pour toute donnée déjà écrite qui répond à une sous-question.
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

- 4 questions maximum par appel `AskUserQuestion` (limite de l'outil).
- Chaque question doit être fermée et actionnable (pas de question ouverte type "que penses-tu de X ?" — proposer des options concrètes).
- Toujours inclure, quand c'est pertinent, une option qui reporte la décision (call, plus tard) plutôt que de forcer un choix immédiat sur un point que Clément préfère garder ouvert.
- Ne jamais reformuler une réponse déjà donnée dans un lot précédent en la faisant passer pour une nouvelle question — si un point est tranché, il est tranché.

## Exemple de séquencement (mail de réponse à un questionnaire partenaire)

1. Lot 1 — Positionnement & chiffres d'activité (statut juridique, clients citables, volume d'activité)
2. Lot 2 — Prix (planchers, remises)
3. Lot 3 — Modalités du partenariat (commissions, exclusivité)
4. Lot 4 — Mécanique de suivi (jalons, propriété client, clauses)
5. Audit de complétude vs le questionnaire d'origine, section par section
6. Si des trous substantiels apparaissent (offres détaillées, preuves chiffrées, mécanique contractuelle, logistique formateurs, certifications) → nouveaux lots ciblés sur CES trous précis, en réutilisant en priorité les données déjà trouvées dans le vault (ex: cas clients chiffrés déjà documentés) avant de redemander à Clément.
