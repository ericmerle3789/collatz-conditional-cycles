import Mathlib.Data.Rat.Defs
import Mathlib.Data.ZMod.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.Ring.Rat
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.GCongr

/-!
# Phase VIII — Structural Excess Ψ_s

Custom definition of Gowers-like U^s norms for Collatz cycle parity analysis.

**Why custom?** Mathlib v4.27.0 does NOT contain Gowers U^s norms (verified via
`grep -rn "Gowers" .lake/packages/mathlib/`). We therefore define the minimal
machinery needed (`Φ_1`, `Φ_2`, `Ψ_1`, `Ψ_2`) from scratch via `Finset.sum`
on the rationals `ℚ`, suitable for `native_decide` on small `T`.

**Authoritative reference.** internal mathnotes (Phase VIII
Sub-Bricks 1–4), `mailbox/archive/from_mathlib_prover/`.

## Main definitions

* `ParityVec T`    — parity vector `ZMod T → Bool`
* `countK v`       — number of `true` entries
* `meanK T v`      — `K/T` as rational
* `parityToRat b`  — `true ↦ 1`, `false ↦ -1`
* `phi1 T v`       — `Φ_1(v) = (2·K/T - 1)²`
* `phi2 T v`       — `Φ_2(v) = (1/T³) Σ f(x)·f(x+h₁)·f(x+h₂)·f(x+h₁+h₂)`
* `psi1 T v`       — `Ψ_1(v) = Φ_1(v) − (2·K/T − 1)²`
* `psi2 T v`       — `Ψ_2(v) = Φ_2(v) − (2·K/T − 1)⁴`

## Convention

Non-accelerated Collatz : `T(n) = n/2` if `n` even, `T(n) = 3n+1` if `n` odd.
The trivial cycle `1 → 4 → 2 → 1` gives `T = 3`, `K = 1` and parity vector
`(true, false, false)`.

## Status

`[OBSERVATION PROVED MINOR]` for `psi1_eq_zero` and the Part A2 trivial-cycle
computations. The deep conjecture `T4c` is encoded as a parametric `def`
(`T4c_Conjecture_Psi2` / `_Uniform`) — a Prop whose shape is recorded without
a pseudo-proof. Zero `sorry`, zero new axioms.
-/

namespace ProjetCollatz.PhaseVIII

open Finset

/-- Parity vector of period `T`, indexed by `ZMod T`.
`v x = true` encodes "odd step at position `x`". -/
abbrev ParityVec (T : ℕ) := ZMod T → Bool

section Definitions

variable {T : ℕ} [NeZero T]

/-- `countK v = |{ x : v x = true }|`, the number of odd steps. -/
def countK (v : ParityVec T) : ℕ :=
  (Finset.univ.filter (fun x : ZMod T => v x = true)).card

/-- Mean frequency of odd steps, `K/T` as a rational number. -/
def meanK (T : ℕ) [NeZero T] (v : ParityVec T) : ℚ :=
  (countK v : ℚ) / (T : ℚ)

/-- `Bool → ℚ` encoding : `true ↦ 1`, `false ↦ -1`. -/
def parityToRat : Bool → ℚ
  | true  => 1
  | false => -1

/-- `Φ_1(v) = |E[f]|² = (2·K/T - 1)²`. -/
def phi1 (T : ℕ) [NeZero T] (v : ParityVec T) : ℚ :=
  (2 * meanK T v - 1) ^ 2

/-- `Φ_2(v) = E_{x,h₁,h₂} [f(x)·f(x+h₁)·f(x+h₂)·f(x+h₁+h₂)]`,
computed as the explicit average over `T³` tuples. -/
def phi2 (T : ℕ) [NeZero T] (v : ParityVec T) : ℚ :=
  (1 / ((T : ℚ) ^ 3)) *
    ∑ x : ZMod T, ∑ h1 : ZMod T, ∑ h2 : ZMod T,
      parityToRat (v x) * parityToRat (v (x + h1)) *
      parityToRat (v (x + h2)) * parityToRat (v (x + h1 + h2))

/-- Structural excess `Ψ_1(v) = Φ_1(v) - (2·K/T - 1)² = 0`. -/
def psi1 (T : ℕ) [NeZero T] (v : ParityVec T) : ℚ :=
  phi1 T v - (2 * meanK T v - 1) ^ 2

/-- Structural excess `Ψ_2(v) = Φ_2(v) - (2·K/T - 1)⁴`. -/
def psi2 (T : ℕ) [NeZero T] (v : ParityVec T) : ℚ :=
  phi2 T v - (2 * meanK T v - 1) ^ 4

end Definitions

section BasicLemmas

variable {T : ℕ} [NeZero T]

/-- **[OBSERVATION PROVED MINOR]** `Ψ_1` is identically zero (by construction). -/
theorem psi1_eq_zero (v : ParityVec T) : psi1 T v = 0 := by
  unfold psi1 phi1
  ring

/-- `parityToRat` values are ±1. -/
theorem parityToRat_sq (b : Bool) : parityToRat b * parityToRat b = 1 := by
  cases b <;> simp [parityToRat]

/-- `parityToRat b = 1 ∨ parityToRat b = -1`. -/
theorem parityToRat_eq_one_or_neg_one (b : Bool) :
    parityToRat b = 1 ∨ parityToRat b = -1 := by
  cases b <;> simp [parityToRat]

/-- `|parityToRat b| = 1`. -/
theorem parityToRat_abs_eq_one (b : Bool) : |parityToRat b| = 1 := by
  rcases parityToRat_eq_one_or_neg_one b with h | h <;> rw [h] <;> simp

/-- **[OBSERVATION PROVED MINOR]** `countK v ≤ T`: count is bounded by period. -/
theorem countK_le (v : ParityVec T) : countK v ≤ T := by
  classical
  unfold countK
  calc (Finset.univ.filter (fun x : ZMod T => v x = true)).card
      ≤ (Finset.univ : Finset (ZMod T)).card := Finset.card_filter_le _ _
    _ = T := by simp [ZMod.card]

/-- **[OBSERVATION PROVED MINOR]** `meanK` is nonnegative. -/
theorem meanK_nonneg (v : ParityVec T) : 0 ≤ meanK T v := by
  have hT_nn : (0 : ℚ) ≤ (T : ℚ) := Nat.cast_nonneg _
  have hK_nn : (0 : ℚ) ≤ (countK v : ℚ) := Nat.cast_nonneg _
  unfold meanK
  exact div_nonneg hK_nn hT_nn

/-- **[OBSERVATION PROVED MINOR]** `Φ_1(v) ≥ 0` (it is a square). -/
theorem phi1_nonneg (v : ParityVec T) : 0 ≤ phi1 T v := by
  unfold phi1
  exact sq_nonneg _

/-- **[OBSERVATION PROVED MINOR]** `Ψ_1(v) = 0 ≥ 0` (trivial corollary). -/
theorem psi1_nonneg (v : ParityVec T) : 0 ≤ psi1 T v := by
  rw [psi1_eq_zero]

/-- **[OBSERVATION PROVED MINOR]** `meanK ≤ 1` (the proportion of odd steps is at most 1). -/
theorem meanK_le_one (v : ParityVec T) : meanK T v ≤ 1 := by
  have hT_pos : (0 : ℚ) < (T : ℚ) := by
    have h : (0 : ℕ) < T := Nat.pos_of_ne_zero (NeZero.ne T)
    exact_mod_cast h
  have hK_le : (countK v : ℚ) ≤ (T : ℚ) := by exact_mod_cast countK_le v
  unfold meanK
  exact (div_le_one₀ hT_pos).mpr hK_le

/-- **[OBSERVATION PROVED MINOR]** `meanK ∈ [0, 1]`. -/
theorem meanK_mem_unit (v : ParityVec T) : 0 ≤ meanK T v ∧ meanK T v ≤ 1 :=
  ⟨meanK_nonneg v, meanK_le_one v⟩

/-- **[OBSERVATION PROVED MINOR]** `2·meanK - 1 ∈ [-1, 1]`. -/
theorem two_meanK_minus_one_mem (v : ParityVec T) :
    -1 ≤ 2 * meanK T v - 1 ∧ 2 * meanK T v - 1 ≤ 1 := by
  obtain ⟨h0, h1⟩ := meanK_mem_unit v
  refine ⟨?_, ?_⟩ <;> linarith

/-- **[OBSERVATION PROVED MINOR]** `|2·meanK - 1| ≤ 1`. -/
theorem abs_two_meanK_minus_one_le_one (v : ParityVec T) :
    |2 * meanK T v - 1| ≤ 1 := by
  rw [abs_le]
  exact two_meanK_minus_one_mem v

/-- **[OBSERVATION PROVED MINOR]** `Φ_1(v) ≤ 1`: upper bound via `(2·mean - 1) ∈ [-1, 1]`. -/
theorem phi1_le_one (v : ParityVec T) : phi1 T v ≤ 1 := by
  unfold phi1
  rw [sq_le_one_iff_abs_le_one]
  exact abs_two_meanK_minus_one_le_one v

/-- **[OBSERVATION PROVED MINOR]** `Φ_1(v) ∈ [0, 1]`. -/
theorem phi1_mem_unit (v : ParityVec T) : 0 ≤ phi1 T v ∧ phi1 T v ≤ 1 :=
  ⟨phi1_nonneg v, phi1_le_one v⟩

/-- **[OBSERVATION PROVED MINOR]** `Ψ_1(v) ∈ [0, 1]` (= 0 actually, from `psi1_eq_zero`). -/
theorem psi1_mem_unit (v : ParityVec T) : 0 ≤ psi1 T v ∧ psi1 T v ≤ 1 := by
  rw [psi1_eq_zero]
  exact ⟨le_refl 0, by norm_num⟩

end BasicLemmas

section TrivialCycle

/-!
## Part A2 — Trivial cycle numerical verification

The unique known Collatz cycle `1 → 4 → 2 → 1` has period `T = 3`, one odd
step (`K = 1`), and parity vector `(true, false, false)` under the
non-accelerated convention.

We verify `Ψ_2 = 32/81` by reflection (`native_decide`) on the 27-term
explicit sum, matching the hand computation in the corresponding mathnote §5
and the structural excess value reported in 0039 §4.3.
-/

/-- Trivial cycle `(1 → 4 → 2 → 1)` parity vector on `ZMod 3`. -/
def trivialCycleParity : ParityVec 3 :=
  fun x => decide (x = 0)

/-- **[OBSERVATION PROVED MINOR]** The trivial cycle has `K = 1`. -/
theorem trivialCycle_countK : countK trivialCycleParity = 1 := by
  native_decide

/-- **[OBSERVATION PROVED MINOR]** The trivial cycle has `K/T = 1/3`. -/
theorem trivialCycle_meanK : meanK 3 trivialCycleParity = 1 / 3 := by
  native_decide

/-- **[OBSERVATION PROVED MINOR]** `Φ_1(v_trivial) = 1/9`. -/
theorem trivialCycle_phi1 : phi1 3 trivialCycleParity = 1 / 9 := by
  native_decide

/-- **[OBSERVATION PROVED MINOR]** `Φ_2(v_trivial) = 11/27` (Gowers `U^2`
computation on 27 tuples, matching mathnote 0037 §5). -/
theorem trivialCycle_phi2 : phi2 3 trivialCycleParity = 11 / 27 := by
  native_decide

/-- **[OBSERVATION PROVED MINOR]** Structural excess `Ψ_2(v_trivial) = 32/81`.

This is the machine-verified structural excess of the trivial Collatz cycle
over its mean-implied `(2K/T-1)^4 = 1/81` baseline, matching the hand
computation in the corresponding mathnote §4.3. A factor-`32×` excess over the
i.i.d. mean prediction. -/
theorem trivialCycle_psi2 : psi2 3 trivialCycleParity = 32 / 81 := by
  native_decide

end TrivialCycle

section T4cConjecture

/-!
## Part A3 — Conjecture T4c statement

The T4c conjecture (the corresponding mathnote, Sub-Brick 3 §5.3) states :

> *For every non-trivial Collatz cycle parity vector `v` of period `T ≥ T_0`,
> the structural excess `Ψ_2(v)` is bounded below by a positive constant.*

We formalize this as a **parametric `Prop`**, independent of a specific
machine-checkable `CollatzCycleParity` predicate (whose rigorous definition
via the Steiner equation belongs to `Phase52SteinerEquation.lean` / Part A4).

Stating the conjecture as a `def` (rather than a `theorem ... := sorry`)
avoids any semantic commitment : we record the shape of the claim, not a
pseudo-proof. This is the honest Lean encoding of a mathematical conjecture.

**Status: CONJECTURE WITH HEURISTIC (NOT PROVEN).**

* Empirical support : `trivialCycle_psi2` above shows `Ψ_2 = 32/81 > 0` for
  the trivial cycle. This is a single data point; extrapolation to large
  hypothetical cycles requires the open questions in mathnote 0040 §2–§6
  (Steiner rigidity, `i.i.d.` validity, Green–Tao–Ziegler inverse theorem
  application).
* Subjective probability of resolution : **20–30%** full proof within 5–10
  years (per mathnote 0040 §5.3).
-/

/-- **Parametric `Ψ_s` conjecture (`s = 2`)** : given any predicate
`CollatzCycleParity` identifying the parity vectors arising from genuine
non-trivial Collatz cycles, the claim is that every such vector has
positive `Ψ_2` structural excess.

To instantiate this into a concrete conjecture one chooses
`CollatzCycleParity` (intended meaning: "there exists an integer cycle
`(n_0, …, n_{T-1})` of the non-accelerated Collatz map with `v i = (n_i`
is odd`)`, and `(T, v) ≠ (3, trivialCycleParity)`"). -/
def T4c_Conjecture_Psi2
    (CollatzCycleParity : ∀ (T : ℕ), ParityVec T → Prop) : Prop :=
  ∀ (T : ℕ) [NeZero T] (v : ParityVec T),
    CollatzCycleParity T v → psi2 T v > 0

/-- **Parametric structural-excess conjecture (arbitrary `s ≥ 2`,
`Ψ_2` witness)**.

A slightly stronger form : we ask for an explicit positive lower bound
`ε > 0` depending only on the cycle predicate, matching the
`Ψ_s(v_cycle) ≥ ε_s` formulation in mathnote 0039 §5.1. -/
def T4c_Conjecture_Psi2_Uniform
    (CollatzCycleParity : ∀ (T : ℕ), ParityVec T → Prop) : Prop :=
  ∃ ε : ℚ, ε > 0 ∧
    ∀ (T : ℕ) [NeZero T] (v : ParityVec T),
      CollatzCycleParity T v → psi2 T v ≥ ε

/-- **[OBSERVATION PROVED MINOR]** `T4c_Conjecture_Psi2_Uniform` implies
the pointwise form `T4c_Conjecture_Psi2`. -/
theorem T4c_uniform_imp_pointwise
    (CollatzCycleParity : ∀ (T : ℕ), ParityVec T → Prop) :
    T4c_Conjecture_Psi2_Uniform CollatzCycleParity →
    T4c_Conjecture_Psi2 CollatzCycleParity := by
  rintro ⟨ε, hε, h⟩ T _ v hv
  exact lt_of_lt_of_le hε (h T v hv)

end T4cConjecture

section ContradictionSchema

/-!
## Part A4 — Contradiction schema (bridge shape)

The Ψ_s framework aims at excluding hypothetical Collatz cycles by
providing a **lower bound** on `Ψ_2(v_cycle)` (conjectural : T4c) that
contradicts some **independent upper bound** (currently unknown).

We record the *logical shape* of this attack as a purely formal
proposition. The schema is trivially a tautology — if you have both
`x ≥ ε` and `x < ε`, then any antecedent must be false. But recording
it explicitly in Lean makes the *attack strategy* machine-checkable
even when the two sides are mathematically out of reach.

**Connection to existing infrastructure.** A fully integrated bridge
would instantiate `CyclePredicate` from `IsOddCycle` (Phase50) by
extracting a parity vector. Such an extraction — `parityVectorOfOddCycle :
(n k : ℕ) → IsOddCycle n k → ParityVec (k + totalEvenSteps)` — is out
of Phase IX scope (requires deep coupling with `nSeq`, `aSumSeq`,
Phase47–Phase50 machinery).

The upper bound direction is the **open question of mathnote 0040
§2.3**: does Steiner rigidity force a non-trivial upper bound on
`Ψ_2(v_cycle)` ? No known result provides this. Without it, the
schema has a lower side (conjectural) but no upper side.
-/

/-- **[OBSERVATION PROVED MINOR]** *Contradiction schema* : if the
structural-excess `Ψ_2` has a positive lower bound `ε` on cycle vectors
(from T4c) and a strict upper bound by the same `ε` (from some
independent argument), then no cycle vector exists. -/
theorem psi2_bounds_no_cycle
    (CyclePredicate : ∀ (T : ℕ), ParityVec T → Prop)
    (ε : ℚ)
    (lower_bound :
      ∀ (T : ℕ) [NeZero T] (v : ParityVec T),
        CyclePredicate T v → psi2 T v ≥ ε)
    (upper_bound :
      ∀ (T : ℕ) [NeZero T] (v : ParityVec T),
        CyclePredicate T v → psi2 T v < ε) :
    ∀ (T : ℕ) [NeZero T] (v : ParityVec T), ¬ CyclePredicate T v := by
  intro T _ v hv
  exact absurd (lower_bound T v hv) (not_le.mpr (upper_bound T v hv))

/-- **Instantiation of the schema from T4c (uniform form) plus an
independent upper bound.** Given T4c's uniform lower-bound constant `ε`
and a strict upper bound `< ε` on the same cycle predicate, no cycle
vector exists.

In practice the two hypotheses share the same `ε` only if the upper
bound is "aware" of the T4c constant. A concrete proof path would
either (a) use T4c's Skolemized `ε` as input to the upper-bound
construction, or (b) combine a smaller upper bound with a weakened
T4c. -/
theorem T4c_plus_upper_bound_no_cycle
    (CyclePredicate : ∀ (T : ℕ), ParityVec T → Prop)
    (hT4c : T4c_Conjecture_Psi2_Uniform CyclePredicate)
    (hUpper :
      ∀ ε : ℚ, ε > 0 →
        ∀ (T : ℕ) [NeZero T] (v : ParityVec T),
          CyclePredicate T v → psi2 T v < ε) :
    ∀ (T : ℕ) [NeZero T] (v : ParityVec T), ¬ CyclePredicate T v := by
  obtain ⟨ε, hε, lower⟩ := hT4c
  intro T _ v hv
  have h1 : psi2 T v ≥ ε := lower T v hv
  have h2 : psi2 T v < ε := hUpper ε hε T v hv
  exact absurd h1 (not_le.mpr h2)

end ContradictionSchema

end ProjetCollatz.PhaseVIII
