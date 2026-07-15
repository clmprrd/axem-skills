# Conseil d'agents — régimes, model/effort-tiering & discipline de tokens (détail)

Chargé à la demande par le SKILL.md principal. Le corps du skill garde les résumés ; ici c'est le détail complet.

## Les 3 régimes (choisis en Phase 0 par l'orchestrateur, en contexte)

| Régime | Quand | Deepsearch | Débat | Coût cible |
|---|---|---|---|---|
| **⚡ Éclair** | question cadrée, décision quasi binaire, ou vault a déjà 80 % de la réponse | 3-4 agents Sonnet | 3 lentilles (Sceptique, Stratège, Pragmatique) | léger |
| **⚖️ Standard** (défaut) | vraie question ouverte, impact réel, plusieurs options | 6-8 agents Sonnet | 5 lentilles | moyen |
| **🏛️ Plénier** | décision structurante, gros budget, irréversible, ou Clément dit « à fond / sans pitié / plénier » | 10-15 agents Sonnet | 5 lentilles + Contrarian round 2 | lourd, assumé |

En cas de doute → **Standard**. Le sous-dimensionnement est le mode d'échec *silencieux* (réponse pauvre sans alerte) ;
le sur-dimensionnement n'est que du gaspillage visible. Donc au moindre doute, prends le régime au-dessus.

## Model-tiering + effort-tiering (deux axes)

| Rôle | `model` | `effort` | Pourquoi |
|---|---|---|---|
| **Orchestrateur = toi (main loop)** | `opus` | — | tu tranches, synthétises, gardes le fil |
| **Triage / cadrage (Phase 0)** | *toi, en contexte* | — | pas d'agent : tu as déjà le contexte, Opus décide en 1 passe |
| **Lookup mémoire/vault, fetch pur** | `haiku` | `low` | récupérer, pas raisonner |
| **Agents deepsearch (recherche + verdict)** | `sonnet` | `medium`→`high` si angle dur | raisonnement + web, meilleur rapport qualité/coût |
| **Conseillers du débat (lentilles)** | `sonnet` | `medium` | critique argumentée |
| **Fixers code / contenu (Phase 3)** | `sonnet` | `medium` | édition fiable |
| **Reviewer adversarial d'un fix critique** | `opus` | `high` | uniquement si l'enjeu le justifie |

Deux règles d'or :
- **Jamais d'Opus en sous-agent** sauf revue d'un fix à fort enjeu. Opus, c'est toi, une fois.
- **Effort bas sur le mécanique, haut seulement sur le critique.** Un fetch ou un lookup ne mérite pas de
  reasoning coûteux ; une vérification adversariale d'un fix qui touche à la sécurité, si.

## Discipline de tokens — les 7 règles

1. **Calibrer le nombre d'agents au sujet — LE levier n°1** (Phase 0). C'est lui qui pilote le multiplicateur
   de coût (un système multi-agents brûle ~4-15× un chat simple, selon la largeur du fan-out). Ne dégaine
   10-15 agents que sur un vrai enjeu.
2. **Sortie compacte par sous-agent** (levier n°2). `verdict ≤200 mots + reco n°1 + 3-5 sources`, et **renvoie
   des références, pas le contenu brut** (« synthétise, ne dump pas »). ⚠️ Mais ne pas sur-compresser : un verdict
   amputé de son raisonnement coûte en qualité. Vise le dense, pas le vide.
3. **Réutilise avant de chercher** : Phase 0 vérifie `memory/` + le vault (`08-Idees-et-veille`). Si un verdict
   récent existe (ex: `crawl4ai-ecarte-deepsearch`), pointe dessus au lieu de relancer 15 agents.
4. **Un seul tour de deepsearch par défaut.** Vague 2 uniquement si un angle *critique* manque après la Phase 2 —
   pas « pour être sûr ».
5. **Zéro chevauchement d'angles** : 6 agents sur 6 angles distincts battent 15 agents qui se marchent dessus.
6. **Skip ce qui ne s'applique pas** : pas de code → pas de Phase 3 ; sujet interne (`besoin_web: false`) → agents
   de lecture de code, pas de recherche web ; sujet tranché à 90 % → 1 seul lot de questions, pas 4.
7. **Le fan-out passe par le Workflow `conseil-agents-recherche`** (voir SKILL.md Phase 1) : les rapports bruts
   restent dans les variables du script, hors de ton contexte Opus, et le harness gère la concurrence/budget —
   plus besoin de gérer des « vagues » à la main.
