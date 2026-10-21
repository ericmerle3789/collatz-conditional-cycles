import Labo.S1_Phase58PorteDeuxFinal

/-!
# LABO-COLLATZ · S1 · A4 (Formaliste) — X02 and R03 on the Lean 4.34.0 kernel

The imported modules `Labo.S1_*` are a verbatim port (only `import` lines rewritten) of the import
closure of `ProjetCollatz.Phase58PorteDeuxFinal`, collatz-conditional-cycles commit c24633c (E. Merle).
Names below prefixed `S1_` are new (LABO-COLLATZ, 2026-09-25).
-/

namespace ProjetCollatz

/-! ## X02 — under H1 (`BakerSeparation`) and H2 (`BarinaVerification`), H3 carries the conclusion -/

/-- H1 + H2 + H3 ⇒ no cycle, WITHOUT `no_nontrivial_cycle_final`: H3 gives k ≤ 982,
`bk_1322_derived` (H1 + H2) gives k > 1322. -/
theorem S1_x02_H3_implies_no_cycle (baker : BakerSeparation) (barina : BarinaVerification)
    (sdw : ProductBoundThreshold) (n k : ℕ) (hcyc : IsOddCycle n k) : False := by
  have h1 := sdw.cycle_length_bound n k hcyc
  have h2 := bk_1322_derived baker barina n k hcyc
  omega

/-- The converse needs NO hypothesis at all: if there is no cycle, H3 holds vacuously. -/
theorem S1_x02_no_cycle_implies_H3 (h : ∀ n k : ℕ, ¬ IsOddCycle n k) : ProductBoundThreshold :=
  ⟨fun n k hcyc => (h n k hcyc).elim⟩

/-- **X02.** Under H1 + H2, H3 is logically equivalent to "there is no cycle". -/
theorem S1_x02_H3_iff_no_cycle (baker : BakerSeparation) (barina : BarinaVerification) :
    Nonempty ProductBoundThreshold ↔ ∀ n k : ℕ, ¬ IsOddCycle n k :=
  ⟨fun ⟨sdw⟩ n k hcyc => S1_x02_H3_implies_no_cycle baker barina sdw n k hcyc,
   fun h => ⟨S1_x02_no_cycle_implies_H3 h⟩⟩

/-- X02, general form: for every K ≤ 1322, "every cycle has k ≤ K" is equivalent under H1 + H2
to "there is no cycle". The constant 982 plays no role. -/
theorem S1_x02_any_bound_iff (baker : BakerSeparation) (barina : BarinaVerification)
    (K : ℕ) (hK : K ≤ 1322) :
    (∀ n k : ℕ, IsOddCycle n k → k ≤ K) ↔ ∀ n k : ℕ, ¬ IsOddCycle n k := by
  constructor
  · intro h n k hcyc
    have h1 := h n k hcyc
    have h2 := bk_1322_derived baker barina n k hcyc
    omega
  · intro h n k hcyc
    exact (h n k hcyc).elim

/-- NEGATIVE CONTROL: at K = 1323 the same arithmetic step must fail (H1 + H2 leave k = 1323 open). -/
example (baker : BakerSeparation) (barina : BarinaVerification)
    (h : ∀ n k : ℕ, IsOddCycle n k → k ≤ 1323) (n k : ℕ) (hcyc : IsOddCycle n k) : True := by
  have h1 := h n k hcyc
  have h2 := bk_1322_derived baker barina n k hcyc
  fail_if_success (exfalso; omega)
  trivial

/-! ## R03 — `no_cycle_k_le_1322` with H1 used only at the cycle's own k ≤ 1322 -/

/-- Copy of `cycle_min_bound_small_k` (Phase56, E. Merle) in which the global field
`ext.baker_separation` is replaced by the single instance `hB` at the cycle's own (s, k). -/
theorem S1_cycle_min_bound_small_k_local (n k : ℕ) (hcm : IsCycleMin n k)
    (hkn : k < 3 * n) (hB : (2 ^ aSumSeq n k - 3 ^ k) * k ^ 6 ≥ 3 ^ k) :
    3 * n ≤ k ^ 7 + k := by
  have hcyc := hcm.toAnd
  have hn_pos : n > 0 := by have := hcyc.1; omega
  have hgt := cycle_pow2_gt_pow3 n k hcyc
  have hbaker := hB
  have hprod := product_bound n k hcm
  have hbern := bernoulli_upper_nat (3 * n) 1 k (by omega)
  simp only [mul_one] at hbern
  have hle : 3 ^ k ≤ 2 ^ aSumSeq n k := Nat.le_of_lt hgt
  have hk_le_3n : k ≤ 3 * n := by omega
  zify [hle, hk_le_3n] at hbaker hprod hbern ⊢
  have hbaker2 : (2 : ℤ) ^ aSumSeq n k * (k : ℤ) ^ 6 ≥ (3 : ℤ) ^ k * ((k : ℤ) ^ 6 + 1) := by
    nlinarith
  have hn_nn : (0 : ℤ) ≤ (n : ℤ) ^ k := by positivity
  have hstar : ((k : ℤ) ^ 6 + 1) * ((3 : ℤ) * n) ^ k ≤ (k : ℤ) ^ 6 * ((3 : ℤ) * n + 1) ^ k := by
    have h1 : (3 : ℤ) ^ k * ((k : ℤ) ^ 6 + 1) * (n : ℤ) ^ k
            ≤ (2 : ℤ) ^ aSumSeq n k * (k : ℤ) ^ 6 * (n : ℤ) ^ k := by
      exact mul_le_mul_of_nonneg_right hbaker2 hn_nn
    have h2 : (2 : ℤ) ^ aSumSeq n k * (k : ℤ) ^ 6 * (n : ℤ) ^ k
            = (2 : ℤ) ^ aSumSeq n k * (n : ℤ) ^ k * (k : ℤ) ^ 6 := by ring
    have h3 : (2 : ℤ) ^ aSumSeq n k * (n : ℤ) ^ k * (k : ℤ) ^ 6
            ≤ ((3 : ℤ) * n + 1) ^ k * (k : ℤ) ^ 6 := by
      exact mul_le_mul_of_nonneg_right hprod (by positivity)
    have h4 : (3 : ℤ) ^ k * ((k : ℤ) ^ 6 + 1) * (n : ℤ) ^ k
            ≤ ((3 : ℤ) * n + 1) ^ k * (k : ℤ) ^ 6 := by linarith
    have h5 : (3 : ℤ) ^ k * ((k : ℤ) ^ 6 + 1) * (n : ℤ) ^ k
            = ((k : ℤ) ^ 6 + 1) * ((3 : ℤ) * n) ^ k := by
      rw [show ((3 : ℤ) * (n : ℤ)) ^ k = (3 : ℤ) ^ k * (n : ℤ) ^ k from mul_pow 3 (n : ℤ) k]
      ring
    have h6 : ((3 : ℤ) * n + 1) ^ k * (k : ℤ) ^ 6
            = (k : ℤ) ^ 6 * ((3 : ℤ) * n + 1) ^ k := by ring
    linarith
  have h3n_k_nn : (0 : ℤ) ≤ (3 : ℤ) * n - k := by omega
  have hchain1 : ((k : ℤ) ^ 6 + 1) * ((3 : ℤ) * n) ^ k * ((3 : ℤ) * n - k)
               ≤ (k : ℤ) ^ 6 * ((3 : ℤ) * n + 1) ^ k * ((3 : ℤ) * n - k) :=
    mul_le_mul_of_nonneg_right hstar h3n_k_nn
  have hchain2 : (k : ℤ) ^ 6 * ((3 : ℤ) * n + 1) ^ k * ((3 : ℤ) * n - k)
               = (k : ℤ) ^ 6 * (((3 : ℤ) * n + 1) ^ k * ((3 : ℤ) * n - k)) := by ring
  have hchain3 : (k : ℤ) ^ 6 * (((3 : ℤ) * n + 1) ^ k * ((3 : ℤ) * n - k))
               ≤ (k : ℤ) ^ 6 * (((3 : ℤ) * n) ^ k * ((3 : ℤ) * n)) :=
    mul_le_mul_of_nonneg_left hbern (by positivity)
  have hcombined : ((k : ℤ) ^ 6 + 1) * ((3 : ℤ) * n) ^ k * ((3 : ℤ) * n - k)
                 ≤ (k : ℤ) ^ 6 * ((3 : ℤ) * n) ^ k * ((3 : ℤ) * n) := by
    calc ((k : ℤ) ^ 6 + 1) * ((3 : ℤ) * n) ^ k * ((3 : ℤ) * n - k)
        ≤ (k : ℤ) ^ 6 * ((3 : ℤ) * n + 1) ^ k * ((3 : ℤ) * n - k) := hchain1
      _ = (k : ℤ) ^ 6 * (((3 : ℤ) * n + 1) ^ k * ((3 : ℤ) * n - k)) := hchain2
      _ ≤ (k : ℤ) ^ 6 * (((3 : ℤ) * n) ^ k * ((3 : ℤ) * n)) := hchain3
      _ = (k : ℤ) ^ 6 * ((3 : ℤ) * n) ^ k * ((3 : ℤ) * n) := by ring
  have h3n_pos : (0 : ℤ) < (3 : ℤ) * n := by omega
  have h3nk_pos : (0 : ℤ) < ((3 : ℤ) * n) ^ k := by positivity
  have hdiv : ((k : ℤ) ^ 6 + 1) * ((3 : ℤ) * n - k) ≤ (k : ℤ) ^ 6 * ((3 : ℤ) * n) := by
    have hmul : ((k : ℤ) ^ 6 + 1) * ((3 : ℤ) * n - k) * ((3 : ℤ) * n) ^ k
             ≤ (k : ℤ) ^ 6 * ((3 : ℤ) * n) * ((3 : ℤ) * n) ^ k := by nlinarith
    exact le_of_mul_le_mul_right hmul h3nk_pos
  nlinarith

/-- **R03, localised.** No cycle with k ≤ 1322, from Barina and H1 restricted to 2 ≤ k ≤ 1322
(a finite family of statements in k). No `BakerSeparation` for all k is used. -/
theorem S1_no_cycle_k_le_1322_local (barina : BarinaVerification)
    (hH1 : ∀ s k : ℕ, s ≥ 1 → 2 ≤ k → k ≤ 1322 → 2 ^ s > 3 ^ k → (2 ^ s - 3 ^ k) * k ^ 6 ≥ 3 ^ k)
    (n k : ℕ) (hcyc : IsOddCycle n k) (hk : k ≤ 1322) : False := by
  obtain ⟨m, hcm, hcyc_m⟩ := cycle_has_min n k hcyc
  have hc := hcm.toAnd
  have hbound : m ≤ (k ^ 7 + k) / 3 := by
    by_cases hkn : k ≥ 3 * m
    · exact cycle_min_bound_large_k m k hc.2.2.1 hkn
    · push_neg at hkn
      have h := S1_cycle_min_bound_small_k_local m k hcm hkn
        (hH1 _ k (cycle_sum_pos m k hc) (cycle_k_ge_two m k hc) hk (cycle_pow2_gt_pow3 m k hc))
      omega
  have hm_lt := k1322_bound_implies_n_bound k hk m hbound
  have hm_pos : m > 0 := by have := hcyc_m.1; omega
  exact cycle_prevents_reaching_one m k hcyc_m (barina.convergence m hm_pos hm_lt)

/-- The kernel-only twin of `product_bound_fits_barina_1322` (which uses `native_decide`). -/
theorem S1_product_bound_fits_barina_1322_kernel : (1322 ^ 7 + 1322 : ℕ) < 3 * 2 ^ 71 := by
  norm_num

/-- Negative control, arithmetic: 1323 must NOT fit (the threshold of Phase58 is exact). -/
theorem S1_threshold_1323_fails : ¬ ((1323 ^ 7 + 1323 : ℕ) < 3 * 2 ^ 71) := by
  norm_num

end ProjetCollatz
