#!/usr/bin/env python3
"""Rendu du kit AXEM : une page HTML vers PNG (taille exacte) ou PDF (A4 ou 16:9).

Usage :
  python3 render.py page.html sortie.png --w 1920 --h 1080 [--scale 2] [--transparent] [--selector .zone]
  python3 render.py page.html sortie.pdf --pdf [--format A4 | --w 1920 --h 1080]

Attend que les polices soient chargées (document.fonts.ready) avant de capturer.
"""
import argparse, pathlib, sys
from playwright.sync_api import sync_playwright

p = argparse.ArgumentParser()
p.add_argument("html"); p.add_argument("out")
p.add_argument("--w", type=int, default=1920); p.add_argument("--h", type=int, default=1080)
p.add_argument("--scale", type=float, default=1)
p.add_argument("--transparent", action="store_true")
p.add_argument("--selector")
p.add_argument("--pdf", action="store_true")
p.add_argument("--format")
a = p.parse_args()

page, _, frag = a.html.partition("#")
url = pathlib.Path(page).resolve().as_uri() + ("#" + frag if frag else "")
with sync_playwright() as pw:
    b = pw.chromium.launch()
    pg = b.new_page(viewport={"width": a.w, "height": a.h}, device_scale_factor=a.scale)
    pg.goto(url, wait_until="networkidle")
    pg.evaluate("document.fonts.ready")
    pg.wait_for_timeout(250)
    missing = pg.evaluate("""[...document.fonts].filter(f=>f.status!=='loaded' && f.status!=='unloaded').map(f=>f.family)""")
    if missing:
        print("polices non chargees:", missing, file=sys.stderr)
    if a.pdf:
        kw = {"print_background": True, "prefer_css_page_size": True}
        if a.format: kw["format"] = a.format
        else: kw.update(width=f"{a.w}px", height=f"{a.h}px")
        pg.pdf(path=a.out, **kw)
    elif a.selector:
        pg.locator(a.selector).first.screenshot(path=a.out, omit_background=a.transparent)
    else:
        pg.screenshot(path=a.out, omit_background=a.transparent, full_page=False)
    b.close()
print("ok", a.out)
