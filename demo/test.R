# test.R 
# This demo shows how this package can be used in action. It simulates 
# preferences for a matching market and computes the Gale-Shapley Algorithm with 
# both male and female proposers
require("matchingR")

# set seed for replicability
set.seed(1)
# set commonality
commonality = 0.5
# number of firms
M = 2000
# number of workers
N = 2500

# generate preferences for firms and workers
tic()
uFirms = commonality * matrix(runif(N), nrow=M, ncol=N, byrow = TRUE) + (1-commonality) * runif(N*M)
uWorkers = commonality * matrix(runif(M), nrow=N, ncol=M, byrow = TRUE) + (1-commonality) * runif(M*N)
toc()

# compute the firm-optimal one-to-one matching
tic()
res.one2one = one2one(uFirms, uWorkers)
toc()

# this will leave 500 workers unmatched
length(res.one2one$single.reviewers)

# check if matching is stable
checkStability(uFirms, uWorkers, res.one2one$proposals, res.one2one$engagements)

# workers proposing to multi-worker firms
tic()
res.one2many = one2many(uWorkers, uFirms, slots=2)
toc()

# this will leave 1500 positions vacant
length(res.one2many$single.reviewers)

# check if matching is stable
checkStability(uWorkers, uFirms, res.one2many$proposals, res.one2many$engagements)

# multi-worker firms proposing to workers
tic()
res.many2one = many2one(uFirms, uWorkers, slots=2)
toc()

# this will leave 1500 positions vacant
length(res.many2one$single.proposers)
# check if matching is stable
checkStability(uFirms, uWorkers, res.many2one$proposals, res.many2one$engagements)
