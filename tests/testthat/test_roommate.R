# test_roommate.R
# test matching using Irving's Algorithm for the stable roommate problem

test_that("Stable roommate?", {
    set.seed(1)
    for (i in c(4, 8, 16, 32, 128, 256)) {
        p = roommate.validate(utils = replicate(i, rnorm(i-1)))
        results = roommate.matching(pref = p)
        expect_true(roommate.checkStability(pref = p, matching = results))
    }
})

test_that("Check preference orderings for one sided matching", {
    p = as.matrix(c(0, 1, 2), nrow = 1, ncol = 3)
    expect_error(roommate.validate(pref = p))
    expect_error(roommate.validate(utils = p))
})


test_that("Row vs column major?", {
    # generate preferences
    set.seed(1)
    utils = matrix(rnorm(100), ncol=10, nrow=10)
    p = roommate.validate(utils = utils)

    # use preference orderings
    set.row.major()
    results.row.major = roommate.matching(pref = t(p))
    set.column.major()
    results.column.major = roommate.matching(pref = p)
    expect_true(identical(results.row.major, results.column.major))

    # do the same with payoff matrices instead of preference orderings
    set.row.major()
    results.row.major = roommate.matching(utils = t(utils))
    set.column.major()
    results.column.major = roommate.matching(utils = utils)
    expect_true(identical(results.row.major, results.column.major))

})
