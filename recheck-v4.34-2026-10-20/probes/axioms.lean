import Labo.S1_X02_Barina

/-! Axiom profile of the re-checked theorems (Lean 4.34.0, Mathlib v4.34.0).
Expected: the output of every `#print axioms` below is `depends on axioms: [...]` with a subset of
`propext`, `Classical.choice`, `Quot.sound`, or `does not depend on any axioms`. -/

-- v1.0, Phase58PorteDeuxFinal.lean: the non-circular result
#print axioms ProjetCollatz.no_cycle_k_le_1322
#check @ProjetCollatz.no_cycle_k_le_1322

-- v1.0, same import closure: the circular headline theorems (see the erratum), then three immediate
-- consequences of no_cycle_k_le_1322 under BakerSeparation and BarinaVerification, for every return time k:
-- k > 1322 (bk_1322_derived) and k ≥ 92 (hercher_from_baker_barina, hercher_derived)
#print axioms ProjetCollatz.no_nontrivial_cycle_final
#print axioms ProjetCollatz.no_nontrivial_cycle_derived
#print axioms ProjetCollatz.no_nontrivial_cycle_full
#print axioms ProjetCollatz.bk_1322_derived
#print axioms ProjetCollatz.hercher_from_baker_barina
#print axioms ProjetCollatz.hercher_derived

-- LABO-COLLATZ, S1_X02_H3.lean: X02 under BakerSeparation and BarinaVerification, then
-- S1_no_cycle_k_le_1322_local (register entry R03)
#print axioms ProjetCollatz.S1_x02_H3_implies_no_cycle
#print axioms ProjetCollatz.S1_x02_no_cycle_implies_H3
#print axioms ProjetCollatz.S1_x02_H3_iff_no_cycle
#print axioms ProjetCollatz.S1_x02_any_bound_iff
#print axioms ProjetCollatz.S1_no_cycle_k_le_1322_local

-- LABO-COLLATZ, S1_H1_Fini.lean: BakerSeparation for 2 ≤ k ≤ 1322 (one kernel reduction over all these k, then
-- monotonicity in s), and its consequence under BarinaVerification alone
#print axioms ProjetCollatz.S1_chk_range
#print axioms ProjetCollatz.S1_H1_finite
#print axioms ProjetCollatz.S1_no_cycle_k_le_1322_barina_only
#check @ProjetCollatz.S1_no_cycle_k_le_1322_barina_only

-- LABO-COLLATZ, S1_X02_Barina.lean: X02 under BarinaVerification alone
#print axioms ProjetCollatz.S1_x02_barina_only_any_bound_iff
#print axioms ProjetCollatz.S1_x02_barina_only_H3_iff
#print axioms ProjetCollatz.S1_no_nontrivial_cycle_without_baker
