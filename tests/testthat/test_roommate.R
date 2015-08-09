# test_roommate.R
# test matching using Irving's Algorithm for the stable roommate problem

test_that("Stable roommate?", {
    set.seed(1)
    for (i in c(4, 8, 16, 32, 128, 256)) {
        p = validateInputsOneSided(utils = replicate(i, rnorm(i-1)))
        results = onesided(pref = p)
        expect_true(checkStabilityRoommate(pref = p, matchings = results))
    }
})

test_that("Check preference orderings for one sided matching", {
    p = as.matrix(c(0, 1, 2), nrow = 1, ncol = 3)
    expect_error(validateInputsOneSided(pref = p))
    expect_error(validateInputsOneSided(utils = p))
})


test_that("Row vs column major?", {
    # generate preferences
    set.seed(1)
    utils = matrix(rnorm(100), ncol=10, nrow=10)
    p = validateInputsOneSided(utils = utils)
    
    # use preference orderings
    set.row.major()
    results.row.major = onesided(pref = t(p))
    set.column.major()
    results.column.major = onesided(pref = p)
    expect_true(identical(results.row.major, results.column.major))
    
    # do the same with payoff matrices instead of preference orderings
    set.row.major()
    results.row.major = onesided(utils = t(utils))
    set.column.major()
    results.column.major = onesided(utils = utils)
    expect_true(identical(results.row.major, results.column.major))
    
})
