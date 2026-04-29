import ProjetCollatz.SyracuseDefs
import ProjetCollatz.ModularHierarchy
import ProjetCollatz.HardLowerBoundPaper
import ProjetCollatz.Phase33ConditionalCollatz

/-!
# ParityModConstraints.lean — Direction 5 (Round 10): 2-adic resonance lower bound

This file formalizes the **first parameter-free lower bound on `Σ s_i`** for any
Collatz odd-iterate sequence, using the modular hierarchy already developed in
`ModularHierarchy.lean` (Theorems A8/A9: `v2_mod4_eq*_from_A9`).

## Main result

For any odd starting value `n` and any length `K`:

```
aSumSeq n K ≥ K + |{i ∈ [0, K) : nSeq n i % 4 = 1}|
```

This is a **parameter-free** statement — independent of `X_0` (Barina threshold),
of `m` (cycle minimum), and of `n_min`. It captures the structural fact that:
- when `n_i ≡ 1 (mod 4)`, the parity exponent `s_i = v_2(3 n_i + 1) ≥ 2`;
- when `n_i ≡ 3 (mod 4)`, the parity exponent `s_i = v_2(3 n_i + 1) = 1`.

## Significance

This is the first concrete formal lemma of the post-JAR research program
(Direction 5, "TRIZ-19 2-adic resonance"). Combined with Steiner's identity
`s ≈ k · log_2(3)` and a future fine analysis of the residue distribution
of the orbit modulo `2^j`, it constitutes a building block toward a
parameter-free upper bound `g(k) = O(k^{-7})` on the deviation
`Σ s_i - k · log_2(3)` — which would close the chain via Baker.

The theorem itself does NOT prove the cycle bound. It is a **necessary
condition** that any hypothetical Collatz cycle must satisfy.

## Methodology

- **Mode**: parameter-free, no `X_0`/`m`/`n_min` hypothesis.
- **Tools**: existing `ModularHierarchy` (Theorems A8/A9), `syracuseNext_odd`,
  finite sum identities (`aSum_succ`).
- **Proof technique**: induction on `K`, case split on `nSeq n K % 4 ∈ {1, 3}`.
-/

namespace ProjetCollatz

open ProjetCollatz

/-!
## Auxiliary: every iterate of `nSeq` from an odd start is odd

For `n` odd and any `K`, `nSeq n K` is odd. We re-export Eric's existing
theorem `nSeq_odd` from `Phase33ConditionalCollatz` for convenience.
-/

-- nSeq_odd is provided by ProjetCollatz.Phase33ConditionalCollatz with
-- signature (n k : ℕ) (hodd : n % 2 = 1) : nSeq n k % 2 = 1.

/-!
## Auxiliary: `nSeq n K % 4 ∈ {1, 3}` for `n` odd

A direct consequence of `nSeq_odd`: any odd natural number's residue mod 4 is
either 1 or 3.
-/

theorem nSeq_mod4_in_one_three (n : ℕ) (h_odd : n % 2 = 1) (K : ℕ) :
    nSeq n K % 4 = 1 ∨ nSeq n K % 4 = 3 := by
  have hodd_K : nSeq n K % 2 = 1 := nSeq_odd n K h_odd
  -- Any odd number mod 4 is 1 or 3
  have h4 : nSeq n K % 4 = 0 ∨ nSeq n K % 4 = 1 ∨
            nSeq n K % 4 = 2 ∨ nSeq n K % 4 = 3 := by
    have hbnd : nSeq n K % 4 < 4 := Nat.mod_lt _ (by decide)
    interval_cases (nSeq n K % 4) <;> tauto
  rcases h4 with h | h | h | h
  · -- mod 4 = 0 contradicts mod 2 = 1
    exfalso
    have : nSeq n K % 2 = 0 := by
      have : (4 : ℕ) % 2 = 0 := by decide
      omega
    omega
  · exact Or.inl h
  · -- mod 4 = 2 contradicts mod 2 = 1
    exfalso
    omega
  · exact Or.inr h

/-!
## Auxiliary: per-step parity exponent lower bound

This lemma packages the case split on `nSeq n i % 4 ∈ {1, 3}` and applies
the existing `v2_mod4_eq*_from_A9` theorems to obtain a uniform lower bound
on `aSeq n i`.
-/

theorem aSeq_lower_mod4 (n : ℕ) (h_odd : n % 2 = 1) (i : ℕ) :
    aSeq n i ≥ 1 + (if nSeq n i % 4 = 1 then 1 else 0) := by
  rcases nSeq_mod4_in_one_three n h_odd i with h1 | h3
  · -- Case nSeq n i % 4 = 1: aSeq n i = v2_3n1 (nSeq n i) ≥ 2
    have hv2 : 2 ≤ v2Nat (3 * nSeq n i + 1) := v2_mod4_eq1_from_A9 (nSeq n i) h1
    simp [aSeq, v2_3n1, h1]
    omega
  · -- Case nSeq n i % 4 = 3: aSeq n i = v2_3n1 (nSeq n i) = 1
    have hv2 : v2Nat (3 * nSeq n i + 1) = 1 := v2_mod4_eq3_from_A9 (nSeq n i) h3
    have h_ne_1 : ¬ (nSeq n i % 4 = 1) := by omega
    simp [aSeq, v2_3n1, h_ne_1]
    omega

/-!
## Main theorem: parameter-free lower bound on `Σ s_i`

For any odd `n` and any `K`:
  `aSumSeq n K ≥ K + |{i ∈ [0, K) : nSeq n i % 4 = 1}|`

This is a building block for Direction 5 of the post-JAR research program.
-/

theorem cycle_parity_sum_lower_mod4 (n : ℕ) (h_odd : n % 2 = 1) (K : ℕ) :
    aSumSeq n K ≥
      K + ((Finset.range K).filter (fun i => nSeq n i % 4 = 1)).card := by
  induction K with
  | zero =>
      -- Base: aSumSeq n 0 = 0, RHS = 0 + 0 = 0
      simp [aSumSeq, aSum]
  | succ K ih =>
      -- Inductive step
      -- aSumSeq n (K+1) = aSumSeq n K + aSeq n K (by aSumSeq_succ)
      -- IH: aSumSeq n K ≥ K + a_4(K)
      -- Two cases on nSeq n K % 4 ∈ {1, 3}:
      --   Case 1: aSeq n K ≥ 2, a_4(K+1) = a_4(K) + 1
      --     LHS ≥ K + a_4(K) + 2 = (K+1) + (a_4(K) + 1) = (K+1) + a_4(K+1) ✓
      --   Case 3: aSeq n K ≥ 1, a_4(K+1) = a_4(K)
      --     LHS ≥ K + a_4(K) + 1 = (K+1) + a_4(K) = (K+1) + a_4(K+1) ✓
      have step : aSumSeq n (K + 1) = aSumSeq n K + aSeq n K :=
        aSumSeq_succ n K
      have lower : aSeq n K ≥ 1 + (if nSeq n K % 4 = 1 then 1 else 0) :=
        aSeq_lower_mod4 n h_odd K
      -- Cardinality decomposition: a_4(K+1) = a_4(K) + (1 if nSeq n K % 4 = 1 else 0)
      have card_succ :
          ((Finset.range (K + 1)).filter (fun i => nSeq n i % 4 = 1)).card =
          ((Finset.range K).filter (fun i => nSeq n i % 4 = 1)).card +
          (if nSeq n K % 4 = 1 then 1 else 0) := by
        rw [Finset.range_add_one, Finset.filter_insert]
        by_cases h : nSeq n K % 4 = 1
        · -- K is in the filter
          have hK_notin :
              K ∉ (Finset.range K).filter (fun i => nSeq n i % 4 = 1) := by
            simp [Finset.mem_filter]
          rw [if_pos h, Finset.card_insert_of_notMem hK_notin]
          simp [h]
        · -- K is not in the filter
          rw [if_neg h]
          simp [h]
      -- Combine IH + step + lower + card_succ
      rw [step, card_succ]
      omega

/-!
## Corollary: connection to Steiner deviation

For a Collatz cycle of length `K`, Steiner's identity gives `aSumSeq n K ≈ K · log_2(3)`.
Combined with the lower bound above, the count `a_4(K)` of indices `i` with
`nSeq n i ≡ 1 (mod 4)` satisfies:

  `a_4(K) ≤ aSumSeq n K - K`

which, in a real (non-trivial) cycle, becomes `a_4(K) ≤ K · (log_2(3) - 1) ≈ 0.585 K`.

Equivalently, the count `a_3(K)` of indices with `nSeq n i ≡ 3 (mod 4)` satisfies:

  `a_3(K) = K - a_4(K) ≥ K - (aSumSeq n K - K) = 2K - aSumSeq n K`

so `a_3(K) ≥ K · (2 - log_2(3)) ≈ 0.415 K`.

This is a parameter-free structural property of every Collatz cycle. It constitutes
the first concrete formal lemma of the Direction-5 research program.
-/

theorem cycle_count_mod4_eq1_upper (n K : ℕ) (h_odd : n % 2 = 1) :
    ((Finset.range K).filter (fun i => nSeq n i % 4 = 1)).card ≤
      aSumSeq n K - K := by
  have h := cycle_parity_sum_lower_mod4 n h_odd K
  omega

end ProjetCollatz
