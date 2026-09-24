---
name: veille-reels-ig
description: Repere les comptes Instagram dont les reels depassent 100 000 lectures, les classe, transcrit les meilleurs et rend des scripts francais au format mesure de dryxio.us. A utiliser quand Clement veut de nouvelles idees de reels, ajouter des comptes a surveiller, ou refaire tourner le classement.
---

# Veille reels Instagram, et adaptation francaise

Ce skill fait la moitie amont de la chaine : **trouver quoi dire**. Il s'arrete au script francais.
La moitie aval, **fabriquer la video**, appartient a `copie-reel-ang-fr` et aux skills `reel-*`
d'Alexis. Ne pas les reimplementer ici.

Invoquer `unlazy` avant de commencer, et ecrire les gates dans
`GATES-veille-ig-<date>.md` (nom unique : un `GATES.md` nu se fait ecraser par les autres
sessions du meme repertoire).

## Le piege a connaitre avant tout le reste : il y a DEUX compteurs de vues

La sortie de l'acteur Apify contient `videoPlayCount` **et** `videoViewCount`. L'ecart va de 2x
a 5x. Mesure du 09/09/2026 sur `nick_saraev/Da8ZthUPK98` : **3 431 373** plays contre **649 204**
views. Un seuil de 100 000 applique au mauvais compteur ne selectionne pas les memes videos.

**Le compteur qui fait foi ici est `videoPlayCount`**, parce que c'est celui qui reproduit les
chiffres deja etablis dans le vault (dryxio.us plafonne a 162 708, `nick_saraev` a 32 reels
au-dessus de 100 000, exactement ce qu'annonce `FORMAT-DRYXIO.md`). `classe-comptes.py` l'impose,
ne pas le contourner.

Deuxieme piege, du meme ordre : **une legende n'est pas une cle.** dryxio.us reutilise ses moules,
« Ça risque de tout changer pour ... avec Claude 😳 » existe sur au moins deux posts avec des
scores tres differents. Identifier un reel par son `shortCode`, jamais par sa legende.

## Phase 1 — Le perimetre des comptes

Source de verite : `09-Marketing-LinkedIn/comptes-reference-ig/COMPTES.md` (15 comptes envoyes
par Alexis en DM). Pour en ajouter, les ecrire la, pas dans ce skill.

Le classement du 09/09/2026 sur 418 reels, a garder en tete comme reference de comparaison :

| Compte | reels | mediane plays | reels > 100k | part |
|---|---|---|---|---|
| `nick_saraev` | 40 | 176 136 | 32 | 80 % |
| `0xloucash` | 38 | 105 148 | 19 | 50 % |
| `liamjohnston.ai` | 31 | 23 866 | 10 | 32 % |
| `algorithmswithpeter` | 40 | 29 968 | 5 | 13 % |
| `theopenstack` | 38 | 29 896 | 5 | 13 % |
| `tristan_vncnt` | 34 | 25 635 | 5 | 15 % |
| `dryxio.us` | 39 | 24 765 | 4 | 10 % |

Un compte qui n'apparait pas dans un classement n'est pas forcement vide : `gabrielsamp.ia`
disparait parce qu'il ne publie pas de reels, seulement des images. Le dire, ne pas l'omettre.

## Phase 2 — La collecte

Acteur : **`apify/instagram-scraper`**, id `shu8hvrXbJbY3Eb9W`, verifie non deprecie le
09/09/2026. Facturation a l'evenement, **0,0027 USD par resultat au palier gratuit** : une passe
de 40 reels sur 15 comptes coute environ 1,60 USD. Le dire a Clement avant une grosse passe.

```
call-actor apify/instagram-scraper
  input : {"directUrls": ["https://www.instagram.com/<compte>/"],
           "resultsType": "posts", "resultsLimit": 40, "addParentData": false}
```

Puis `get-dataset-items` avec `fields="ownerUsername,shortCode,type,productType,videoPlayCount,videoViewCount,likesCount,commentsCount,videoDuration,timestamp,caption,url"`.
Projeter les champs est obligatoire : la sortie brute fait 81 colonnes et sature le contexte.

**Repli quand l'instance Apify primaire est au plafond mensuel** et renvoie « Monthly usage hard limit exceeded » : basculer
sur la seconde instance MCP Apify configuree sur le poste. C'est arrive le 07/09/2026 en pleine
collecte, et c'est le mode de panne le plus probable de ce skill.

Ecrire le JSON brut dans le dossier de travail avant toute analyse. Il fait foi, et il permet de
rejouer le classement sans repayer la collecte.

## Phase 3 — Le classement

```
scripts/classe-comptes.py brut.json --seuil 100000 --sortie DOSSIER
```

Rend `classement-comptes.tsv` (un compte par ligne, trie sur le nombre de reels au-dessus du
seuil) et `reels-retenus.tsv` (un reel par ligne, trie sur les plays). Le script ignore les
carrousels et les images, et le dit dans son recapitulatif.

## Phase 3 bis — Le filtre de pertinence, AVANT de transcrire

Appris a la premiere vraie passe, le 09/09/2026, et ca a coute 9 minutes de calcul pour rien.

**Le seuil de 100 000 lectures selectionne des comptes qui marchent, jamais des comptes qui
parlent du sujet de Clement.** `tristan_vncnt` est remonte septieme du classement avec 5 reels
au-dessus du seuil : il fait du developpement personnel, pas de l'IA, et son meilleur contenu dure
258 secondes, donc hors format reel. Ses 5 transcripts ont ete ecartes apres coup.

Donc : ouvrir 2 legendes et 1 transcript par compte AVANT de lancer la transcription du lot, et
ecarter les comptes hors sujet a ce moment-la. C'est une lecture humaine, aucun script ne la fait.

Marquer ensuite chaque script retenu d'une ligne de pertinence, pour que Clement voie d'un coup
d'oeil ce qui est dans son sujet et ce qui est a la marge, au lieu de le decouvrir en tournant.

## Phase 4 — La transcription, en local et gratuite

```
scripts/transcris-reels.sh reels-retenus.tsv DOSSIER_TX en 30
```

`yt-dlp` puis `ffmpeg` puis `whisper-cli` avec `ggml-large-v3-turbo`. Aucun service tiers, aucun
cout. Mesure du 09/09/2026 : **106 secondes pour un reel de 61 secondes**, donc a peu pres
55 minutes pour 30 reels. Annoncer ce budget avant de lancer, ne pas laisser Clement attendre
sans savoir.

🔴 **Le code de langue est obligatoire.** Sans `-l`, whisper **traduit** au lieu de transcrire :
le 07/09/2026 les 12 transcriptions de dryxio.us sont revenues en anglais et ont du etre
refaites. `en` pour les comptes americains, `fr` pour les comptes francais.

🔴 **Whisper deforme les noms propres, systematiquement.** Il entend « cloud code » pour Claude
Code, « cloud skills » pour les skills Claude, « Market Down » pour MarkItDown, et il a rendu le
meme outil NVIDIA en « Skillspector » chez un createur et « Skill Spectre » chez un autre. Deux
consequences : corriger Claude partout dans les scripts, et porter sur chaque script une ligne
`OUTIL` marquee a confirmer. Prononcer un nom de depot faux face camera est le pire defaut
possible sur ce format.

Un transcript court n'est pas forcement rate. Le 07/09, trois transcriptions de `jackroberts` ont
ete marquees douteuses sous un seuil de 80 mots : c'etaient de vrais scripts courts de 66 a
79 mots. Verifier en lisant avant de rejeter.

## Phase 5 : l'adaptation française, au format dryxio.us

**Refondue le 13/09/2026, après le rejet des 69 premiers scripts par Clément.** Le conseil d'agents a établi
la cause : pas la traduction, l'improvisation. L'agent inventait des chiffres (« quatre-vingts euros par
mois », absent de toute source) et commentait (« personne ne le dit ») au lieu de suivre un gabarit.
Références à relire, jamais de mémoire : `09-Marketing-LinkedIn/skill-veille-reels-ig/refonte-dryxio-2026-09-13/`
`PATTERN-DRYXIO.md` (mesuré sur ses 12 transcripts) et `VERDICT-CONSEIL.md`.

**Le gabarit fermé, dans cet ordre, sans marge d'improvisation :**

1. **Les faits.** Extraire du transcript source uniquement les faits, dans leur ordre : nom de l'outil,
   chiffres, étapes, bénéfices. Aucun chiffre, prix ou nom absent de la source. Les chiffres restent ceux
   de la source, dits comme tels.
2. **Le sous-genre, jamais les deux.** OUTIL : accroche menace, capacité ou nouveauté ; nom de l'outil tôt
   (« Ça s'appelle… ») ; un seul chiffre de preuve ; installation dite triviale si la source la donne.
   MÉTHODE : « Qu'est-ce qui se passe quand tu demandes à ChatGPT de… ? J'ai testé. » puis D'abord,
   Ensuite, et voilà l'astuce.
3. **L'accroche** se pioche dans les cinq accroches réelles du PATTERN. Jamais la traduction de la
   première phrase américaine.
4. **Le corps parle.** Phrases courtes et fragments (« Mais attends. »), le « tu » en tête de phrase,
   « Alors » et « Donc » pour conclure, un chiffre accolé à une durée quand la source le permet, les
   ordinaux (« Le premier, c'est… ») pour une liste homogène de 4 éléments au plus. Deux relances au plus.
5. **Jamais** : commentaire éditorial, morale, « personne ne le dit », expression vieillie, nombre écrit en
   lettres, anglicisme traduit quand dryxio.us le garde (skill, prompt, scraper, leads).
6. **Fin fixe** : « Commente MOT sous cette vidéo et je te l'envoie. » Le follow n'est JAMAIS dit dans le
   script, décision de Clément du 13/09/2026, écart assumé : dryxio.us le dit dans 11 vidéos sur 12. Le
   follow se demande ensuite dans le message automatique.
7. **Contrôle, bloquant** : `python3 ~/.claude/skills/veille-reels-ig/scripts/verifie-script.py --fichier
   <script> --source <transcript source>` doit rendre `ok`. Étalonné le 13/09 : 12 transcripts dryxio.us
   sur 12 passent, 69 anciens scripts sur 69 échouent. Puis un critique aveugle Sonnet reçoit le script et
   un vrai transcript dryxio.us du même sous-genre, dernière phrase retirée des deux côtés, sans savoir
   lequel est lequel. Trois tours au plus.
8. **La mise en page téléprompteur, obligatoire** : chaque script porte un champ `prompteur` en plus de
   `txt`. Une ligne = un souffle (3 à 9 mots), une ligne vide = une pause entre les temps (4 à 6 blocs),
   `*mot*` = le mot à appuyer, une ligne sur deux environ ; la phrase de fin seule dans le dernier bloc.
   Mêmes mots exactement que le script, rien de réécrit. Règles complètes :
   `refonte-dryxio-2026-09-13/SPEC-PROMPTEUR.md`. Sans ce champ, la console affiche un pavé coupé au
   hasard : n71 et n72, ajoutés par le passage du lundi 14/09, sont arrivés ainsi.

**Tri avant d'écrire.** Jeter les sujets pour développeurs purs et les faits invérifiables. Refondre en un
seul outil les listes fourre-tout ; une liste reste permise si ses éléments partagent un même thème.

**La légende**, une phrase d'environ 56 caractères et un emoji : « Ça risque de tout changer pour
[BÉNÉFICE] 😳 » ou « C'est [ADJECTIF FORT] 😳 ». Aucun hashtag, aucun appel à commenter.

Écrire les scripts dans `09-Marketing-LinkedIn/`, puis republier la console (phase 7).

## Phase 6 — Le passage de relais

Le script francais part ensuite dans `copie-reel-ang-fr`, qui orchestre le clonage : il appelle
`reel-clone-transcript` puis `reel-clone-anim`, et rend le panneau du haut. Le rush selfie de
Clement passe par `reel-insta` et `reel-montage`. Ces skills sont servis en plugin, il n'y a pas
de SKILL.md sur le disque : les invoquer, ne pas supposer leur contenu.


## Phase 7 : la console de tournage se met a jour, a chaque passage

La console est la page ou Clement lit ses scripts au teleprompteur et suit chaque video :
https://claude.ai/code/artifact/ea20780b-cb5a-44af-bc24-0c295f1d1c0d

**Quelle console ?** Si le fichier `~/.claude/skills/veille-reels-ig/console/URL` existe, son
contenu (une URL `claude.ai/code/artifact/...`) remplace l'URL ci-dessus partout. C'est ainsi
qu'une autre personne, Alexis ou un collegue, utilise le skill : la console de Clement est privee
et ne se lit que depuis son compte. **Premiere fois sur un autre compte** : lancer
`maj-console.py --live <fichier vide> --out console.html` avec un fichier vide contenant
`<script type="application/json" id="etat">{"version":1,"maj":"","scripts":[],"statuts":{},"posts":{},"retires":[]}</script>`,
publier `console.html` par Artifact (nouvelle URL, `capabilities: {artifact: {}}` pour que la page
s'enregistre), puis ecrire cette URL dans le fichier `console/URL`. Teste le 23/09/2026 : la
fusion rend une console vide valide (0 script, identifiants uniques).


**Cette phase n'est pas facultative.** Avant le 13/09/2026 le skill s'arretait aux fichiers du
vault, et la console restait figee : les 20 scripts de la vague 2 y ont ete recopies a la main,
deux fois. Un passage de veille qui ne republie pas la console est un passage a moitie fait.

**Trois appels, dans cet ordre :**

1. `Artifact action=read url=<console>`. Le resultat sauvegarde la page complete dans un fichier et
   donne son chemin. **C'est elle qui fait foi**, jamais un fichier local : elle porte les statuts
   et les posts que Clement a saisis depuis la page.
2. ```
   python3 ~/.claude/skills/veille-reels-ig/scripts/maj-console.py \
     --live <fichier lu a l'etape 1> \
     --lot <SCRIPTS-FR-xxx.md ou lot.json> [--lot ...] \
     --out ~/.claude/skills/veille-reels-ig/console/console.html
   ```
3. `Artifact file_path=~/.claude/skills/veille-reels-ig/console/console.html url=<console>`, sans
   passer `capabilities` : la declaration `artifact` qui permet a la page de s'enregistrer est
   reportee telle quelle. Si la publication est refusee pour conflit, Clement a modifie la page
   entre-temps : refaire les etapes 1 et 2, jamais `force`.

Le script rend une ligne JSON : `ajoutes`, `doublons_ignores`, `statuts_montes`,
`dossiers_orphelins`, `sans_code`. Ces chiffres vont tels quels dans le rapport.

**Format d'un lot.** Soit le markdown des vagues (`## NN. Titre`, puis `SOURCE : compte / shortcode /
N lectures`, `OUTIL`, `POUR TOI`, `LEGENDE`, `SCRIPT :`), soit un JSON
`[{code, compte, src, leg, txt, prompteur, titre, mot, warn, lot}]` (le JSON est préférable : le
markdown ne porte pas le champ `prompteur` de la phase 5). **Le shortcode est la cle anti-doublon** :
un reel deja present n'est jamais rajoute. Sans shortcode, le dedoublonnage ne se fait que sur le
texte, et une reecriture du meme reel passerait.

**Ne pas retranscrire ce qui est deja dans la console.** Avant la phase 4, lire les shortcodes
presents dans le fichier de l'etape 1 et les retirer du lot a transcrire :
```
python3 -c "import re,json,sys;e=json.loads(re.search(r'id=\"etat\"[^>]*>(.*?)</script>',open(sys.argv[1]).read(),re.S).group(1));print('\n'.join(s['code'] for s in e['scripts'] if s.get('code')))" <fichier lu>
```

**Le suivi des videos.** Chaque script a un statut : a tourner, tourne, monte, pret, publie. Les
trois du milieu montent tout seuls a chaque passage du script, d'apres les dossiers
`~/Documents/videos/n<numero>-<slug>/` :

| Ce qu'il y a dans le dossier | Statut |
| --- | --- |
| une video qui n'est ni `aroll` ni `final` (le rush) | tourne |
| `aroll.mp4` ou `assets/aroll.mp4` | monte |
| `final-instagram.mp4` ou `renders/final.mp4` | pret |

Creer le dossier au bon nom avec
`python ~/.claude/skills/reel-insta/scripts/nouveau_projet.py n59-prospection --dossier ~/Documents/videos`.
Un statut ne redescend jamais tout seul, et « publie » ne se pose qu'a la main dans la page (ou en
ajoutant le post dans l'onglet Suivi). Un dossier dont le numero n'existe pas remonte dans
`dossiers_orphelins` : le signaler, ne rien inventer.

**Retirer ou reecrire un script** sur decision de Clement : `--modifs modifs.json` avec
`{"retirer": [50], "remplacer": {"44": {"txt": "...", "titre": "..."}}}`. Un script retire garde une
trace dans `retires` (numero, shortcode, empreinte du texte) : aucun lot ne peut le faire revenir, et
son numero n'est jamais reattribue. Premier usage le 13/09/2026 : n50 retire, n44 reecrit sans
l'echeance perimee.

**Le passage automatique.** La tache programmee `veille-reels-ig-lundi` (lundi 7h30) deroule ce skill
en entier sans Clement, phase 7 comprise. Si l'outil `Artifact` manque dans sa session ou si la
publication echoue, elle garde la console fusionnee et depose une notification de niveau action.

**Mettre seulement les statuts a jour**, apres un montage par exemple : les trois memes appels, sans
`--lot`.

**Deux defauts connus dans la console, a ne pas prendre pour des bugs du script.** Les scripts n44
(PLAN) et n50 (NUIT) adaptaient le **meme** reel `DaeHOnXPy2z` de nocodealex : n50 a ete retire le
13/09, `codes_uniques` est revenu a true. Et n18 (REGLES) n'a pas de shortcode retrouvable : ses 199 111 vues
n'apparaissent dans aucun fichier brut.

## Ce que ce skill ne fait pas, et il faut le dire

- **Il ne publie rien sur Instagram.** Aucun skill de publication Instagram n'existe sur ce poste,
  `linkedin-autopost` ne publie que sur LinkedIn.
- **Il ne dit pas ce qui fait un carton.** L'analyse du 07/09 sur `nocodealex` et sur ses propres
  donnees LinkedIn n'a trouve aucune variable de legende qui separe les cartons des flops : le
  CTA « commente MOT » est present dans 24 cartons sur 24 **et** dans 16 flops sur 16. Le seul
  signal tenu a ce jour est la formule dryxio.us de la phase 5, et il est fragile. Ne jamais
  vendre une recette a Clement sur cette base.
- **Il ne tourne pas les videos.** dryxio.us se filme lui-meme, verifie en extrayant des images
  de ses deux meilleurs reels le 08/09/2026. Il n'y a pas de raccourci sans tournage.
- **Il ne cherche pas de nouveaux comptes tout seul.** Le perimetre vient de `COMPTES.md`.
