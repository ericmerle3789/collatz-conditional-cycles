# Conclusion

This paper presents a machine-checked conditional non-existence result
for non-trivial Collatz cycles, three named hypotheses on which it
rests, two impossibility lemmas explaining why the third hypothesis
cannot be discharged within the standard Diophantine framework, and a
literature mapping documenting the structural gap that makes the
conditionality necessary. The Lean 4 formalization is reproducible
under Mathlib v4.27.0 with an isolated and documented axiom profile.

## What this paper establishes

The five contributions of §1.3 are realized as follows:

- **6α (formal verification, §3 + §8).** The conditional theorem
  `no_nontrivial_cycle_final` (`ProjetCollatz/Phase58PorteDeuxFinal.lean`
  line 339) is declared parametrically with the three structures of §4
  and is machine-verified. Its kernel-3 axiom profile
  (`propext`, `Classical.choice`, `Quot.sound`) is exhibited verbatim
  in §3.3 and §8.6, and reproducibility is encoded in `reproduce.sh`
  against the `expected_axioms.md` baseline (§8.7).

- **$\delta 7$ (alternative framing, §7).** Reformulation
  \ref{ref:disjunction} restates the central result equivalently as
  the disjunction "$k \leq 1322$ or $n > 2^{71}$" (§7.1),
  establishing a one-sentence bridge from the conditional theorem to
  Hercher's (2023) lower bound $K > 1.375 \cdot 10^{11}$ (§7.2). A
  finer-grained continued-fraction refinement at the cycle-length
  scale $k > 1322$ is documented as a Phase63 Lean skeleton (§8);
  its non-completion meets the obstruction of §5.

- **$\delta 8$ (Product-Bound Impossibility Lemma, §5.1).**
  Lemma \ref{lem:productbound} formalizes a meta-mathematical
  obstruction: every uniform algebraic bound $F(k)$ with
  $F(k) < 2^{71}$ derived through the Product Bound derivation
  forces an irrationality-measure constraint on $\log_2 3$ that
  contradicts irrationality. The lemma is a publication-only
  argument about the structural limits of the Baker + continued-
  fraction framework, not a Lean theorem.

- **$\delta 8'$ (extended impossibility, §5.2).**
  Corollary \ref{cor:lowerasymmetry} extends $\delta 8$ to Baker-type
  inequalities composed with Steiner's cycle equation.
  Window-by-window numerical corroboration via Khinchin's
  best-second-kind characterization closes $k \leq 982$
  (Baker $\mu = 6$), $k \leq 3693$ (Salikhov 2007 $\mu = 5.125$), and
  $k \lesssim 3 \cdot 10^{10}$ (Khinchin per-window) — all below
  Hercher's lower bound $K > 1.375 \cdot 10^{11}$.

- **$\delta 9$ (state-of-the-art mapping, §6).** Section 6
  catalogs the 1977-2026 Collatz cycle literature in five
  categories: historical lower bounds (§6.1), structural-class
  eliminations (§6.2), meta-impossibilities (§6.3), recent
  reformulation attempts (§6.4), and probabilistic / density results
  (§6.5). The mapping documents, to the best of our literature
  review, the absence of any peer-reviewed deterministic upper bound
  on cycle length $k$ for general Collatz cycles (§6.6).

## What this paper does not claim

- We do **not** prove the Collatz conjecture. The third hypothesis,
  `ProductBoundThreshold` (§4.3), remains a hypothesis; the paper
  is *about* why it cannot be discharged within the standard framework.

- We do **not** address the divergence half of the Collatz conjecture
  (§1.1). The cycle problem and the divergence problem are
  disjoint; this paper concerns only the former.

- We do **not** dismiss or subsume Santana (2026), Knight (2026),
  Dhiman-Pandey (2026), or Rozier-Terracol (2026). Each is situated
  in §6.4 as either complementary (different methodological framework)
  or restricted-class (does not extend to general cycles), with the
  documented gaps and indirect-source flags clearly attributed.

- We do **not** claim that the obstruction of §5 is final. The
  obstruction is structural under the *Baker + CF + Product Bound*
  paradigm; methodological frameworks outside that paradigm — for
  instance a deterministic upper bound on cycle length derived from
  ergodic, density-theoretic, or yet-uncataloged techniques — would
  immediately discharge `ProductBoundThreshold` and upgrade
  Theorem \ref{thm:main} from conditional to unconditional.

## Modular invitation for future work

The paper's structure is deliberately additive: conditional theorem
+ documented obstructions + machine-verifiable formalization. A
future contribution that resolves any of the three following lines
of work would, without further editorial intervention, upgrade the
conditional theorem:

1. **Discharge `ProductBoundThreshold`** (§4.3). Any deterministic
   proof that hypothetical cycles satisfy $k \leq K$ for some
   explicit $K$ (whether $K = 982$ or larger) would replace the
   structure field with a Lean theorem.

2. **Close the $\delta 9$ gap** (§6.6). A peer-reviewed
   deterministic upper bound on $k$ for general cycles, by any
   methodological framework, would supersede the project-specific
   encoding.

3. **Refine or supersede $\delta 8$** (§5). A novel argument
   framework not bound by the Baker + CF + Product Bound family of
   inequalities could in principle bypass the obstruction, with
   corresponding refinement of the conditional theorem.

Speculative tracks documented in §9 (open problems) — including the
$\Psi_s$ structural-excess framework (§9.7) and the upper-bound
complement attempt (§9.8) — are presented as ongoing work not
integrated into the central conditional theorem of §3; we list them
for transparency and as invitations rather than as results.

The Lean 4 formalization is intended as a stable substrate for such
future work: the conditional theorem, the three hypothesis
structures, and the axiom profile are all parametric, so additive
contributions need not re-formalize the existing argument.

## Declarations {.unnumbered}

### Funding {.unnumbered}

The author received no funding for this research.

### Competing interests {.unnumbered}

The author declares no competing interests.

### Ethics approval and consent to participate {.unnumbered}

Not applicable (the research involves neither human nor animal
subjects).

### Data and code availability {.unnumbered}

All paper sources, the Lean 4 formalization, the verification
probes, and the reproduction script are publicly available at
<https://github.com/ericmerle3789/collatz-conditional-cycles>
(branch `main`) and permanently archived on Zenodo at
<https://doi.org/10.5281/zenodo.19790406>. Reproduction requires
the Lean toolchain `leanprover/lean4:v4.27.0` against Mathlib
commit `a3a10db0e9d66acbebf76c5e6a135066525ac900` (pinned in the
project's `lake-manifest.json`). With the Mathlib cache fetched,
full reproduction completes in approximately 5 minutes on a Mac
M1 Pro with 16 GB RAM, exiting with kernel-3 axiom profile and
zero `sorry`. The exit-code semantics of `reproduce.sh`
(0 = success, 1 = toolchain mismatch, 2 = build failure,
3 = axiom drift, 4 = `sorryAx` detected) are documented in §8.7.

### Author contributions {.unnumbered}

Sole author. Eric Merle: conceptualization, mathematical
development, Lean 4 formalization, manuscript preparation, and
verification.

### Use of large language models {.unnumbered}

The author used Claude Opus 4.7 (Anthropic) during manuscript
preparation for drafting, revision, and literature retrieval. The
mathematical content and the scientific responsibility for the
manuscript rest entirely with the author. The formal verification
is performed by Lean 4 (the proof assistant) — not by any
language model — under the standard kernel-3 axiom profile
(`propext`, `Classical.choice`, `Quot.sound`), as documented in
§8.6 and Appendix B; it is therefore mechanically reproducible
and independent of any language-model assistance described above.

## Acknowledgements {.unnumbered}

The Lean formalization builds on Mathlib (Mathematics in Lean 4);
the author thanks the Mathlib community for the continued-fraction,
Diophantine-approximation, and number-theory infrastructure on
which the central chain depends. The author also thanks D. Barina
for the 2025 computational verification underpinning hypothesis
(ii). The state-of-the-art mapping in §6 is indebted to the
cumulative work of the Collatz literature 1977-2026 surveyed
therein.

