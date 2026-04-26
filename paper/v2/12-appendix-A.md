```{=latex}
\appendix
```

# Alternate-notation explorations of the high-complexity disjunct

This appendix builds on the META-ROADMAP THEOREM framing of §9.8.3
(Wall DNA Theorem, brick $W_2$) and the Lean prototype of §9.8.5
(documented in the accompanying repository). It isolates the
alternate-notation results that use a convention inherited from the
Hercher 2023 / Steiner cycle-structure literature. Throughout the
appendix we adopt this paper's $(a, k)$ convention (consistent with
§3 and §4): $a$ is the number of even steps in a hypothetical cycle,
$k$ is the number of odd steps, and $q := 2^a - 3^k$ is the Steiner
difference. Where Hercher 2023 writes $K$ for the number of odd
elements in a cycle (cf. Theorem 27 of *op. cit.* and §6.1 above),
we have $K = k$; where Hercher writes $T$ for the cycle period, we
have $T = a + k$. The appendix is otherwise self-contained.

## Salikhov 2007 + Hercher 2023 establish a $q \gg 2.836^k$ lower bound

```{=latex}
\begin{proposition}[Conditional consequence of Salikhov 2007 and Hercher 2023]
\label{thm:Aone}
\emph{Conditional on (i) Hercher's Corollary 29 lower bound
$K > 1.375 \cdot 10^{11}$, (ii) Salikhov's irrationality-measure
result $\mu(\ln 3) \leq 5.125$, and (iii) an effective
linear-form lemma turning (ii) into}
$|p \cdot \ln 2 - k \cdot \ln 3| \geq C_{\ln} / k^c$
\emph{with} $c \leq 5.125$, $C_{\ln} > 0$, \emph{and $k$ above an
effective threshold $k_0$ — none of which is established here} —
\emph{for every admissible Collatz cycle $(a, k)$, with $a$ and
$k$ related by} $a = \lceil k \cdot \log_2 3 \rceil$
\emph{(so that} $2^a > 3^k > 2^{a-1}$\emph{) and with}
$k > 1.375 \cdot 10^{11}$,
$$
q := 2^a - 3^k > 2.836^k.
$$
\end{proposition}
```

**Proof sketch.** Set $\alpha = k \cdot \log_2 3$ and write
$a = \lceil \alpha \rceil$, so $0 < a - \alpha \leq 1$. Since
$3^k = 2^{\alpha}$, the Steiner difference satisfies
$q = 2^a - 3^k = 3^k \cdot (2^{a - \alpha} - 1)$. Using the
elementary inequality $2^x - 1 \geq x \cdot \ln 2$, valid for
$x \in (0, 1]$, we obtain $q \geq 3^k \cdot (a - \alpha) \cdot \ln 2$.
The effective irrationality measure $\mu(\ln 3) \leq 5.125$
(Salikhov 2007, refining Rhin 1987's linear-form bound
$\leq 8.616$) yields, in linear-form shape,
$|p \cdot \ln 2 - k \cdot \ln 3| \geq C_{\ln} / k^c$ for
$c \leq 5.125$, an effective constant $C_{\ln} > 0$, and $k$
sufficiently large. Translating to the $\log_2 3$ form via
$\log_2 3 = \ln 3 / \ln 2$ gives
$a - \alpha = a - k \cdot \log_2 3 \geq C \cdot k^{-(c-1)}$ with
$C = C_{\ln} / \ln 2$; for $c = 5.125$ this is the bound
$a - \alpha \geq C \cdot k^{-4.125}$. Combining:
$q \geq C \cdot \ln 2 \cdot 3^k \cdot k^{-4.125}$. The conclusion
$q > 2.836^k$ then reduces to
$(3/2.836)^k > k^{4.125} / (C \cdot \ln 2)$. Since
$\log_2(3/2.836) \approx 0.0811 > 0$, the left-hand side grows
exponentially in $k$ while the right-hand side grows polynomially;
under Hercher's lower bound $k > 1.375 \cdot 10^{11}$ the inequality
holds with an enormous margin (the exponential side is approximately
$10^{3.4 \cdot 10^9}$, dwarfing any polynomial in $k$), and the
threshold $k_0$ from Salikhov's effective bound sits well below
$1.375 \cdot 10^{11}$. Theorem \ref{thm:Aone} therefore establishes
the conjectural lower bound $q \gg 2.836^k$ modulo the two cited
source results.

## Refined central rigidity question (OPEN)

The structural question that Theorem \ref{thm:Aone} does not answer
is the $\sigma$-level uniform distribution of
$$
R_k(\sigma) := \sum_{i=0}^{k-1} 3^{k-1-i} \cdot 2^{\sigma(i)}
\quad \pmod{q}.
$$

```{=latex}
\begin{conjecture}[Central rigidity]
\label{conj:Atwo}
For every Collatz cycle $(a, k)$ with $k > 1.375 \cdot 10^{11}$, the
values
$$
\bigl\{ R_k(\sigma) \pmod{q} : \sigma \text{ increasing map }
\{0, \dots, k{-}1\} \to \{0, \dots, a{+}k{-}1\} \bigr\}
$$
are approximately uniformly distributed modulo $q$.
\end{conjecture}
```

This refines the "Steiner rigidity" open question identified in
§9.8.3 (META-ROADMAP THEOREM, Wall brick `W2`): a positive
resolution of Conjecture \ref{conj:Atwo} would, combined with
Theorem \ref{thm:Aone}, complete the $\sigma$-level rigidity
argument. Heuristic plausibility is supported by orbit-cover
arguments; no obstruction is currently known.

## Three challenges and a research-program framing

We document three substantive technical challenges to a direct
attack on Conjecture \ref{conj:Atwo} via Kloosterman + Weil +
Vinogradov sums:

1. **$q$ composite obstruction.** The Weil bound
   $|\sum e(\alpha\, 2^t / q)| = O(\sqrt{q})$ requires $q$ prime
   (with Kloosterman-pair structure). For $q = 2^a - 3^k$ composite,
   generalized Weil (Estermann + Hensel) yields
   $O(q^{1/2 + \varepsilon})$ heuristically for square-free $q$,
   but rigorously verifying favorable factorization for every
   admissible $q$ is open.

2. **Increasing subset constraint.** $S_k(c)$ sums over increasing
   $k$-tuples, not arbitrary tuples. Cauchy-Schwarz /
   inclusion-exclusion decompositions yield cross-terms with
   rank-dependent coefficients that standard analytic-number-theory
   techniques do not directly handle.

3. **Mixed exponential 3-adic + 2-adic structure.** $R_k(\sigma)$
   mixes powers of $3$ (deterministic coefficient) and $2$
   ($\sigma$-dependent), so the standard Kloosterman-sum framework
   over a single multiplicative group does not directly apply.
   Decoupling absorbs the $3$-power into a constant
   $\alpha_i = c \cdot 3^{k-1-i} \pmod{q}$ whose orbit under
   multiplication by $3$ covers most residues — challenge 3
   resolves conditional on challenges 1 and 2.

The path forward is one of three options: (a) develop new analytic
techniques for composite-modulus exponential sums with
increasing-subset constraints; (b) restrict to admissible $(a, k)$
with favorable factorization of $q$; or (c) accept a partial bound
and identify the specific obstruction to closing the remaining gap.
Each option defines a distinct sub-line of investigation outside the
present paper's scope.
