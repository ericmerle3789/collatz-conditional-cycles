# Introduction

## The Collatz conjecture and the cycle problem

For each positive integer $n$, the Collatz map
$T: \mathbb{N} \to \mathbb{N}$ is defined by $T(n) = n/2$ if $n$ is
even and $T(n) = (3n+1)/2$ if $n$ is odd. The Collatz conjecture
asserts that, for every starting value, iterating $T$ eventually
reaches $1$. Equivalently, it makes two negative claims: (i) no
trajectory diverges to infinity, and (ii) no non-trivial periodic
orbit exists — where *non-trivial* means distinct from the fixed
orbit $1 \to 1$. The present paper addresses (ii) only; the
divergence half of the conjecture is outside our scope.

We find it convenient to work with the *odd iterate* $T_{\mathrm{odd}}$,
which compresses runs of halvings and advances the index by one
only on a $(3n+1)$ step. A pair $(n, k)$ with $n$ odd, $k \geq 1$,
and $T_{\mathrm{odd}}^k(n) = n$ is called an **odd Collatz cycle**
of length $k$. The trivial cycle $(1, 2)$ gives the trivial period
$1 \to 1$. Our central question is whether any pair $(n, k)$ with
$n > 1$ is an odd Collatz cycle.

## Motivation and scope

A natural starting point is the conditional reduction of the cycle
problem to two published external results: Baker's 1966 theorem on
linear forms in logarithms of algebraic numbers, and Barina's 2025
computational verification that every integer below $2^{71}$
ultimately reaches $1$. In early 2026 we set out to remove the
second of these, or at least to reduce the verification range
substantially, by promoting an intermediate structural hypothesis
of our Lean formalization to a Lean theorem. A deliberately
exhaustive exploration of the available methodology returned a
single structural verdict: every product-bound approach known to
the literature is limited to cycle length at most of order
$10^{10}$, and any successful bridge from Baker's theorem through
the continued-fraction theory of $\log_2 3$ to the cycle-length
bound we require would have to surmount an obstruction we
formulate here as the **Product-Bound Impossibility Lemma**
(§5, Lemma \ref{lem:productbound}).

The obstruction is not a gap in our own effort alone; it is a
consequence of the irrationality measure of $\log_2 3$ and is
shared by every argument in the same family. It is also worth
documenting that the obstruction cuts off not just our approach
but, as we detail in §6, the closest 2026 preprints as well. The
present paper therefore (a) states the conditional theorem
cleanly, (b) records the three structural hypotheses that it
rests on, and (c) explains the obstruction and the state of the
art that make the third hypothesis necessary. The third hypothesis
is named **ProductBoundThreshold** and is made explicit in §4.3.

## Contributions

The paper contains five originals, each with a rigorous statement
later in the text. To make cross-section navigation easier we use
five short labels — $\delta 7$, $\delta 8$, $\delta 8'$,
$\delta 9$, and $6\alpha$ — each of which is defined verbatim
in the corresponding bullet below. These labels are
*presentational shorthand only* (they have no mathematical content
beyond what the bulleted text states) and are reused in the §10
conclusion to keep the contributions traceable.

- **$\delta 7$ (alternative framing, §7).** A logically equivalent
  presentational restatement of the central theorem as the
  disjunction "$k \leq 1322$ or $n > 2^{71}$". The reformulation is
  not an independent theorem (it is equivalent to
  Theorem \ref{thm:main} under the same three hypotheses); we list
  it as a contribution because the disjunctive form makes the
  bridge to Hercher's (2023) lower-bound regime transparent at a
  glance, even though it does not close the cycle problem.

- **$\delta 8$ (Product-Bound Impossibility Lemma, §5.1).** A
  meta-mathematical lemma: any argument that bounds a hypothetical
  cycle minimum $m$ by a polynomial-over-cycle-length $F(k)$ with
  $F(k) < 2^{71}$ uniformly in $k$ forces $\log_2 3$ to be
  rationally approximable within a constant factor, contradicting
  its irrationality. The lemma explains why no refinement of
  Baker's effective exponent within the standard framework can
  discharge our third hypothesis.

- **$\delta 8'$ (extended impossibility, §5.2).** A corollary of
  $\delta 8$ extending the obstruction to the family of bound
  schemes obtained by composing Baker-type inequalities with
  Steiner's cycle equation and the continued-fraction convergents
  $p_j / q_j$ of $\log_2 3$. Numerical corroboration is given
  window by window, connecting with Khinchin's best-second-kind
  characterization of convergents.

- **$\delta 9$ (state-of-the-art mapping, §6).** A typology of the 1977-2026
  Collatz cycle literature distinguishing lower bounds on cycle length,
  structural-class eliminations (Steiner 1977 circuits; Knight 2026
  high cycles), probabilistic density results (Terras 1976; Tao 2019/2022),
  and recent reformulation attempts (Santana 2026; Dhiman-Pandey 2026;
  Rozier-Terracol 2026). The typology makes explicit, to the best of our
  literature review, that no published result supplies the deterministic
  upper bound on cycle length that our third hypothesis encodes.

- **6α (formal verification, §8).** The central theorem and its immediate
  dependencies are formalized in Lean 4 under Mathlib v4.27.0, with zero
  user-declared axioms, zero `sorry`, and an axiom profile whose central
  chain consists of the three Mathlib kernel axioms (`propext`,
  `Classical.choice`, `Quot.sound`). Arithmetic gap constants used
  in auxiliary roles are isolated from the central chain through a
  structural parameter, so that the two Lean compiler axioms
  required by `native_decide` remain outside it at the present
  formalization state.

## Relation to the 2026 literature

Four recent contributions warrant explicit positioning relative to our
conditional theorem.

- **Santana (2026, arXiv:2601.03297v4)** proposes a topological and ergodic
  reformulation of the cycle problem. We directly consulted the full
  preprint. The argument for Theorem B (finiteness) relies on an
  unjustified boundedness assumption for a sequence of integrals over
  atomic invariant measures, and Lemma 16, which would extend finiteness
  to uniqueness, is labeled by the author (Remark 17) as "an alternative
  approach [...] rather than a proof". The framework therefore does not
  discharge our third hypothesis, although it is complementary (§6.4).

- **Knight (2026, *Discrete Math.* 349(3), 114812)** proves that
  Collatz "high cycles" do not exist. This
  is a restricted-class elimination in the tradition of Steiner's
  (1977) circuits result; it does not extend, without substantial
  further work, to general parity patterns (§6.2). Access to the
  full text was blocked at the time of writing; we therefore rely
  on the abstract-level formulation validated by our upstream survey
  and flag the claim as such.

- **Dhiman-Pandey (2026, arXiv:2601.12772)** prove, by a 2-adic
  "ghost-cycle" construction, that cycle equations cannot be characterized
  in Presburger arithmetic. This is methodologically orthogonal to our
  Baker-plus-continued-fractions approach: the two results rule out
  different proof families (§5.3).

- **Rozier-Terracol (2025, arXiv:2502.00948, to appear *Discrete Math.* 2026)**
  enumerate so-called *paradoxical sequences* and use Rhin's effective
  irrationality bound heuristically. Their finiteness statement for
  paradoxical sequences is independent of our third hypothesis (§6.4).

## Paper organization

Section 2 fixes notation and restates the three hypothesis-structures as
they appear in the Lean 4 formalization. Section 3 gives the central
conditional theorem. Section 4 discusses the mathematical origin and the
published support of each of the three hypotheses. Section 5 proves the
Product-Bound Impossibility Lemma (δ8) and its extension (δ8'). Section 6
presents the literature mapping (δ9). Section 7 gives the disjunction
framing (δ7). Section 8 describes the Lean 4 formalization (6α), including
its axiom profile and its reproducibility contract. Section 9 lists open
problems and connects with ongoing speculative tracks not integrated here.
Section 10 concludes. Section 11 is the reference list.

