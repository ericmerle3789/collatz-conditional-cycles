# Design — Closure E.1 Salikhov 2007 (μ ≤ 5.125) → δ11 impossibility lemma

**Date** : 2026-05-07
**Auteurs** : Session A (Claude Code) + Eric (proxy validator de l'architecture 5-IA)
**Statut** : DESIGN PHASE — δ11 NON encore prouvé. Ce document enregistre l'architecture validée de la mission.
**Référence brainstorming** : skill `superpowers:brainstorming` étape 5 (design doc) → étape 6 (writing-plans)

## 1. Mission

Fermer la piste E.1 du registre `pistes.json` et de `papers/index.html` via une preuve formelle d'**insuffisance** (impossibility result).

### 1.1 Texte original du lead (papers/index.html L372-378)

> « Idée : formaliser Salikhov 2007 (μ ≤ 5.125) **ou** Wu 2003 (c = 5.117) pour réduire la dépendance Baker dans la sous-branche k ≤ 3732. Le gap résiduel (k ∈ [3733, 1.375·10¹¹]) reste conditionnel. »

### 1.2 Discordance détectée pendant le cadrage

| Source | Salikhov k_max | Wu k_max | Notes |
|--------|---------------|----------|-------|
| `pistes.json` E.1 (L108) | k ≤ **3693** | — | « Ferme k ≤ 3693 inconditionnel » |
| `pistes.json` E.2 (L125) | — | k ≤ **3732** | « meilleur que Salikhov » |
| `tests_math/test_REQ-MATH-003_wu_salikhov_kmax.py` | 3693 | 3732 | Vérifié empirique |
| `papers/index.html` L375 | (sous-entend 3732) | (correct 3732) | **Imprécision** |

**Implication** : papers/index.html présente Salikhov et Wu comme équivalents pour k ≤ 3732, mais Salikhov SEUL ne ferme que k ≤ 3693. Gap non couvert : k ∈ [3694, 3732].

→ Mea culpa #29 candidate à confirmer post-G3.

## 2. δ11 — Énoncé candidat (à raffiner G1)

**Working title** : « Salikhov-Insufficient-for-3732 lemma »

**Forme candidate** :
> Pour k ∈ {3694, ..., 3732}, la borne d'irrationalité de Salikhov 2007 (μ(log 2 / log 3) ≤ 5.125) ne produit PAS d'inégalité diophantienne |2^s − 3^k| ≥ f(k) suffisante pour fermer ces k inconditionnellement, contrairement à Wu 2003 (c = 5.117) qui les ferme.

**Position relative à δ10** :
- δ10 (Phase 64, kernel-1 [propext]) : impossibilité **GLOBALE** — aucune borne du catalogue {Salikhov, Wu, Rhin, Simons-de Weger} ne peut remplacer BarinaVerification dans `no_nontrivial_cycle_phase59`.
- δ11 (proposed) : impossibilité **GRANULAIRE** — Salikhov SEUL est insuffisant pour le sous-cas k ≤ 3732 spécifiquement (zoom in sur la sous-question soulevée par papers/index.html).

δ11 affine δ10 sans le contredire ni le remplacer.

## 3. Architecture 5-IA validée par Eric (chat 2026-05-07)

```
Eric (superviseur)
   │
   └── Session A (Claude Code, moi) ── orchestrateur central
        │
        ├─ Chrome MCP ──┬── Gemini Pro 3.1 (Deep Research)
        │              ├── ChatGPT 5.5 (thinking advanced)
        │              └── Claude.ai Opus 4.7 (web)
        │
        └─ Filesystem mailbox ── Session D (Claude Opus 4.7 CLI)
                                  └─ Bash + Lean local + git
```

**Mailbox commune** : `_mailbox/E1_salikhov_2026-05-06/` dans `collatz-lab-audit`

**Anti-corrélation à 2 axes** :
1. Modèle : Claude vs Gemini vs ChatGPT (effet « famille de modèles »)
2. Scaffolding : Session D (CLI, filesystem) vs Claude.ai (web, artifacts) (effet « environnement »)

## 4. Trois portes (3 gates) avec unanimité 5-IA

| Gate | Livrable | Mode dispatch | Validation |
|------|----------|---------------|------------|
| **G1 — Énoncé math δ11** | Théorème formel d'insuffisance E.1 (forme finale) | 5 IA parallèle, prompt identique | Unanimité 5/5 |
| **G2 — Preuve Lean** | `Delta11Salikhov.lean` compile sans `sorry` | Session D leads, Gemini + ChatGPT + Claude.ai relisent par chunks | Build vert + 5 IA OK |
| **G3 — Audits 3 protocoles + meta + cross-Claude** | Red Team + NASA + ARES + meta-audit + cross-Claude NASA | 5 IA parallèle, 1 protocole / IA | Unanimité PASS |

## 5. Distribution des rôles G3

| IA | Rôle G3 | Justification |
|----|---------|---------------|
| Session A (Claude Code) | Red Team épistémique 12pts | Skill `superpowers` + accès codebase + meta-skills |
| Session D (Opus 4.7 CLI) | NASA failure modes 15pts | Lean local, peut tester edge cases au build |
| Gemini Pro | ARES adversarial 10pts | Deep Research + force adversariale |
| ChatGPT 5.5 | Meta-audit cross | Vérifie la cohérence entre les 3 audits |
| Claude.ai (web) | Cross-Claude NASA + revue éditoriale site | Refait NASA indépendamment de Session D ; relit la MAJ site |

## 6. Timeline cible (5-7 jours)

| Jour | Activité |
|------|----------|
| J1 | Lancement G1 — dispatch prompt 5 IA + collecte premières réponses |
| J2 | Convergence G1 — itérations jusqu'à unanimité énoncé δ11 + pre-registration GF9 |
| J3-4 | G2 — Session D rédige `Delta11Salikhov.lean`, autres relisent par chunks via mailbox |
| J5 | G2 build vert — fix résiduels + cross-validation finale |
| J6 | G3 — 5 audits parallèles (Red Team / NASA / ARES / meta / cross-Claude) |
| J7 | MAJ site (papers/index.html + pistes.json + changelog/) + push branche `study/E1-salikhov-2007-impossibility` après Eric chat OK |

## 7. Branche cible + EXCLUSIONS + garde-fous

- **Branche** : `study/E1-salikhov-2007-impossibility` créée depuis `arsenal-postjar` (post-G1)
- **JAMAIS** : `main` (paper JAR Springer en review depuis 2026-04-27 — GF1 critique), `gh-pages` (live site jusqu'à validation finale Eric)
- **EXCLUSIONS 14 fichiers protégés** (11 originales + #12-#14) : intactes
- **Identifiant Lean `BakerSeparation`** (~70 occurrences) : jamais modifié — δ11 est complémentaire, pas un remplacement
- **Push origin** : uniquement après G3 PASS unanime + Eric chat OK explicite (verrou GF8)
- **0 sorry** obligatoire (GF4) ; profil axiomes minimal kernel-1 [propext] visé (cf. δ10)

## 8. Livrables finaux

| # | Fichier | Repo | Branch | Phase |
|---|---------|------|--------|-------|
| 1 | `docs/plans/2026-05-07-E1-salikhov-design.md` | collatz-gh-pages | gh-pages | **ce document** |
| 2 | `META_PROMPT_SESSION_D.md` | collatz-lab-audit | (no git) | next |
| 3 | `_mailbox/E1_salikhov_2026-05-06/000_brief.md` | collatz-lab-audit | (no git) | next |
| 4 | `findings/PREREG_E1_DELTA11.md` | collatz-lab-audit | (no git) | post-G1 (GF9) |
| 5 | `ProjetCollatz/PostJAR/Delta11Salikhov.lean` | collatz-conditional-cycles | study/E1-salikhov-2007-impossibility | post-G2 |
| 6 | `findings/E1_audit_red_team.md` | collatz-lab-audit | (no git) | post-G3 |
| 7 | `findings/E1_audit_nasa.md` | collatz-lab-audit | (no git) | post-G3 |
| 8 | `findings/E1_audit_ares.md` | collatz-lab-audit | (no git) | post-G3 |
| 9 | `findings/E1_meta_audit_chatgpt.md` | collatz-lab-audit | (no git) | post-G3 |
| 10 | `findings/E1_cross_claude_nasa.md` | collatz-lab-audit | (no git) | post-G3 |
| 11 | `findings/PROVENANCE_DELTA11.md` | collatz-lab-audit | (no git) | post-G3 (GF10) |
| 12 | `papers/index.html` L372-378 (raturer ou reformuler) | collatz-gh-pages | gh-pages | post-validation Eric |
| 13 | `assets/data/pistes.json` E.1 entry MAJ | collatz-gh-pages | gh-pages | post-validation Eric |
| 14 | `changelog/index.html` (entrée δ11 + mea culpa #29 si applicable) | collatz-gh-pages | gh-pages | post-validation Eric |
| 15 | `index.html` (frise chronologique + diagrammes selon impact) | collatz-gh-pages | gh-pages | post-validation Eric |

## 9. Sauvegardes anti-biais

### 9.1 Pre-registration (GF9 — open science discipline)

Avant tout travail Lean en G2, Session D écrit `findings/PREREG_E1_DELTA11.md` avec :
- Énoncé exact attendu (depuis G1 unanimity)
- Axiomes nécessaires anticipés (probablement [propext] only, kernel-1 comme δ10)
- Tactiques anticipées (omega, nlinarith, Mathlib bounds)
- Effort estimé (heures)
- Probabilité succès first try (%)

Si G2 trouve un résultat différent → signal scientifique fort à discuter en consensus 5-IA.

### 9.2 Provenance graph (GF10 — intégrité scientifique)

Post-G2, Session D écrit `findings/PROVENANCE_DELTA11.md` documentant :
- Lineage `Claim → Theorem → Axioms → Sources externes (DOI)`
- Lien Salikhov 2007 paper (DOI Doklady Math. 76(3))
- Connexion à δ10 existant + BarinaVerification + BakerSeparation
- Numerical verification REQ-MATH-003 link

### 9.3 5-IA anti-corrélation (deux axes)

| Axe | Comparaison | Ce qu'on isole |
|-----|-------------|----------------|
| Modèle | Claude vs Gemini vs ChatGPT | Effet « famille de modèles » |
| Scaffolding | Session D (CLI) vs Claude.ai (web) | Effet « environnement / outils » |

Si Session D et Claude.ai convergent ET les autres modèles convergent → confiance maximale.
Si Session D et Claude.ai divergent → révèle un biais de pipeline (signal instructif).

## 10. Critères de succès

- ✅ **Succès G1** : 5/5 IA convergent sur l'énoncé δ11 (formulation, hypothèses, conclusion)
- ✅ **Succès G2** : `lake build` vert sur `study/E1-salikhov-2007-impossibility`, 0 sorry, profil axiomes [propext] kernel-1 (ou kernel-3 max), 5/5 IA cross-validation
- ✅ **Succès G3** : 5/5 audits PASS (RT 12/12, NASA 15/15, ARES 10/10, meta cohérent, cross-Claude convergent NASA)
- ✅ **Succès propagation site** : papers/index.html corrigé, pistes.json E.1 status mis à jour, changelog entrée δ11, mea culpa #29 si discordance Salikhov/Wu confirmée

## 11. Échecs anticipés et plans B

| Échec | Plan B |
|-------|--------|
| G1 divergence persistante 5-IA | Eric arbitre ; sinon abandonner δ11 sous forme actuelle, reformuler |
| G2 sorry irréductible (preuve échoue) | Documenter l'échec dans findings/, conclure « δ11 conjecturé » plutôt que prouvé, MAJ site avec disclaimer |
| G3 échec un protocole | Itérer fix selon feedback ; si échec persistant > 2 itérations, escalader Eric |
| Salikhov 2007 PDF introuvable | Fallback dérivation depuis citations δ10 + REQ-MATH-003 |
| Cross-Claude divergence (Session D ≠ Claude.ai) | Signal NOTABLE — analyser source de divergence, peut révéler biais d'environnement |

## 12. Disclaimer (open science)

Ce document est un **DESIGN**. δ11 est un lemme **proposé**, pas encore prouvé. La mission peut conclure par :
1. **δ11 prouvé** → MAJ site + mea culpa #29 si applicable
2. **δ11 réfuté** par 5-IA → pas de MAJ site, échec documenté, learning publié dans `findings/`
3. **δ11 reformulé** par convergence 5-IA → énoncé révisé et workflow recommencé depuis G1

Discipline open science : hypothèse pré-enregistrée (GF9), divergence est un signal scientifique, pas un échec.

## 13. Références

- δ10 lemma existant : branche `study/delta10-barina-replacement-impossibility` (Phase 64, kernel-1, commit 7efbf34, 296 lignes Lean)
- Mea culpa #28 : BakerSeparation comme conjecture de travail, pas borne publiée — `pistes.json` L26+L43
- REQ-MATH-003 test : `tests_math/test_REQ-MATH-003_wu_salikhov_kmax.py` (vérifie k_max 3693 vs 3732)
- Salikhov 2007 : Doklady Math. 76(3) — paper à sourcer via Eric ou arxiv/Mathematical Reviews
- Wu 2003 : Math. Comp. 72(242), 901-911
- `META_PROMPT_SESSION_C.md` : 12 garde-fous + pipeline 9-phase + 6 protocoles d'audit (RT 12 + NASA 15 + ARES 10 + WCAG 8 + RGPD 5 + Provenance 5)
- Templates audit : `findings/AUDIT_RED_TEAM_REPORT_CGS7.md`, `AUDIT_NASA_REPORT_CGS7.md`, `AUDIT_ARES_REPORT_CGS7.md`
- Phase 4 ADR-0001 : approche hybride β monitoring (précédent pour validation 4-IA)
- ADR-0002 : Pattern audit pré-Edit — appliqué ici (avant écrire `Delta11Salikhov.lean`, vérifier `PadeBound.lean` existant qui est scaffolding Rhin 1987 + LMN, distinct de δ11 Salikhov-specific)

---

*Design validé Eric chat 2026-05-07 « Je valide l'architecture. » + extension Claude.ai chat 2026-05-07 « On peut continuer aussi avec Claude.ai ». Prochaine étape : skill writing-plans → plan d'exécution étape par étape.*
