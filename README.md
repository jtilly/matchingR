Matching Algorithms in R: Gale-Shapley and Irving's Stable Roommate Problem
===============
[![Build Status](https://travis-ci.org/jtilly/matchingR.png)](https://travis-ci.org/jtilly/matchingR) 
[![Coverage Status](https://coveralls.io/repos/jtilly/matchingR/badge.svg?branch=master)](https://coveralls.io/r/jtilly/matchingR?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/matchingR)](http://cran.r-project.org/web/packages/matchingR)


[!["You know that I'll never leave you. Not as long as she's with someone."](http://imgs.xkcd.com/comics/all_the_girls.png)](http://xkcd.com/770/ "You know that I'll never leave you. Not as long as she's with someone.")


`matchingR` is an R Package that efficiently computes the [Gale-Shapley Algorithm](http://en.wikipedia.org/wiki/Stable_marriage_problem) and [Irving's Stable Roommate Problem](https://en.wikipedia.org/wiki/Stable_roommates_problem) for large matching markets. The package can be useful when the number of market participants is large or when very many matchings need to be computed (e.g. for extensive simulations or for estimation purposes). The Gale-Shapley function of this package has successfully been used to simulate preferences and compute the matching with 30,000 participants on each side of the market.

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
* [Vignette: Matching Algorithms in R: An Introduction to matchingR](http://jtilly.io/matchingR/matchingR-intro.html "Matching Algorithms in R: An Introduction to matchingR")
* [Vignette: Computing the Gale-Shapley Algorithm in R: Performance](http://jtilly.io/matchingR/matchingR-performance-galeshapley.html "Computing the Gale-Shapley Algorithm in R: Performance")
* [Vignette: Solving the Stable Roommate Problem in R: Performance](http://jtilly.io/matchingR/matchingR-performance-roommate.html "Solving the Stable Roommate Problem in R: Performance")

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
results = matchingR::one2one(proposerPref = prefM, reviewerPref = prefW)
```
The original Gale-Shapley algorithm can be easily modified to accommodate unequal numbers of participants on each side of the market as well as one-to-many matchings, i.e. the matching of workers to multi-worker firms or the matching of students to colleges.

For additional examples, take a look at the [vignette](http://jtilly.io/matchingR/matchingR-intro.html) or at the [examples page](EXAMPLES.md).

## Irving's Stable Roommate Algorithm: How does it work?

Preferences of potential roommates are summarized by an `n-1` by `n` dimensional matrix, e.g., if `n = 6`, 
```{r}
pref = matrix(c(2, 5, 1, 4, 2, 4,
                3, 4, 3, 1, 0, 0,
                1, 3, 4, 2, 1, 2,
                5, 0, 0, 5, 3, 3,
                4, 2, 5, 0, 5, 1), nrow = 5, ncol = 6, byrow = TRUE)
```
Column `i` represents the preferences of the `i`th roommate, and row `j` represents the ranking of the roommate whose index is encoded in that row. For example, in the above preference matrix, roommate `0` most prefers to be matched with roommate `2`, followed by `3`, followed by `1`.

The algorithm proceeds in two phases.

### Phase 1

In phase 1, potential roommates take turns sequentially proposing to the other roommates. Each roommate who is proposed to can accept or reject the proposal. A roommate accepts if he currently has made no better proposal which was accepted to another roommate. If a roommate has accepted a proposal, and then receives a better proposal, he rejects the old proposal and substitutes in the new proposal. 

In the above example, 

1. Roommate `0` begins by proposing to roommate `2`, he most preferred roommate. `2`, having no better offers, accepts.
2. `1` proposes to `5`, who accepts.
3. `2` proposes to `1`, who accepts.
4. `3` proposes to `4`, who accepts.
5. `4` proposes to `2`, who accepts. `2` cancels his proposal from `0`.
6. `0`, having no proposal, proposes to `3`, who accepts.
7. `5` proposes to `4`, who rejects, having a better proposal from `3`.
8. `5` proposes to `0`, who accepts.

### Phase 2

In phase 2, we begin by eliminating all potential roommate matches which are worse than the current proposals held. For example, in the above example, `2` has a proposal from `4`, and so we eliminate `0` and `5` from `2`'s column, and symmetrically eliminate `2` from `0` and `5`'s column. This results in the following 'reduced' preference listing:
```
   5, 1, 4, 2,  
3, 4, 3, 1,    0
1, 3, 4, 2, 1,  
5, 0,    5, 3, 3
   2,    0,    1
```
These preferences form what is called a 'stable' table, or, 's-table'. ('Stable' for short.) The defining characteristic of a stable table is that if `i` is the most preferred roommate on `j`s list, then `j` is the least preferred roommate on `i`s list. For example, `0` most prefers `3`, but `3` least prefers `0`. 

The algorithm proceeds by finding and eliminating 'rotations'. A rotation is a sequence of pairs of roommates, such that there is a distinct roommate in the first position of each pair, the second roommate in each pair least prefers the roommate he is paired with, the first roommate in each pair most prefers the roommate he is paired with, and finally, the first roommate in each pair ranks the second roommate in the following pair second (modulo the number of pairs, that is, the first roommate in the last pair ranks the second roommate in the first pair second) Once a rotation has been identified, removing it results in another stable table.

For example, `(0, 3), (2, 1)` is a rotation in the above table, because `0` loves `3`, `2` loves `1`, `3` hates `0`, `1` hates `2`, `1` is second on `0`s list, and `3` is second on `2`'s list. Eliminating this rotation involves `1` rejecting `2`, `3` rejecting `0`, and then we remove every successive potential roommate as well to preserve the stable table property, resulting in
```
   5,    4, 2,  
   4, 3, 1,    0
1, 3, 4, 2, 1,  
5, 0,    5, 3, 3
               1
```
A further rotation is `(0, 1), (1, 5), (3, 4)`. Eliminating it yields
```
            2,  
   4, 3, 1,    0
   3, 4, 2, 1,  
5,              
                
```
A final rotation is `(1, 4), (2, 3)`. Eliminating it yields
```
            2,  
         1,    0
   3, 4,        
5,              
                
```
Therefore, a stable matching is for `0` and `5` to match, `1` and `3` to match, and `2` and `4` to match. 
```{r}
results = onesided(pref = pref)
```
