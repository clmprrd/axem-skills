#!/usr/bin/env python3
"""Classe des comptes Instagram sur leurs reels, a partir du JSON brut d'apify/instagram-scraper.

Le compteur qui fait foi est videoPlayCount, JAMAIS videoViewCount : les deux existent dans la
sortie de l'acteur et l'ecart va de 2x a 5x. Sur nick_saraev/Da8ZthUPK98 mesure le 09/09/2026 :
videoPlayCount 3 431 373 contre videoViewCount 649 204. Un seuil de 100 000 applique au mauvais
compteur ne selectionne pas les memes videos.

Usage :
  classe-comptes.py brut.json [--seuil 100000] [--sortie DOSSIER]

Accepte soit une liste d'items, soit l'enveloppe {"items": [...]} rendue par get-dataset-items,
soit plusieurs fichiers concatenes.
"""
import argparse, json, statistics, sys, os, csv

def charge(chemins):
    items = []
    for c in chemins:
        with open(c, encoding="utf-8") as f:
            d = json.load(f)
        if isinstance(d, dict):
            d = d.get("items", [])
        items.extend(d)
    return items

def est_reel(it):
    # productType "clips" est le marqueur reel ; type "Video" seul attrape aussi les videos de feed
    return it.get("type") == "Video" and it.get("videoPlayCount") is not None

def main():
    p = argparse.ArgumentParser()
    p.add_argument("brut", nargs="+")
    p.add_argument("--seuil", type=int, default=100000)
    p.add_argument("--sortie", default=".")
    a = p.parse_args()

    items = charge(a.brut)
    reels = [x for x in items if est_reel(x)]
    ignores = len(items) - len(reels)

    par_compte = {}
    for r in reels:
        par_compte.setdefault(r.get("ownerUsername", "?"), []).append(r)

    lignes = []
    for compte, rs in par_compte.items():
        vues = sorted((r["videoPlayCount"] for r in rs), reverse=True)
        lignes.append({
            "compte": compte,
            "reels": len(rs),
            "mediane": int(statistics.median(vues)),
            "max": vues[0],
            "au_dessus_seuil": sum(1 for v in vues if v >= a.seuil),
            "part_seuil": round(100.0 * sum(1 for v in vues if v >= a.seuil) / len(vues), 1),
        })
    lignes.sort(key=lambda x: (-x["au_dessus_seuil"], -x["mediane"]))

    os.makedirs(a.sortie, exist_ok=True)
    chemin_comptes = os.path.join(a.sortie, "classement-comptes.tsv")
    with open(chemin_comptes, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, delimiter="\t")
        w.writerow(["rang", "compte", "reels", "mediane_plays", "max_plays",
                    "reels_au_dessus_seuil", "part_pourcent"])
        for i, l in enumerate(lignes, 1):
            w.writerow([i, l["compte"], l["reels"], l["mediane"], l["max"],
                        l["au_dessus_seuil"], l["part_seuil"]])

    retenus = sorted((r for r in reels if r["videoPlayCount"] >= a.seuil),
                     key=lambda r: -r["videoPlayCount"])
    chemin_reels = os.path.join(a.sortie, "reels-retenus.tsv")
    with open(chemin_reels, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, delimiter="\t")
        w.writerow(["rang", "compte", "shortcode", "plays", "views", "likes",
                    "duree_s", "date", "url"])
        for i, r in enumerate(retenus, 1):
            w.writerow([i, r.get("ownerUsername"), r.get("shortCode"), r.get("videoPlayCount"),
                        r.get("videoViewCount"), r.get("likesCount"),
                        round(r.get("videoDuration") or 0, 1), (r.get("timestamp") or "")[:10],
                        r.get("url") or "https://www.instagram.com/reel/%s/" % r.get("shortCode")])

    print("items lus            : %d" % len(items))
    print("non-reels ignores    : %d" % ignores)
    print("reels analyses       : %d" % len(reels))
    print("comptes              : %d" % len(par_compte))
    print("seuil                : %d plays" % a.seuil)
    print("reels au-dessus      : %d" % len(retenus))
    print("classement comptes   : %s" % chemin_comptes)
    print("reels retenus        : %s" % chemin_reels)

if __name__ == "__main__":
    main()
