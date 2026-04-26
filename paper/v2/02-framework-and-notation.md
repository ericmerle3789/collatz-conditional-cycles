# Framework and notation

## The Collatz map, the odd iterate, and odd cycles

The **Collatz map** `T: ℕ_{≥1} → ℕ_{≥1}` is defined by
`T(n) = n/2` when `n` is even, and `T(n) = (3n+1)/2` when `n` is odd.
The **odd iterate** `T_odd` compresses the halvings: starting from an
odd integer, `T_odd(n)` is the unique odd integer on the Collatz
trajectory of `n` reached after exactly one `3n+1/2` step followed by
all consecutive halvings. In the Lean 4 formalization accompanying
this paper `T_odd` is written `syracuseNext`, and its iterate is the
function `nSeq: ℕ → ℕ → ℕ` of `ProjetCollatz/SyracuseDefs.lean` line 213,
defined by `nSeq start 0 = start` and `nSeq start (k+1) = syracuseNext (nSeq start k)`.

```{=latex}
\begin{definition}[Odd Collatz cycle]
\label{def:oddcycle}
A pair $(n, k)$ of natural numbers is an \emph{odd Collatz cycle} if
$n > 1$, $n$ is odd, $k \geq 1$, and $\mathtt{nSeq}\, n\, k = n$.
\end{definition}
```

This corresponds to the predicate `IsOddCycle` of
`ProjetCollatz/Phase50CycleEquation.lean` lines 27-28:

```lean
def IsOddCycle (n: ℕ) (k: ℕ): Prop :=
  n > 1 ∧ n % 2 = 1 ∧ k ≥ 1 ∧ nSeq n k = n
```

The exclusion `n > 1` removes the trivial fixed orbit at `1`; every
reference below to "cycle" means *odd Collatz cycle* in this sense.
The cycle problem is the negative claim: no such `(n, k)` exists.

## Parity vectors, the sum of halving exponents, and Steiner's identity

Fix an odd Collatz cycle $(n, k)$. Write $n_i := \mathtt{nSeq}\, n\, i$
for $0 \leq i \leq k$, so that $n_0 = n_k = n$ and each $n_i$ is odd.
Between $n_i$ and $n_{i+1}$ there is exactly one $(3n+1)/2$ step
followed by some number $s_{i+1} \geq 0$ of halvings, called the
$i$-th *parity exponent*. The list $(s_1, \ldots, s_k)$ is the
*parity vector* of the cycle, and $s := s_1 + \cdots + s_k$ its
*sum of halving exponents*.

Collecting all $k$ odd steps yields **Steiner's cycle identity**:
$$
n \cdot (2^s - 3^k) \;=\; C_{n, k, s},
$$
where
$$
C_{n, k, s} \;=\; \sum_{i=1}^{k} 3^{\,k-i}\, 2^{\,s_1 + \cdots + s_{i-1}}
$$
is a strictly positive integer (the "corrective sum"). The identity
is the discrete analogue of log-linearity of the Collatz dynamics
and is the conventional entry point to Baker-style arguments. Its
Lean formalization is in `ProjetCollatz/Phase52SteinerEquation.lean`
(`corrSum`, `steiner_eq`, `steiner_cycle_eq`, `corrSum_pos_of_cycle`,
lines 101-150).

A direct consequence of Steiner's identity is that $2^s > 3^k$ for
any hypothetical non-trivial cycle (else the right-hand side would
be non-positive), so $s = \lceil k \cdot \log_2 3 \rceil$ whenever
the cycle is compatible with the ambient inequality framework. This
is the bridge to continued-fraction approximation theory (§7).

## The three structural hypotheses

Our central theorem depends on three `structure` fields, all declared
in `ProjetCollatz/Phase58PorteDeuxFinal.lean`.[^porte-deux]

[^porte-deux]: Module names follow the project's bilingual French/English convention (e.g., "PorteDeux" = "Door Two"); mathematical content is unaffected.

### `BakerSeparation` (Phase58, lines 67-69) {.unnumbered}

```lean
structure BakerSeparation where
  separation : ∀ (s k : ℕ), s ≥ 1 → k ≥ 2 → 2^s > 3^k →
    (2^s - 3^k) * k^6 ≥ 3^k
```

This is the effective version of Baker's 1966 theorem specialized to
the cycle problem, at irrationality-measure exponent $\mu = 6$ — a
strictly weaker constant than Salikhov's (2007) sharper bound
$\mu(\ln 3) \leq 5.125$ (refining Rhin's 1987 linear-form bound),
but sufficient for our derivation and straightforward to state.
See §4.1.

### `BarinaVerification` (Phase58, lines 80-81) {.unnumbered}

```lean
structure BarinaVerification where
  convergence: ∀ (n: ℕ), n > 0 → n < 2^71 → reaches_one n
```

Barina's 2025 computational verification that every positive integer
below $2^{71}$ ultimately reaches $1$. See §4.2.

### `ProductBoundThreshold` (Phase58, lines 296-297) {.unnumbered}

```lean
structure ProductBoundThreshold where
  cycle_length_bound: ∀ (n k: ℕ), IsOddCycle n k → k ≤ 982
```

This is the third hypothesis. Its origin is derived, not taken from
a single published paper: combining the Product Bound lemma of
`ProjetCollatz/Phase56*.lean`, which states $m \leq (k^7 + k)/3$ for
a cycle minimum $m$ (a consequence of Baker's separation inequality),
with Barina's limit $2^{71}$ yields the optimal threshold
$k \leq 1322$, certified by the arithmetic inequality
$$
(1322^7 + 1322)/3 \;<\; 2^{71} \;<\; (1323^7 + 1323)/3.
$$
The structure parameter is fixed at the conservative value
$k \leq 982$ (an $\approx 8\times$ safety margin below the optimal
threshold), which produces the simpler arithmetic certificate
$(982^7 + 982)/3 < 2^{71}$. Both bounds (the optimal $1322$ and the
conservative $982$) are mechanically verified: the former by
`product_bound_fits_barina_1322` and the latter by `k982_bound`,
both in Phase56-58 via `native_decide`.
The derivation is honest and transparent, but the promotion of this
hypothesis to a theorem is structurally blocked: this is the content
of §5. See also `ProjetCollatz/HYPOTHESES.md` in the accompanying
repository for the full derivation chain. Throughout this paper, $k$
denotes the number of odd steps in the cycle, and $m$ denotes the
**cycle minimum integer** (smallest odd element of the cycle); this
$m$ notation appears in §3.2 step 1 and corresponds to the Phase56
lemma `cycle_has_min`. Note that Simons-de Weger (2005) use $m$ for
a distinct quantity (number of local minima in the cycle); their
convention is not adopted here, and their bound $m > 68$ is
reproduced verbatim in §6.1 with explicit author attribution.

## The central theorem (forward pointer)

**Theorem (informal statement, see §3 for the formal version).**
Assume `BakerSeparation`, `BarinaVerification`, and
`ProductBoundThreshold`. Then there is no odd Collatz cycle in the
sense of Definition 2.1.

In the Lean formalization this is
`ProjetCollatz.no_nontrivial_cycle_final` in
`ProjetCollatz/Phase58PorteDeuxFinal.lean` line 339. Its proof is
discharged in six elementary steps, recorded verbatim in §3 and
documented with line numbers in §8.

## Notation conventions

- $\log_2 3$ denotes the real number `Real.logb 2 3` of Mathlib 4.
- Continued-fraction convergents of $\log_2 3$ are written $p_n / q_n$
  with $q_n \in \mathbb{N}_{\geq 1}$ the denominator; these correspond
  to the Lean-side notation `q_n` of
  `ProjetCollatz/Phase61CFConvergents.lean`.
- The six *windows* used in §7 are defined by
  $W_n := [q_n, q_{n+1})$ for $n \in \{8, 9, 10, 11, 12, 13\}$, the
  predicate `InWindow n k ↔ q_n ≤ k < q_{n+1}` being the Lean
  abbreviation of
  `ProjetCollatz/Phase61CFConvergents.lean`.
- Numerical values: $q_8 = 665$, $q_9 = 15{,}601$,
  $q_{10} = 31{,}867$, $q_{11} = 79{,}335$, $q_{12} = 111{,}202$,
  $q_{13} = 190{,}537$, $q_{14} = 10{,}590{,}737$ (Phase59
  `cf_nbound_*` constants).
- `reaches_one` is the Lean abbreviation for "the Collatz trajectory
  starting at $n$ eventually hits $1$"; used in the
  `BarinaVerification` field and in the contradiction-on-cycle proof.

All other symbols introduced later are local to their section.

## Summary of the three structural hypotheses

The three structural hypotheses underlying the conditional theorem
of §3 are summarized below. Their mathematical and bibliographic
context is detailed in §4; their formal Lean signatures are quoted
verbatim in §2.3.

```{=latex}
{\small
\begin{tabular}{@{}p{0.21\linewidth}p{0.20\linewidth}p{0.18\linewidth}p{0.32\linewidth}@{}}
\toprule
\textbf{Symbol} & \textbf{Origin} & \textbf{Status} & \textbf{Mathematical content} \\
\midrule
\texttt{BakerSeparation} &
Baker (1966), Rhin (1987), Matveev (2000) &
Published; not Lean-formalized &
$(2^s - 3^k)\, k^6 \geq 3^k$ for $s \geq 1,\ k \geq 2,\ 2^s > 3^k$ \\
\addlinespace
\texttt{BarinaVerification} &
Barina (2025) &
Computational; not Lean-formalized &
$\forall n > 0.\ n < 2^{71} \Rightarrow \mathtt{reaches\_one}(n)$ \\
\addlinespace
\texttt{ProductBoundThreshold} &
Project-derived (§4.3) &
Hypothesis; obstruction in §5 &
$\forall n, k.\ \mathtt{IsOddCycle}(n, k) \Rightarrow k \leq 982$ \\
\bottomrule
\end{tabular}}
```

The three hypotheses are exhibited as Lean `structure` parameters
of `no_nontrivial_cycle_final` (§3.1, §8.1); the conditional theorem
is independent of the *content* of these structures, depending only
on their declared signatures.

## Notation index

For ease of reference, the principal symbols introduced in this
section and used recurrently throughout the paper are collected
here.

| Symbol | Meaning | First occurrence |
|--------|---------|------------------|
| $T$ | Collatz map $T: \mathbb{N}_{\geq 1} \to \mathbb{N}_{\geq 1}$ | §1.1 |
| $T_{\mathrm{odd}}$ | Odd iterate (compresses halvings) | §1.1 |
| `nSeq` | Lean encoding of $T_{\mathrm{odd}}^k$ | §2.1 |
| `IsOddCycle` | Lean predicate $(n, k) \mapsto \text{cycle}$ | §2.1, Definition 2.1 |
| $n, k$ | Cycle starting point and length | §2.1 |
| $m$ | Cycle minimum integer | §2.3.3, §3.2 |
| $s, s_i$ | Halving exponents and parity vector | §2.2 |
| $C_{n, k, s}$ | Steiner corrective sum | §2.2 |
| $\log_2 3$ | Real number, irrationality measure $\leq 5.125$ | §2.5 |
| $p_n / q_n$ | Continued-fraction convergents of $\log_2 3$ | §2.5 |
| $W_n$ | Continued-fraction window $[q_n, q_{n+1})$ | §2.5 |
| `BakerSeparation` | First structural hypothesis (Baker 1966) | §2.3.1, §4.1 |
| `BarinaVerification` | Second structural hypothesis (Barina 2025) | §2.3.2, §4.2 |
| `ProductBoundThreshold` | Third structural hypothesis (project-derived) | §2.3.3, §4.3 |
| `DerivedLargeKBound` | CF-side equivalent of `ProductBoundThreshold` | §8.1, Appendix D |
| $\delta 7, \delta 8, \delta 8', \delta 9$ | Paper contributions (informal codes) | §1.3 |
| $6\alpha$ | Paper contribution: formal-verification artifact | §1.3 |
| $\Phi_s, \Psi_s, \psi_s$ | Structural-excess functions (supplementary) | §8.5, §9.7, Appendix A |

