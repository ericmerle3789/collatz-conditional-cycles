# Numerical verification of the cycle-length thresholds

This appendix exhibits the high-precision numerical certificates
that anchor the threshold values used throughout the paper. All
computations are performed at $50$-digit decimal precision via the
`mpmath` Python library; the specific numerical claims correspond
to Lean lemmas closed by `native_decide` and are recorded under
their `cf_gap_*`, `cf_nbound_*`, `k982_bound`, and
`product_bound_fits_barina_1322` names in
`ProjetCollatz/Phase56*.lean` and `Phase58*.lean`.

## Conservative threshold $k \leq 982$

The `ProductBoundThreshold` parameter (§4.3) fixes the conservative
value:
$$
\frac{982^7 + 982}{3} = 2.93534504905515 \cdots \times 10^{20}
\;<\; 2^{71} = 2.36118324143482 \cdots \times 10^{21}.
$$
The $\approx 8\times$ safety margin is visible: $2^{71}$ is roughly
eight times larger than $(982^7 + 982)/3$. This certifies the Lean
lemma `k982_bound` (Phase56, line 249), which is stated in the
equivalent multiplicative form $982^7 + 982 < 3 \cdot 2^{71}$ over
$\mathbb{N}$ to allow direct `native_decide` evaluation without
rational arithmetic.

## Optimal threshold $k \leq 1322$

The Lean theorem `no_cycle_k_le_1322` (Phase58, line 134) covers
the optimal range, certified by:
$$
\frac{1322^7 + 1322}{3} = 2.35233370497325 \cdots \times 10^{21}
\;<\; 2^{71} = 2.36118324143482 \cdots \times 10^{21}
\;<\; \frac{1323^7 + 1323}{3} = 2.36481763080817 \cdots \times 10^{21}.
$$
As with the conservative case, the corresponding Lean lemma
`product_bound_fits_barina_1322` (Phase58, line 122) is stated in
the equivalent multiplicative form $1322^7 + 1322 < 3 \cdot 2^{71}$.
The optimal value $1322$ saturates the inequality
$(k^7 + k)/3 < 2^{71}$ on the integer side; $1323$ is the smallest
integer for which it fails.

## Salikhov closure $k \leq 3693$

Under the Salikhov 2007 sharper exponent $c = 5.125$, the Product
Bound formula $(k^{c+1} + k)/3 < 2^{71}$ closes the larger range
$k \leq 3693$:
$$
\frac{3693^{6.125} + 3693}{3} = 2.36089680607476 \cdots \times 10^{21}
\;<\; 2^{71}
\;<\; \frac{3694^{6.125} + 3694}{3} = 2.36481517339814 \cdots \times 10^{21}.
$$
The $\approx 2.8\times$ improvement over the Baker $\mu = 6$
threshold $1322$ is the contribution of Salikhov's bound; further
refinement to Wu's (2003) sharper $c = 5.117$ improves this only
marginally. None of these thresholds reach Hercher's lower bound
$K > 1.375 \cdot 10^{11}$, illustrating the structural obstruction
of Lemma \ref{lem:productbound}.

## Continued-fraction convergents of $\log_2 3$

The seven convergents $q_n$ of $\log_2 3$ used in §2.5, §5.2, §8.3,
and §9.2 are all directly computable from the standard CF expansion
$\log_2 3 = [1; 1, 1, 2, 2, 3, 1, 5, 2, 23, 2, 2, 1, 1, 55, \ldots]$:

```{=latex}
\begin{center}
\begin{tabular}{@{}c r r@{}}
\toprule
$n$ & $p_n$ & $q_n$ \\
\midrule
8  & 1{,}054      & 665           \\
9  & 24{,}727     & 15{,}601      \\
10 & 50{,}508     & 31{,}867      \\
11 & 125{,}743    & 79{,}335      \\
12 & 176{,}251    & 111{,}202     \\
13 & 301{,}994    & 190{,}537     \\
14 & 16{,}785{,}921 & 10{,}590{,}737 \\
\bottomrule
\end{tabular}
\end{center}
```

The large jump $q_{13} \to q_{14}$ is governed by the partial
quotient $a_{14} = 55$ in the CF expansion. These convergents are
formalized in `ProjetCollatz/Phase61CFConvergents.lean` and used by
the gap constants `cf_gap_8` to `cf_gap_13` in
`Phase59ContinuedFractions.lean` (lines 128-153).

## Logarithmic ratio in the appendix bound

Theorem \ref{thm:Aone} requires the strict positivity of
$\log_2(3 / 2.836)$:
$$
\log_2(3 / 2.836) = 0.0811049681 \cdots > 0.
$$
This is the small-but-positive constant whose exponential growth
$(3/2.836)^k$ dominates the polynomial $k^{4.125}$ for $k$ above a
threshold safely below Hercher's $1.375 \cdot 10^{11}$.

## Reproducibility

Each numerical claim in this appendix can be reproduced by a
five-line `mpmath` script with `mp.dps = 50`. The corresponding
Lean lemmas are closed by `native_decide` (working at exact
integer or rational arithmetic, not at floating-point precision)
and are exhibited in their named modules in `ProjetCollatz/`.
