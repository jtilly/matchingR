# test_toptradingcycle.R
# test the top trading cycle algorithm

test_that("Stable?", {
    set.seed(1)
    for (i in c(4, 8, 16, 32, 128, 256)) {
        p = validateInputsOneSided(utils = replicate(i, rnorm(i-1)))
        results = onesided(pref = p)
        expect_true(checkStabilityRoommate(pref = p, matchings = results))
    }
})