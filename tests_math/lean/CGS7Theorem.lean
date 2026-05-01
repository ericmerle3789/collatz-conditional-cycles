/-
CGS7Theorem_DRAFT.lean — Phase 3 CGS-7 (Option C-bis : instanciation, pas from scratch)

Synthèse 4/4 IA (Session A + B + ChatGPT thinking étendu + Gemini Pro 3.1) du 2026-05-01.

ÉNONCÉ FINAL (reformulation ChatGPT, validée 4/4) :
  Pour un cycle impair avec x_t > 1, s_t ≥ 1 et x_{t+1} = (3·x_t + 1)/2^{s_t},
  poser N = #{t < k | x_{t+1} ≤ x_t}.
  Alors S = ∑_{t<k} s_t ≥ k + N.

PIVOT : l'esquisse NEW3 (29 avril 2026) avait écrit "from scratch" ce qui devait être
"instantiation". Le lemme abstrait `abstract_decomposition_totalVal_ge_totalLen_plus_blocks`
(ChatGPTLemmas_test.lean ligne 234) est isomorphe à CGS-7 (totalLen↔k, B.card↔D, totalVal↔S).
Il suffit donc de :
  1) instancier le lemme algébrique pur sur D = #{t | s_t ≥ 2}
  2) prouver le transfert dynamique N ⊆ D via `drop_forces_s_ge_two` (ligne 139)
  3) combiner par card_le_card

DRAFT pour relecture Session A + 3 audits (RED TEAM / NASA / ARES) + re-validation 4 IA.

GARDE-FOUS APPLIQUÉS (Eric directives 021 A→B) :
  ✅ 0 sorry
  ✅ Imports Mathlib + référence ChatGPTLemmas_test (ligne 139 et 234)
  ✅ Profil axiomes minimal kernel-3 standard attendu (à confirmer post-build)
  ✅ Aucune touch sur main / arsenal-postjar / gh-pages / study/* existants
  ✅ Draft strictement dans findings/ du repo collatz-lab-audit
-/

import Mathlib

-- Patch import Phase 8 build :
-- Au lieu d'importer le fichier `ChatGPTLemmas_test.lean` complet (qui contient
-- 9 lemmes auxiliaires, dont plusieurs avec des API Mathlib v4.x renommées en
-- v4.27), on importe `CGS7Dependencies` qui extrait UNIQUEMENT les 2 lemmes
-- nécessaires (`one_step_strict_increase_if_s_eq_one` + `drop_forces_s_ge_two`)
-- avec leurs preuves patchées pour Mathlib v4.27.
--
-- Cohérent avec le choix Option C-bis 4/4 IA : on n'utilise pas le lemme
-- abstrait `abstract_decomposition_totalVal_ge_totalLen_plus_blocks` (l. 234),
-- on fait une décomposition directe via `1 + indicatrice`.
import CGS7Dependencies
-- Pour la migration vers le repo conditional-cycles, ce fichier doit être placé
-- dans `tests_math/lean/CGS7Theorem.lean` avec la même branche d'origine.

open Finset

namespace ProjetCollatz.PostJAR.CGS7

/-! ## Lemme intermédiaire 1 : algébrique pur

Pour toute séquence `s : ℕ → ℕ` avec `s_t ≥ 1` sur `[0, k)`, la somme totale
est minorée par la longueur plus le cardinal des indices où `s_t ≥ 2`. -/

theorem cgs7_algebraic_pure
    (s : ℕ → ℕ) (k : ℕ)
    (hs : ∀ t, t < k → 1 ≤ s t) :
    k + ((Finset.range k).filter (fun t => 2 ≤ s t)).card
      ≤ ∑ t ∈ Finset.range k, s t := by
  -- Stratégie : minorer chaque terme par (1 + indicatrice 2 ≤ s_t),
  -- puis sommer et utiliser ∑ 1 = k et ∑ indicatrice = card du filter.
  have hpoint : ∀ t ∈ Finset.range k,
      1 + (if 2 ≤ s t then (1 : ℕ) else 0) ≤ s t := by
    intro t ht
    rw [Finset.mem_range] at ht
    have h1 : 1 ≤ s t := hs t ht
    by_cases h2 : 2 ≤ s t
    · -- Patch build P1bis : `simp [h2]` ferme déjà le but (h2 est l'hypothèse)
      simp [h2]
    · simp [h2]
      exact h1
  have hsum := Finset.sum_le_sum hpoint
  -- Calcul : ∑ (1 + ind) = k + filter.card
  -- Patch P1 + P5 (ChatGPT/Gemini convergent) : remplace `simp`-en-boucle par
  -- `Finset.sum_filter` + `Finset.sum_const` ciblé sans set complet de simp.
  have hcalc :
      (∑ t ∈ Finset.range k, (1 + (if 2 ≤ s t then (1 : ℕ) else 0)))
        = k + ((Finset.range k).filter (fun t => 2 ≤ s t)).card := by
    rw [Finset.sum_add_distrib]
    congr 1
    · -- ∑ 1 = k via card_range
      rw [Finset.sum_const, Finset.card_range]
      simp
    · -- ∑ t ∈ range k, (if 2≤s t then 1 else 0) = (filter (2≤s ·)).card
      -- Patch P5 (ChatGPT) : éviter `simp [..., card_eq_sum_ones]` qui boucle
      -- avec `sum_const`. Utilise rewrite ciblé et égalité directe.
      rw [← Finset.sum_filter, Finset.sum_const]
      simp
  linarith [hsum, hcalc.symm.le, hcalc.le]

/-! ## Lemme intermédiaire 2 : transfert dynamique

Application directe de `drop_forces_s_ge_two` (ChatGPTLemmas_test.lean ligne 139)
pour chaque indice où la trajectoire ne croît pas strictement. -/

theorem cgs7_dynamic_transfer
    (x : ℕ → ℕ) (s : ℕ → ℕ) (k : ℕ)
    (hx : ∀ t, t < k → x t > 1)
    (hs : ∀ t, t < k → 1 ≤ s t)
    (hcycle : ∀ t, t < k → x ((t + 1) % k) = (3 * x t + 1) / 2 ^ (s t)) :
    ∀ t, t < k → x ((t + 1) % k) ≤ x t → 2 ≤ s t := by
  intro t ht hdrop
  -- Application directe du lemme `drop_forces_s_ge_two`
  -- avec y = x_{t+1}, x = x_t (au sens du lemme).
  exact ProjetCollatz.PostJAR.CGS7Dependencies.drop_forces_s_ge_two
    (x t) (x ((t + 1) % k)) (s t)
    (hx t ht) (hs t ht) (hcycle t ht) hdrop

/-! ## Théorème final CGS-7 (synthèse 4 IA, énoncé ChatGPT)

`S = ∑_{t<k} s_t ≥ k + N` où `N = #{t < k | x_{t+1} ≤ x_t}`.

Preuve : combine cgs7_algebraic_pure + cgs7_dynamic_transfer via card_le_card. -/

-- Patch P3 (ChatGPT issue #3) : `hk : 0 < k` retiré car non utilisé dans la preuve.
-- Le théorème reste vrai pour k = 0 (cas trivial : 0 + 0 ≤ 0).
-- Pour la sémantique "cycle non vide", l'hypothèse k > 0 doit être imposée
-- au site d'utilisation (ex : phase59 du paper JAR).
theorem cgs7_final
    (x : ℕ → ℕ) (s : ℕ → ℕ) (k : ℕ)
    (hx : ∀ t, t < k → x t > 1)
    (hs : ∀ t, t < k → 1 ≤ s t)
    (hcycle : ∀ t, t < k → x ((t + 1) % k) = (3 * x t + 1) / 2 ^ (s t)) :
    k + ((Finset.range k).filter (fun t => x ((t + 1) % k) ≤ x t)).card
      ≤ ∑ t ∈ Finset.range k, s t := by
  -- Notation : N = filter dynamique, D = filter algébrique
  set N := (Finset.range k).filter (fun t => x ((t + 1) % k) ≤ x t) with hN_def
  set D := (Finset.range k).filter (fun t => 2 ≤ s t) with hD_def
  -- Inclusion N ⊆ D via cgs7_dynamic_transfer
  have hsubset : N ⊆ D := by
    intro t ht
    rw [Finset.mem_filter, Finset.mem_range] at ht
    obtain ⟨ht_range, ht_drop⟩ := ht
    rw [Finset.mem_filter, Finset.mem_range]
    exact ⟨ht_range, cgs7_dynamic_transfer x s k hx hs hcycle t ht_range ht_drop⟩
  -- Card monotone via inclusion
  have hcard : N.card ≤ D.card := Finset.card_le_card hsubset
  -- Borne algébrique
  have halg := cgs7_algebraic_pure s k hs
  -- Patch P4 (ChatGPT issue #4) : remplacement `linarith [hcard, halg]` par chaîne
  -- explicite `Nat.add_le_add_left` + `le_trans`. Plus lisible, moins dépendant
  -- des heuristiques `linarith` qui peuvent diverger sur ℕ.
  exact le_trans (Nat.add_le_add_left hcard k) halg

/-! ## TEST NÉGATIF RED TEAM EXÉCUTABLE (Patch P2 ChatGPT issue #2)

Garde-fou : la version avec `x_{t+1} ≥ x_t` (polarité inversée que NEW3 avait suggérée
dans son esquisse via "non-décroissants") NE DOIT PAS compiler par les mêmes outils.

Avant le patch P2, c'était un commentaire pseudo-code (refusé par ChatGPT
en Phase 3 : "un commentaire ne protège pas contre une régression").

**Patch P2** : test exécutable via `#check_failure`. Le compilateur Lean
échoue à typecheck l'expression, ce qui est précisément le comportement
attendu (le `#check_failure` lui-même réussit alors).

Si quelqu'un modifie `drop_forces_s_ge_two` pour accepter la polarité inversée,
le `#check_failure` ci-dessous va échouer (= l'expression typecheck),
et le build attire l'attention sur la régression. -/

section RedTeamNegativeTest
variable (x : ℕ → ℕ) (s : ℕ → ℕ) (k : ℕ)
variable (hx : ∀ t, t < k → x t > 1)
variable (hs : ∀ t, t < k → 1 ≤ s t)
variable (hcycle : ∀ t, t < k → x ((t + 1) % k) = (3 * x t + 1) / 2 ^ (s t))
variable (t : ℕ) (ht : t < k)
variable (hraise : x t ≤ x ((t + 1) % k))  -- polarité INVERSÉE (montée)

/-
  Test négatif : `drop_forces_s_ge_two` exige `y ≤ x` (descente faible),
  ici `y = x((t+1) % k)` et on lui passe `hraise : x t ≤ x((t+1) % k)`,
  qui est de type `x ≤ y` (montée) — type incompatible avec `y ≤ x`.
  Donc `drop_forces_s_ge_two ... hraise` ne typecheck PAS.
  `#check_failure` réussit ssi l'expression échoue à typecheck.
-/
#check_failure
  ProjetCollatz.PostJAR.CGS7Dependencies.drop_forces_s_ge_two
    (x t) (x ((t + 1) % k)) (s t)
    (hx t ht) (hs t ht) (hcycle t ht) hraise

end RedTeamNegativeTest

end ProjetCollatz.PostJAR.CGS7

/-! ## Métadonnées draft v2 (post Phase 3.5 patches ChatGPT)

- LOC ≈ 130 (objectif 80-100 légèrement dépassé pour intégrer test négatif exécutable P2)
- Sorry count : 0 ✅
- Lemmes externes utilisés (ChatGPTLemmas_test.lean, branche arsenal-postjar) :
  - `drop_forces_s_ge_two` (ligne 139) — utilisé dans `cgs7_dynamic_transfer` + test négatif RT
  - lemme abstract ligne 234 NON utilisé (validé par 4 IA en Phase 3, "approche locale plus robuste")
- Profil axiomes attendu (à confirmer post-`lake build` + `#print axioms cgs7_final`) :
    [propext, Classical.choice, Quot.sound] (kernel-3 standard)
- Test négatif Red Team : **EXÉCUTABLE via `#check_failure`** (patch P2 ChatGPT)
- Patches v2 (Session A, post-verdict ChatGPT 22:25) :
  - P1 (ligne 70) : `Finset.sum_ite_eq_sum_filter` → `Finset.sum_filter` + `Finset.card_eq_sum_ones`
  - P2 (fin namespace) : commentaire pseudo-code → `#check_failure` exécutable
  - P3 (cgs7_final) : `hk : 0 < k` retiré (inutilisé)
  - P4 (ligne 121) : `linarith [hcard, halg]` → `le_trans (Nat.add_le_add_left hcard k) halg`
- Phases restantes (pipeline Eric 021 A→B) :
  Phase 3.6 = re-validation 4 IA sur draft v2,
  Phase 4 = audit RED TEAM,
  Phase 5 = audit NASA,
  Phase 6 = audit ARES,
  Phase 7 = migration `study/cgs-7-instantiation`,
  Phase 8 = `lake build` (Session A en autonomie : GitHub Actions ou Mac M1),
  Phase 9 = propagation site exhaustive.
-/
