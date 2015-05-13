# matchingR: Efficient Computation of the Gale-Shapley Algorithm in R and C++  [![Build Status](https://travis-ci.org/jtilly/matchingR.png)](https://travis-ci.org/jtilly/matchingR) [![Coverage Status](https://coveralls.io/repos/jtilly/matchingR/badge.svg?branch=master)](https://coveralls.io/r/jtilly/matchingR?branch=master)
matchingR is an R Package that quickly computes the Gale-Shapley Algorithm for large scale matching markets. This package can be useful when the number of market participants is large or when very many matchings need to be computed (e.g. for extensive simulations or for estimation purposes). The package has successfully been used to simulate preferences and compute the matching with 30,000 participants on each side of the market.

## Depends on
* [Rcpp](http://cran.r-project.org/web/packages/Rcpp/index.html)
* [RcppArmadillo](http://cran.r-project.org/web/packages/RcppArmadillo/index.html)


## Installation
This package can be installed from [CRAN](http://cran.r-project.org/web/packages/matchingR/):
```
install.packages("matchingR", type="source")
```
Binaries will be available soon.

## Documentation
* [Documentation as PDF](http://jtilly.io/matchingR/matchingR.pdf)

## Example: Marriage Market
```
library("matchingR")

# set seed for replicability
set.seed(1)
# set commonality
commonality = 0.5
# set number of men
nmen = 2500
# set number of women
nwomen = 2000

# generate preferences
uM = commonality * matrix(runif(nwomen), nrow=nmen, ncol=nwomen, byrow = TRUE) + (1-commonality) * runif(nmen*nwomen)
uW = commonality * matrix(runif(nmen), nrow=nwomen, ncol=nmen, byrow = TRUE) + (1-commonality) * runif(nwomen*nmen)

# male optimal matching
resultsM = one2one(uM, uW)
# female optimal matching
resultsW = one2one(uW, uM)

# check if matching is stable
checkStability(uM, uW, resultsM$proposals, resultsM$engagements)
checkStability(uW, uM, resultsW$proposals, resultsW$engagements)
```

## Example: College Admissions Problem
```
library("matchingR")

# set seed for replicability
set.seed(1)
# set commonality
commonality = 0.5
# set number of workers
nstudents = 1000
# set number of colleges
ncolleges = 400

# generate preferences
uStudents = commonality * matrix(runif(ncolleges), nrow=nworkers, ncol=ncolleges, byrow = TRUE) + (1-commonality) * runif(nworkers*ncolleges)
uColleges = commonality * matrix(runif(nworkers), nrow=ncolleges, ncol=nworkers, byrow = TRUE) + (1-commonality) * runif(ncolleges*nworkers)

# worker optimal matching
results = one2many(uStudents, uColleges, slots=2)

# check if matching is stable
checkStability(uStudents, uColleges, results$proposals, results$engagements)
```
