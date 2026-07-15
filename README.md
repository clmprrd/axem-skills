# axem-skills — marketplace de skills Claude

Skills génériques réutilisables (recherche adversariale, design, process, méta-outils) de Clément Predo — Axem IA.
Compatibles **Claude Code (CLI)** et **claude.ai / Claude Desktop / Cowork** via le système de plugins.

## Installer

### Dans Claude Code (CLI)
```
/plugin marketplace add clmprrd/axem-skills
/plugin install axem-skills@axem-marketplace
```

### Dans claude.ai / Claude Desktop / Cowork
Customize → **Plugins** → **Personal plugins** → **+** → **Add marketplace** → **Add from a repository**
→ coller `clmprrd/axem-skills` (ou l'URL du repo) → puis **Install** le plugin `axem-skills`.

Une fois installé, les skills sont invocables via `/axem-skills:<nom>` (ex : `/axem-skills:conseil-agents`)
et se déclenchent aussi automatiquement selon leur description.

## Mettre à jour
Après un changement poussé sur ce repo : `/plugin marketplace update axem-marketplace` (CLI) ou clic **Update** (UI).

## Skills inclus
`askuser-question-batch` · `conseil-agents` · `deepsearch` · `derame` · `ponytail` · `ppt-design-check` · `taste-skill` · `upgrade-skill` · `webinar-prep`

## Note de maintenance (privé)
La source de vérité de ces skills est le vault Obsidian privé `Axem-IA-Hub/06-Skills-Claude/`.
Ce repo public est **régénéré** par `build-public-plugin.sh`, qui ne copie QUE les skills listés dans
`PUBLIC_SKILLS.txt` (allowlist = garde-fou anti-fuite). Ne jamais éditer les SKILL.md ici à la main :
modifier dans le vault, puis relancer le script.
