import ProjetCollatz.PostJAR.CollatzAxioms
import ProjetCollatz.PostJAR.CycleArithmetic

/-!
# LTupleSieve.lean — Round 29: Hercher's l-tuple sieve (T5)

## Origin

Per Hercher expert agent R25 verdict, T5 is "the l-tuple sieve":
combinatorial analysis on the drop-height vectors `(s_1, ..., s_k)`
that constrain admissible cycle patterns.

## Status

This file lays out the **definitions and statements** for T5, complementing
OLD's parallel work on T4 (m-cycle reduction). The combinatorial bounds
are axiomatised (`ltuple_admissibility`) since the full sieve is ~3 months
of work per Hercher expert.

## Concept

For a hypothetical Collatz cycle `s = (s_1, ..., s_k)`:
- All `s_i ≥ 1` (drop heights are positive)
- `Σ s_i = S` (total drop sum)
- 2-adic constraints: `n_{i+1} = (3 n_i + 1) / 2^{s_i}` requires
  `(3 n_i + 1) % 2^{s_i} = 0` and `(3 n_i + 1) % 2^{s_i + 1} ≠ 0`

These last constraints define the "admissible" l-tuples. Hercher §6 enumerates
admissible patterns and shows none satisfies the cycle equation for k ≤ 91.

## Honest scope

This is a **statement-only** file. The proofs reference Hercher §6 and the
combinatorial sieve algorithm. Implementing them in Lean is the bulk of
the T5 work (~3 months).
-/

namespace ProjetCollatz.PostJAR

noncomputable section

open Real

/-! ## Section 1: Admissibility predicate -/

/-- An l-tuple `(s_1, ..., s_k)` is **admissible** for a hypothetical
Collatz cycle starting at `n` if the 2-adic constraints are satisfied:
- All `s_i ≥ 1`
- For each i, `nSeq n i` is odd and `aSeq n i = s_i`
-/
def IsAdmissibleLTuple (n : ℕ) (s : List ℕ) : Prop :=
  (∀ x ∈ s, 1 ≤ x) ∧
  (∀ i : Fin s.length, aSeq n i.val = s.get i)

/-! ## Section 2: Hercher's sieve bound (axiomatised, T5)

Hercher 2023 §6 enumerates admissible l-tuples for k ≤ 91 and shows that
no admissible tuple satisfies the cycle equation `n · (2^S - 3^k) = corrSum n k`
for `n ≥ 2^68`. This is the combinatorial heart of the result.

We axiomatise the conclusion: "no admissible l-tuple of length k ≤ 91 with
n ≥ 2^68 forms a cycle".
-/

/-- **Hercher 2023 l-tuple sieve bound** (axiomatised, T5).

For any `k ≤ 91`, any `n ≥ barina_bound = 2^68`, and any admissible l-tuple
of length `k`, the cycle equation has no solution.

This axiom encodes Hercher §6's enumeration + branch-and-bound result. -/
axiom ltuple_sieve_bound
    (k : ℕ) (hk : 1 ≤ k ∧ k ≤ 91)
    (n : ℕ) (hn : n ≥ barina_bound)
    (s : List ℕ) (hlen : s.length = k)
    (hadm : IsAdmissibleLTuple n s) :
    ¬ ((n : ℤ) * cyclicDenom s = cyclicSum s)

/-! ## Section 3: Connection to Hercher main bound

The l-tuple sieve combined with Barina forces `n < barina_bound` for any
non-trivial cycle of length k ≤ 91. This is precisely `hercher_main_bound`
from `HercherTheorem.lean`, but derived from finer pieces.
-/

/-! ## Section 3a: Parity vector construction + bridge to corrSum -/

/-- The parity vector of a Collatz orbit: list of drop heights from index 0
to k-1. -/
noncomputable def parityVector (n k : ℕ) : List ℕ :=
  (List.range k).map (aSeq n)

@[simp] lemma parityVector_length (n k : ℕ) :
    (parityVector n k).length = k := by
  simp [parityVector]

/-- The sum of drop heights in `parityVector n k` equals `aSumSeq n k`. -/
@[simp] lemma parityVector_sum (n k : ℕ) : (parityVector n k).sum = aSumSeq n k := by
  induction k with
  | zero => simp [parityVector, aSumSeq, aSum]
  | succ k ih =>
    simp [parityVector, List.range_succ, List.map_append, List.sum_append]
    rw [show ((List.range k).map (aSeq n)).sum = (parityVector n k).sum from rfl,
        ih, aSumSeq_succ' n k]

/-- The parity vector is always admissible (its drop heights are aSeq by
construction). -/
lemma parityVector_admissible (n k : ℕ) (hodd : n % 2 = 1) :
    IsAdmissibleLTuple n (parityVector n k) := by
  refine ⟨?_, ?_⟩
  · -- All s_i ≥ 1
    intro x hx
    simp [parityVector, List.mem_map, List.mem_range] at hx
    obtain ⟨i, _, hxi⟩ := hx
    rw [← hxi]
    -- Need aSeq n i ≥ 1, which follows from nSeq_odd via aSeq_ge_one_of_odd
    exact ProjetCollatz.PostJAR.aSeq_ge_one_of_odd n i hodd
  · -- For each i : Fin (parityVector n k).length, aSeq n i.val = parityVector n k get i
    intro i
    -- Direct computation: parityVector n k = (range k).map (aSeq n), so
    -- get i = aSeq n (range k).get i = aSeq n i.val.
    simp only [parityVector, List.get_eq_getElem, List.getElem_map, List.getElem_range]

/-! ### Bridge: cyclicSum (parityVector n k) = corrSum n k -/

/-- Helper: appending one drop height multiplies cyclicSum by 3 and adds 2^s.sum.

This is the recursive structure of the cyclic correction sum, parallel to
`corrSum_succ`. Proof by direct computation on the definition. -/
lemma cyclicSum_append (s : List ℕ) (a : ℕ) :
    cyclicSum (s ++ [a]) = 3 * cyclicSum s + 2 ^ s.sum := by
  unfold cyclicSum
  -- length of (s ++ [a]) is s.length + 1
  rw [List.length_append, List.length_singleton]
  -- Split the sum into i < s.length and i = s.length
  rw [Finset.sum_range_succ]
  -- For i = s.length: (s ++ [a]).take s.length = s, so partial_sum = s.sum.
  --                   3^(s.length+1-1-s.length) = 3^0 = 1.
  --                   So this term = 1 * 2^s.sum = 2^s.sum.
  have h_last : 3 ^ (s.length + 1 - 1 - s.length) *
                2 ^ parity_partial_sum (s ++ [a]) s.length = 2 ^ s.sum := by
    rw [show s.length + 1 - 1 - s.length = 0 by omega, pow_zero, one_mul]
    congr 1
    -- parity_partial_sum (s ++ [a]) s.length = (s ++ [a]).take s.length = s, so .sum = s.sum
    show ((s ++ [a]).take s.length).sum = s.sum
    rw [List.take_left]
  -- For i < s.length: (s ++ [a]).take i = s.take i, so partial_sum = parity_partial_sum s i.
  --                   3^(s.length+1-1-i) = 3 * 3^(s.length-1-i).
  have h_inner : ∀ i ∈ Finset.range s.length,
      3 ^ (s.length + 1 - 1 - i) * 2 ^ parity_partial_sum (s ++ [a]) i =
      3 * (3 ^ (s.length - 1 - i) * 2 ^ parity_partial_sum s i) := by
    intro i hi
    rw [Finset.mem_range] at hi
    have h_pow : s.length + 1 - 1 - i = (s.length - 1 - i) + 1 := by omega
    have h_take : ((s ++ [a]).take i).sum = (s.take i).sum := by
      rw [List.take_append_of_le_length (by omega : i ≤ s.length)]
    rw [h_pow, pow_succ]
    show _ * 2 ^ parity_partial_sum (s ++ [a]) i = _
    show 3 ^ (s.length - 1 - i) * 3 * 2 ^ parity_partial_sum (s ++ [a]) i = _
    -- parity_partial_sum (s ++ [a]) i = ((s ++ [a]).take i).sum = (s.take i).sum = parity_partial_sum s i
    have : parity_partial_sum (s ++ [a]) i = parity_partial_sum s i := by
      simp [parity_partial_sum, h_take]
    rw [this]
    ring
  rw [h_last]
  rw [Finset.sum_congr rfl h_inner]
  rw [← Finset.mul_sum]

/-- **Bridge theorem (cyclicSum vs corrSum)**: by induction on k, using
`cyclicSum_append` and `corrSum_succ`. Eliminates the previously axiomatised
bridge — now a fully Lean-proved theorem. -/
theorem cyclicSum_eq_corrSum_for_parityVector (n k : ℕ) :
    cyclicSum (parityVector n k) = corrSum n k := by
  induction k with
  | zero =>
    -- cyclicSum [] = 0 (empty Finset.sum), corrSum n 0 = 0.
    simp [parityVector, cyclicSum]
  | succ k ih =>
    -- parityVector n (k+1) = parityVector n k ++ [aSeq n k]
    have h_pv_succ : parityVector n (k + 1) = parityVector n k ++ [aSeq n k] := by
      simp [parityVector, List.range_succ, List.map_append]
    rw [h_pv_succ, cyclicSum_append, ih, parityVector_sum, corrSum_succ]

/-- **L-tuple sieve implies Hercher's main bound** (proved from sieve axiom).

For any non-trivial Collatz cycle of length k ≤ 91, the starting value n
must satisfy `n < barina_bound`. This follows from `ltuple_sieve_bound`:
the parity vector is admissible AND must satisfy the cycle equation, but
the sieve says no admissible tuple satisfies the cycle equation for n ≥
barina_bound.

The remaining gap to close (sorry deferred to R31): connect the actual
cycle equation `n · (2^aSumSeq n k - 3^k) = corrSum n k` to
`(n : ℤ) · cyclicDenom (parityVector n k) = cyclicSum (parityVector n k)`.

This requires proving `cyclicSum (parityVector n k) = corrSum n k` (~50 lines
by induction on k using corrSum_succ, parityVector definition, and the
existing R22-R24 unfoldings).
-/
theorem hercher_n_bound_from_sieve
    (n k : ℕ) (hk : 1 ≤ k ∧ k ≤ 91)
    (hcyc : IsOddCycle n k) :
    n < barina_bound := by
  -- Step 1: extract odd / cycle-equation facts.
  obtain ⟨hn_gt1, hodd, hk_pos, hcyc_eq⟩ := hcyc
  -- Step 2: by contradiction, assume n ≥ barina_bound.
  by_contra h_not_lt
  push_neg at h_not_lt
  -- Step 3: parity vector is admissible.
  have hadm := parityVector_admissible n k hodd
  -- Step 4: by Steiner cycle equation, n * (2^aSumSeq - 3^k) = corrSum n k.
  have hsteiner := steiner_cycle_eq n k ⟨hn_gt1, hodd, hk_pos, hcyc_eq⟩
  -- Step 5: in ℤ-form using parityVector
  have h_pv_len : (parityVector n k).length = k := parityVector_length n k
  have h_pv_sum : (parityVector n k).sum = aSumSeq n k := parityVector_sum n k
  -- Step 6: cyclicDenom (parityVector n k) = 2^aSumSeq - 3^k.
  have h_pv_denom : cyclicDenom (parityVector n k) =
      (2 : ℤ) ^ aSumSeq n k - (3 : ℤ) ^ k := by
    simp [cyclicDenom, h_pv_len, h_pv_sum]
  -- Step 7: cyclicSum (parityVector n k) = corrSum n k (axiom).
  have h_pv_sum_eq := cyclicSum_eq_corrSum_for_parityVector n k
  -- Step 8: ℤ-equation for cycle.
  have heq_int : (n : ℤ) * cyclicDenom (parityVector n k) =
      cyclicSum (parityVector n k) := by
    rw [h_pv_denom, h_pv_sum_eq]
    have h_int : (n : ℤ) * ((2 : ℤ) ^ aSumSeq n k) =
        3 ^ k * n + corrSum n k := by exact_mod_cast hsteiner
    linarith
  -- Step 9: contradict ltuple_sieve_bound.
  exact ltuple_sieve_bound k hk n h_not_lt (parityVector n k) h_pv_len hadm heq_int

end

end ProjetCollatz.PostJAR
