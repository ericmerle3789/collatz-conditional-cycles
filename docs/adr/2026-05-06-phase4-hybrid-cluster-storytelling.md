# ADR-0001 — Phase 4 : Approche hybride « clusters cohérents »

**Date** : 2026-05-06
**Statut** : Accepté
**Auteurs** : Session A + Session C (validation proxy user, Eric chat 2026-05-06 15:25 « En autonomie avec session C »)

## Contexte

Le 2026-05-06 chat 15:18, Eric livre 7 idées de génie pour Phase 4 :

| # | Idée | Effort | Gain |
|---|---|---|---|
| #11 | Page « Behind the proof » (storytelling Eric) | 1-2j | ★★★★★ |
| #12 | Live Lean playground embedded | 3-5j | ★★★★ |
| #13 | ✅ Newsletter mensuelle (validée) | 5h setup | ★★★★★ |
| #14 | GitHub Discussions activé sur le repo | 15 min | ★★★★ |
| #15 | Modal « Citer » BibTeX/RIS/APA | 3h | ★★★★ |
| #16 | Mention Wikipedia (post-acceptation JAR) | 2h | ★★★★★ |
| #17 | Carte postale virtuelle PNG citable | 2-3h | ★★★ |

Phase 3.6 + 3.7 α SHIPPED le matin (tag `v0.7.2`), β monitoring 7-14j en arrière-plan (calendar 2026-05-13 + 2026-05-20). 3 approches d'ordonnancement possibles : séquentiel strict, parallèle agressif, hybride clusters.

Eric chat 15:25 délègue validation à C (proxy user role HARD-GATE `superpowers:brainstorming` skill).

## Décision

Adopter **approche hybride « clusters cohérents »** :

- **M1 J+0 (today, 2026-05-06)** — Quick wins burst (parallèle car indépendants)
  - #14 GitHub Discussions (15 min, ROI extrême ★★★★ pour 15 min)
  - #15 Modal Citer (3h, alimente #16 futur via références propres)
- **M2 J+7 (2026-05-13)** — Cluster Storytelling start
  - #11 Behind the proof (1-2j, hub central narratif voix Eric)
- **M3 J+14 (2026-05-20)** — Cluster Storytelling end (cascade #11)
  - #17 Carte postale PNG (2-3h, alimenté visuels #11)
  - #13 Newsletter setup (5h, 1er numéro = #11 distillé)
- **M4 post-JAR acceptation** — Parking lot
  - #16 Wikipedia (2h, déclencheur externe = paper accepté)
- **M5 sprint dédié post-M3** — Marathon
  - #12 Lean playground (3-5j, sandbox isolé)

## Conséquences

- ✅ Charge cognitive maîtrisée (★★ modérée, 1 cluster = 1 thème)
- ✅ Quick wins immédiats M1 (momentum + sentiment shipped)
- ✅ Cluster Storytelling cohérent (effet vague communication)
- ✅ Marathon technique séparé (pas de pollution roadmap principale)
- ⚠️ Période #11 (1-2j) sans livraison intermédiaire — patience requise
- ⚠️ Newsletter (#13) dépend de #11 (cascade) — blocage si #11 retardé

## Alternatives considérées

### Approche 1 — Séquentiel strict
1 idée à la fois, validation continue avant la suivante. ~2-3 semaines totales.

**Rejeté** : perd momentum (sentiment shipped étalé sur 3 semaines), effet cluster narratif perdu.

### Approche 2 — Parallèle agressif
Tout en parallèle quand possible. ~1 semaine totale.

**Rejeté** : charge cognitive ★★★ excessive, risque qualité réduite si rush, push multiples chaînés (cache buster bumps en cascade).

## KPIs de succès

- **KPI méta agrégé** : ratio bots/humains Cloudflare, actuel ~99% bots → objectif Phase 4 ≤95% bots
- **KPIs par idée** : voir `docs/plans/2026-05-06-phase4-roadmap-design.md` §3
- **KPIs enrichis (091_C→A §2)** : citations académiques Google Scholar (≥3 J+90) + GitHub stars (+20 J+30)

## Cohabitation β monitoring

Sur dates coïncidentes M2/M3 et β weekly checks (2026-05-13, 2026-05-20) :
- Matin : émettre Phase 4 livrable (commit + push)
- Après-midi : émettre β summary (observation passive, mailbox séparé)
- Pas de fusion contenu, pas de mélange livrable / observation

## Références

- Mailbox A↔C : `090_A→C` brainstorming + `091_C→A` vote convergent α/α/α/α + `092_A→C` HARD-GATE relâché
- Eric chat 2026-05-06 15:25 : « En autonomie avec session C » (proxy validation déléguée)
- Design doc complet : `docs/plans/2026-05-06-phase4-roadmap-design.md`
- Plan implémentation M1 : `docs/plans/2026-05-06-phase4-M1-quick-wins.md`
- Tag git précédent : `v0.7.2` (Phase 3.6 wrap-up + 3.7 α SHIPPED 2026-05-06 15:00, sha `ea14f40`)

---

*ADR-0001 — Phase 4 hybride — 2026-05-06.*
