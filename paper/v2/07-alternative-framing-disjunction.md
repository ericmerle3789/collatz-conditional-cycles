# Alternative framing via disjunction (δ7)

The conditional Theorem 3.1 admits a logically equivalent disjunctive
reformulation that frames the conditionality structurally rather than
operationally. This section presents the disjunctive form ("δ7") and
its interpretation under current SOTA bounds.

## Statement

Theorem \ref{thm:main} is logically equivalent to the disjunctive
statement below.

```{=latex}
\begin{reformulation}[Equivalent disjunctive form, $\delta 7$]
\label{ref:disjunction}
Under the three structural hypotheses of §4 (\texttt{BakerSeparation},
\texttt{BarinaVerification}, \texttt{ProductBoundThreshold}), for
every non-trivial Collatz cycle $(n, k)$ one has $k \leq 1322$ or
$n > 2^{71}$.
\end{reformulation}
```

```{=latex}
\begin{proof}
The reformulation is logically equivalent to Theorem \ref{thm:main}
under the same three structural hypotheses; it is a presentational
restatement, not an independent result.

\smallskip
\noindent\textit{Forward direction (Theorem \ref{thm:main} implies
Reformulation \ref{ref:disjunction}).} Theorem \ref{thm:main} says
no non-trivial cycle exists, so the disjunction holds vacuously over
the empty set of cycles.

\smallskip
\noindent\textit{Converse (Reformulation \ref{ref:disjunction}
implies Theorem \ref{thm:main}).} Assume the disjunction holds for
any hypothetical cycle $(n, k)$. If $k \leq 1322$, the optimal Lean
theorem \texttt{no\_cycle\_k\_le\_1322} (Phase58, using
\texttt{BakerSeparation} and \texttt{BarinaVerification}) yields a
direct contradiction. If instead $n > 2^{71}$, the
\texttt{ProductBoundThreshold.cycle\_length\_bound} hypothesis gives
$k \leq 982 < 1322$, reducing to the first case.
\end{proof}
```

The threshold `k ≤ 1322` is the optimal Lean threshold:
`(1322⁷ + 1322)/3 < 2⁷¹ < (1323⁷ + 1323)/3` (verified by
`native_decide` in `product_bound_fits_barina_1322`, Phase58).

## Interpretation

Theorem 7.1 is **vacuously true** under the Collatz no-cycle
conjecture. The disjunction `k ≤ 1322 ∨ n > 2⁷¹` partitions
hypothetical cycles into two regimes:

- Low cycle complexity (`k ≤ 1322`) — closed unconditionally by the
  optimal Lean theorem `no_cycle_k_le_1322` under
  `BakerSeparation + BarinaVerification`, OR
- High cycle complexity (`k > 1322`) and `n > 2⁷¹` — closed under
  `ProductBoundThreshold` (which forces `k ≤ 982 < 1322` for any
  cycle, reducing to the first regime) but lying outside current
  *unconditional* methods.

The two cases not made explicit by the disjunction
($k \leq 1322$ with $n > 2^{71}$, and $k > 1322$ with $n \leq 2^{71}$)
are also ruled out — by `no_cycle_k_le_1322` and by Barina's
verification respectively — so the four quadrants of
$(k \text{ vs } 1322) \times (n \text{ vs } 2^{71})$ are jointly
covered.

**Barina (2025)** rules out the first disjunct: every positive
integer $n < 2^{71}$ reaches $1$, so no Collatz cycle with
$n < 2^{71}$ exists. (The boundary case $n = 2^{71}$ is
automatically excluded: `IsOddCycle n k` requires $n$ odd, while
$2^{71}$ is even, so a cycle starting point cannot equal
$2^{71}$.)

**Hercher (2023) Corollary 29.** Independently, Hercher
establishes $K > 1.375 \cdot 10^{11}$ *conditional on*
$X_0 \geq 1536 \cdot 2^{60} = 3 \cdot 2^{69} \approx 1.77 \cdot 10^{21}$,
where Hercher's $K$ is identified with this paper's $k$ (§6.1
note). The Hercher condition $X_0 \geq 1536 \cdot 2^{60}$ is
strictly above $2^{71}$ ($1536 \cdot 2^{60} \approx 2^{71.58}$),
so Hercher's bound is **silent on the regime $n \leq 2^{71}$
already covered by Barina** and applies only in the regime
$n > 2^{71}$, which is precisely the second disjunct of the
reformulation. Within that second disjunct (and only there),
Hercher's bound provides corroborative information by ruling out
small-$k$ instances: any cycle with $n > 2^{71}$ and
$X_0 \geq 1536 \cdot 2^{60}$ must have $k > 1.375 \cdot 10^{11}$,
eight orders of magnitude above the optimal Lean threshold
$1322$. Hercher therefore does not close the second disjunct
(which would require either $X_0 < 1536 \cdot 2^{60}$ to be
ruled out, or a deterministic upper bound on $k$ in the regime
$n > 2^{71}$); it constrains its low-$k$ corner. Combined with
our optimal Lean theorem `no_cycle_k_le_1322`, the first
disjunct of Reformulation \ref{ref:disjunction} is closed; the
only remaining configuration is the second disjunct
($k > 1322$, $n > 2^{71}$), which is outside current methods.

**Consistency check.** `n > 2⁷¹` is **outside** current peer-reviewed
verification (Barina's `2⁷¹` is the SOTA). Any future extension of
Barina (or equivalent) to `n > 2⁷¹` would directly test hypothetical
cycles against our framework.

A finer-grained six-window continued-fraction refinement of the
high-complexity disjunct (`k ∈ W_8 ∪ … ∪ W_{13}` for the cycle-bound
range `k > 1322`) is documented as a Lean skeleton in
`ProjetCollatz/Phase63DerivedLargeKBoundTheorem.lean` (see §8); the
non-completion of that skeleton meets the structural obstruction of
§5 (δ8 / δ8'), which explains why the conditional theorem cannot be
closed unconditionally via further Diophantine refinement within the
Baker + CF paradigm.

