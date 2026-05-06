# Design — Phase 4 « Idées de génie » roadmap

> **Date** : 2026-05-06
> **Auteurs** : Session A + Session C (validation proxy user, Eric chat 15:25 « En autonomie avec session C »)
> **Statut** : Validé α/α/α/α par convergence A+C (091_C→A vote)
> **Skill** : `superpowers:brainstorming` HARD-GATE relâché → terminal `superpowers:writing-plans`

---

## §1. Contexte

### Liste 7 idées de génie (Eric, 2026-05-06 chat 15:18)

| # | Piste | Effort | Gain |
|---|---|---|---|
| #11 | Page « Behind the proof » (storytelling Eric) | 1-2j | ★★★★★ |
| #12 | Live Lean playground embedded | 3-5j | ★★★★ |
| #13 | ✅ Newsletter mensuelle (validée) | 5h setup | ★★★★★ |
| #14 | GitHub Discussions activé sur le repo | 15 min | ★★★★ |
| #15 | Modal « Citer » BibTeX/RIS/APA | 3h | ★★★★ |
| #16 | Mention Wikipedia (post-acceptation JAR) | 2h | ★★★★★ |
| #17 | Carte postale virtuelle PNG citable | 2-3h | ★★★ |

### Dépendances identifiées

```
#11 Behind the proof  ━━━━┳━━━► alimente #13 (1er numéro newsletter)
                          ┃
                          ┗━━━► alimente #17 (visuel signature carte postale)

#15 Modal Citer ━━━━━━━━━━━━━► alimente #16 Wikipedia (références propres)

#14 Discussions = isolé, lance community immédiatement
#12 Lean playground = isolé, marathon technique pur
```

### Bloqueurs temporels

- **#16 Wikipedia** : nécessite acceptation JAR (paper soumis pas encore accepté)
- **#13 Newsletter** : ✅ déjà validée par Eric (mais bénéficie d'attendre #11 pour alimenter le 1er numéro)

---

## §2. Décision — Approche hybride « clusters cohérents »

### 3 approches considérées

1. **Séquentiel strict** — 1 idée à la fois, validation continue. Sécurité max, ~2-3 semaines, perd momentum.
2. **Parallèle agressif** — tout en parallèle quand possible. ~1 semaine, qualité réduite si rush.
3. **Hybride clusters cohérents** ⭐ — quick wins burst + cluster narratif + spike sandbox isolé.

### Approche retenue (3 — hybride)

```
🚀 M1 J+0 (today, 2026-05-06) — Quick wins burst
   ├─ #14 GitHub Discussions (15 min, ROI extrême)
   └─ #15 Modal Citer 3 onglets BibTeX/RIS/APA (3h)

🎬 M2-M3 J+1 → J+14 — Cluster « Storytelling »
   ├─ #11 Behind the proof (1-2j, hub central narratif voix Eric) → M2 (J+7, 2026-05-13)
   ├─ #17 Carte postale PNG (2-3h, alimenté par visuels #11) → M3 (J+14, 2026-05-20)
   └─ #13 Newsletter setup (5h, 1er numéro = #11 distillé) → M3 (J+14, 2026-05-20)

⏸ M4 — Parking lot (déclencheur externe)
   └─ #16 Wikipedia (post-JAR acceptation, 2h)

🏗 M5 — Marathon dédié
   └─ #12 Lean playground (3-5j, sandbox isolé, post-M3)
```

### Trade-offs acceptés

- ✅ Charge cognitive maîtrisée (★★ modérée — 1 cluster = 1 thème)
- ✅ Quick wins immédiats M1 (momentum + sentiment shipped)
- ✅ Cluster Storytelling cohérent (effet vague communication)
- ✅ Marathon technique séparé (pas de pollution roadmap principale)
- ⚠️ Période #11 (1-2j) sans livraison intermédiaire → patience requise
- ⚠️ Newsletter (#13) dépend de #11 (cascade) → blocage si #11 retardé

---

## §3. KPIs — métriques de succès

### KPI méta agrégé (objectif central Phase 4)

**Ratio bots/humains Cloudflare** : actuellement ~99% bots, objectif ≤95% bots (5× plus humains qu'avant Phase 4).

### KPIs par idée

| # | KPI primaire | Outils mesure | Window | Objectif |
|---|---|---|---|---|
| #14 | Threads créés / mois | GitHub Insights | mensuel | ≥3 M1+30 |
| #15 | Clicks bouton Cite | Cloudflare event ou GA4 | mensuel | ≥10/mois |
| #11 | Temps lecture moyen | Cloudflare Web Analytics | hebdo | ≥3 min (vs ~30s autres pages) |
| #11 | Partages externes | Recherche manuelle + LinkedIn | hebdo | ≥5 partages/semaine post-publication |
| #17 | Téléchargements PNG / partages social | Cloudflare event PNG | mensuel | ≥20 téléchargements/mois |
| #13 | Inscriptions cumulées | Newsletter platform | hebdo | ≥50 J+30 |
| #13 | Taux ouverture mensuel | Newsletter platform | mensuel | ≥40% |
| #16 | Présence Wikipedia + backlinks | Recherche Wikipedia + Cloudflare referrers | mensuel | Article créé J+30 post-JAR |
| #12 | Sessions utilisateur > 30s | Cloudflare Web Analytics | hebdo | ≥30% sessions playground |

### KPIs enrichissements (091_C→A §2 suggestions)

| KPI | Source | Métrique | Window | Objectif |
|---|---|---|---|---|
| **Citations académiques** | Google Scholar | Citations cumulées DOI Zenodo `10.5281/zenodo.19790406` | mensuel | ≥3 citations cumulées J+90 |
| **GitHub stars** | GitHub Insights | Étoiles cumulées repo `collatz-conditional-cycles` | hebdo | +20 stars cumulées J+30 |

---

## §4. Milestones M1 → M5

| Milestone | Date cible | Livrable | Effort estimé |
|---|---|---|---|
| **M1** | J+0 (today, 2026-05-06) | #14 + #15 + ADR-0001 SHIPPED | ~3h45 |
| **M2** | J+7 (2026-05-13) | #11 SHIPPED + 1er β weekly check | ~1-2j |
| **M3** | J+14 (2026-05-20) | #17 + #13 SHIPPED + 2ème β weekly check + γ décision Eric | ~7-8h |
| **M4** | post-JAR acceptation (?) | #16 Wikipedia SHIPPED | ~2h |
| **M5** | sprint dédié post-M3 | #12 Lean playground SHIPPED | ~3-5j |

### Cohabitation β monitoring (091_C→A §3 mitigation acceptée)

Sur les dates 2026-05-13 et 2026-05-20 où coïncident M2/M3 et β weekly checks :
- **Matin** : émettre Phase 4 livrable (commit + push)
- **Après-midi** : émettre β summary (observation passive, mailbox C séparé)
- Pas de fusion contenu, pas de mélange livrable / observation.

---

## §5. Phase 3.8 candidates (parallèles ou intégrées)

Activées progressivement par les milestones Phase 4 :

| # | Candidate | Effort | Trigger |
|---|---|---|---|
| 3.8.1 | ADR lightweight `docs/adr/` | ~10-15 min/ADR | **Activé M1** : ADR-0001 Phase 4 hybride (ce design) |
| 3.8.2 | Footer link `Migration notes` p1 11 pages | ~10 min | M1 ou M2 sweep |
| 3.8.3 | CI script identifiants Lean + sentinelles humilité | ~30 min | Sprint isolé post-M3 |
| 3.8.4 | Cron `durable: true` + audit `.gitignore` | ~10 min | Sprint isolé post-M3 |
| 3.8.5 | Brand truncation `text-overflow: ellipsis` | ~10 min | Si Eric confirme gêne |
| 3.8.6 | Footer Atom/RSS cleanup | ~10 min | Si Cloudflare montre désuet |

---

## §6. Architecture / Components — Quick wins M1

### #14 GitHub Discussions (15 min)

**Architecture** : option GitHub native, pas de code.

**Components** :
- 4 catégories initiales : 📢 Announcements / 💬 General / 🔬 Math discussions / 🐛 Site feedback
- Premier post pinned : « Bienvenue — Discussions ouvertes » (voix Eric, bilingue inline)
- Mention dans `MAINTAINERS.md` ou footer

**Data flow** : aucun (option GitHub côté serveur).

**Error handling** : modération Eric + SPAM filter natif GitHub.

**Testing** : créer 1-2 threads test post-activation pour vérifier permissions.

### #15 Modal « Citer » BibTeX/RIS/APA (3h)

**Architecture** : HTML5 `<dialog>` natif + JavaScript clipboard API.

**Components** :
- `<dialog id="cite-modal">` avec 3 tabs : BibTeX | RIS | APA
- Bouton `id="citeBtn"` déjà présent dans topbar canonical pattern
- Contenu de chaque onglet généré depuis Schema.org `ScholarlyArticle` JSON-LD existant
- Bouton « Copier » par tab → `navigator.clipboard.writeText(...)`
- Toast confirmation 2 sec (CSS animation)
- Bilingue inline FR/EN (cohérent voix site)

**Data flow** :
1. User clique `#citeBtn` (topbar)
2. JS ouvre `<dialog>` avec `dialog.showModal()`
3. User sélectionne onglet (BibTeX par défaut)
4. User clique « Copier »
5. JS lit le `<textarea>` du tab actif → `navigator.clipboard.writeText(...)`
6. JS affiche toast « Copié ! » 2 sec
7. User ferme dialog (Esc ou bouton X)

**Données injectées dans templates** :
- Author : Eric Merle
- ORCID : 0009-0008-7940-402X
- Title : « Conditional theorem on Collatz / Syracuse non-trivial cycles »
- Year : 2026
- DOI Zenodo : 10.5281/zenodo.19790406
- URL : https://collatz-lab.org/papers/
- Note : « Submitted to Journal of Automated Reasoning »

**Error handling** :
- Fallback si `navigator.clipboard` indisponible → `document.execCommand('copy')` + alert sélection manuelle
- Fallback si `<dialog>` non supporté (Safari < 15.4) → `<div role="dialog">` polyfill simple

**Testing** :
- UX MCP runtime test localhost (Chrome moderne)
- Sample sur Safari (fallback dialog)
- Vérifier copie BibTeX → coller dans Zotero (round-trip)

### ADR-0001 (15 min)

**Path** : `/Users/ericmerle/Documents/collatz-gh-pages/docs/adr/2026-05-06-phase4-hybrid-cluster-storytelling.md`

**Format** : Michael Nygard 2011 (Date / Statut / Auteurs / Contexte / Décision / Conséquences / Alternatives / Références).

**Contenu** : capture la décision approche hybride avec justifications + alternatives écartées + références mailbox.

---

## §7. Verrous opérationnels (rappel permanent)

1. **Pas de push origin sans OK chat explicite Eric** OU autonomie A+C maintenue (chat 15:25)
2. **Pas de modif EXCLUSIONS originales** (11 + #12-#14 = 14 EXCLUSIONS protégées)
3. **Pas de touche identifiant Lean `BakerSeparation`**
4. **Branche `gh-pages` uniquement** (jamais `main` réservé paper JAR)
5. **Concertation A+C systématique** via mailbox `_handoff_mailbox/`
6. **UX MCP runtime test obligatoire post-apply** (Eric directive)

---

## §8. Skip MVP — décisions documentées

### Sub-vote 091 §5 — 4 suggestions techniques #15 → α sobriété MVP

Pour M1, **3 onglets uniquement** (BibTeX + RIS + APA). Skip :
- ❌ CSL JSON (Citation Style Language, Zotero modernes) → Phase 4.5+ si demande
- ❌ Markdown simple (blog/Slack/forums) → Phase 4.5+ si demande
- ❌ BibTeX `eprint = arXiv:XXX` → Phase 4.5+ si Eric a/aura preprint arXiv
- ❌ RIS skeleton complet (EndNote) → déjà couvert par RIS minimal

**Justification** : sobriété directive Eric (« le plus simple qui marche »), 3 formats couvrent 80% besoins citation académique, ajouts conditionnels au feedback utilisateur réel.

### #14 — Skip catégorie « Lean / Formal verification » dédiée

Pour M1, **4 catégories** (Announcements / General / Math / Site feedback). Skip :
- ❌ Catégorie 5ème « Lean / Formal verification » dédiée → ajout uniquement si audience math research devient active (signal monitoring β)

**Justification** : éviter complexité prématurée, « Math discussions » suffit en MVP.

---

## §9. Références

- Mailbox : `090_A→C` brainstorming + `091_C→A` vote convergent + `092_A→C` HARD-GATE relâché
- Eric chat 2026-05-06 15:18 : liste 7 idées génie
- Eric chat 2026-05-06 15:25 : « En autonomie avec session C » (proxy validation)
- Skill `superpowers:brainstorming` HARD-GATE → terminal `superpowers:writing-plans`
- Précédent : `MIGRATION_NOTES.md` Phase 3.6 wrap-up + EXCLUSIONS_LIST.md (audit folder)
- Tag git : `v0.7.2` (Phase 3.6 + 3.7 α SHIPPED 2026-05-06 15:00)

---

## §10. Transition writing-plans

Ce design doc est **input** au skill `superpowers:writing-plans` qui produit le **plan d'implémentation détaillé M1** :
- Steps numbered avec dependencies
- Validation points (UX MCP test, audit C, etc.)
- Rollback strategy si bug
- Time budget par step

Le plan d'implémentation sera créé dans `docs/plans/2026-05-06-phase4-M1-impl-plan.md` (généré par writing-plans skill, ou intégré directement dans la session via TodoWrite).

---

*Fin de design doc Phase 4 — v1.0 — 2026-05-06.*
