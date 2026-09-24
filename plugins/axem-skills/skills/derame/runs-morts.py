#!/usr/bin/env python3
"""runs-morts.py : previent Clement par MAIL quand une tache programmee meurt sans rien faire.

POURQUOI : le 01/09/2026, six taches (facturation coaching, facturation de trois clients,
URSSAF + France Travail, depenses partagees, audit tokens, releve LinkedIn) ont heurte la limite
d'usage des la premiere seconde : 17 lignes de journal, zero action. lastRunAt etait frais, rien
ne l'a signale. Estimation du conseil du 13/09 : 700 a 2 000 EUR par mois exposes.

COMMENT : lit les fiches de sessions Claude Desktop (scheduledTaskId) et leur transcript. Un run
est MORT s'il contient le message de limite d'usage, ou s'il n'a fait aucune action en moins
d'une minute. Mail via Mail.app (compte clementpredo4, expediteur different = l'iPhone sonne),
un seul mail par run mort, jamais deux fois le meme.

Tests : python3 runs-morts.py --dry --depuis-heures 336
"""
import json, glob, os, sys, time, subprocess, argparse

B = os.path.expanduser('~/Library/Application Support/Claude/claude-code-sessions')
ETAT = os.path.expanduser('~/Library/Logs/axem/.runs-morts-signales.json')
LOG = os.path.expanduser('~/Library/Logs/axem/runs-morts.log')
LIMITE = ("hit your weekly limit", "hit your limit", "usage limit reached", "You've hit your")

def log(m):
    with open(LOG, 'a') as f: f.write(time.strftime('%Y-%m-%d %H:%M:%S') + '  ' + m + '\n')

def desc(tid):
    p = os.path.expanduser(f'~/.claude/scheduled-tasks/{tid}/SKILL.md')
    try:
        for l in open(p):
            if l.startswith('description:'): return l.split(':', 1)[1].strip().strip('"')[:140]
    except OSError: pass
    return ''

def diagnostic(d):
    tr = glob.glob(os.path.expanduser(f"~/.claude/projects/*/{d.get('cliSessionId')}.jsonl"))
    if not tr: return None
    outils, limite = 0, False
    for l in open(tr[0], errors='ignore'):
        if any(k in l for k in LIMITE) and '"role":"assistant"' in l.replace(' ', ''): limite = True
        try: o = json.loads(l)
        except ValueError: continue
        c = (o.get('message') or {}).get('content')
        if isinstance(c, list): outils += sum(1 for b in c if b.get('type') == 'tool_use')
    duree = (d['lastActivityAt'] - d['createdAt']) / 60000
    if limite: return 'bloquee par la limite d\'usage'
    if outils == 0 and duree < 1: return 'arretee sans aucune action'
    return None

def main():
    a = argparse.ArgumentParser(); a.add_argument('--dry', action='store_true'); a.add_argument('--depuis-heures', type=float, default=6)
    x = a.parse_args()
    maintenant = time.time() * 1000; borne = maintenant - x.depuis_heures * 3600000
    deja = set(json.load(open(ETAT))) if os.path.exists(ETAT) else set()
    morts, sains = [], 0
    for p in glob.glob(B + '/*/*/local_*.json'):
        try: d = json.load(open(p))
        except (ValueError, OSError): continue
        tid = d.get('scheduledTaskId')
        if not tid or d['createdAt'] < borne or maintenant - d['createdAt'] < 10 * 60000: continue
        r = diagnostic(d)
        if r is None: sains += 1; continue
        if d['sessionId'] in deja and not x.dry: continue
        morts.append((d['createdAt'], tid, r, d['sessionId']))
    morts.sort()
    if x.dry:
        print(f"fenetre {x.depuis_heures} h : {sains} runs sains, {len(morts)} morts")
        for c, t, r, s in morts: print('  ', time.strftime('%d/%m %H:%M', time.localtime(c/1000)), t, '->', r)
        return
    if not morts: return
    taches = sorted({t for _, t, _, _ in morts})
    sujet = f"[Axem] {len(taches)} tâche(s) programmée(s) morte(s) sans rien faire : {', '.join(taches)[:120]}"
    lignes = [f"{i}. {t}\n{desc(t) or 'Description absente.'}\nMorte {r}, le {time.strftime('%d/%m à %H:%M', time.localtime(c/1000))}."
              for i, (c, t, r, _) in enumerate(morts, 1)]
    corps = ("Bonjour Clément,\n\n" + f"{len(morts)} run(s) de tâches programmées se sont arrêtés sans rien produire. "
             "Leur date de dernier passage a l'air normale, c'est pour ça que rien d'autre ne te le dit.\n\n"
             + "\n\n".join(lignes) +
             "\n\nCe qu'il faut faire : relance chaque tâche depuis Claude, onglet Code, Tâches programmées, bouton « Lancer maintenant », "
             "ou fais le travail à la main si l'échéance est passée (facturation, URSSAF, France Travail).\n\n"
             "Ce mail part du Mac lui-même, sans Claude.")
    script = ('on run argv\n set wasRunning to application "Mail" is running\n tell application "Mail"\n  set m to make new outgoing message with properties {subject:item 1 of argv, content:item 2 of argv, visible:false}\n'
              '  tell m to make new to recipient at end of to recipients with properties {address:"<EMAIL_MASQUE>"}\n  send m\n end tell\n'
              ' if not wasRunning then\n  repeat 30 times\n   tell application "Mail" to set n to count of messages of outbox\n   if n = 0 then exit repeat\n   delay 1\n  end repeat\n  tell application "Mail" to quit\n end if\nend run')
    rc = subprocess.run(['osascript', '-', sujet, corps], input=script, text=True, capture_output=True).returncode
    json.dump(sorted(deja | {s for _, _, _, s in morts}), open(ETAT, 'w'))
    log(f"mail rc={rc} : {len(morts)} run(s) mort(s) : {', '.join(taches)}")

if __name__ == '__main__': main()
