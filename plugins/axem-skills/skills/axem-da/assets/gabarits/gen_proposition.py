#!/usr/bin/env python3
"""Proposition commerciale AXEM : données JSON vers PDF A4 à la charte.

Usage :
  python3 gen_proposition.py donnees.json sortie.pdf

Le JSON suit la structure de exemple-proposition.json (kit/commercial/).
Les montants viennent du JSON : aucun prix n'est inventé ici, et un devis
qui engage de l'argent se fait valider par Clément avant tout envoi.
"""
import json, pathlib, subprocess, sys, tempfile

SRC = pathlib.Path(__file__).resolve().parent
data = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
out = pathlib.Path(sys.argv[2]).resolve()
html = (SRC / "proposition.html").read_text(encoding="utf-8")
inject = "<script>window.DATA = " + json.dumps(data, ensure_ascii=False) + ";</script>\n<script>\n/* Données"
html = html.replace("<script>\n/* Données", inject, 1)
with tempfile.NamedTemporaryFile("w", suffix=".html", dir=SRC, delete=False, encoding="utf-8") as f:
    f.write(html); tmp = f.name
try:
    subprocess.run([sys.executable, str(SRC / "render.py"), tmp, str(out), "--pdf", "--format", "A4"], check=True)
finally:
    pathlib.Path(tmp).unlink()
