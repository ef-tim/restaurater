# Easyflex Competitor Watcher

Wekelijkse monitoring van concurrenten in de uitzendsoftware-markt.

## Concurrenten
- **Zvoove** — zvoove.com / zvoove.nl
- **MySolution** — mysolution.nl
- **Nocore** — nocore.nl
- **Planbition** — planbition.com
- **Carerix** — carerix.com
- **Plan4flex** — plan4flex.nl

## Rapportage
Rapporten worden opgeslagen als `competitor-report-YYYY-MM-DD.md`.

Bekijk het meest recente rapport:
```
cat competitor-report-$(date +%Y-%m-%d).md
```

## Handmatig uitvoeren
```bash
./competitor-watcher.sh
```

## Automatisch wekelijks uitvoeren (cron)
Voeg toe aan crontab (`crontab -e`):
```
# Elke maandag om 07:00
0 7 * * 1 cd /pad/naar/restaurater && ./competitor-watcher.sh >> logs/watcher.log 2>&1
```

## Vereisten
- [Claude Code CLI](https://claude.ai/code) geïnstalleerd en geconfigureerd
- Internetverbinding

## Monitoringscope per concurrent
Per wekelijkse run wordt het volgende gecheckt:
1. **LinkedIn** — nieuwe posts van de afgelopen 7 dagen (via geïndexeerde content)
2. **Website** — homepage en "over ons" / pricing messaging
3. **Nieuws** — persberichten en nieuwsartikelen van de afgelopen 7 dagen
