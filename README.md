Matching Algorithms in R: Gale-Shapley and Irving's Stable Roommate Problem
===============
[![Build Status](https://travis-ci.org/jtilly/matchingR.png)](https://travis-ci.org/jtilly/matchingR) 
[![Coverage Status](https://coveralls.io/repos/jtilly/matchingR/badge.svg?branch=master)](https://coveralls.io/r/jtilly/matchingR?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/matchingR)](http://cran.r-project.org/web/packages/matchingR)


[!["You know that I'll never leave you. Not as long as she's with someone."](http://imgs.xkcd.com/comics/all_the_girls.png)](http://xkcd.com/770/ "You know that I'll never leave you. Not as long as she's with someone.")


`matchingR` is an R Package that efficiently computes the [Gale-Shapley Algorithm](http://en.wikipedia.org/wiki/Stable_marriage_problem) and [Irving's Algorithm for the Stable Roommate Problem](https://en.wikipedia.org/wiki/Stable_roommates_problem) for large matching markets. The package can be useful when the number of market participants is large or when very many matchings need to be computed (e.g. for extensive simulations or for estimation purposes). The Gale-Shapley function of this package has successfully been used to simulate preferences and compute the matching with 30,000 participants on each side of the market.

Matching markets are very common in practice and widely studied by economists. Popular examples include
* the National Resident Matching Program that matches recent graduates from medical school to residency programs at teaching hospitals throughout the United States
* the matching of students to schools including the New York City High School or the the Boston Public School Match (and many more)
* the matching of kidney donors to recipients in kidney exchanges.

This package implements the Gale-Shapley Algorithm and Irving's Algorithm to compute a stable matching for such markets.

Installation
------------

`matchingR` can be installed from [CRAN](http://cran.r-project.org/web/packages/matchingR/):
```{r}
install.packages("matchingR")
```
The latest development release is available from GitHub:
```{r}
#install.packages("devtools")
devtools::install_github("jtilly/matchingR.git")
```

## Documentation
* [Reference Manual](http://jtilly.io/matchingR/matchingR-documentation.pdf "Computing Stable Matchings in R: Reference Manual for matchingR")
* [Vignette: Matching Algorithms in R: An Introduction to matchingR](http://jtilly.io/matchingR/matchingR-intro.pdf "Matching Algorithms in R: An Introduction to matchingR")
* [Vignette: Computing the Gale-Shapley Algorithm in R: Performance](http://jtilly.io/matchingR/matchingR-performance-galeshapley.pdf "Computing the Gale-Shapley Algorithm in R: Performance")

## Gale-Shapley Algorithm: How does it work?
Consider a market with three men and three women. The men's preferences are given by
```{r}
prefM = matrix(c(1, 3, 3,
                 2, 1, 2,
                 3, 2, 1), nrow = 3, ncol = 3, byrow = TRUE)
```
`prefM` states that man `1` prefers woman `1` over woman `2` over woman `3`. Man `2` prefers woman `3` over woman `1` over woman `2`. Man `3` prefers woman `3` over woman `2` over woman `1`. The women's preferences are given by
```{r}
prefW = matrix(c(3, 1, 3,
                 2, 3, 2,
                 1, 2, 1), nrow = 3, ncol = 3, byrow = TRUE)
```
`prefW` states that woman `1` prefers man `3` over man `2` over man `1`, etc. 

We can now compute the Gale-Shapley Algorithm by hand. For the preferences defined in `prefM` and `prefW` it takes five rounds until all men (and women) are matched. 

1. Man `1` proposes to woman `1`, his most-preferred choice. 
    Unmatched men: `2`, `3`.
2. Man `2` proposes to woman `3`, his most-preferred choice. 
    Unmatched men: `3`.
3. Man `3` proposes to woman `3`, his most-preferred choice. 
    Woman `3` now dumps man `2`. 
    Unmatched men: `2`.
4. Man `2` proposes to woman `1`, his most-preferred *available* choice.  
    Woman `1` now dumps man `1`. 
    Unmatched men: `1`.
5. Man `1` proposes to woman `2`, his most-preferred *available* choice. 
    All men are now matched.

The male-optimal stable matching is therefore:

|   Man  |  Woman   |
|--------|----------|
|  Man 1 |  Woman 2 |
|  Man 2 |  Woman 1 |
|  Man 3 |  Woman 3 |

This matching can be computed using
```{r}
results = one2one(proposerPref = prefM, reviewerPref = prefW)
```
The original Gale-Shapley algorithm can be easily modified to accommodate unequal numbers of participants on each side of the market as well as one-to-many matchings, i.e. the matching of workers to multi-worker firms or the matching of students to colleges.

For additional examples, take a look at the [vignette](http://jtilly.io/matchingR/matchingR-intro.html) or at the [examples page](EXAMPLES.md).

## Irving's Stable Roommate Algorithm: How does it work?

Preferences of potential roommates are summarized by an `n-1 \times n` dimensional matrix, e.g., if `n = 6`, 
```{r}
pref = matrix(c(3, 6, 2, 5, 3, 5,
                4, 5, 4, 2, 1, 1,
                2, 4, 5, 3, 2, 3,
                6, 1, 1, 6, 4, 4,
                5, 3, 6, 1, 6, 2), nrow = 5, ncol = 6, byrow = TRUE)
```
Column `i` represents the preferences of the `i`th roommate, and row `j` represents the ranking of the roommate whose index is encoded in that row. For example, in the above preference matrix, roommate `1` most prefers to be matched with roommate `3`, followed by `4`, followed by `2`.

The algorithm proceeds in two phases.

### Phase 1

In phase 1, potential roommates take turns sequentially proposing to the other roommates. Each roommate who is proposed to can accept or reject the proposal. A roommate accepts if he currently has made no better proposal which was accepted to another roommate. If a roommate has accepted a proposal, and then receives a better proposal, he rejects the old proposal and substitutes in the new proposal. 

In the above example, 

1. Roommate `1` begins by proposing to roommate `3`, his most preferred roommate. `3`, having no better offers, accepts.
2. `2` proposes to `6`, who accepts.
3. `3` proposes to `2`, who accepts.
4. `4` proposes to `5`, who accepts.
5. `5` proposes to `3`, who accepts. `3` cancels his proposal from `1`.
6. `1`, having no proposal, proposes to `4`, who accepts.
7. `6` proposes to `5`, who rejects, having a better proposal from `4`.
8. `6` proposes to `1`, who accepts.

### Phase 2

In phase 2, we begin by eliminating all potential roommate matches which are worse than the current proposals held. For example, in the above example, `3` has a proposal from `5`, and so we eliminate `1` and `6` from `3`'s column, and symmetrically eliminate `3` from `1` and `6`'s column. This results in the following 'reduced' preference listing:
```
   6, 2, 5, 3,  
4, 5, 4, 2,    1
2, 4, 5, 3, 2,  
6, 1,    6, 4, 4
   3,    1,    2
```
These preferences form what is called a 'stable' table, or, 's-table'. ('Stable' for short.) The defining characteristic of a stable table is that if `i` is the most preferred roommate on `j`s list, then `j` is the least preferred roommate on `i`s list. For example, `1` most prefers `4`, but `4` least prefers `1`. 

The algorithm proceeds by finding and eliminating 'rotations'. A rotation is a sequence of pairs of roommates, such that there is a distinct roommate in the first position of each pair, the second roommate in each pair least prefers the roommate he is paired with, the first roommate in each pair most prefers the roommate he is paired with, and finally, the first roommate in each pair ranks the second roommate in the following pair second (modulo the number of pairs, that is, the first roommate in the last pair ranks the second roommate in the first pair second) Once a rotation has been identified, removing it results in another stable table.

For example, `(1, 4), (3, 2)` is a rotation in the above table, because `1` loves `4`, `3` loves `2`, `4` hates `1`, `2` hates `3`, `2` is second on `1`s list, and `4` is second on `3`'s list. Eliminating this rotation involves `2` rejecting `3`, `4` rejecting `1`, and then we remove every successive potential roommate as well to preserve the stable table property, resulting in
```
   6,    5, 3,  
   5, 4, 2,    1
2, 4, 5, 3, 2,  
6, 1,    6, 4, 4
               2
```
A further rotation is `(1, 2), (2, 6), (4, 5)`. Eliminating it yields
```
            3,  
   5, 4, 2,    1
   4, 5, 3, 2,  
6,              
```
A final rotation is `(2, 5), (3, 4)`. Eliminating it yields
```
            3,  
         2,    1
   4, 5,        
6,              

```
Therefore, a stable matching is for `1` and `6` to match, `2` and `4` to match, and `3` and `5` to match. 
```{r}
results = onesided(pref = pref - 1)
results
```
