import ProjetCollatz.PostJAR.Mod8Constraints

/-!
# LayerCakeIdentity.lean — Round 13: layer-cake identity for parity sums

## Mathematical content

Classical identity (the "layer cake" / Cavalieri): for natural-valued sequences,
the sum of values equals the sum over levels of the count of indices exceeding
that level.

Specifically, for any `a : ℕ → ℕ` and `K, M : ℕ` with `a i ≤ M` for `i < K`:
$$\sum_{i < K} a(i) \;=\; \sum_{k < M} \big| \{ i < K : k < a(i) \} \big|$$

## Application to Collatz parity sums

Specialized to `a = aSeq n` (the parity exponents of the Collatz odd-iterate),
the identity becomes:
$$\sum_{i < K} s_i \;=\; \sum_{k < M} A_k(K), \quad A_k(K) = \big| \{i < K : s_i > k \} \big|$$

Since `s_i > k ⟺ s_i ≥ k+1 ⟺ 2^{k+1} ∣ (3 n_i + 1)`, each "layer" `A_k`
is the count of orbital points whose 2-adic valuation crosses the `k+1` threshold.

This gives a **complete decomposition** of `aSumSeq n K` into parameter-free
combinatorial counts, refining Rounds 11 (`A_1`) and 12 (`A_1 + A_2`).

## Significance

The layer-cake identity is exact (no inequality), so it supersedes Rounds 11+12
as a quantitative tool. The bottleneck for closing the cycle problem becomes
**bounding each `A_k(K)` from above**.

For `k = 0`: `A_0(K) = K` (every odd `n_i` has `s_i ≥ 1`).
For `k = 1`: `A_1(K) = a_4(K)` (count of `n_i ≡ 1 mod 4`, i.e. `s_i ≥ 2`).
For `k = 2`: `A_2(K) = a_{5,8}(K)` (count of `n_i ≡ 5 mod 8`, i.e. `s_i ≥ 3`).
For `k ≥ j`: `A_k(K)` counts indices with `2^{k+1} ∣ (3 n_i + 1)`, which by A9/A10
corresponds to membership in the unique stochastic class at level `k+1`.

Combined with Steiner's identity (Round 14, next file), this gives a system
of constraints on `(A_k(K))_{k≥0}` that any Collatz cycle must satisfy.

## Verifications

- Pure induction proof, no `decide`, no `native_decide`.
- 0 sorry, 0 admit.
- Kernel-3 axiom profile.
- Out-of-tree from JAR submission baseline.
-/

namespace ProjetCollatz

open ProjetCollatz Finset

/-!
## Generic layer-cake identity for `aSum`
-/

/-- **Layer-cake identity** for natural-valued finite sums.

For any `a : ℕ → ℕ` and `K, M : ℕ` such that `a i ≤ M` for all `i < K`:
$$\sum_{i < K} a(i) = \sum_{k < M} \big| \{ i < K : k < a(i) \} \big|$$

Proof by induction on `K`. -/
theorem aSum_layer_cake (a : ℕ → ℕ) (K M : ℕ) (hM : ∀ i, i < K → a i ≤ M) :
    aSum a K =
    ∑ k ∈ Finset.range M, ((Finset.range K).filter (fun i => k < a i)).card := by
  induction K with
  | zero =>
      -- Empty sum on both sides
      simp [aSum]
  | succ K ih =>
      have hM' : ∀ i, i < K → a i ≤ M :=
        fun i hi => hM i (Nat.lt_succ_of_lt hi)
      have haK : a K ≤ M := hM K (Nat.lt_succ_self K)
      -- Decompose LHS: aSum a (K+1) = aSum a K + a K
      rw [aSum_succ]
      rw [ih hM']
      -- For each k, decompose the cardinality on Finset.range (K+1)
      have decomp_card :
          ∀ k, ((Finset.range (K + 1)).filter (fun i => k < a i)).card =
               ((Finset.range K).filter (fun i => k < a i)).card +
               (if k < a K then 1 else 0) := by
        intro k
        rw [Finset.range_add_one, Finset.filter_insert]
        by_cases h : k < a K
        · -- K is in the filter
          have hK_notin :
              K ∉ (Finset.range K).filter (fun i => k < a i) := by
            simp [Finset.mem_filter]
          rw [if_pos h, Finset.card_insert_of_notMem hK_notin]
          simp [h]
        · rw [if_neg h]; simp [h]
      -- Substitute the decomposition
      have step :
          ∑ k ∈ Finset.range M,
              ((Finset.range (K + 1)).filter (fun i => k < a i)).card =
          ∑ k ∈ Finset.range M,
              (((Finset.range K).filter (fun i => k < a i)).card +
                  (if k < a K then 1 else 0)) :=
        Finset.sum_congr rfl (fun k _ => decomp_card k)
      rw [step, Finset.sum_add_distrib]
      -- The second sum collapses to a K, since k < a K and a K ≤ M
      have count_eq :
          ∑ k ∈ Finset.range M, (if k < a K then 1 else 0) = a K := by
        -- {k < M : k < a K} = Finset.range (a K) since a K ≤ M
        have h_set :
            (Finset.range M).filter (fun k => k < a K) = Finset.range (a K) := by
          ext k
          simp only [Finset.mem_filter, Finset.mem_range]
          constructor
          · rintro ⟨_, h2⟩; exact h2
          · intro h; exact ⟨lt_of_lt_of_le h haK, h⟩
        calc ∑ k ∈ Finset.range M, (if k < a K then (1:ℕ) else 0)
            = ((Finset.range M).filter (fun k => k < a K)).card := by
                rw [Finset.sum_ite, Finset.sum_const_zero, add_zero,
                    Finset.sum_const, smul_eq_mul, Nat.mul_one]
          _ = (Finset.range (a K)).card := by rw [h_set]
          _ = a K := Finset.card_range (a K)
      rw [count_eq]

/-!
## Specialization to Collatz parity sums
-/

/-- The `k`-th layer of the parity sum: count of indices `i < K` whose
parity exponent strictly exceeds `k`. -/
noncomputable def parityLayer (n : ℕ) (k K : ℕ) : ℕ :=
  ((Finset.range K).filter (fun i => k < aSeq n i)).card

/-- **Round 13 main theorem** (layer-cake decomposition of `aSumSeq`).

For any odd `n`, `K ≥ 0`, and `M` an upper bound on `aSeq n i` for `i < K`:
$$\sum_{i < K} s_i \;=\; \sum_{k < M} A_k(K)$$
where `A_k(K) = |\{i < K : s_i > k\}|`. -/
theorem aSumSeq_layer_decomp (n K M : ℕ) (hM : ∀ i, i < K → aSeq n i ≤ M) :
    aSumSeq n K = ∑ k ∈ Finset.range M, parityLayer n k K := by
  unfold aSumSeq parityLayer
  exact aSum_layer_cake (aSeq n) K M hM

/-!
## Connection with Round 11 / Round 12

Round 11 and Round 12 are recovered as lower bounds on `parityLayer n 0` and
`parityLayer n 1` respectively, via the modular dichotomies of mod 4 and mod 8.
-/

/-- The `0`-th layer counts all indices: every odd `n` has `aSeq n i ≥ 1`. -/
theorem parityLayer_zero_eq (n K : ℕ) (h_odd : n % 2 = 1) :
    parityLayer n 0 K = K := by
  unfold parityLayer
  -- For odd n_i, aSeq n i ≥ 1, so 0 < aSeq n i is always true
  have h_all : ∀ i ∈ Finset.range K, 0 < aSeq n i := by
    intro i hi
    -- aSeq n i = v_2(3 * nSeq n i + 1) ≥ 1 because 3 n + 1 is even for odd n
    rcases nSeq_mod4_in_one_three n h_odd i with h1 | h3
    · -- n_i ≡ 1 mod 4: aSeq ≥ 2 > 0
      have hv2 : 2 ≤ v2Nat (3 * nSeq n i + 1) := v2_mod4_eq1_from_A9 (nSeq n i) h1
      simp [aSeq, v2_3n1]; omega
    · -- n_i ≡ 3 mod 4: aSeq = 1 > 0
      have hv2 : v2Nat (3 * nSeq n i + 1) = 1 := v2_mod4_eq3_from_A9 (nSeq n i) h3
      simp [aSeq, v2_3n1]; omega
  rw [Finset.filter_true_of_mem h_all]
  exact Finset.card_range K

/-- The `1`-st layer is the mod-4 count `a_4(K) = |{i : n_i ≡ 1 mod 4}|`. -/
theorem parityLayer_one_eq_mod4 (n K : ℕ) (h_odd : n % 2 = 1) :
    parityLayer n 1 K = ((Finset.range K).filter (fun i => nSeq n i % 4 = 1)).card := by
  unfold parityLayer
  congr 1
  ext i
  simp only [Finset.mem_filter, Finset.mem_range]
  refine and_congr_right (fun hi => ?_)
  -- 1 < aSeq n i ⟺ aSeq n i ≥ 2 ⟺ n_i ≡ 1 mod 4
  rcases nSeq_mod4_in_one_three n h_odd i with h1 | h3
  · -- n_i ≡ 1 mod 4: aSeq ≥ 2
    have hv2 : 2 ≤ v2Nat (3 * nSeq n i + 1) := v2_mod4_eq1_from_A9 (nSeq n i) h1
    simp [aSeq, v2_3n1, h1]; omega
  · -- n_i ≡ 3 mod 4: aSeq = 1, not > 1
    have hv2 : v2Nat (3 * nSeq n i + 1) = 1 := v2_mod4_eq3_from_A9 (nSeq n i) h3
    have h_ne : nSeq n i % 4 ≠ 1 := by omega
    simp [aSeq, v2_3n1, h_ne]
    omega

/-!
## Summary: layer-cake decomposition recovers Rounds 11+12 exactly
-/

/-- The bound from Round 11 is recovered as `parityLayer n 0 K + parityLayer n 1 K`. -/
theorem round11_via_layers (n K : ℕ) (h_odd : n % 2 = 1) :
    K + ((Finset.range K).filter (fun i => nSeq n i % 4 = 1)).card =
    parityLayer n 0 K + parityLayer n 1 K := by
  rw [parityLayer_zero_eq n K h_odd, parityLayer_one_eq_mod4 n K h_odd]

end ProjetCollatz
