# test_toptradingcycle.R
# test the top trading cycle algorithm

test_that("Stable?", {
    set.seed(1)
    for (i in c(4, 8, 16, 32, 128, 256)) {
        utils = replicate(i, rnorm(i))
        results = toptrading.matching(utils = utils)
        expect_true(toptrading.checkStability(utils = utils, matchings = results))
    }
})
