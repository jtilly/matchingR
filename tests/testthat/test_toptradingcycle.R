# test_toptradingcycle.R
# test the top trading cycle algorithm

test_that("Stable?", {
    set.seed(1)
    for (i in c(4, 8, 16, 32, 128, 256)) {
        utils = replicate(i, rnorm(i))
        args = validateInputs(proposerPref = NULL, reviewerPref = NULL, proposerUtils = utils, reviewerUtils = utils)$proposerPref
        results = toptrading(pref = args)
        expect_true(checkStabilityTopTradingCycle(args, results$matchings-1))
    }
})