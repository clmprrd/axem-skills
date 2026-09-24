#!/bin/sh
# Transcrit une liste de reels Instagram en local. Aucun service tiers, aucun cout.
#
# Usage :
#   transcris-reels.sh reels-retenus.tsv DOSSIER_SORTIE [LANGUE] [MAX]
#
# reels-retenus.tsv : sortie de classe-comptes.py (entete + colonnes rang/compte/shortcode/...)
# LANGUE : code force passe a whisper (en pour les comptes US, fr pour les comptes francais).
#          NE PAS omettre : sans -l, whisper TRADUIT au lieu de transcrire. Incident du
#          07/09/2026, les 12 transcriptions de dryxio.us etaient revenues en anglais.
# MAX : nombre de reels a traiter, defaut 30.
#
# Compte environ 110 secondes par reel de 60 s avec ggml-large-v3-turbo sur un Mac Apple Silicon
# (mesure le 09/09/2026 : 106,5 s pour un reel de 61 s). 30 reels = a peu pres 55 minutes.

set -e
TSV="$1"; OUT="$2"; LANG="${3:-en}"; MAX="${4:-30}"
if [ -z "$TSV" ] || [ -z "$OUT" ]; then echo "usage: $0 reels-retenus.tsv DOSSIER [LANGUE] [MAX]"; exit 2; fi
[ -f "$TSV" ] || { echo "introuvable: $TSV"; exit 2; }

YTDLP=$(command -v yt-dlp) || { echo "yt-dlp absent"; exit 2; }
WHISPER=$(command -v whisper-cli) || { echo "whisper-cli absent"; exit 2; }
command -v ffmpeg >/dev/null || { echo "ffmpeg absent"; exit 2; }
MODEL=""
for m in "/Users/clementpredo/Documents/my-video/.whisper-cpp/ggml-large-v3-turbo.bin" \
         "$HOME/whisper.cpp/models/ggml-large-v3-turbo.bin"; do
  [ -f "$m" ] && MODEL="$m" && break
done
[ -n "$MODEL" ] || { echo "modele ggml-large-v3-turbo.bin introuvable"; exit 2; }

mkdir -p "$OUT" "$OUT/.audio"
fait=0; saute=0; echec=0; n=0

# tail -n +2 saute la ligne d'entete du TSV
tail -n +2 "$TSV" | while IFS="$(printf '\t')" read -r rang compte code plays reste; do
  n=$((n+1))
  [ "$n" -gt "$MAX" ] && break
  cible="$OUT/${compte}__${code}.txt"
  if [ -s "$cible" ]; then
    saute=$((saute+1)); echo "[$n] deja fait   $compte $code"; continue
  fi
  a="$OUT/.audio/$code"
  if ! "$YTDLP" --no-warnings --socket-timeout 30 -f "bestaudio/best" \
        -o "${a}.%(ext)s" "https://www.instagram.com/reel/$code/" >/dev/null 2>&1; then
    echec=$((echec+1)); echo "[$n] ECHEC dl    $compte $code"; continue
  fi
  src=$(ls "${a}".* 2>/dev/null | head -1)
  [ -n "$src" ] || { echec=$((echec+1)); echo "[$n] ECHEC dl    $compte $code"; continue; }
  ffmpeg -y -loglevel error -i "$src" -ar 16000 -ac 1 -c:a pcm_s16le "${a}.wav" 2>/dev/null
  "$WHISPER" -m "$MODEL" -l "$LANG" -nt -otxt -of "${a}" "${a}.wav" >/dev/null 2>&1
  if [ -s "${a}.txt" ]; then
    mv "${a}.txt" "$cible"
    mots=$(wc -w < "$cible" | tr -d ' ')
    fait=$((fait+1)); echo "[$n] ok $mots mots  $compte $code ($plays plays)"
  else
    echec=$((echec+1)); echo "[$n] ECHEC whisper $compte $code"
  fi
  rm -f "${a}".* 2>/dev/null || true
done

echo "---"
echo "transcrits dans : $OUT"
echo "recompte reel   : $(ls "$OUT"/*.txt 2>/dev/null | wc -l | tr -d ' ') fichiers .txt"
rmdir "$OUT/.audio" 2>/dev/null || true
