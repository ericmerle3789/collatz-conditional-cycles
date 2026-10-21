import Labo.S1_X02_H3
/-!
# LABO-COLLATZ · S1 · A4 — H1 on 2 ≤ k ≤ 1322 as a kernel-checked finite fact (no `native_decide`)

Answers A1 (Diophante, S1): `no_cycle_k_le_1322` needs H1 only at the cycle's own k ≤ 1322
(`S1_no_cycle_k_le_1322_local`); here that finite H1 is PROVED by kernel reduction (`decide +kernel`,
GMP-accelerated `Nat.pow`/`Nat.log2`), so the theorem depends on Barina's verification ALONE.
-/
namespace ProjetCollatz

/-- H1 at s = s_min(k) = log2(3^k) + 1. -/
def S1_chk (k : ℕ) : Bool := Nat.ble (3 ^ k) ((2 ^ (Nat.log2 (3 ^ k) + 1) - 3 ^ k) * k ^ 6)

/-- Kernel check over k = 2 … 1322. -/
theorem S1_chk_range : (List.range 1321).all (fun j => S1_chk (j + 2)) = true := by decide +kernel

theorem S1_chk_of_le (k : ℕ) (hk2 : 2 ≤ k) (hk : k ≤ 1322) : S1_chk k = true := by
  have h := List.all_eq_true.mp S1_chk_range (k - 2) (List.mem_range.mpr (by omega))
  have e : k - 2 + 2 = k := by omega
  rw [e] at h
  exact h

/-- **H1 restricted to 2 ≤ k ≤ 1322, for every s** (monotone in s above s_min). -/
theorem S1_H1_finite (s k : ℕ) (hs : s ≥ 1) (hk2 : 2 ≤ k) (hk : k ≤ 1322) (hgt : 2 ^ s > 3 ^ k) :
    (2 ^ s - 3 ^ k) * k ^ 6 ≥ 3 ^ k := by
  have hc := S1_chk_of_le k hk2 hk
  unfold S1_chk at hc
  have hc' : 3 ^ k ≤ (2 ^ (Nat.log2 (3 ^ k) + 1) - 3 ^ k) * k ^ 6 := Nat.le_of_ble_eq_true hc
  have hne : 3 ^ k ≠ 0 := by positivity
  have hL : 2 ^ Nat.log2 (3 ^ k) ≤ 3 ^ k := Nat.log2_self_le hne
  have hsL : Nat.log2 (3 ^ k) + 1 ≤ s := by
    by_contra h
    push_neg at h
    have : 2 ^ s ≤ 2 ^ Nat.log2 (3 ^ k) := Nat.pow_le_pow_right (by norm_num) (by omega)
    omega
  have hpow : 2 ^ (Nat.log2 (3 ^ k) + 1) ≤ 2 ^ s := Nat.pow_le_pow_right (by norm_num) hsL
  calc 3 ^ k ≤ (2 ^ (Nat.log2 (3 ^ k) + 1) - 3 ^ k) * k ^ 6 := hc'
    _ ≤ (2 ^ s - 3 ^ k) * k ^ 6 := Nat.mul_le_mul_right _ (Nat.sub_le_sub_right hpow _)

/-- **R03 made hypothesis-light.** No Collatz cycle with k ≤ 1322 odd steps, assuming ONLY Barina's
verification (all n < 2^71 reach 1). No Baker-type hypothesis, no `native_decide`. -/
theorem S1_no_cycle_k_le_1322_barina_only (barina : BarinaVerification)
    (n k : ℕ) (hcyc : IsOddCycle n k) (hk : k ≤ 1322) : False :=
  S1_no_cycle_k_le_1322_local barina S1_H1_finite n k hcyc hk

/-- NEGATIVE CONTROL 1: H1 fails at k = 1 (as Phase58 itself notes). -/
theorem S1_chk_one_false : S1_chk 1 = false := by decide +kernel

/-- NEGATIVE CONTROL 2: with exponent 0 in place of 6 the same kernel check must FAIL on 2 … 1322. -/
def S1_chk0 (k : ℕ) : Bool := Nat.ble (3 ^ k) (2 ^ (Nat.log2 (3 ^ k) + 1) - 3 ^ k)
theorem S1_chk0_range_fails : (List.range 1321).all (fun j => S1_chk0 (j + 2)) = false := by decide +kernel

/-- Canary (hand): k = 2, s_min = 4, (16 − 9)·2^6 = 448 ≥ 9. -/
theorem S1_canari_k2 : Nat.log2 (3 ^ 2) + 1 = 4 ∧ (2 ^ 4 - 3 ^ 2) * 2 ^ 6 = 448 := by decide +kernel

end ProjetCollatz

#print axioms ProjetCollatz.S1_chk_range
#print axioms ProjetCollatz.S1_H1_finite
#print axioms ProjetCollatz.S1_no_cycle_k_le_1322_barina_only
#print axioms ProjetCollatz.S1_chk_one_false
#print axioms ProjetCollatz.S1_chk0_range_fails
#print axioms ProjetCollatz.S1_canari_k2
#check @ProjetCollatz.S1_no_cycle_k_le_1322_barina_only
