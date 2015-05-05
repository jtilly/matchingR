# matchingR: Efficient Computation of the Gale-Shapley Algorithm in R and C++
R Package that quickly computes the Gale-Shapley Algorithm for large scale matching markets.

## Depends on
* (http://cran.r-project.org/web/packages/Rcpp/index.html)[Rcpp]
* (http://cran.r-project.org/web/packages/RcppArmadillo/index.html)[RcppArmadillo]
* (http://cran.r-project.org/web/packages/tictoc/index.html)[tictoc]

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
# set number of men/women
N = 2500

# generate preferences
tic()
uM = commonality * matrix(runif(N), nrow=N, ncol=N, byrow = TRUE) + (1-commonality) * runif(N^2)
uW = commonality * matrix(runif(N), nrow=N, ncol=N, byrow = TRUE) + (1-commonality) * runif(N^2)
toc()

# compute preference and rank matrices
# ... prefW[1,2] gives us the index of the second-most preferred man by woman 1
# ... prefM[1,2] gives us the index of the second-most preferred woman by man 1
tic()
prefM = sortIndex(uM)
prefW = sortIndex(uW)
toc()

# compute matching
tic()
resM = galeShapleyMatching(prefM, uW)
resW = galeShapleyMatching(prefW, uM)
toc()

# check if matching is stable
checkStability(uM, uW, resM$proposals, resM$engagements)
checkStability(uW, uM, resW$proposals, resW$engagements)
```
