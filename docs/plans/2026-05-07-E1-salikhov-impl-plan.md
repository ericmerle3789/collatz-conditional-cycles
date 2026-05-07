# E.1 Salikhov 2007 Closure (δ11 Impossibility Lemma) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task.

**Goal :** Fermer la piste E.1 du registre via une preuve Lean formelle de δ11 (« Salikhov 2007 μ ≤ 5.125 est INSUFFISANT pour la sous-branche k ∈ [3694, 3732] »), validée par unanimité 5-IA à travers 3 portes (énoncé math / preuve Lean / audits 3-protocoles), puis MAJ site avec mea culpa #29 si applicable.

**Architecture :** Session A (Claude Code, orchestrateur) + Session D (Claude Opus 4.7 CLI mailbox) + Gemini Pro 3.1 + ChatGPT 5.5 thinking + Claude.ai Opus 4.7 web. Coordination filesystem mailbox `_mailbox/E1_salikhov_2026-05-06/` dans `collatz-lab-audit` + Chrome MCP pour les 3 IA web. Branche dédiée `study/E1-salikhov-2007-impossibility` créée depuis `arsenal-postjar` post-G1. **JAMAIS** main, **JAMAIS** push origin sans Eric chat OK explicite.

**Tech Stack :** Lean 4 + Mathlib v4.27, Chrome MCP (mcp__Claude_in_Chrome__*), Bash, git + tag annoté, templates audits RT12 + NASA15 + ARES10 dans `collatz-lab-audit/findings/`.

**Référence design** : `docs/plans/2026-05-07-E1-salikhov-design.md` (commit `ac285d3`).

---

## Vue d'ensemble des 7 phases

| Phase | Nom | Acteur principal | Output | Durée |
|-------|-----|------------------|--------|-------|
| **0** | Prep | Session A seul | META_PROMPT_SESSION_D + mailbox 000_brief | 30 min |
| **1 (G1)** | Énoncé math δ11 | 5 IA parallèle | `findings/CONSENSUS_5IA_DELTA11_G1.md` unanime | J1-2 |
| **2** | Pre-reg + branche | Session D + Session A | PREREG + branche `study/E1-salikhov-2007-impossibility` | J2 |
| **3 (G2)** | Preuve Lean | Session D leads, autres relisent | `Delta11Salikhov.lean` 0 sorry | J3-5 |
| **4 (G3)** | Audits 3+meta+cross | 5 IA parallèle | 5 rapports findings/ PASS unanime | J6 |
| **5** | Site update | Session A + Claude.ai relit | papers/pistes/changelog MAJ | J7 |
| **6** | Push origin | Eric OK explicite + Session A push | Branche + tag + Cloudflare propag | J7 |

---

## Phase 0 — Prep (Session A seul, ~30 min)

### Task 0.1 — Drafter `META_PROMPT_SESSION_D.md`

**Files :**
- Create : `/Users/ericmerle/Documents/collatz-lab-audit/META_PROMPT_SESSION_D.md`

**Step 1 :** Re-lire les sections clés de `META_PROMPT_SESSION_C.md` :
- §3 GARDE-FOUS GF1-GF12
- §6 Coordination mailbox
- §15 Comportements proscrits
- §16 Disclosure méthodologique 5 evidence levels

**Step 2 :** Adapter pour Session D avec différences clés :
- Session D ne pilote PAS d'IA web (Session A le fait)
- Session D = expert math + Lean + git
- Mission = δ11 (E.1 Salikhov insuffisance), pas audit site général
- Mailbox dédié `_mailbox/E1_salikhov_2026-05-06/` (pas from_X_to_Y)
- Format messages mailbox : `NNN_<from>_<topic>.md` avec frontmatter YAML

**Step 3 :** Inclure obligatoirement dans META_PROMPT_SESSION_D :
- §1 Identité + mandat (postdoc rigueur extrême)
- §2 Architecture 3 repos (paths absolus)
- §3 GARDE-FOUS GF1-GF12 (copie verbatim depuis C)
- §4 État actuel (post-CGS-7 + δ10 sur `study/delta10-...`)
- §5 Mission δ11 spécifique (énoncé candidat + position vs δ10)
- §6 Mailbox protocol (`_mailbox/E1_salikhov_2026-05-06/`)
- §7 3 gates G1/G2/G3 + rôle Session D dans chacun
- §8 Pre-registration GF9 obligatoire avant G2
- §9 Provenance graph GF10 obligatoire post-G2
- §10 Première action : ack 000_brief.md

**Step 4 :** Écrire le fichier (Write tool, ~6-8 KB markdown)

**Step 5 :** Commit atomique (collatz-lab-audit n'est pas git, donc pas de commit ; juste écriture sur disque)

**Verify :** Le fichier existe, fait > 200 lignes, contient les 12 garde-fous textuellement.

---

### Task 0.2 — Créer le dossier mailbox dédié

**Step 1 :** Bash mkdir
```bash
mkdir -p /Users/ericmerle/Documents/collatz-lab-audit/_mailbox/E1_salikhov_2026-05-06/
```

**Step 2 :** Verify
```bash
ls -la /Users/ericmerle/Documents/collatz-lab-audit/_mailbox/E1_salikhov_2026-05-06/
```

Expected : dossier vide, créé.

---

### Task 0.3 — Écrire `000_brief.md` (mission brief commune aux 5 IA)

**Files :**
- Create : `/Users/ericmerle/Documents/collatz-lab-audit/_mailbox/E1_salikhov_2026-05-06/000_brief.md`

**Contenu requis :**
- YAML frontmatter (from: Session A, to: ALL, timestamp, status: open, topic, priority: HIGH)
- §1 Mission verbatim Eric
- §2 Architecture 5-IA (recap)
- §3 État actuel : design doc validé `docs/plans/2026-05-07-E1-salikhov-design.md` commit `ac285d3`
- §4 Discordance papers/index.html vs pistes.json (sections 1.1 + 1.2 du design doc)
- §5 δ11 énoncé candidat à raffiner G1
- §6 Workflow 3 gates (G1/G2/G3) avec unanimité 5/5
- §7 Garde-fous critiques (GF1 main 🚫, GF8 push 🚫, EXCLUSIONS 14, BakerSeparation 70 occ)
- §8 Action attendue de chaque IA : ack 000 + attendre 001_G1_brief

**Step 1 :** Écrire le brief (Write tool, ~3-4 KB markdown)

**Verify :** Le fichier existe, contient le YAML frontmatter, fait référence explicite au design doc commit `ac285d3`.

---

### Task 0.4 — Écrire `META_PROMPT_SESSION_D.md` invitation message

**Files :**
- Modify : préparer le texte que Eric copy-paste pour démarrer Session D

**Contenu :**
```
Tu es Session D (Claude Opus 4.7 CLI). Lis :
1. /Users/ericmerle/Documents/collatz-lab-audit/META_PROMPT_SESSION_D.md (mandat complet)
2. /Users/ericmerle/Documents/collatz-lab-audit/_mailbox/E1_salikhov_2026-05-06/000_brief.md (mission brief)
3. /Users/ericmerle/Documents/collatz-gh-pages/docs/plans/2026-05-07-E1-salikhov-design.md (design validé)

Première action : écris `_mailbox/E1_salikhov_2026-05-06/001_D_ack_000.md` confirmant compréhension + 12 garde-fous + branche `study/E1-salikhov-2007-impossibility` jamais créée encore + ready pour G1.
```

**Step 1 :** Écrire ce texte dans `META_PROMPT_SESSION_D_INVOCATION.md` (à côté du META_PROMPT principal) pour que Eric puisse le copier facilement.

**Verify :** Eric peut copy-paste sans modification.

---

### Task 0.5 — Eric lance Session D + ack

**Step 1 :** Eric ouvre nouveau terminal + lance `claude` CLI dans n'importe quel folder (Session D peut naviguer)

**Step 2 :** Eric copy-paste le texte de Task 0.4

**Step 3 :** Session D lit les 3 fichiers, écrit `001_D_ack_000.md`

**Step 4 :** Session A polling le mailbox (ScheduleWakeup ou manuel)
```bash
ls /Users/ericmerle/Documents/collatz-lab-audit/_mailbox/E1_salikhov_2026-05-06/
```
Expected (post-ack) : `000_brief.md` + `001_D_ack_000.md`

**Step 5 :** Session A lit `001_D_ack_000.md`, valide compréhension D
- Vérifier 12 garde-fous présents
- Vérifier référence au design doc commit `ac285d3`
- Vérifier engagement à 0 sorry + kernel-1 cible

**Verify :** ACK reçu et valide → unlock Phase 1

**Si KO :** Demander à Eric de relancer Session D avec correctifs au META_PROMPT

---

## Phase 1 (G1) — Énoncé math δ11 unanimité 5-IA (J1-2)

### Task 1.1 — Drafter le prompt G1 (commun aux 5 IA)

**Files :**
- Create : `_mailbox/E1_salikhov_2026-05-06/002_A_G1_prompt.md`

**Structure obligatoire (anti-base64 GF2) :**
```
<context>
Mission δ11 closure E.1 Salikhov 2007 (μ ≤ 5.125).
Design doc : docs/plans/2026-05-07-E1-salikhov-design.md commit ac285d3.
Discordance papers/index.html L372-378 vs pistes.json E.1 (Salikhov k_max=3693, pas 3732).
</context>

<spec>
Énoncé candidat δ11 :
"Pour k ∈ {3694, ..., 3732}, la borne d'irrationalité de Salikhov 2007
(μ(log 2 / log 3) ≤ 5.125) ne produit PAS d'inégalité diophantienne
|2^s − 3^k| ≥ f(k) suffisante pour fermer ces k inconditionnellement,
contrairement à Wu 2003 (c = 5.117) qui les ferme."
</spec>

<task>
1. Valides-tu cet énoncé tel quel ?
2. Si non, propose la formulation que tu préfères (raffiner)
3. Quelles hypothèses doivent être explicites ? (ex: "k entier, s entier ≥ 1, ...")
4. Quelle f(k) précise est nécessaire pour fermer le cycle Collatz dans cette branche ?
5. Quel rapport avec δ10 (Phase 64, kernel-1) ? Confirmes-tu que δ11 affine δ10 sans le contredire ?
</task>

<constraints>
- Français
- Pas de chain-of-thought visible (si possible)
- Pas de base64/hex >2000 chars
- Citer Salikhov 2007 Doklady Math. 76(3) si tu as accès au paper
</constraints>

<output_format>
Réponse 5 sections numérotées Q1-Q5, chacune en 5-15 lignes max.
Conclusion : "VALIDE tel quel" / "RAFFINER vers : [...]" / "REJETER car [...]"
</output_format>
```

**Step 1 :** Écrire le prompt dans le fichier mailbox

**Step 2 :** Verify : prompt < 2000 chars (anti-GF2), structure CTCO+XML respectée.

---

### Task 1.2 — Dispatch G1 prompt à Session D via mailbox

**Step 1 :** Le fichier `002_A_G1_prompt.md` est déjà dans le dossier mailbox (Task 1.1)

**Step 2 :** Session A peut écrire `_mailbox/E1_salikhov_2026-05-06/003_A_to_D_signal.md` pour signaler à Session D « lis 002 et réponds dans 004_D_response_G1.md »

**Step 3 :** Session D détectera (via ScheduleWakeup mailbox polling ou Eric ping) et écrira sa réponse

**Verify :** `004_D_response_G1.md` apparaît dans le dossier mailbox.

---

### Task 1.3 — Dispatch G1 prompt à Gemini Pro via Chrome MCP

**Step 1 :** Get tabs context
```
mcp__Claude_in_Chrome__tabs_context_mcp avec createIfEmpty: false
```
Expected : voir Tab Gemini Pro (id ~1543732067 ou nouveau)

**Step 2 :** Activer le mode Deep Research si disponible (sélecteur composer)

**Step 3 :** Type le prompt G1 dans le composer Gemini

**Step 4 :** Submit + attendre la réponse (15-60s)

**Step 5 :** Lire la réponse via `read_page` ou `get_page_text`

**Step 6 :** Sauvegarder dans `_mailbox/E1_salikhov_2026-05-06/005_Gemini_response_G1.md` avec frontmatter approprié

**Verify :** Fichier créé, réponse > 300 chars, contient « VALIDE / RAFFINER / REJETER ».

---

### Task 1.4 — Dispatch G1 prompt à ChatGPT 5.5 via Chrome MCP

**Step 1 :** Tab ChatGPT (id ~1543732070)

**Step 2 :** Vérifier mode « Étendue » via dropdown sélecteur — fallback Instant si silent failure (cf. META_PROMPT_C §7)

**Step 3 :** Type le prompt G1

**Step 4 :** Submit + attendre la réponse

**Step 5 :** Lire la réponse, vérifier longueur > 300 chars (sinon silent failure pattern)

**Step 6 :** Sauvegarder dans `006_ChatGPT_response_G1.md`

**Verify :** Si silent failure (textContent ~15-30 chars), fallback (a) demander Eric copy-paste écran ou (b) basculer Instant.

---

### Task 1.5 — Dispatch G1 prompt à Claude.ai web via Chrome MCP

**Step 1 :** Tab Claude.ai Opus 4.7 (id ~1543732071, login confirmé « Eric est de retour », Plan Max actif)

**Step 2 :** Vérifier mode « Adaptatif » (déjà sélectionné)

**Step 3 :** Type le prompt G1

**Step 4 :** Submit + attendre la réponse

**Step 5 :** Lire la réponse

**Step 6 :** Sauvegarder dans `007_ClaudeAI_response_G1.md`

**Verify :** Réponse cohérente Claude (style typique), pas de silent failure.

---

### Task 1.6 — Réponse Session A interne à G1

**Files :**
- Create : `_mailbox/E1_salikhov_2026-05-06/008_A_response_G1.md`

**Step 1 :** Session A raisonne en interne sur les 5 questions du prompt G1

**Step 2 :** Écrire la réponse dans le fichier mailbox avec frontmatter approprié

**Step 3 :** Conclure « VALIDE tel quel » ou « RAFFINER vers : [...] »

**Verify :** Réponse cohérente avec design doc, pas de contradiction avec δ10 existant.

---

### Task 1.7 — Cross-comparaison + détection divergences

**Files :**
- Create : `_mailbox/E1_salikhov_2026-05-06/009_A_G1_comparison.md`

**Step 1 :** Lire les 5 réponses (D, Gemini, ChatGPT, Claude.ai, A)

**Step 2 :** Tableau comparatif :
| IA | Q1 valide ? | Q2 raffinement | Q3 hypothèses | Q4 f(k) | Q5 vs δ10 |
|----|-----------|----------------|---------------|---------|-----------|
| ... | ... | ... | ... | ... | ... |

**Step 3 :** Identifier les divergences fortes (≥ 2 IA en désaccord sur un point)

**Step 4 :** Écrire la synthèse comparative dans le fichier mailbox

**Verify :** Tableau complet 5 lignes, divergences listées explicitement.

---

### Task 1.8 — Itération si non-unanime

**Step 1 :** Si **unanimité atteinte** → skip à Task 1.9

**Step 2 :** Sinon, Session A écrit un follow-up prompt qui adresse spécifiquement les divergences détectées
- Format : « Q6 : [IA divergente X] propose [...]. [IAs convergents Y,Z] proposent [...]. Pouvez-vous reconverger ? »

**Step 3 :** Re-dispatch follow-up aux 5 IA (re-exécuter Tasks 1.2-1.6 avec nouveau prompt)

**Step 4 :** Re-cross-compare

**Step 5 :** Boucle jusqu'à unanimité OU max 3 itérations OU décision Eric d'arbitrer

**Verify :** Convergence atteinte (5/5 même verdict) ou escalade Eric.

---

### Task 1.9 — Rédiger CONSENSUS_5IA_DELTA11_G1

**Files :**
- Create : `/Users/ericmerle/Documents/collatz-lab-audit/findings/CONSENSUS_5IA_DELTA11_G1.md`

**Step 1 :** Document final avec :
- Énoncé δ11 finalisé (texte exact)
- Hypothèses explicites
- f(k) précise
- Position relative δ10 (clarifiée)
- Tableau 5/5 IA convergence
- Citations Salikhov 2007 Doklady Math. 76(3)

**Step 2 :** Écrire le document (~3-4 KB)

**Verify :** Document complet, citations DOI vérifiables, énoncé sans ambiguïté.

---

### Task 1.10 — Eric review G1 verdict

**Step 1 :** Session A présente CONSENSUS_5IA_DELTA11_G1.md à Eric en chat avec résumé 5 lignes

**Step 2 :** Eric valide ou demande ajustements

**Step 3 :** Si KO Eric, retour Task 1.8

**Verify :** Eric chat OK explicite « G1 validé, go G2 ».

---

## Phase 2 — Pre-registration + branche dédiée (J2)

### Task 2.1 — Session D rédige PREREG_E1_DELTA11

**Files :**
- Create : `/Users/ericmerle/Documents/collatz-lab-audit/findings/PREREG_E1_DELTA11.md`

**Step 1 :** Session D lit CONSENSUS_5IA_DELTA11_G1.md

**Step 2 :** Session D rédige pre-registration (GF9) avec :
- Énoncé exact attendu (depuis G1)
- Axiomes nécessaires anticipés (cible [propext] kernel-1)
- Tactiques anticipées (omega, nlinarith, Mathlib bounds spécifiques)
- Effort estimé en heures
- Probabilité succès first try (%)

**Verify :** Document existant, signé Session D, timestamp.

---

### Task 2.2 — Créer branche `study/E1-salikhov-2007-impossibility`

**Files :**
- Branch : `study/E1-salikhov-2007-impossibility` (nouvelle, jamais existé)

**Step 1 :** Session D ou Session A (selon dispo) :
```bash
cd /Users/ericmerle/Documents/collatz-conditional-cycles
git checkout arsenal-postjar
git pull origin arsenal-postjar  # latest
git checkout -b study/E1-salikhov-2007-impossibility
```

**Step 2 :** Vérifier branche active
```bash
git branch --show-current
```
Expected : `study/E1-salikhov-2007-impossibility`

**Step 3 :** Verify untracked files inchangés (pas de pollution)
```bash
git status
```

**Verify :** Sur la nouvelle branche, working tree similaire à arsenal-postjar.

---

### Task 2.3 — Vérifier EXCLUSIONS + BakerSeparation intacts

**Step 1 :** Lire EXCLUSIONS_LIST.md
```bash
cat /Users/ericmerle/Documents/collatz-lab-audit/findings/EXCLUSIONS_LIST.md
```

**Step 2 :** Pour chaque fichier listé, `git diff arsenal-postjar` vide

**Step 3 :** Compter occurrences BakerSeparation
```bash
grep -rn "BakerSeparation" /Users/ericmerle/Documents/collatz-conditional-cycles/ProjetCollatz/ | wc -l
```
Expected : ~70 (cohérent avec META_PROMPT_C)

**Verify :** Aucune modif EXCLUSIONS, BakerSeparation count stable.

---

## Phase 3 (G2) — Preuve Lean (J3-5)

### Task 3.1 — Session D drafte squelette `Delta11Salikhov.lean`

**Files :**
- Create : `/Users/ericmerle/Documents/collatz-conditional-cycles/ProjetCollatz/PostJAR/Delta11Salikhov.lean`

**Step 1 :** Session D crée le fichier avec en-tête, imports, énoncé principal + sorry

**Step 2 :** Énoncé :
```lean
theorem delta11_salikhov_insufficient_for_3732 :
  ∀ (k : ℕ), k ∈ Finset.Icc 3694 3732 →
    ¬ (∃ (f : ℕ → ℝ), salikhov_bound_implies f ∧ closes_collatz_branch f k) := by
  sorry
```
(pseudocode — sera raffiné selon CONSENSUS_5IA)

**Step 3 :** Build initial pour vérifier compilation imports
```bash
cd /Users/ericmerle/Documents/collatz-conditional-cycles
lake build ProjetCollatz.PostJAR.Delta11Salikhov 2>&1 | tail -20
```
Expected : compile avec warning sorry, pas d'error.

---

### Task 3.2 — Cross-validation chunk énoncé Lean

**Step 1 :** Session A copie l'énoncé Lean dans un message mailbox `010_A_lean_skeleton_review.md`

**Step 2 :** Dispatch chunk aux 3 IA web (Gemini/ChatGPT/Claude.ai) via Chrome MCP avec prompt « Cet énoncé Lean capte-t-il bien la sémantique du CONSENSUS_5IA_DELTA11 ? »

**Step 3 :** Collecter 3 réponses dans `011_Gemini_lean_review.md`, `012_ChatGPT_lean_review.md`, `013_ClaudeAI_lean_review.md`

**Verify :** 3/3 OK ou itération.

---

### Task 3.3 — Session D remplit la preuve tactique-par-tactique

**Step 1 :** Session D décompose l'énoncé en sous-lemmes (probable structure : (a) Salikhov bound formalisée → (b) inégalité dérivée trop faible → (c) impossibilité fermer cycle)

**Step 2 :** Pour chaque sous-lemme, écrire la preuve avec tactiques Lean

**Step 3 :** Build incrémental après chaque sous-lemme
```bash
lake build ProjetCollatz.PostJAR.Delta11Salikhov
```

**Step 4 :** Si erreur → diagnostiquer + fix + rebuild

**Verify :** lake build vert, 0 sorry, 0 admit.

---

### Task 3.4 — Vérifier profil axiomes

**Step 1 :** Lean command pour profil axiomes
```lean
#print axioms delta11_salikhov_insufficient_for_3732
```

**Step 2 :** Expected : `[propext]` (kernel-1) ou `[propext, Classical.choice, Quot.sound]` (kernel-3)

**Step 3 :** Si autres axiomes apparaissent → analyser pourquoi + tenter de les éliminer

**Verify :** Profil minimal documenté.

---

### Task 3.5 — Cross-validation finale Lean

**Step 1 :** Session A dispatch le fichier Lean complet aux 3 IA web (chunked si > 2000 chars)

**Step 2 :** Demander : « Cette preuve Lean est-elle correcte ? Tactiques utilisées appropriées ? Pas de cas limite oublié ? »

**Step 3 :** Collecter 3 réponses

**Step 4 :** Si convergence → G2 PASS. Sinon, itérer fix.

**Verify :** 5/5 OK (D + Gemini + ChatGPT + Claude.ai + A).

---

### Task 3.6 — Commit Lean sur branche dédiée

**Step 1 :** Session D
```bash
cd /Users/ericmerle/Documents/collatz-conditional-cycles
git add ProjetCollatz/PostJAR/Delta11Salikhov.lean
git commit -m "$(cat <<'EOF'
Add δ11 Salikhov-Insufficient-for-3732 lemma

Formal proof in Lean 4 that Salikhov 2007 (μ ≤ 5.125) is INSUFFICIENT
for sub-branche k ∈ [3694, 3732] (gap between Salikhov k_max=3693 and
Wu k_max=3732). Refines δ10 globally → δ11 granular.

0 sorry, axiom profile [propext] kernel-1 (matching δ10 standard).

5-IA cross-validation: Session D + Gemini Pro + ChatGPT 5.5 + Claude.ai + Session A.
Branch: study/E1-salikhov-2007-impossibility (NEVER main, NEVER push without Eric OK).

Pre-registration: findings/PREREG_E1_DELTA11.md (GF9).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

**Verify :** Commit créé, working tree clean post-commit.

---

## Phase 4 (G3) — Audits primary + cross-validation (J6)

### Task 4.1 — Session D dispatche 3 sub-agents parallèles (primary)

**Acteur** : Session D (Opus 4.7 CLI) via Agent tool

**Files :**
- Create : `findings/E1_audit_red_team_primary.md` (D-1)
- Create : `findings/E1_audit_nasa_primary.md` (D-2)
- Create : `findings/E1_audit_ares_primary.md` (D-3)

**Step 1 :** Session D lit les templates audit dans `collatz-lab-audit/findings/` :
- `AUDIT_RED_TEAM_REPORT_CGS7.md` (12 pts RT1-RT12)
- `AUDIT_NASA_REPORT_CGS7.md` (15 pts N1-N15)
- `AUDIT_ARES_REPORT_CGS7.md` (10 pts A1-A10)

**Step 2 :** Session D rédige 3 prompts d'audit (un par protocole) ciblés sur :
- `Delta11Salikhov.lean` (commit hash post-G2)
- design doc commit `ac285d3`
- pre-registration `findings/PREREG_E1_DELTA11.md`
- consensus G1 `findings/CONSENSUS_5IA_DELTA11_G1.md`

**Step 3 :** Session D dispatche les 3 sub-agents **dans un seul tool_use block** Agent tool en parallèle :
```
Agent(description="Red Team E1 audit", subagent_type="general-purpose", prompt="<RT 12pts prompt + Lean file path + Lean local read access>")
Agent(description="NASA E1 audit", subagent_type="general-purpose", prompt="<NASA 15pts prompt + lake build edge cases>")
Agent(description="ARES E1 audit", subagent_type="general-purpose", prompt="<ARES 10pts prompt + adversarial focus>")
# Les 3 lances dans le meme message → vrai parallèle (Claude Code Agent tool)
```

**Step 4 :** Session D collecte les 3 verdicts retournés (chaque sub-agent renvoie son rapport)

**Step 5 :** Session D écrit les 3 rapports dans `collatz-lab-audit/findings/` avec frontmatter YAML :
- Score X/12, X/15, X/10 explicite
- Verdict PASS/FAIL/NOTE par critère
- Conclusion globale PASS/FAIL/itérer

**Verify :** 3 fichiers créés, scores explicites, verdict global PASS unanime ou FAIL identifié + root cause.

**Si échec sub-agent :** Re-dispatch avec prompt raffiné. Max 2 itérations avant escalade Eric.

---

### Task 4.2 — ChatGPT shadow Red Team (cross-val cross-modèle)

**Files :**
- Create : `_mailbox/E1_salikhov_2026-05-06/020_A_chatgpt_RT_prompt.md`
- Create : `findings/E1_audit_red_team_shadow_chatgpt.md`

**Step 1 :** Session A drafte prompt ChatGPT thinking étendu (CTCO + XML, anti-base64 GF2)

**Step 2 :** Session A dispatch via Chrome MCP onglet ChatGPT 5.5

**Step 3 :** Si silent failure (textContent < 100 chars) → fallback Eric copy-paste écran

**Step 4 :** Collecter réponse, sauvegarder

**Verify :** Score X/12 explicite, comparaison post-hoc avec D-1 primary cohérente OU divergence analysée.

---

### Task 4.3 — Claude.ai shadow NASA (cross-val cross-Claude pur)

**Files :**
- Create : `_mailbox/E1_salikhov_2026-05-06/021_A_claudeai_NASA_prompt.md`
- Create : `findings/E1_audit_nasa_shadow_claude.md`

**Step 1 :** Session A drafte prompt Claude.ai web (mode Adaptatif) avec instruction « Refais indépendamment, ne regarde pas D-2 primary »

**Step 2 :** Dispatch via Chrome MCP onglet Claude.ai (Tab 1543732071)

**Step 3 :** Collecter réponse, sauvegarder

**Verify :** Score X/15 + comparaison post-hoc avec D-2 primary. Si divergence → cross-Claude blind spot identifié (révèle effet scaffolding même modèle).

---

### Task 4.4 — Gemini shadow ARES (cross-val cross-modèle Deep Research)

**Files :**
- Create : `_mailbox/E1_salikhov_2026-05-06/022_A_gemini_ARES_prompt.md`
- Create : `findings/E1_audit_ares_shadow_gemini.md`

**Step 1 :** Session A drafte prompt Gemini Pro avec Deep Research mode actif (vérification DOI Salikhov 2007 + Wu 2003)

**Step 2 :** Dispatch via Chrome MCP onglet Gemini

**Step 3 :** Collecter réponse Deep Research (peut prendre 2-5 min)

**Verify :** Score X/10 + bibliographie vérifiée externe + comparaison post-hoc avec D-3 primary.

---

### Task 4.5 — Session A meta-audit synthesis 5-IA

**Files :**
- Create : `findings/E1_meta_audit_synthesis.md`

**Step 1 :** Session A lit les 6 audits :
- Primary D-1 RT, D-2 NASA, D-3 ARES (Session D sub-agents)
- Shadow ChatGPT RT, Claude.ai NASA, Gemini ARES

**Step 2 :** Tableau récap par protocole :
| Protocole | Primary (Session D) | Cross-val (externe) | Convergent ? | Notes |
|-----------|---------------------|---------------------|--------------|-------|
| Red Team 12 | D-1 score X/12 | ChatGPT score Y/12 | OUI/NON | ... |
| NASA 15 | D-2 score X/15 | Claude.ai score Y/15 | OUI/NON | ... |
| ARES 10 | D-3 score X/10 | Gemini score Y/10 | OUI/NON | ... |

**Step 3 :** Anti-corrélation 3 niveaux check :
- Sub-agents Session D inter-cohérence (3 prompts différents convergent ou non) ?
- Cross-modèle convergent (D-1 vs ChatGPT, D-3 vs Gemini) ?
- Cross-Claude convergent (D-2 vs Claude.ai) ?

**Step 4 :** Verdict G3 final :
- ✅ PASS unanime sur 3 protocoles + 3 niveaux anti-corr → G3 GREEN
- ⚠️ Divergence quelconque → analyser source (model bias / scaffolding bias) avant validation
- ❌ FAIL primary ou cross-val → fix iteration loop (retour G2 ou G1 selon root cause)

**Verify :** Synthèse complète, divergences explicites si applicable, recommandation Eric.

---

### Task 4.6 — Provenance graph (GF10)

**Acteur** : Session D (Opus 4.7 CLI) en post-G3

**Files :**
- Create : `/Users/ericmerle/Documents/collatz-lab-audit/findings/PROVENANCE_DELTA11.md`

**Step 1 :** Session D documente le lineage complet :
- Claim : δ11 Salikhov-Insufficient-for-3732
- Theorem Lean : `delta11_salikhov_insufficient_for_3732` dans `Delta11Salikhov.lean`
- Axioms : [propext] (kernel-1) ou kernel-3 (selon résultat G2)
- Sources externes : Salikhov 2007 (DOI Doklady Math. 76(3)), Wu 2003 (DOI), δ10 (branch + commit)
- Tests connexes : REQ-MATH-003 (`tests_math/test_REQ-MATH-003_wu_salikhov_kmax.py`)
- Audits : 3 primary + 3 shadow + 1 meta-synthesis (chemins findings/ explicites)

**Verify :** Lineage complet, vérifiable indépendamment, DOIs résolvables.

---

## Phase 5 — Site update (J7)

### Task 5.1 — MAJ `papers/index.html` L372-378

**Files :**
- Modify : `/Users/ericmerle/Documents/collatz-gh-pages/papers/index.html` lignes 372-378

**Step 1 :** Décider de la reformulation post-G3 :
- Option A : raturer le bloc E.1 (ne plus présenter Salikhov comme alternative équivalente à Wu)
- Option B : reformuler avec précision (Salikhov ferme k≤3693, Wu ferme k≤3732, gap [3694,3732] traité par δ11 impossibility)

**Step 2 :** Edit lignes 372-378 avec la formulation choisie

**Step 3 :** Verify localement (ouvrir le HTML dans browser local)

**Verify :** Texte FR + EN cohérents, pas de cassure HTML.

---

### Task 5.2 — MAJ `assets/data/pistes.json` E.1 entry

**Files :**
- Modify : `/Users/ericmerle/Documents/collatz-gh-pages/assets/data/pistes.json` ligne 105-120

**Step 1 :** Changer status E.1 de `partiel` test4=3/4 à... ?
- Si δ11 prouvé impossibilité : status devient `impossible-formal-proof` (nouveau status à créer ?) OU `prouve` (avec sens « impossibilité prouvée ») OU `closed-with-impossibility-lemma`

**Step 2 :** Mettre à jour `lean: "Delta11Salikhov (prouvé)"`, `leanFile: "ProjetCollatz/PostJAR/Delta11Salikhov.lean"`

**Step 3 :** Mettre à jour `why` FR + EN avec mention δ11 + commit hash

**Verify :** JSON valide (`jq . pistes.json > /dev/null`).

---

### Task 5.3 — MAJ `changelog/index.html` (entrée δ11)

**Files :**
- Modify : `/Users/ericmerle/Documents/collatz-gh-pages/changelog/index.html`

**Step 1 :** Ajouter entrée timeline date 2026-05-07 ou date push :
- δ11 Salikhov-Insufficient-for-3732 lemma — Phase 65 (kernel-1)
- 5-IA validation
- Mea culpa #29 si applicable (papers/index.html L375 imprécision corrigée)

**Step 2 :** Si mea culpa, ajouter dans la section mea culpa avec numéro #29

**Verify :** HTML valide, lien pointe vers commit branche.

---

### Task 5.4 — MAJ `index.html` si frise/diagrams impactés

**Step 1 :** Vérifier mentions Salikhov dans index.html
```bash
grep -n "Salikhov" /Users/ericmerle/Documents/collatz-gh-pages/index.html
```

**Step 2 :** Si mentions → reformuler pour cohérence avec δ11 (notamment ligne 304, 651-652 selon notes summary)

**Step 3 :** Verify cohérence diagrams Mermaid si applicables

---

### Task 5.5 — Cross-validation Claude.ai sur copy site

**Step 1 :** Session A dispatch les 4 fichiers modifiés à Claude.ai pour relecture éditoriale

**Step 2 :** Demander : « Ce texte est-il clair, sans surenchère, conforme open science ? »

**Step 3 :** Collecter feedback, appliquer corrections mineures si pertinent

**Verify :** Claude.ai OK sur la copy.

---

### Task 5.6 — Commit site updates sur gh-pages

**Files :**
- Branch : gh-pages (collatz-gh-pages)

**Step 1 :** Bash :
```bash
cd /Users/ericmerle/Documents/collatz-gh-pages
git add papers/index.html assets/data/pistes.json changelog/index.html
git status  # vérifier les 3 fichiers staged
git commit -m "$(cat <<'EOF'
δ11 Salikhov-Insufficient-for-3732 lemma SHIPPED → MAJ site

E.1 Salikhov 2007 (μ ≤ 5.125) closure formalisée :
- papers/index.html L372-378 reformulé (Salikhov k≤3693, pas k≤3732)
- pistes.json E.1 entry status mis à jour avec δ11 commit
- changelog/index.html entry δ11 + mea culpa #29 (si applicable)

Impossibility lemma 5-IA validée : Session A + Session D + Gemini + ChatGPT + Claude.ai
(2 axes anti-corrélation : modèles + scaffolding D-CLI vs Claude-web).

Branch: study/E1-salikhov-2007-impossibility (collatz-conditional-cycles).
Push origin nécessite Eric chat OK explicite (verrou GF8).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

**Verify :** Commit créé local.

---

## Phase 6 — Push origin (Eric chat OK requis)

### Task 6.1 — Eric chat OK explicite

**Step 1 :** Session A présente résumé final à Eric :
- δ11 prouvé Lean 0 sorry kernel-1
- 5-IA validation 5/5
- 5 audits PASS unanimes
- Site MAJ local prêt
- 2 commits locaux : `study/E1-salikhov-2007-impossibility` (Lean) + `gh-pages` (site)

**Step 2 :** Demander Eric chat OK explicite pour push origin

**Verify :** Eric répond « OK push » ou équivalent explicite (pas implicite).

---

### Task 6.2 — Push branche `study/E1-salikhov-2007-impossibility`

**Step 1 :** Bash :
```bash
cd /Users/ericmerle/Documents/collatz-conditional-cycles
git push origin study/E1-salikhov-2007-impossibility
```

**Step 2 :** Verify
```bash
git log --oneline origin/study/E1-salikhov-2007-impossibility -3
```

**Verify :** Branche apparaît sur GitHub.

---

### Task 6.3 — Tag annoté

**Step 1 :** Bash :
```bash
cd /Users/ericmerle/Documents/collatz-conditional-cycles
git tag -a v0.7.3-delta11 -m "δ11 Salikhov-Insufficient-for-3732 impossibility lemma (E.1 closure, 5-IA validated)"
git push origin v0.7.3-delta11
```

**Verify :** Tag visible sur GitHub.

---

### Task 6.4 — Push gh-pages

**Step 1 :** Bash :
```bash
cd /Users/ericmerle/Documents/collatz-gh-pages
git push origin gh-pages
```

**Step 2 :** Cloudflare propag ETA ~3-5 min

**Verify :** `curl https://collatz-lab.org/papers/` montre la nouvelle copy après propagation.

---

### Task 6.5 — Verification finale

**Step 1 :** EXCLUSIONS check final
```bash
cd /Users/ericmerle/Documents/collatz-conditional-cycles
diff <(git show study/E1-salikhov-2007-impossibility:<EXCLUSION-FILE>) <(git show arsenal-postjar:<EXCLUSION-FILE>)
```
(répéter pour les 14 fichiers)

**Step 2 :** BakerSeparation count
```bash
grep -rn "BakerSeparation" ProjetCollatz/ | wc -l
```
Expected : ~70 (stable depuis avant mission)

**Step 3 :** Working tree clean partout
```bash
cd /Users/ericmerle/Documents/collatz-conditional-cycles && git status
cd /Users/ericmerle/Documents/collatz-gh-pages && git status
```

**Verify :** Tout clean, pas de pollution résiduelle.

---

### Task 6.6 — Mailbox archive final

**Step 1 :** Session A écrit `_mailbox/E1_salikhov_2026-05-06/999_FINAL_summary.md` avec :
- Récap mission (durée réelle, gates traversés, divergences notables)
- Liens commits + tag + URLs site
- Lessons learned + ADR-0005 candidat si pattern réutilisable

**Verify :** Archive complète, mission close.

---

## Critères de succès globaux

- ✅ δ11 prouvé Lean 0 sorry, kernel-1 [propext] (idéal) ou kernel-3 (acceptable)
- ✅ 5-IA convergent à G1 + G2 + G3 (15/15 verdicts PASS)
- ✅ Cross-Claude NASA convergent ou divergence analysée
- ✅ Branche `study/E1-salikhov-2007-impossibility` pushée + tag annoté
- ✅ Site MAJ propagée Cloudflare
- ✅ Mea culpa #29 ajouté si discordance Salikhov/Wu confirmée
- ✅ EXCLUSIONS 14 + BakerSeparation 70 occ intacts
- ✅ Pas un seul push origin sans Eric chat OK explicite

## Plans B en cas d'échec

| Échec phase | Plan B |
|-------------|--------|
| G1 divergence persistante | Eric arbitre ; sinon abandonner δ11 forme actuelle, reformuler |
| G2 sorry irréductible | Documenter échec ; conclure δ11 conjecturé (pas prouvé) ; MAJ site avec disclaimer |
| G3 audit FAIL | Iter fix ; si > 2 itérations échec, escalader Eric |
| Salikhov 2007 PDF introuvable | Fallback dérivation depuis citations δ10 + REQ-MATH-003 |
| Cross-Claude divergence | Signal NOTABLE — analyser source, peut révéler biais d'env |
| Eric refuse push | Branche reste locale, mission concluante quand même côté preuve |

---

*Plan validé pour exécution. Skill `superpowers:writing-plans` étape 6 brainstorming complète. Prochaine étape : invoquer `superpowers:executing-plans` ou `superpowers:subagent-driven-development` selon choix Eric.*
