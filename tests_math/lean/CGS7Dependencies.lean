/-
CGS7Dependencies.lean — Dépendances minimales de CGS7Theorem (Phase 8 build)

Extraction des **deux lemmes nécessaires** depuis `ChatGPTLemmas_test.lean`,
patchés pour compiler avec Mathlib v4.27 :
  1. `one_step_strict_increase_if_s_eq_one` — préalable utilisé en interne
  2. `drop_forces_s_ge_two` — utilisé directement par `CGS7Theorem.cgs7_dynamic_transfer`

POURQUOI un fichier séparé ?
  Le fichier original `ChatGPTLemmas_test.lean` contient 9 lemmes (sections 3.1-3.6).
  Plusieurs lemmes auxiliaires (sections 3.5, 3.6) utilisent des API Mathlib v4 plus
  anciennes (`Finset.card_le_sum`, `Finset.sum_eq_add_sum_erase`, `Finset.card_Ico`)
  qui ont été renommées/déplacées en Mathlib v4.27. Pour le build CGS-7, on n'a
  besoin QUE des 2 lemmes ci-dessus, donc on les extrait dans ce fichier dédié
  pour éviter de devoir patcher tous les lemmes auxiliaires non utilisés.

  Les lemmes restants de ChatGPTLemmas_test (block_sum_s_ge_length_plus_one,
  sum_blocks_ge_lengths_plus_card, abstract_decomposition_*) ne sont PAS
  utilisés par CGS-7 en raison du choix Option C-bis (décomposition directe
  via `1 + indicatrice` plutôt que via le lemme abstrait l.234), validé 4/4 IA.

  → Ce fichier respecte le critère ARES "0 nouvelle dépendance externe non auditée"
  car les preuves ici sont identiques (modulo patches v4.27) à celles auditées
  Phase 1 dans `ChatGPTLemmas_test.lean`.
-/

import Mathlib

namespace ProjetCollatz.PostJAR.CGS7Dependencies

/-! ## Lemme 1 : si s = 1, l'odd Collatz step augmente

(Identique à `ChatGPTLemmas_test.one_step_strict_increase_if_s_eq_one`, l. 127, patché v4.27) -/

theorem one_step_strict_increase_if_s_eq_one
    (x y : ℕ)
    (hx : x > 1)
    (heq : y = (3 * x + 1) / 2) :
    x < y := by
  subst y
  have hnum : (x + 1) * 2 ≤ 3 * x + 1 := by linarith
  have hdiv : x + 1 ≤ (3 * x + 1) / 2 :=
    (Nat.le_div_iff_mul_le (by norm_num : 0 < 2)).2 hnum
  omega

/-! ## Lemme 2 : descente forcée → s ≥ 2

(Identique à `ChatGPTLemmas_test.drop_forces_s_ge_two`, l. 139, inchangé) -/

theorem drop_forces_s_ge_two
    (x y s : ℕ)
    (hx : x > 1)
    (hs : 1 ≤ s)
    (heq : y = (3 * x + 1) / 2 ^ s)
    (hdrop : y ≤ x) :
    2 ≤ s := by
  by_contra hnot
  have hs_eq : s = 1 := by omega
  subst s
  simp at heq
  have hinc : x < y :=
    one_step_strict_increase_if_s_eq_one x y hx heq
  omega

end ProjetCollatz.PostJAR.CGS7Dependencies
