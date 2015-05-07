# matchingR: Efficient Computation of the Gale-Shapley Algorithm in R and C++  [![Build Status](https://travis-ci.org/jtilly/matchingR.png)](https://travis-ci.org/jtilly/matchingR)
R Package that quickly computes the Gale-Shapley Algorithm for large scale matching markets. This package can be useful when the number of market participants is large or when very many matchings need to be computed (e.g. for extensive simulations or for estimation purposes). The package has successfully been used to simulate preferences and compute the matching with 30,000 participants on each side of the market.

## Depends on
* [Rcpp](http://cran.r-project.org/web/packages/Rcpp/index.html)
* [RcppArmadillo](http://cran.r-project.org/web/packages/RcppArmadillo/index.html)
* [tictoc](http://cran.r-project.org/web/packages/tictoc/index.html)

## Installation
```
library("devtools")
install_github("jtilly/matchingR")
```

## Example
```
library("matchingR")

# set seed for replicability
set.seed(1)
# set commonality
commonality = 0.5
# set number of men
M = 2500
# set number of women
N = 2000

# generate preferences
tic()
uM = commonality * matrix(runif(N), nrow=M, ncol=N, byrow = TRUE) + (1-commonality) * runif(N*M)
uW = commonality * matrix(runif(M), nrow=N, ncol=M, byrow = TRUE) + (1-commonality) * runif(M*N)
toc()

tic()
# male optimal matching
resM = one2one(uM, uW)
# female optimal matching
resW = one2one(uW, uM)
toc()

# check if matching is stable
checkStability(uM, uW, resM$proposals, resM$engagements)
checkStability(uW, uM, resW$proposals, resW$engagements)
```
