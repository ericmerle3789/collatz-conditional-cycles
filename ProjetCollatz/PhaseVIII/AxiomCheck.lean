import ProjetCollatz.PhaseVIII.StructuralExcess

/-!
# Phase IX — Axiom audit

Verifies that no new user axioms are introduced by Phase VIII Ψ_s
framework. Expected axioms: `propext`, `Classical.choice`, `Quot.sound`
(standard Lean/Mathlib), plus `Lean.ofReduceBool` / `Lean.trustCompiler`
for `native_decide`-based theorems.
-/

open ProjetCollatz.PhaseVIII

#print axioms psi1_eq_zero
#print axioms parityToRat_sq
#print axioms trivialCycle_countK
#print axioms trivialCycle_meanK
#print axioms trivialCycle_phi1
#print axioms trivialCycle_phi2
#print axioms trivialCycle_psi2
#print axioms T4c_uniform_imp_pointwise
#print axioms psi2_bounds_no_cycle
#print axioms T4c_plus_upper_bound_no_cycle
