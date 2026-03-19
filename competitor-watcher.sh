#!/usr/bin/env bash
# ==============================================================================
# Competitor Watcher — Easyflex
# Wekelijks script om concurrenten te monitoren en een rapport te genereren.
#
# Gebruik:
#   ./competitor-watcher.sh
#
# Vereisten:
#   - claude CLI (Claude Code) geïnstalleerd en geconfigureerd
#   - Internetverbinding
#
# Automatisering (cron):
#   Elke maandag om 07:00:
#   0 7 * * 1 cd /pad/naar/restaurater && ./competitor-watcher.sh >> logs/watcher.log 2>&1
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATE=$(date +%Y-%m-%d)
REPORT_FILE="${SCRIPT_DIR}/competitor-report-${DATE}.md"
LOG_DIR="${SCRIPT_DIR}/logs"

mkdir -p "$LOG_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Competitor Watcher gestart voor datum: $DATE"

# Controleer of rapport al bestaat (voorkom dubbele run op zelfde dag)
if [[ -f "$REPORT_FILE" ]]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Rapport voor vandaag bestaat al: $REPORT_FILE"
  echo "Verwijder het bestand handmatig als je opnieuw wilt genereren."
  exit 0
fi

COMPETITORS=(
  "Zvoove"
  "MySolution"
  "Nocore"
  "Planbition"
  "Carerix"
  "Plan4flex"
)

COMPETITOR_URLS=(
  "https://www.zvoove.com"
  "https://www.mysolution.com"
  "https://www.nocore.nl"
  "https://www.planbition.com"
  "https://www.carerix.com"
  "https://www.plan4flex.nl"
)

# ==============================================================================
# Schrijf rapport-header
# ==============================================================================
cat > "$REPORT_FILE" << EOF
# Competitor Intelligence Report — Easyflex
**Datum:** $(date '+%-d %B %Y')
**Periode:** Afgelopen 7 dagen
**Concurrenten:** ${COMPETITORS[*]}

> *Dit rapport is automatisch gegenereerd door competitor-watcher.sh*

---

EOF

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Rapport aangemaakt: $REPORT_FILE"

# ==============================================================================
# Onderzoek per concurrent via Claude
# ==============================================================================
for i in "${!COMPETITORS[@]}"; do
  COMPETITOR="${COMPETITORS[$i]}"
  URL="${COMPETITOR_URLS[$i]}"

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Onderzoek: $COMPETITOR ($URL)"

  PROMPT="Je bent een competitive intelligence analist voor Easyflex (uitzendsoftware, NL).

Onderzoek de concurrent: ${COMPETITOR} (website: ${URL})
Datum van onderzoek: ${DATE}

Doe het volgende:
1. Zoek naar LinkedIn-posts van ${COMPETITOR} uit de afgelopen 7 dagen (zoek op 'site:linkedin.com ${COMPETITOR}' en nieuws-zoekopdrachten)
2. Zoek naar persberichten of nieuws over ${COMPETITOR} uit de afgelopen 7 dagen
3. Analyseer hun huidige website-homepage en positionering

Schrijf een sectie in Markdown (geen ```markdown blokken, gewoon platte Markdown) met:
## ${COMPETITOR}

### Nieuws afgelopen 7 dagen
[wat gevonden]

### Actuele messaging & positionering
[analyse homepage/over ons/pricing]

### Opvallend qua communicatie
[wat valt op in toon, thema's, campagnes]

### Strategisch relevant voor Easyflex
[beoordeling: Laag / Middel / Hoog + 2-3 zinnen uitleg]

---
"

  # Voeg sectie toe aan rapport via claude CLI
  if command -v claude &>/dev/null; then
    claude --print "$PROMPT" >> "$REPORT_FILE" 2>> "${LOG_DIR}/watcher-errors.log" || {
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] WAARSCHUWING: claude CLI fout voor $COMPETITOR — zie logs/watcher-errors.log"
      echo "## ${COMPETITOR}" >> "$REPORT_FILE"
      echo "" >> "$REPORT_FILE"
      echo "> **Fout bij ophalen:** claude CLI retourneerde een fout. Controleer logs/watcher-errors.log." >> "$REPORT_FILE"
      echo "" >> "$REPORT_FILE"
      echo "---" >> "$REPORT_FILE"
      echo "" >> "$REPORT_FILE"
    }
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WAARSCHUWING: claude CLI niet gevonden — installeer Claude Code (https://claude.ai/code)"
    echo "## ${COMPETITOR}" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "> **claude CLI niet gevonden.** Installeer Claude Code en voer opnieuw uit." >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "---" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
  fi

  # Korte pauze om rate limits te respecteren
  sleep 5
done

# ==============================================================================
# Schrijf rapport-footer
# ==============================================================================
cat >> "$REPORT_FILE" << EOF

---

## Overkoepelende Observaties
*(Voeg hier handmatig strategische context toe na het lezen van het rapport)*

## Actiepunten voor Easyflex
- [ ] ...

---
*Rapport gegenereerd op ${DATE} door competitor-watcher.sh*
*Volgende geplande run: $(date -d 'next monday' '+%Y-%m-%d') (maandag)*
EOF

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Rapport voltooid: $REPORT_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Competitor Watcher klaar."
