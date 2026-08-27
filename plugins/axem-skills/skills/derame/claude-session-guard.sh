#!/bin/bash

# Numero retire du code le 26/08/2026 : ce script part dans le catalogue public de skills.
DESTINATAIRE="$(cat "$HOME/.claude/notifications/destinataire.txt" 2>/dev/null | tr -d '[:space:]')"
#
# claude-session-guard.sh
# Tue les sessions Claude Code de TACHES PROGRAMMEES qui asphyxient le Mac,
# ainsi que leurs serveurs MCP enfants. Deux regles :
#
#   A. age  — une session programmee vivante depuis plus de SEUIL (2 h) est
#             bloquee, pas lente. On la coupe.
#   B. cascade — au-dela de MAX_SIMULT (5) sessions programmees simultanees,
#             on coupe les plus anciennes pour ramener le compte a MAX_SIMULT,
#             quel que soit leur age (plancher : MIN_AGE_SIMULT, 5 min).
#             Sans cette regle, une cascade a 2 h pour pourrir la machine.
#
# POURQUOI
# Le 30/07/2026 puis le 10/08/2026, le Mac est reste eteint toute la journee.
# Au reveil, le planificateur a rattrape d'un coup toutes les taches manquees :
# 21 sessions lancees en 90 minutes, chacune avec son jeu de serveurs MCP.
# Sur 16 Go, le swap est parti a 12 Go et les taches se sont mutuellement
# asphyxiees : aucune n'a fini, load average a 117 sur 8 coeurs.
#
# POURQUOI UN SCRIPT SHELL ET PAS UNE TACHE CLAUDE
# La tache derame-alerte-seuils-cpu-swap existait deja et devait justement
# signaler ce cas. Elle s'est fait avaler par l'embouteillage qu'elle
# surveillait. Un garde-fou doit peser quelques Mo et ne dependre d'aucun
# serveur MCP pour rester operationnel quand la machine sature.
#
# CE QU'IL NE FAIT PAS
# Il ne touche jamais aux sessions interactives. Il ne cible que les process
# portant --disallowedTools AskUserQuestion, signature du mode headless des
# taches programmees. Une conversation ouverte par Clement n'est jamais tuee,
# meme vieille de 10 h.
#
# Desinstallation :
#   launchctl bootout gui/$(id -u)/com.axem.claude-session-guard
#   rm ~/Library/LaunchAgents/com.axem.claude-session-guard.plist

set -uo pipefail

SEUIL=${SEUIL:-7200}                       # regle A : age max d'une session, 2 h
# Regle B : releve de 5 a 8 le 10/08/2026. A 5, le garde coupait des runs
# LinkedIn legitimes : le meme jour, la cadence est passee a 13 runs quotidiens
# (skool-post-2807 a 9 runs, linkedin-comment-autoreply a 4) pour resorber un
# backlog de 1 466 personnes qui grossit de 100 par jour. Le garde doit proteger
# contre la CASCADE DE RATTRAPAGE (21 taches relachees d'un coup apres un Mac
# eteint), pas contre une cadence choisie deliberement. A 8, il laisse passer
# l'heure de pointe et les runs LinkedIn, et casse toujours une vraie cascade.
# Redescendu de 8 a 6 le 10/08/2026 au soir, sur deux mesures reelles de la
# meme journee : a 5, le garde coupait des runs legitimes trois fois dans la
# matinee ; a 8, la machine est montee a load 255 a 12h29 avec exactement 8
# sessions en parallele. Six est le point entre les deux, et depuis que le
# garde reagit en 1 seconde au lieu de 8 minutes, il coupe AVANT que le swap
# ne sature au lieu d'arriver apres la bataille.
MAX_SIMULT=${MAX_SIMULT:-6}
# Regle B : plancher d'age releve de 5 a 20 min le 10/08/2026. A 5 min, le garde
# coupait des taches legitimes : entre 9h et 9h30 Clement a normalement 6 a 8
# taches en parallele, et une tache qui pilote Chrome met 15 a 20 min. Une vraie
# cascade, elle, laisse ses sessions vivantes des HEURES (21 taches bloquees 7 h
# le 09/08), donc 20 min la detecte toujours sans mordre sur le fonctionnement
# normal. Le 10/08 a 09h09 le garde a coupe 3 sessions sur 8 en pleine heure de
# pointe : c'est ce faux positif que ce plancher corrige.
MIN_AGE_SIMULT=${MIN_AGE_SIMULT:-1200}
DRY=${DRY:-0}                              # DRY=1 : n'envoie aucun signal
LOG_DIR="$HOME/Library/Logs/axem"
LOG="$LOG_DIR/claude-session-guard.log"
NOTIFQ="$HOME/.claude/notifications/notifq.py"

mkdir -p "$LOG_DIR"
log() { printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG"; }

# ═══ UNE SEULE PHOTO DES PROCESS, prise une fois et reutilisee partout ═══
#
# Pourquoi c'est critique (constate le 10/08/2026 a 12h29) : la version
# precedente appelait `ps` deux fois par session candidate et `pgrep` une fois
# par descendant, soit plusieurs centaines de forks. Sous un load de 250, chaque
# fork prend des secondes : le garde a mis HUIT MINUTES a couper deux sessions,
# pendant que le swap saturait. Un garde-fou qui ralentit proportionnellement au
# probleme qu'il traite ne sert a rien au moment ou on a besoin de lui.
# Ici : un seul `ps`, puis tout se calcule en awk sur cette photo. Quelques
# secondes meme a load 250.
#
# Effet de bord assume : la photo peut etre legerement perimee quand la machine
# thrashe (un process tue entre-temps). Sans consequence, `kill` sur un pid mort
# echoue silencieusement et c'est le comportement voulu.
SNAPSHOT=$(ps -Ao pid=,ppid=,etime=,command=)

# Descendants recursifs d'un ou plusieurs pids, calcules sur la photo.
# Un seul awk, aucun fork par process.
descendants() {
  printf '%s\n' "$SNAPSHOT" | awk -v roots="$1" '
    BEGIN { n = split(roots, r, " "); for (i = 1; i <= n; i++) if (r[i] != "") keep[r[i]] = 1 }
    { parent[$1] = $2 }
    END {
      changed = 1
      while (changed) {
        changed = 0
        for (p in parent) if (!(p in keep) && (parent[p] in keep)) { keep[p] = 1; changed = 1 }
      }
      for (p in keep) print p
    }'
}

# Le ps de macOS ne connait pas etimes : on convertit etime ([[JJ-]HH:]MM:SS)
etime_secondes() {
  local e=$1 d=0 h=0 m=0 s=0
  case "$e" in *-*) d=${e%%-*}; e=${e#*-} ;; esac
  local IFS=:
  set -- $e
  case $# in
    3) h=$1; m=$2; s=$3 ;;
    2) m=$1; s=$2 ;;
    *) s=${1:-0} ;;
  esac
  echo $(( 10#${d:-0} * 86400 + 10#${h:-0} * 3600 + 10#${m:-0} * 60 + 10#${s:-0} ))
}

# --- Reperage des sessions headless trop vieilles --------------------------
# Inventaire "age pid" des sessions programmees vivantes.
# Chaque session apparait en double dans ps : un launcher (fils de Claude
# Desktop) et la session reelle (fille du launcher, celle qui porte les
# serveurs MCP). On ne retient que la seconde, sinon tous les comptes doublent.
# Calcule en UN SEUL awk sur la photo : plus aucun fork par session candidate.
# La conversion de etime ([[JJ-]HH:]MM:SS) en secondes est faite en awk aussi,
# la fonction shell etime_secondes n'est plus sur le chemin critique.
INVENTAIRE=$(
  printf '%s\n' "$SNAPSHOT" | awk '
    function secondes(e,   d, p, n) {
      d = 0
      if (index(e, "-")) { split(e, p, "-"); d = p[1] + 0; e = p[2] }
      n = split(e, p, ":")
      if (n == 3) return d*86400 + p[1]*3600 + p[2]*60 + p[3]
      if (n == 2) return d*86400 + p[1]*60 + p[2]
      return d*86400 + p[1]
    }
    {
      pid = $1; ppid = $2; et = $3
      cmd = $0
      ligne[pid] = cmd
      pere[pid]  = ppid
      age[pid]   = secondes(et)
    }
    END {
      for (p in ligne) {
        c = ligne[p]
        if (index(c, "claude-code/") == 0) continue
        if (index(c, "claude.app/Contents/MacOS/claude") == 0) continue
        if (index(c, "--disallowedTools AskUserQuestion") == 0) continue
        if (index(c, "claude-session-guard")) continue
        # Chaque session apparait en double : un launcher (fils de Claude Desktop)
        # et la session reelle (fille du launcher, celle qui porte les MCP). On ne
        # garde que la seconde, sinon tous les comptes doublent.
        pp = pere[p]
        if (!(pp in ligne)) continue
        if (index(ligne[pp], "claude.app/Contents/MacOS/claude") == 0) continue
        print age[p], p
      }
    }'
)

NB_VIVANTES=$(printf '%s\n' "$INVENTAIRE" | grep -c '[0-9]' || true)

# Regle A — une session programmee qui depasse SEUIL est bloquee, pas lente.
RACINES_A=$(printf '%s\n' "$INVENTAIRE" | awk -v s="$SEUIL" '$1 > s {print $2}')

# Regle B — cascade de rattrapage. Quand le Mac a passe la journee eteint, le
# planificateur relache d'un coup toutes les taches manquees : le 09/08/2026,
# 21 sessions en 90 minutes sur 16 Go de RAM. Elles s'asphyxient mutuellement
# et AUCUNE n'aboutit. En laisser tourner MAX_SIMULT et couper le reste donne
# un resultat strictement meilleur que de toutes les laisser echouer.
RACINES_B=""
MOTIF="age"
if [ "$NB_VIVANTES" -gt "$MAX_SIMULT" ]; then
  EXCES=$((NB_VIVANTES - MAX_SIMULT))
  RACINES_B=$(printf '%s\n' "$INVENTAIRE" \
    | awk -v m="$MIN_AGE_SIMULT" '$1 >= m' \
    | sort -rn | head -n "$EXCES" | awk '{print $2}')
  [ -n "$RACINES_B" ] && MOTIF="cascade ($NB_VIVANTES simultanees)"
fi

RACINES=$(printf '%s\n%s\n' "$RACINES_A" "$RACINES_B" | grep -v '^$' | sort -un)

# --- Surveillance ----------------------------------------------------------
# Reprend le role de la tache programmee derame-alerte-seuils-cpu-swap, qui
# faisait le meme travail mais depuis une session Claude Code : le 10/08/2026
# elle s'est fait avaler par l'embouteillage qu'elle devait justement signaler.
# Ici c'est du shell : quelques Mo, aucun MCP, insensible au thrashing.
surveiller() {
  [ "$DRY" = "1" ] && return 0             # un test ne pollue pas la file
  local load1 swap_pct swap_u swap_t nb_cc alerte=""
  load1=$(uptime | sed 's/.*load averages*: *//' | awk '{print $1}' | tr -d ',')
  swap_u=$(sysctl -n vm.swapusage | sed 's/.*used = \([0-9.]*\)M.*/\1/')
  swap_t=$(sysctl -n vm.swapusage | sed 's/.*total = \([0-9.]*\)M.*/\1/')
  swap_pct=$(awk -v u="${swap_u:-0}" -v t="${swap_t:-1}" 'BEGIN{printf "%.0f", (t>0? u*100/t : 0)}')
  nb_cc=$(ps -Ao command= | grep -cF 'claude.app/Contents/MacOS/claude' || true)

  # Seuil swap en valeur ABSOLUE et non en pourcentage : macOS redimensionne
  # le swap tout seul (13,3 Go avant le menage du 10/08, 5,1 Go apres), donc
  # "84 %" peut valoir 11 Go un jour et 4 Go le lendemain. Le pourcentage
  # aurait sonne a tort des le lendemain de l'incident.
  local swap_go
  swap_go=$(awk -v u="${swap_u:-0}" 'BEGIN{printf "%.1f", u/1024}')

  awk -v l="${load1:-0}" 'BEGIN{exit !(l>20)}' && alerte="load ${load1}"
  awk -v g="${swap_go:-0}" 'BEGIN{exit !(g>10)}' && alerte="${alerte:+$alerte, }swap ${swap_go} Go"
  [ "${nb_cc:-0}" -gt 40 ] 2>/dev/null && alerte="${alerte:+$alerte, }${nb_cc} process claude-code"

  # --- Alerte TEMPS REEL -----------------------------------------------
  # Le 09/08, l'alerte "load 215" a ete deposee a 17h18 et attendait encore
  # le digest de 9h44 seize heures plus tard. Un Mac qui sature au point
  # qu'aucune tache n'aboutit EST un echec de taches programmees, donc l'une
  # des trois exceptions qui ont droit a l'iMessage immediat.
  # Le load seul ne suffit PAS a declencher un iMessage : le 10/08 a 02h32,
  # une synchro iCloud (bird + fileproviderd) a pousse le load a 68 avec
  # seulement 2 taches programmees vivantes. C'est du bruit legitime, pas une
  # cascade. Le signal d'une cascade, c'est le NOMBRE de taches en parallele.
  local nb_prog critique=""
  nb_prog=$(printf '%s\n' "$INVENTAIRE" | grep -c '[0-9]' || true)
  if [ "${nb_prog:-0}" -gt 8 ] 2>/dev/null; then
    critique="${nb_prog} taches programmees en parallele"
  elif [ "${nb_prog:-0}" -gt 5 ] 2>/dev/null && awk -v l="${load1:-0}" 'BEGIN{exit !(l>50)}'; then
    critique="load ${load1} avec ${nb_prog} taches programmees"
  fi

  if [ -n "$critique" ]; then
    local temoin_i="$LOG_DIR/.last-imessage" maintenant_i recent_i=0
    maintenant_i=$(date +%s)
    if [ -f "$temoin_i" ]; then
      [ $((maintenant_i - $(cat "$temoin_i" 2>/dev/null || echo 0))) -lt 10800 ] && recent_i=1
    fi
    if [ "$recent_i" = "0" ]; then
      echo "$maintenant_i" > "$temoin_i"
      # Texte SANS ACCENT et sans URL nue (regles iMessage de Clement)
      local msg="Mac sature : $critique. Le garde a coupe ce qu il pouvait, les taches programmees ne finissent plus. Verifie avec /derame si ca dure."
      osascript <<OSA >/dev/null 2>&1
tell application "Messages"
  set svc to 1st service whose service type = iMessage
  send "$msg" to buddy "$DESTINATAIRE" of svc
end tell
OSA
      log "iMESSAGE temps reel envoye : $critique"
    fi
  fi

  # Alerte : au plus une toutes les 3 h, pour ne pas inonder la file
  if [ -n "$alerte" ] && [ -f "$NOTIFQ" ]; then
    local temoin="$LOG_DIR/.last-alert"
    local maintenant recent=0
    maintenant=$(date +%s)
    if [ -f "$temoin" ]; then
      [ $((maintenant - $(cat "$temoin" 2>/dev/null || echo 0))) -lt 10800 ] && recent=1
    fi
    if [ "$recent" = "0" ]; then
      echo "$maintenant" > "$temoin"
      python3 "$NOTIFQ" add --task derame-alerte-seuils --level alert \
        --text "Mac sature : $alerte (normale : load sous 8). Le garde a deja coupe ce qu'il pouvait. Lance /derame si ca persiste." \
        >/dev/null 2>&1
      log "ALERTE deposee : $alerte"
    fi
  fi

  # --- UNE seule ligne de digest par jour, agregee -------------------------
  # Le 10/08 au matin, le digest de 9h44 contenait 15 lignes dont 9 sur le Mac,
  # et 6 venaient d'ici : une ligne deposee a CHAQUE passage, cinq fois le meme
  # texte. Verdict de Clement : « c'est nul, ca m'apprend rien ». Il avait
  # raison : ce bruit a noye Fathom muet depuis 10 jours, 13 RDV du jour et une
  # relance mairie jamais partie. La regle du CLAUDE.md est « rien a dire = ne
  # rien deposer » ; repeter six fois qu'une cascade a ete coupee, c'est
  # exactement le bruit que Clement avait supprime en refondant ses notifs.
  # Desormais : on ACCUMULE en silence, on depose UNE ligne le matin, et
  # seulement si la nuit a reellement eu quelque chose a raconter.
  if [ -f "$NOTIFQ" ]; then
    local jour temoin_j cumul heure
    jour=$(date +%Y-%m-%d); temoin_j="$LOG_DIR/.last-daily"
    cumul="$LOG_DIR/.cumul-$jour"
    heure=$(date +%H)
    # Fenetre de depot : entre 9h et 9h40, juste avant le digest de 9h44.
    if [ "$(cat "$temoin_j" 2>/dev/null)" != "$jour" ] && [ "$heure" -ge 9 ] 2>/dev/null; then
      echo "$jour" > "$temoin_j"
      local n_sessions=0 n_passages=0 libre
      if [ -f "$cumul" ]; then
        n_sessions=$(awk '{s+=$1} END{print s+0}' "$cumul")
        n_passages=$(awk 'END{print NR+0}' "$cumul")
      fi
      libre=$(df -g / | awk 'NR==2{print $4}')
      if [ "${n_sessions:-0}" -gt 0 ] 2>/dev/null; then
        python3 "$NOTIFQ" add --task derame-sante-mac --level info \
          --text "Nuit : ${n_sessions} sessions de taches bloquees coupees en ${n_passages} passages. Machine OK ce matin (load ${load1}, ${libre} Go libres). Les taches coupees repassent a leur cadence, rien a faire." \
          >/dev/null 2>&1
      fi
      # Rien coupe cette nuit = rien a dire. On ne depose pas.
      find "$LOG_DIR" -name '.cumul-*' -mtime +2 -delete 2>/dev/null
    fi
  fi
}
surveiller

if [ -z "$RACINES" ]; then
  exit 0                                   # rien a tuer, et rien a dire
fi

# --- Construction de l'arbre complet a tuer --------------------------------
# Tout en UN SEUL appel a descendants() et UN SEUL awk pour les launchers :
# plus de boucle avec deux `ps` par racine. Voir le commentaire sur SNAPSHOT
# plus haut pour la raison (8 minutes d'inaction a load 250 le 10/08).
NB_SESSIONS=$(printf '%s\n' "$RACINES" | grep -c '[0-9]' || true)

RACINES_PLATES=$(printf '%s\n' "$RACINES" | tr '\n' ' ')

# Les launchers parents sont eux aussi des process claude.app : on les emporte,
# sinon ils restent orphelins et faussent les comptes du passage suivant.
LAUNCHERS=$(printf '%s\n' "$SNAPSHOT" | awk -v roots="$RACINES_PLATES" '
  BEGIN { n = split(roots, r, " "); for (i = 1; i <= n; i++) if (r[i] != "") cible[r[i]] = 1 }
  { pere[$1] = $2; ligne[$1] = $0 }
  END {
    for (p in cible) {
      pp = pere[p]
      if (pp == "" || pp <= 1) continue
      if (index(ligne[pp], "claude.app/Contents/MacOS/claude")) print pp
    }
  }')

CIBLES=$(printf '%s\n%s\n%s\n' \
  "$RACINES" \
  "$LAUNCHERS" \
  "$(descendants "$RACINES_PLATES $(printf '%s\n' "$LAUNCHERS" | tr '\n' ' ')")" \
  | grep -v '^$' | sort -un)
NB_PROCS=$(echo "$CIBLES" | wc -l | tr -d ' ')

# Garde-fou : ne jamais se tuer soi-meme ni sa chaine d'ancetres
# Chaine d'ancetres remontee sur la photo, sans un `ps` par niveau.
CHAINE=$(printf '%s\n' "$SNAPSHOT" | awk -v moi="$$" '
  { pere[$1] = $2 }
  END {
    cur = moi
    while (cur > 1 && (cur in pere)) { print cur; suivant = pere[cur]; if (suivant == cur) break; cur = suivant }
    if (cur > 1) print cur
  }')
for c in $CHAINE; do
  if echo "$CIBLES" | grep -qx "$c"; then
    log "ABANDON : le garde est lui-meme dans la cible (pid $c). Rien tue."
    exit 1
  fi
done

if [ "$DRY" = "1" ]; then
  log "DRY-RUN : $NB_SESSIONS sessions / $NB_PROCS process seraient tues : $(echo $CIBLES | tr '\n' ' ')"
  echo "DRY-RUN : $NB_SESSIONS sessions, $NB_PROCS process"
  echo "$CIBLES" | tr '\n' ' '; echo
  exit 0
fi

# --- Arret propre puis force ------------------------------------------------
for p in $CIBLES; do kill -TERM "$p" 2>/dev/null; done
sleep 8
SURVIVANTS=0
for p in $CIBLES; do
  if kill -0 "$p" 2>/dev/null; then kill -KILL "$p" 2>/dev/null; SURVIVANTS=$((SURVIVANTS + 1)); fi
done

sleep 2
RESTANTS=0
for p in $CIBLES; do kill -0 "$p" 2>/dev/null && RESTANTS=$((RESTANTS + 1)); done

log "motif=$MOTIF : $NB_SESSIONS sessions tuees ($NB_PROCS process, $SURVIVANTS forces, $RESTANTS restants, $NB_VIVANTES vivantes avant)"

# --- Accumulation SILENCIEUSE ----------------------------------------------
# Aucun depot dans la file ici : une coupe est un non-evenement pour Clement,
# c'est le travail normal du garde. On incremente un compteur du jour, que
# surveiller() agrege en UNE seule ligne le matin. Voir le commentaire dans
# surveiller() pour le pourquoi (digest du 10/08 noye par 6 lignes d'ici).
if [ "$NB_SESSIONS" -gt 0 ] 2>/dev/null; then
  echo "$NB_SESSIONS" >> "$LOG_DIR/.cumul-$(date +%Y-%m-%d)"
fi

exit 0
