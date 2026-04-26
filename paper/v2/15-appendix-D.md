# Seven theorems of the central chain

The central conditional non-existence theorem is exposed as seven
distinct theorems in `ProjetCollatz/`, each tailored to a specific
downstream packaging convention (six aliases of the canonical form
plus the bridge lemma `sdw_from_cf`). All seven share the kernel-3
axiom profile of Appendix B; they differ only in how the three
hypotheses are bundled and which sub-branch they discharge.

## Canonical form

`ProjetCollatz.no_nontrivial_cycle_final`
:   `Phase58PorteDeuxFinal.lean`, line 339. Three `structure`
    hypotheses (`BakerSeparation`, `BarinaVerification`,
    `ProductBoundThreshold`) as explicit arguments. This is the
    form quoted in §3.1 and is the canonical entry point for
    downstream consumers.

## Variants of the canonical form

`ProjetCollatz.no_nontrivial_cycle_phase59`
:   `Phase59ContinuedFractions.lean`, line 236. Three-argument
    version that takes `BakerSeparation`, `BarinaVerification`,
    and a continued-fraction-side hypothesis structure
    `DerivedLargeKBound` (with signature
    $\forall n, k.\ \mathtt{IsOddCycle}(n, k) \Rightarrow
    k > 1322 \Rightarrow n < 2^{71}$) instead of
    `ProductBoundThreshold`. The conversion
    `DerivedLargeKBound → ProductBoundThreshold` is performed by
    `sdw_from_cf` (below); the two forms are interderivable under
    the standard hypotheses.

`ProjetCollatz.no_nontrivial_cycle_derived`
:   `Phase56Bloc18Complete.lean`, line 355. Variant taking
    `ExternalCycleHypothesesDerived` (a structure that bundles the
    three hypotheses into a single record). Equivalent to the
    canonical form via record projection.

`ProjetCollatz.no_nontrivial_cycle_full`
:   `Phase52SteinerEquation.lean`, line 202. Foundation form
    taking `ExternalCycleHypothesesFull` (which augments the three
    fields with an explicit cycle-element bound below $2^{71}$).
    Used as the constructive seed of the alias chain; the
    cycle-element bound of `ExternalCycleHypothesesFull` is
    discharged by Barina's verification.

## Sub-branch theorems

`ProjetCollatz.no_cycle_k_le_1322`
:   `Phase58PorteDeuxFinal.lean`, line 134. Closes the optimal
    sub-branch $k \leq 1322$ (Baker + Barina). Used directly
    by §7.1 (Reformulation \ref{ref:disjunction}, low-complexity
    disjunct).

`ProjetCollatz.no_cycle_k_gt_1322`
:   `Phase59ContinuedFractions.lean`, line 173. Closes the
    sub-branch $k > 1322$ (continued fractions + Barina), under
    `DerivedLargeKBound`. Used by `no_nontrivial_cycle_phase59`
    above as one of the two cases.

## Conditional bridge lemma

`ProjetCollatz.sdw_from_cf`
:   `Phase59ContinuedFractions.lean`, line 197. The conditional
    derivation `BakerSeparation + BarinaVerification +
    DerivedLargeKBound → ProductBoundThreshold`. Witnesses the
    interchangeability of the two strong-hypothesis structures and
    is the key step in proving `no_nontrivial_cycle_phase59`.

## Logical relationships

The seven theorems form a small commutative diagram (informally):
$$
\begin{array}{c}
\mathtt{BakerSeparation} \\
\mathtt{BarinaVerification} \\
\mathtt{DerivedLargeKBound}
\end{array}
\;\xrightarrow{\;\mathtt{sdw\_from\_cf}\;}\;
\mathtt{ProductBoundThreshold}
\;\Rightarrow\;
\mathtt{no\_nontrivial\_cycle\_final}
$$
with the canonical form `no_nontrivial_cycle_final` being the
single endpoint, and the various intermediate variants
(`derived`, `full`, `phase59`) corresponding to alternative ways
to package the hypotheses into Lean structures. The two
sub-branches `no_cycle_k_le_1322` and `no_cycle_k_gt_1322` are
the case split that the canonical form composes.

The probe `probes/check_central_axioms.lean` runs `#print axioms`
for all seven, certifying that each lives strictly under the
kernel-3 baseline of Appendix B.
