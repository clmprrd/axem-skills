# -*- coding: utf-8 -*-
"""Verifie qu'un script de reel sonne dryxio.us et respecte les decisions de Clement.

Regles calees le 13/09/2026 sur les 12 transcripts de dryxio.us (192 mots en mediane, de 117 a 271,
11 mots par phrase) et sur les 69 scripts rejetes par Clement.

    python3 verifie-script.py --console console.html        # tous les scripts de la console
    python3 verifie-script.py --fichier script.txt          # un script
    python3 verifie-script.py --dossier tx-dryxio --sans-cta # etalonnage sur les transcripts de reference

Sortie : une ligne JSON par script, {"id", "ok", "violations": [...]}, puis un total. Code 1 si une violation.
"""
import argparse, glob, json, os, re, statistics, sys

BANNIES = [
    (r"follow", "le follow ne se dit jamais dans le script (decision de Clement du 13/09)"),
    (r"b[eê]te comme chou", "expression vieillie"),
    (r"il fallait y penser", "expression vieillie"),
    (r"personne ne (le )?(dit|mentionne|precise|précise|parle)", "commentaire editorial"),
    (r"la nuance", "commentaire editorial"),
    (r"soyons clairs", "commentaire editorial"),
    (r"honn[eê]tet[eé]", "commentaire editorial"),
    (r"concr[eè]tement", "calque de l'anglais, absent chez dryxio.us"),
    (r"\bvoila\b", "accent manquant ou tic de traduction"),
    (r"du moment que", "condition de follow"),
    (r"—", "tiret cadratin"),
    (r"ne bascule pas tout", "conseil de moderation"),
]
CTA = re.compile(r"commente\s+[«\"]?\s*[A-ZÉÈÀÇ0-9][\wÉÈÀÇéèàç-]*\s*[»\"]?\s+sous cette vid[ée]o et je te l[e'’]\s*envoie", re.I)


def phrases(t):
    return [p for p in re.split(r"(?<=[.?!])\s+", t.replace("\n", " ")) if p.strip()]


def nombres(t):
    """Nombres ecrits en chiffres, normalises : « 45 000 », « 45,000 » et « 45000 » donnent 45000."""
    t = re.sub(r"(?<=\d)[\s\u202f\u00a0,.](?=\d{3}\b)", "", t)
    return set(re.findall(r"\d+(?:[.,]\d+)?", t))


def verifier(txt, cta=True, source=None):
    """Rend (violations, avertissements). La longueur de phrase n'est qu'un avertissement : mesuree le
    13/09, elle ne separe pas dryxio.us des scripts rejetes (medianes 6 a 22 contre 8,5 a 22,5), parce que
    la ponctuation de whisper varie d'une video a l'autre."""
    v, w = [], []
    mots = len(txt.split())
    if not 110 <= mots <= 280:
        v.append(f"longueur {mots} mots, attendu 110 a 280")
    lp = [len(p.split()) for p in phrases(txt)]
    if lp and statistics.median(lp) > 17:
        w.append(f"phrases longues, mediane {statistics.median(lp)} mots (dryxio.us : 11)")
    if not re.search(r"[éèàùçêâîôû]", txt):
        v.append("aucun accent")
    for motif, raison in BANNIES:
        if cta is False and motif in ("follow", "du moment que"):
            continue
        m = re.search(motif, txt, re.I)
        if m:
            v.append(f"banni « {m.group(0)} » : {raison}")
    grand = re.search(r"(?<!\d )(?<!\d)(?<!plusieurs )(?<!des )\b(vingt|trente|quarante|cinquante|soixante|cent|mille|millions?|milliards?)\b", txt, re.I)
    if grand:
        v.append(f"nombre écrit en lettres « {grand.group(0)} » : l'écrire en chiffres, pour qu'il se vérifie contre la source")
    if source is not None:
        manquants = sorted(nombres(txt) - {n.replace(",", ".") for n in nombres(source)} - {n.replace(".", ",") for n in nombres(source)} - nombres(source))
        if manquants:
            v.append(f"chiffre absent de la source : {', '.join(manquants)} (ne jamais inventer un chiffre)")
    if cta:
        fin = " ".join(phrases(txt)[-2:])
        if not CTA.search(fin):
            v.append("fin attendue : « commente MOT sous cette vidéo et je te l'envoie »")
    return v, w


def main():
    ap = argparse.ArgumentParser()
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--console"); g.add_argument("--fichier"); g.add_argument("--dossier")
    ap.add_argument("--sans-cta", action="store_true")
    ap.add_argument("--source", help="transcript source : tout chiffre du script doit y figurer")
    ap.add_argument("--n", type=int, action="append", help="limiter a ces numeros de la console")
    a = ap.parse_args()
    items = []
    if a.console:
        e = json.loads(re.search(r'id="etat"[^>]*>(.*?)</script>', open(a.console, encoding="utf-8").read(), re.S).group(1))
        items = [(f"n{s['n']}", s["txt"]) for s in e["scripts"] if not a.n or s["n"] in a.n]
    elif a.fichier:
        items = [(os.path.basename(a.fichier), open(a.fichier, encoding="utf-8").read())]
    else:
        items = [(os.path.basename(f), open(f, encoding="utf-8").read()) for f in sorted(glob.glob(os.path.join(a.dossier, "*.txt")))]
    ko = 0
    for i, t in items:
        v, w = verifier(t, cta=not a.sans_cta, source=open(a.source, encoding="utf-8").read() if a.source else None)
        ko += bool(v)
        print(json.dumps({"id": i, "ok": not v, "violations": v, "avertissements": w}, ensure_ascii=False))
    print(json.dumps({"total": len(items), "conformes": len(items) - ko, "en_violation": ko}, ensure_ascii=False))
    sys.exit(1 if ko else 0)


if __name__ == "__main__":
    main()
