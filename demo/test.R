# test.R 
# This demo shows how this package can be used in action. It simulates 
# preferences for a matching market and computes the Gale-Shapley Algorithm with 
# both male and female proposers
require("matchingR")

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
