# Main theorem: conditional proof

## Statement

We formalize the following conditional result in Lean 4 (Mathlib v4.27.0).

```{=latex}
\begin{theorem}[Conditional non-existence of non-trivial Collatz cycles]
\label{thm:main}
Let \texttt{baker : BakerSeparation}, \texttt{barina : BarinaVerification},
and \texttt{sdw : ProductBoundThreshold}. Then for every pair of
natural numbers \texttt{n}, \texttt{k}, the predicate
\texttt{IsOddCycle n k} entails \texttt{False}.
\end{theorem}
```

The formal Lean statement (verbatim from the project, file
`ProjetCollatz/Phase58PorteDeuxFinal.lean`, line 339) reads:

```lean
theorem no_nontrivial_cycle_final
    (baker : BakerSeparation) (barina : BarinaVerification)
    (sdw : ProductBoundThreshold)
    (n k : ℕ) (hcyc : IsOddCycle n k) : False
```

See §2.3 for the Lean `structure` fields underlying the three
hypothesis parameters, §4 for the mathematical origin of each
hypothesis, and §8.1 for the full aliases listing the six
equivalent packagings of Theorem \ref{thm:main} exported by the
repository.

**Note on hypothesis redundancy.** The third hypothesis
`ProductBoundThreshold` is *interderivable* with the
continued-fraction-side hypothesis `DerivedLargeKBound` (§8.1) in
the presence of `BakerSeparation` and `BarinaVerification`: the
bridge lemma `sdw_from_cf` (Phase59 line 197) constructs the
former from the latter. The two formulations are therefore
logically equivalent, and the canonical theorem can be
equivalently stated under either of the two three-hypothesis
sets `(BakerSeparation, BarinaVerification, ProductBoundThreshold)`
or `(BakerSeparation, BarinaVerification, DerivedLargeKBound)`.
We adopt the former in §3.1 because `ProductBoundThreshold` is
the directly cycle-length-bounded statement (and thus the most
natural target for elimination-as-theorem); we adopt the latter
in §8 (Phase59 packaging) because it is the formulation that the
continued-fraction infrastructure actually produces.

## Proof chain

1. Extract the cycle minimum $m$ via `cycle_has_min` (Phase56, proved).
2. Apply `cycle_min_bound_nat` (Phase56, proved, uses Baker):
   $m \leq (k^7 + k) / 3$.
3. Use `ProductBoundThreshold.cycle_length_bound`: $k \leq 982$.
   This is the **structure parameter** (a conservative bound with
   $\approx 8\times$ safety margin); the corresponding optimal Lean
   theorem `no_cycle_k_le_1322` (cf. §4.3 and §8.1) covers the
   larger range $k \leq 1322$.
4. Apply `k982_bound` (Phase56, `native_decide`):
   $(982^7 + 982)/3 < 2^{71}$.
5. Hence $m < 2^{71}$. Combined with $m > 0$ (from `IsOddCycle`),
   Barina gives `reaches_one m`.
6. `cycle_prevents_reaching_one` (Phase50, proved) yields a
   contradiction.

## Axiom profile

**Note on perspective (parametric primary).**
`no_nontrivial_cycle_final` is **declared parametrically** with
`sdw : ProductBoundThreshold` as an explicit parameter. The proof
uses `sdw.cycle_length_bound` directly, without unfolding any
specific witness. Therefore, the **theorem-as-declared has axiom
profile** `[propext, Classical.choice, Quot.sound]` (kernel-3), as
machine-verified by `reproduce.sh` against the `expected_axioms.md`
baseline (see §8.6 / §8.7).

The alternative five-axiom reading below corresponds to the
**fully-instantiated** proof term obtained when a caller supplies
the concrete witness `k982_bound` (whose proof uses `native_decide`,
introducing `Lean.ofReduceBool` and `Lean.trustCompiler`). This
perspective is helpful for readers reconstructing the end-to-end
argument but does not modify the axiom profile of the parametric
theorem itself.

**Instantiated profile.** `propext`, `Classical.choice`, `Quot.sound`
(kernel-3) + `Lean.ofReduceBool`, `Lean.trustCompiler` (from
`native_decide` on `k982_bound`). All documented in
`expected_axioms.md`.

