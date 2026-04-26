# Open problems

## Removing `ProductBoundThreshold`
The central open question raised by this paper: can `ProductBoundThreshold` be promoted to a theorem? §5 Obstruction I answers *not within any product-bound approach*. The question is therefore: what non-product-bound technique might close the `k > 1322` case?

## The `k ≥ q_{14}` tail
Current-generation Barina reaches `n < 2^{71}`, which via CF windows `W_8, ..., W_{13}` covers `k < q_{14} ≈ 10,590,737`. A `W_{14}` extension would require arithmetic gap constants involving `3^{q_{14}}`, a number with approximately `5 · 10^6` decimal digits — outside `native_decide`'s reach at present hardware.

## Formalization challenges
- The bridge `(Real.convergent v n).den: ℝ = (GenContFract.of v).dens n` is not direct in Mathlib v4.27.0. Phase62 works around it via a parametric real-valued form; a proper bridge would strengthen the Phase61 / Phase62 integration.
- Phase63 Sections 2-11 as Lean theorems would require the breakthrough discussed in §9.1 + the bridge in §9.3.

## Relation to divergence
This paper does not address the divergence half of Collatz. The techniques (Baker's theorem + CF theory + formal verification) are in principle adaptable, but the structure is different. Explicit scope disclosure.

## Speculative tracks pointer
Ongoing speculative investigations on transcendence-theoretic approaches (Santana 2026 rigor-closure, Knight 2026 extension, transcendence-gap sharpenings). Results, if any, would feed a future paper revision.

## Probabilistic techniques (Tao)


Tao's probabilistic approach (2019, *Forum of Mathematics, Pi*) proves that almost all Collatz orbits attain almost bounded values under logarithmic density. This result is **probabilistic** and does not extend to deterministic statements about hypothetical cycles (which have density zero). Tao's broader toolkit (entropy compression à la Moser-Tardos [blog 2009], higher-order Fourier analysis à la Green-Tao-Ziegler) has not been successfully applied to deterministic Collatz cycle bounds; such applications would require substantial new theoretical work. We therefore do not integrate probabilistic techniques into our proof of Theorem 3.1 (which remains conditional on the structural hypotheses §4).

## Structural-excess framework Ψ_s

*[Lean formalization status: see §8.5 for the supplementary
`ProjetCollatz/PhaseVIII/` module.]*

We formalize in Lean 4 a custom $\Phi_s / \Psi_s$ structural-excess
framework (Mathlib v4.27.0 lacks Gowers norms). Machine-verified:
the trivial Collatz cycle has $\Psi_2 = 32/81$, establishing a
factor-$32\times$ structural excess over its mean prediction
($1/81$). The T4c conjecture is encoded as parametric
`def T4c_Conjecture_Psi2`, and the contradiction schema
`psi2_bounds_no_cycle` records the logical shape of the intended
attack. See `ProjetCollatz.PhaseVIII.StructuralExcess` in the
accompanying repository (§8.5).

## Set-theoretic and rigidity-based research directions

**Status note.** The remainder of this section sketches a
research-direction frame — not a result. None of the constructions
below participates in the central proof chain of §3, none is
formalized in the kernel-3 Lean baseline, and none is asserted as
established mathematics. We include the sketch here for
transparency about the lines of work the present paper does
*not* close, and as forward pointers to Appendix A where the
alternate-notation explorations are gathered.

The frame, inherited from the Hercher / Steiner cycle-structure
literature, uses the alternate notation of Appendix A
($a$ = even steps, $k$ = odd steps, $T = a + k$ the cycle period,
$q = 2^a - 3^k$ the Steiner difference, $K$ for Hercher's
cycle-length invariant per §6.1 note, $R_K(\sigma) := \sum_i
3^{K-1-i} \cdot 2^{\sigma(i)}$ for the permutation sum behind
the Steiner rigidity question, and $\psi_s, \Psi_s$ for the
structural-excess functions of §9.7).

The frame organizes a hypothetical cycle's parity vector as
sitting inside an intersection
$S_{\mathrm{cycle}} \subset S_{\mathrm{Steiner}} \cap
S_{\Psi\text{-large}} \cap S_{\mathrm{Kol\text{-}bounded}} \setminus
S_{\mathrm{Hercher}}$ — combining Steiner-rigid tuples, a
$\Psi_s$-excess condition (cf. §9.7), and a conditional-Kolmogorov
compressibility condition. Five "bricks" $W_1, W_2, W_3, W_4, W_5$
of this frame are exploited or reduced to redundancy in the
present paper, except for $W_2$ (Steiner rigidity), which is the
remaining open input. We refer to this informally as the *Wall
DNA* arrangement and to its conjectural closure as the
*META-ROADMAP* statement; both labels are descriptive
shorthand, not theorems. A 200-line exploratory Lean 4 prototype
attaches a `sorry` placeholder to the META-ROADMAP statement
under five hypotheses (`hSteinerRigidity`, `hCycle`, `hPsiLarge`,
`hKolBounded`, `hHercher`); the only machine-verified part of
the prototype is the trivial-cycle evaluation $\psi_2 = 32/81$,
reusing the structural-excess framework of §8.5. **None of this
prototype lies in the central chain of `no_nontrivial_cycle_final`,
none of its hypotheses is proven, and the present paper does not
claim that any such closure is achievable.**

A boundary scan over classical mechanisms (Schmidt subspace
theorems for transcendental $\alpha$, Tao 2019/2022 entropy
compression for typical orbits, Lagarias's $T_\infty$
Galton–Watson framework) confirms that none extends to
deterministic cycle bounds without substantial additional work.
Salikhov 2007 combined with Hercher 2023, in this alternate
notation, yields a $q \gg 2.836^k$ lower bound (Proposition A.1)
under the explicit conditioning of Appendix A. These extensions
are documented in **Appendix A** with self-contained notation;
we reference them here only as forward pointers.

