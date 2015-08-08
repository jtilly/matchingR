Matching Algorithms in R: Gale-Shapley and Irving's Stable Roommate Problem
===============
[![Build Status](https://travis-ci.org/jtilly/matchingR.png)](https://travis-ci.org/jtilly/matchingR) 
[![Coverage Status](https://coveralls.io/repos/jtilly/matchingR/badge.svg?branch=master)](https://coveralls.io/r/jtilly/matchingR?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/matchingR)](http://cran.r-project.org/web/packages/matchingR)


[!["You know that I'll never leave you. Not as long as she's with someone."](http://imgs.xkcd.com/comics/all_the_girls.png)](http://xkcd.com/770/ "You know that I'll never leave you. Not as long as she's with someone.")


`matchingR` is an R Package that efficiently computes the [Gale-Shapley Algorithm](http://www.jstor.org/stable/2312726) and [Irving's Algorithm for the Stable Roommate Problem](http://www.sciencedirect.com/science/article/pii/0196677485900331) for large matching markets.  The
  package provides functions to compute the solutions to the
  [stable marriage problem](http://en.wikipedia.org/wiki/Stable_matching), to the
  [college admission problem](http://en.wikipedia.org/wiki/Hospital_resident), and to the
  [stable roommates problem](http://en.wikipedia.org/wiki/Stable_roommates_problem).
The package can be useful when the number of market participants is large or when very many matchings need to be computed (e.g. for extensive simulations or for estimation purposes). The Gale-Shapley function of this package has successfully been used to simulate preferences and compute the matching with 30,000 participants on each side of the market.

Matching markets are very common in practice and widely studied by economists. Popular examples include
* the [National Resident Matching Program](http://www.nrmp.org/) that matches graduates from medical school to residency programs at teaching hospitals throughout the United States
* the matching of students to schools including the [New York City High School Match](http://www.jstor.org/stable/4132848) or the the [Boston Public School Match](http://www.jstor.org/stable/4132849) (and many more)
* the matching of kidney donors to recipients in [kidney exchanges](http://www.jstor.org/stable/4132851).
 
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

## Readme
* [Gale-Shapley Algorithm](GALESHAPLEY.md)
* [Irving's Algorithm for the Stable Roommate Problem](IRVING.md)

## Documentation
* [Reference Manual](http://jtilly.io/matchingR/matchingR-documentation.pdf "Computing Stable Matchings in R: Reference Manual for matchingR")
* [Vignette: Matching Algorithms in R: An Introduction to matchingR](http://jtilly.io/matchingR/matchingR-intro.pdf "Matching Algorithms in R: An Introduction to matchingR")
* Computational Performance: [Gale-Shapley](http://jtilly.io/matchingR/matchingR-performance-galeshapley.html "Computing the Gale-Shapley Algorithm in R: Performance") [Stable Roommate Problem](http://jtilly.io/matchingR/matchingR-performance-roommate.html "Solving the Stable Roommate Problem in R")

