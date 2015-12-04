Matching Algorithms in R and C++
===============
[![Build Status](https://travis-ci.org/jtilly/matchingR.png)](https://travis-ci.org/jtilly/matchingR) 
[![Coverage Status](https://coveralls.io/repos/jtilly/matchingR/badge.svg?branch=master)](https://coveralls.io/r/jtilly/matchingR?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/matchingR)](http://cran.r-project.org/package=matchingR)
[![CRAN_Downloads](http://cranlogs.r-pkg.org/badges/grand-total/matchingR?color=brightgreen)](http://cran.r-project.org/package=matchingR)


[!["You know that I'll never leave you. Not as long as she's with someone."](http://imgs.xkcd.com/comics/all_the_girls.png)](http://xkcd.com/770/ "You know that I'll never leave you. Not as long as she's with someone.")


`matchingR` is an R package which quickly computes the [Gale-Shapley algorithm](http://www.jstor.org/stable/2312726), [Irving's algorithm for the stable roommate problem](http://www.sciencedirect.com/science/article/pii/0196677485900331), and the [top trading cycle algorithm](http://pareto.uab.es/jmasso/pdf/ShapleyScarfJME1974.pdf) for large matching markets. The package provides functions to compute the solutions to the
  [stable marriage problem](http://en.wikipedia.org/wiki/Stable_matching), the
  [college admission problem](http://en.wikipedia.org/wiki/Hospital_resident), the
  [stable roommates problem](http://en.wikipedia.org/wiki/Stable_roommates_problem), and the
  [house allocation problem](http://web.stanford.edu/~niederle/HouseAllocation.pdf).
  
The package may be useful when the number of market participants is large or when many matchings need to be computed (e.g., for simulation or estimation purposes). It has been used in practice to compute the Gale-Shapley stable matching with 30,000 participants on each side of the market.

Matching markets are common in practice and widely studied by economists. Popular examples include

 * the [National Resident Matching Program](http://www.nrmp.org/) which matches graduates from medical school to residency programs at teaching hospitals throughout the United States
 * the matching of students to schools including the [New York City High School Match](http://www.jstor.org/stable/4132848) or the [Boston Public School Match](http://www.jstor.org/stable/4132849) (and many more)
 * the matching of kidney donors to recipients in [kidney exchanges](http://www.jstor.org/stable/4132851).

Installation
------------

`matchingR` may be installed from [CRAN](http://cran.r-project.org/package=matchingR):
```R
install.packages("matchingR")
```
The latest development release is available from GitHub:
```R
#install.packages("devtools")
devtools::install_github("jtilly/matchingR")
```

## Examples

### Gale-Shapley Algorithm for Two-Sided Markets

**Stable Marriage Problem**
``` r
# stable marriage problem with three men and two women
uM = matrix(c(1.0, 0.5, 0.0,
              0.5, 0.0, 0.5), nrow = 2, ncol = 3, byrow = TRUE)

uW = matrix(c(0.0, 1.0,
              0.5, 0.0,
              1.0, 0.5), nrow = 3, ncol = 2, byrow = TRUE)

matching = galeShapley(uM, uW)
matching$engagements
#>      [,1]
#> [1,]    3
#> [2,]    1
matching$single.proposers
#> [1] 2
galeShapley.checkStability(uM, uW, matching$proposals, matching$engagements)
#> [1] TRUE
```

**College Admissions Problem**
``` r
# college admissions problem with five students and two colleges with two slots each
set.seed(1)
nStudents = 5
nColleges = 2
uStudents = matrix(runif(nStudents*nColleges), nrow=nColleges, ncol=nStudents)
uStudents
#>           [,1]      [,2]      [,3]      [,4]       [,5]
#> [1,] 0.2655087 0.5728534 0.2016819 0.9446753 0.62911404
#> [2,] 0.3721239 0.9082078 0.8983897 0.6607978 0.06178627
uColleges = matrix(runif(nStudents*nColleges), nrow=nStudents, ncol=nColleges)
uColleges
#>           [,1]      [,2]
#> [1,] 0.2059746 0.4976992
#> [2,] 0.1765568 0.7176185
#> [3,] 0.6870228 0.9919061
#> [4,] 0.3841037 0.3800352
#> [5,] 0.7698414 0.7774452
matching = galeShapley.collegeAdmissions(uStudents, uColleges, slots=2)
matching$matched.students
#>      [,1]
#> [1,]   NA
#> [2,]    2
#> [3,]    2
#> [4,]    1
#> [5,]    1
matching$matched.colleges
#>      [,1] [,2]
#> [1,]    5    4
#> [2,]    3    2
galeShapley.checkStability(uStudents, uColleges, matching$matched.students, matching$matched.colleges)
#> [1] TRUE
```

### Irving's Algorithm for the Stable Roommate Problem
``` r
# stable roommate problem with four students and two rooms
set.seed(2)
n = 4
u = matrix(runif(n^2),  nrow = n, ncol = n)
u
#>           [,1]      [,2]      [,3]      [,4]
#> [1,] 0.1848823 0.9438393 0.4680185 0.7605133
#> [2,] 0.7023740 0.9434750 0.5499837 0.1808201
#> [3,] 0.5733263 0.1291590 0.5526741 0.4052822
#> [4,] 0.1680519 0.8334488 0.2388948 0.8535485
results = roommate(utils = u)
results
#>      [,1]
#> [1,]    2
#> [2,]    1
#> [3,]    4
#> [4,]    3
```

### Top-Trading Cycle Algorithm
``` r
# top trading cycle algorithm with four houses
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
#>      [,1]
#> [1,]    2
#> [2,]    1
#> [3,]    3
#> [4,]    4
```

## Documentation
* [Reference Manual](https://cran.r-project.org/web/packages/matchingR/matchingR.pdf "Matching Algorithms in R and C++: Reference Manual")
* [Vignette: Matching Algorithms in R and C++: An Introduction to matchingR](https://cran.r-project.org/web/packages/matchingR/vignettes/matchingR-intro.html "Matching Algorithms in R and C++: An Introduction to matchingR")
* [Vignette: Matching Algorithms in R and C++: Computational Performance](https://cran.r-project.org/web/packages/matchingR/vignettes/matchingR-performance.html "Matching Algorithms in R and C++: Computational Performance")
