# Structural obstructions II: state-of-the-art mapping ($\delta 9$)

We document the state of the art on Collatz cycle non-existence as of
2026, identifying a structural gap ("δ9"): no published peer-reviewed
result provides a deterministic upper bound on $k$ (the number of
odd steps) for general Collatz cycles. Our `ProductBoundThreshold`
hypothesis (§4.3) is therefore a project-specific encoding rather
than a citation, and §5's $\delta 8 / \delta 8'$ impossibility
lemmas explain why this gap is structural rather than incidental.

## Historical lower bounds on k for hypothetical cycles

| Author | Year | Method | Bound |
|--------|------|--------|-------|
| Crandall | 1978 | CF + $n_0$ bound | $k > (3/2) \cdot \min(q_j, 2 n_0 / (q_j + q_{j+1}))$ |
| Steiner | 1977 | Baker effective + CF | Circuits $\to$ only trivial cycle |
| Eliahou | 1993 | Refined CF bookkeeping | $k > 17{,}087{,}915$ |
| Applegate-Lagarias | 1995 | Density bounds | density $\gamma > 0.81$ |
| Krasikov-Lagarias | 2003 | Difference inequalities | density $\gamma \geq 0.84$ |
| Simons-de Weger | 2005 | LFL + CF iterations | local-minima $m > 68$ |
| Barina | 2025 | Computational, $X_0 = 2075 \cdot 2^{60} \approx 2^{71.02}$ | Provides bound for above |
| Hercher | 2023 | Iterative refinement (post-SdW) | $K > 1.375 \cdot 10^{11}$ (SOTA) |

These are all *lower* bounds on `k`: they assume hypothetical cycles
exist and place arithmetic constraints on their parameters. None
bounds `k` from above.

**Note on Hercher 2023's invariants.** Hercher's main theorem
(Theorem 23, *"There are no Collatz m-Cycles with $m \leq 91$"*)
bounds the **number of local minima** in a hypothetical cycle:
$m \geq 92$, where $m$ follows the **Simons-de Weger (2005)
convention**. This $m$ is *not* the number of odd steps and is
therefore not directly comparable to this paper's $k$. Separately,
Hercher's Corollary 29 (via the auxiliary Theorem 27) bounds $K$,
defined as the number of odd elements in the cycle:
$K \geq 1.375 \cdot 10^{11}$, conditional on
$X_0 \geq 1536 \cdot 2^{60}$. Hercher's $K$ therefore *coincides
with this paper's* $k$, the number of odd steps (since each odd
element of the cycle is visited exactly once per period, generating
exactly one application of the odd-step map $3n + 1$). The
numerical comparisons in §5.2 and §7.2 below use Corollary 29's
$K = k > 1.375 \cdot 10^{11}$ directly.

## Structural class eliminations (restricted classes of cycles)

- **Steiner** (1977): circuits (cycles with one positive-to-maximum
  segment + one maximum-to-minimum descent) → only trivial cycle.
- **Knight** (2026, *Discrete Mathematics* 349(3), 114812):
  Collatz "high cycles" → do not exist *(bibliographic record
  Crossref-verified; full article behind Elsevier paywall;
  Knight's specific definition of "high cycle" is not invoked
  by the present paper, and the citation is at the level of the
  published title only — see reference [19] note)*.

Neither result extends to general $m$-cycles with $m \geq 2$ in
the published form. Iterating restricted-class eliminations to
cover all parity patterns faces combinatorial explosion.

## Meta-impossibility results

- **Our δ8 + δ8'** (this paper §5): Baker + CF approaches yield
  *lower* bounds on `k`, never uniform upper bounds.
- **Dhiman-Pandey** (2026, arXiv:2601.12772): Presburger / 2-adic
  approaches are impossible (orthogonal framework, see §5.3).

## Recent reformulation attempts (insufficient alone)

- **Santana** (2026, arXiv:2601.03297v4): topological / ergodic
  reformulation. Proves conditional finiteness (Theorem B) under a
  boundedness hypothesis on continuous integrable potentials. Three
  structural gaps in the published proof, documented by direct
  verification of arXiv:2601.03297v4: (i) the boundedness
  assumption on the integrals `∫φ dδᵢ` of ergodic measures is not
  justified in the proof of Theorem B; (ii) Lemma 14 (finiteness)
  and Lemma 16 (uniqueness) are not equivalent under Santana's
  coarser topology *T* (without Alexandroff compactification);
  (iii) Remark 17 in Santana (2026) explicitly disclaims:
  *"In Lemma 16 we address an alternative approach of the
  conjecture, rather than a proof of it."* No quantitative bounds
  on `n₀` or `k`. The framework is *complementary* to our Baker + CF
  approach but cannot substitute for the `ProductBoundThreshold`
  hypothesis.
- **Honarvar Shakibaei Asli** (2026, arXiv:2601.04289):
  near-conjugacy to circle rotation. The author explicitly states
  that any resolution of the Collatz conjecture would require
  additional arithmetic arguments.
- **Rozier-Terracol** (2026, arXiv:2502.00948): paradoxical
  sequences approach (Theorem 1.1), uses Rhin Proposition 6.3
  heuristically. The framework is independent of our Baker + CF
  approach.

## Probabilistic / density results (not deterministic)

- **Terras** (1976): almost all integers have finite stopping time.
- **Tao** (2019/2022): almost all Collatz orbits attain almost
  bounded values (cf. Tao, *Almost all orbits of the Collatz map
  attain almost bounded values*, *Forum of Mathematics, Pi* 10 (2022), e12).

These are probabilistic / density-theoretic results: they do not
provide deterministic statements about every cycle. See §9.6 for
Tao's explicit framing of the cycle problem as still open.

## Gap identified (δ9)

To the best of our literature review (17 peer-reviewed papers
consulted + 5 recent preprints, as of April 2026):

> **No peer-reviewed result provides a deterministic upper bound on
> `k` (the number of odd steps) for general Collatz cycles.**

The `ProductBoundThreshold` hypothesis of §4.3 is therefore a
**project-specific encoding** of the Product Bound + Barina chain,
rather than a direct citation of any published theorem. This
transparency is maintained throughout our paper to avoid
misattribution to peer-reviewed results. See §5 for the structural
reason ($\delta 8 / \delta 8'$) why this gap is unlikely to close
via standard Diophantine refinements.

## Comparison with the 2026 literature

The 2026 reformulation attempts (cf. §6.4) and the present paper
each address the cycle problem from a distinct methodological
angle. The table below summarizes their position relative to four
key dimensions: framework, whether they yield a *deterministic
upper bound on cycle length* $k$, whether they discharge our
`ProductBoundThreshold` hypothesis, and their peer-review status
as of April 2026.

```{=latex}
{\footnotesize
\begin{tabular}{@{}p{0.20\linewidth}p{0.21\linewidth}p{0.16\linewidth}p{0.20\linewidth}p{0.15\linewidth}@{}}
\toprule
\textbf{Reference} & \textbf{Framework} & \textbf{Det.\ upper bound on $k$?} & \textbf{Discharges \texttt{ProductBoundThreshold}?} & \textbf{Peer-reviewed} \\
\midrule
Santana 2026 \newline (arXiv:2601.03297v4) &
Topological / ergodic &
No (qualitative finiteness only) &
No (independent) &
Preprint \\
\addlinespace
Honarvar 2026 \newline (arXiv:2601.04289) &
Near-conjugacy with circle rotation &
No &
No (acknowledged by author) &
Preprint \\
\addlinespace
Rozier–Terracol 2025 \newline (arXiv:2502.00948) &
Paradoxical sequences (Rhin heuristic) &
No &
No (independent) &
To appear, \emph{Discrete Math.} 349 (2026) \\
\addlinespace
Dhiman–Pandey 2026 \newline (arXiv:2601.12772) &
2-adic Presburger obstruction &
No (negative result) &
No (orthogonal) &
Preprint \\
\addlinespace
\textbf{This paper} &
\textbf{Baker + CF + Product Bound} &
\textbf{Yes ($k \leq 982$, conditional)} &
\textbf{Encodes it} &
\textbf{In review} \\
\bottomrule
\end{tabular}}
```

None of the 2026 contributions surveyed yields a deterministic
upper bound on $k$ for general Collatz cycles, confirming the
$\delta 9$ gap claim in §6.6. The present paper is the only one in
the survey that exposes a specific cycle-length bound as a
formalized Lean hypothesis; the obstruction lemmas of §5 explain
why this hypothesis cannot be promoted to a theorem within the
Baker + continued-fraction framework.

