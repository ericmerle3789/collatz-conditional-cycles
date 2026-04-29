import ProjetCollatz.PostJAR.LayerCakeIdentity
import ProjetCollatz.Phase50CycleEquation

/-!
# SteinerLayerConnection.lean — Round 14: Steiner identity in layer-cake form

## Mathematical content

For any hypothetical Collatz cycle of length `K`, the Steiner identity
`n · 2^S = 3^K · n + corrSum` together with the cycle-positivity of the
correction sum implies the strict inequality
$$2^S > 3^K, \quad S = \sum_i s_i.$$

Combined with Round 13 (layer-cake decomposition `S = \sum_k A_k(K)`), we
obtain the **layer-cake form of Steiner**:
$$3^K \;<\; 2^{\sum_{k} A_k(K)} \quad \text{for any Collatz cycle.}$$

This is a **parameter-free strict lower bound** on the total layer count,
expressed entirely in terms of combinatorial counts of the parity exponents.

## Significance

Round 14 is the bridge between:
- the **modular hierarchy** (Rounds 11-12: per-layer constraints from mod 4 / mod 8)
- the **parity-sum decomposition** (Round 13: total = sum of layers)
- **Steiner's identity** (this file: cycle ⟹ total bounded below by `K · log_2 3`)

Combined with Eric's existing bound `S ≤ 2K` (`cycle_sum_upper` from Phase 50),
the layer-cake form constrains `S` to an interval:
$$K \cdot \log_2(3) \;<\; \sum_k A_k(K) \;\leq\; 2K$$
i.e., the total layer count lies in roughly `(1.585 K, 2K]`.

This interval is the **"target" that any future parameter-free upper bound
on individual layers must respect**. If one proves `\sum_k A_k(K) < K \log_2 3`
under any independent constraint, one obtains a contradiction via Steiner —
hence a proof of no cycle.

This file makes that structural observation explicit and machine-verified.

## Verifications

- 0 errors, 0 warnings, 0 sorry
- Kernel-3 axiom profile
- Out-of-tree from JAR submission baseline
-/

namespace ProjetCollatz

open ProjetCollatz Finset

/-!
## Auxiliary: each `aSeq n i` is bounded by `aSumSeq n K` for `i < K`
-/

theorem aSeq_le_aSumSeq (n K : ℕ) (i : ℕ) (hi : i < K) :
    aSeq n i ≤ aSumSeq n K := by
  unfold aSumSeq aSum
  exact Finset.single_le_sum (f := fun j => aSeq n j)
    (fun j _ => Nat.zero_le _) (Finset.mem_range.mpr hi)

/-- For a cycle, each individual `aSeq n i` is bounded above by `2K`. -/
theorem cycle_aSeq_le_2K (n K : ℕ) (hcyc : IsOddCycle n K) (i : ℕ) (hi : i < K) :
    aSeq n i ≤ 2 * K := by
  have h1 : aSeq n i ≤ aSumSeq n K := aSeq_le_aSumSeq n K i hi
  have h2 : aSumSeq n K ≤ 2 * K := cycle_sum_upper n K hcyc
  omega

/-!
## Round 14 main theorem: layer-cake form of Steiner's strict inequality
-/

/-- **Round 14 main theorem.** For any Collatz cycle of length `K`, the sum of
the layer counts `parityLayer n k K` over `k ∈ [0, 2K)` is at least
`aSumSeq n K`, and `2^{aSumSeq n K} > 3^K` by Steiner.

Combined: `3^K < 2^(\sum_{k < 2K} parityLayer n k K)`. -/
theorem cycle_layer_pow_gt_3pow (n K : ℕ) (hcyc : IsOddCycle n K) :
    3 ^ K < 2 ^ (∑ k ∈ Finset.range (2 * K + 1), parityLayer n k K) := by
  -- Step 1: aSeq n i ≤ 2K for i < K
  have h_aSeq_le : ∀ i, i < K → aSeq n i ≤ 2 * K := cycle_aSeq_le_2K n K hcyc
  -- Step 2: aSumSeq n K ≤ 2 * K (so M = 2K+1 is a strict upper bound)
  have h_aSumSeq_le : aSumSeq n K ≤ 2 * K := cycle_sum_upper n K hcyc
  -- Step 3: aSeq n i ≤ 2K + 1 for i < K (margin of safety for layer-cake)
  have h_aSeq_le' : ∀ i, i < K → aSeq n i ≤ 2 * K + 1 := fun i hi => by
    have := h_aSeq_le i hi; omega
  -- Step 4: Apply Round 13 with M = 2K + 1
  have h_layer : aSumSeq n K =
      ∑ k ∈ Finset.range (2 * K + 1), parityLayer n k K :=
    aSumSeq_layer_decomp n K (2 * K + 1) h_aSeq_le'
  -- Step 5: Steiner gives 3^K < 2^(aSumSeq n K)
  have h_steiner : 3 ^ K < 2 ^ (aSumSeq n K) := cycle_pow2_gt_pow3 n K hcyc
  -- Step 6: Substitute
  rw [← h_layer]
  exact h_steiner

/-!
## Corollary: the layer-cake total has an explicit lower bound
-/

/-- For any cycle, the total layer-cake sum strictly exceeds `K · log_2(3)`
in the sense of `2^{total} > 3^K`. This is the parameter-free strict lower
bound on the layer-cake total. -/
theorem cycle_layer_total_gt_log2_3 (n K : ℕ) (hcyc : IsOddCycle n K) :
    3 ^ K < 2 ^ (∑ k ∈ Finset.range (2 * K + 1), parityLayer n k K) :=
  cycle_layer_pow_gt_3pow n K hcyc

/-!
## Combined upper-lower interval on layer-cake total
-/

/-- For any cycle, `S = aSumSeq` lies in `(K · log_2 3, 2K]` (in pow form):
- Lower bound: `2^S > 3^K` (Steiner)
- Upper bound: `S ≤ 2K` (Eric's `cycle_sum_upper`)

Both expressed via the layer-cake decomposition. -/
theorem cycle_layer_interval (n K : ℕ) (hcyc : IsOddCycle n K) :
    3 ^ K < 2 ^ (∑ k ∈ Finset.range (2 * K + 1), parityLayer n k K) ∧
    ∑ k ∈ Finset.range (2 * K + 1), parityLayer n k K ≤ 2 * K := by
  refine ⟨cycle_layer_pow_gt_3pow n K hcyc, ?_⟩
  -- Upper bound: aSumSeq = sum layers ≤ 2K
  have h_aSeq_le' : ∀ i, i < K → aSeq n i ≤ 2 * K + 1 := fun i hi =>
    Nat.le_succ_of_le (cycle_aSeq_le_2K n K hcyc i hi)
  have h_layer : aSumSeq n K =
      ∑ k ∈ Finset.range (2 * K + 1), parityLayer n k K :=
    aSumSeq_layer_decomp n K (2 * K + 1) h_aSeq_le'
  rw [← h_layer]
  exact cycle_sum_upper n K hcyc

/-!
## Significance summary

For any Collatz cycle:
$$\boxed{
  3^K \;<\; 2^{\sum_{k<2K+1} A_k(K)} \;\leq\; 2^{2K}
}$$

where `A_k(K) = parityLayer n k K = #\{i < K : k < s_i\}`.

The lower bound `K · \log_2 3` follows from Steiner; the upper bound `2K`
follows from the combinatorial constraint that each `s_i ≤ 2K` is needed
for cycle existence.

Within this interval, the question of the post-JAR research program becomes:
**can a parameter-free analytical or combinatorial argument force the layer-cake
total to lie strictly above `K \log_2 3 + g(K)` with `g(K) = O(K^{-7})`?**
If yes, Baker's lower bound `(2^S - 3^K) k^6 ≥ 3^K` forces a contradiction
for `K` sufficiently large, replacing `ProductBoundThreshold` by an
unconditional theorem.

The structural framework for this attack is now in place (Rounds 11-14).
What remains is the **analytical step** — bounding the difference
`\sum_k A_k - K \log_2 3` from below or above by a parameter-free function.
-/

end ProjetCollatz
