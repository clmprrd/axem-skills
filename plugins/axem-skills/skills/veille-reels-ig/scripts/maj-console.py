# -*- coding: utf-8 -*-
"""Met a jour la Console Instagram (ex Console Reels Axem) a partir de sa version EN LIGNE.

Depuis le 26/09/2026 la meme page porte aussi les carrousels et les pubs Stories :
  --carrousels LOT.json   lot du skill carrousels-insta, deja rendu par rendu.py
  --pubs pubs.json        liste des visuels de pub ({n, fichier, format, titre, statut})
  --medias DIR            ou ecrire les images allegees ; DIR/files.json donne la carte
                          {chemin publie: fichier source} a passer a `Artifact files`.
Les statuts des carrousels (etat.cstatuts) et des pubs (etat.pstatuts) sont repris de la page
en ligne comme ceux des scripts, jamais ecrases.

Trois choses, dans cet ordre, sans jamais perdre ce que Clement a saisi dans la page :
  1. relit l'etat embarque dans la page publiee (scripts, statuts, posts) ;
  2. fusionne les nouveaux lots de scripts, sans doublon (cle = shortcode du reel source,
     a defaut empreinte du texte) ;
  3. fait monter le statut des videos d'apres les dossiers de tournage
     (~/Documents/videos/n59-...) : rush -> tourne, aroll.mp4 -> monte,
     final-instagram.mp4 -> pret. Un statut ne redescend jamais, et publie ne se pose qu'a la main.

    python3 maj-console.py --live live.html --out console.html [--lot SCRIPTS.md|lot.json ...]
                           [--codes codes.json] [--racines ~/Documents/videos] [--date AAAA-MM-JJ]

Le fichier --live est la page telle que la rend `Artifact action=read` (sauvegardee sur disque).
Le fichier --out se publie ensuite avec `Artifact file_path=<out> url=<url de la console>`.
Deux passages de suite sur les memes entrees donnent un fichier identique a l'octet.
"""
import argparse, datetime, hashlib, io, json, os, re, sys

try:
    from PIL import Image
except ImportError:  # seulement requis avec --medias
    Image = None

ICI = os.path.dirname(os.path.abspath(__file__))
VAULT = os.path.abspath(os.path.join(ICI, "..", "..", ".."))
RENDUS = os.path.join(VAULT, "09-Marketing-LinkedIn", "carrousels-insta")
GABARIT = os.path.join(os.path.dirname(ICI), "console", "console.template.html")
ORDRE = ["a_tourner", "tourne", "monte", "pret", "publie"]
VIDEO = re.compile(r"\.(mp4|mov|m4v)$", re.I)


def lire(p):
    return io.open(os.path.expanduser(p), encoding="utf-8").read()


def empreinte(txt):
    return hashlib.sha1(re.sub(r"\W+", "", (txt or "").lower()).encode("utf-8")).hexdigest()[:16]


def etat_depuis_live(html):
    m = re.search(r'<script[^>]*id="etat"[^>]*>(.*?)</script>', html, re.S)
    if m and m.group(1).strip() not in ("", "/*ETAT*/"):
        e = json.loads(m.group(1))
        e.setdefault("statuts", {}); e.setdefault("posts", [])
        return e, False
    # Ancienne console (avant le 13/09/2026) : tableaux JS en dur, aucun etat persistant.
    ms = re.search(r"const SCRIPTS = (\[.*?\]);\s*let POSTS", html, re.S)
    if not ms:
        sys.exit("ERREUR : ni bloc etat ni tableau SCRIPTS dans la page en ligne, rien a fusionner.")
    mp = re.search(r"let POSTS = (\[.*?\]);", html, re.S)
    return {"version": 1, "maj": None, "scripts": json.loads(ms.group(1)), "statuts": {},
            "posts": json.loads(mp.group(1)) if mp else []}, True


CHAMPS = ["n", "code", "compte", "lot", "titre", "mot", "src", "leg", "txt", "prompteur", "warn"]


def texte_du_prompteur(p):
    """Le texte lu, tiré de la mise en forme : sans astérisques ni retours à la ligne."""
    return " ".join(p.replace("*", "").split())


def normaliser(s):
    o = {k: s.get(k) for k in CHAMPS}
    o["src"] = int(o["src"] or 0)
    for k in ("code", "compte", "lot", "titre", "mot", "leg", "warn"):
        o[k] = (o[k] or "").strip()
    o["prompteur"] = "\n".join(l.rstrip() for l in (o["prompteur"] or "").strip().splitlines())
    if o["prompteur"]:
        o["txt"] = texte_du_prompteur(o["prompteur"])
    o["txt"] = " ".join((o["txt"] or "").split())
    return {k: v for k, v in o.items() if v not in ("", None) or k in ("n", "src", "txt")}


def lot_markdown(chemin):
    """Format SCRIPTS-FR-VAGUE*.md : '## NN. Titre' puis SOURCE/OUTIL/POUR TOI/LEGENDE/SCRIPT."""
    txt = lire(chemin)
    parts = re.split(r"\n## (\d\d)\. ", txt)
    lot = re.sub(r"^SCRIPTS-FR-", "", os.path.splitext(os.path.basename(chemin))[0]).replace("-", " ").lower()
    out = []
    for k in range(1, len(parts), 2):
        corps = parts[k + 1]
        tete = corps.split("\nSCRIPT :\n")[0]
        champ = lambda nom: (re.search(r"^%s : (.+)$" % nom, tete, re.M) or [None, ""])[1].strip()
        src = champ("SOURCE")
        ms = re.match(r"([\w.]+) / ([\w-]+) / ([\d\s  ]+) lectures", src)
        if not ms:
            continue
        outil, pour = champ("OUTIL"), champ("POUR TOI")
        alertes = [" ".join(m.group(1).split()) for m in
                   re.finditer(r"^(🔴 .+?)(?=\n(?:[A-Z]{4,} :|🔴 )|\Z)", tete, re.S | re.M)]
        warn = " ".join(alertes + (["Pertinence : " + pour] if pour else []))
        g = re.search(r"github\.com/([\w.-]+/[\w.-]+)", outil)
        mot = ("✅ " + g.group(1).rstrip(".")) if outil.startswith("✅") and g else \
              ("⛔ a ne pas recommander" if outil.startswith("⛔") else
               ("⏳ non verifie" if outil else ""))
        script = re.search(r"\nSCRIPT :\n(.*?)(?=\n\n|\Z)", corps, re.S)
        if not script:
            continue
        out.append({"code": ms.group(2), "compte": ms.group(1), "lot": lot,
                    "titre": corps.split("\n", 1)[0].strip(), "mot": mot,
                    "src": int(re.sub(r"\D", "", ms.group(3))), "leg": champ("LEGENDE"),
                    "txt": script.group(1), "warn": warn})
    return out


def lot_json(chemin):
    d = json.loads(lire(chemin))
    d = d if isinstance(d, list) else d.get("scripts", [])
    lot = os.path.splitext(os.path.basename(chemin))[0]
    return [dict(x, lot=x.get("lot") or lot) for x in d]


def statut_dossier(d):
    fichiers = []
    for base, reps, noms in os.walk(d):
        if base[len(d):].count(os.sep) >= 2:
            reps[:] = []
        reps[:] = [r for r in reps if r not in ("node_modules", ".git")]
        fichiers += [os.path.relpath(os.path.join(base, n), d) for n in noms]
    bas = [f.lower() for f in fichiers]
    if any(f.endswith("final-instagram.mp4") or f == os.path.join("renders", "final.mp4") for f in bas):
        return "pret"
    if any(os.path.basename(f) == "aroll.mp4" for f in bas):
        return "monte"
    if any(VIDEO.search(f) and not re.search(r"aroll|final|crop|proxy|preview", f) for f in bas):
        return "tourne"
    return None


def alleger(src, dst, largeur):
    if os.path.exists(dst) and os.path.getmtime(dst) >= os.path.getmtime(src):
        return
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    im = Image.open(src).convert("RGB")
    if im.width > largeur:
        im = im.resize((largeur, round(im.height * largeur / im.width)), Image.LANCZOS)
    im.save(dst, "JPEG", quality=80, optimize=True, progressive=True)


def fusion_carrousels(etat, chemins, medias, carte):
    """Ajoute ou rafraichit les carrousels des lots. Cle = lot/id ; le contenu vient du lot, le statut de la page."""
    par_k = {c["k"]: c for c in etat["carrousels"]}
    ajoutes = []
    for chemin in chemins:
        lot = json.loads(lire(chemin))
        rendu = os.path.join(RENDUS, lot["nom"])
        for c in lot["carrousels"]:
            images = sorted(f for f in os.listdir(os.path.join(rendu, c["id"])) if f.endswith(".jpg")) \
                if os.path.isdir(os.path.join(rendu, c["id"])) else []
            if not images:
                sys.exit("ERREUR : pas de rendu pour %s/%s, lancer rendu.py d'abord" % (lot["nom"], c["id"]))
            k = lot["nom"] + "/" + c["id"]
            rel = ["m/c/%s/%s" % (k, f) for f in images]
            if medias:
                for f, r in zip(images, rel):
                    alleger(os.path.join(rendu, c["id"], f), os.path.join(medias, r), 720)
                    carte[r] = os.path.join(medias, r)
            o = {"k": k, "lot": lot["nom"], "id": c["id"], "theme": c.get("theme", ""), "mot": c.get("mot", ""),
                 "ressource": c.get("ressource", ""), "legende": c.get("legende", ""), "images": rel}
            if k not in par_k:
                ajoutes.append(k)
                etat["carrousels"].append(o)
            else:
                par_k[k].update(o)
    return ajoutes


def fusion_pubs(etat, chemin, medias, carte):
    d = json.loads(lire(chemin))
    base = os.path.dirname(os.path.abspath(os.path.expanduser(chemin)))
    par_n = {p["n"]: p for p in etat["pubs"]}
    ajoutes = []
    for p in d["pubs"]:
        src = os.path.join(base, p["fichier"])
        if not os.path.exists(src):
            sys.exit("ERREUR : visuel de pub introuvable : " + src)
        rel = "m/p/%02d.jpg" % p["n"]
        if medias:
            alleger(src, os.path.join(medias, rel), 540)
            carte[rel] = os.path.join(medias, rel)
        o = {"n": p["n"], "format": p.get("format", ""), "titre": p.get("titre", ""), "image": rel}
        if p["n"] not in par_n:
            ajoutes.append(p["n"])
            etat["pubs"].append(o)
            if p.get("statut") and str(p["n"]) not in etat["pstatuts"]:
                etat["pstatuts"][str(p["n"])] = {"s": p["statut"], "d": d.get("date", ""), "auto": True}
        else:
            par_n[p["n"]].update(o)
    etat["pubs"].sort(key=lambda x: x["n"])
    return ajoutes


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--live", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--lot", action="append", default=[])
    ap.add_argument("--codes", help="migration : {n: {code, compte, lot, titre}} pour la vieille console")
    ap.add_argument("--racines", action="append", default=None)
    ap.add_argument("--date", default=datetime.date.today().isoformat())
    ap.add_argument("--modifs", help='{"retirer": [n, ...], "remplacer": {"n": {"txt": ..., "titre": ..., "leg": ...}}}')
    ap.add_argument("--gabarit", default=GABARIT)
    ap.add_argument("--carrousels", action="append", default=[])
    ap.add_argument("--pubs")
    ap.add_argument("--medias")
    a = ap.parse_args()
    racines = a.racines or ["~/Documents/videos"]

    etat, ancien = etat_depuis_live(lire(a.live))
    avant = json.dumps(etat, sort_keys=True, ensure_ascii=False)
    if a.codes:
        codes = json.loads(lire(a.codes))
        for s in etat["scripts"]:
            c = codes.get(str(s["n"]))
            if c:
                for k in ("code", "compte", "lot", "titre"):
                    if c.get(k) and not s.get(k):
                        s[k] = c[k]
    # Normaliser APRES l'ajout des codes : l'ordre des champs doit etre le meme a chaque passage,
    # sinon deux passages identiques ne rendent pas le meme fichier.
    etat["scripts"] = [normaliser(s) for s in etat["scripts"]]

    # Retraits et reecritures decides par Clement. Un script retire garde une trace (code et
    # empreinte du texte) : aucun lot ne peut le faire revenir, et son numero n'est jamais reutilise.
    etat.setdefault("retires", [])
    retires_ici, remplaces = [], []
    if a.modifs:
        mod = json.loads(lire(a.modifs))
        for n in mod.get("retirer", []):
            s = next((x for x in etat["scripts"] if x["n"] == int(n)), None)
            if s:
                etat["scripts"].remove(s)
                etat["retires"].append({"n": s["n"], "code": s.get("code", ""), "empreinte": empreinte(s["txt"]), "d": a.date})
                etat["statuts"].pop(str(s["n"]), None)
                retires_ici.append(s["n"])
        for n, champs in mod.get("remplacer", {}).items():
            k = next((i for i, x in enumerate(etat["scripts"]) if x["n"] == int(n)), None)
            if k is None:
                sys.exit("ERREUR : script n%s a remplacer introuvable" % n)
            nouveau = normaliser(dict(etat["scripts"][k], **{c: v for c, v in champs.items() if c in CHAMPS and c != "n"}))
            if nouveau != etat["scripts"][k]:
                etat["scripts"][k] = nouveau
                remplaces.append(int(n))

    vus_code = {s["code"] for s in etat["scripts"] if s.get("code")} | {r["code"] for r in etat["retires"] if r.get("code")}
    vus_txt = {empreinte(s["txt"]) for s in etat["scripts"]} | {r["empreinte"] for r in etat["retires"]}
    prochain = max([s["n"] for s in etat["scripts"]] + [r["n"] for r in etat["retires"]] + [0]) + 1
    ajoutes, doublons = [], []
    for chemin in a.lot:
        items = lot_markdown(chemin) if chemin.lower().endswith(".md") else lot_json(chemin)
        for it in items:
            it = normaliser(dict(it, n=0))
            cle_txt = empreinte(it["txt"])
            if (it.get("code") and it["code"] in vus_code) or cle_txt in vus_txt:
                doublons.append(it.get("code") or cle_txt); continue
            it["n"] = prochain; prochain += 1
            etat["scripts"].append(it); ajoutes.append(it["n"])
            vus_txt.add(cle_txt)
            if it.get("code"):
                vus_code.add(it["code"])

    par_n = {s["n"] for s in etat["scripts"]}
    montes, orphelins = [], []
    for r in racines:
        r = os.path.expanduser(r)
        if not os.path.isdir(r):
            continue
        for nom in sorted(os.listdir(r)):
            m = re.match(r"n(\d+)(?:$|[-_ .])", nom)
            d = os.path.join(r, nom)
            if not m or not os.path.isdir(d):
                continue
            n = int(m.group(1))
            if n not in par_n:
                orphelins.append(nom); continue
            trouve = statut_dossier(d)
            if not trouve:
                continue
            actuel = etat["statuts"].get(str(n), {}).get("s", "a_tourner")
            if actuel != "publie" and ORDRE.index(trouve) > ORDRE.index(actuel):
                etat["statuts"][str(n)] = {"s": trouve, "d": a.date, "auto": True,
                                           "dossier": d.replace(os.path.expanduser("~"), "~")}
                montes.append((n, actuel, trouve))

    for cle, defaut in (("carrousels", []), ("pubs", []), ("cstatuts", {}), ("pstatuts", {})):
        etat.setdefault(cle, defaut)
    carte = {}
    if a.medias and Image is None:
        sys.exit("ERREUR : Pillow manquant, requis pour --medias")
    c_ajoutes = fusion_carrousels(etat, a.carrousels, a.medias, carte)
    p_ajoutes = fusion_pubs(etat, a.pubs, a.medias, carte) if a.pubs else []
    if a.medias:
        io.open(os.path.join(a.medias, "files.json"), "w", encoding="utf-8").write(
            json.dumps(dict(sorted(carte.items())), ensure_ascii=False, indent=0))

    etat["statuts"] = {k: etat["statuts"][k] for k in sorted(etat["statuts"], key=int)}
    etat["version"] = 1
    if ajoutes or montes or ancien or retires_ici or remplaces or c_ajoutes or p_ajoutes or json.dumps(etat, sort_keys=True, ensure_ascii=False) != avant:
        etat["maj"] = a.date
    doc = lire(a.gabarit)
    if doc.count("/*ETAT*/") != 1:
        sys.exit("ERREUR : le gabarit doit contenir exactement un /*ETAT*/")
    charge = json.dumps(etat, ensure_ascii=False, separators=(",", ":")).replace("<", "\\u003c")
    io.open(os.path.expanduser(a.out), "w", encoding="utf-8").write(doc.replace("/*ETAT*/", charge))

    ids = [s["n"] for s in etat["scripts"]]
    codes_ = [s["code"] for s in etat["scripts"] if s.get("code")]
    print(json.dumps({
        "scripts": len(ids), "ids_uniques": len(set(ids)) == len(ids),
        "codes_uniques": len(set(codes_)) == len(codes_), "sans_code": [s["n"] for s in etat["scripts"] if not s.get("code")],
        "ajoutes": ajoutes, "doublons_ignores": len(doublons), "statuts_montes": montes,
        "dossiers_orphelins": orphelins, "posts": len(etat["posts"]), "statuts": len(etat["statuts"]),
        "migration_ancienne_console": ancien, "retires": retires_ici, "remplaces": remplaces, "maj": etat["maj"],
        "carrousels": len(etat["carrousels"]), "carrousels_ajoutes": c_ajoutes,
        "carrousels_publies": sum(1 for v in etat["cstatuts"].values() if v.get("s") == "publie"),
        "pubs": len(etat["pubs"]), "pubs_ajoutees": p_ajoutes, "medias": len(carte)}, ensure_ascii=False))


if __name__ == "__main__":
    main()
