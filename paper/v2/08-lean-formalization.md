# Formalization in Lean 4 (Mathlib v4.27.0)

The entire conditional theorem of §3 and all of its dependencies are
mechanically verified in the Lean 4 proof assistant, under Mathlib
version `v4.27.0`. The repository accompanying this paper is
self-contained: the reader can clone it from
<https://github.com/ericmerle3789/collatz-conditional-cycles>
(branch `main`; the release commit hash will be recorded in the Zenodo metadata upon deposit), run a single shell script,
and obtain a full verification with an explicit axiom profile. This section records the structure of that
verification, the axiom profile it produces, and the reproducibility
contract it exposes to the reader.

## The central conditional theorem

The statement of §3 is implemented as

```lean
theorem no_nontrivial_cycle_final
    (baker : BakerSeparation) (barina : BarinaVerification)
    (sdw : ProductBoundThreshold)
    (n k : ℕ) (hcyc : IsOddCycle n k) : False
```

in `ProjetCollatz/Phase58PorteDeuxFinal.lean` (line 339), with the three
`structure` hypotheses quoted verbatim in §2.3. The repository exposes
seven theorems (six aliases of the central theorem plus one helper
`sdw_from_cf`) for downstream use under different packagings:

`no_nontrivial_cycle_final`
:   `Phase58PorteDeuxFinal.lean`, line 339. Three `structure`
    hypotheses as explicit arguments (the canonical form).

`no_nontrivial_cycle_derived`
:   `Phase56Bloc18Complete.lean`, line 355. Takes
    `ExternalCycleHypothesesDerived`.

`no_nontrivial_cycle_full`
:   `Phase52SteinerEquation.lean`, line 202. Foundation form taking
    `ExternalCycleHypothesesFull` (the union of the three structure
    fields plus an explicit cycle-element bound below `2⁷¹`); used
    as the constructive seed of the alias chain.

`no_nontrivial_cycle_phase59`
:   `Phase59ContinuedFractions.lean`, line 236. Three-argument
    version that takes `BakerSeparation`, `BarinaVerification`, and
    a continued-fraction-side hypothesis structure
    `DerivedLargeKBound` (`Phase59ContinuedFractions.lean`,
    line 115; signature
    `∀ n k, IsOddCycle n k → k > 1322 → n < 2^71`) instead of
    `ProductBoundThreshold`. The conversion
    `DerivedLargeKBound → ProductBoundThreshold` is performed by
    `sdw_from_cf` below; the two formulations are interderivable
    under the standard hypotheses.

`no_cycle_k_le_1322`
:   `Phase58PorteDeuxFinal.lean`, line 134. Sub-branch
    `k ≤ 1322` (Baker + Barina).

`no_cycle_k_gt_1322`
:   `Phase59ContinuedFractions.lean`, line 173. Sub-branch
    `k > 1322` (continued fractions + Barina).

`sdw_from_cf`
:   `Phase59ContinuedFractions.lean`, line 197. Assembles
    `ProductBoundThreshold` from continued-fraction ingredients.

All seven theorems are listed in the *central chain* of the probe
`probes/check_central_axioms.lean` and consequently subject to
axiom-drift detection by `reproduce.sh` (§8.6). Their pairwise
logical dependencies are summarized graphically below
(Figure \ref{fig:depgraph}), and each is exhibited verbatim with
its Lean signature in Appendix D.

## Theorem-dependency diagram

```{=latex}
\begin{figure}[ht]
\centering
\resizebox{\linewidth}{!}{%
\begin{tikzpicture}[
  node distance=8mm and 10mm,
  hyp/.style={rectangle, draw, rounded corners, fill=gray!10,
              align=center, font=\scriptsize\ttfamily,
              minimum height=7mm, minimum width=22mm,
              inner sep=2pt},
  thm/.style={rectangle, draw, fill=blue!8, align=center,
              font=\scriptsize\ttfamily, minimum height=7mm,
              minimum width=22mm, inner sep=2pt},
  bridge/.style={rectangle, draw, dashed, fill=yellow!10,
                 align=center, font=\scriptsize\ttfamily,
                 minimum height=7mm, minimum width=18mm,
                 inner sep=2pt},
  arr/.style={->, >=Stealth, thick, shorten >=1pt}
]
\node[hyp] (B) {BakerSeparation};
\node[hyp, below=of B] (Ba) {BarinaVerification};
\node[hyp, below=of Ba] (D) {DerivedLargeKBound};

\node[thm, right=14mm of B] (kle) {no\_cycle\_k\_le\_1322};
\node[thm, right=14mm of Ba] (kgt) {no\_cycle\_k\_gt\_1322};
\node[bridge, right=14mm of D] (sdw) {sdw\_from\_cf};

\node[hyp, right=14mm of kgt] (PBT) {ProductBound\\Threshold};

\node[thm, right=14mm of PBT] (final) {no\_nontrivial\\\_cycle\_final};

\draw[arr] (B) -- (kle);
\draw[arr] (Ba.east) -- (kle.west);
\draw[arr] (Ba) -- (kgt);
\draw[arr] (D.east) -- (kgt.west);
\draw[arr] (B.east) -- (sdw.west);
\draw[arr] (Ba.east) -- (sdw.west);
\draw[arr] (D) -- (sdw);
\draw[arr] (sdw) -- (PBT);
\draw[arr] (kle.east) -- (final.west);
\draw[arr] (kgt.east) -- (PBT.west);
\draw[arr] (PBT) -- (final);
\end{tikzpicture}}
\caption{Dependency graph of the seven central theorems.
Hypothesis structures (gray) feed the two sub-branch theorems
(blue, $k \leq 1322$ and $k > 1322$) and the bridge lemma
\texttt{sdw\_from\_cf} (yellow, dashed); the canonical theorem
\texttt{no\_nontrivial\_cycle\_final} sits at the right. The
bridge lemma converts \texttt{DerivedLargeKBound} into
\texttt{ProductBoundThreshold} under the standard hypotheses,
making the two formulations interderivable.}
\label{fig:depgraph}
\end{figure}
```

## Infrastructure lemmas (continued-fraction side)

Three dedicated modules formalize the classical continued-fraction theory
needed by §7 and by the Phase59 sub-branch `no_cycle_k_gt_1322`:

- **`ProjetCollatz/Phase60IrrationalityLog23.lean`** — irrationality of
  `log_2 3` and the corollary `2^s ≠ 3^k` for all `(s, k)` with `k ≥ 1`
  (used in the product-bound obstruction reasoning of §5).
- **`ProjetCollatz/Phase61CFConvergents.lean`** — convergents
  `Real.convergent log_2 3 n`, the denominators `q_n`, the window
  predicate `InWindow n k ↔ q_n ≤ k < q_{n+1}`, the bridge theorem
  `q_n_eq_den: (Real.convergent log_2 3 n).den = q_n`, and the
  far-approximation lemma `not_convergent_implies_far_approx`.
- **`ProjetCollatz/Phase62BestApproxBridge.lean`** — the public
  approximation bound `log23_abs_sub_convergent_le`, its parametric
  in-window variant `log23_abs_sub_convergent_le_in_window`, the
  wrapper `of_convs_eq_log23_convergent`, and non-termination of the
  continued-fraction expansion `log23_never_terminates`.

These continued-fraction infrastructure theorems have axiom profile
`[propext, Classical.choice, Quot.sound]` — the three standard Mathlib
kernel axioms, no more. They
are not in the central chain of `no_nontrivial_cycle_final` (which goes
via Phase58 directly); they are in the central chain of the variant
`no_nontrivial_cycle_phase59` via `no_cycle_k_gt_1322`.

## Arithmetic gap constants verified by `native_decide`

Six windows `W_8, ..., W_{13}` of continued-fraction denominators of
`log_2 3` (see §2.5 for numerical values) come with six "gap constants"
`cf_gap_n: ℕ` and six window-size bounds `cf_nbound_n: ℕ`, all proved
by Lean's `native_decide` tactic in
`ProjetCollatz/Phase59ContinuedFractions.lean`. Three of these are
sampled in the probe `probes/check_central_axioms.lean` (`cf_gap_8`,
`cf_gap_13`, `cf_nbound_8`); their axiom profile is
`[propext, Lean.ofReduceBool, Lean.trustCompiler]` — the three standard
`native_decide` axioms, and nothing else.

These twelve arithmetic lemmas are **isolated from the central chain**
at the current formalization state: they are consumed only through
`sdw_from_cf` (§8.1 table), which is itself called only through
`no_nontrivial_cycle_phase59`, not through `no_nontrivial_cycle_final`.
The isolation is recorded in `expected_axioms.md` (§8.6) and enforced
by `reproduce.sh` (§8.7). It is also the reason why the central chain
of `no_nontrivial_cycle_final` is kernel-3, despite the presence of the
`native_decide` axioms elsewhere in the project.

A forthcoming pass on the Phase63 skeleton (§8.4) would integrate the
gap constants directly into the central chain; such a pass is
structurally blocked by the obstruction of §5.

## The Phase63 skeleton

The file `ProjetCollatz/Phase63DerivedLargeKBoundTheorem.lean` (175
lines, **Section 1 only**, no `theorem` / `lemma` declarations)
preserves, as a documented skeleton, the architecture that would be
needed to promote the Phase59 structure `DerivedLargeKBound` from
hypothesis to theorem. Its Section 1 consists of:

- Imports (2 Mathlib + 5 Phase58-62 transitive dependencies);
- Namespace `ProjetCollatz.Phase63` and `open` declarations for the 12
  arithmetic constants `cf_gap_8..13` and `cf_nbound_8..13`;
- A detailed module docstring laying out the eleven-section architecture
  originally planned;
- A footer added at Commit #1 (`d41e2e9`) explicitly recording that
  Sections 2-11 are **not implemented** and redirecting to §5
  (Obstruction I) of this paper for the structural reason.

The skeleton is kept in the repository so that future readers trace the
original design; it **does not participate** in the central chain of
`no_nontrivial_cycle_final` or any of its aliases. The axiom profile of
the file (as a whole) is vacuous — no theorem is declared.

## Structural-excess framework (extension, separate branch)

Alongside the main formalization described above, a parallel Lean 4
effort develops a custom *structural-excess* framework `Φ_s / Ψ_s` for
quantifying deviations of cycle parity vectors from an i.i.d.-Bernoulli
null, motivated by the probabilistic discussion of §9. Because Mathlib
v4.27.0 lacks a native Gowers-norm library, this framework is
implemented from first principles in a dedicated module
`ProjetCollatz/PhaseVIII/StructuralExcess.lean`.

The extension is provided as the supplementary `PhaseVIII/`
sub-directory of the accompanying repository. It is **not** part of
the central proof chain that carries this paper's main theorem and
its kernel-3 axiom profile verification; it sits alongside, with a
clearly separated namespace and probe.

The extension contains: parametric definitions of $\Phi_s$ and
$\Psi_s$; a machine-verified evaluation of the trivial Collatz
cycle as `trivialCycle_psi2: ... = 32/81 := by native_decide`,
establishing a concrete non-zero structural excess on the unique
known cycle of the $3x+1$ map; a parametric `Prop` definition for
the T4c conjecture of §9; a contradiction schema
`psi2_bounds_no_cycle` showing how a future T4c proof would
discharge the cycle problem; and an axiom-audit probe confirming
**zero new user axioms**, which leaves the extension's axiom
profile at the standard kernel three plus the two `native_decide`
axioms inherited from the one `trivialCycle_psi2` evaluation.

Nothing in §1-§7 depends on the `PhaseVIII/` extension; its status
is purely supplementary. The reader interested in the
structural-excess viewpoint is referred to §9 for the mathematical
framing and to `ProjetCollatz/PhaseVIII/` for the Lean source.

## Expected axiom profile (`expected_axioms.md`)

The project publishes a reference snapshot of the `#print axioms`
baseline at the repository root, file `expected_axioms.md`. Its
Section 1 lists the *central* theorems (as in §8.1) with expected
axiom set `[propext, Classical.choice, Quot.sound]`. Its Section 2
lists three sampled auxiliary `native_decide` lemmas with expected
set `[propext, Lean.ofReduceBool, Lean.trustCompiler]`. The
remaining sections document the out-of-scope structures and the
forbidden-axiom patterns enforced by the probe.

The baseline is enforced by the probe `probes/check_central_axioms.lean`
(plus the dedicated Phase-level probes `check_phase60..63_axioms.lean`),
and any deviation triggers a non-zero exit from `reproduce.sh`.

## Reproducibility (`reproduce.sh`)

A single shell script at the repository root encapsulates the full
verification pipeline:

```bash
bash reproduce.sh
# 0: all checks PASS
# 1: toolchain mismatch (lean-toolchain / elan)
# 2: Lean build error or sorry-related warning
# 3: axiom drift (unexpected or missing axiom vs expected_axioms.md)
# 4: sorryAx detected in the central or auxiliary chain
```

The five steps of the script are (i) toolchain check, (ii) Mathlib
cache fetch, (iii) `lake build ProjetCollatz`, (iv) axiom probe on
**25 theorems** (7 central + 3 auxiliary + 15 M3 foundational), and
(v) sorry probe. On a fresh clone with cache available, the total
runtime is of the order of 3-5 minutes (incremental: 10 seconds);
on a from-source build without cache, of the order of 90 minutes.
The Continuous-Integration workflow at `.github/workflows/verify.yml`
runs the same checks on every push and pull-request.

## Integrity invariants

The following project-wide invariants are enforced by the combination
of the probes, `reproduce.sh`, and the project's review protocol:

- **No user `axiom` declaration.** No file in `ProjetCollatz/` introduces
  a new axiom; the only axioms in the transitive closure are the
  Mathlib kernel axioms listed in §8.6.
- **No `sorry`, `admit`, or `stop`.** Every declaration has a complete
  proof term; the `sorryAx` probe (`probes/check_sorry.lean`) is run
  as a separate step by `reproduce.sh` for defense in depth.
- **All docstrings are in English.**

These are enforced per-commit and recorded in the project's
development journal.

