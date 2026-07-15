---
name: webinar-prep
description: Prépare le script mot-à-mot et les prompts copier-coller d'un intervenant qui doit animer un webinaire, une présentation, un pitch ou une conférence en ligne avec démonstration live d'un outil (Claude Cowork, connecteurs Gmail/Agenda/Drive, plugins Excel/Word/PowerPoint, ou tout autre logiciel). Produit une "cheat sheet" HTML autonome avec un bouton de copie en un clic sur chaque prompt, pensée pour être ouverte à côté de l'outil de présentation pendant le direct. Utilise ce skill dès que l'utilisateur mentionne qu'il doit préparer, animer, co-animer ou intervenir dans un webinaire ou une démo live, même s'il n'a pas encore de plan, même s'il ne connaît pas encore le détail des démos, et même s'il ne nomme pas ce skill explicitement — des phrases comme "je dois faire un webinaire demain", "prépare-moi pour cette présentation avec démo", "j'ai une intervention live la semaine prochaine" ou "fais-moi le script pour ma partie" doivent déclencher ce skill.
---

# Webinar Prep

Transforme la préparation d'un webinaire (ou de toute intervention orale avec démonstration live) en deux livrables concrets :

1. **Un script mot-à-mot** pour la portion de l'utilisateur — assez détaillé pour être dit quasiment tel quel, avec assez de matière pour ne jamais laisser de blanc pendant qu'une démo tourne.
2. **Une page HTML autonome ("cheat sheet")** que l'utilisateur ouvre à côté de son outil de présentation, avec un bouton "Copier" en un clic sur chaque prompt à coller en direct.

Ce skill est générique : il s'adapte à n'importe quel sujet, outil démontré et audience. Ce n'est pas un template figé sur un secteur particulier — ne réutilise pas mot pour mot un exemple d'une session précédente, reconstruis le contenu à partir du plan réel de l'utilisateur.

## Étape 0 — Toujours commencer par ces questions

Un webinaire raté à cause d'un script mal calé ou d'une démo improvisée coûte cher : crédibilité de l'utilisateur, temps des autres intervenants, image de la boîte. Avant de rédiger quoi que ce soit, pose ces questions (regroupe-les en un seul appel si l'outil de questions le permet, et saute celles dont la réponse est déjà donnée dans la conversation) :

1. Sujet, audience cible et objectif du webinaire (générer des leads ? vendre une offre ? former ? autre ?).
2. Qui sont les intervenants, et quelle est la portion de CET utilisateur dans le programme (ordre, timing approximatif) ?
3. Y a-t-il déjà un plan/déroulé (texte collé, fichier joint, ou email à retrouver) à suivre à l'identique, ou faut-il en proposer un ?
4. Quelles démonstrations live sont prévues, et avec quels outils (boîte mail, agenda, stockage cloud, notetaker de réunion, Excel/Word/PowerPoint, autre logiciel) ?
5. Si une démo s'appuie sur des données réelles (tableur, document) : l'utilisateur a-t-il un jeu de données à fournir, ou faut-il en générer un fictif plausible ?

Ne saute pas cette étape même si l'utilisateur a l'air pressé ("c'est demain") — c'est justement quand c'est urgent qu'une mauvaise supposition coûte le plus cher : un script écrit sur de mauvaises hypothèses est plus long à corriger que ces questions ne prennent de temps à poser.

## Étape 1 — Obtenir le plan exact

Le traitement dépend de ce que l'utilisateur a déjà :

- **Plan fourni directement** (texte collé ou fichier joint) : utilise-le tel quel. Ne résume pas, ne réécris pas la structure ni les timings — un plan de webinaire à plusieurs voix a probablement déjà été négocié et validé avec d'autres personnes ; le déformer casse la coordination avec elles.
- **Plan dans un email** : si l'utilisateur indique qu'un partenaire ou collègue le lui a envoyé, cherche l'échange (nom de la personne, sujet, date approximative), lis le fil complet — les plans sont souvent révisés dans les réponses successives, pars toujours de la DERNIÈRE version du fil, jamais de la première pièce jointe trouvée — et télécharge la pièce jointe si le déroulé y est détaillé plutôt que dans le corps du texte.
- **Pas de plan encore** : sois force de proposition. Construis un déroulé minuté complet à partir des réponses de l'étape 0 (sujet, durée totale, nombre et rôle des intervenants, objectif), et fais-le valider avant d'aller plus loin — ne rédige jamais 30 minutes de script sur une structure encore hypothétique, le risque de devoir tout refaire est trop élevé.

## Étape 2 — Rédiger le script mot-à-mot

Pour chaque section du plan qui concerne l'utilisateur :

- Écris une réplique d'ouverture ("setup") qui pose le problème ou le contexte avant de montrer la solution — jamais une démo qui démarre sans mise en contexte.
- Pour toute démo live qui prend du temps à s'exécuter, écris PLUSIEURS phrases à dire "pendant que ça tourne". L'erreur la plus fréquente est de sous-estimer le nombre de choses à dire pendant qu'un outil travaille en arrière-plan — compte large, mieux vaut trop de matière que un blanc gênant devant une salle. Utilise ce temps pour expliquer ce qui se passe techniquement, relier au métier de l'audience, ou glisser une réassurance (sécurité, contrôle humain).
- Si le webinaire s'appuie sur des connecteurs/outils spécifiques (boîte mail, agenda, stockage, notetaker, plugin bureautique), explique CHACUN individuellement avec une phrase concrète sur ce qu'il fait et sur ses limites/garanties (lecture seule vs écriture, ce qui se passe seulement sur demande explicite vs automatiquement, etc.). Vérifie ces détails avec une recherche web plutôt que de les inventer : les fonctionnalités de ces outils changent vite et une explication fausse en direct devant une audience est le pire moment pour se tromper.
- Si l'utilisateur veut placer une preuve de crédibilité générique (nombre de clients déjà accompagnés, cas déjà déployés), places-en une version courte tôt dans le script pour poser la crédibilité avant les démos, et une autre près du closing/CTA pour la relier à l'action demandée.
- Termine chaque section par un pont explicite vers l'étape suivante du programme — jamais une démo qui retombe à plat sans relance vers la suite (récap, CTA, Q&A).

## Étape 3 — Écrire les prompts à copier-coller

- Chaque prompt doit nommer explicitement le connecteur/outil qu'il utilise À L'INTÉRIEUR du texte du prompt lui-même (ex : "Utilise le connecteur Gmail : lis mes emails non lus..."), pas seulement dans un commentaire à côté. L'utilisateur va lire ce prompt à voix haute en le collant en direct — la mention doit y être pour que ce qu'il dit corresponde à ce qui s'affiche à l'écran.
- Un prompt = une action claire, avec un format de sortie précisé si le résultat doit être lisible par l'audience.
- Si une démo a un aspect "bonus" plus risqué ou plus long à démontrer (ex : créer une automatisation en direct), propose-le comme prompt optionnel séparé plutôt que de le mélanger au prompt principal — ça laisse à l'utilisateur la liberté de le sauter si le timing se resserre.

## Étape 4 — Fichier de démonstration avec données réelles (seulement si demandé explicitement)

Ne construis PAS de fichier de démo par défaut — seulement si l'utilisateur le demande ou fournit lui-même des données à utiliser.

Si une démo porte sur un outil bureautique (Excel/Word/PowerPoint) avec un vrai jeu de données : utilise le skill xlsx/docx/pptx approprié pour construire le fichier support, avec des formules natives (jamais de valeurs calculées en Python et codées en dur), zéro erreur de formule vérifiée avant livraison, et une mise en forme professionnelle sobre. Ce fichier est l'état "avant" de la démo : ne fabrique pas toi-même le résultat "après" (graphiques, mise en forme finale, tableau de bord) que la démo est censée produire EN DIRECT devant l'audience — le construire à l'avance viderait l'effet de la démonstration que l'utilisateur veut montrer.

## Étape 5 — Construire la cheat sheet HTML

Utilise `assets/cheat-sheet-base.html` comme point de départ. Il contient déjà la mise en page (nav collante avec ancres, timeline du déroulé, cartes de section, boîtes de prompt) et surtout la fonction JavaScript de copie en un clic — déjà conçue pour marcher même en ouvrant le fichier en local (`file://`), un contexte où l'API clipboard standard du navigateur échoue silencieusement (elle demande un "contexte sécurisé" que file:// ne fournit pas toujours). Ne réécris pas cette fonction à partir de zéro : copie le fichier tel quel et ajoute juste un bloc `<pre id="...">` par prompt avec son bouton, en suivant le pattern déjà présent dans le fichier.

Structure attendue (adapte les sections au plan réel, n'invente pas de sections qui n'existent pas dans le programme de l'utilisateur) :
- En-tête avec les infos de l'événement (date, horaire, portion de l'utilisateur dans le programme).
- Un bloc "déroulé" qui montre le programme complet, avec la portion de l'utilisateur mise en évidence visuellement.
- Une carte par section du script de l'utilisateur (intro, chaque démo, conclusion), avec les répliques et les boîtes de prompt copiables intégrées au bon endroit du script (pas toutes regroupées à la fin).
- Une section Q&A avec des questions de secours à poser soi-même si la salle reste timide.
- Une checklist technique à cocher avant le direct (comptes/outils connectés, fichiers ouverts, jeux de données prêts, tâches programmées déjà créées si applicable).

Sauvegarde le fichier final là où l'utilisateur travaille habituellement (vault Obsidian, dossier projet, dossier partagé) — pas seulement dans un dossier temporaire qu'il ne retrouvera pas.

## Rappel

Si le timing total de la portion de l'utilisateur dépasse ce qui a été validé avec les autres intervenants (par exemple si une démo est ajoutée en cours de route), signale-le clairement et visiblement dans le déroulé de la cheat sheet — ne laisse pas ce genre de dérive passer inaperçue, ça se répercute sur les autres personnes qui comptent sur le timing annoncé pour caler leur propre partie.
