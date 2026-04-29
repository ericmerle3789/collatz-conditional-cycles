import ProjetCollatz.PostJAR.CycleArithmetic
import Mathlib.Data.Nat.GCD.Basic

/-!
# MCycleReduction.lean — Round 28+T4: m-cycle reduction (OLD parallel work)

## Origin

Following the R28 milestone (Hercher modulo 3 axioms) and Eric's directive
"OLD peut travailler aussi", this file proves T4 of Hercher's roadmap:

  Every m-cycle of the Collatz odd-iterate map decomposes into the repetition
  of a minimal cycle of length m (where m divides k).

OLD wrote the scaffolding via mailbox (cron loop restricts direct repo edits);
NEW commits it on OLD's behalf.

## Reference

- Steiner 1977, *A theorem on the Syracuse problem*, Lemma 1.
- Hercher 2023, *New cycle bounds for the 3x+1 problem*, §5.

## Status

OLD vote (R29): option B = AXIOMATISE temporarily (style R28, +1 refereed
axiom) to reach k ≤ 91 modulo 4 axioms quickly. Future round can replace
the axiom with a full proof (~100-150 Lean lines, ~1-2 weeks).

This commit applies vote B: axiom + theorem statements.
-/

namespace ProjetCollatz.PostJAR

open ProjetCollatz

/-- A cycle is called *minimal* if no proper divisor of its length is also a
cycle. Equivalently, the values `n_0, n_1, ..., n_{k-1}` are all distinct. -/
def IsMinimalCycle (n k : ℕ) : Prop :=
  IsOddCycle n k ∧ ∀ d : ℕ, d ∣ k → d < k → ¬ IsOddCycle n d

/-- **T4 (Steiner-Hercher m-cycle reduction)** — PROVED (R34).

For any non-trivial Collatz cycle `IsOddCycle n k`, there exists a divisor
`m ∣ k` such that `(n, m)` is itself a minimal cycle.

**Reference**: Steiner 1977 (*A theorem on the Syracuse problem*, Lemma 1).

**Proof strategy**: take `m = Nat.find { j | 1 ≤ j ∧ nSeq n j = n }` (smallest
period). This `m` exists because `k` is in the set (k ≥ 1 and nSeq n k = n).
Then:
- `m ∣ k` (by Euclidean division and minimality of m).
- `IsOddCycle n m` (n > 1, n odd, m ≥ 1, nSeq n m = n).
- `IsMinimalCycle n m` (any smaller divisor would contradict `Nat.find`'s
  minimality).

We give a clean Lean proof using `Nat.find`. -/
theorem m_cycle_reduces_to_minimal
    (n k : ℕ) (hcyc : IsOddCycle n k) :
    ∃ m : ℕ, m ∣ k ∧ 1 ≤ m ∧
    ∃ n' : ℕ, IsMinimalCycle n' m := by
  obtain ⟨hn_gt1, hodd, hk_pos, hcyc_eq⟩ := hcyc
  classical
  -- Existence of a period: k itself is one.
  have h_exists : ∃ j : ℕ, 1 ≤ j ∧ nSeq n j = n := ⟨k, hk_pos, hcyc_eq⟩
  -- Take m = smallest period.
  set m := Nat.find h_exists with hm_def
  have hm_spec : 1 ≤ m ∧ nSeq n m = n := Nat.find_spec h_exists
  obtain ⟨hm_pos, hm_period⟩ := hm_spec
  have hm_min : ∀ j, j < m → ¬ (1 ≤ j ∧ nSeq n j = n) := fun j hjm =>
    Nat.find_min h_exists hjm
  have hm_le_k : m ≤ k := Nat.find_le ⟨hk_pos, hcyc_eq⟩
  refine ⟨m, ?_, hm_pos, n, ⟨⟨hn_gt1, hodd, hm_pos, hm_period⟩, ?_⟩⟩
  · -- m ∣ k: by minimality, k mod m must be 0.
    -- Otherwise k = q*m + r with 0 < r < m, but nSeq n r = nSeq n (k - q*m) = n
    -- (using cycle_nSeq_periodic), contradicting minimality.
    by_contra h_not_dvd
    have hr_pos : 0 < k % m := Nat.pos_of_ne_zero (fun h => h_not_dvd (Nat.dvd_of_mod_eq_zero h))
    have hr_lt : k % m < m := Nat.mod_lt _ hm_pos
    -- Use periodicity: nSeq n (k % m) = nSeq n k = n (multiple full periods cancel out).
    have h_nseq_mod : nSeq n (k % m) = n := by
      have h_decomp : k = (k / m) * m + k % m := by
        rw [Nat.mul_comm]
        exact (Nat.div_add_mod k m).symm
      have h_periodic : ∀ j : ℕ, nSeq n (j + m) = nSeq n j :=
        cycle_nSeq_periodic n m hm_period
      have h_periodic_mult : ∀ j : ℕ, nSeq n ((k / m) * m + j) = nSeq n j := by
        intro j
        induction (k / m) with
        | zero => simp
        | succ q ih =>
          have : (q + 1) * m + j = (q * m + j) + m := by ring
          rw [this, h_periodic, ih]
      have hk_eq : nSeq n k = nSeq n (k % m) := by
        calc nSeq n k
            = nSeq n ((k / m) * m + k % m) := by rw [← h_decomp]
          _ = nSeq n (k % m) := h_periodic_mult (k % m)
      rw [hcyc_eq] at hk_eq
      exact hk_eq.symm
    -- But hm_min says no j < m has 1 ≤ j ∧ nSeq n j = n.
    exact hm_min (k % m) hr_lt ⟨hr_pos, h_nseq_mod⟩
  · -- IsMinimalCycle: no proper divisor d < m gives IsOddCycle n d.
    intros d hd_dvd hd_lt h_cyc_d
    -- IsOddCycle n d implies nSeq n d = n. But d < m contradicts hm_min.
    obtain ⟨_, _, hd_pos, hd_eq⟩ := h_cyc_d
    exact hm_min d hd_lt ⟨hd_pos, hd_eq⟩

/-- **Corollary**: it suffices to eliminate minimal cycles. The full set of
cycles for k ≤ 91 is exactly the union of m-cycle repetitions for m ≤ 91. -/
theorem no_cycle_via_minimal (k : ℕ) (hk : 1 ≤ k)
    (hmin : ∀ n m : ℕ, m ∣ k → 1 ≤ m → ¬ IsMinimalCycle n m) :
    ∀ n : ℕ, ¬ IsOddCycle n k := by
  intro n hcyc
  obtain ⟨m, hmdvd, hmpos, n', hmin_cyc⟩ := m_cycle_reduces_to_minimal n k hcyc
  exact hmin n' m hmdvd hmpos hmin_cyc

end ProjetCollatz.PostJAR
