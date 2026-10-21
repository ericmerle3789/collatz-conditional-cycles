import Labo.S1_H1_Fini
/-! LABO-COLLATZ · S1 · A4 — X02 strengthened: H1 (Baker) is not needed at all. -/
namespace ProjetCollatz

/-- Under Barina ALONE, for every K ≤ 1322: "every cycle has k ≤ K" ⇔ "no cycle". -/
theorem S1_x02_barina_only_any_bound_iff (barina : BarinaVerification) (K : ℕ) (hK : K ≤ 1322) :
    (∀ n k : ℕ, IsOddCycle n k → k ≤ K) ↔ ∀ n k : ℕ, ¬ IsOddCycle n k := by
  constructor
  · intro h n k hcyc
    exact S1_no_cycle_k_le_1322_barina_only barina n k hcyc (le_trans (h n k hcyc) hK)
  · intro h n k hcyc
    exact (h n k hcyc).elim

/-- **X02, final form.** Under Barina alone, the published third hypothesis H3 (`ProductBoundThreshold`,
k ≤ 982) is logically equivalent to the conclusion "there is no cycle". -/
theorem S1_x02_barina_only_H3_iff (barina : BarinaVerification) :
    Nonempty ProductBoundThreshold ↔ ∀ n k : ℕ, ¬ IsOddCycle n k := by
  constructor
  · rintro ⟨sdw⟩
    exact (S1_x02_barina_only_any_bound_iff barina 982 (by norm_num)).mp sdw.cycle_length_bound
  · intro h
    exact ⟨⟨fun n k hcyc => (h n k hcyc).elim⟩⟩

/-- The published main theorem, re-derived from Barina + H3 only (BakerSeparation discarded). -/
theorem S1_no_nontrivial_cycle_without_baker (barina : BarinaVerification) (sdw : ProductBoundThreshold)
    (n k : ℕ) (hcyc : IsOddCycle n k) : False :=
  (S1_x02_barina_only_H3_iff barina).mp ⟨sdw⟩ n k hcyc

/-- NEGATIVE CONTROL: with a bound K = 1323 the Barina-only argument must not close. -/
example (barina : BarinaVerification) (h : ∀ n k : ℕ, IsOddCycle n k → k ≤ 1323)
    (n k : ℕ) (hcyc : IsOddCycle n k) : True := by
  fail_if_success exact S1_no_cycle_k_le_1322_barina_only barina n k hcyc (h n k hcyc)
  trivial

end ProjetCollatz
#print axioms ProjetCollatz.S1_x02_barina_only_any_bound_iff
#print axioms ProjetCollatz.S1_x02_barina_only_H3_iff
#print axioms ProjetCollatz.S1_no_nontrivial_cycle_without_baker
