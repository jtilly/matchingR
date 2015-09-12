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
devtools::install_github("jtilly/matchingR.git")
```

## Examples
```{r}
# stable marriage problem
nmen = 25
nwomen = 20
uM = matrix(runif(nmen*nwomen), nrow=nwomen, ncol=nmen)
uW = matrix(runif(nwomen*nmen), nrow=nmen, ncol=nwomen)
results = one2one(uM, uW)
checkStability(uM, uW, results$proposals, results$engagements)

# college admissions problem
nstudents = 25
ncolleges = 5
uStudents = matrix(runif(nstudents*ncolleges), nrow=ncolleges, ncol=nstudents)
uColleges = matrix(runif(nstudents*ncolleges), nrow=nstudents, ncol=ncolleges)
results = one2many(uStudents, uColleges, slots=4)
checkStability(uStudents, uColleges, results$proposals, results$engagements)

# stable roommate problem
n = 10
u = matrix(runif(N^2),  nrow = n, ncol = n)
results = onesided(utils = u)

# top trading cycle algorithm
n = 10
u = matrix(runif(N^2),  nrow = n, ncol = n)
results = toptrading(utils = u)
```

## Documentation
* [Reference Manual](http://jtilly.io/matchingR/matchingR-documentation.pdf "Computing Stable Matchings in R: Reference Manual for matchingR")
* [Vignette: Matching Algorithms in R: An Introduction to matchingR](http://jtilly.io/matchingR/matchingR-intro.html "Matching Algorithms in R: An Introduction to matchingR")
* [Vignette: Matching Algorithms in R: Computational Performance](http://jtilly.io/matchingR/matchingR-performance.html "Matching Algorithms in R: Computational Performance")
