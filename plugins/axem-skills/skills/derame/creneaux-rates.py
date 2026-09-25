#!/usr/bin/env python3
"""
creneaux-rates.py : detecte un planificateur de taches mort SANS battement (audit du 25/09/2026).

Le planificateur de l'application Claude ecrit, pour chaque tache, `lastScheduledFor` (le creneau
cron qu'il a declenche en dernier) dans scheduled-tasks.json. Si une tache active avait un creneau
il y a plus de TOLERANCE minutes et que `lastScheduledFor` est plus ancien, elle a rate ce creneau.
Plusieurs taches ratees en meme temps = planificateur mort (le symptome du 22/08 : lastRunAt fige).

Avantage sur le battement horaire : zero session Claude (le battement coutait ~470 000 tokens par
passage, 168 passages par semaine), et la detection porte sur ce qui compte, une tache qui aurait
du tourner, au lieu d'un fichier touche toutes les heures.

Usage : creneaux-rates.py [--decalage-min N] [--json]
  --decalage-min N : fait comme si l'heure etait now + N minutes (temoin : doit declencher).
Sortie : code 0 = sain, 2 = planificateur suspect (au moins SEUIL_TACHES taches ratees).
"""
import datetime as dt
import glob
import json
import os
import sys

TOLERANCE_MIN = 45        # le planificateur applique un decalage de quelques minutes
FENETRE_MIN = 6 * 60      # on ne regarde que les creneaux des 6 dernieres heures
SEUIL_TACHES = 3          # une tache isolee qui rate peut etre un cas particulier

FICHIERS = glob.glob(os.path.expanduser(
    "~/Library/Application Support/Claude/claude-code-sessions/*/*/scheduled-tasks.json"))


def champ(expr, lo, hi):
    vals = set()
    for part in expr.split(","):
        pas = 1
        if "/" in part:
            part, p = part.split("/")
            pas = int(p)
        if part in ("*", ""):
            a, b = lo, hi
        elif "-" in part:
            a, b = map(int, part.split("-"))
        else:
            a = int(part)
            b = hi if pas > 1 else a
        vals.update(range(a, b + 1, pas))
    return vals


def correspond(cron, t):
    mi, h, dom, mo, dow = cron.split()
    jours_sem = {d % 7 for d in champ(dow, 0, 7)}
    ok_dom = t.day in champ(dom, 1, 31)
    ok_dow = (t.isoweekday() % 7) in jours_sem
    if dom != "*" and dow != "*":
        jour = ok_dom or ok_dow          # semantique cron standard : OU si les deux sont restreints
    else:
        jour = ok_dom and ok_dow
    return (t.minute in champ(mi, 0, 59) and t.hour in champ(h, 0, 23)
            and t.month in champ(mo, 1, 12) and jour)


def dernier_creneau(cron, borne_haute, borne_basse):
    t = borne_haute.replace(second=0, microsecond=0)
    while t >= borne_basse:
        if correspond(cron, t):
            return t
        t -= dt.timedelta(minutes=1)
    return None


def main():
    decalage = 0
    if "--decalage-min" in sys.argv:
        decalage = int(sys.argv[sys.argv.index("--decalage-min") + 1])
    maintenant = dt.datetime.now().astimezone() + dt.timedelta(minutes=decalage)
    haute = maintenant - dt.timedelta(minutes=TOLERANCE_MIN)
    basse = maintenant - dt.timedelta(minutes=FENETRE_MIN)
    ratees, verifiees = [], 0
    satures = set()
    for f in FICHIERS:
        doc = json.load(open(f))
        sauts = doc.get("recordedSkips", {})
        for t in doc.get("scheduledTasks", []):
            cron = t.get("cronExpression")
            if not t.get("enabled") or not cron or len(cron.split()) != 5:
                continue
            try:
                c = dernier_creneau(cron, haute.replace(tzinfo=None), basse.replace(tzinfo=None))
            except ValueError:
                continue
            if c is None:
                continue
            verifiees += 1
            c = c.replace(tzinfo=maintenant.tzinfo)
            last = t.get("lastScheduledFor")
            last = dt.datetime.fromisoformat(last.replace("Z", "+00:00")) if last else None
            plancher = t.get("missedRunScanFloor")
            plancher = dt.datetime.fromisoformat(plancher.replace("Z", "+00:00")) if plancher else None
            if plancher and c < plancher:
                continue                   # creneau anterieur a la derniere reprogrammation
            if last is not None and last >= c - dt.timedelta(minutes=1):
                continue
            # Un saut enregistre apres le creneau (global_limit, per_task_limit) prouve que le
            # planificateur est VIVANT mais sature : ce n'est pas la panne du 22/08.
            if any(x.get("at", 0) / 1000 >= c.timestamp() for x in sauts.get(t["id"], [])):
                satures.add(t["id"])
                continue
            ratees.append((t["id"], c.strftime("%d/%m %H:%M")))
    suspect = len(ratees) >= SEUIL_TACHES
    res = {"maintenant": maintenant.isoformat(timespec="minutes"), "taches_attendues": verifiees,
           "ratees": len(ratees), "exemples": ratees[:8], "sautees_par_saturation": sorted(satures),
           "planificateur_suspect": suspect}
    print(json.dumps(res, ensure_ascii=False) if "--json" in sys.argv else
          f"{res['maintenant']} : {verifiees} taches avaient un creneau dans les 6 h, {len(ratees)} ratees"
          + (f" ({', '.join(i for i, _ in ratees[:5])})" if ratees else "")
          + (f", {len(satures)} en file d'attente (planificateur sature)" if satures else "")
          + (" -> PLANIFICATEUR SUSPECT" if suspect else " -> sain"))
    sys.exit(2 if suspect else 0)


if __name__ == "__main__":
    main()
