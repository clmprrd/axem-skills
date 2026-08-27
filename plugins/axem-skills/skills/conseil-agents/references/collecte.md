# Collecte terrain, routes gratuites verifiees

> 🟡 **26/08/2026 : X est partiellement RETROUVE.** Nitter a bien ete ferme le 24/08 par mise en demeure
> de X Corp, et toutes ses instances sont mortes. Mais l'API interne de X repond en **mode invite**, sans
> compte ni cookie : `x-user` (timeline d'un compte) et `x-tweet` fonctionnent de nouveau.
> **La recherche par mot-cle reste fermee** (404 en invite) : on suit des comptes, on ne cherche plus.
> Ce n'est pas une perte pour l'usage principal, le conseil du 22/08 ayant mesure la recherche X generique
> comme bruitee a 90 % par du spam de formations.


Source de verite des routes de collecte. Toutes ont ete **testees sur la machine de Clement le 22/08/2026**.
Rien ici n'est repris d'une documentation : ce qui est marque OK a repondu, ce qui est marque MORT a echoue.

**Regle absolue** : aucune route payante. Pas d'Apify facture, pas de Bright Data, pas d'API X a 200 dollars.
Si une route echoue, on signale « terrain partiel, route gratuite bloquee » et on degrade. On ne cascade jamais
vers du payant.

## Le module

```bash
~/.claude/scrapling/.venv/bin/python ~/.claude/scrapling/collect.py <commande> [args]
```

Toujours le chemin absolu, jamais relatif : les sous-agents du fan-out ne partagent pas le repertoire courant.
Chaque commande rend du JSON sur la sortie standard.

| Commande | Ce que ca rend | Etat mesure |
|---|---|---|
| ~~`x-search`~~ | ~~Recherche X par mot-cle~~ | 🔴 fermee, 404 en mode invite |
| `x-user <handle>` | Timeline d'un compte X : texte, likes, reposts, reponses, URL | ✅ **retrouve le 26/08**, mode invite |
| `x-tweet <id>` | Un tweet precis, JSON complet | OK, pas de rate-limit observe |
| `reddit "<requete>" --limit 25` | Recherche Reddit : titre, sub, score, commentaires, date, texte | OK, preciser un subreddit pour armer le repli |
| `reddit-sub <subreddit> --limit 25` | Derniers posts d'un subreddit | OK |
| `github "<requete>" --min-stars 500` | Repos avec date de dernier push | OK |
| `github-issues <owner/repo> "<mot>"` | Les issues, la ou se trouve ce que le README tait | OK |
| `instagram <compte>` | Profil public IG : abonnes, bio, posts avec likes et commentaires | OK, intermittent selon les comptes |
| `yt-channel <channel_id>` | 15 dernieres videos d'une chaine, via RSS | OK |
| `bluesky <handle>` | Posts d'un compte Bluesky : texte, likes, reposts, date | OK, mais peu de comptes actifs |
| `bluesky-qui "<nom>"` | Trouver si quelqu'un est sur Bluesky | OK |
| `github-trending [daily\|weekly]` | Repos qui montent, avec les etoiles gagnees SUR LA PERIODE | OK |
| `hn "<requete>" --limit 20` | Hacker News trie par VELOCITE (points par heure) | OK |
| `entreprise "<nom>"` | SIREN, code NAF, effectif, commune, **dirigeants** | OK |
| `bodacc [modification\|creation\|procedure]` | Annonces legales du jour | OK |
| `doctor` | Teste chaque route en direct et liste les routes mortes | A lancer des qu'une collecte revient vide |

## Bluesky n'est pas le substitut de X, et il faut le savoir

Mesure du 26/08 sur sept comptes de reference : **deux seulement sont vraiment actifs**. `anthropic.com` a
reserve son handle sans jamais publier, `karpathy` n'a rien poste depuis mai 2023, `levels.io` depuis
fevrier 2025. Seuls `simonwillison.net` et `vercel.com` publient encore, avec un engagement deux ordres de
grandeur sous celui de X.

**L'ecosysteme n'a pas migre**, il a reserve des noms. Bluesky sert donc a suivre les rares comptes qui y
publient vraiment, rien de plus. **Ne jamais y trier par engagement** : les chiffres ne mesurent pas la
meme chose.

⚠️ Avant d'ajouter un compte a une veille, verifier son ACTIVITE avec `bluesky <handle>` et regarder la date
du premier resultat. Un handle sans post recent est un compte mort, pas une source.

## Detection precoce : regarder la VITESSE, pas le total

Ajoute le 22/08 apres le conseil sur la data. 100 % du reach LinkedIn de Clement vient de POC americains
reperes tot et repris credites : le signal utile n'est donc pas le volume d'engagement mais sa **velocite**,
la vitesse d'accumulation dans les premieres heures. Un post a 70 points en 6 heures vaut bien plus qu'un
post a 120 points en trois jours.

- `hn` trie deja par **points par heure** et le champ `velocite` est la colonne a lire en premier.
- `github-trending` rend `etoiles_periode`, c'est-a-dire les etoiles gagnees **aujourd'hui**. Un repo a
  200 000 etoiles qui en gagne 30 est mort ; un repo a 800 qui en gagne 400 est en train de percer.
  Ne jamais trier sur le total.

Ces deux sources sont les plus **precoces** mesurees : un projet y apparait avant d'etre repris en France.
La fenetre utile pour republier est de 24 a 72 heures apres l'emergence americaine.

## Signal d'intention business, l'angle mort comble le 22/08

Tout le dispositif collectait du CONTENU et zero signal disant qu'une entreprise a un besoin **maintenant**.
Deux sources publiques, gratuites, sans cle :

- `entreprise "<nom>"` qualifie un prospect en un appel. Elle rend aussi les **dirigeants legaux**, ce qui
  n'est pas un detail : sur un dossier reel, elle a revele que l'interlocuteur n'etait pas le decideur et
  qu'il devait en convaincre deux autres, ce que rien dans l'echange ne laissait deviner. Un ecart entre
  l'effectif declare au registre et l'effectif annonce en rendez-vous est lui-meme un signal.
  ⚠️ Ne jamais recopier ici le nom d'un client ou d'un dirigeant : ce fichier part dans le catalogue
  public. L'enseignement de methode se transmet sans les identites, la reciproque est fausse.
- `bodacc modification` liste les changements de dirigeant et de capital du jour. Un nouveau dirigeant ouvre
  une fenetre de prospection d'environ trois mois. `bodacc procedure` liste les procedures collectives, a
  lire comme un filtre anti-mauvais-payeur **avant** d'envoyer un devis.

## Toute sortie est enveloppee, lis le statut avant de conclure

Chaque commande rend un objet, jamais une simple liste :

```json
{
  "fiable": false,
  "statut": {"x": "casse: rate-limite (429)"},
  "n": 0,
  "avertissement": "COLLECTE CASSEE : ce resultat vide ne dit RIEN du sujet cherche...",
  "resultats": []
}
```

**`fiable: false` interdit de conclure quoi que ce soit sur le sujet cherche.** Une route morte et un sujet
dont personne ne parle produisent tous les deux zero resultat : seule cette enveloppe les distingue. C'est le
mode d'echec le plus dangereux du dispositif, parce qu'il ne ressemble pas a une panne. Quand `fiable` est
faux, le rapport dit « terrain partiel, route gratuite bloquee » et la confiance descend.

## Reddit passe par deux routes, dans cet ordre

`api.pullpush.io` d'abord, **Arctic Shift** (`arctic-shift.photon-reddit.com`) en repli. pullpush rend 429 de
facon erratique : ce n'est pas un quota par IP mais une charge serveur globale, donc une requete passe pendant
que la suivante echoue a quinze secondes d'intervalle. Le repli n'est pas un luxe, c'est le chemin nominal une
fois sur deux.

**Contrainte d'Arctic Shift** : son parametre `query` exige d'etre couple a `subreddit` ou `author`, il ne fait
pas de recherche globale. Consequence pratique : **toujours cadrer un subreddit** dans le triage terrain, sinon
le repli ne peut pas jouer et une panne de pullpush devient une panne seche.

## Ce qui est MORT, ne pas retenter

| Route | Pourquoi |
|---|---|
| `old.reddit.com/*.json` et `www.reddit.com/*.json` en anonyme | 403 depuis mai 2026, Reddit protege ses contrats IA. Le DDG-hop du skill `reddit-fetch` est mort sur cette route. |
| Inscription self-service a l'API Reddit gratuite | Fermee depuis fin 2025, passage par ticket manuel. |
| Instagram, recherche par hashtag | Renvoie une page de login. Les profils publics, eux, repondent. |
| `xcancel.com` | Challenge Anubis en preuve de travail, non franchi par StealthyFetcher. |
| `lightbrd.com`, `nitter.space` | Cloudflare, non franchi malgre `solve_cloudflare=True`. |
| `nitter.privacydev.net`, `nitter.poast.org`, `nitter.tiekoetter.com`, `nitter.kavin.rocks` | Mortes ou bloquees. |
| GitHub code search en anonyme | 401. Les recherches repos et issues restent ouvertes. |
| `snscrape` | Mort depuis 2023. |

## Instagram, la route qu'on avait enterree a tort

L'endpoint web d'Instagram repond « useragent mismatch » tant qu'il manque le header **`X-IG-App-ID:
936619743392459`**, la cle publique de son client web. Avec ce header, les profils publics rendent le nombre
d'abonnes, la bio et les derniers posts avec leur engagement (verifie le 22/08 sur un compte a 11,8 millions
d'abonnes). Sans lui, tout echoue et on croit le mur infranchissable.

Deux limites : la recherche par hashtag reste fermee, et Meta renvoie par moments un 400 sur certains comptes,
erreur de schema de leur cote. Le module reessaie une fois puis marque `casse`, jamais `vide`.

## Les trois fragilites a connaitre

**1. nitter.net est un point de defaillance unique.** C'est la seule instance testee qui rend encore des
resultats de recherche X. Toutes les autres sont mortes. Si elle tombe, la recherche X par mot-cle tombe avec
elle, et il ne reste que la lecture d'un tweet dont on connait deja l'identifiant. Ce n'est pas un risque
theorique : c'est arrive a toutes les autres instances en dix-huit mois. Quand `x-search` rend zero resultat
deux fois de suite, lancer `doctor` avant de conclure quoi que ce soit sur le sujet cherche.

**2. Le rate-limit est la contrainte numero un.** nitter.net repond 429 des la quatrieme requete rapide,
pullpush.io fait pareil. Le module espace deja les appels de 5 secondes par hote et reessaie deux fois avec
backoff. Consequence a integrer dans le cadrage : **une collecte X de 6 requetes prend une demi-minute**. Ne
pas lancer trente requetes en esperant qu'elles passent, cadrer les requetes en amont.

**3. Une collecte vide n'est pas une absence de sujet.** C'est le piege qui fabrique de faux verdicts. Si une
route est bloquee, le rapport doit dire « route gratuite bloquee, terrain partiel » et la confiance doit
descendre. Jamais conclure « personne n'en parle » sur la foi d'une collecte qui a echoue techniquement.

## GitHub, la source que Clement veut en premiere classe

Le CLI `gh` est deja installe et authentifie sur sa machine, ce qui donne **5000 requetes par heure** au lieu
des 60 de l'acces anonyme. Le prefere a l'API HTTP brute quand il est disponible.

```bash
gh search repos "claude code skill" --sort stars --limit 20
gh search issues "cloudflare" --repo D4Vinci/Scrapling --limit 10
gh search code "StealthyFetcher"      # exige l'authentification, 401 en anonyme
```

**Filtre de vitalite obligatoire apres tout tri par etoiles.** Un tri `sort:stars` brut a fait remonter en
premiere position, lors du test du 22/08, un repo inconnu affichant 100 000 etoiles : signature classique de
gonflage. Les etoiles ne prouvent rien seules. Verifier systematiquement :

- la date du dernier push (`pushed_at`), un repo sans commit depuis 6 mois est un repo mort ;
- le ratio forks sur etoiles, entre 10 et 25 % indique un usage reel ;
- la cadence des releases et le nombre de contributeurs distincts.

Ce que GitHub apporte que le web ne donne pas : les **issues** disent ce qui casse vraiment et sur quelle
version, les **CHANGELOG** donnent la fraicheur reelle d'un outil, et le **code** prouve qu'une technique
fonctionne au lieu de l'affirmer.

## Scrapling, ce qu'il fait et ce qu'il ne fait pas

Installe dans `~/.claude/scrapling/.venv` (version 0.4.14) et utilise par `collect.py` pour son `Fetcher`,
qui porte une empreinte TLS de navigateur et evite les blocages les plus grossiers.

**Sa promesse principale a echoue au test.** `StealthyFetcher` avec `solve_cloudflare=True` a ete mis en
echec 2 fois sur 2 sur des cibles reelles, et un benchmark tiers le mesure autour de 58 % de reussite pour
29 secondes par tentative. Ne jamais concevoir une route de collecte dont le succes depend de ce bypass.

**Il ne contourne pas une authentification**, ce n'est pas son objet. Le login-wall de X et d'Instagram lui
resiste par construction.

## Pourquoi on ne passe pas par des cookies de compte

Deux raisons, et la premiere suffit.

**La recherche X fonctionne deja sans compte.** L'interet d'un compte serait nul pour le cas d'usage
principal.

**Le droit francais.** Contourner une mesure d'authentification releve de l'acces frauduleux a un systeme de
traitement automatise de donnees, articles 323-1 et 323-3 du code penal, jusqu'a cinq ans et 150 000 euros.
La collecte de donnees publiques non authentifiees est d'un tout autre ordre et reste toleree au cas par cas
par la CNIL. La frontiere est l'authentification, pas le scraping. On reste du bon cote.

S'y ajoute le precedent LinkedIn : une restriction de compte arrive **sans aucun symptome visible**, et se
decouvre des semaines plus tard a la portee qui s'effondre.
