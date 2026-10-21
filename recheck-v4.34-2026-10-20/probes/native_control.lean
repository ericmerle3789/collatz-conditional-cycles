import Labo.S1_Phase56Bloc18Complete

/-! Positive control for the axiom check of `verify.sh`. `k982_bound` (v1.0, Phase56Bloc18Complete.lean)
is proved by `native_decide`; on Lean 4.34.0 its axioms must include an auxiliary axiom named
`ProjetCollatz.k982_bound._native.native_decide.ax_…`, which the axiom check of `verify.sh` rejects. -/

#print axioms ProjetCollatz.k982_bound
