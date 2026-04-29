/-
ChatGPTLemmas_test.lean

Test compilation des 6 lemmes ChatGPT du document `collatz_cycles_study_REGENERATED.md`
(sections 3.1 à 3.6).

REQ-MATH-007 : Vérifier que les lemmes proposés par ChatGPT compilent en Lean 4 + Mathlib.

ATTENTION : ce fichier est UN TEST, pas une intégration officielle.
Pas de commit sans coordination NEW (HANDOFF protocol).
-/

import Mathlib

namespace ProjetCollatz.PostJAR.ChatGPTLemmas

-- =============================================================================
-- 3.1 Strict peak in a non-flat block
-- =============================================================================

theorem exists_strict_peak_between_minima
    {a : ℕ → ℕ} {i j : ℕ}
    (hij : i < j)
    (hmin_i : ∀ t, i ≤ t → t ≤ j → a i ≤ a t)
    (hnonflat : ∃ t, i ≤ t ∧ t ≤ j ∧ a t ≠ a i) :
    ∃ u, i ≤ u ∧ u ≤ j ∧ a i < a u := by
  rcases hnonflat with ⟨t, hti, htj, hneq⟩
  have hle : a i ≤ a t := hmin_i t hti htj
  have hlt : a i < a t := Nat.lt_of_le_of_ne hle hneq.symm
  exact ⟨t, hti, htj, hlt⟩

-- =============================================================================
-- 3.2 Finset sum with one extra term
-- =============================================================================

open Finset

theorem sum_ge_card_plus_one_of_all_ge_one_exists_ge_two
    {α : Type} [DecidableEq α]
    (A : Finset α)
    (f : α → ℕ)
    (hall : ∀ x ∈ A, 1 ≤ f x)
    (hex : ∃ x ∈ A, 2 ≤ f x) :
    A.card + 1 ≤ ∑ x ∈ A, f x := by
  rcases hex with ⟨x0, hx0, hx2⟩

  have hrest :
      (A.erase x0).card ≤ ∑ x ∈ A.erase x0, f x := by
    refine Finset.card_le_sum ?_
    intro x hx
    exact hall x (Finset.mem_of_mem_erase hx)

  have hdecomp :
      ∑ x ∈ A, f x = f x0 + ∑ x ∈ A.erase x0, f x := by
    rw [Finset.sum_eq_add_sum_erase _ _ hx0]

  have hcard :
      A.card = (A.erase x0).card + 1 := by
    exact (Finset.card_erase_add_one hx0).symm

  rw [hdecomp, hcard]
  nlinarith

-- =============================================================================
-- 3.3 Strict growth over an interval
-- =============================================================================

theorem strict_steps_imply_endpoint_lt
    (a : ℕ → ℕ)
    {u r : ℕ}
    (hr : 0 < r)
    (hstep : ∀ t, u ≤ t → t < u + r → a t < a (t + 1)) :
    a u < a (u + r) := by
  induction r with
  | zero =>
      omega
  | succ r ih =>
      by_cases hzero : r = 0
      · subst r
        simpa using hstep u (by omega) (by omega)
      · have hrpos : 0 < r := by omega
        have hprev : a u < a (u + r) := by
          apply ih
          · exact hrpos
          · intro t htu ht
            apply hstep
            · exact htu
            · omega
        have hlast : a (u + r) < a (u + r + 1) := by
          apply hstep
          · omega
          · omega
        omega

theorem exists_nonincrease_step_if_endpoint_not_above
    (a : ℕ → ℕ)
    {u j : ℕ}
    (huj : u < j)
    (hend : a j ≤ a u) :
    ∃ t, u ≤ t ∧ t < j ∧ a (t + 1) ≤ a t := by
  by_contra h
  have hstrict : ∀ t, u ≤ t → t < j → a t < a (t + 1) := by
    intro t htu htj
    have hnot : ¬ a (t + 1) ≤ a t := by
      intro hle
      exact h ⟨t, htu, htj, hle⟩
    omega

  have hdist : 0 < j - u := by omega
  have hj : u + (j - u) = j := by omega

  have hlt : a u < a (u + (j - u)) := by
    apply strict_steps_imply_endpoint_lt
    · exact hdist
    · intro t htu ht
      apply hstrict
      · exact htu
      · omega

  rw [hj] at hlt
  omega

-- =============================================================================
-- 3.4 Si s = 1, l'odd Collatz step augmente
-- =============================================================================

theorem one_step_strict_increase_if_s_eq_one
    (x y : ℕ)
    (hx : x > 1)
    (heq : y = (3 * x + 1) / 2) :
    x < y := by
  subst y
  have hnum : 2 * (x + 1) ≤ 3 * x + 1 := by
    nlinarith
  have hdiv : x + 1 ≤ (3 * x + 1) / 2 := by
    exact (Nat.le_div_iff_mul_le (by norm_num : 0 < 2)).2 hnum
  omega

theorem drop_forces_s_ge_two
    (x y s : ℕ)
    (hx : x > 1)
    (hs : 1 ≤ s)
    (heq : y = (3 * x + 1) / 2^s)
    (hdrop : y ≤ x) :
    2 ≤ s := by
  by_contra hnot
  have hs_eq : s = 1 := by omega
  subst s
  simp at heq
  have hinc : x < y :=
    one_step_strict_increase_if_s_eq_one x y hx heq
  omega

-- =============================================================================
-- 3.5 Block valuation sum: local +1
-- =============================================================================

theorem block_sum_s_ge_length_plus_one
    (a s : ℕ → ℕ)
    {i j u : ℕ}
    (hij : i < j)
    (hiu : i ≤ u)
    (hu_lt_j : u < j)
    (hpeak : a i < a u)
    (hend : a j ≤ a u)
    (hs_pos : ∀ t, i ≤ t → t < j → 1 ≤ s t)
    (ha_pos : ∀ t, i ≤ t → t < j → a t > 1)
    (hstep : ∀ t, i ≤ t → t < j →
      a (t + 1) = (3 * a t + 1) / 2^(s t)) :
    (j - i) + 1 ≤ ∑ t ∈ Finset.Ico i j, s t := by
  obtain ⟨t, hut, htj, hdrop⟩ :=
    exists_nonincrease_step_if_endpoint_not_above a hu_lt_j hend

  have hit : i ≤ t := by omega

  have ht_mem : t ∈ Finset.Ico i j := by
    simp
    exact ⟨hit, htj⟩

  have hall : ∀ q ∈ Finset.Ico i j, 1 ≤ s q := by
    intro q hq
    simp at hq
    exact hs_pos q hq.1 hq.2

  have hs2 : 2 ≤ s t := by
    apply drop_forces_s_ge_two (a t) (a (t+1)) (s t)
    · exact ha_pos t hit htj
    · exact hs_pos t hit htj
    · exact hstep t hit htj
    · exact hdrop

  have hsum :
      (Finset.Ico i j).card + 1 ≤ ∑ q ∈ Finset.Ico i j, s q := by
    apply sum_ge_card_plus_one_of_all_ge_one_exists_ge_two
    · exact hall
    · exact ⟨t, ht_mem, hs2⟩

  have hcard : (Finset.Ico i j).card = j - i := by
    simp [Finset.card_Ico]

  simpa [hcard] using hsum

-- =============================================================================
-- 3.6 Abstract block summation
-- =============================================================================

theorem sum_blocks_ge_lengths_plus_card
    {ι : Type} [DecidableEq ι]
    (B : Finset ι)
    (len val : ι → ℕ)
    (hblock : ∀ b ∈ B, len b + 1 ≤ val b) :
    (∑ b ∈ B, len b) + B.card ≤ ∑ b ∈ B, val b := by
  have hsum :
      ∑ b ∈ B, (len b + 1) ≤ ∑ b ∈ B, val b := by
    exact Finset.sum_le_sum hblock

  have hrewrite :
      (∑ b ∈ B, (len b + 1)) =
        (∑ b ∈ B, len b) + B.card := by
    simp [Finset.sum_add_distrib]

  rw [← hrewrite]
  exact hsum

structure AbstractBlockDecomposition (ι : Type) where
  B : Finset ι
  len : ι → ℕ
  val : ι → ℕ
  totalLen : ℕ
  totalVal : ℕ
  len_sum : (∑ b ∈ B, len b) = totalLen
  val_sum : (∑ b ∈ B, val b) = totalVal

theorem abstract_decomposition_totalVal_ge_totalLen_plus_blocks
    {ι : Type} [DecidableEq ι]
    (D : AbstractBlockDecomposition ι)
    (hblock : ∀ b ∈ D.B, D.len b + 1 ≤ D.val b) :
    D.totalLen + D.B.card ≤ D.totalVal := by
  have h :=
    sum_blocks_ge_lengths_plus_card D.B D.len D.val hblock
  rw [D.len_sum, D.val_sum] at h
  exact h

end ProjetCollatz.PostJAR.ChatGPTLemmas
