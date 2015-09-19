Matching Algorithms in R
===============
[![Build Status](https://travis-ci.org/jtilly/matchingR.png)](https://travis-ci.org/jtilly/matchingR) 
[![Coverage Status](https://coveralls.io/repos/jtilly/matchingR/badge.svg?branch=master)](https://coveralls.io/r/jtilly/matchingR?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/matchingR)](http://cran.r-project.org/web/packages/matchingR)


[!["You know that I'll never leave you. Not as long as she's with someone."](http://imgs.xkcd.com/comics/all_the_girls.png)](http://xkcd.com/770/ "You know that I'll never leave you. Not as long as she's with someone.")


`matchingR` is an R package that efficiently computes the [Gale-Shapley algorithm](http://www.jstor.org/stable/2312726), [Irving's algorithm for the stable roommate problem](http://www.sciencedirect.com/science/article/pii/0196677485900331), and the [top trading cycle algorithm](http://pareto.uab.es/jmasso/pdf/ShapleyScarfJME1974.pdf) for large matching markets. The package provides functions to compute the solutions to the
  [stable marriage problem](http://en.wikipedia.org/wiki/Stable_matching), to the
  [college admission problem](http://en.wikipedia.org/wiki/Hospital_resident), the
  [stable roommates problem](http://en.wikipedia.org/wiki/Stable_roommates_problem), and the
  [house allocation problem](http://web.stanford.edu/~niederle/HouseAllocation.pdf).
  
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
devtools::install_github("jtilly/matchingR")
```

## Examples

### Gale-Shapley Algorithm
``` r
# stable marriage problem with three men and two women
uM = matrix(c(1.0, 0.5, 0.0,
              0.5, 0.0, 0.5), nrow = 2, ncol = 3, byrow = TRUE)

uW = matrix(c(0.0, 1.0,
              0.5, 0.0,
              1.0, 0.5), nrow = 3, ncol = 2, byrow = TRUE)

matching = one2one(uM, uW)
matching$engagements
#>      [,1]
#> [1,]    3
#> [2,]    1
matching$single.proposers
#> [1] 2
checkStability(uM, uW, matching$proposals, matching$engagements)
#> [1] TRUE

# college admissions problem with five students and two colleges with two slots each
nstudents = 5
ncolleges = 2
uStudents = matrix(runif(nstudents*ncolleges), nrow=ncolleges, ncol=nstudents)
uColleges = matrix(runif(nstudents*ncolleges), nrow=nstudents, ncol=ncolleges)
matching = one2many(uStudents, uColleges, slots=2)
matching$engagements
#>      [,1] [,2]
#> [1,]    1    4
#> [2,]    3    5
matching$single.proposers
#> [1] 2
checkStability(uStudents, uColleges, matching$proposals, matching$engagements)
#> [1] TRUE
```

### Irving's Algorithm
``` r
# stable roommate problem
set.seed(2)
n = 4
u = matrix(runif(n^2),  nrow = n, ncol = n)
u
#>           [,1]      [,2]      [,3]      [,4]
#> [1,] 0.1848823 0.9438393 0.4680185 0.7605133
#> [2,] 0.7023740 0.9434750 0.5499837 0.1808201
#> [3,] 0.5733263 0.1291590 0.5526741 0.4052822
#> [4,] 0.1680519 0.8334488 0.2388948 0.8535485
results = onesided(utils = u)
results
#>      [,1]
#> [1,]    2
#> [2,]    1
#> [3,]    4
#> [4,]    3
```

### Top-Trading Cycle Algorithm
``` r
# top trading cycle algorithm
set.seed(2)
n = 4
u = matrix(runif(n^2),  nrow = n, ncol = n)
u
#>           [,1]      [,2]      [,3]      [,4]
#> [1,] 0.1848823 0.9438393 0.4680185 0.7605133
#> [2,] 0.7023740 0.9434750 0.5499837 0.1808201
#> [3,] 0.5733263 0.1291590 0.5526741 0.4052822
#> [4,] 0.1680519 0.8334488 0.2388948 0.8535485
results = toptrading(utils = u)
results
#> $matchings
#>      [,1]
#> [1,]    2
#> [2,]    1
#> [3,]    3
#> [4,]    4
```


## Documentation
* [Reference Manual](http://jtilly.io/matchingR/matchingR-documentation.pdf "Computing Stable Matchings in R: Reference Manual for matchingR")
* [Vignette: Matching Algorithms in R: An Introduction to matchingR](http://jtilly.io/matchingR/matchingR-intro.html "Matching Algorithms in R: An Introduction to matchingR")
* [Vignette: Matching Algorithms in R: Computational Performance](http://jtilly.io/matchingR/matchingR-performance.html "Matching Algorithms in R: Computational Performance")
