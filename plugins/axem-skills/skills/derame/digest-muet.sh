#!/bin/bash
#
# digest-muet.sh
# Previent Clement par MAIL quand le digest du matin ne vide plus la file d'alertes.
#
# POURQUOI : du 06 au 13/09/2026, digest-matin etait desactive. 364 alertes n'ont jamais ete
# livrees et personne ne l'a vu pendant sept jours. Le digest est le seul consommateur de
# notifs.db : s'il meurt, tout meurt en silence.
#
# POURQUOI HORS DE CLAUDE : une tache programmee qui surveille le digest meurt avec le
# planificateur. Ce script tourne sous launchd et ecrit par Mail.app, compte clementpredo4,
# donc un expediteur DIFFERENT de clem.pred : c'est ce qui fait sonner l'iPhone (tests du
# 13/09/2026 : iMessage vers soi sans notification, mail recu et notifie).
#
# Test sans envoi : DRY=1 bash digest-muet.sh

set -uo pipefail
DB="$HOME/.claude/notifications/notifs.db"
LOG_DIR="$HOME/Library/Logs/axem"; LOG="$LOG_DIR/digest-muet.log"
TEMOIN="$LOG_DIR/.last-alerte-digest-muet"
SEUIL=${SEUIL:-93600}      # 26 h sans livraison
SILENCE=${SILENCE:-86400}  # au plus un mail par 24 h
mkdir -p "$LOG_DIR"
log() { echo "$(date '+%Y-%m-%d %H:%M:%S')  $1" >> "$LOG"; }

# Controle 2, ajoute le 13/09/2026 : runs de taches morts sans rien faire (limite d'usage, zero action).
#
# Interpreteur change le 16/09/2026. Le 15/09 apres 09h30, /usr/bin/python3 est tombe sur
# « You have not agreed to the Xcode license agreements » et n'a plus rien execute : ce controle
# ecrivait « runs-morts.py en erreur » a chaque passage sans jamais nommer les taches mortes.
# Il aurait justement du nommer meet-acces-ouvert et heartbeat-planificateur le 15/09 a 07h39.
# /opt/homebrew/bin/python3 n'a pas cette dependance, et runs-morts.py est du stdlib pur.
PYBIN=/opt/homebrew/bin/python3
[ -x "$PYBIN" ] || PYBIN=$(command -v python3)
"$PYBIN" "$(dirname "$0")/runs-morts.py" >/dev/null 2>&1 || log "runs-morts.py en erreur"

attente=$(sqlite3 "$DB" "select count(*) from digest_items where consumed_at is null;" 2>/dev/null || echo "?")
# consumed_at melange deux formats (« 2026-09-13T14:13:30+00:00 » et « 2026-09-13 14:13:30 ») : le max
# textuel choisit toujours le « T », et un parse rate donnait une alerte fausse. On normalise en SQL.
derniere=$(sqlite3 "$DB" "select max(replace(substr(consumed_at,1,19),'T',' ')) from digest_items where consumed_at is not null;" 2>/dev/null)
[ -z "$derniere" ] && { log "aucune livraison jamais enregistree"; exit 0; }
t_derniere=$(date -j -u -f "%Y-%m-%d %H:%M:%S" "${derniere:0:19}" +%s 2>/dev/null || echo "")
[ -z "$t_derniere" ] && { log "date illisible : $derniere, aucune alerte"; exit 0; }
ecart=$(( $(date +%s) - t_derniere ))

if [ "$attente" = "0" ] || [ "$ecart" -lt "$SEUIL" ]; then
  [ "${DRY:-0}" = "1" ] && echo "OK : derniere livraison il y a $((ecart/3600)) h, $attente en attente, pas d'alerte"
  exit 0
fi
if [ -f "$TEMOIN" ] && [ $(( $(date +%s) - $(stat -f %m "$TEMOIN") )) -lt "$SILENCE" ]; then
  log "digest muet depuis $((ecart/3600)) h, mail deja envoye recemment"; exit 0
fi

sujet="[Axem] Le résumé du matin ne tourne plus : $attente alertes bloquées"
corps="Bonjour Clément,

Le résumé du matin n'a rien livré depuis $((ecart/3600)) heures, et $attente alertes attendent dans la file sans jamais t'arriver.

1. Ce qui se passe
La tâche digest-matin est la seule qui vide cette file. Si elle est désactivée ou si l'application Claude ne tourne plus, plus aucune alerte ne te parvient, sans aucun signe visible.

2. Ce qu'il faut faire
Ouvre Claude, onglet Code, Tâches programmées, et vérifie que « Digest du matin » est activé. Si l'application semble figée, quitte-la et rouvre-la.

Ce mail part du Mac lui-même, sans Claude, au plus une fois par jour."

if [ "${DRY:-0}" = "1" ]; then echo "ALERTE (non envoyee, DRY) : $sujet"; exit 0; fi
osascript - "$sujet" "$corps" <<'OSA' >/dev/null 2>&1
on run argv
  set wasRunning to application "Mail" is running
  tell application "Mail"
    set m to make new outgoing message with properties {subject:item 1 of argv, content:item 2 of argv, visible:false}
    tell m to make new to recipient at end of to recipients with properties {address:"<EMAIL_MASQUE>"}
    send m
  end tell
  if not wasRunning then
    repeat 30 times
      tell application "Mail" to set n to count of messages of outbox
      if n = 0 then exit repeat
      delay 1
    end repeat
    tell application "Mail" to quit
  end if
end run
OSA
rc=$?
touch "$TEMOIN"; log "ALERTE mail envoyee (rc=$rc) : digest muet depuis $((ecart/3600)) h, $attente en attente"
