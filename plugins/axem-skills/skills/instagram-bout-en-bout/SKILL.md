---
name: instagram-bout-en-bout
description: Porte d'entrée unique de tout Instagram (reels à lire au prompteur, carrousels façon Olli, pubs Stories en infographie), avec un seul tableau, la Console Instagram. Route vers veille-reels-ig (scripts et prompteur), carrousels-insta (carrousels) et story-coaching (pubs), tient la console à jour et publie un carrousel par jour. Déclencher sur « lance le process Instagram », « console instagram », « fais-moi un reel de bout en bout », « process insta complet », « publie le carrousel du jour », /instagram-bout-en-bout.
---

# Instagram de bout en bout : un skill, un tableau

Demande de Clément du 26/09/2026 : « juste un skill et un tableau unique pour tout le contenu Instagram
qui comporte les carrousels, les ads et les scripts à lire, au lieu d'avoir plusieurs trucs ».

Ce skill est **la seule porte d'entrée**. Il n'écrit rien lui-même : il **appelle les skills spécialisés**
avec l'outil `Skill` et tient à jour **un seul tableau**. Ne jamais imiter un sous-skill à la main,
l'invoquer. Dans Claude Code les noms peuvent être préfixés (`anthropic-skills:reel-insta`) : utiliser le
nom exact qui figure dans la liste des skills de la session.

## Le tableau unique : la Console Instagram

https://claude.ai/artifact/VuqXzrJnN9EwCudg5rUgEQ (même artifact que l'ancienne Console Reels,
`claude.ai/code/artifact/ea20780b-cb5a-44af-bc24-0c295f1d1c0d`). Partagée par lien.

| Onglet | Contenu | Statuts (posés par les boutons de la page) |
|---|---|---|
| Tournage | les scripts à lire au prompteur (reels) | `tourne`, `monte`, `pret`, `publie` dans `statuts` |
| Carrousels | les carrousels à faire glisser, légende, mot-clé, ressource DM | `a_publier`, `publie`, `ecarte` dans `cstatuts` |
| Pubs | les visuels de pub Stories (infographie, jamais face caméra) | `a_tester`, `choisie`, `en_ligne`, `gagnante`, `ecartee` dans `pstatuts` |
| Vidéos, Suivi | les reels montés et les chiffres | inchangés |

La page s'enregistre elle-même (capacité `artifact`). L'état est le JSON de
`<script type="application/json" id="etat">`. **Ne jamais écraser un clic de Clément** : toute mise à jour
part de la version EN LIGNE, relue juste avant.

**Quelle console ?** Si `~/.claude/skills/veille-reels-ig/console/URL` existe, son contenu remplace l'URL
ci-dessus partout (cas d'Alexis ou d'un autre compte ; procédure de première fois dans
`veille-reels-ig/SKILL.md`).

### Mettre à jour la console (scripts, carrousels et pubs en une seule passe)

1. `Artifact action=read` sur l'URL : le fichier sauvegardé est le `--live`.
2. Construire la page :
```bash
cd ~/.claude/skills/veille-reels-ig
python3 scripts/maj-console.py --live <fichier lu> --out $S/console-ig/index.html \
  --carrousels ../carrousels-insta/lots/<lot>.json \
  --pubs "/Users/clementpredo/Axem-IA-Hub/09-Marketing-LinkedIn/skill-veille-reels-ig/story-coaching/pubs-console.json" \
  --medias $S/console-ig [--lot SCRIPTS.md ...]
```
   (`$S` = le scratchpad de la session.) `--carrousels` se répète pour plusieurs lots. Les images partent
   allégées dans `$S/console-ig/m/` (carrousels 720 px, pubs 540 px) et `files.json` en donne la liste.
3. Publier `index.html` avec `url` = la console, `root` = `$S/console-ig`, `files` = les chemins de
   `files.json`. **Ne pas passer `capabilities`** (la déclaration `artifact` est conservée).
4. Vérifier : `Artifact action=list scope=files` doit lister `index.html` + toutes les images.
   Si des images manquent, la page affiche un bandeau « relance la mise à jour » : refaire l'étape 3.

## Les trois contenus, et qui les fabrique

### A. Reels à lire au prompteur → `veille-reels-ig`, puis montage
1. **État** : champ `maj` de la console. Plus de 7 jours, ou idées neuves demandées : invoquer
   **`veille-reels-ig`** en entier (collecte, scripts au format dryxio.us, prompteur, republication).
2. **Choix du script (arrêt n° 1)** : un `AskUserQuestion` avec les 3 meilleurs scripts encore à tourner
   (numéro `n` absent de `statuts`), titre, mot-clé, première ligne du prompteur ; signaler tout `warn`.
3. **Tournage (arrêt n° 2)** : Clément tourne au prompteur (iPhone + DJI, voir `veille-reels-ig`) et
   envoie ses rushs par AirDrop. Vérifier le fichier avec `ls` avant de lancer quoi que ce soit.
4. **Montage** :

| Cas | Skill |
|---|---|
| Rush seul, animation du haut générée | **`reel-insta`** (appelle `reel-montage` puis `reel-insta-anim`) |
| Rush + vidéo source à découper | **`reel-insta`** (route vers `reel-insta-source`) |
| Reel anglais à cloner en français pour le haut | **`copie-reel-ang-fr`**, puis **`reel-insta`** |

   Montrer la vidéo finale (`SendUserFile`).
5. **Légende** : `leg` et `mot` du script, fin de vidéo « Commente MOT sous cette vidéo et je te
   l'envoie. », jamais de « follow ». Publication d'un reel : voir « Publier » plus bas.

### B. Carrousels façon Olli → `carrousels-insta`
Nouveau lot : invoquer **`carrousels-insta`** (écriture, rendu 1080x1350, contrôle visuel des planches).
Puis mettre à jour la console avec `--carrousels`. Les carrousels validés par Clément le 26/09/2026 ne se
retouchent pas (seul l'avatar a changé). La Console Carrousels séparée
(`claude.ai/artifact/N7NDd1BmgXknhBEU3eahsL`) est **remplacée** par l'onglet Carrousels : ne plus la tenir.

### C. Pubs Stories → `story-coaching`
Les visuels vivent dans `09-Marketing-LinkedIn/skill-veille-reels-ig/story-coaching/formats-kolton/`,
listés dans `pubs-console.json` (numéro, fichier, format, titre, statut initial). Nouveau visuel : l'ajouter
à ce JSON puis mettre à jour la console avec `--pubs`. Règles : infographie seulement, jamais « Mister IA »
sur le visuel, jamais mister-ia.com. **Les pubs ne se lancent jamais d'ici** : une dépense Meta Ads se
valide et se paie par Clément.

## Publier

Composio (connecteur claude.ai), toolkit `instagram`, alias `mister-ia`, compte @mister.ia__
(`ig_user_id` 28939155819035694), quota 100 publications par 24 h. Avant tout : `INSTAGRAM_GET_USER_INFO`
et vérifier que c'est bien le compte de Clément, sinon s'arrêter.

### Carrousel du jour, en automatique (demande du 26/09/2026 : « 1 par jour »)
Une tâche programmée, une fois par jour :
1. Lire la console en ligne. Le carrousel du jour est le **premier `a_publier`** dans l'ordre des clés
   (`<lot>/<id>`), celui que la page marque « Prochain ». Aucun : ne rien faire, ne rien déposer.
2. Déjà un carrousel publié aujourd'hui (`cstatuts[k].d` = date du jour) : ne rien faire.
3. Les JPEG 1080x1350 d'origine (pas les versions allégées) doivent être à une **URL HTTPS publique
   directe** : les fichiers d'un artifact ne le sont pas (testé le 26/09 : l'URL rend la page de
   l'application, pas l'image). Hébergement retenu : voir `HEBERGEMENT` ci-dessous.
4. `INSTAGRAM_CREATE_CAROUSEL_CONTAINER` (légende `legende` du carrousel, images dans l'ordre),
   `INSTAGRAM_POST_IG_USER_MEDIA_PUBLISH`, puis `INSTAGRAM_GET_IG_MEDIA` pour le lien.
5. Poser `cstatuts[k] = {s: "publie", d: <date>, auto: true, media: <id>, lien: <permalink>}` dans l'état et
   republier la console (relue juste avant, jamais écrasée).
6. Échec : `notifq.py add --task carrousel-du-jour --level alert --text "..."`. Réussite : rien
   (le digest n'a pas besoin de « tout va bien »).
Clément garde la main : le bouton « Écarté » de chaque carte, dans l'onglet Carrousels sort un carrousel de la file.

HEBERGEMENT : à trancher (voir la note du domaine Instagram). Tant que ce n'est pas branché, la
tâche programmée n'existe pas et un carrousel se publie à la main depuis le téléphone.

### Reel
Conteneur `INSTAGRAM_POST_IG_USER_MEDIA` (`video_file` = le MP4 final, `media_type: REELS`, légende `leg`,
`share_to_feed: true`), puis publication (attente 120 s) et `INSTAGRAM_GET_IG_MEDIA`. Montrer la légende
exacte et le fichier dans un `AskUserQuestion` avant la publication d'un reel : l'automatique ne concerne
que les carrousels.

## Mot-clé en commentaire et DM
Verdict du 26/09/2026 : automatisations natives d'Instagram pour 5 mots-clés, chatmany (Cloudflare,
gratuit) au-delà. Détail et prérequis : `carrousels-insta/SKILL.md`, étape 7. La ressource promise est un
guide Skool (`09-Marketing-LinkedIn/carrousels-insta/guides-skool/`, un par carrousel), lien vers la
communauté https://www.skool.com/ia-automatisations-a-z-7045. Tant que rien n'est branché, envoi à la main.

## Ce que ce skill ne fait pas
- Il ne tourne pas à la place de Clément, ne réécrit aucun script (phase 5 de `veille-reels-ig`).
- Il ne lance aucune pub payante et n'engage aucune dépense.
- Il ne pose jamais les statuts des reels ni des pubs à la place des boutons de la console.
