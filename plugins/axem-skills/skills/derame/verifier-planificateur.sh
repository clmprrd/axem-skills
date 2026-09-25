#!/bin/bash
#
# verifier-planificateur.sh
# Detecte que le PLANIFICATEUR DE TACHES PROGRAMMEES est mort, et le dit par iMessage.
#
# POURQUOI CE SCRIPT EXISTE
# Le 22/08/2026, le Mac a redemarre a 12h55. L'application Claude est repartie normalement
# a 12h56, mais son planificateur n'a plus execute AUCUNE tache pendant six heures. Symptome
# perfide : le champ nextRunAt continuait d'avancer d'horaire en horaire, comme si tout allait
# bien, alors que lastRunAt restait fige et qu'aucun processus de tache n'existait. Cinquante
# taches sont mortes en silence, dont le bilan de 19h qui aurait justement du le signaler.
#
# POURQUOI IL EST DEHORS, ET PAS DANS UNE TACHE PROGRAMMEE
# Meme raison que claude-session-guard.sh : une tache programmee chargee de surveiller le
# planificateur meurt avec lui. Le 22/08, le watchdog de 9h a ecrit « 31/31 presentes, 29 actives
# toutes a l'heure » alors que plus rien ne tournait quatre heures plus tard : il verifiait la
# PRESENCE des taches, pas leur EXECUTION. Un garde-fou doit vivre hors de ce qu'il surveille.
#
# COMMENT CA MARCHE, EN DEUX PIECES
#   1. Une tache programmee « heartbeat-planificateur » ecrit l'heure dans BATTEMENT chaque heure.
#      Elle ne fait que ca. Si le planificateur meurt, elle meurt avec lui et le fichier se fige.
#   2. Ce script, lance par launchd toutes les 30 min, regarde l'age du fichier. Au-dela de
#      SEUIL (2 h 30, soit deux battements manques), il previent Clement.
#
# Ce script ne repare rien : le correctif est de QUITTER ET ROUVRIR l'application Claude, ce qui
# coupe toutes les sessions Claude Code puisqu'elles sont ses filles. C'est un geste humain.
#
# Desinstallation :
#   launchctl bootout gui/$(id -u)/com.axem.verifier-planificateur
#   rm ~/Library/LaunchAgents/com.axem.verifier-planificateur.plist

set -uo pipefail

BATTEMENT="$HOME/.claude/heartbeats/planificateur.txt"
LOG_DIR="$HOME/Library/Logs/axem"
LOG="$LOG_DIR/verifier-planificateur.log"
TEMOIN="$LOG_DIR/.last-alerte-planificateur"
SEUIL=${SEUIL:-9000}          # 2 h 30 : deux battements horaires manques
SILENCE=${SILENCE:-21600}     # au plus un iMessage toutes les 6 h
# Numero retire du code le 26/08/2026 : ces scripts sont publies dans le catalogue public
# de skills, et le garde-fou anti-fuite bloquait le push depuis le 23/08 a cause de cette ligne.
# Le numero se lit maintenant dans ~/.claude/notifications/destinataire.txt, non versionne.
TEL="$(cat "$HOME/.claude/notifications/destinataire.txt" 2>/dev/null | tr -d '[:space:]')"
if [ -z "$TEL" ]; then
  echo "destinataire absent : creer ~/.claude/notifications/destinataire.txt" >&2
  exit 1
fi

mkdir -p "$LOG_DIR" "$(dirname "$BATTEMENT")"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S')  $1" >> "$LOG"; }

# Canal d'alerte, change le 13/09/2026 : l'iMessage vers le propre numero de Clement arrive SANS
# notification (test avec temoin). Mail.app envoie depuis clementpredo4 vers clem.pred, expediteur
# different, donc l'iPhone sonne. Le numero TEL ne sert plus qu'au controle de configuration.
alerter() {
  osascript - "$1" "$2" <<'OSA' >/dev/null 2>&1
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
}

maintenant=$(date +%s)

# OBSERVATION du 25/09/2026 (audit) : second detecteur sans battement, lu dans l'etat du planificateur
# lui-meme. Journalise seulement, n'alerte pas. S'il concorde une semaine avec le battement, il le remplace
# et la tache heartbeat-planificateur (168 sessions/sem, ~470 k tokens chacune) s'arrete.
/usr/bin/python3 "$(dirname "$0")/creneaux-rates.py" >> "$LOG_DIR/creneaux-rates.log" 2>&1

# Pas de fichier du tout : le heartbeat n'a jamais tourne. On ne crie pas au premier passage,
# on cree le fichier a l'heure courante et on laisse une chance au premier battement.
if [ ! -f "$BATTEMENT" ]; then
  echo "$maintenant" > "$BATTEMENT"
  log "amorcage : fichier de battement cree, aucun controle ce passage"
  exit 0
fi

dernier=$(cat "$BATTEMENT" 2>/dev/null | tr -dc '0-9')
[ -z "$dernier" ] && dernier=0
ecart=$(( maintenant - dernier ))

if [ "$ecart" -lt "$SEUIL" ]; then
  exit 0
fi

# Le planificateur n'a pas battu depuis trop longtemps. Deuxieme preuve avant d'alerter :
# aucun processus de tache programmee ne tourne. La signature du mode headless est l'option
# --disallowedTools, jamais presente sur une conversation ouverte par Clement.
taches_en_cours=$(ps ax -o args= | grep -c -- '--disallowedTools' || true)
taches_en_cours=$(( taches_en_cours - 1 ))   # la ligne du grep lui-meme
[ "$taches_en_cours" -lt 0 ] && taches_en_cours=0

if [ "$taches_en_cours" -gt 0 ]; then
  log "battement vieux de $((ecart/60)) min MAIS $taches_en_cours tache(s) en cours : pas d'alerte"
  exit 0
fi

# Anti-inondation
recent=0
if [ -f "$TEMOIN" ]; then
  [ $(( maintenant - $(cat "$TEMOIN" 2>/dev/null | tr -dc '0-9' || echo 0) )) -lt "$SILENCE" ] && recent=1
fi

if [ "$recent" = "1" ]; then
  log "planificateur toujours mort ($((ecart/60)) min) : mail deja envoye recemment, silence"
  exit 0
fi

echo "$maintenant" > "$TEMOIN"

# Texte SANS ACCENT et sans URL nue : regles iMessage de Clement, alignees sur claude-session-guard.
msg="Planificateur mort : aucune tache programmee executee depuis $((ecart/3600)) h. Le correctif est de quitter et rouvrir l application Claude, ca coupe les sessions Claude Code ouvertes. Verifie ensuite qu une tache repasse."

alerter "[Axem] Planificateur de taches arrete" "$msg"

log "ALERTE : planificateur muet depuis $((ecart/60)) min, 0 tache en cours, mail envoye"

# ─────────────────────────────────────────────────────────────────────────────
# CONTROLE 2, ajoute le 27/08/2026 : le RUN AUTOPILOTE qui meurt en cours de route
#
# POURQUOI
# Le 26/08, linkedin-autopilot-batch-quotidien a travaille 51 minutes, programme un post,
# puis est mort a 21h05 : un second Chrome s'etait appaire au compte, la tache devait poser
# une question de selection, et une tache programmee ne peut pas en poser. Elle a fini EN VERT
# avec un lastRunAt frais. Le watchdog de 9h l'a donc comptee « a l'heure ».
# Pire : recap, journal et fichier de programmation etaient ecrits en fin de run. Le crash les
# a emportes, laissant UN POST PUBLIE SUR LINKEDIN SANS AUCUNE TRACE LOCALE, que le run suivant
# allait reprogrammer en doublon.
#
# COMMENT
# La tache ecrit AUTO_DEBUT en premiere action et AUTO_FIN en derniere. Ici, hors de
# l'application, on detecte un debut sans fin. C'est le seul endroit qui survit au crash.
#
# POURQUOI C'EST AUTORISE A PARLER EN TEMPS REEL
# « Echec ou disparition d'une tache programmee » est l'une des trois exceptions actees au
# regime du digest. Les autres alertes attendent 19h, celle-ci non.

AUTO_DEBUT="$HOME/.claude/heartbeats/autopilot-debut.txt"
AUTO_FIN="$HOME/.claude/heartbeats/autopilot-fin.txt"
AUTO_SEUIL=${AUTO_SEUIL:-4500}        # 75 min : un run normal dure ~50 min
AUTO_TEMOIN="$LOG_DIR/.last-alerte-autopilot"

if [ -f "$AUTO_DEBUT" ]; then
  debut=$(cat "$AUTO_DEBUT" 2>/dev/null | tr -d '[:space:]')
  fin=$(cat "$AUTO_FIN" 2>/dev/null | tr -d '[:space:]')
  now=$(date +%s)
  # Un debut plus recent que la derniere fin = run en cours ou mort en cours.
  if [ -n "$debut" ] && { [ -z "$fin" ] || [ "$debut" -gt "$fin" ]; }; then
    ecoule=$(( now - debut ))
    if [ "$ecoule" -gt "$AUTO_SEUIL" ]; then
      dernier=$(cat "$AUTO_TEMOIN" 2>/dev/null | tr -d '[:space:]')
      dernier=${dernier:-0}
      if [ $(( now - dernier )) -gt "$SILENCE" ]; then
        msg2="Run LinkedIn mort en cours de route : demarre il y a $(( ecoule / 60 )) min, jamais termine. Il a peut-etre programme un post sans laisser de trace locale. Verifie tes posts programmes avant le prochain run, sinon risque de doublon."
        alerter "[Axem] Run LinkedIn mort en cours de route" "$msg2"
        echo "$now" > "$AUTO_TEMOIN"
        log "ALERTE : run autopilote demarre il y a $(( ecoule / 60 )) min sans fin, mail envoye"
      fi
    fi
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# CONTROLE 3 : LE DECLENCHEUR PASSE DU COTE DU SURVEILLANT. Ajoute le 27/08/2026.
#
# POURQUOI
# Le controle 2 ci-dessus ne se declenche que si le run a ecrit son debut. Or les trois
# pannes de la semaine du 24 au 26/08 sont precisement des runs qui n'ont RIEN ecrit :
# plafond de depense, limite hebdomadaire, planificateur inerte apres redemarrage. Un
# surveillant arme par le surveille ne voit jamais la panne qui empeche le surveille de
# demarrer. Verifie le 27/08 : ~/.claude/heartbeats/ ne contenait pas autopilot-debut.txt,
# donc TOUT le bloc precedent etait inerte depuis sa creation.
#
# COMMENT
# L'horaire attendu est connu et fixe : cron « 30 20 * * 1-4 ». On ne demande donc rien au
# run. Apres 22h00 un jour ouvre lundi-jeudi, l'absence d'une FIN datee du jour est une
# panne, que le run ait demarre ou non.
#
# POURQUOI C'EST AUTORISE A PARLER EN TEMPS REEL
# Meme exception que le controle 2 : echec ou disparition d'une tache programmee.

heure=$(date +%H)
jour=$(date +%u)          # 1 = lundi ... 7 = dimanche
AUTO_TEMOIN_ABS="$LOG_DIR/.last-alerte-autopilot-absent"

if [ "$jour" -ge 1 ] && [ "$jour" -le 4 ] && [ "$heure" -ge 22 ]; then
  minuit=$(date -j -f "%Y-%m-%d %H:%M:%S" "$(date +%Y-%m-%d) 00:00:00" +%s 2>/dev/null)
  fin=$(cat "$AUTO_FIN" 2>/dev/null | tr -d '[:space:]')
  fin=${fin:-0}
  if [ -n "$minuit" ] && [ "$fin" -lt "$minuit" ]; then
    dernier=$(cat "$AUTO_TEMOIN_ABS" 2>/dev/null | tr -d '[:space:]')
    dernier=${dernier:-0}
    now=$(date +%s)
    if [ $(( now - dernier )) -gt "$SILENCE" ]; then
      msg3="Run LinkedIn de 20h35 : aucune trace de fin ce soir. Il n'a pas tourne, ou il est mort avant d'ecrire. La file se vide de 3 creneaux par jour tant que ca dure."
      alerter "[Axem] Run LinkedIn du soir absent" "$msg3"
      echo "$now" > "$AUTO_TEMOIN_ABS"
      log "ALERTE : aucune fin de run autopilote datee d'aujourd'hui a ${heure}h, mail envoye"
    fi
  fi
fi
