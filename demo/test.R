# test.R 
# This demo shows how this package can be used in action. It simulates 
# preferences for a matching market and computes the Gale-Shapley Algorithm with 
# both male and female proposers
require("matchingR")

# set seed for replicability
set.seed(1)
# number of firms
M = 2000
# number of workers
N = 2500

# generate preferences for firms and workers
uFirms = matrix(runif(N*M), nrow=M, ncol=N) 
uWorkers = matrix(runif(N*M), nrow=N, ncol=M)

# compute the firm-optimal one-to-one matching
res.one2one = one2one(uFirms, uWorkers)

# this will leave 500 workers unmatched
length(res.one2one$single.reviewers)

# check if matching is stable
checkStability(uFirms, uWorkers, res.one2one$proposals, res.one2one$engagements)

# workers proposing to multi-worker firms
res.one2many = one2many(uWorkers, uFirms, slots=2)

# this will leave 1500 positions vacant
length(res.one2many$single.reviewers)

# check if matching is stable
checkStability(uWorkers, uFirms, res.one2many$proposals, res.one2many$engagements)

# multi-worker firms proposing to workers
res.many2one = many2one(uFirms, uWorkers, slots=2)

# this will leave 1500 positions vacant
length(res.many2one$single.proposers)
# check if matching is stable
checkStability(uFirms, uWorkers, res.many2one$proposals, res.many2one$engagements)
