#!/bin/bash
# derame.sh — Diagnostic RAM + purge mémoire inactive (mode doux, ne ferme rien)
# Axem IA Hub — skill /derame

echo "🧠 ===== DÉRAMAGE — DIAGNOSTIC MÉMOIRE ====="
echo "📅 $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# --- 1. État de la pression mémoire ---
echo "📊 PRESSION MÉMOIRE"
PRESSURE=$(memory_pressure 2>/dev/null | grep -i "System-wide memory free percentage" | head -1)
if [ -n "$PRESSURE" ]; then
  echo "   $PRESSURE"
else
  vm_stat | awk '
    /page size of/ {ps=$8}
    /Pages free/ {free=$3}
    /Pages active/ {act=$3}
    /Pages inactive/ {inact=$3}
    /Pages wired/ {wired=$4}
    /Pages occupied by compressor/ {comp=$5}
    END {
      gsub(/\./,"",free); gsub(/\./,"",inact); gsub(/\./,"",wired); gsub(/\./,"",comp); gsub(/\./,"",act)
      mb=ps/1048576
      printf "   Libre        : %6.0f Mo\n", free*mb
      printf "   Inactive     : %6.0f Mo  (récupérable par purge)\n", inact*mb
      printf "   Active        : %6.0f Mo\n", act*mb
      printf "   Wired (sys)  : %6.0f Mo\n", wired*mb
      printf "   Compressée   : %6.0f Mo\n", comp*mb
    }'
fi
echo ""

# --- 2. Charge système ---
echo "⚙️  CHARGE SYSTÈME"
uptime | sed 's/.*load averages*:/   Load avg :/'
echo ""

# --- 3. Top 12 process gourmands en RAM ---
echo "🐷 TOP 12 GLOUTONS RAM (mémoire physique réelle)"
echo "   ----------------------------------------------------"
ps -axo rss,pid,comm -r | awk 'NR>1 {printf "   %7.0f Mo  [pid %6s]  %s\n", $1/1024, $2, $3}' \
  | sort -rn | head -12
echo ""

# --- 4. Purge mémoire inactive (mode doux : seule action automatique) ---
echo "🧹 PURGE MÉMOIRE INACTIVE"
if command -v purge >/dev/null 2>&1; then
  if purge 2>/dev/null; then
    echo "   ✅ Purge effectuée."
  else
    echo "   ⚠️  Purge nécessite les droits admin. Lance manuellement : sudo purge"
  fi
else
  echo "   ⚠️  Commande purge indisponible (installe les Xcode Command Line Tools)."
fi
echo ""

# --- 5. État après purge ---
echo "📊 MÉMOIRE LIBRE APRÈS PURGE"
vm_stat | awk '
  /page size of/ {ps=$8}
  /Pages free/ {free=$3}
  /Pages inactive/ {inact=$3}
  END {
    gsub(/\./,"",free); gsub(/\./,"",inact)
    mb=ps/1048576
    printf "   Libre    : %6.0f Mo\n", free*mb
    printf "   Inactive : %6.0f Mo\n", inact*mb
  }'
echo ""
echo "✅ ===== FIN DU DIAGNOSTIC ====="
