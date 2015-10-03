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
    
    # generate error
    expect_error(roommate.validate())
    
    # generate error
    p = matrix(c(0, 1, 2), nrow = 1, ncol = 3)
    expect_error(roommate.validate(pref = p))
    
    # generate error
    u = matrix(c(3, 2, 1), nrow = 1, ncol = 3)
    expect_error(roommate.validate(utils = u))
    
    # generate warning
    u = matrix(runif(6), nrow = 2, ncol = 3)
    p = sortIndexOneSided(u)
    expect_warning(roommate.validate(utils = u, pref = p))
    
    # incomplete preferences
    p = matrix(c(1, 0, 1, 
                 3, 2, 0), nrow = 2, byrow = TRUE)
    expect_error(roommate.validate(pref = p))

    # check C++ vs R style indexing
    p = matrix(c(1, 0, 1, 
                 2, 2, 0), nrow = 2, byrow = TRUE)
    expect_identical(roommate.checkPreferences(p), 
                     roommate.checkPreferences(p + 1))
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
