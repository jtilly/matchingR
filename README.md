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

## Example: Multi Worker Firms
```
library("matchingR")

# set seed for replicability
set.seed(1)
# set commonality
commonality = 0.5
# set number of workers
nworkers = 10
# set number of firms
nfirms = 4

# generate preferences
uWorkers = commonality * matrix(runif(nfirms), nrow=nworkers, ncol=nfirms, byrow = TRUE) + (1-commonality) * runif(nworkers*nfirms)
uFirms = commonality * matrix(runif(nworkers), nrow=nfirms, ncol=nworkers, byrow = TRUE) + (1-commonality) * runif(nfirms*nworkers)

# worker optimal matching
results = one2many(uWorkers, uFirms, slots=2)

# check if matching is stable
checkStability(uWorkers, uFirms, results$proposals, results$engagements)
```
