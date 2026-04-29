import ProjetCollatz.Phase52SteinerEquation
import ProjetCollatz.Phase50CycleEquation
import ProjetCollatz.PostJAR.SteinerLayerConnection

/-!
# CycleArithmetic.lean — Round 19: Triadic convergence on `v_p(C_s)` vs `v_p(D_s)`

## Origin

This file is the formal Lean output of a structured tri-partite Phase B
research session (NEW + OLD + ChatGPT, Rounds 15-18, 2026-04-27).

After the JAR resubmission was filed (`cb5f8d08-...` Technical Check),
the triade systematically explored possible parameter-free obstructions
to non-trivial Collatz cycles. The conclusion (Round 18 ChatGPT, validated
by OLD audit) is:

> **All "naive" obstructions reduce structurally to the divisibility condition
> `D_s ∣ C_s` from Steiner's identity.**
>
> **The only remaining angle non-absorbed by Steiner / Baker / Mignotte / Hercher /
> Bernstein–Lagarias is fine analysis of the p-adic valuations
> `v_p(C_s)` versus `v_p(D_s)` for primes `p ≥ 5`.**

This file:

1. Reformulates Eric's `corrSum n K` as a **function of the parity vector**
   (`cyclicSum : List ℕ → ℕ`), enabling reasoning independent of any candidate
   starting value `n_0`.
2. States the cycle ↔ divisibility equivalence, which is a direct corollary of
   Eric's `Phase52SteinerEquation.steiner_eq`.
3. Eliminates the `k = 1` case explicitly (only `s = [2]` admits a positive
   integer cycle, and that is the trivial cycle `1 → 1` in odd-iterate
   convention).
4. **States the key conjecture identified by the triade**: for every non-trivial
   parity vector with length `k ≥ 2`, there exists a prime `p` such that
   `v_p (cyclicSum s) < v_p (cyclicDenom s)`, which would imply
   `cyclicDenom s ∤ cyclicSum s` and hence eliminate the cycle.

If the conjecture `cycle_v_p_obstruction` is proven for all parity vectors with
`k ≥ 2`, the conditional theorem `Phase58PorteDeuxFinal.no_nontrivial_cycle_full`
becomes unconditional via `cycle_iff_divisibility`.

## Status

- Out-of-tree from the JAR submission baseline (`paper/v2/jar-build/`).
- `cyclicSum`, `cyclicDenom`: complete, computable definitions.
- `cyclicSum_singleton`, `cyclicDenom_singleton`: proved.
- `cycle_v_p_obstruction`: stated as conjecture (`sorry`).
- This file does NOT modify any baseline of the JAR conditional theorem.
-/

namespace ProjetCollatz.PostJAR

open scoped BigOperators

/-! ## Parity-vector parameterization -/

/--
Partial sum of parity exponents: `parity_partial_sum s i = s_1 + ... + s_i`.

Convention: `parity_partial_sum s 0 = 0` (empty prefix).
-/
def parity_partial_sum (s : List ℕ) (i : ℕ) : ℕ :=
  (s.take i).sum

@[simp] lemma parity_partial_sum_zero (s : List ℕ) : parity_partial_sum s 0 = 0 := by
  simp [parity_partial_sum]

@[simp] lemma parity_partial_sum_full (s : List ℕ) :
    parity_partial_sum s s.length = s.sum := by
  simp [parity_partial_sum, List.take_length]

/--
The cyclic sum:
$$C_s := \sum_{i=1}^{k} 3^{k-i} \cdot 2^{S_{i-1}}, \quad S_j = \sum_{m \le j} s_m.$$

For a hypothetical Collatz cycle of length `k = s.length` with parity vector `s`,
the (Steiner) identity reads
`n_0 \cdot (2^{S_k} - 3^k) = C_s`,
so the existence of a positive-integer cycle is equivalent to
`(2^{S_k} - 3^k) \mid C_s` together with positivity.

This formulation is the parity-vector form of `corrSum` from
`ProjetCollatz.Phase52SteinerEquation`.
-/
def cyclicSum (s : List ℕ) : ℕ :=
  let k := s.length
  ∑ i ∈ Finset.range k, 3 ^ (k - 1 - i) * 2 ^ (parity_partial_sum s i)

/--
The cyclic denominator: `D_s := 2^S - 3^k` where `S = Σ s_i` and `k = s.length`.

For any Collatz cycle, `D_s > 0` (this is `Phase50CycleEquation.cycle_pow2_gt_pow3`).
We use `ℤ` to keep arithmetic clean even outside the cycle case.
-/
def cyclicDenom (s : List ℕ) : ℤ :=
  (2 : ℤ) ^ s.sum - (3 : ℤ) ^ s.length

/--
The candidate cycle starting value `x_s = C_s / D_s`, taken in the rationals.

For a real Collatz cycle with parity vector `s`, this rational must be a
positive integer (`n_0 > 0`).
-/
noncomputable def cyclicValue (s : List ℕ) : ℚ :=
  (cyclicSum s : ℚ) / (cyclicDenom s : ℚ)

/-! ## Explicit calculations: `k = 1` and `k = 2` -/

/-- For a singleton parity vector `s = [s_1]`, we have `C_s = 1`. -/
@[simp] lemma cyclicSum_singleton (s_1 : ℕ) : cyclicSum [s_1] = 1 := by
  simp [cyclicSum, parity_partial_sum]

/-- For a singleton parity vector `s = [s_1]`, we have `D_s = 2^{s_1} - 3`. -/
@[simp] lemma cyclicDenom_singleton (s_1 : ℕ) :
    cyclicDenom [s_1] = (2 : ℤ) ^ s_1 - 3 := by
  simp [cyclicDenom]

/--
For a pair parity vector `s = [s_1, s_2]`, we have
`C_s = 3 + 2^{s_1}`.
-/
lemma cyclicSum_pair (s_1 s_2 : ℕ) :
    cyclicSum [s_1, s_2] = 3 + 2 ^ s_1 := by
  unfold cyclicSum parity_partial_sum
  simp [Finset.sum_range_succ, pow_succ, pow_zero,
        List.take, List.sum]

/--
For a pair parity vector `s = [s_1, s_2]`, we have
`D_s = 2^{s_1 + s_2} - 9`.
-/
lemma cyclicDenom_pair (s_1 s_2 : ℕ) :
    cyclicDenom [s_1, s_2] = (2 : ℤ) ^ (s_1 + s_2) - 9 := by
  unfold cyclicDenom
  simp [List.sum, List.length]

/-! ## Elimination `k = 1`: only the trivial cycle -/

/--
For `k = 1`, the cycle equation `n_0 \cdot D_s = C_s` becomes
`n_0 \cdot (2^{s_1} - 3) = 1`. The only positive integer solution is
`s_1 = 2, n_0 = 1`, which is the trivial cycle `1 → 1`.

This rules out all other length-1 parity vectors (`s_1 \in \{1, 3, 4, 5, ...\}`).
-/
theorem k1_only_trivial (s_1 n_0 : ℕ) (hpos : 0 < n_0)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ s_1 - 3) = 1) :
    s_1 = 2 ∧ n_0 = 1 := by
  -- We have n_0 ≥ 1 and (n_0 : ℤ) · (2^{s_1} - 3) = 1.
  -- Since n_0 ≥ 1, we need (2^{s_1} - 3) ∈ {1, -1, 0} but only `=1` gives n_0 = 1 > 0.
  -- s_1 = 0: 2^0 - 3 = -2, then n_0 = -1/2, impossible
  -- s_1 = 1: 2^1 - 3 = -1, then n_0 = -1, contradicts n_0 > 0
  -- s_1 = 2: 2^2 - 3 = 1, then n_0 = 1 ✓
  -- s_1 ≥ 3: |2^{s_1} - 3| ≥ 5, then |n_0 · (...)| ≥ 5 > 1, impossible
  rcases Nat.lt_or_ge s_1 3 with hlt | hge
  · -- Case s_1 < 3: try s_1 = 0, 1, 2
    interval_cases s_1
    · -- s_1 = 0: 2^0 - 3 = -2, n_0 · (-2) = 1, impossible for n_0 ≥ 1
      simp at heq
      omega
    · -- s_1 = 1: 2^1 - 3 = -1, n_0 · (-1) = 1, n_0 = -1, impossible
      simp at heq
      omega
    · -- s_1 = 2: 2^2 - 3 = 1, n_0 · 1 = 1, n_0 = 1 ✓
      refine ⟨rfl, ?_⟩
      simp at heq
      omega
  · -- Case s_1 ≥ 3: 2^{s_1} ≥ 8, so 2^{s_1} - 3 ≥ 5
    exfalso
    have h2pow : (2 : ℤ) ^ s_1 ≥ 8 := by
      calc (2 : ℤ) ^ s_1 ≥ (2 : ℤ) ^ 3 := by
            apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hge
        _ = 8 := by norm_num
    have hge5 : (2 : ℤ) ^ s_1 - 3 ≥ 5 := by linarith
    -- Then n_0 · (2^{s_1} - 3) ≥ 1 · 5 = 5 > 1
    have hn0 : (n_0 : ℤ) ≥ 1 := by exact_mod_cast hpos
    nlinarith [hn0, hge5, heq]

/-! ## Round 20: Elimination of `k = 2` (archimedean argument by cases on S = s_1 + s_2)

For `k = 2` with `s_1, s_2 ≥ 1`, the cycle equation reads
   `n_0 · (2^(s_1+s_2) - 9) = 2^(s_1) + 3`.

We split on `S := s_1 + s_2`:
- `S ≤ 3`:  `2^S ≤ 8 < 9`, so `D_s < 0`; together with `n_0 > 0`, contradicts `C_s > 0`.
- `S = 4` :  `D_s = 7`, three cases (1,3), (2,2), (3,1):
    - `(1, 3)`:  `7 n_0 = 5`, no integer solution
    - `(2, 2)`:  `7 n_0 = 7`, gives `n_0 = 1` (the trivial cycle 1→1, *not* a true k=2 cycle)
    - `(3, 1)`:  `7 n_0 = 11`, no integer solution
- `S ≥ 5` :  archimedean argument: `2^(s_1) + 3 < 2^(s_1+s_2) - 9`, so `n_0 < 1` is impossible
  for `n_0 ≥ 1`.

The output is the elimination of all *non-trivial* k=2 parity vectors.
-/

/-- Sub-case `S = s_1 + s_2 = 4` of `cycle_eliminated_k2`: only (2, 2) admits an
    integer solution, and that solution is `n_0 = 1` (which is the trivial cycle
    excluded by `n_0 > 1`). -/
theorem cycle_k2_S_eq_4_only_trivial
    (s_1 s_2 n_0 : ℕ) (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1)
    (hsum : s_1 + s_2 = 4) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2) - 9) = 2 ^ s_1 + 3) :
    False := by
  -- s_1 + s_2 = 4, s_1, s_2 ≥ 1 forces (s_1, s_2) ∈ {(1,3), (2,2), (3,1)}.
  have hs_lt : s_1 ≤ 3 := by omega
  interval_cases s_1
  · -- s_1 = 1, so s_2 = 3
    have hs_2 : s_2 = 3 := by omega
    subst hs_2
    -- heq becomes n_0 * 7 = 5, impossible
    norm_num at heq
    omega
  · -- s_1 = 2, so s_2 = 2
    have hs_2 : s_2 = 2 := by omega
    subst hs_2
    -- heq becomes n_0 * 7 = 7, so n_0 = 1, contradicting hpos
    norm_num at heq
    omega
  · -- s_1 = 3, so s_2 = 1
    have hs_2 : s_2 = 1 := by omega
    subst hs_2
    -- heq becomes n_0 * 7 = 11, impossible
    norm_num at heq
    omega

/-- Sub-case `S ≤ 3` of `cycle_eliminated_k2`: `D_s = 2^S - 9 ≤ -1 < 0`, so
    `n_0 · D_s < 0` for `n_0 > 0`, contradicting `C_s = 2^(s_1) + 3 > 0`. -/
theorem cycle_k2_S_le_3_impossible
    (s_1 s_2 n_0 : ℕ) (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1)
    (hsum_le : s_1 + s_2 ≤ 3) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2) - 9) = 2 ^ s_1 + 3) :
    False := by
  -- We bound 2^(s_1 + s_2) ≤ 2^3 = 8, so 2^(s_1+s_2) - 9 ≤ -1.
  have h2S : (2 : ℤ) ^ (s_1 + s_2) ≤ 8 := by
    have : (s_1 + s_2 : ℕ) ≤ 3 := hsum_le
    calc (2 : ℤ) ^ (s_1 + s_2) ≤ (2 : ℤ) ^ 3 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) this
      _ = 8 := by norm_num
  have hDneg : (2 : ℤ) ^ (s_1 + s_2) - 9 ≤ -1 := by linarith
  have hn0pos : (n_0 : ℤ) ≥ 2 := by exact_mod_cast hpos
  have hCpos : (2 : ℤ) ^ s_1 + 3 ≥ 5 := by
    have : (2 : ℤ) ^ s_1 ≥ 2 := by
      calc (2 : ℤ) ^ s_1 ≥ (2 : ℤ) ^ 1 := by
            apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) h1
        _ = 2 := by norm_num
    linarith
  -- LHS = n_0 · D, with n_0 ≥ 2 ≥ 0 and D ≤ -1, so LHS ≤ -2 < 0
  -- But LHS = RHS = 2^(s_1) + 3 ≥ 5 > 0. Contradiction.
  nlinarith [heq, hDneg, hn0pos, hCpos]

/-- Sub-case `S ≥ 5` of `cycle_eliminated_k2`: archimedean argument shows that
    `0 < (2^(s_1) + 3) / (2^(s_1+s_2) - 9) < 1`, so the integer equation
    `n_0 · D_s = C_s` forces `n_0 = 0`, contradicting `n_0 > 1`. -/
theorem cycle_k2_S_ge_5_impossible
    (s_1 s_2 n_0 : ℕ) (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1)
    (hsum_ge : s_1 + s_2 ≥ 5) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2) - 9) = 2 ^ s_1 + 3) :
    False := by
  -- We show 2^(s_1) + 3 < 2^(s_1+s_2) - 9, equivalently 12 < 2^(s_1) · (2^(s_2) - 1).
  -- Combined with n_0 ≥ 2, n_0 · D_s ≥ 2 · D_s ≥ 2 · (C_s + 1) > C_s. Contradiction.
  have h2pow_S : (2 : ℤ) ^ (s_1 + s_2) ≥ 32 := by
    calc (2 : ℤ) ^ (s_1 + s_2) ≥ (2 : ℤ) ^ 5 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum_ge
      _ = 32 := by norm_num
  -- We show: 2^(s_1+s_2) - 9 > 2^(s_1) + 3 (i.e. C_s < D_s strictly)
  -- Using s_1 ≤ s_1+s_2-1 (since s_2 ≥ 1), 2^(s_1) ≤ 2^(s_1+s_2-1) = 2^(s_1+s_2) / 2.
  have hs1_le : s_1 ≤ s_1 + s_2 - 1 := by omega
  have h2pow_s1 : (2 : ℤ) ^ s_1 ≤ (2 : ℤ) ^ (s_1 + s_2 - 1) := by
    apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hs1_le
  -- 2 · 2^(s_1+s_2-1) = 2^(s_1+s_2). So 2^(s_1) ≤ 2^(s_1+s_2)/2.
  have h_half : (2 : ℤ) * (2 : ℤ) ^ (s_1 + s_2 - 1) = (2 : ℤ) ^ (s_1 + s_2) := by
    have h_pos : 1 ≤ s_1 + s_2 := by omega
    rw [← pow_succ']
    congr 1
    omega
  have hC_lt_D : (2 : ℤ) ^ s_1 + 3 < (2 : ℤ) ^ (s_1 + s_2) - 9 := by
    have : (2 : ℤ) ^ s_1 ≤ (2 : ℤ) ^ (s_1 + s_2) / 2 := by
      have h_div : (2 : ℤ) ^ (s_1 + s_2 - 1) = (2 : ℤ) ^ (s_1 + s_2) / 2 := by
        rw [← h_half]; ring_nf; omega
      linarith [h2pow_s1, h_div]
    linarith
  -- From heq: n_0 · D = C, with n_0 ≥ 2 and D > C > 0
  -- Then n_0 · D ≥ 2 · D > 2 · C > C, contradicting equality.
  have hn0 : (n_0 : ℤ) ≥ 2 := by exact_mod_cast hpos
  have hD_pos : (2 : ℤ) ^ (s_1 + s_2) - 9 > 0 := by linarith
  have hC_pos : (2 : ℤ) ^ s_1 + 3 > 0 := by positivity
  nlinarith [heq, hC_lt_D, hn0, hD_pos]

/-- **Round 20 main theorem**: For any parity vector `s = [s_1, s_2]` with
    `s_1, s_2 ≥ 1`, there is **no** integer cycle starting value `n_0 > 1`.

The only k=2 case admitting `n_0 = 1` is `(s_1, s_2) = (2, 2)`, but this
corresponds to the trivial cycle `1 → 1` already realized at k=1
(odd-iterate convention). So no genuine k=2 non-trivial Collatz cycle exists.

Combined with `k1_only_trivial`, this eliminates Collatz cycles for `k ∈ {1, 2}`,
matching Hercher 2023 (k ≤ 91) on the smallest cases.
-/
theorem cycle_eliminated_k2
    (s_1 s_2 n_0 : ℕ) (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2) - 9) = 2 ^ s_1 + 3) :
    False := by
  -- Split on S = s_1 + s_2: either S ≤ 3, S = 4, or S ≥ 5.
  rcases lt_or_ge (s_1 + s_2) 4 with hS_lt | hS_ge
  · -- S ≤ 3
    exact cycle_k2_S_le_3_impossible s_1 s_2 n_0 h1 h2 (by omega) hpos heq
  · rcases lt_or_ge (s_1 + s_2) 5 with hS_lt5 | hS_ge5
    · -- S = 4
      have hS_eq : s_1 + s_2 = 4 := by omega
      exact cycle_k2_S_eq_4_only_trivial s_1 s_2 n_0 h1 h2 hS_eq hpos heq
    · -- S ≥ 5
      exact cycle_k2_S_ge_5_impossible s_1 s_2 n_0 h1 h2 hS_ge5 hpos heq

/-! ## Round 21: Elimination of `k = 3` (refined archimedean argument)

For `k = 3` with `s_1, s_2, s_3 ≥ 1`, the cycle equation reads
   `n_0 · (2^(s_1+s_2+s_3) - 27) = 9 + 3 · 2^(s_1) + 2^(s_1+s_2)`.

**Triadic convergence (Round 21, NEW + OLD + ChatGPT)**: the standard archimedean
threshold "C_s < D_s for all S ≥ N" *does not exist* for k=3 (unlike k=2). For
`s_3 = 1`, `D_s = 2 · 2^(s_1+s_2) - 27` stays close to
`C_s = 9 + 3 · 2^(s_1) + 2^(s_1+s_2)` and asymptotically `n_0 → 5/4` for
`s_2 = s_3 = 1, s_1 → ∞`.

**OLD's elegant fix**: use the hypothesis `n_0 > 1` directly in the archimedean
step. We require `C_s < 2 D_s` instead of `C_s < D_s`, which gives a clean
threshold `S ≥ 7`. For `S ≥ 7`, `n_0 < 2`, so `n_0 ∈ {0, 1}`, contradicting
`n_0 > 1`.

We split on `S := s_1 + s_2 + s_3`:
- `S ≤ 4`: `2^S ≤ 16 < 27`, so `D_s < 0`; combined with `n_0 > 0` and `C_s > 0`,
  contradicts the equation.
- `S = 5`: `D_s = 5`, six cases (1,1,3), (1,2,2), (1,3,1), (2,1,2), (2,2,1),
  (3,1,1). All `C_s mod 5 ≠ 0`.
- `S = 6`: `D_s = 37`, ten cases. Only `(2, 2, 2)` admits `n_0 = 1` (the trivial
  cycle 1→1→1), which is excluded by `n_0 > 1`.
- `S ≥ 7`: refined archimedean. `C_s ≤ 9 + 5·2^(S-2)`, `2 D_s = 8·2^(S-2) - 54`.
  Then `C_s < 2 D_s ⟺ 2^(S-2) > 21 ⟺ S ≥ 7`. So `n_0 < 2`, contradicting `n_0 > 1`.

ChatGPT's complementary numerical verification: for `s_i ∈ [1, 50)`, exhaustive
Python enumeration finds 0 solutions with `n_0 ≥ 2` and only the trivial case
`(2, 2, 2, 1, 37, 37)`. This empirically confirms the analytical proof.
-/

/--
For a triple parity vector `s = [s_1, s_2, s_3]`, we have
`C_s = 9 + 3 · 2^(s_1) + 2^(s_1 + s_2)`.
-/
lemma cyclicSum_triple (s_1 s_2 s_3 : ℕ) :
    cyclicSum [s_1, s_2, s_3] = 9 + 3 * 2 ^ s_1 + 2 ^ (s_1 + s_2) := by
  unfold cyclicSum parity_partial_sum
  simp [Finset.sum_range_succ, pow_succ, pow_zero,
        List.take, List.sum]

/--
For a triple parity vector `s = [s_1, s_2, s_3]`, we have
`D_s = 2^(s_1 + s_2 + s_3) - 27`.
-/
lemma cyclicDenom_triple (s_1 s_2 s_3 : ℕ) :
    cyclicDenom [s_1, s_2, s_3] = (2 : ℤ) ^ (s_1 + s_2 + s_3) - 27 := by
  unfold cyclicDenom
  simp [List.sum, List.length, Nat.add_assoc]

/-- Sub-case `S ≤ 4` of `cycle_eliminated_k3`: `D_s = 2^S - 27 ≤ -11 < 0`, so
    `n_0 · D_s < 0` for `n_0 > 0`, contradicting `C_s > 0`. -/
theorem cycle_k3_S_le_4_impossible
    (s_1 s_2 s_3 n_0 : ℕ) (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1)
    (hsum_le : s_1 + s_2 + s_3 ≤ 4) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3) - 27) =
           9 + 3 * 2 ^ s_1 + 2 ^ (s_1 + s_2)) :
    False := by
  -- Bound 2^(s_1+s_2+s_3) ≤ 2^4 = 16, so D ≤ -11.
  have h2S : (2 : ℤ) ^ (s_1 + s_2 + s_3) ≤ 16 := by
    have : (s_1 + s_2 + s_3 : ℕ) ≤ 4 := hsum_le
    calc (2 : ℤ) ^ (s_1 + s_2 + s_3) ≤ (2 : ℤ) ^ 4 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) this
      _ = 16 := by norm_num
  have hDneg : (2 : ℤ) ^ (s_1 + s_2 + s_3) - 27 ≤ -11 := by linarith
  have hn0 : (n_0 : ℤ) ≥ 2 := by exact_mod_cast hpos
  -- C_s ≥ 9 + 3·2 + 2^2 = 9 + 6 + 4 = 19 > 0 (using s_1 ≥ 1, s_1+s_2 ≥ 2).
  have h2pow_s1 : (2 : ℤ) ^ s_1 ≥ 2 := by
    calc (2 : ℤ) ^ s_1 ≥ (2 : ℤ) ^ 1 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) h1
      _ = 2 := by norm_num
  have hsum12 : s_1 + s_2 ≥ 2 := by omega
  have h2pow_s12 : (2 : ℤ) ^ (s_1 + s_2) ≥ 4 := by
    calc (2 : ℤ) ^ (s_1 + s_2) ≥ (2 : ℤ) ^ 2 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum12
      _ = 4 := by norm_num
  have hCpos : (9 : ℤ) + 3 * 2 ^ s_1 + 2 ^ (s_1 + s_2) ≥ 19 := by linarith
  -- LHS ≤ 2 · (-11) = -22 < 0, but RHS ≥ 19 > 0. Contradiction.
  nlinarith [heq, hDneg, hn0, hCpos]

/-- Sub-case `S = 5` of `cycle_eliminated_k3`: `D_s = 5`, six enumerated cases,
    none admits an integer `n_0 ≥ 2`. -/
theorem cycle_k3_S_eq_5_impossible
    (s_1 s_2 s_3 n_0 : ℕ) (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1)
    (hsum_eq : s_1 + s_2 + s_3 = 5) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3) - 27) =
           9 + 3 * 2 ^ s_1 + 2 ^ (s_1 + s_2)) :
    False := by
  -- s_1 ∈ {1, 2, 3}, s_2 ∈ {1, ...}, s_3 = 5 - s_1 - s_2.
  rw [hsum_eq] at heq
  norm_num at heq
  -- heq : n_0 * 5 = 9 + 3 * 2^s_1 + 2^(s_1+s_2)
  have hs_1_le : s_1 ≤ 3 := by omega
  interval_cases s_1
  · -- s_1 = 1: s_2 + s_3 = 4, s_2 ∈ {1, 2, 3}
    have hs_2_le : s_2 ≤ 3 := by omega
    interval_cases s_2
    all_goals (norm_num at heq; omega)
  · -- s_1 = 2: s_2 + s_3 = 3, s_2 ∈ {1, 2}
    have hs_2_le : s_2 ≤ 2 := by omega
    interval_cases s_2
    all_goals (norm_num at heq; omega)
  · -- s_1 = 3: s_2 = 1, s_3 = 1
    have hs_2_eq : s_2 = 1 := by omega
    subst hs_2_eq
    norm_num at heq
    omega

/-- Sub-case `S = 6` of `cycle_eliminated_k3`: `D_s = 37`, ten enumerated cases.
    Only `(2, 2, 2)` admits `n_0 = 1` (trivial cycle), excluded by `n_0 > 1`. -/
theorem cycle_k3_S_eq_6_only_trivial
    (s_1 s_2 s_3 n_0 : ℕ) (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1)
    (hsum_eq : s_1 + s_2 + s_3 = 6) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3) - 27) =
           9 + 3 * 2 ^ s_1 + 2 ^ (s_1 + s_2)) :
    False := by
  rw [hsum_eq] at heq
  norm_num at heq
  -- heq : n_0 * 37 = 9 + 3 * 2^s_1 + 2^(s_1+s_2)
  have hs_1_le : s_1 ≤ 4 := by omega
  interval_cases s_1
  · -- s_1 = 1: s_2 + s_3 = 5, s_2 ∈ {1, 2, 3, 4}
    have hs_2_le : s_2 ≤ 4 := by omega
    interval_cases s_2
    all_goals (norm_num at heq; omega)
  · -- s_1 = 2: s_2 + s_3 = 4, s_2 ∈ {1, 2, 3}
    have hs_2_le : s_2 ≤ 3 := by omega
    interval_cases s_2
    · -- (2, 1, 3): C = 9 + 12 + 8 = 29, n_0 * 37 = 29, impossible
      norm_num at heq; omega
    · -- (2, 2, 2): C = 9 + 12 + 16 = 37, n_0 = 1, contradicts hpos
      norm_num at heq; omega
    · -- (2, 3, 1): C = 9 + 12 + 32 = 53, n_0 * 37 = 53, impossible
      norm_num at heq; omega
  · -- s_1 = 3: s_2 + s_3 = 3, s_2 ∈ {1, 2}
    have hs_2_le : s_2 ≤ 2 := by omega
    interval_cases s_2
    all_goals (norm_num at heq; omega)
  · -- s_1 = 4: s_2 = 1, s_3 = 1
    have hs_2_eq : s_2 = 1 := by omega
    subst hs_2_eq
    norm_num at heq
    omega

/-- Sub-case `S ≥ 7` of `cycle_eliminated_k3`: refined archimedean.

The bound `C_s ≤ 9 + 5 · 2^(S-2)` (achieved at `(s_1, s_2, s_3) = (S-2, 1, 1)`)
combined with `2 D_s = 8 · 2^(S-2) - 54` yields `C_s < 2 D_s` iff `2^(S-2) > 21`,
which holds for `S ≥ 7`. Then `n_0 < 2`, but `n_0 > 1` forces `n_0 ≥ 2`,
contradiction.
-/
theorem cycle_k3_S_ge_7_impossible
    (s_1 s_2 s_3 n_0 : ℕ) (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1)
    (hsum_ge : s_1 + s_2 + s_3 ≥ 7) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3) - 27) =
           9 + 3 * 2 ^ s_1 + 2 ^ (s_1 + s_2)) :
    False := by
  -- We show: 2 · D_s > C_s, so n_0 ≥ 2 implies n_0 · D_s ≥ 2 D_s > C_s. Contradiction.
  set S := s_1 + s_2 + s_3 with hS_def
  -- Bound 2^S ≥ 2^7 = 128.
  have h2pow_S : (2 : ℤ) ^ S ≥ 128 := by
    calc (2 : ℤ) ^ S ≥ (2 : ℤ) ^ 7 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum_ge
      _ = 128 := by norm_num
  -- D_s ≥ 128 - 27 = 101 > 0.
  have hD_pos : (2 : ℤ) ^ S - 27 ≥ 101 := by linarith
  -- Upper bound C_s: we use s_1 ≤ S - 2 and s_1 + s_2 ≤ S - 1.
  have hs_1_le : s_1 ≤ S - 2 := by omega
  have hs_12_le : s_1 + s_2 ≤ S - 1 := by omega
  have h2pow_s1_le : (2 : ℤ) ^ s_1 ≤ (2 : ℤ) ^ (S - 2) := by
    apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hs_1_le
  have h2pow_s12_le : (2 : ℤ) ^ (s_1 + s_2) ≤ (2 : ℤ) ^ (S - 1) := by
    apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hs_12_le
  -- Express 2^(S-2) and 2^(S-1) in terms of 2^S using S ≥ 7.
  have hS_ge : S ≥ 7 := hsum_ge
  -- 2^S = 4 · 2^(S-2)
  have h2S_eq_4 : (2 : ℤ) ^ S = 4 * (2 : ℤ) ^ (S - 2) := by
    have hS2 : S - 2 + 2 = S := by omega
    calc (2 : ℤ) ^ S
        = (2 : ℤ) ^ (S - 2 + 2) := by rw [hS2]
      _ = (2 : ℤ) ^ (S - 2) * (2 : ℤ) ^ 2 := by rw [pow_add]
      _ = (2 : ℤ) ^ (S - 2) * 4 := by norm_num
      _ = 4 * (2 : ℤ) ^ (S - 2) := by ring
  -- 2^S = 2 · 2^(S-1)
  have h2S_eq_2 : (2 : ℤ) ^ S = 2 * (2 : ℤ) ^ (S - 1) := by
    have hS1 : S - 1 + 1 = S := by omega
    calc (2 : ℤ) ^ S
        = (2 : ℤ) ^ (S - 1 + 1) := by rw [hS1]
      _ = (2 : ℤ) ^ (S - 1) * (2 : ℤ) ^ 1 := by rw [pow_add]
      _ = (2 : ℤ) ^ (S - 1) * 2 := by norm_num
      _ = 2 * (2 : ℤ) ^ (S - 1) := by ring
  -- So 2^(S-2) = 2^S / 4 and 2^(S-1) = 2^S / 2.
  -- Bound C_s ≤ 9 + 3 · 2^(S-2) + 2^(S-1) = 9 + (3/4) · 2^S + (1/2) · 2^S = 9 + (5/4) · 2^S
  -- But for integer arithmetic, we work with: 4 · C_s ≤ 36 + 12 · 2^(S-2) + 4 · 2^(S-1)
  --                                                  = 36 + 3 · 2^S + 2 · 2^S = 36 + 5 · 2^S
  have hC_le : (9 : ℤ) + 3 * 2 ^ s_1 + 2 ^ (s_1 + s_2) ≤
               9 + 3 * (2 : ℤ) ^ (S - 2) + (2 : ℤ) ^ (S - 1) := by
    linarith
  -- 2 D_s = 2 · 2^S - 54
  -- Want: C_s < 2 D_s, i.e. 9 + 3 · 2^(S-2) + 2^(S-1) < 2 · 2^S - 54
  -- Multiply by 4: 36 + 12 · 2^(S-2) + 4 · 2^(S-1) < 8 · 2^S - 216
  --             ⟺ 36 + 3 · 2^S + 2 · 2^S < 8 · 2^S - 216
  --             ⟺ 36 + 5 · 2^S < 8 · 2^S - 216
  --             ⟺ 252 < 3 · 2^S
  --             ⟺ 2^S > 84
  -- For S ≥ 7, 2^S ≥ 128 > 84. ✓
  have hC_lt_2D : (9 : ℤ) + 3 * 2 ^ s_1 + 2 ^ (s_1 + s_2) < 2 * ((2 : ℤ) ^ S - 27) := by
    have h_combine : 9 + 3 * (2 : ℤ) ^ (S - 2) + (2 : ℤ) ^ (S - 1) < 2 * ((2 : ℤ) ^ S - 27) := by
      -- Substitute 2^S = 4 · 2^(S-2) = 2 · 2^(S-1)
      -- 2 · (2^S - 27) = 2^(S+1) - 54
      -- We want: 9 + 3 · 2^(S-2) + 2^(S-1) < 2 · 2^S - 54
      -- Using h2S_eq_4: 4 · 2^(S-2) = 2^S, so 3 · 2^(S-2) = (3/4) · 2^S
      -- Using h2S_eq_2: 2 · 2^(S-1) = 2^S, so 2^(S-1) = (1/2) · 2^S
      nlinarith [h2pow_S, h2S_eq_4, h2S_eq_2]
    linarith
  -- From heq: n_0 · D_s = C_s, with n_0 ≥ 2 and 2 D_s > C_s.
  -- Then n_0 · D_s ≥ 2 D_s > C_s, but heq says equality. Contradiction.
  have hn0 : (n_0 : ℤ) ≥ 2 := by exact_mod_cast hpos
  have hD_pos' : (2 : ℤ) ^ S - 27 > 0 := by linarith
  nlinarith [heq, hC_lt_2D, hn0, hD_pos']

/-- **Round 21 main theorem**: For any parity vector `s = [s_1, s_2, s_3]` with
    `s_1, s_2, s_3 ≥ 1`, there is **no** integer cycle starting value `n_0 > 1`
    satisfying the Steiner cycle equation specialized to `k = 3`.

The only k=3 case admitting `n_0 = 1` is `(s_1, s_2, s_3) = (2, 2, 2)`, but this
corresponds to the trivial cycle `1 → 1` repeated three times (odd-iterate
convention). So no genuine k=3 non-trivial Collatz cycle exists.

Combined with `k1_only_trivial` (Round 19) and `cycle_eliminated_k2` (Round 20),
this eliminates Collatz cycles for `k ∈ {1, 2, 3}`, matching Hercher 2023
(k ≤ 91) on the smallest cases.

**Scope (Red Team R21 finding, severity 8/10)**: this is a *purely arithmetic*
theorem about the equation `n_0 (2^S - 27) = 9 + 3·2^{s_1} + 2^{s_1+s_2}`. The
implication "no k=3 Collatz cycle exists" requires composing this result with
`Phase52SteinerEquation.steiner_cycle_eq`, which establishes that any
`IsOddCycle n 3` satisfies the Steiner equation with the cycle's actual drop
heights `s_i = aSeq n i`. The bridge `corrSum n 3 = cyclicSum (parityVector n 3)`
+ verification that drop heights are `≥ 1` is left to a future round. The
present theorem is therefore *arithmetically correct* but does not yet close the
"no Collatz cycle of length 3" claim end-to-end in a single Lean term. -/
theorem cycle_eliminated_k3
    (s_1 s_2 s_3 n_0 : ℕ) (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1)
    (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3) - 27) =
           9 + 3 * 2 ^ s_1 + 2 ^ (s_1 + s_2)) :
    False := by
  -- Split on S = s_1 + s_2 + s_3.
  rcases lt_or_ge (s_1 + s_2 + s_3) 5 with hS_lt | hS_ge
  · -- S ≤ 4
    exact cycle_k3_S_le_4_impossible s_1 s_2 s_3 n_0 h1 h2 h3 (by omega) hpos heq
  · rcases lt_or_ge (s_1 + s_2 + s_3) 6 with hS_lt6 | hS_ge6
    · -- S = 5
      have hS_eq : s_1 + s_2 + s_3 = 5 := by omega
      exact cycle_k3_S_eq_5_impossible s_1 s_2 s_3 n_0 h1 h2 h3 hS_eq hpos heq
    · rcases lt_or_ge (s_1 + s_2 + s_3) 7 with hS_lt7 | hS_ge7
      · -- S = 6
        have hS_eq : s_1 + s_2 + s_3 = 6 := by omega
        exact cycle_k3_S_eq_6_only_trivial s_1 s_2 s_3 n_0 h1 h2 h3 hS_eq hpos heq
      · -- S ≥ 7
        exact cycle_k3_S_ge_7_impossible s_1 s_2 s_3 n_0 h1 h2 h3 hS_ge7 hpos heq

/-! ## Round 22: Steiner bridge for k=3 (closes Red Team finding F3)

Round 21 left `cycle_eliminated_k3` as a *purely arithmetic* theorem about the
equation `n_0 (2^S - 27) = 9 + 3·2^{s_1} + 2^{s_1+s_2}`. Round 22 closes the
chain end-to-end by composing with `Phase52SteinerEquation.steiner_cycle_eq`:
any `IsOddCycle n 3` produces concrete drop heights `s_i = aSeq n i ≥ 1` whose
arithmetic relation matches the hypothesis of `cycle_eliminated_k3` with
`n_0 = n`. The result is `no_collatz_cycle_k3`: there is **no** non-trivial
Collatz cycle of length 3 in the odd-iterate convention.
-/

/-- For an odd starting value `n`, every drop height `aSeq n j` is at least 1.
This holds because the Syracuse map preserves oddness (`nSeq_odd`), and for
any odd `m`, `3m + 1` is even, so `v_2(3m + 1) ≥ 1`. -/
lemma aSeq_ge_one_of_odd (n j : ℕ) (hodd : n % 2 = 1) :
    aSeq n j ≥ 1 := by
  unfold aSeq v2_3n1
  have hodd_j : nSeq n j % 2 = 1 := nSeq_odd n j hodd
  have h_3n1_ne_zero : 3 * nSeq n j + 1 ≠ 0 := by omega
  have h_div : (2 : ℕ) ^ 1 ∣ (3 * nSeq n j + 1) := by
    have : (2 : ℕ) ∣ (3 * nSeq n j + 1) := by omega
    simpa using this
  exact pow2_dvd_le_v2Nat_pos _ 1 h_3n1_ne_zero h_div

/-- Unfolding `aSumSeq n 3 = aSeq n 0 + aSeq n 1 + aSeq n 2`. -/
lemma aSumSeq_three_eq (n : ℕ) :
    aSumSeq n 3 = aSeq n 0 + aSeq n 1 + aSeq n 2 := by
  rw [show (3 : ℕ) = 2 + 1 from rfl, aSumSeq_succ' n 2,
      show (2 : ℕ) = 1 + 1 from rfl, aSumSeq_succ' n 1,
      show (1 : ℕ) = 0 + 1 from rfl, aSumSeq_succ' n 0]
  unfold aSumSeq aSum
  simp

/-- Unfolding `corrSum n 3 = 9 + 3·2^(aSeq n 0) + 2^(aSeq n 0 + aSeq n 1)`. -/
lemma corrSum_three_eq (n : ℕ) :
    corrSum n 3 = 9 + 3 * 2 ^ (aSeq n 0) + 2 ^ (aSeq n 0 + aSeq n 1) := by
  show corrSum n (2 + 1) = _
  rw [corrSum_succ]
  show 3 * corrSum n (1 + 1) + 2 ^ (aSumSeq n 2) = _
  rw [corrSum_succ]
  show 3 * (3 * corrSum n (0 + 1) + 2 ^ (aSumSeq n 1)) + 2 ^ (aSumSeq n 2) = _
  rw [corrSum_succ]
  -- corrSum n 0 = 0, aSumSeq n 0 = 0, aSumSeq n 1 = aSeq n 0,
  -- aSumSeq n 2 = aSeq n 0 + aSeq n 1.
  have h0 : corrSum n 0 = 0 := rfl
  have hsum0 : aSumSeq n 0 = 0 := by unfold aSumSeq aSum; simp
  have hsum1 : aSumSeq n 1 = aSeq n 0 := by
    rw [show (1 : ℕ) = 0 + 1 from rfl, aSumSeq_succ' n 0, hsum0]
    omega
  have hsum2 : aSumSeq n 2 = aSeq n 0 + aSeq n 1 := by
    rw [show (2 : ℕ) = 1 + 1 from rfl, aSumSeq_succ' n 1, hsum1]
  rw [h0, hsum0, hsum1, hsum2]
  ring

/-- **Round 22 main theorem (Red Team F3 closed)**: there is no non-trivial
Collatz cycle of length 3 in the odd-iterate convention.

Composition: `IsOddCycle n 3` → Steiner equation → arithmetic obstruction
(`cycle_eliminated_k3`).
-/
theorem no_collatz_cycle_k3 (n : ℕ) (hcyc : IsOddCycle n 3) : False := by
  -- Steiner equation: n * 2^(aSumSeq n 3) = 3^3 * n + corrSum n 3
  have hsteiner := steiner_cycle_eq n 3 hcyc
  obtain ⟨hn_gt1, hodd, _, _⟩ := hcyc
  -- Unfold aSumSeq n 3 and corrSum n 3.
  rw [aSumSeq_three_eq n, corrSum_three_eq n] at hsteiner
  -- hsteiner : n * 2^(aSeq n 0 + aSeq n 1 + aSeq n 2)
  --          = 3^3 * n + (9 + 3 * 2^(aSeq n 0) + 2^(aSeq n 0 + aSeq n 1))
  -- Drop height positivity.
  have ha0 : aSeq n 0 ≥ 1 := aSeq_ge_one_of_odd n 0 hodd
  have ha1 : aSeq n 1 ≥ 1 := aSeq_ge_one_of_odd n 1 hodd
  have ha2 : aSeq n 2 ≥ 1 := aSeq_ge_one_of_odd n 2 hodd
  -- Convert ℕ equation to ℤ equation suitable for cycle_eliminated_k3.
  have heq_int : (n : ℤ) * ((2 : ℤ) ^ (aSeq n 0 + aSeq n 1 + aSeq n 2) - 27)
                 = 9 + 3 * 2 ^ (aSeq n 0) + 2 ^ (aSeq n 0 + aSeq n 1) := by
    have h_nat : n * 2 ^ (aSeq n 0 + aSeq n 1 + aSeq n 2)
               = 3 ^ 3 * n + (9 + 3 * 2 ^ (aSeq n 0) + 2 ^ (aSeq n 0 + aSeq n 1)) :=
      hsteiner
    have h_int : (n : ℤ) * (2 : ℤ) ^ (aSeq n 0 + aSeq n 1 + aSeq n 2)
               = 3 ^ 3 * n + (9 + 3 * (2 : ℤ) ^ (aSeq n 0) + 2 ^ (aSeq n 0 + aSeq n 1)) := by
      exact_mod_cast h_nat
    have h27 : (3 : ℤ) ^ 3 = 27 := by norm_num
    linarith [h_int, h27]
  -- Apply cycle_eliminated_k3 with n_0 = n.
  exact cycle_eliminated_k3 (aSeq n 0) (aSeq n 1) (aSeq n 2) n ha0 ha1 ha2 hn_gt1 heq_int

/-! ## Round 22 (extended): Steiner bridges for k=1 and k=2

Following OLD's R22 recommendation, we close the chain end-to-end for k=1 and
k=2 as well (analogous to `no_collatz_cycle_k3` for k=3). This gives uniform
"no Collatz cycle of length k" for k ∈ {1, 2, 3} in the odd-iterate convention.
-/

/-- Unfolding `aSumSeq n 1 = aSeq n 0`. -/
lemma aSumSeq_one_eq (n : ℕ) : aSumSeq n 1 = aSeq n 0 := by
  rw [show (1 : ℕ) = 0 + 1 from rfl, aSumSeq_succ' n 0]
  unfold aSumSeq aSum
  simp

/-- Unfolding `aSumSeq n 2 = aSeq n 0 + aSeq n 1`. -/
lemma aSumSeq_two_eq (n : ℕ) : aSumSeq n 2 = aSeq n 0 + aSeq n 1 := by
  rw [show (2 : ℕ) = 1 + 1 from rfl, aSumSeq_succ' n 1, aSumSeq_one_eq]

/-- Unfolding `corrSum n 1 = 1`. -/
lemma corrSum_one_eq (n : ℕ) : corrSum n 1 = 1 := by
  show corrSum n (0 + 1) = 1
  rw [corrSum_succ]
  have h0 : corrSum n 0 = 0 := rfl
  have hsum0 : aSumSeq n 0 = 0 := by unfold aSumSeq aSum; simp
  rw [h0, hsum0]
  norm_num

/-- Unfolding `corrSum n 2 = 3 + 2^(aSeq n 0)`. -/
lemma corrSum_two_eq (n : ℕ) : corrSum n 2 = 3 + 2 ^ (aSeq n 0) := by
  show corrSum n (1 + 1) = _
  rw [corrSum_succ, corrSum_one_eq, aSumSeq_one_eq]

/-- **No Collatz cycle of length 1**: composition of `k1_only_trivial`
(arithmetic) with the Steiner bridge for k=1.

The only k=1 cycle equation solution is `(s_1, n_0) = (2, 1)`, the trivial
cycle 1 → 1, excluded by `n > 1`.
-/
theorem no_collatz_cycle_k1 (n : ℕ) (hcyc : IsOddCycle n 1) : False := by
  have hsteiner := steiner_cycle_eq n 1 hcyc
  obtain ⟨hn_gt1, hodd, _, _⟩ := hcyc
  -- Unfold aSumSeq n 1 = aSeq n 0, corrSum n 1 = 1.
  rw [aSumSeq_one_eq, corrSum_one_eq] at hsteiner
  -- hsteiner : n * 2^(aSeq n 0) = 3^1 * n + 1, i.e. n * 2^(aSeq n 0) = 3 * n + 1.
  have ha0 : aSeq n 0 ≥ 1 := aSeq_ge_one_of_odd n 0 hodd
  -- Convert to ℤ: n * (2^(aSeq n 0) - 3) = 1.
  have heq_int : (n : ℤ) * ((2 : ℤ) ^ (aSeq n 0) - 3) = 1 := by
    have h_int : (n : ℤ) * (2 : ℤ) ^ (aSeq n 0) = 3 ^ 1 * n + 1 := by
      exact_mod_cast hsteiner
    have h3 : (3 : ℤ) ^ 1 = 3 := by norm_num
    linarith [h_int, h3]
  -- Apply k1_only_trivial.
  have hn_pos : 0 < n := by omega
  obtain ⟨_, hn_eq⟩ := k1_only_trivial (aSeq n 0) n hn_pos heq_int
  omega

/-- **No Collatz cycle of length 2**: composition of `cycle_eliminated_k2`
(arithmetic) with the Steiner bridge for k=2.
-/
theorem no_collatz_cycle_k2 (n : ℕ) (hcyc : IsOddCycle n 2) : False := by
  have hsteiner := steiner_cycle_eq n 2 hcyc
  obtain ⟨hn_gt1, hodd, _, _⟩ := hcyc
  rw [aSumSeq_two_eq, corrSum_two_eq] at hsteiner
  -- hsteiner : n * 2^(aSeq n 0 + aSeq n 1) = 3^2 * n + (3 + 2^(aSeq n 0))
  have ha0 : aSeq n 0 ≥ 1 := aSeq_ge_one_of_odd n 0 hodd
  have ha1 : aSeq n 1 ≥ 1 := aSeq_ge_one_of_odd n 1 hodd
  -- Convert to ℤ: n * (2^(aSeq n 0 + aSeq n 1) - 9) = 2^(aSeq n 0) + 3.
  have heq_int : (n : ℤ) * ((2 : ℤ) ^ (aSeq n 0 + aSeq n 1) - 9)
                 = 2 ^ (aSeq n 0) + 3 := by
    have h_int : (n : ℤ) * (2 : ℤ) ^ (aSeq n 0 + aSeq n 1)
               = 3 ^ 2 * n + (3 + (2 : ℤ) ^ (aSeq n 0)) := by
      exact_mod_cast hsteiner
    have h9 : (3 : ℤ) ^ 2 = 9 := by norm_num
    linarith [h_int, h9]
  -- Apply cycle_eliminated_k2.
  exact cycle_eliminated_k2 (aSeq n 0) (aSeq n 1) n ha0 ha1 hn_gt1 heq_int

/-! ## Round 23: First step toward k=4 elimination

Round 23 starts the k=4 case. The full proof requires more sub-cases than k=3
because the archimedean threshold `n_0 < N(k)` grows: for k=4, `N(4) = 3`, but
the bound `C_s < 2 D_s` fails at all S (asymptotic ratio C_max/D = 19/8 > 2),
so the strategy `n_0 > 1 → n_0 ≥ 2 → n_0 D_s > C_s` (which works for k=2, k=3)
*does not extend to k=4*.

Numerical exploration (s_i ∈ [1, 20]) confirms:
- 0 non-trivial cycle solutions for k=4
- Only the trivial cycle `(2, 2, 2, 2)` with `n_0 = 1`, `C = D = 175`

This file currently only proves the easy sub-case `S ≤ 6` (sign argument). The
remaining sub-cases (`S ∈ {7, 8}` enumeration + `S ≥ 9` archimedean with
n_0 = 2 sub-analysis) are deferred to a future round, possibly via a generic
k-parametric lemma.
-/

/-- Sub-case `S ≤ 6` of `cycle_eliminated_k4`: `D_s = 2^S - 81 ≤ -17 < 0`, so
    `n_0 · D_s < 0` for `n_0 > 0`, contradicting `C_s > 0`. -/
theorem cycle_k4_S_le_6_impossible
    (s_1 s_2 s_3 s_4 n_0 : ℕ) (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1)
    (hsum_le : s_1 + s_2 + s_3 + s_4 ≤ 6) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) - 81) =
           27 + 9 * 2 ^ s_1 + 3 * 2 ^ (s_1 + s_2) + 2 ^ (s_1 + s_2 + s_3)) :
    False := by
  have h2S : (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) ≤ 64 := by
    calc (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) ≤ (2 : ℤ) ^ 6 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum_le
      _ = 64 := by norm_num
  have hDneg : (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) - 81 ≤ -17 := by linarith
  have hn0 : (n_0 : ℤ) ≥ 2 := by exact_mod_cast hpos
  -- C_s_min: with s_1, s_1+s_2, s_1+s_2+s_3 ≥ 1, 2, 3 respectively,
  -- C_s ≥ 27 + 9·2 + 3·4 + 2^3 = 27 + 18 + 12 + 8 = 65 > 0.
  have h2pow_s1 : (2 : ℤ) ^ s_1 ≥ 2 := by
    calc (2 : ℤ) ^ s_1 ≥ (2 : ℤ) ^ 1 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) h1
      _ = 2 := by norm_num
  have hsum12 : s_1 + s_2 ≥ 2 := by omega
  have h2pow_s12 : (2 : ℤ) ^ (s_1 + s_2) ≥ 4 := by
    calc (2 : ℤ) ^ (s_1 + s_2) ≥ (2 : ℤ) ^ 2 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum12
      _ = 4 := by norm_num
  have hsum123 : s_1 + s_2 + s_3 ≥ 3 := by omega
  have h2pow_s123 : (2 : ℤ) ^ (s_1 + s_2 + s_3) ≥ 8 := by
    calc (2 : ℤ) ^ (s_1 + s_2 + s_3) ≥ (2 : ℤ) ^ 3 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum123
      _ = 8 := by norm_num
  have hCpos : (27 : ℤ) + 9 * 2 ^ s_1 + 3 * 2 ^ (s_1 + s_2) + 2 ^ (s_1 + s_2 + s_3) ≥ 65 := by
    linarith
  -- LHS ≤ 2 · (-17) = -34 < 0, but RHS ≥ 65 > 0. Contradiction.
  nlinarith [heq, hDneg, hn0, hCpos]

/-! ## Round 24: Algebraic recurrence identity for `cyclicDenom` (NEW + OLD + ChatGPT R24 convergence)

Following the R24 metaprompt asking for an *algebraic formula uniform in k*
(no computation, no enumeration), the triade converged on the following
identity, proposed by ChatGPT and validated by OLD's Padé/Tijdeman analysis:

**Recurrence identity** (k → k+1):
```
cyclicDenom (s ++ [a]) = 2^a · cyclicDenom s + 3^(s.length) · (2^a - 3)
```

**Unfolded identity** (closed form, k arbitrary):
```
cyclicDenom s = Σ_{i=0}^{k-1} 3^i · 2^{S - S_{i+1}} · (2^{s_i} - 3)
```
where `S = s.sum`, `S_j = s_1 + ... + s_j`, k = s.length, s_i = s[i] (1-indexed).

The **local defect** `2^{s_i} - 3` has nice values:
- `s_i = 1` → `-1`
- `s_i = 2` → `1`
- `s_i ≥ 3` → positive and large

This identity does *not* prove cycle non-existence on its own (per ChatGPT
severity 10/10 caveat: "c'est un changement de base algébrique, pas une preuve").
But it is:
1. **Algebraic, uniform in k** (no Baker, no Barina, no CF dependency).
2. **Lean-provable by induction** on the list structure.
3. **Foundation** for any future Padé/Tijdeman effective bound (OLD's P4
   recommendation) without rewriting the algebra.

This is Round 24's contribution: a clean algebraic brick.
-/

/-- **Round 24 main identity (recurrence)**: appending a drop height `a` to a
parity vector `s` transforms `cyclicDenom` by multiplying by `2^a` and adding
a defect contribution `3^(s.length) · (2^a - 3)`.

Proof: direct computation from `cyclicDenom s = 2^(s.sum) - 3^(s.length)`.
The `s ++ [a]` increases `s.sum` by `a` and `s.length` by 1.
-/
lemma cyclicDenom_append (s : List ℕ) (a : ℕ) :
    cyclicDenom (s ++ [a]) =
      2 ^ a * cyclicDenom s + (3 : ℤ) ^ s.length * ((2 : ℤ) ^ a - 3) := by
  unfold cyclicDenom
  simp [List.sum_append, List.length_append, pow_add]
  ring

/-! ### Note (R24 closed form, informal)

`cyclicDenom_append` iterated gives a closed-form expression for `cyclicDenom s`
as a weighted sum of local defects `(2^{s_i} - 3)`. Formalising the closed
form requires careful list indexing; for the practical use of the recurrence
in proofs, the recursive `cyclicDenom_append` is sufficient.

The closed form (mathematical statement, not yet a Lean lemma) is:
`cyclicDenom s = Σ_{i=0}^{k-1} 3^i · 2^{(s.drop (i+1)).sum} · (2^{s[i]} - 3)`.

This is the formula highlighted by ChatGPT R24 and partially convergent with
OLD's Padé piste (P4). Future rounds may formalise it explicitly via
`List.foldr` or `List.range` indexing.
-/

/-! ## Round 37: cycle_k4_S_eq_7_impossible (k=4 sub-case S=7)

Following Eric's "construire l'outil ensemble" directive, this proves the
S=7 sub-case for k=4. Pattern: 20 partitions of 7 into 4 parts ≥ 1,
each gives `n_0 * 47 = (specific value)` with the specific value not
divisible by 47 (or n_0 = 1 trivial). Direct enumeration via interval_cases.
-/

/-- Sub-case `S = 7` of `cycle_eliminated_k4`: D_s = 47 (prime), 20
enumerated cases, none admits an integer n_0 ≥ 2. -/
theorem cycle_k4_S_eq_7_impossible
    (s_1 s_2 s_3 s_4 n_0 : ℕ)
    (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1)
    (hsum_eq : s_1 + s_2 + s_3 + s_4 = 7) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) - 81) =
           27 + 9 * 2 ^ s_1 + 3 * 2 ^ (s_1 + s_2) + 2 ^ (s_1 + s_2 + s_3)) :
    False := by
  rw [hsum_eq] at heq
  norm_num at heq
  -- heq : n_0 * 47 = 27 + 9 * 2^s_1 + 3 * 2^(s_1+s_2) + 2^(s_1+s_2+s_3)
  have hs_1_le : s_1 ≤ 4 := by omega
  interval_cases s_1
  · -- s_1 = 1, s_2+s_3+s_4 = 6, s_2 ∈ [1, 4]
    have hs_2_le : s_2 ≤ 4 := by omega
    interval_cases s_2
    · -- s_1=1, s_2=1, s_3+s_4=5, s_3 ∈ [1, 4]
      have hs_3_le : s_3 ≤ 4 := by omega
      interval_cases s_3 <;> (norm_num at heq; omega)
    · -- s_1=1, s_2=2, s_3+s_4=4, s_3 ∈ [1, 3]
      have hs_3_le : s_3 ≤ 3 := by omega
      interval_cases s_3 <;> (norm_num at heq; omega)
    · -- s_1=1, s_2=3, s_3+s_4=3, s_3 ∈ [1, 2]
      have hs_3_le : s_3 ≤ 2 := by omega
      interval_cases s_3 <;> (norm_num at heq; omega)
    · -- s_1=1, s_2=4, s_3+s_4=2, s_3 = 1
      have hs_3_eq : s_3 = 1 := by omega
      subst hs_3_eq; norm_num at heq; omega
  · -- s_1 = 2, s_2+s_3+s_4 = 5, s_2 ∈ [1, 3]
    have hs_2_le : s_2 ≤ 3 := by omega
    interval_cases s_2
    · have hs_3_le : s_3 ≤ 3 := by omega
      interval_cases s_3 <;> (norm_num at heq; omega)
    · have hs_3_le : s_3 ≤ 2 := by omega
      interval_cases s_3 <;> (norm_num at heq; omega)
    · have hs_3_eq : s_3 = 1 := by omega
      subst hs_3_eq; norm_num at heq; omega
  · -- s_1 = 3, s_2+s_3+s_4 = 4, s_2 ∈ [1, 2]
    have hs_2_le : s_2 ≤ 2 := by omega
    interval_cases s_2
    · have hs_3_le : s_3 ≤ 2 := by omega
      interval_cases s_3 <;> (norm_num at heq; omega)
    · have hs_3_eq : s_3 = 1 := by omega
      subst hs_3_eq; norm_num at heq; omega
  · -- s_1 = 4, s_2+s_3+s_4 = 3, s_2 = 1, s_3 = 1, s_4 = 1
    have hs_2_eq : s_2 = 1 := by omega
    subst hs_2_eq
    have hs_3_eq : s_3 = 1 := by omega
    subst hs_3_eq
    norm_num at heq; omega

/-! ## Round 38: cycle_k4_S_eq_8_only_trivial (k=4 sub-case S=8) -/

/-- Sub-case `S = 8` of `cycle_eliminated_k4`: D_s = 175 = 5^2 * 7,
35 enumerated cases. Only `(2, 2, 2, 2)` admits `n_0 = 1` (trivial cycle
1→1→1→1), excluded by `n_0 > 1`. -/
theorem cycle_k4_S_eq_8_only_trivial
    (s_1 s_2 s_3 s_4 n_0 : ℕ)
    (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1)
    (hsum_eq : s_1 + s_2 + s_3 + s_4 = 8) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) - 81) =
           27 + 9 * 2 ^ s_1 + 3 * 2 ^ (s_1 + s_2) + 2 ^ (s_1 + s_2 + s_3)) :
    False := by
  rw [hsum_eq] at heq
  norm_num at heq
  -- heq : n_0 * 175 = 27 + 9 * 2^s_1 + 3 * 2^(s_1+s_2) + 2^(s_1+s_2+s_3)
  have hs_1_le : s_1 ≤ 5 := by omega
  -- Uniform bound: s_3 ≤ 6 (since s_3 ≤ S - 3 = 5, but use 6 for slack)
  -- Actually s_3 ≤ 6 - s_1 - s_2 + 1, but uniform bound 6 always works.
  interval_cases s_1 <;>
    (have hs_2_le : s_2 ≤ 6 := by omega
     interval_cases s_2 <;>
       (have hs_3_le : s_3 ≤ 6 := by omega
        interval_cases s_3 <;> (norm_num at heq; omega)))

/-! ## Auxiliary: 2^x is never divisible by 3 -/

/-- Key auxiliary lemma: `(2 : ℤ)^x` is never divisible by 3.

Proven by induction using `IsCoprime` (gcd(3, 2) = 1). Used in R44 for the
n_0=3 case of cycle_k5_S_ge_11_impossible. -/
lemma three_not_dvd_two_pow (x : ℕ) :
    ¬ (3 : ℤ) ∣ (2 : ℤ) ^ x := by
  induction x with
  | zero =>
    intro h
    -- 3 ∣ 1 is false
    norm_num at h
  | succ n ih =>
    intro h
    rw [pow_succ] at h
    -- h : 3 ∣ 2^n * 2
    -- gcd(3, 2) = 1, so 3 ∣ 2^n.
    have h_co : IsCoprime (3 : ℤ) 2 := by
      rw [Int.isCoprime_iff_gcd_eq_one]
      decide
    exact ih (h_co.dvd_of_dvd_mul_right h)

/-! ## Round 39: cycle_k4_S_ge_9_impossible (archimedean n_0 < 3) -/

/-- **Sub-theorem for cycle_k4_S_ge_9 case n_0 = 2** — PROVED via parity!

🎯 **Eureka**: The case n_0 = 2 is eliminated by elementary parity analysis,
not enumeration!

LHS = 2 * (2^S - 81) is always EVEN (factor of 2).
RHS = 27 + 9·2^{s_1} + 3·2^{s_1+s_2} + 2^{s_1+s_2+s_3}.
  - 27 is ODD.
  - 9·2^{s_1} is even (s_1 ≥ 1).
  - 3·2^{s_1+s_2} is even (s_1+s_2 ≥ 2).
  - 2^{s_1+s_2+s_3} is even (s_1+s_2+s_3 ≥ 3).
  - So RHS = ODD + EVEN + EVEN + EVEN = ODD.

EVEN ≠ ODD → Contradiction.

This eliminates the 4th project axiom (R39 had it as `axiom`). -/
theorem cycle_k4_S_ge_9_n0_2_impossible
    (s_1 s_2 s_3 s_4 : ℕ) (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1)
    (hsum_ge : s_1 + s_2 + s_3 + s_4 ≥ 9)
    (heq : (2 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) - 81) =
           27 + 9 * 2 ^ s_1 + 3 * 2 ^ (s_1 + s_2) + 2 ^ (s_1 + s_2 + s_3)) :
    False := by
  -- Factor each power of 2 with positive exponent (using conv_lhs to localise rewrite).
  have h_s1 : ∃ a : ℤ, (2 : ℤ) ^ s_1 = 2 * a := by
    refine ⟨(2 : ℤ) ^ (s_1 - 1), ?_⟩
    conv_lhs => rw [show s_1 = (s_1 - 1) + 1 from by omega]
    rw [pow_succ]; ring
  have h_s12 : ∃ b : ℤ, (2 : ℤ) ^ (s_1 + s_2) = 2 * b := by
    refine ⟨(2 : ℤ) ^ (s_1 + s_2 - 1), ?_⟩
    conv_lhs => rw [show s_1 + s_2 = (s_1 + s_2 - 1) + 1 from by omega]
    rw [pow_succ]; ring
  have h_s123 : ∃ c : ℤ, (2 : ℤ) ^ (s_1 + s_2 + s_3) = 2 * c := by
    refine ⟨(2 : ℤ) ^ (s_1 + s_2 + s_3 - 1), ?_⟩
    conv_lhs => rw [show s_1 + s_2 + s_3 = (s_1 + s_2 + s_3 - 1) + 1 from by omega]
    rw [pow_succ]; ring
  obtain ⟨a, ha⟩ := h_s1
  obtain ⟨b, hb⟩ := h_s12
  obtain ⟨c, hc⟩ := h_s123
  rw [ha, hb, hc] at heq
  -- heq becomes : 2 * (2^S - 81) = 27 + 9 * (2*a) + 3 * (2*b) + (2*c)
  --              = 27 + 18a + 6b + 2c = 27 + 2*(9a + 3b + c)
  -- LHS = 2*(2^S - 81) is even.
  -- RHS = 27 + 2*(stuff) is odd.
  -- Contradiction by linarith with the integer constraint.
  omega

/-- Sub-case `S ≥ 9` of `cycle_eliminated_k4`: archimedean `n_0 < 3`.

For S ≥ 9: `C_s ≤ 27 + (19/8)·2^S` (max at `(S-3, 1, 1, 1)`),
`3 D_s = 3·2^S - 243`, so `3 D_s - C_s ≥ (5/8)·2^S - 270 > 0` for S ≥ 9
(since 2^9 = 512, (5/8)·512 = 320 > 270).

Hence `n_0 < 3`, so n_0 ∈ {0, 1, 2}. By `hpos: n_0 > 1`, n_0 = 2.
The case n_0 = 2 is axiomatised separately as `cycle_k4_S_ge_9_n0_2_impossible`. -/
theorem cycle_k4_S_ge_9_impossible
    (s_1 s_2 s_3 s_4 n_0 : ℕ)
    (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1)
    (hsum_ge : s_1 + s_2 + s_3 + s_4 ≥ 9) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) - 81) =
           27 + 9 * 2 ^ s_1 + 3 * 2 ^ (s_1 + s_2) + 2 ^ (s_1 + s_2 + s_3)) :
    False := by
  set S := s_1 + s_2 + s_3 + s_4 with hS_def
  -- Bounds for archimedean argument
  have h2pow_S : (2 : ℤ) ^ S ≥ 512 := by
    calc (2 : ℤ) ^ S ≥ (2 : ℤ) ^ 9 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum_ge
      _ = 512 := by norm_num
  -- D > 0
  have hD_pos : (2 : ℤ) ^ S - 81 ≥ 431 := by linarith
  -- Bound C_s ≤ 27 + 9·2^(S-3) + 3·2^(S-2) + 2^(S-1)
  have hs_1_le : s_1 ≤ S - 3 := by omega
  have hs_12_le : s_1 + s_2 ≤ S - 2 := by omega
  have hs_123_le : s_1 + s_2 + s_3 ≤ S - 1 := by omega
  have h2pow_s1_le : (2 : ℤ) ^ s_1 ≤ (2 : ℤ) ^ (S - 3) := by
    apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hs_1_le
  have h2pow_s12_le : (2 : ℤ) ^ (s_1 + s_2) ≤ (2 : ℤ) ^ (S - 2) := by
    apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hs_12_le
  have h2pow_s123_le : (2 : ℤ) ^ (s_1 + s_2 + s_3) ≤ (2 : ℤ) ^ (S - 1) := by
    apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hs_123_le
  -- 2^S = 8 · 2^(S-3), 2^S = 4 · 2^(S-2), 2^S = 2 · 2^(S-1)
  have h2S_eq_8 : (2 : ℤ) ^ S = 8 * (2 : ℤ) ^ (S - 3) := by
    have hS3 : S - 3 + 3 = S := by omega
    calc (2 : ℤ) ^ S = (2 : ℤ) ^ (S - 3 + 3) := by rw [hS3]
      _ = (2 : ℤ) ^ (S - 3) * 8 := by rw [pow_add]; norm_num
      _ = 8 * (2 : ℤ) ^ (S - 3) := by ring
  have h2S_eq_4 : (2 : ℤ) ^ S = 4 * (2 : ℤ) ^ (S - 2) := by
    have hS2 : S - 2 + 2 = S := by omega
    calc (2 : ℤ) ^ S = (2 : ℤ) ^ (S - 2 + 2) := by rw [hS2]
      _ = (2 : ℤ) ^ (S - 2) * 4 := by rw [pow_add]; norm_num
      _ = 4 * (2 : ℤ) ^ (S - 2) := by ring
  have h2S_eq_2 : (2 : ℤ) ^ S = 2 * (2 : ℤ) ^ (S - 1) := by
    have hS1 : S - 1 + 1 = S := by omega
    calc (2 : ℤ) ^ S = (2 : ℤ) ^ (S - 1 + 1) := by rw [hS1]
      _ = (2 : ℤ) ^ (S - 1) * 2 := by rw [pow_add]; norm_num
      _ = 2 * (2 : ℤ) ^ (S - 1) := by ring
  -- Goal: derive contradiction. Split on n_0 = 2 vs n_0 ≥ 3.
  by_cases hn0_eq_2 : n_0 = 2
  · -- n_0 = 2: defer to axiomatised sub-axiom.
    subst hn0_eq_2
    push_cast at heq
    exact cycle_k4_S_ge_9_n0_2_impossible s_1 s_2 s_3 s_4 h1 h2 h3 h4 hsum_ge heq
  · -- n_0 ≥ 3: archimedean argument 3D > C
    have hn0_ge3 : (n_0 : ℤ) ≥ 3 := by
      have : n_0 ≥ 3 := by omega
      exact_mod_cast this
    -- C ≤ 27 + 9·2^(S-3) + 3·2^(S-2) + 2^(S-1)
    have hC_bound : (27 : ℤ) + 9 * 2 ^ s_1 + 3 * 2 ^ (s_1 + s_2) + 2 ^ (s_1 + s_2 + s_3) ≤
                    27 + 9 * (2 : ℤ) ^ (S - 3) + 3 * (2 : ℤ) ^ (S - 2) + (2 : ℤ) ^ (S - 1) := by
      linarith
    -- 3·D - bound ≥ 0 for S ≥ 9
    have h3D_gt_C : 3 * ((2 : ℤ) ^ S - 81) >
                    27 + 9 * (2 : ℤ) ^ (S - 3) + 3 * (2 : ℤ) ^ (S - 2) + (2 : ℤ) ^ (S - 1) := by
      nlinarith [h2pow_S, h2S_eq_8, h2S_eq_4, h2S_eq_2]
    -- LHS = n_0 · D ≥ 3 · D > C ≥ C_s = LHS. Contradiction.
    nlinarith [heq, hn0_ge3, hD_pos, hC_bound, h3D_gt_C]

/-! ## Round 40: cycle_eliminated_k4 (combine 4 sub-cases) + no_collatz_cycle_k4 -/

/-- **Round 40 main theorem**: For any parity vector `s = [s_1, s_2, s_3, s_4]`
with `s_i ≥ 1`, no integer cycle starting value `n_0 > 1` exists.

Combines:
  cycle_k4_S_le_6_impossible (R23, sign argument)
  cycle_k4_S_eq_7_impossible (R37, 20-case enumeration)
  cycle_k4_S_eq_8_only_trivial (R38, 35-case enumeration with trivial)
  cycle_k4_S_ge_9_impossible (R39, archimedean n_0 < 3 + axiom n_0 = 2)

This matches Hercher 2023 for k = 4 (modulo the n_0 = 2 sub-axiom). -/
theorem cycle_eliminated_k4
    (s_1 s_2 s_3 s_4 n_0 : ℕ)
    (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1)
    (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) - 81) =
           27 + 9 * 2 ^ s_1 + 3 * 2 ^ (s_1 + s_2) + 2 ^ (s_1 + s_2 + s_3)) :
    False := by
  rcases lt_or_ge (s_1 + s_2 + s_3 + s_4) 7 with hS_lt | hS_ge
  · exact cycle_k4_S_le_6_impossible s_1 s_2 s_3 s_4 n_0 h1 h2 h3 h4 (by omega) hpos heq
  · rcases lt_or_ge (s_1 + s_2 + s_3 + s_4) 8 with hS_lt8 | hS_ge8
    · have hS_eq : s_1 + s_2 + s_3 + s_4 = 7 := by omega
      exact cycle_k4_S_eq_7_impossible s_1 s_2 s_3 s_4 n_0 h1 h2 h3 h4 hS_eq hpos heq
    · rcases lt_or_ge (s_1 + s_2 + s_3 + s_4) 9 with hS_lt9 | hS_ge9
      · have hS_eq : s_1 + s_2 + s_3 + s_4 = 8 := by omega
        exact cycle_k4_S_eq_8_only_trivial s_1 s_2 s_3 s_4 n_0 h1 h2 h3 h4 hS_eq hpos heq
      · exact cycle_k4_S_ge_9_impossible s_1 s_2 s_3 s_4 n_0 h1 h2 h3 h4 hS_ge9 hpos heq

/-! ## Round 40 Steiner bridge for k=4 -/

/-- Unfolding `aSumSeq n 4 = aSeq n 0 + aSeq n 1 + aSeq n 2 + aSeq n 3`. -/
lemma aSumSeq_four_eq (n : ℕ) :
    aSumSeq n 4 = aSeq n 0 + aSeq n 1 + aSeq n 2 + aSeq n 3 := by
  rw [show (4 : ℕ) = 3 + 1 from rfl, aSumSeq_succ' n 3, aSumSeq_three_eq n]

/-- Unfolding `corrSum n 4 = 27 + 9·2^{a_0} + 3·2^{a_0+a_1} + 2^{a_0+a_1+a_2}`. -/
lemma corrSum_four_eq (n : ℕ) :
    corrSum n 4 = 27 + 9 * 2 ^ (aSeq n 0) + 3 * 2 ^ (aSeq n 0 + aSeq n 1) +
                  2 ^ (aSeq n 0 + aSeq n 1 + aSeq n 2) := by
  show corrSum n (3 + 1) = _
  rw [corrSum_succ, corrSum_three_eq]
  -- aSumSeq n 3 = aSeq n 0 + aSeq n 1 + aSeq n 2
  have hsum3 : aSumSeq n 3 = aSeq n 0 + aSeq n 1 + aSeq n 2 := by
    rw [show (3 : ℕ) = 2 + 1 from rfl, aSumSeq_succ' n 2,
        show (2 : ℕ) = 1 + 1 from rfl, aSumSeq_succ' n 1,
        show (1 : ℕ) = 0 + 1 from rfl, aSumSeq_succ' n 0]
    have h0 : aSumSeq n 0 = 0 := by unfold aSumSeq aSum; simp
    omega
  rw [hsum3]
  ring

/-- **No Collatz cycle of length 4** (modulo `cycle_k4_S_ge_9_n0_2_impossible`). -/
theorem no_collatz_cycle_k4 (n : ℕ) (hcyc : IsOddCycle n 4) : False := by
  have hsteiner := steiner_cycle_eq n 4 hcyc
  obtain ⟨hn_gt1, hodd, _, _⟩ := hcyc
  rw [aSumSeq_four_eq n, corrSum_four_eq n] at hsteiner
  have ha0 : aSeq n 0 ≥ 1 := aSeq_ge_one_of_odd n 0 hodd
  have ha1 : aSeq n 1 ≥ 1 := aSeq_ge_one_of_odd n 1 hodd
  have ha2 : aSeq n 2 ≥ 1 := aSeq_ge_one_of_odd n 2 hodd
  have ha3 : aSeq n 3 ≥ 1 := aSeq_ge_one_of_odd n 3 hodd
  have heq_int : (n : ℤ) * ((2 : ℤ) ^ (aSeq n 0 + aSeq n 1 + aSeq n 2 + aSeq n 3) - 81) =
                 27 + 9 * 2 ^ (aSeq n 0) + 3 * 2 ^ (aSeq n 0 + aSeq n 1) +
                 2 ^ (aSeq n 0 + aSeq n 1 + aSeq n 2) := by
    have h_int : (n : ℤ) * (2 : ℤ) ^ (aSeq n 0 + aSeq n 1 + aSeq n 2 + aSeq n 3) =
                 3 ^ 4 * n + (27 + 9 * (2 : ℤ) ^ (aSeq n 0) +
                              3 * (2 : ℤ) ^ (aSeq n 0 + aSeq n 1) +
                              (2 : ℤ) ^ (aSeq n 0 + aSeq n 1 + aSeq n 2)) := by
      exact_mod_cast hsteiner
    have h81 : (3 : ℤ) ^ 4 = 81 := by norm_num
    linarith [h_int, h81]
  exact cycle_eliminated_k4 (aSeq n 0) (aSeq n 1) (aSeq n 2) (aSeq n 3) n
    ha0 ha1 ha2 ha3 hn_gt1 heq_int

/-! ## Round 42: cycle_k5_S_le_7_impossible (k=5 sub-case, sign) -/

/-- Sub-case `S ≤ 7` of `cycle_eliminated_k5`: `D_s = 2^S - 243 ≤ -115 < 0`,
sign argument. -/
theorem cycle_k5_S_le_7_impossible
    (s_1 s_2 s_3 s_4 s_5 n_0 : ℕ)
    (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1) (h5 : s_5 ≥ 1)
    (hsum_le : s_1 + s_2 + s_3 + s_4 + s_5 ≤ 7) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5) - 243) =
           81 + 27 * 2 ^ s_1 + 9 * 2 ^ (s_1 + s_2) + 3 * 2 ^ (s_1 + s_2 + s_3) +
           2 ^ (s_1 + s_2 + s_3 + s_4)) :
    False := by
  have h2S : (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5) ≤ 128 := by
    calc (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5) ≤ (2 : ℤ) ^ 7 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum_le
      _ = 128 := by norm_num
  have hDneg : (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5) - 243 ≤ -115 := by linarith
  have hn0 : (n_0 : ℤ) ≥ 2 := by exact_mod_cast hpos
  -- C_s lower bound
  have h2pow_s1 : (2 : ℤ) ^ s_1 ≥ 2 := by
    calc (2 : ℤ) ^ s_1 ≥ (2 : ℤ) ^ 1 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) h1
      _ = 2 := by norm_num
  have hsum12 : s_1 + s_2 ≥ 2 := by omega
  have h2pow_s12 : (2 : ℤ) ^ (s_1 + s_2) ≥ 4 := by
    calc (2 : ℤ) ^ (s_1 + s_2) ≥ (2 : ℤ) ^ 2 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum12
      _ = 4 := by norm_num
  have hsum123 : s_1 + s_2 + s_3 ≥ 3 := by omega
  have h2pow_s123 : (2 : ℤ) ^ (s_1 + s_2 + s_3) ≥ 8 := by
    calc (2 : ℤ) ^ (s_1 + s_2 + s_3) ≥ (2 : ℤ) ^ 3 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum123
      _ = 8 := by norm_num
  have hsum1234 : s_1 + s_2 + s_3 + s_4 ≥ 4 := by omega
  have h2pow_s1234 : (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) ≥ 16 := by
    calc (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) ≥ (2 : ℤ) ^ 4 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum1234
      _ = 16 := by norm_num
  have hCpos : (81 : ℤ) + 27 * 2 ^ s_1 + 9 * 2 ^ (s_1 + s_2) + 3 * 2 ^ (s_1 + s_2 + s_3) +
               2 ^ (s_1 + s_2 + s_3 + s_4) ≥ 211 := by linarith
  -- LHS ≤ 2 * (-115) = -230, RHS ≥ 211. Contradiction.
  nlinarith [heq, hDneg, hn0, hCpos]

/-! ## Round 43: cycle_k5_S_ge_11_impossible (FUTURE WORK)

For k=5, S ≥ 11: archimedean argument gives `5 D > C_max`, hence n_0 < 5.
With hpos: n_0 > 1, n_0 ∈ {2, 3, 4}. Each case eliminated by modular
arithmetic (n_0 = 2, 4 by parity, n_0 = 3 by mod 3).

Initial implementation (R43 attempt) hit Lean compile timeout due to the
size of context (10+ hypotheses on power inequalities). Refactoring into
smaller sub-theorems is needed (~3-5 sub-theorems for n_0 = 2, 3, 4 and
archimedean separately).

Deferred to R44+. The mathematical argument is clear and correct.
-/

set_option maxHeartbeats 400000 in
theorem cycle_k5_S_ge_11_impossible
    (s_1 s_2 s_3 s_4 s_5 n_0 : ℕ)
    (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1) (h5 : s_5 ≥ 1)
    (hsum_ge : s_1 + s_2 + s_3 + s_4 + s_5 ≥ 11) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5) - 243) =
           81 + 27 * 2 ^ s_1 + 9 * 2 ^ (s_1 + s_2) + 3 * 2 ^ (s_1 + s_2 + s_3) +
           2 ^ (s_1 + s_2 + s_3 + s_4)) :
    False := by
  set S := s_1 + s_2 + s_3 + s_4 + s_5 with hS_def
  -- 2^S >= 2^11 = 2048
  have h2pow_S : (2 : ℤ) ^ S ≥ 2048 := by
    calc (2 : ℤ) ^ S ≥ (2 : ℤ) ^ 11 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum_ge
      _ = 2048 := by norm_num
  -- D > 0
  have hD_pos : (2 : ℤ) ^ S - 243 ≥ 1805 := by linarith
  -- Bounds on s_1, s_1+s_2, etc.
  have hs_1_le : s_1 ≤ S - 4 := by omega
  have hs_12_le : s_1 + s_2 ≤ S - 3 := by omega
  have hs_123_le : s_1 + s_2 + s_3 ≤ S - 2 := by omega
  have hs_1234_le : s_1 + s_2 + s_3 + s_4 ≤ S - 1 := by omega
  have h2pow_s1_le : (2 : ℤ) ^ s_1 ≤ (2 : ℤ) ^ (S - 4) := by
    apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hs_1_le
  have h2pow_s12_le : (2 : ℤ) ^ (s_1 + s_2) ≤ (2 : ℤ) ^ (S - 3) := by
    apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hs_12_le
  have h2pow_s123_le : (2 : ℤ) ^ (s_1 + s_2 + s_3) ≤ (2 : ℤ) ^ (S - 2) := by
    apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hs_123_le
  have h2pow_s1234_le : (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) ≤ (2 : ℤ) ^ (S - 1) := by
    apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hs_1234_le
  -- 2^S = 16 * 2^(S-4), 2^S = 8 * 2^(S-3), 2^S = 4 * 2^(S-2), 2^S = 2 * 2^(S-1)
  have h2S_eq_16 : (2 : ℤ) ^ S = 16 * (2 : ℤ) ^ (S - 4) := by
    have hS4 : S - 4 + 4 = S := by omega
    calc (2 : ℤ) ^ S = (2 : ℤ) ^ (S - 4 + 4) := by rw [hS4]
      _ = (2 : ℤ) ^ (S - 4) * 16 := by rw [pow_add]; norm_num
      _ = 16 * (2 : ℤ) ^ (S - 4) := by ring
  have h2S_eq_8 : (2 : ℤ) ^ S = 8 * (2 : ℤ) ^ (S - 3) := by
    have hS3 : S - 3 + 3 = S := by omega
    calc (2 : ℤ) ^ S = (2 : ℤ) ^ (S - 3 + 3) := by rw [hS3]
      _ = (2 : ℤ) ^ (S - 3) * 8 := by rw [pow_add]; norm_num
      _ = 8 * (2 : ℤ) ^ (S - 3) := by ring
  have h2S_eq_4 : (2 : ℤ) ^ S = 4 * (2 : ℤ) ^ (S - 2) := by
    have hS2 : S - 2 + 2 = S := by omega
    calc (2 : ℤ) ^ S = (2 : ℤ) ^ (S - 2 + 2) := by rw [hS2]
      _ = (2 : ℤ) ^ (S - 2) * 4 := by rw [pow_add]; norm_num
      _ = 4 * (2 : ℤ) ^ (S - 2) := by ring
  have h2S_eq_2 : (2 : ℤ) ^ S = 2 * (2 : ℤ) ^ (S - 1) := by
    have hS1 : S - 1 + 1 = S := by omega
    calc (2 : ℤ) ^ S = (2 : ℤ) ^ (S - 1 + 1) := by rw [hS1]
      _ = (2 : ℤ) ^ (S - 1) * 2 := by rw [pow_add]; norm_num
      _ = 2 * (2 : ℤ) ^ (S - 1) := by ring
  -- Split on n_0 ∈ {2, 3, 4} vs n_0 ≥ 5.
  by_cases hn0_5 : n_0 ≥ 5
  · -- Archimedean: 5 D > C_max
    have hn0_ge5 : (n_0 : ℤ) ≥ 5 := by exact_mod_cast hn0_5
    have hC_bound : (81 : ℤ) + 27 * 2 ^ s_1 + 9 * 2 ^ (s_1 + s_2) +
                    3 * 2 ^ (s_1 + s_2 + s_3) + 2 ^ (s_1 + s_2 + s_3 + s_4) ≤
                    81 + 27 * (2 : ℤ) ^ (S - 4) + 9 * (2 : ℤ) ^ (S - 3) +
                    3 * (2 : ℤ) ^ (S - 2) + (2 : ℤ) ^ (S - 1) := by linarith
    have h5D_gt_C : 5 * ((2 : ℤ) ^ S - 243) >
                    81 + 27 * (2 : ℤ) ^ (S - 4) + 9 * (2 : ℤ) ^ (S - 3) +
                    3 * (2 : ℤ) ^ (S - 2) + (2 : ℤ) ^ (S - 1) := by
      nlinarith [h2pow_S, h2S_eq_16, h2S_eq_8, h2S_eq_4, h2S_eq_2]
    nlinarith [heq, hn0_ge5, hD_pos, hC_bound, h5D_gt_C]
  · -- n_0 ∈ {2, 3, 4}
    push_neg at hn0_5
    -- Factor 2 from each power (for parity arg)
    have h_s1 : ∃ a : ℤ, (2 : ℤ) ^ s_1 = 2 * a := by
      refine ⟨(2 : ℤ) ^ (s_1 - 1), ?_⟩
      conv_lhs => rw [show s_1 = (s_1 - 1) + 1 from by omega]
      rw [pow_succ]; ring
    have h_s12 : ∃ b : ℤ, (2 : ℤ) ^ (s_1 + s_2) = 2 * b := by
      refine ⟨(2 : ℤ) ^ (s_1 + s_2 - 1), ?_⟩
      conv_lhs => rw [show s_1 + s_2 = (s_1 + s_2 - 1) + 1 from by omega]
      rw [pow_succ]; ring
    have h_s123 : ∃ c : ℤ, (2 : ℤ) ^ (s_1 + s_2 + s_3) = 2 * c := by
      refine ⟨(2 : ℤ) ^ (s_1 + s_2 + s_3 - 1), ?_⟩
      conv_lhs => rw [show s_1 + s_2 + s_3 = (s_1 + s_2 + s_3 - 1) + 1 from by omega]
      rw [pow_succ]; ring
    have h_s1234 : ∃ d : ℤ, (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) = 2 * d := by
      refine ⟨(2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 - 1), ?_⟩
      conv_lhs => rw [show s_1 + s_2 + s_3 + s_4 = (s_1 + s_2 + s_3 + s_4 - 1) + 1 from by omega]
      rw [pow_succ]; ring
    obtain ⟨a, ha⟩ := h_s1
    obtain ⟨b, hb⟩ := h_s12
    obtain ⟨c, hc⟩ := h_s123
    obtain ⟨d, hd⟩ := h_s1234
    rw [ha, hb, hc, hd] at heq
    -- heq : n_0 * (2^S - 243) = 81 + 27*(2a) + 9*(2b) + 3*(2c) + (2d)
    --      = 81 + 2*(27a + 9b + 3c + d)
    -- For n_0 ∈ {2, 3, 4} : determined by omega.
    -- n_0 = 2: 2 * (2^S - 243) = 2*(2^(S-1) - 243/... no, just 2*(2^S - 243))
    --         Wait, 2*(2^S - 243) is even. RHS = 81 + 2*(...) is odd. Contradiction.
    -- n_0 = 3: 3 * (2^S - 243). RHS = 81 + 2*(...). 81 mod 3 = 0, 2*(...) mod 3 varies.
    --         3*(2^S - 243) mod 3 = 0. RHS mod 3 = 0 + 2*(27a+9b+3c+d) mod 3
    --                              = 2 * d mod 3 (since 27a, 9b, 3c are divisible by 3).
    --         So d mod 3 = 0 needed. But d = 2^(s_1+s_2+s_3+s_4-1), and 2^x mod 3 ∈ {1, 2}.
    --         Contradiction.
    -- n_0 = 4: same as n_0 = 2 (parity).
    interval_cases n_0
    · -- n_0 = 2: parity
      omega
    · -- n_0 = 3: mod 3 argument.
      -- 3D = 81 + 27a' + 9b' + 3c' + 2^{s_1+s_2+s_3+s_4} where a',b',c' ≥ 0.
      -- All terms except last are divisible by 3.
      -- So 3 | 2^{s_1+s_2+s_3+s_4}. But 2^x is never divisible by 3.
      -- We use the key lemma three_not_dvd_two_pow proven below.
      have h_dvd_3 : (3 : ℤ) ∣ (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) := by
        -- heq (after push_cast) : 3 * (2^S - 243) = 81 + 27*(2a) + 9*(2b) + 3*(2c) + 2*d
        -- 81 + 54a + 18b + 6c is divisible by 3 (each term).
        -- So 2d = 3*(2^S - 243) - 3*(27 + 18a + 6b + 2c) = 3 * something.
        push_cast at heq
        have heq3 : 2 * d = 3 * (((2 : ℤ) ^ S - 243) - (27 + 18 * a + 6 * b + 2 * c)) := by
          linarith
        rw [hd]
        exact ⟨_, heq3⟩
      -- But 2^(s_1+s_2+s_3+s_4) is never divisible by 3. Use auxiliary lemma.
      exact three_not_dvd_two_pow (s_1 + s_2 + s_3 + s_4) h_dvd_3
    · -- n_0 = 4: parity
      omega

/-! ## Round 45: cycle_k5_S_eq_8_impossible (35 cases enumeration) -/

set_option maxHeartbeats 800000 in
theorem cycle_k5_S_eq_8_impossible
    (s_1 s_2 s_3 s_4 s_5 n_0 : ℕ)
    (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1) (h5 : s_5 ≥ 1)
    (hsum_eq : s_1 + s_2 + s_3 + s_4 + s_5 = 8) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5) - 243) =
           81 + 27 * 2 ^ s_1 + 9 * 2 ^ (s_1 + s_2) + 3 * 2 ^ (s_1 + s_2 + s_3) +
           2 ^ (s_1 + s_2 + s_3 + s_4)) :
    False := by
  rw [hsum_eq] at heq
  norm_num at heq
  -- heq : n_0 * 13 = 81 + 27 * 2^s_1 + 9 * 2^(s_1+s_2) + 3 * 2^(s_1+s_2+s_3) + 2^(s_1+s_2+s_3+s_4)
  have hs_1_le : s_1 ≤ 4 := by omega
  interval_cases s_1 <;>
    (have hs_2_le : s_2 ≤ 6 := by omega
     interval_cases s_2 <;>
       (have hs_3_le : s_3 ≤ 6 := by omega
        interval_cases s_3 <;>
          (have hs_4_le : s_4 ≤ 6 := by omega
           interval_cases s_4 <;> (norm_num at heq; omega))))

/-! ## Round 46: cycle_k5_S_eq_9_impossible (70 cases enumeration) -/

set_option maxHeartbeats 1600000 in
theorem cycle_k5_S_eq_9_impossible
    (s_1 s_2 s_3 s_4 s_5 n_0 : ℕ)
    (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1) (h5 : s_5 ≥ 1)
    (hsum_eq : s_1 + s_2 + s_3 + s_4 + s_5 = 9) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5) - 243) =
           81 + 27 * 2 ^ s_1 + 9 * 2 ^ (s_1 + s_2) + 3 * 2 ^ (s_1 + s_2 + s_3) +
           2 ^ (s_1 + s_2 + s_3 + s_4)) :
    False := by
  rw [hsum_eq] at heq
  norm_num at heq
  -- heq : n_0 * 269 = ...
  have hs_1_le : s_1 ≤ 5 := by omega
  interval_cases s_1 <;>
    (have hs_2_le : s_2 ≤ 7 := by omega
     interval_cases s_2 <;>
       (have hs_3_le : s_3 ≤ 7 := by omega
        interval_cases s_3 <;>
          (have hs_4_le : s_4 ≤ 7 := by omega
           interval_cases s_4 <;> (norm_num at heq; omega))))

/-! ## Round 47: cycle_k5_S_eq_10_impossible (126 cases enumeration) -/

set_option maxHeartbeats 3200000 in
theorem cycle_k5_S_eq_10_impossible
    (s_1 s_2 s_3 s_4 s_5 n_0 : ℕ)
    (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1) (h5 : s_5 ≥ 1)
    (hsum_eq : s_1 + s_2 + s_3 + s_4 + s_5 = 10) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5) - 243) =
           81 + 27 * 2 ^ s_1 + 9 * 2 ^ (s_1 + s_2) + 3 * 2 ^ (s_1 + s_2 + s_3) +
           2 ^ (s_1 + s_2 + s_3 + s_4)) :
    False := by
  rw [hsum_eq] at heq
  norm_num at heq
  -- heq : n_0 * 781 = ...
  have hs_1_le : s_1 ≤ 6 := by omega
  interval_cases s_1 <;>
    (have hs_2_le : s_2 ≤ 8 := by omega
     interval_cases s_2 <;>
       (have hs_3_le : s_3 ≤ 8 := by omega
        interval_cases s_3 <;>
          (have hs_4_le : s_4 ≤ 8 := by omega
           interval_cases s_4 <;> (norm_num at heq; omega))))

/-! ## Round 48: cycle_eliminated_k5 + no_collatz_cycle_k5 -/

/-- **Round 48 main theorem**: k=5 elimination by combining 5 sub-cases. -/
theorem cycle_eliminated_k5
    (s_1 s_2 s_3 s_4 s_5 n_0 : ℕ)
    (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1) (h5 : s_5 ≥ 1)
    (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5) - 243) =
           81 + 27 * 2 ^ s_1 + 9 * 2 ^ (s_1 + s_2) + 3 * 2 ^ (s_1 + s_2 + s_3) +
           2 ^ (s_1 + s_2 + s_3 + s_4)) :
    False := by
  rcases lt_or_ge (s_1 + s_2 + s_3 + s_4 + s_5) 8 with hS_lt | hS_ge
  · exact cycle_k5_S_le_7_impossible s_1 s_2 s_3 s_4 s_5 n_0 h1 h2 h3 h4 h5
      (by omega) hpos heq
  · rcases lt_or_ge (s_1 + s_2 + s_3 + s_4 + s_5) 9 with hS_lt9 | hS_ge9
    · have hS_eq : s_1 + s_2 + s_3 + s_4 + s_5 = 8 := by omega
      exact cycle_k5_S_eq_8_impossible s_1 s_2 s_3 s_4 s_5 n_0 h1 h2 h3 h4 h5
        hS_eq hpos heq
    · rcases lt_or_ge (s_1 + s_2 + s_3 + s_4 + s_5) 10 with hS_lt10 | hS_ge10
      · have hS_eq : s_1 + s_2 + s_3 + s_4 + s_5 = 9 := by omega
        exact cycle_k5_S_eq_9_impossible s_1 s_2 s_3 s_4 s_5 n_0 h1 h2 h3 h4 h5
          hS_eq hpos heq
      · rcases lt_or_ge (s_1 + s_2 + s_3 + s_4 + s_5) 11 with hS_lt11 | hS_ge11
        · have hS_eq : s_1 + s_2 + s_3 + s_4 + s_5 = 10 := by omega
          exact cycle_k5_S_eq_10_impossible s_1 s_2 s_3 s_4 s_5 n_0 h1 h2 h3 h4 h5
            hS_eq hpos heq
        · exact cycle_k5_S_ge_11_impossible s_1 s_2 s_3 s_4 s_5 n_0 h1 h2 h3 h4 h5
            hS_ge11 hpos heq

/-! ## Round 48 Steiner bridge for k=5 -/

/-- Unfolding `aSumSeq n 5 = aSeq n 0 + aSeq n 1 + aSeq n 2 + aSeq n 3 + aSeq n 4`. -/
lemma aSumSeq_five_eq (n : ℕ) :
    aSumSeq n 5 = aSeq n 0 + aSeq n 1 + aSeq n 2 + aSeq n 3 + aSeq n 4 := by
  rw [show (5 : ℕ) = 4 + 1 from rfl, aSumSeq_succ' n 4, aSumSeq_four_eq n]

/-- Unfolding `corrSum n 5`. -/
lemma corrSum_five_eq (n : ℕ) :
    corrSum n 5 = 81 + 27 * 2 ^ (aSeq n 0) + 9 * 2 ^ (aSeq n 0 + aSeq n 1) +
                  3 * 2 ^ (aSeq n 0 + aSeq n 1 + aSeq n 2) +
                  2 ^ (aSeq n 0 + aSeq n 1 + aSeq n 2 + aSeq n 3) := by
  show corrSum n (4 + 1) = _
  rw [corrSum_succ, corrSum_four_eq]
  -- aSumSeq n 4 = aSeq n 0 + aSeq n 1 + aSeq n 2 + aSeq n 3
  rw [aSumSeq_four_eq]
  ring

/-- **No Collatz cycle of length 5** (END-TO-END, unconditional). -/
theorem no_collatz_cycle_k5 (n : ℕ) (hcyc : IsOddCycle n 5) : False := by
  have hsteiner := steiner_cycle_eq n 5 hcyc
  obtain ⟨hn_gt1, hodd, _, _⟩ := hcyc
  rw [aSumSeq_five_eq n, corrSum_five_eq n] at hsteiner
  have ha0 : aSeq n 0 ≥ 1 := aSeq_ge_one_of_odd n 0 hodd
  have ha1 : aSeq n 1 ≥ 1 := aSeq_ge_one_of_odd n 1 hodd
  have ha2 : aSeq n 2 ≥ 1 := aSeq_ge_one_of_odd n 2 hodd
  have ha3 : aSeq n 3 ≥ 1 := aSeq_ge_one_of_odd n 3 hodd
  have ha4 : aSeq n 4 ≥ 1 := aSeq_ge_one_of_odd n 4 hodd
  have heq_int : (n : ℤ) *
      ((2 : ℤ) ^ (aSeq n 0 + aSeq n 1 + aSeq n 2 + aSeq n 3 + aSeq n 4) - 243) =
      81 + 27 * 2 ^ (aSeq n 0) + 9 * 2 ^ (aSeq n 0 + aSeq n 1) +
      3 * 2 ^ (aSeq n 0 + aSeq n 1 + aSeq n 2) +
      2 ^ (aSeq n 0 + aSeq n 1 + aSeq n 2 + aSeq n 3) := by
    have h_int : (n : ℤ) * (2 : ℤ) ^ (aSeq n 0 + aSeq n 1 + aSeq n 2 + aSeq n 3 + aSeq n 4) =
                 3 ^ 5 * n + (81 + 27 * (2 : ℤ) ^ (aSeq n 0) +
                              9 * (2 : ℤ) ^ (aSeq n 0 + aSeq n 1) +
                              3 * (2 : ℤ) ^ (aSeq n 0 + aSeq n 1 + aSeq n 2) +
                              (2 : ℤ) ^ (aSeq n 0 + aSeq n 1 + aSeq n 2 + aSeq n 3)) := by
      exact_mod_cast hsteiner
    have h243 : (3 : ℤ) ^ 5 = 243 := by norm_num
    linarith [h_int, h243]
  exact cycle_eliminated_k5 (aSeq n 0) (aSeq n 1) (aSeq n 2) (aSeq n 3) (aSeq n 4) n
    ha0 ha1 ha2 ha3 ha4 hn_gt1 heq_int

/-! ## Round 50: cyclicSum recurrence (helper for universal properties) -/

/-- **R50 helper**: appending a drop height to s gives a recursive formula for cyclicSum.
This is the analog of cyclicDenom_append, dual key for proving parity properties. -/
lemma cyclicSum_append_recurrence (s : List ℕ) (a : ℕ) :
    cyclicSum (s ++ [a]) = 3 * cyclicSum s + 2 ^ s.sum := by
  unfold cyclicSum
  rw [List.length_append, List.length_singleton]
  rw [Finset.sum_range_succ]
  have h_last : 3 ^ (s.length + 1 - 1 - s.length) *
                2 ^ parity_partial_sum (s ++ [a]) s.length = 2 ^ s.sum := by
    rw [show s.length + 1 - 1 - s.length = 0 by omega, pow_zero, one_mul]
    congr 1
    show ((s ++ [a]).take s.length).sum = s.sum
    rw [List.take_left]
  have h_inner : ∀ i ∈ Finset.range s.length,
      3 ^ (s.length + 1 - 1 - i) * 2 ^ parity_partial_sum (s ++ [a]) i =
      3 * (3 ^ (s.length - 1 - i) * 2 ^ parity_partial_sum s i) := by
    intro i hi
    rw [Finset.mem_range] at hi
    have h_pow : s.length + 1 - 1 - i = (s.length - 1 - i) + 1 := by omega
    have h_take : ((s ++ [a]).take i).sum = (s.take i).sum := by
      rw [List.take_append_of_le_length (by omega : i ≤ s.length)]
    rw [h_pow, pow_succ]
    have : parity_partial_sum (s ++ [a]) i = parity_partial_sum s i := by
      simp [parity_partial_sum, h_take]
    rw [this]
    ring
  rw [h_last]
  rw [Finset.sum_congr rfl h_inner]
  rw [← Finset.mul_sum]

/-! ## Round 49 + R50: Universal property — n_0 must be coprime to 6 (∀ k)

🎯 **Strategic insight (Eric R44 directive)**: looking for the dynamic
behind k arbitrary, we observe two universal properties:

**Property 1 (parity)**: For any k and any cycle, n_0 cannot be even.
  Proof: LHS = n_0·D, with n_0 even gives LHS even. But C = 3^{k-1} + ...
  where 3^{k-1} is odd and other terms are 3^j · 2^{positive} hence even.
  So C is odd (= odd + even + ... + even). EVEN ≠ ODD.

**Property 2 (mod 3)**: For any k and any cycle, 3 cannot divide n_0.
  Proof: LHS mod 3 = 0 (3 | n_0). RHS mod 3 = the only non-divisible-by-3
  term is 2^{S-s_k}. And 2^x mod 3 ∈ {1, 2}, never 0. Contradiction.

Combined: **n_0 must be coprime to 6** (impair non-divisible-by-3).

This dramatically reduces the candidate space. Combined with archimedean
n_0 < N(k), it leaves few values to check per k. This is the foundation
for the dynamic toward "all k".
-/

/-- **Universal property 1** (R49 scaffolding): in any Collatz cycle equation,
n_0 cannot be even. Proven for any k and any parity-vector s.

**Proof sketch** (deferred to R50):
- `cyclicSum s` is always ODD for `s.length ≥ 1`, by induction:
  - Base: `cyclicSum [s_1] = 1` (odd).
  - Step: `cyclicSum (t ++ [a]) = 3 * cyclicSum t + 2^t.sum`. By IH cyclicSum t
    is odd, so 3·odd = odd, and 2^t.sum is even (t.sum ≥ 1), so sum is odd.
- LHS = n_0·D is even when n_0 even.
- LHS = cyclicSum (odd) by heq. Contradiction.

Status: stated, proof deferred.
-/
theorem cycle_n_0_not_even
    (k : ℕ) (hk : 1 ≤ k)
    (s : List ℕ) (hlen : s.length = k) (hpos : ∀ x ∈ s, 1 ≤ x)
    (n_0 : ℕ) (hn_0 : 0 < n_0)
    (heq : (n_0 : ℤ) * cyclicDenom s = cyclicSum s)
    (h_even : 2 ∣ n_0) : False := by
  -- Step 1: prove cyclicSum s is odd (induction on s, length ≥ 1).
  have h_odd : ¬ 2 ∣ cyclicSum s := by
    have hslen : 1 ≤ s.length := by omega
    clear heq hk hlen
    induction s using List.reverseRecOn with
    | nil => simp at hslen
    | append_singleton t a ih =>
      by_cases ht : t = []
      · subst ht
        intro h
        simp [cyclicSum, parity_partial_sum] at h
      · have htlen : 1 ≤ t.length := by
          cases t
          · simp at ht
          · simp
        have ht_pos : ∀ x ∈ t, 1 ≤ x := fun x hx =>
          hpos x (by simp [hx])
        have hih := ih ht_pos htlen
        rw [cyclicSum_append_recurrence]
        intro h
        have ht_sum_pos : 1 ≤ t.sum := by
          cases t with
          | nil => simp at htlen
          | cons x xs =>
            simp [List.sum_cons]
            have hx : 1 ≤ x := hpos x (by simp)
            omega
        have h_2pow_even : 2 ∣ (2 : ℕ) ^ t.sum := by
          refine ⟨2 ^ (t.sum - 1), ?_⟩
          conv_lhs => rw [show t.sum = (t.sum - 1) + 1 from by omega]
          rw [pow_succ]; ring
        have h1 : 2 ∣ 3 * cyclicSum t := by
          have : 2 ∣ (3 * cyclicSum t + 2 ^ t.sum) - 2 ^ t.sum := Nat.dvd_sub h h_2pow_even
          simpa using this
        have h_co : Nat.Coprime 2 3 := by decide
        exact hih (h_co.dvd_of_dvd_mul_left h1)
  -- Step 2: derive contradiction.
  have h_LHS_2 : (2 : ℤ) ∣ (n_0 : ℤ) * cyclicDenom s := by
    obtain ⟨m, hm⟩ := h_even
    exact ⟨m * cyclicDenom s, by rw [hm]; push_cast; ring⟩
  rw [heq] at h_LHS_2
  have hC_2 : (2 : ℕ) ∣ cyclicSum s := by exact_mod_cast h_LHS_2
  exact h_odd hC_2

/-- **Universal property 2** (R49 scaffolding): in any Collatz cycle equation,
3 cannot divide n_0.

**Proof sketch** (deferred to R50):
- `cyclicSum s` is never divisible by 3 (similar induction):
  - Base: `cyclicSum [s_1] = 1` (1 mod 3 = 1).
  - Step: 3 * cyclicSum t mod 3 = 0, plus 2^t.sum mod 3 ∈ {1, 2}.
- LHS = n_0·D is div by 3 when 3 | n_0.
- Contradiction with cyclicSum mod 3 ≠ 0.
-/
theorem cycle_n_0_not_dvd_three
    (k : ℕ) (hk : 1 ≤ k)
    (s : List ℕ) (hlen : s.length = k) (hpos : ∀ x ∈ s, 1 ≤ x)
    (n_0 : ℕ) (hn_0 : 0 < n_0)
    (heq : (n_0 : ℤ) * cyclicDenom s = cyclicSum s)
    (h_3 : 3 ∣ n_0) : False := by
  -- Step 1: prove cyclicSum s is not divisible by 3.
  have h_not3 : ¬ 3 ∣ cyclicSum s := by
    have hslen : 1 ≤ s.length := by omega
    clear heq hk hlen
    induction s using List.reverseRecOn with
    | nil => simp at hslen
    | append_singleton t a ih =>
      by_cases ht : t = []
      · subst ht
        intro h
        simp [cyclicSum, parity_partial_sum] at h
      · have htlen : 1 ≤ t.length := by
          cases t
          · simp at ht
          · simp
        have ht_pos : ∀ x ∈ t, 1 ≤ x := fun x hx =>
          hpos x (by simp [hx])
        have hih := ih ht_pos htlen
        rw [cyclicSum_append_recurrence]
        intro h
        have h3_first : (3 : ℕ) ∣ 3 * cyclicSum t := ⟨_, rfl⟩
        have h3_2pow : (3 : ℕ) ∣ 2 ^ t.sum := by
          have : 3 ∣ (3 * cyclicSum t + 2 ^ t.sum) - 3 * cyclicSum t := Nat.dvd_sub h h3_first
          simpa using this
        -- 3 ∤ 2^x (gcd(3, 2) = 1)
        have h_co : Nat.Coprime 3 2 := by decide
        have h_co_pow : Nat.Coprime 3 (2 ^ t.sum) := h_co.pow_right t.sum
        have h_gcd : Nat.gcd 3 (2 ^ t.sum) = 1 := h_co_pow
        have h_dvd_gcd : 3 ∣ Nat.gcd 3 (2 ^ t.sum) := Nat.dvd_gcd (dvd_refl 3) h3_2pow
        rw [h_gcd] at h_dvd_gcd
        omega
  -- Step 2: derive contradiction.
  have h_LHS_3 : (3 : ℤ) ∣ (n_0 : ℤ) * cyclicDenom s := by
    obtain ⟨m, hm⟩ := h_3
    exact ⟨m * cyclicDenom s, by rw [hm]; push_cast; ring⟩
  rw [heq] at h_LHS_3
  have hC_3 : (3 : ℕ) ∣ cyclicSum s := by exact_mod_cast h_LHS_3
  exact h_not3 hC_3

/-- **Universal corollary**: n_0 must be coprime to 6 in any cycle. -/
theorem cycle_n_0_coprime_six
    (k : ℕ) (hk : 1 ≤ k)
    (s : List ℕ) (hlen : s.length = k) (hpos : ∀ x ∈ s, 1 ≤ x)
    (n_0 : ℕ) (hn_0 : 0 < n_0)
    (heq : (n_0 : ℤ) * cyclicDenom s = cyclicSum s) :
    ¬ (2 ∣ n_0) ∧ ¬ (3 ∣ n_0) := by
  refine ⟨?_, ?_⟩
  · intro h2; exact cycle_n_0_not_even k hk s hlen hpos n_0 hn_0 heq h2
  · intro h3; exact cycle_n_0_not_dvd_three k hk s hlen hpos n_0 hn_0 heq h3

/-! ## Round 51: cycle_k6_S_le_9_impossible (k=6 sign sub-case)

For k=6: D = 2^S - 729. S ≤ 9 → D ≤ 2^9 - 729 = 512 - 729 = -217 < 0. -/

theorem cycle_k6_S_le_9_impossible
    (s_1 s_2 s_3 s_4 s_5 s_6 n_0 : ℕ)
    (h1 : s_1 ≥ 1) (h2 : s_2 ≥ 1) (h3 : s_3 ≥ 1) (h4 : s_4 ≥ 1)
    (h5 : s_5 ≥ 1) (h6 : s_6 ≥ 1)
    (hsum_le : s_1 + s_2 + s_3 + s_4 + s_5 + s_6 ≤ 9) (hpos : n_0 > 1)
    (heq : (n_0 : ℤ) * ((2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5 + s_6) - 729) =
           243 + 81 * 2 ^ s_1 + 27 * 2 ^ (s_1 + s_2) + 9 * 2 ^ (s_1 + s_2 + s_3) +
           3 * 2 ^ (s_1 + s_2 + s_3 + s_4) + 2 ^ (s_1 + s_2 + s_3 + s_4 + s_5)) :
    False := by
  have h2S : (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5 + s_6) ≤ 512 := by
    calc (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5 + s_6) ≤ (2 : ℤ) ^ 9 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum_le
      _ = 512 := by norm_num
  have hDneg : (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5 + s_6) - 729 ≤ -217 := by linarith
  have hn0 : (n_0 : ℤ) ≥ 2 := by exact_mod_cast hpos
  -- C_s lower bound for s_i ≥ 1: 243 + 81·2 + 27·4 + 9·8 + 3·16 + 32
  --                            = 243 + 162 + 108 + 72 + 48 + 32 = 665
  have h2pow_s1 : (2 : ℤ) ^ s_1 ≥ 2 := by
    calc (2 : ℤ) ^ s_1 ≥ (2 : ℤ) ^ 1 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) h1
      _ = 2 := by norm_num
  have hsum12 : s_1 + s_2 ≥ 2 := by omega
  have h2pow_s12 : (2 : ℤ) ^ (s_1 + s_2) ≥ 4 := by
    calc (2 : ℤ) ^ (s_1 + s_2) ≥ (2 : ℤ) ^ 2 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum12
      _ = 4 := by norm_num
  have hsum123 : s_1 + s_2 + s_3 ≥ 3 := by omega
  have h2pow_s123 : (2 : ℤ) ^ (s_1 + s_2 + s_3) ≥ 8 := by
    calc (2 : ℤ) ^ (s_1 + s_2 + s_3) ≥ (2 : ℤ) ^ 3 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum123
      _ = 8 := by norm_num
  have hsum1234 : s_1 + s_2 + s_3 + s_4 ≥ 4 := by omega
  have h2pow_s1234 : (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) ≥ 16 := by
    calc (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4) ≥ (2 : ℤ) ^ 4 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum1234
      _ = 16 := by norm_num
  have hsum12345 : s_1 + s_2 + s_3 + s_4 + s_5 ≥ 5 := by omega
  have h2pow_s12345 : (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5) ≥ 32 := by
    calc (2 : ℤ) ^ (s_1 + s_2 + s_3 + s_4 + s_5) ≥ (2 : ℤ) ^ 5 := by
          apply pow_le_pow_right₀ (by norm_num : (1 : ℤ) ≤ 2) hsum12345
      _ = 32 := by norm_num
  have hCpos : (243 : ℤ) + 81 * 2 ^ s_1 + 27 * 2 ^ (s_1 + s_2) +
               9 * 2 ^ (s_1 + s_2 + s_3) + 3 * 2 ^ (s_1 + s_2 + s_3 + s_4) +
               2 ^ (s_1 + s_2 + s_3 + s_4 + s_5) ≥ 665 := by linarith
  -- LHS ≤ 2 * (-217) = -434 < 0, RHS ≥ 665. Contradiction.
  nlinarith [heq, hDneg, hn0, hCpos]

/-! ## Round 52: Eliahou-style forward descent for n_0 = 5 (universal for all k)

🎯 **Strategic insight (Eliahou expert R51)**: For small n_0 coprime to 6,
the **forward Collatz trajectory** descends below n_0 within a few steps.
Combined with the cycle structure (orbit returns to n_0), this gives a
contradiction independent of k.

For n_0 = 5: syracuseNext(5) = (3·5+1)/2^4 = 16/16 = 1.
So nSeq 5 1 = 1. And nSeq 1 j = 1 forever (1 is fixed point).
Therefore nSeq 5 k = 1 for all k ≥ 1.
But IsOddCycle 5 k requires nSeq 5 k = 5.
Contradiction: 1 ≠ 5.

This argument is **universal in k** and **inconditionnel**.
-/

/-- **R52 (Eliahou strategy)**: n_0 = 5 cannot be a Collatz cycle starting
value for any k. Universal in k, no Baker, no Barina. -/
theorem cycle_n_0_eq_5_impossible (k : ℕ) (hcyc : IsOddCycle 5 k) : False := by
  obtain ⟨h_gt1, h_odd, h_k_pos, h_eq⟩ := hcyc
  -- nSeq 5 1 = 1 (by direct computation)
  have h_nseq_5_1 : nSeq 5 1 = 1 := by
    rw [← nSeqC_eq_nSeq]
    native_decide
  -- nSeq 1 j = 1 for all j (1 is fixed point)
  have h_nseq_1 : ∀ j, nSeq 1 j = 1 := nSeq_stays_at_one
  -- Decompose k = 1 + (k - 1) and use nSeq_add
  have hk_decomp : k = 1 + (k - 1) := by omega
  have h_chain : nSeq 5 k = 1 := by
    calc nSeq 5 k = nSeq 5 (1 + (k - 1)) := by rw [← hk_decomp]
      _ = nSeq (nSeq 5 1) (k - 1) := nSeq_add 5 1 (k - 1)
      _ = nSeq 1 (k - 1) := by rw [h_nseq_5_1]
      _ = 1 := h_nseq_1 (k - 1)
  rw [h_chain] at h_eq
  omega

/-! ## Round 53: Generic Eliahou descent — eliminate n_0 if it reaches 1

🎯 **Generic theorem**: if `nSeq n_0 J = 1` for some J ≥ 1, then n_0 cannot
be the starting value of any Collatz cycle (k arbitrary).

Sub-cases:
- k ≤ J - 1 : verify nSeq n_0 k ≠ n_0 by native_decide.
- k ≥ J : nSeq n_0 k = nSeq (nSeq n_0 J) (k - J) = nSeq 1 (k - J) = 1 ≠ n_0
  (since n_0 > 1).

This unified theorem allows extending to many n_0 with finite stopping time.
-/

/-- **Helper R53**: if nSeq n_0 J = 1 for J ≥ 1 and n_0 > 1, then for k ≥ J,
nSeq n_0 k = 1. -/
lemma nSeq_eq_one_after_descent (n_0 J k : ℕ) (hJ : J ≥ 1)
    (h_descent : nSeq n_0 J = 1) (hk_ge : k ≥ J) :
    nSeq n_0 k = 1 := by
  have hk_decomp : k = J + (k - J) := by omega
  calc nSeq n_0 k = nSeq n_0 (J + (k - J)) := by rw [← hk_decomp]
    _ = nSeq (nSeq n_0 J) (k - J) := nSeq_add n_0 J (k - J)
    _ = nSeq 1 (k - J) := by rw [h_descent]
    _ = 1 := nSeq_stays_at_one (k - J)

/-- **R53 n_0 = 7**: trajectoire 7 → 11 → 17 → 13 → 5 → 1 (J=5). -/
theorem cycle_n_0_eq_7_impossible (k : ℕ) (hcyc : IsOddCycle 7 k) : False := by
  obtain ⟨h_gt1, h_odd, h_k_pos, h_eq⟩ := hcyc
  have h_nseq_7_5 : nSeq 7 5 = 1 := by
    rw [← nSeqC_eq_nSeq]; native_decide
  by_cases hk : k ≤ 4
  · interval_cases k <;>
      (rw [← nSeqC_eq_nSeq] at h_eq; revert h_eq; native_decide)
  · push_neg at hk
    have h_chain : nSeq 7 k = 1 :=
      nSeq_eq_one_after_descent 7 5 k (by omega) h_nseq_7_5 (by omega)
    rw [h_chain] at h_eq
    omega

/-- **R53 n_0 = 11**: trajectoire 11 → 17 → 13 → 5 → 1 (J=4). -/
theorem cycle_n_0_eq_11_impossible (k : ℕ) (hcyc : IsOddCycle 11 k) : False := by
  obtain ⟨h_gt1, h_odd, h_k_pos, h_eq⟩ := hcyc
  have h_nseq_11_4 : nSeq 11 4 = 1 := by
    rw [← nSeqC_eq_nSeq]; native_decide
  by_cases hk : k ≤ 3
  · interval_cases k <;>
      (rw [← nSeqC_eq_nSeq] at h_eq; revert h_eq; native_decide)
  · push_neg at hk
    have h_chain : nSeq 11 k = 1 :=
      nSeq_eq_one_after_descent 11 4 k (by omega) h_nseq_11_4 (by omega)
    rw [h_chain] at h_eq
    omega

/-- **R53 n_0 = 13**: trajectoire 13 → 5 → 1 (J=2). -/
theorem cycle_n_0_eq_13_impossible (k : ℕ) (hcyc : IsOddCycle 13 k) : False := by
  obtain ⟨h_gt1, h_odd, h_k_pos, h_eq⟩ := hcyc
  have h_nseq_13_2 : nSeq 13 2 = 1 := by
    rw [← nSeqC_eq_nSeq]; native_decide
  by_cases hk : k ≤ 1
  · interval_cases k <;>
      (rw [← nSeqC_eq_nSeq] at h_eq; revert h_eq; native_decide)
  · push_neg at hk
    have h_chain : nSeq 13 k = 1 :=
      nSeq_eq_one_after_descent 13 2 k (by omega) h_nseq_13_2 (by omega)
    rw [h_chain] at h_eq
    omega

/-- **R53 n_0 = 17**: trajectoire 17 → 13 → 5 → 1 (J=3). -/
theorem cycle_n_0_eq_17_impossible (k : ℕ) (hcyc : IsOddCycle 17 k) : False := by
  obtain ⟨h_gt1, h_odd, h_k_pos, h_eq⟩ := hcyc
  have h_nseq_17_3 : nSeq 17 3 = 1 := by
    rw [← nSeqC_eq_nSeq]; native_decide
  by_cases hk : k ≤ 2
  · interval_cases k <;>
      (rw [← nSeqC_eq_nSeq] at h_eq; revert h_eq; native_decide)
  · push_neg at hk
    have h_chain : nSeq 17 k = 1 :=
      nSeq_eq_one_after_descent 17 3 k (by omega) h_nseq_17_3 (by omega)
    rw [h_chain] at h_eq
    omega

/-! ## Round 54: More n_0 eliminated (19, 23, 25, 29) -/

/-- **R54 n_0 = 19**: 19 → 29 → 11 → 17 → 13 → 5 → 1 (J=6). -/
theorem cycle_n_0_eq_19_impossible (k : ℕ) (hcyc : IsOddCycle 19 k) : False := by
  obtain ⟨h_gt1, h_odd, h_k_pos, h_eq⟩ := hcyc
  have h_descent : nSeq 19 6 = 1 := by rw [← nSeqC_eq_nSeq]; native_decide
  by_cases hk : k ≤ 5
  · interval_cases k <;>
      (rw [← nSeqC_eq_nSeq] at h_eq; revert h_eq; native_decide)
  · push_neg at hk
    have h_chain : nSeq 19 k = 1 :=
      nSeq_eq_one_after_descent 19 6 k (by omega) h_descent (by omega)
    rw [h_chain] at h_eq
    omega

/-- **R54 n_0 = 23**: 23 → 35 → 53 → 5 → 1 (J=4). -/
theorem cycle_n_0_eq_23_impossible (k : ℕ) (hcyc : IsOddCycle 23 k) : False := by
  obtain ⟨h_gt1, h_odd, h_k_pos, h_eq⟩ := hcyc
  have h_descent : nSeq 23 4 = 1 := by rw [← nSeqC_eq_nSeq]; native_decide
  by_cases hk : k ≤ 3
  · interval_cases k <;>
      (rw [← nSeqC_eq_nSeq] at h_eq; revert h_eq; native_decide)
  · push_neg at hk
    have h_chain : nSeq 23 k = 1 :=
      nSeq_eq_one_after_descent 23 4 k (by omega) h_descent (by omega)
    rw [h_chain] at h_eq
    omega

/-- **R54 n_0 = 25**: 25 → 19 → 29 → 11 → 17 → 13 → 5 → 1 (J=7). -/
theorem cycle_n_0_eq_25_impossible (k : ℕ) (hcyc : IsOddCycle 25 k) : False := by
  obtain ⟨h_gt1, h_odd, h_k_pos, h_eq⟩ := hcyc
  have h_descent : nSeq 25 7 = 1 := by rw [← nSeqC_eq_nSeq]; native_decide
  by_cases hk : k ≤ 6
  · interval_cases k <;>
      (rw [← nSeqC_eq_nSeq] at h_eq; revert h_eq; native_decide)
  · push_neg at hk
    have h_chain : nSeq 25 k = 1 :=
      nSeq_eq_one_after_descent 25 7 k (by omega) h_descent (by omega)
    rw [h_chain] at h_eq
    omega

/-- **R54 n_0 = 29**: 29 → 11 → 17 → 13 → 5 → 1 (J=5). -/
theorem cycle_n_0_eq_29_impossible (k : ℕ) (hcyc : IsOddCycle 29 k) : False := by
  obtain ⟨h_gt1, h_odd, h_k_pos, h_eq⟩ := hcyc
  have h_descent : nSeq 29 5 = 1 := by rw [← nSeqC_eq_nSeq]; native_decide
  by_cases hk : k ≤ 4
  · interval_cases k <;>
      (rw [← nSeqC_eq_nSeq] at h_eq; revert h_eq; native_decide)
  · push_neg at hk
    have h_chain : nSeq 29 k = 1 :=
      nSeq_eq_one_after_descent 29 5 k (by omega) h_descent (by omega)
    rw [h_chain] at h_eq
    omega

/-! ## Round 55: More n_0 eliminated (35, 37) -/

/-- **R55 n_0 = 35**: 35 → 53 → 5 → 1 (J=3). -/
theorem cycle_n_0_eq_35_impossible (k : ℕ) (hcyc : IsOddCycle 35 k) : False := by
  obtain ⟨h_gt1, h_odd, h_k_pos, h_eq⟩ := hcyc
  have h_descent : nSeq 35 3 = 1 := by rw [← nSeqC_eq_nSeq]; native_decide
  by_cases hk : k ≤ 2
  · interval_cases k <;>
      (rw [← nSeqC_eq_nSeq] at h_eq; revert h_eq; native_decide)
  · push_neg at hk
    have h_chain : nSeq 35 k = 1 :=
      nSeq_eq_one_after_descent 35 3 k (by omega) h_descent (by omega)
    rw [h_chain] at h_eq
    omega

/-- **R55 n_0 = 37**: 37 → 7 → 11 → 17 → 13 → 5 → 1 (J=6). -/
theorem cycle_n_0_eq_37_impossible (k : ℕ) (hcyc : IsOddCycle 37 k) : False := by
  obtain ⟨h_gt1, h_odd, h_k_pos, h_eq⟩ := hcyc
  have h_descent : nSeq 37 6 = 1 := by rw [← nSeqC_eq_nSeq]; native_decide
  by_cases hk : k ≤ 5
  · interval_cases k <;>
      (rw [← nSeqC_eq_nSeq] at h_eq; revert h_eq; native_decide)
  · push_neg at hk
    have h_chain : nSeq 37 k = 1 :=
      nSeq_eq_one_after_descent 37 6 k (by omega) h_descent (by omega)
    rw [h_chain] at h_eq
    omega

/-! ## Round 56: LE GESTE — Eliahou descent universel (extracted from R52-R55)

🎯 **Critique d'Eric (verbatim)**:
> "Vous frappez la pierre 11 fois pour faire 11 feux. Je veux LE GESTE
> qui marche pour tout allumage de feu."

Convergence des 6 sources (Tao, Lagarias, Collatz, allégorique, OLD, ChatGPT) :
**Extraire le théorème universel** dont R52-R55 (n_0 = 5, 7, 11, ..., 37) ne
sont que des applications.

LE GESTE: si la trajectoire forward de n_0 atteint 1 en J étapes, alors n_0
ne peut être minimum d'aucun cycle Collatz (pour tout k).

Démonstration: dans un cycle, nSeq n_0 (J*k) = n_0 (par k cycles).
Mais nSeq n_0 J = 1, et 1 est point fixe, donc nSeq n_0 (J + i) = 1 pour
tout i. Particulièrement nSeq n_0 (J*k) = 1. D'où n_0 = 1, contradiction
avec n_0 > 1.
-/

/-- **R56 LE GESTE universel** : descent forward → no cycle.

Application: R52 (n_0=5), R53 (n_0=7,11,13,17), R54 (n_0=19,23,25,29),
R55 (n_0=35,37) deviennent des **corollaires d'une ligne**.

Cet outil élimine n_0 par n_0 (chaque n_0 avec stopping time fini), mais
le théorème lui-même est **universel en k**. -/
theorem cycle_excluded_if_descent_to_one
    (n_0 J k : ℕ) (h_n0 : n_0 > 1) (hJ : J ≥ 1)
    (h_descent : nSeq n_0 J = 1)
    (hcyc : IsOddCycle n_0 k) : False := by
  obtain ⟨_, _, hk_pos, h_cyc_eq⟩ := hcyc
  -- Par cycle, nSeq n_0 (J * k) = n_0.
  have h_cyc_mult : nSeq n_0 (J * k) = n_0 :=
    cycle_nSeq_multiples n_0 k h_cyc_eq J
  -- Par descent + point fixe, nSeq n_0 (J * k) = 1.
  have h_descent_chain : nSeq n_0 (J * k) = 1 := by
    have h_decomp : J * k = J + (J * k - J) := by
      have : J * k ≥ J := by
        nlinarith [hk_pos]
      omega
    calc nSeq n_0 (J * k)
        = nSeq n_0 (J + (J * k - J)) := by rw [← h_decomp]
      _ = nSeq (nSeq n_0 J) (J * k - J) := nSeq_add n_0 J (J * k - J)
      _ = nSeq 1 (J * k - J) := by rw [h_descent]
      _ = 1 := nSeq_stays_at_one (J * k - J)
  -- Combiner: n_0 = 1, contradiction.
  rw [h_descent_chain] at h_cyc_mult
  omega

/-! ### Corollaires d'une ligne (R52-R55 réécrits via OU-A) -/

theorem cycle_n_0_eq_5_via_descent (k : ℕ) (hcyc : IsOddCycle 5 k) : False :=
  cycle_excluded_if_descent_to_one 5 1 k (by omega) (by omega)
    (by rw [← nSeqC_eq_nSeq]; native_decide) hcyc

theorem cycle_n_0_eq_7_via_descent (k : ℕ) (hcyc : IsOddCycle 7 k) : False :=
  cycle_excluded_if_descent_to_one 7 5 k (by omega) (by omega)
    (by rw [← nSeqC_eq_nSeq]; native_decide) hcyc

theorem cycle_n_0_eq_11_via_descent (k : ℕ) (hcyc : IsOddCycle 11 k) : False :=
  cycle_excluded_if_descent_to_one 11 4 k (by omega) (by omega)
    (by rw [← nSeqC_eq_nSeq]; native_decide) hcyc

theorem cycle_n_0_eq_13_via_descent (k : ℕ) (hcyc : IsOddCycle 13 k) : False :=
  cycle_excluded_if_descent_to_one 13 2 k (by omega) (by omega)
    (by rw [← nSeqC_eq_nSeq]; native_decide) hcyc

/-! ## Round 57: La POUTRE — Ratio universel S/k > log_2(3)

🎯 **Convergence Tao + Lagarias + Collatz + ChatGPT**:
> "Le bilan énergie minimal de tout cycle. La poutre sur laquelle tous les
> outils futurs s'accrochent (cocycle, convergents CF, inégalité-poussée)."

Pour tout cycle non-trivial, on a `2^S > 3^k`, équivalent à `S/k > log_2(3)`.

Cette propriété est **déjà acquise** dans `Phase50CycleEquation.cycle_pow2_gt_pow3`.
Nous la **ré-exportons** ici comme outil universel, pour préparer le pont
vers les convergents CF (Lagarias) et le cocycle (Tao).
-/

/-- **R57 La POUTRE** : pour tout cycle Collatz non-trivial, `2^S > 3^k`.

Forme exponentielle du ratio fondamental S/k > log_2(3).

C'est l'outil universel sur lequel tous les autres s'accrochent :
- Cocycle Tao : log Π = 0 ⟺ S/k = log_2(3) (à epsilon près)
- Convergents Lagarias : approximations rationnelles de log_2(3)
- Inégalité-poussée Collatz : S ≥ φ(k) explicite -/
theorem cycle_pow2_gt_pow3_universal (n k : ℕ) (hcyc : IsOddCycle n k) :
    (2 : ℕ) ^ (aSumSeq n k) > (3 : ℕ) ^ k :=
  cycle_pow2_gt_pow3 n k hcyc

/-- **Corollaire R57** : reformulation en termes de l'identité Steiner.

Pour tout cycle, le dénominateur de Steiner `2^S - 3^k` est strictement positif.
C'est l'invariant sur lequel s'appuie tout sous-théorème (cycle_eliminated_kN). -/
theorem steiner_denom_pos_universal (n k : ℕ) (hcyc : IsOddCycle n k) :
    (0 : ℤ) < (2 : ℤ) ^ (aSumSeq n k) - (3 : ℤ) ^ k := by
  have h := cycle_pow2_gt_pow3_universal n k hcyc
  have : (3 : ℤ) ^ k < (2 : ℤ) ^ (aSumSeq n k) := by exact_mod_cast h
  linarith

/-! ## Round 58: OU-D — v_2(D_s) = 0 universel (D_s = 2^S - 3^k always odd)

🎯 **Outil universel**: pour tout cycle Collatz, le dénominateur de Steiner
`D_s = 2^S - 3^k` est **toujours impair** (v_2(D_s) = 0).

Preuve élémentaire: `2^S` pair (S ≥ k ≥ 1), `3^k` impair, donc différence impair.

Utilité: élimine certaines familles de candidats où on aurait besoin que `D_s`
soit divisible par 2 (ne marche jamais). Outil structurel uniformément vrai.
-/

/-- **R58 OU-D**: pour tout cycle, `2^S - 3^k` est ODD (v_2 = 0). -/
theorem steiner_denom_odd_universal (n k : ℕ) (hcyc : IsOddCycle n k) :
    Odd ((2 : ℤ) ^ (aSumSeq n k) - (3 : ℤ) ^ k) := by
  obtain ⟨_, hodd_n, hk_pos, _⟩ := hcyc
  -- Need: aSumSeq n k ≥ 1 to ensure 2^S is even.
  -- aSumSeq n k = sum of aSeq n i for i < k, each aSeq n i ≥ 1 (when n is odd).
  -- For odd cycle (n_0 odd), all aSeq n i ≥ 1, so aSumSeq n k ≥ k ≥ 1.
  have h_aSumSeq_pos : aSumSeq n k ≥ 1 := by
    have h_a0 : aSeq n 0 ≥ 1 := aSeq_ge_one_of_odd n 0 hodd_n
    -- aSumSeq n k = ∑ i ∈ range k, aSeq n i ≥ aSeq n 0 ≥ 1 (k ≥ 1)
    have : aSumSeq n k = ∑ i ∈ Finset.range k, aSeq n i := by
      unfold aSumSeq aSum
      rfl
    rw [this]
    have hk : k ≥ 1 := hk_pos
    cases k with
    | zero => omega
    | succ kk =>
      rw [Finset.sum_range_succ']
      simp
      have : aSeq n 0 ≥ 1 := h_a0
      omega
  -- 2^S is even, 3^k is odd, so 2^S - 3^k is odd.
  have h_2_even : Even ((2 : ℤ) ^ aSumSeq n k) := by
    refine ⟨2 ^ (aSumSeq n k - 1), ?_⟩
    conv_lhs => rw [show aSumSeq n k = (aSumSeq n k - 1) + 1 from by omega]
    rw [pow_succ]
    ring
  have h_3_odd : Odd ((3 : ℤ) ^ k) := Odd.pow ⟨1, by norm_num⟩
  exact Even.sub_odd h_2_even h_3_odd

/-! ## Round 59: OU-B — Borne multiplicative max/min dans cycle

🎯 **Outil universel** (OLD R56 OU-B): à chaque step Syracuse,
`2 · n_{i+1} ≤ 3 · n_i + 1`. Donc max(n_i) ≤ min(n_i) · (3/2)^k.

Utilité: borne le ratio max/min dans tout cycle, pont vers Eliahou.
-/

/-- **R59 OU-B step bound**: à chaque step Syracuse impair, le rapport est borné.

`2 * syracuseNext n ≤ 3 * n + 1` car syracuseNext n = (3n+1) / 2^{v}, avec v ≥ 1
(pour n impair). -/
theorem syracuseNext_two_le_three_n_plus_one
    (n : ℕ) (hn : n > 0) (hodd : n % 2 = 1) :
    2 * syracuseNext n ≤ 3 * n + 1 := by
  have h_spec : syracuseNext n * 2 ^ (v2_3n1 n) = 3 * n + 1 := syracuseNext_spec n
  -- v2_3n1 n ≥ 1 pour n impair (3n+1 est pair).
  have hv_ge1 : 1 ≤ v2_3n1 n := by
    unfold v2_3n1
    have h2div : 2 ∣ (3 * n + 1) := by omega
    exact pow2_dvd_le_v2Nat_pos _ 1 (by omega) (by simpa using h2div)
  have h_pow_ge_2 : 2 ^ (v2_3n1 n) ≥ 2 := by
    calc 2 ^ (v2_3n1 n) ≥ 2 ^ 1 :=
          Nat.pow_le_pow_right (by norm_num) hv_ge1
      _ = 2 := by norm_num
  calc 2 * syracuseNext n
      ≤ syracuseNext n * 2 ^ (v2_3n1 n) := by
        rw [Nat.mul_comm 2 _]
        exact Nat.mul_le_mul_left _ h_pow_ge_2
    _ = 3 * n + 1 := h_spec

/-- **R59 OU-B nSeq step bound**: pour orbite Syracuse de n impair, à chaque step,
`2 * nSeq n (i+1) ≤ 3 * nSeq n i + 1`. -/
theorem nSeq_step_bound (n : ℕ) (hn : n > 0) (hodd : n % 2 = 1) (i : ℕ) :
    2 * nSeq n (i + 1) ≤ 3 * nSeq n i + 1 := by
  have hodd_i : nSeq n i % 2 = 1 := nSeq_odd n i hodd
  have hpos_i : nSeq n i > 0 := nSeq_pos n hn i
  show 2 * syracuseNext (nSeq n i) ≤ 3 * nSeq n i + 1
  exact syracuseNext_two_le_three_n_plus_one (nSeq n i) hpos_i hodd_i

/-! ## Round 60: Inégalité-poussée Steiner (Collatz historique)

🎯 **Outil universel** (Collatz historique R56): pour tout cycle, S > k.

Preuve élémentaire: 2^S > 3^k > 2^k (pour k ≥ 1), d'où S > k.

C'est la version faible de l'inégalité-poussée S ≥ ⌈k · log_2(3)⌉ qui sera
prouvée dans une round future via convergents CF (Lagarias).
-/

/-- **R60 inégalité-poussée (forme faible)**: pour tout cycle non-trivial,
`S = aSumSeq n k > k`. Conséquence de `2^S > 3^k > 2^k` (k ≥ 1).

Version forte (à venir via Lagarias convergents) : `S ≥ ⌈k · log_2(3)⌉`. -/
theorem cycle_S_gt_k (n k : ℕ) (hcyc : IsOddCycle n k) :
    aSumSeq n k > k := by
  have h_2S_gt_3k := cycle_pow2_gt_pow3_universal n k hcyc
  obtain ⟨_, _, hk_pos, _⟩ := hcyc
  -- 3^k > 2^k for k ≥ 1
  have h_3k_gt_2k : (3 : ℕ) ^ k > 2 ^ k := by
    apply Nat.pow_lt_pow_left (by norm_num : (2 : ℕ) < 3)
    omega
  -- 2^S > 3^k > 2^k ⟹ 2^S > 2^k ⟹ S > k
  have h_2S_gt_2k : (2 : ℕ) ^ (aSumSeq n k) > 2 ^ k := by linarith
  -- Strict monotonicity of x → 2^x.
  by_contra h
  push_neg at h  -- h : aSumSeq n k ≤ k
  have : (2 : ℕ) ^ (aSumSeq n k) ≤ 2 ^ k :=
    Nat.pow_le_pow_right (by norm_num : (1 : ℕ) ≤ 2) h
  omega

/-! ## Round 61: Outil 5 — borne max nSeq n j ≤ 2^j · n (univ.)

🎯 **Outil universel** (composition R59 step bound):
À chaque step Syracuse, `n_{i+1} ≤ (3·n_i + 1)/2 ≤ 2·n_i` (pour n_i ≥ 1).

Donc par récurrence: `nSeq n j ≤ 2^j · n` pour tout j.

Combiné avec la propriété de cycle (nSeq n k = n_0), cela donne:
- max(n_i) ≤ 2^k · min(n_i) (avec min = n_0 si min position 0).

Forme faible de Outil 5 (min/max global). Version forte M/m ≤ (3/2)^k
demande analyse plus fine, à venir dans round suivant.
-/

/-- **R61 Outil 5 (forme faible)**: `nSeq n j ≤ 2^j * n` pour orbite Syracuse. -/
theorem nSeq_le_2pow_mul (n : ℕ) (hn : n > 0) (hodd : n % 2 = 1) (j : ℕ) :
    nSeq n j ≤ 2 ^ j * n := by
  induction j with
  | zero => simp [nSeq]
  | succ j ih =>
    -- nSeq n (j+1) = syracuseNext (nSeq n j) ≤ 2 · nSeq n j (ascent_always_bounded)
    have hpos_j : nSeq n j > 0 := nSeq_pos n hn j
    have hodd_j : nSeq n j % 2 = 1 := nSeq_odd n j hodd
    have h_step : nSeq n (j + 1) < 2 * nSeq n j := by
      show syracuseNext (nSeq n j) < 2 * nSeq n j
      exact ascent_always_bounded (nSeq n j) hpos_j hodd_j
    -- nSeq n (j+1) ≤ 2 · nSeq n j ≤ 2 · 2^j · n = 2^(j+1) · n
    calc nSeq n (j + 1) ≤ 2 * nSeq n j := by omega
      _ ≤ 2 * (2 ^ j * n) := Nat.mul_le_mul_left 2 ih
      _ = 2 ^ (j + 1) * n := by ring

/-- **Corollaire R61**: dans un cycle Collatz, `max ≤ 2^k · min` (forme lâche). -/
theorem cycle_max_le_2pow_k_min (n k : ℕ) (hcyc : IsOddCycle n k) :
    ∀ j, j ≤ k → nSeq n j ≤ 2 ^ k * n := by
  obtain ⟨hn_gt1, hodd, hk_pos, _⟩ := hcyc
  intro j hj
  have h_n_pos : n > 0 := by omega
  -- nSeq n j ≤ 2^j · n ≤ 2^k · n (puisque j ≤ k)
  have h_le := nSeq_le_2pow_mul n h_n_pos hodd j
  have h_pow_mono : 2 ^ j ≤ 2 ^ k := Nat.pow_le_pow_right (by norm_num) hj
  calc nSeq n j ≤ 2 ^ j * n := h_le
    _ ≤ 2 ^ k * n := Nat.mul_le_mul_right n h_pow_mono

/-! ## Round 64: Outil 11 — Lien algébrique parityVector ↔ blocs

🎯 **Conjecture NEW Q4 (validée par directeur de recherche)**:
Un bloc "descendant" dans l'orbite Syracuse ⟺ aSeq n i ≥ 2.

Preuve : nSeq n (i+1) = (3·n_i + 1) / 2^{s_i}.
- s_i = 1 → (3n_i + 1)/2 > n_i (ascension stricte).
- s_i ≥ 2 → (3n_i + 1)/4 < n_i (descente stricte si n_i ≥ 2).

Cet outil permet à NEW2 (BlockDecomposition) de **caractériser les minima
locaux algébriquement** via parityVector. Correction NEW2 R64
(bug docstring R64 NEW initial):

  i est MAXIMUM local ↔ aSeq n (i-1) = 1 ET aSeq n i ≥ 2
                       (ascension précédente, descente suivante)
  i est MINIMUM local ↔ aSeq n (i-1) ≥ 2 ET aSeq n i = 1
                       (descente précédente, ascension suivante)

Pont algébrique entre arbre 10 (NEW2) et nos outils R24/R32-33.
-/

/-- **R64 Outil 11**: descente Syracuse caractérisée par s_i ≥ 2.

Pour orbite Syracuse non-triviale (n_i ≥ 2), `aSeq n i ≥ 2 → nSeq n (i+1) < nSeq n i`. -/
theorem nSeq_decreases_if_aSeq_ge_2
    (n : ℕ) (hn : n > 0) (hodd : n % 2 = 1)
    (i : ℕ) (h_n_i_ge_2 : nSeq n i ≥ 2) (h_a_ge_2 : aSeq n i ≥ 2) :
    nSeq n (i + 1) < nSeq n i := by
  show syracuseNext (nSeq n i) < nSeq n i
  -- Spec: syracuseNext m · 2^(v2_3n1 m) = 3·m + 1
  have h_spec : syracuseNext (nSeq n i) * 2 ^ (v2_3n1 (nSeq n i)) =
                3 * nSeq n i + 1 := syracuseNext_spec (nSeq n i)
  -- aSeq n i = v2_3n1 (nSeq n i) by def
  have h_aSeq_def : aSeq n i = v2_3n1 (nSeq n i) := rfl
  rw [← h_aSeq_def] at h_spec
  -- 2^(aSeq n i) ≥ 4
  have h_pow_ge_4 : 2 ^ (aSeq n i) ≥ 4 := by
    calc 2 ^ (aSeq n i) ≥ 2 ^ 2 :=
          Nat.pow_le_pow_right (by norm_num) h_a_ge_2
      _ = 4 := by norm_num
  -- syracuseNext · 4 ≤ 3·n_i + 1
  have h_le : syracuseNext (nSeq n i) * 4 ≤ 3 * nSeq n i + 1 := by
    calc syracuseNext (nSeq n i) * 4
        ≤ syracuseNext (nSeq n i) * 2 ^ (aSeq n i) :=
          Nat.mul_le_mul_left _ h_pow_ge_4
      _ = 3 * nSeq n i + 1 := h_spec
  -- 4·syracuseNext ≤ 3·n_i + 1 ; n_i ≥ 2 → 4·n_i > 3·n_i + 1
  -- Donc 4·syracuseNext < 4·n_i, donc syracuseNext < n_i
  omega

/-- **R64 corollaire**: dans cycle Collatz, descente Syracuse à position i ⟸ aSeq n i ≥ 2.

Reverse direction (s_i = 1 → ascension) à prouver dans R65 si nécessaire. -/
theorem cycle_descent_if_aSeq_ge_2
    (n k : ℕ) (hcyc : IsOddCycle n k) (i : ℕ)
    (h_n_i_ge_2 : nSeq n i ≥ 2) (h_a_ge_2 : aSeq n i ≥ 2) :
    nSeq n (i + 1) < nSeq n i := by
  obtain ⟨hn_gt1, hodd, _, _⟩ := hcyc
  have hn_pos : n > 0 := by omega
  exact nSeq_decreases_if_aSeq_ge_2 n hn_pos hodd i h_n_i_ge_2 h_a_ge_2

/-! ## Conjecture: v_p obstruction (Round 18 ChatGPT triade convergence) -/

/--
**Key conjecture identified by the Phase B triadic exploration (Round 18)**:

For every parity vector `s` with `s.length ≥ 2` and `s` not the periodic
extension of `[2]` (which corresponds to the trivial cycle), there exists a
prime `p` such that the `p`-adic valuation of `cyclicSum s` is strictly less
than that of `cyclicDenom s`.

If proven, the conjecture implies `cyclicDenom s ∤ cyclicSum s` for every
non-trivial `s` with `k ≥ 2`, eliminating all non-trivial Collatz cycles via
`cycle_iff_divisibility` (Steiner).

Status: **open**. Identified by ChatGPT R18 elimination as the only angle
*not* absorbed by Steiner / Baker / Mignotte / Hercher / Bernstein–Lagarias.

Implementation note: the natural `p`-adic valuation in Mathlib is via
`Nat.factorization` (for `ℕ`) and `padicValNat`. The cleanest formulation is
left as future work; here we use a simple existential placeholder.
-/
theorem cycle_v_p_obstruction (s : List ℕ)
    (hk : s.length ≥ 2)
    (h_nontriv : s ≠ List.replicate s.length 2) :
    ∃ p : ℕ, p.Prime ∧
      (padicValNat p (cyclicSum s) :ℤ) < (padicValInt p (cyclicDenom s) : ℤ) := by
  sorry

/-! ## Documentation of the triadic convergence

The path from R15 to R18:

- **R15** (ChatGPT): proposed `mod 3^r` as a transport obstruction. Self-refuted
  via `|𝒜_k| = 1` (unique class mod 3^k).
- **R16** (ChatGPT): refined to `S(s) = ⋂_i 𝒞_i` with positivity + parity +
  dynamic coherence constraints. OLD audit: reformulation valid but equivalent
  to Steiner mod 3^k by aggregation.
- **R17** (ChatGPT): proposed archimedean obstruction
  `s ≠ trivial ⟹ x_s ∉ ℤ_{>0}`. NEW + OLD audit: structurally equivalent to
  `D_s ∣ C_s` (the Steiner divisibility condition).
- **R18** (ChatGPT): honest admission. All naive angles eliminated:
  - 2-adic-only: KO (folklore Steiner)
  - taille / croissance: KO (Baker μ approximation)
  - probabiliste: KO (zero-measure cycles)
  - inversion locale: KO (always solvable)
  - **only remaining**: fine analysis of `v_p(C_s)` vs `v_p(D_s)` (this file).

OLD super-additivity finding: the asymmetry between mod-`3^k` (where 2 is
invertible) and mod-`2^j` (where division-by-2 loses information) preserves
the validity of Eric's existing Rounds 11-14 (mod-2^j parity-sum bounds).

Eric's existing `corrSum n K = cyclicSum (parityVector n K)` link, combined
with `cycle_v_p_obstruction`, would close the conditional theorem.
-/

end ProjetCollatz.PostJAR
