# test_toptradingcycle.R
# test the top trading cycle algorithm

test_that("Stable?", {
    set.seed(1)
    for (i in c(4, 8, 16, 32, 128, 256)) {
        utils = replicate(i, rnorm(i))
        pref = NULL
        args = validateInputs(proposerPref = pref, reviewerPref = pref, proposerUtils = utils, reviewerUtils = utils)$proposerPref
        results = toptrading(pref = args)
        expect_true(checkStabilityTopTradingCycle(pref = args, matchings = results))
    }
})