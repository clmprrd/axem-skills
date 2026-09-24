---
name: instagram-bout-en-bout
description: Porte d'entrée unique du process Instagram de A à Z, de l'idée au reel monté prêt à poster. Enchaîne veille-reels-ig (idées, scripts, console de tournage), le choix du script, le tournage par Clément, puis reel-insta ou copie-reel-ang-fr pour le montage, et rend la légende avec son mot-clé. Déclencher sur « lance le process Instagram », « fais-moi un reel de bout en bout », « process insta complet », /instagram-bout-en-bout.
---

# Instagram de bout en bout

Ce skill n'écrit rien lui-même : il **appelle les skills existants dans l'ordre**, avec l'outil `Skill`,
et ne s'arrête qu'aux deux moments où Clément est indispensable (choisir le script, tourner).
Chaque sous-skill garde ses propres règles : ne jamais imiter un sous-skill à la main, l'invoquer.

Testé le 18/09/2026 : un skill qui en invoque un autre par l'outil `Skill` enchaîne bien les deux,
dans l'ordre, depuis une session neuve (journal `08-Idees-et-veille/_TESTS-TERRAIN.md`).

Noms des sous-skills : dans Claude Code ils peuvent apparaître préfixés (`anthropic-skills:reel-insta`).
Utiliser le nom exact qui figure dans la liste des skills disponibles de la session.

## Étape 1 : l'état de la console

Lire la console de tournage (Artifact `read`) :
https://claude.ai/code/artifact/ea20780b-cb5a-44af-bc24-0c295f1d1c0d
L'état est le JSON de `<script type="application/json" id="etat">`.

**Quelle console ?** Si le fichier `~/.claude/skills/veille-reels-ig/console/URL` existe, son
contenu (une URL `claude.ai/code/artifact/...`) remplace l'URL ci-dessus partout. C'est ainsi
qu'une autre personne, Alexis ou un collegue, utilise le skill : la console de Clement est privee
et ne se lit que depuis son compte. **Premiere fois sur un autre compte** : lancer
`maj-console.py --live <fichier vide> --out console.html` avec un fichier vide contenant
`<script type="application/json" id="etat">{"version":1,"maj":"","scripts":[],"statuts":{},"posts":{},"retires":[]}</script>`,
publier `console.html` par Artifact (nouvelle URL, `capabilities: {artifact: {}}` pour que la page
s'enregistre), puis ecrire cette URL dans le fichier `console/URL`. Teste le 23/09/2026 : la
fusion rend une console vide valide (0 script, identifiants uniques).


- La date de la dernière veille est le champ `maj` de l'état. Si elle date de **plus de 7 jours**, ou si Clément demande des idées neuves :
  invoquer **`veille-reels-ig`** en entier (collecte, classement, transcription, scripts au format
  dryxio.us, mise en page téléprompteur, republication de la console). Sinon, passer.

## Étape 2 : le choix du script (arrêt n° 1)

Un seul `AskUserQuestion` : les **3 meilleurs scripts encore à tourner** (un script est à tourner quand son numéro `n` est absent de `statuts` ; sinon `statuts[n].s` vaut `tourne`, `monte`, `pret` ou `publie`), chacun avec son titre,
son mot-clé et la première ligne de son prompteur. Signaler tout script qui porte un `warn`
(actu datée à revérifier avant de tourner). Option « (Recommandé) » en premier.

## Étape 3 : le tournage (arrêt n° 2)

Clément tourne avec le prompteur de la console. Lui demander **où est le rush** (chemin du fichier
ou du dossier) et, s'il en a une, **la vidéo de référence** d'un autre créateur pour le panneau du haut.
Ne rien lancer tant que le fichier n'existe pas sur le disque : le vérifier avec `ls`.

## Étape 4 : le montage

Selon ce que Clément a fourni :

| Cas | Skill à invoquer |
|---|---|
| Rush seul, animation du haut générée | **`reel-insta`** (il appelle lui-même `reel-montage` puis `reel-insta-anim`) |
| Rush + vidéo source à découper | **`reel-insta`** (il route vers `reel-insta-source`) |
| Reel anglais à cloner en français pour le haut | **`copie-reel-ang-fr`** d'abord, puis **`reel-insta`** pour assembler |

Vérifier que la vidéo finale existe et la montrer (SendUserFile) avant de continuer.

## Étape 5 : la légende et la publication

Rendre la légende (`leg`) et le mot-clé (`mot`) du script tourné, tirés de la console.
Rappel : la fin de la vidéo est « Commente MOT sous cette vidéo et je te l'envoie. », jamais de « follow ».

Les statuts (`tourne`, `monte`, `pret`, `publie`) se posent par les boutons de la console, que la page enregistre elle-même : ce skill ne les écrit pas, pour ne jamais écraser un clic de Clément. Lui rappeler de cliquer.

**Publication par l'API, possible depuis le 24/09/2026** (Composio, toolkit `instagram`, compte
@mister.ia__ connecté sous l'alias `mister-ia`, type Créateur, quota 100 publications par 24 h) :
1. Lire `INSTAGRAM_GET_USER_INFO` (`ig_user_id: me`) et vérifier que c'est bien le compte de Clément
   (Mister IA, ou Clément Predo après renommage). Sinon, s'arrêter.
2. Créer le conteneur avec `INSTAGRAM_POST_IG_USER_MEDIA` : le MP4 final en `video_file` (ou une URL
   HTTPS directe sans redirection), `media_type: REELS`, la légende `leg`, `share_to_feed: true`.
   Un conteneur n'est pas public.
3. **Montrer la légende exacte et le fichier dans un `AskUserQuestion`, et ne publier que sur un oui
   explicite.** Tant qu'aucun reel publié par l'API n'a été vu en ligne par Clément, aucune exception.
4. `INSTAGRAM_POST_IG_USER_MEDIA_PUBLISH` (attente 120 s pour une vidéo), puis `INSTAGRAM_GET_IG_MEDIA`
   pour récupérer le lien et le donner.
Si la connexion n'est plus active, la publication redevient manuelle depuis le téléphone : le dire
en une ligne. Les pubs (Meta Ads) ne se lancent jamais d'ici : une dépense se valide par Clément.

## Ce que ce skill ne fait pas

- Il ne tourne pas à la place de Clément.
- Il ne publie jamais sans le oui explicite de Clément sur la légende et le fichier.
- Il ne réécrit aucun script : la réécriture vit dans la phase 5 de `veille-reels-ig`.
