# δ11 — retiré le 20 octobre 2026 / withdrawn on 20 October 2026

**FR.** Le lemme `delta11_salikhov_insufficient` (Phase 65, fichier `ProjetCollatz/PostJAR/Delta11Salikhov.lean`,
étiquette `v0.7.3-delta11`) est **retiré**. Il portait sur la sous-branche k ∈ [3694, 3732] et reposait sur deux
choses qui ne tiennent pas :

1. la transposition au problème, qui fait intervenir log₂ 3, de la mesure d'irrationalité de **ln 3** établie par
   Salikhov 2007 (μ(ln 3) ≤ 5,125) ;
2. l'axiome ad hoc `c_salikhov_upper_bound : C_Salikhov < 10^-30`, qui n'est pas tiré de l'article (l'en-tête du
   fichier le dit).

La borne de Salikhov n'est établie qu'au-delà de hauteurs non explicites. Aucun seuil explicite, comme k ≤ 3693 ou
k ≤ 3732, ne peut donc en être tiré. Ces seuils sont retirés par l'erratum de la version v4 du preprint (item 3) :
https://doi.org/10.5281/zenodo.23496480. Le code reste consultable ici pour l'historique ; il ne doit plus être
cité comme un résultat.

**EN.** The lemma `delta11_salikhov_insufficient` (Phase 65, file `ProjetCollatz/PostJAR/Delta11Salikhov.lean`,
tag `v0.7.3-delta11`) is **withdrawn**. It concerned the sub-branch k ∈ [3694, 3732] and rested on two things that
do not hold:

1. the transposition to the problem, which involves log₂ 3, of the irrationality measure of **ln 3** proved by
   Salikhov 2007 (μ(ln 3) ≤ 5.125);
2. the ad hoc axiom `c_salikhov_upper_bound : C_Salikhov < 10^-30`, which is not taken from the paper (the file
   header says so).

Salikhov's bound is established only beyond unspecified heights. No explicit threshold, such as k ≤ 3693 or
k ≤ 3732, can be derived from it. These thresholds are withdrawn by the erratum of version v4 of the preprint
(item 3): https://doi.org/10.5281/zenodo.23496480. The code stays here for the record; it should no longer be
cited as a result.
