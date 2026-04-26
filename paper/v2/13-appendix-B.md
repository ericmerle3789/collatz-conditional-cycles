# Lean axiom profile and reproduction contract

This appendix promotes the contents of `expected_axioms.md` from
the accompanying repository into a self-contained reference for the
paper. The axiom profile of the central theorem chain — the seven
theorems of §8.1 — is fixed at the kernel-3 baseline of Mathlib,
with no user-declared axioms and no `sorry`. Auxiliary
`native_decide` lemmas live in a separate axiom class, and are
explicitly excluded from the central chain at the present
formalization state.

## Central theorem chain

For each of the seven theorems below, `#print axioms` reports
exactly the three standard Mathlib kernel axioms `propext`,
`Classical.choice`, `Quot.sound`. The chain is the formal
counterpart of §3.2's six-step proof.

All seven theorems live in the namespace `ProjetCollatz`; the
namespace prefix is omitted in the table for brevity. The expected
axiom set is identical for all seven and corresponds to the
standard Mathlib kernel triple — written below in shorthand as
$K_3$ for `[propext, Classical.choice, Quot.sound]`.

```{=latex}
{\small
\begin{tabular}{@{}p{0.31\linewidth}p{0.10\linewidth}p{0.50\linewidth}@{}}
\toprule
\textbf{Theorem} & \textbf{Axioms} & \textbf{Role} \\
\midrule
\texttt{no\_nontrivial\_cycle\_phase59} & $K_3$ & Principal central theorem (CF-side packaging) \\
\texttt{no\_nontrivial\_cycle\_final}   & $K_3$ & Canonical form (version stated in §3.1) \\
\texttt{no\_nontrivial\_cycle\_derived} & $K_3$ & Variant via \texttt{ExternalCycleHypothesesDerived} \\
\texttt{no\_nontrivial\_cycle\_full}    & $K_3$ & Foundation form via \texttt{ExternalCycleHypothesesFull} \\
\texttt{no\_cycle\_k\_le\_1322}         & $K_3$ & Sub-branch $k \leq 1322$ (Baker + Barina) \\
\texttt{no\_cycle\_k\_gt\_1322}         & $K_3$ & Sub-branch $k > 1322$ (CF + Barina) \\
\texttt{sdw\_from\_cf}                  & $K_3$ & Bridge \texttt{DerivedLargeKBound} $\to$ \texttt{ProductBoundThreshold} \\
\bottomrule
\end{tabular}}
```

All three of the kernel axioms above (`propext`,
`Classical.choice`, `Quot.sound`) are standard Mathlib axioms,
required by any non-constructive theorem using classical reasoning
and quotient types. No `axiom` declaration appears anywhere in
`ProjetCollatz/`.

**Phase63 skeleton — clarification.** The file
`Phase63DerivedLargeKBoundTheorem.lean` contains a forward-looking
docstring describing a hypothetical M3 integration that would
extend the central-chain axiom profile with `Lean.ofReduceBool`
and `Lean.trustCompiler`. That integration is *not* realized at
the present commit: Sections 2-11 of the file are explicitly
marked "not implemented", no theorem is declared, and Phase63 does
not appear in the import closure of any of the seven central
theorems above. The kernel-3 baseline of this appendix is
therefore unaffected by the Phase63 docstring; see §8.5 for the
expanded discussion.

## Auxiliary `native_decide` lemmas (sampled)

Three sampled members of a broader family of arithmetic-gap lemmas
are verified via Lean's `native_decide` tactic. Their axiom profile
is the standard `native_decide` triple, distinct from the kernel-3
profile of the central chain:

Writing $N_3$ for `[propext, Lean.ofReduceBool, Lean.trustCompiler]`
(the standard `native_decide` axiom triple):

```{=latex}
{\small
\begin{tabular}{@{}p{0.25\linewidth}p{0.10\linewidth}p{0.55\linewidth}@{}}
\toprule
\textbf{Theorem} & \textbf{Axioms} & \textbf{Role} \\
\midrule
\texttt{cf\_gap\_8}    & $N_3$ & CF window 8 arithmetic gap \\
\texttt{cf\_gap\_13}   & $N_3$ & CF window 13 arithmetic gap \\
\texttt{cf\_nbound\_8} & $N_3$ & CF window 8 cycle-element bound \\
\bottomrule
\end{tabular}}
```

**Isolation property.** These lemmas are *not* in the transitive
axiom chain of `no_nontrivial_cycle_phase59`, because
`DerivedLargeKBound` is a `structure` taken as a parameter by the
central theorem. The `cf_gap_*` and `cf_nbound_*` lemmas are the
mathematical justification of the structure's content (detailed
algebraically in §4.1 and verified arithmetically here) but are not
composed into the structure's *Lean* proof at the current
formalization state. This isolation is what allows the central
chain to remain at the kernel-3 baseline while the project as a
whole uses `native_decide` extensively. See §8.3 and §8.4.

## Forbidden patterns enforced by `reproduce.sh`

The reproduction script (§8.7) parses the output of
`probes/check_central_axioms.lean` and `probes/check_sorry.lean`
against this baseline. Any deviation triggers a non-zero exit:

- `sorryAx` in any probed theorem $\to$ EXIT 4 (incomplete proof).
- Any user-declared `axiom` not listed above $\to$ EXIT 3
  (unexpected axiom).
- Any unlisted axiom from a transitive dependency $\to$ EXIT 3
  (dependency drift).

A successful run (`EXIT 0`) certifies that the central chain is
machine-verified under the kernel-3 baseline at the recorded commit
hash.
