#!/usr/bin/env python3
"""Habille un devis ou une facture sortis de Qonto : ajoute une couverture AXEM en tête du PDF.

Usage :
  python3 habiller_devis.py devis-qonto.pdf sortie.pdf --client "Nom" --objet "Objet" --ref "D-2026-003" [--interlocuteur "Prénom Nom"] [--date "25 septembre 2026"]

Le contenu chiffré du devis n'est jamais touché : les pages Qonto sont recopiées telles quelles.
"""
import argparse, datetime, json, pathlib, subprocess, sys, tempfile
from pypdf import PdfReader, PdfWriter

SRC = pathlib.Path(__file__).resolve().parent
MOIS = "janvier février mars avril mai juin juillet août septembre octobre novembre décembre".split()
a = argparse.ArgumentParser()
a.add_argument("devis"); a.add_argument("out")
a.add_argument("--client", required=True); a.add_argument("--objet", required=True); a.add_argument("--ref", required=True)
a.add_argument("--interlocuteur", default=""); a.add_argument("--date"); a.add_argument("--validite", default="30 jours")
x = a.parse_args()
t = datetime.date.today()
data = {"mode": "devis", "reference": x.ref, "date": x.date or f"{t.day} {MOIS[t.month-1]} {t.year}", "validite": x.validite,
        "client": x.client, "interlocuteur": x.interlocuteur or x.client, "objet": x.objet,
        "contexte": [], "objectifs": [], "etapes": [], "lignes": [], "tva": 20, "paiement": "", "conditions": []}
with tempfile.TemporaryDirectory() as d:
    j = pathlib.Path(d) / "c.json"; j.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    cover = pathlib.Path(d) / "cover.pdf"
    subprocess.run([sys.executable, str(SRC / "gen_proposition.py"), str(j), str(cover)], check=True)
    w = PdfWriter()
    for src in (cover, x.devis):
        for pg in PdfReader(str(src)).pages: w.add_page(pg)
    w.write(x.out)
print("ok", x.out)
