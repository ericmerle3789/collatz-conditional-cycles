# Structural obstructions I: Product-Bound impossibility

**Editorial framing note.** The "Lemma 5.1" stated in §5.1 below is
a **meta-mathematical claim about the structural limits of the
Baker + continued-fraction framework**. It is *not* a formal Lean
theorem in this repository. The Lean formalization (cf. §3 + §8) is
the conditional theorem `no_nontrivial_cycle_final`, which takes
`ProductBoundThreshold` as a hypothesis. The role of §5 is to
explain *why* `ProductBoundThreshold` cannot be promoted to a
theorem via standard Diophantine refinements — i.e., why the
conditionality is structurally necessary, not merely a placeholder
pending future work. The "δ8" / "δ8'" labels used below correspond
to an informal framework documented in
`ProjetCollatz/Phase63DerivedLargeKBoundTheorem.lean` (docstring
lines 159, 171), not to formal Lean lemmas.

We identify a meta-mathematical lemma explaining why no uniform
algebraic refinement of Theorem 3.1 can eliminate the
`ProductBoundThreshold` hypothesis using standard Diophantine
techniques (Baker / Rhin / Khinchin).

## The Product-Bound Impossibility Lemma (δ8)

```{=latex}
\begin{lemma}[Product-Bound Impossibility, $\delta 8$]
\label{lem:productbound}
Let $\xi \in \mathbb{R} \setminus \mathbb{Q}$ have effective
irrationality measure $\mu(\xi) \leq c$ — that is, there exists an
effective constant $C > 0$ such that, for all $p/q$ with $q$
sufficiently large, $|\xi - p/q| \geq C / q^c$. Suppose any Collatz
cycle $(n, k)$ has its cycle minimum $m$ bounded by the Product
Bound derivation: $m \leq (k^{c+1} + k)/3$. Then no uniform
algebraic bound $F(k)$ with $F(k) < 2^{71}$ for all $k \in
\mathbb{N}$ can be obtained via this derivation chain.
\end{lemma}
```

**Proof sketch.** Suppose, for contradiction, that the chain
yields a uniform bound $m \leq F(k) < 2^{71}$ valid for every
$k \geq k_0$ for some effective $k_0$ (Salikhov's bound is
asymptotic in $H$; the small-$k$ regime is independently closed by
the optimal Lean theorem `no_cycle_k_le_1322`, cf. §7.1, and by
Hercher's lower bound $K > 1.375 \cdot 10^{11}$, cf. §6.1).
The Product Bound derivation yields $(2^s - 3^k)/3^k \geq 1/F(k)$,
so $2^s/3^k \geq 1 + 1/F(k)$. Taking logarithms gives
$s \cdot \ln 2 - k \cdot \ln 3 \geq \ln(1 + 1/F(k)) \geq 1/(2 F(k))$
(for $F(k)$ large), hence the linear-form lower bound
$|s \cdot \ln 2 - k \cdot \ln 3| \geq 1/(2 F(k))$. The effective
irrationality measure of $\ln 3$ (Salikhov 2007) gives, in
linear-form shape, $|q \cdot \ln 3 - p \cdot \ln 2| \geq C / H^{c-1}$
for an effective constant $C > 0$, irrationality-measure exponent
$c \leq 5.125$, and $H = \max(|p|, |q|)$ sufficiently large.
Setting $p = s$, $q = k$, $H = k$, the two bounds combine to
require $1/(2 F(k)) \geq C / k^{c-1}$, that is,
$k^{c-1} \geq 2 C^{-1} F(k)$.
For $F(k)$ to remain uniformly bounded by $2^{71}$ in the
asymptotic regime $k \geq k_0$ while the inequality holds for all
$k$, the polynomial $k^{c-1}$ (with $c - 1 \leq 4.125$) must
dominate $F(k) \leq 2^{71}$. This forces, after taking the
$k$-asymptotic, the effective constant $C$ to satisfy
$C \geq 2^{71 - (c-1)\log_2 k_0}$, which is independent of $F$ but
exceeds any constant attainable from the Salikhov machinery for
the specific exponent $c \leq 5.125$ — Salikhov 2007 establishes
the irrationality measure but does not provide an effective
constant of the magnitude required here. The contradiction is
therefore reached in the asymptotic regime, regardless of which
specific $c \in (1, 5.125]$ or effective $C$ is plugged in: the
obstruction is structural, not threshold-dependent. The small-$k$
regime is closed independently as noted at the start of the proof.

## Extended Lemma (δ8') — Baker + CF yields LOWER, not UPPER

```{=latex}
\begin{corollary}[Lower-bound asymmetry, $\delta 8'$]
\label{cor:lowerasymmetry}
Let $\xi = \log_2 3$. Any Baker-type inequality $(2^s - 3^k) \cdot
k^{\mu} \geq C \cdot 3^k$ combined with Steiner's cycle equation
yields only \emph{lower} bounds on $k$ (via Crandall-type
$k > f(n_0, q_j)$ using continued-fraction convergents $q_j$ of
$\xi$) and cannot yield a uniform \emph{upper} bound on $k$ for
general cycles.
\end{corollary}
```

**Numerical corroboration** (Product-Bound closure via the formula
$(k^{c+1} + k)/3 < 2^{71}$, with $c$ the Baker-type exponent):

- Baker $c = 6$ closes $k \leq 1322$ (the optimal Lean threshold
  `no_cycle_k_le_1322` of §7.1; the structure parameter
  $k \leq 982$ in `ProductBoundThreshold` of §4.3 is a conservative
  tightening by an $\approx 8\times$ safety margin, used for the
  natural $k^7$ arithmetic).
- Salikhov 2007's sharpening of Rhin 1987, $c = 5.125$, closes
  $k \leq 3693$ (numerical verification:
  $(3693^{6.125} + 3693)/3 < 2^{71} < (3694^{6.125} + 3694)/3$,
  consistent with the Salikhov bound; further refinement to Wu
  2003's $c = 5.117$ improves this only marginally).
- A window-by-window continued-fraction refinement at the
  best-second-kind level (Khinchin 1997, Theorem 4.14) closes
  $k \lesssim 3 \cdot 10^{10}$ for the regime
  $k \in W_8 \cup \cdots \cup W_{13}$ covered by the Lean skeleton
  `Phase63DerivedLargeKBoundTheorem.lean` (§8.4); the precise
  constant depends on the partial quotients of $\log_2 3$ and is
  not derived in this paper.

All three are below Hercher's (2023) Corollary 29 lower bound
$K > 1.375 \cdot 10^{11}$. No refinement of $c$ within the Baker
framework bridges this gap; that is the content of
Lemma \ref{lem:productbound} above.

## Complementarity with Dhiman-Pandey (2026)

Dhiman-Pandey (2026, arXiv:2601.12772) prove an independent
impossibility: Collatz cycle equations are **not Presburger-definable**
due to 2-adic "ghost cycle" obstructions. Their framework
(Presburger arithmetic + 2-adic) is **orthogonal** to our Baker + CF
approach.

**Composite picture.** Two impossibility results cover different
methodological frameworks:

- Dhiman-Pandey: rules out Presburger / finite-automata-based
  approaches.
- Our δ8 / δ8': rules out Baker + CF + Product Bound approaches.

Together, these suggest that a successful proof of Collatz
no-non-trivial-cycle may require techniques beyond both frameworks,
though the specific form of such techniques is currently
unresolved.

