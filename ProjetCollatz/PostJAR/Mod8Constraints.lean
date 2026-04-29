import ProjetCollatz.PostJAR.ParityModConstraints

/-!
# Mod8Constraints.lean — Round 12: refined mod-8 lower bound on parity sums

This file extends `ParityModConstraints.lean` (Round 11, mod 4) to mod 8.
The four residue classes 1, 3, 5, 7 mod 8 give the following parity exponents:

| `n % 8` | `v_2(3n+1)` | Justification |
|---------|-------------|---------------|
| 1       | = 2         | A9 with r=1, k=3, v2(4)=2 < 3 |
| 3       | = 1         | A9 with r=3, k=3, v2(10)=1 < 3 |
| 5       | ≥ 3         | Direct: 3(5+8m)+1 = 16+24m = 8(2+3m), so 8 ∣ (3n+1) (stochastic class A10) |
| 7       | = 1         | A9 with r=7, k=3, v2(22)=1 < 3 |

## Main result

```
theorem cycle_parity_sum_lower_mod8 (n K : ℕ) (h_odd : n % 2 = 1) :
    aSumSeq n K ≥ K +
      |{i < K : nSeq n i % 4 = 1}| +
      |{i < K : nSeq n i % 8 = 5}|
```

This **strictly refines** Round 11's `cycle_parity_sum_lower_mod4` because
the additional term `a₅(K) = |{i < K : nSeq n i % 8 = 5}| ≥ 0` is non-negative
and the mod-4 count `a_4(K)` is preserved.

## Significance

This is the second lemma of Direction 5 (post-JAR research program). Together
with Round 11, the chain is being progressively refined toward the limit
`j → ∞` (mod 2^j hierarchy via theorem A9 = `v2_mod_stable`).

The refinement ratio: `Round 12 - Round 11 = a_5(K) ≥ 0`. So Round 12 is
strictly stronger or equal to Round 11.

When combined with Steiner's identity (`s ≈ K · log_2(3)`) for cycles:

  `K · log_2(3) ≥ K + a_4 + a_5`
  ⟹ `a_4 + a_5 ≤ K · (log_2(3) - 1) ≈ 0.585 K`

So **the count `n_i ≡ 1 mod 4` PLUS the count `n_i ≡ 5 mod 8`** is bounded
by ~58.5% of K. Equivalently, at least ~41.5% of n_i are ≡ 3 mod 4.
The mod-8 refinement separates the `≡ 1 mod 4` contribution into two
sub-cases (≡ 1 mod 8 with `s ≥ 2`, ≡ 5 mod 8 with `s ≥ 3`), giving a
sharper bound.

-/

namespace ProjetCollatz

open ProjetCollatz

/-!
## Auxiliary v_2 lemmas for mod 8 cases
-/

/-- **Lemma**: `n ≡ 1 (mod 8)` ⟹ `v_2(3n+1) = 2`.

Proof via A9 (`v2_mod_stable`) with `r = 1`, `k = 3`. Indeed
`v2Nat(3·1+1) = v2Nat(4) = 2 < 3`, so A9 yields `v2Nat(3·(1 + 8m) + 1) = 2`. -/
theorem v2_mod8_eq1_from_A9 (n : ℕ) (hmod : n % 8 = 1) :
    v2Nat (3 * n + 1) = 2 := by
  have hdiv := Nat.div_add_mod n 8
  set m := n / 8
  have hn : n = 1 + 8 * m := by omega
  rw [hn]
  have hbase : v2Nat (3 * 1 + 1) = 2 := by
    show v2Nat 4 = 2
    -- v2Nat(4) = 2: 4 = 2·2, v2(2) = 1, v2(4) = 1 + v2(2) = 1 + 1 = 2
    rw [v2Nat_eq_succ_of_mod2_eq0 4 (by decide) (by decide)]
    rw [v2Nat_eq_succ_of_mod2_eq0 2 (by decide) (by decide)]
    rw [v2Nat_eq_zero_of_mod2_ne0 1 (by decide)]
  have hlt : v2Nat (3 * 1 + 1) < 3 := by omega
  have h := v2_mod_stable 1 3 m hlt
  simp only [show (2:ℕ)^3 = 8 from by norm_num] at h
  rw [h, hbase]

/-- **Lemma**: `n ≡ 3 (mod 8)` ⟹ `v_2(3n+1) = 1`.

Proof via A9 with `r = 3`, `k = 3`. `v2Nat(3·3+1) = v2Nat(10) = 1 < 3`. -/
theorem v2_mod8_eq3_from_A9 (n : ℕ) (hmod : n % 8 = 3) :
    v2Nat (3 * n + 1) = 1 := by
  have hdiv := Nat.div_add_mod n 8
  set m := n / 8
  have hn : n = 3 + 8 * m := by omega
  rw [hn]
  have hbase : v2Nat (3 * 3 + 1) = 1 := by
    show v2Nat 10 = 1
    rw [v2Nat_eq_succ_of_mod2_eq0 10 (by decide) (by decide)]
    rw [v2Nat_eq_zero_of_mod2_ne0 5 (by decide)]
  have hlt : v2Nat (3 * 3 + 1) < 3 := by omega
  have h := v2_mod_stable 3 3 m hlt
  simp only [show (2:ℕ)^3 = 8 from by norm_num] at h
  rw [h, hbase]

/-- **Lemma**: `n ≡ 5 (mod 8)` ⟹ `v_2(3n+1) ≥ 3`.

Direct proof: `3·(5+8m)+1 = 16+24m = 8·(2+3m)`, so `8 ∣ (3n+1)`,
hence `v_2(3n+1) ≥ 3`. (This is the "stochastic class" A10 at level k=3.) -/
theorem v2_mod8_eq5 (n : ℕ) (hmod : n % 8 = 5) :
    3 ≤ v2Nat (3 * n + 1) := by
  have hdiv := Nat.div_add_mod n 8
  set m := n / 8
  have hn : n = 5 + 8 * m := by omega
  rw [hn]
  have h8dvd : 8 ∣ (3 * (5 + 8 * m) + 1) := by omega
  have h_ne : 3 * (5 + 8 * m) + 1 ≠ 0 := by omega
  have h2pow : 2^3 ∣ (3 * (5 + 8 * m) + 1) := by
    show 8 ∣ _; exact h8dvd
  exact pow2_dvd_le_v2Nat_pos _ 3 h_ne h2pow

/-- **Lemma**: `n ≡ 7 (mod 8)` ⟹ `v_2(3n+1) = 1`.

Proof via A9 with `r = 7`, `k = 3`. `v2Nat(3·7+1) = v2Nat(22) = 1 < 3`. -/
theorem v2_mod8_eq7_from_A9 (n : ℕ) (hmod : n % 8 = 7) :
    v2Nat (3 * n + 1) = 1 := by
  have hdiv := Nat.div_add_mod n 8
  set m := n / 8
  have hn : n = 7 + 8 * m := by omega
  rw [hn]
  have hbase : v2Nat (3 * 7 + 1) = 1 := by
    show v2Nat 22 = 1
    rw [v2Nat_eq_succ_of_mod2_eq0 22 (by decide) (by decide)]
    rw [v2Nat_eq_zero_of_mod2_ne0 11 (by decide)]
  have hlt : v2Nat (3 * 7 + 1) < 3 := by omega
  have h := v2_mod_stable 7 3 m hlt
  simp only [show (2:ℕ)^3 = 8 from by norm_num] at h
  rw [h, hbase]

/-!
## Auxiliary: `nSeq n K % 8 ∈ {1, 3, 5, 7}` for `n` odd
-/

theorem nSeq_mod8_odd_classes (n : ℕ) (h_odd : n % 2 = 1) (K : ℕ) :
    nSeq n K % 8 = 1 ∨ nSeq n K % 8 = 3 ∨
    nSeq n K % 8 = 5 ∨ nSeq n K % 8 = 7 := by
  have hodd_K : nSeq n K % 2 = 1 := nSeq_odd n K h_odd
  have h8 : nSeq n K % 8 = 0 ∨ nSeq n K % 8 = 1 ∨
            nSeq n K % 8 = 2 ∨ nSeq n K % 8 = 3 ∨
            nSeq n K % 8 = 4 ∨ nSeq n K % 8 = 5 ∨
            nSeq n K % 8 = 6 ∨ nSeq n K % 8 = 7 := by
    have hbnd : nSeq n K % 8 < 8 := Nat.mod_lt _ (by decide)
    interval_cases (nSeq n K % 8) <;> tauto
  -- Reject even cases by parity contradiction
  rcases h8 with h | h | h | h | h | h | h | h
  all_goals first
    | (exfalso; omega)
    | tauto

/-!
## Per-step refined lower bound (mod 8)
-/

/-- For each step `i`, the parity exponent is bounded below by:
- `1` always (any odd `n` has `v_2(3n+1) ≥ 1`)
- `+1` if `n_i ≡ 1 (mod 4)` (combining `≡ 1` and `≡ 5` mod 8)
- `+1` more if `n_i ≡ 5 (mod 8)` (the deeper sub-class)

So: `aSeq n i ≥ 1 + 𝟙[n_i ≡ 1 mod 4] + 𝟙[n_i ≡ 5 mod 8]`.
-/
theorem aSeq_lower_mod8 (n : ℕ) (h_odd : n % 2 = 1) (i : ℕ) :
    aSeq n i ≥ 1 + (if nSeq n i % 4 = 1 then 1 else 0)
                  + (if nSeq n i % 8 = 5 then 1 else 0) := by
  rcases nSeq_mod8_odd_classes n h_odd i with h1 | h3 | h5 | h7
  · -- n_i ≡ 1 (mod 8): v_2 = 2, n_i ≡ 1 (mod 4)
    have hv2 : v2Nat (3 * nSeq n i + 1) = 2 := v2_mod8_eq1_from_A9 (nSeq n i) h1
    have h_mod4 : nSeq n i % 4 = 1 := by omega
    have h_not5 : ¬ (nSeq n i % 8 = 5) := by omega
    simp [aSeq, v2_3n1, h_mod4, h_not5]
    omega
  · -- n_i ≡ 3 (mod 8): v_2 = 1, n_i ≡ 3 (mod 4)
    have hv2 : v2Nat (3 * nSeq n i + 1) = 1 := v2_mod8_eq3_from_A9 (nSeq n i) h3
    have h_not_mod4 : ¬ (nSeq n i % 4 = 1) := by omega
    have h_not5 : ¬ (nSeq n i % 8 = 5) := by omega
    simp [aSeq, v2_3n1, h_not_mod4, h_not5]
    omega
  · -- n_i ≡ 5 (mod 8): v_2 ≥ 3, n_i ≡ 1 (mod 4)
    have hv2 : 3 ≤ v2Nat (3 * nSeq n i + 1) := v2_mod8_eq5 (nSeq n i) h5
    have h_mod4 : nSeq n i % 4 = 1 := by omega
    have h_5 : nSeq n i % 8 = 5 := h5
    simp [aSeq, v2_3n1, h_mod4, h_5]
    omega
  · -- n_i ≡ 7 (mod 8): v_2 = 1, n_i ≡ 3 (mod 4)
    have hv2 : v2Nat (3 * nSeq n i + 1) = 1 := v2_mod8_eq7_from_A9 (nSeq n i) h7
    have h_not_mod4 : ¬ (nSeq n i % 4 = 1) := by omega
    have h_not5 : ¬ (nSeq n i % 8 = 5) := by omega
    simp [aSeq, v2_3n1, h_not_mod4, h_not5]
    omega

/-!
## Main theorem: refined parameter-free lower bound mod 8
-/

theorem cycle_parity_sum_lower_mod8 (n : ℕ) (h_odd : n % 2 = 1) (K : ℕ) :
    aSumSeq n K ≥
      K + ((Finset.range K).filter (fun i => nSeq n i % 4 = 1)).card
        + ((Finset.range K).filter (fun i => nSeq n i % 8 = 5)).card := by
  induction K with
  | zero =>
      simp [aSumSeq, aSum]
  | succ K ih =>
      have step : aSumSeq n (K + 1) = aSumSeq n K + aSeq n K :=
        aSumSeq_succ n K
      have lower : aSeq n K ≥ 1 + (if nSeq n K % 4 = 1 then 1 else 0)
                                + (if nSeq n K % 8 = 5 then 1 else 0) :=
        aSeq_lower_mod8 n h_odd K
      have card4_succ :
          ((Finset.range (K + 1)).filter (fun i => nSeq n i % 4 = 1)).card =
          ((Finset.range K).filter (fun i => nSeq n i % 4 = 1)).card +
          (if nSeq n K % 4 = 1 then 1 else 0) := by
        rw [Finset.range_add_one, Finset.filter_insert]
        by_cases h : nSeq n K % 4 = 1
        · have hK_notin :
              K ∉ (Finset.range K).filter (fun i => nSeq n i % 4 = 1) := by
            simp [Finset.mem_filter]
          rw [if_pos h, Finset.card_insert_of_notMem hK_notin]
          simp [h]
        · rw [if_neg h]; simp [h]
      have card5_succ :
          ((Finset.range (K + 1)).filter (fun i => nSeq n i % 8 = 5)).card =
          ((Finset.range K).filter (fun i => nSeq n i % 8 = 5)).card +
          (if nSeq n K % 8 = 5 then 1 else 0) := by
        rw [Finset.range_add_one, Finset.filter_insert]
        by_cases h : nSeq n K % 8 = 5
        · have hK_notin :
              K ∉ (Finset.range K).filter (fun i => nSeq n i % 8 = 5) := by
            simp [Finset.mem_filter]
          rw [if_pos h, Finset.card_insert_of_notMem hK_notin]
          simp [h]
        · rw [if_neg h]; simp [h]
      rw [step, card4_succ, card5_succ]
      omega

/-!
## Corollary: refinement of Round 11

`cycle_parity_sum_lower_mod8` is strictly stronger than (or equal to)
`cycle_parity_sum_lower_mod4`, because it adds the non-negative term
`a₅(K) = |{i : n_i ≡ 5 mod 8}|` to the lower bound.
-/

theorem cycle_parity_sum_lower_mod8_refines_mod4
    (n : ℕ) (h_odd : n % 2 = 1) (K : ℕ) :
    aSumSeq n K ≥
      K + ((Finset.range K).filter (fun i => nSeq n i % 4 = 1)).card := by
  have h := cycle_parity_sum_lower_mod8 n h_odd K
  -- Drop the non-negative a_5 term
  have hnn :
      ((Finset.range K).filter (fun i => nSeq n i % 8 = 5)).card ≥ 0 :=
    Nat.zero_le _
  omega

/-!
## Combined corollary: bound on a_4 + a_5_mod_8

For any cycle (where Steiner gives `aSumSeq ≈ K · log_2(3)`):
  `a_4(K) + a_5_mod_8(K) ≤ aSumSeq n K - K`
-/

theorem cycle_count_mod8_combined_upper (n K : ℕ) (h_odd : n % 2 = 1) :
    ((Finset.range K).filter (fun i => nSeq n i % 4 = 1)).card +
    ((Finset.range K).filter (fun i => nSeq n i % 8 = 5)).card ≤
    aSumSeq n K - K := by
  have h := cycle_parity_sum_lower_mod8 n h_odd K
  omega

end ProjetCollatz
