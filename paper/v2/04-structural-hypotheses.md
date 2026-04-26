# The three structural hypotheses

The conditional theorem of §3 depends on three hypothesis-structures
declared in `ProjetCollatz/Phase58PorteDeuxFinal.lean`. The Lean
signatures are shown verbatim in §2.3 (`BakerSeparation` lines 67-69,
`BarinaVerification` lines 80-81, `ProductBoundThreshold` lines
296-297); this section provides the mathematical and bibliographic
context for each.

## BakerSeparation (Baker 1966)

```lean
structure BakerSeparation where
  separation : ∀ (s k : ℕ), s ≥ 1 → k ≥ 2 → 2^s > 3^k →
    (2^s - 3^k) * k^6 ≥ 3^k
```

**Source.** Baker, A. (1966), *Linear forms in the logarithms of
algebraic numbers I*, *Mathematika* 13, pp. 204-216. Refined by Rhin
(1987) and Matveev (2000). Fields Medal 1970.

**Scope.** It is standard in the Collatz cycle literature to adopt
Baker as an external hypothesis; Steiner (1977), Simons-de Weger
(2005), and Hercher (2023) all use variants. Formalizing Baker's
theorem in Lean would require approximately 10{,}000 lines of
transcendence theory (Feldman-Nesterenko-Shorey-Tijdeman framework).
The specific Baker-type inequality
$(2^s - 3^k) \cdot k^{\mu} \geq 3^k$ follows from the standard
reduction documented in Steiner (1977, §2) and Simons-de Weger
(2005, Lemma 2.1). The hypothesis as stated absorbs Baker's
effective constant $C$ into the unit prefactor — that is, it
asserts the inequality at the idealized $C = 1$. For the
literal Baker / Rhin / Matveev constants this absorption is valid
asymptotically (for $k$ large enough that $C \cdot k^c$ exceeds 1
and the polynomial regime dominates), and no concrete lower bound
on the relevant $k_0$ is required for the conditional theorem of
§3 since the small-$k$ regime is closed independently by Hercher
(2023) and by `no_cycle_k_le_1322` (Phase58).

**Effective constant.** The formalization uses the
irrationality-measure exponent $\mu = 6$, strictly weaker than the
sharpest known bound on $\mu(\ln 3)$. Rhin's (1987) linear-form
bound for $|p \cdot \ln 2 + q \cdot \ln 3|$ yields the irrationality
measure $\mu(\ln 3) \leq 8.616$; Salikhov (2007) sharpens this to
$\mu(\ln 3) \leq 5.125$, and the linear-independence measure result
of Wu (2003) corresponds to a slightly sharper formulation
($\mu(\ln 3) \leq 5.117$).

Throughout this paper, three closely related but distinct
quantities appear and we adopt the following convention. The
*exponent* $c$ of an effective lower bound of the form
$|p \cdot \ln 2 - q \cdot \ln 3| \geq C / H^c$ (with
$H = \max(|p|, |q|)$) is invariant under the rational rescaling
$\log_2 3 = \ln 3 / \ln 2$; that is, the irrationality-measure
exponents of $\ln 3$ and of $\log_2 3$ coincide. The *effective
constant* $C$, however, is not invariant: rewriting the linear form
as $|p - q \cdot \log_2 3| \cdot \ln 2 = |p \cdot \ln 2 - q \cdot \ln 3|$
introduces a factor $(\ln 2)^{-1}$ — and, in higher-power forms,
$(\ln 2)^{-c}$ — when transferring between $\ln$-bounds and
$\log_2$-bounds. We track this factor explicitly in §5.1 where it
matters. The structure `BakerSeparation` exposes only the exponent
$\mu = 6$, not the multiplicative constant; this is by design — the
$\mu = 6$ exponent alone suffices for the Product-Bound derivation
chain.

## BarinaVerification (Barina 2025)

```lean
structure BarinaVerification where
  convergence: ∀ (n: ℕ), n > 0 → n < 2^71 → reaches_one n
```

**Source.** Barina, D. (2025), *Improved verification limit for the
convergence of the Collatz conjecture*, *Journal of Supercomputing*
81:810. DOI: 10.1007/s11227-025-07337-0.

**Actual limit.** $2075 \cdot 2^{60} \approx 2^{71.02}$; the bound
$n < 2^{71}$ used in the formalization is slightly conservative.

**Reproducibility.** Barina's code is open-source; the computational
verification relies on modular sieving and is reproducible (though it
requires ~months of CPU time).

## ProductBoundThreshold (project-derived, documented)

```lean
structure ProductBoundThreshold where
  cycle_length_bound: ∀ (n k: ℕ), IsOddCycle n k → k ≤ 982
```

**Origin.** This hypothesis is **not a direct result from any single
published paper** (see `ProjetCollatz/HYPOTHESES.md` in the
accompanying repository). It is a *cycle-complexity bound* whose
explicit threshold $k \leq 982$ derives from:

1. The Product Bound lemma (`ProjetCollatz/Phase56*.lean`, proved
   algebraically from Baker plus Bernoulli): the cycle minimum $m$
   satisfies $m \leq (k^7 + k)/3$.
2. Barina's verification limit $2^{71}$.
3. The arithmetic fact $(982^7 + 982)/3 < 2^{71}$, verified by
   `native_decide` in `k982_bound`
   (`Phase56Bloc18Complete.lean` line 249).

**Status.** For hypothetical cycles, $k \leq 982$ is **vacuously
true** assuming the Collatz no-cycle conjecture. It is *stronger*
than Hercher's (2023) lower bound $K > 1.375 \cdot 10^{11}$, but
this apparent contradiction is resolved because both claims are
vacuous on the (conjectured) empty set of non-trivial cycles.

**Why it remains a hypothesis.** Even though `ProductBoundThreshold`
is not a direct citation, it encapsulates the Product Bound + Barina
chain in a cycle-complexity framing that is natural to formalize and
explicit about what is assumed. We emphasize that the parametric
formulation of Theorem 3.1 makes the theorem hold for *any* witness
of `ProductBoundThreshold`, not only for the witness produced by
the bridge lemma `sdw_from_cf` (§8.1) from Baker plus Barina plus
the continued-fraction-side hypothesis. A non-Baker witness — for
example one derived from ergodic, density-theoretic, or yet
unidentified techniques — would discharge the hypothesis without
appeal to §5's obstruction. The structural obstruction that
prevents promoting `ProductBoundThreshold` to a theorem *within
the Baker + continued-fraction framework* — together with the
resulting gap in the unconditional argument — is the subject of §5
(Obstruction I).

**Conservative bound vs optimal threshold.** The structure fixes
$k \leq 982$ as a *conservative* parameter with an $\approx 8\times$
safety margin, while the corresponding theorem `no_cycle_k_le_1322`
(Phase58, proved) covers the *optimal* range $k \leq 1322$. The
optimal value $1322$ is the maximum integer $k$ such that
$(k^7 + k)/3 < 2^{71}$ (verified:
$(1322^7 + 1322)/3 \approx 2.35 \cdot 10^{21} < 2^{71} \approx
2.36 \cdot 10^{21}$, while $(1323^7 + 1323)/3 > 2^{71}$).
The $982$-vs-$1322$ distinction reflects the gap between the
structural-hypothesis-as-parameter ($982$, conservative for ease of
arithmetic verification) and the proven Lean-side optimal threshold
($1322$, used in §7.1 and §8.1).

