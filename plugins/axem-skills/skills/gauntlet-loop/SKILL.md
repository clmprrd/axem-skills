---
name: gauntlet-loop
description: >
  Construit et exécute un prompt "gauntlet loop" : trois blocs (LA TÂCHE / LA MÉTHODE / LA BARRE), fan-out de
  sous-agents workers, chacun apparié à un critique AVEUGLE qui compare le résultat à une référence réelle nommée,
  et la boucle ne s'arrête que quand le critique préfère notre version. À déclencher quand Clément dit :
  "/gauntlet-loop", "gauntlet", "fais-le tourner jusqu'à ce que ce soit parfait", "fan out des sous-agents",
  "boucle jusqu'à ce que ce soit au niveau de X", "je veux du niveau AAA", "mets un critique dessus",
  "compare en aveugle avec", "polis ça jusqu'au bout", "warp drive sur cette v1".
  À utiliser aussi comme SOUS-ROUTINE : la Phase 3 de /conseil-agents et toute demande de polish d'un livrable
  déjà cadré (site, deck, page, visuel, doc client, page LinkedIn, prototype).
argument-hint: "<la chose à porter au niveau maximum> [+ la référence à battre]"
user-invocable: true
---

# Gauntlet Loop : la boucle qui ne s'arrête pas avant d'avoir battu la référence

## En une phrase

Tu écris trois blocs (la tâche, la méthode de construction, la barre à atteindre), tu fais éclore un worker par
morceau, tu colles à chaque worker **un critique aveugle** qui compare son morceau à **une référence réelle nommée**,
et la boucle tourne tant que le critique n'a pas dit que notre version est meilleure.

## D'où ça vient, et ce qui est réellement nouveau

- Le prompt d'origine tient en **trois lignes**, publié par **Matt Shumer** après sa démo de FPS one-shotté par
  Opus 5 (environ 4,8 millions de vues sur X). Karpathy en a fait le symbole d'une bascule : on ne teste plus un
  modèle avec un SVG de pélican, parce que ces modèles ont « toute la patience du monde » pour du custom que
  personne n'écrirait à la main.
- **Le pattern worker + évaluateur n'est PAS neuf.** Anthropic l'a documenté dès 2024 dans *Building effective
  agents* : un modèle qui juge la sortie d'un autre modèle donne de meilleurs résultats, parce qu'un modèle seul
  se persuade tout seul que sa sortie est déjà bonne.
- **Ce qui est neuf, et c'est là qu'est toute la valeur** : la barre n'est plus une consigne floue (« fais du bon
  travail »), c'est **une comparaison en aveugle contre un objet réel qui existe déjà**. Et le critique n'est pas
  un juge global en fin de course : il est **apparié 1 pour 1** avec chaque worker.

Source vidéo : Jay, `youtu.be/BNjzXcEXmg4` (transcript lu le 26/08/2026).

---

## Le gabarit, à recopier tel quel

```
1. LA TÂCHE (quoi)
   Je veux que tu construises <objet>, au niveau de <référence réelle et nommée>.
   Ce doit être <niveau d'exigence>, avec chaque détail traité à ce niveau :
   <énumère 3 à 5 dimensions concrètes, pas des adjectifs>.

2. LA MÉTHODE (comment)
   Découpe l'objectif en les plus petits morceaux possibles.
   Fais éclore un sous-agent par morceau, chacun traite le sien individuellement.
   Attache à CHAQUE sous-agent un critique séparé qui vérifie son morceau visuellement.
   Ce critique est un juge très dur : si ce n'est pas au niveau, il renvoie le morceau et ça continue.

3. LA BARRE (quand s'arrêter)
   Tu ne t'arrêtes pas tant que chaque critique n'est pas bluffé par la qualité,
   COMPARÉE À <la référence réelle>.
   Le critique doit littéralement mettre les deux côte à côte, EN AVEUGLE,
   et dire laquelle est la meilleure. On continue tant que ce n'est pas la nôtre.
```

Version anglaise d'origine et variantes par domaine : [`references/gabarits.md`](references/gabarits.md).

---

## Les 4 règles qui font la différence entre un gauntlet et « juste plus d'agents »

1. **La référence est nommée, réelle et vérifiable.** « Du niveau Call of Duty », « la vraie page Ketone IQ »,
   « la photo du salon fournie ». Jamais « du niveau pro », « du AAA », « du haut de gamme » : un adjectif ne se
   compare pas, donc la boucle n'a pas de condition d'arrêt et le critique valide au deuxième round.
2. **Le critique est AVEUGLE.** Il reçoit les deux objets sans savoir lequel est le nôtre. C'est le seul garde-fou
   contre le biais d'auto-complaisance, qui est exactement le défaut que l'évaluateur est censé corriger.
3. **Le critique est apparié 1 pour 1 avec son worker**, pas un juge unique en bout de chaîne. Un juge global note
   un ensemble et laisse passer les morceaux faibles ; un critique dédié n'a qu'un morceau à défendre.
4. **La condition d'arrêt appartient au critique, pas à un compteur de rounds.** « 2 rounds puis on livre » n'est
   pas une barre, c'est un budget. La barre, c'est « le critique aveugle préfère la nôtre ».

---

## 🔴 LE PIÈGE, et il coûte deux heures à chaque fois

**Ne jamais lancer un gauntlet loop comme PREMIER prompt d'un sujet.**

Le gauntlet optimise **à la perfection** vers le brief qu'on lui a donné. Si le brief est à côté, il produit un
objet magnifique et hors sujet, en deux heures et beaucoup de tokens. C'est exactement ce qui est arrivé dans la
vidéo sur la page Ketone IQ : visuellement très au-dessus du vibe-coding habituel, et **complètement hors de la
charte réelle de la marque**. Le loop n'avait rien raté : on lui avait demandé la mauvaise cible.

**Donc l'ordre est non négociable :**

```
1. Un MVP / une charte / un brief VALIDÉ         ← batch askuser, humain, pas cher
2. PUIS le gauntlet loop comme warp drive sur la v2   ← deux heures, cher
```

Corollaire chez Clément : **ce qui se fait valider avant de lancer, c'est LA BARRE**, pas seulement le go. Un
« oui vas-y » sur une tâche floue est la façon la plus efficace de brûler une soirée de calcul.

⚠️ Ce piège est le même mode d'échec que celui documenté partout ailleurs dans ses règles : le raisonnement n'est
presque jamais fautif, c'est **la prémisse** qui est périmée ou fausse. Le gauntlet amplifie la prémisse.

---

## Coût, et donc quand ça se justifie

Ordres de grandeur mesurés dans la vidéo : **1 h 19** pour une page produit, **plus de 2 heures** pour un
walkthrough 3D (toujours pas terminé au moment du tournage, et le critique refusait encore).

Donc on le réserve à :
- un livrable **montrable** (page, deck, visuel, prototype, démo client) où la qualité EST le produit ;
- une **v2** dont la v1 est déjà on-brief ;
- un sujet où **une référence réelle existe** et qu'on veut explicitement dépasser.

On ne le sort pas pour : un mail, une note, un arbitrage, une recherche. Ces objets n'ont pas de référence
visuelle à battre, et la boucle tournerait sur du vide.

---

## Exécution, concrètement

**Mode 1 (défaut) : je génère le prompt.** Clément donne la tâche, je rends le prompt gauntlet complet à
copier-coller, avec sa référence nommée déjà remplie et sa barre écrite. C'est le mode le moins cher.

**Mode 2 : je l'exécute.** Uniquement après validation explicite de la barre (batch askuser), parce que c'est un
run long. Mécanique :

- fan-out via `Agent` (ou `Workflow` si Clément a demandé l'orchestration multi-agents), un worker par morceau ;
- pour chaque worker, un **critique séparé** qui reçoit le rendu ET la référence, **sans étiquette**, et rend
  `{ gagnant: "A" | "B", ecart, ce_qui_manque }` ;
- on ne s'arrête que sur « notre version gagne », ou sur **arrêt explicite de Clément** ;
- **plafond dur** : si au bout de 3 rounds le critique préfère toujours la référence sur le même morceau, on
  s'arrête et on remonte le morceau à Clément. Une boucle qui n'avance plus sur trois rounds n'avance plus du
  tout, elle consomme.
- vérification visuelle réelle quand l'objet est visuel : screenshot via les outils navigateur, pas une
  auto-déclaration de l'agent. Un agent qui écrit « c'est superbe » sans avoir regardé est le mode d'échec
  numéro un de ce dispositif.

**Le rapport de comparaison** : sur un objet visuel, produire une page HTML côte à côte (référence à gauche,
notre rendu à droite, verdict et round sous chaque paire). C'est ce qui rend la boucle lisible en un coup d'oeil
sans relire les logs.

---

## Branchements

### Dans `/askuser-question-batch`
Le bloc 3 (LA BARRE) devient une **question du batch** dès qu'on ouvre un chantier de production. On ne demande
pas « on y va ? », on fait choisir **contre quoi on se compare et quand on s'arrête**. Voir la section
« La barre à atteindre » de ce skill.

### Dans `/conseil-agents`
- **Phase 0.5** : quand la sortie attendue est un artefact produit, une question porte obligatoirement sur la
  référence à battre.
- **Phase 3** : la boucle de correction s'exécute en gauntlet (fixer + critique aveugle apparié), et sa condition
  d'arrêt devient la barre au lieu du `loop-until-dry` par compteur.

### Avec `/test-and-learn`
Complémentaires, jamais concurrents : `test-and-learn` tranche **quelle route** prendre en mesurant, le gauntlet
porte **une route déjà choisie** au niveau maximum. Si la question est « quelle méthode », ce n'est pas un gauntlet.

## Garde-fous

- **Pas de gauntlet sans référence nommée.** Si Clément n'en donne pas, je la propose dans le batch, je ne
  l'invente pas en silence.
- **Pas de gauntlet sur un brief non validé.** Le batch amont passe avant, toujours.
- **Zéro tiret cadratin** dans tout livrable texte produit par ce pipeline.
- **Rien d'irréversible** (publication, envoi, déploiement) en fin de boucle sans go explicite.
