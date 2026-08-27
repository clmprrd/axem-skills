# Gabarits gauntlet loop

## Le prompt d'origine (Matt Shumer, verbatim, EN)

> I want you to build a first-person shooter at the level of the most recent Call of Duty games. It should be
> utterly perfect, visually beautiful, with every single thing done at AAA quality, from textures to physics to
> anything you could think of.
>
> Fan out sub-agents and have sub-agents tackle each one individually so that the game is utterly perfect. You
> should /loop on each item and have a separate sub-agent check it visually to ensure it looks triple A. That
> separate sub-agent should be a really harsh critic, and if it doesn't look triple A, it should keep going.
>
> Don't stop until each sub-agent is utterly wowed with the quality when compared with the actual Call of Duty
> game. It should literally compare them side by side blind and say which one looks better. Do this in ThreeJS.
> /loop until it's utterly perfect. Fan out sub-agents and ultracode.

Découpage : paragraphe 1 = LA TÂCHE · paragraphe 2 = LA MÉTHODE · paragraphe 3 = LA BARRE.

Noter les mots qui portent le travail : `fan out`, `individually`, `a separate sub-agent`, `really harsh critic`,
`keep going`, `side by side blind`, `which one looks better`.

---

## Variante site / landing page

```
LA TÂCHE
Construis <la page> pour <produit>. Le niveau à atteindre est celui de <site de référence réel, URL>.
Chaque dimension compte : typographie, grille, densité d'information, animations, états hover,
responsive mobile, mode sombre, temps de premier rendu.

LA MÉTHODE
Découpe la page en blocs (hero, preuve sociale, features, pricing, FAQ, footer).
Un sous-agent par bloc. Chaque sous-agent a un critique dédié qui screenshote le bloc rendu
et le compare au bloc équivalent de la référence. Le critique est dur : au moindre écart, il renvoie.

LA BARRE
On ne s'arrête pas tant que chaque critique, mis en aveugle devant les deux captures,
ne désigne pas la nôtre comme la meilleure. Produis un rapport HTML côte à côte à chaque round.
```

⚠️ Sur une page de marque, la référence n'est PAS « un beau site » : c'est **la charte réelle du client**.
C'est précisément l'erreur Ketone IQ de la vidéo.

## Variante visuel / infographie LinkedIn

```
LA TÂCHE : reproduis le niveau de <post de référence, capture fournie> sur <notre sujet>.
LA MÉTHODE : un sous-agent par élément (hook, hiérarchie typo, palette, data-ink, respiration),
             un critique par élément qui compare la capture rendue à la référence.
LA BARRE : le critique aveugle préfère la nôtre sur la lisibilité au pouce, pas sur le goût.
```

## Variante deck

```
LA TÂCHE : porte ce deck au niveau de <deck de référence réel>.
LA MÉTHODE : un sous-agent par slide, un critique par slide qui exporte en image et compare.
LA BARRE : le critique aveugle préfère la nôtre, slide par slide. Une slide non gagnée bloque la livraison.
```

## Variante prototype / démo 3D ou interactive

```
LA TÂCHE : construis <l'objet> au niveau de <référence>. Textures, physique, éclairage, son, performance.
LA MÉTHODE : un sous-agent par zone/système, critique visuel dédié, screenshots réels dans le navigateur.
LA BARRE : comparaison aveugle contre les photos/captures de référence fournies, round après round.
```

---

## Ce qui casse un gauntlet, observé

| Symptôme | Cause | Correctif |
|---|---|---|
| Le critique valide au round 2 | Barre en adjectif (« AAA », « pro ») | Nommer un objet réel comparable |
| Le rendu est superbe et hors sujet | Gauntlet lancé en premier prompt | MVP / charte validés d'abord |
| Le critique dit « c'est superbe » sans preuve | Pas de capture réelle | Imposer le screenshot avant le verdict |
| La boucle tourne sans fin | Aucun plafond | Stop à 3 rounds sans progrès sur un morceau, remonter à Clément |
| Un morceau faible passe | Juge global au lieu d'un critique par worker | Appariement 1 pour 1 |
