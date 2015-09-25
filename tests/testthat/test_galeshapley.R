# test_galeshapley.R
# test matching with the Gale-Shapley Algorithm

test_that("Check if galeShapley.marriageMarket matching is stable", {
    uM = matrix(runif(12), nrow = 4, ncol = 3)
    uW = matrix(runif(12), nrow = 3, ncol = 4)
    matching.one2one = one2one(uM, uW)
    expect_true(checkStability(uM, uW, matching.one2one$proposals, matching.one2one$engagements))
    matching.marriageMarket = galeShapley.marriageMarket(uM, uW)
    expect_true(checkStability(uM, uW, matching.marriageMarket$proposals, matching.marriageMarket$engagements))
    expect_true(identical(matching.marriageMarket, matching.one2one))
})


test_that("Check if galeShapley.collegeAdmissions matching is stable", {
    uM = matrix(runif(16), nrow = 2, ncol = 8)
    uW = matrix(runif(16), nrow = 8, ncol = 2)
    matching = galeShapley.collegeAdmissions(uM, uW, slots = 4)
    expect_true(checkStability(uM, uW, matching$proposals, matching$engagements))
    matching = galeShapley.collegeAdmissions(uM, uW, slots = 8)
    expect_true(checkStability(uM, uW, matching$proposals, matching$engagements))
    matching = galeShapley.collegeAdmissions(uM, uW, slots = 10)
    expect_true(checkStability(uM, uW, matching$proposals, matching$engagements))
})

test_that("Check if college-optimal galeShapley.collegeAdmissions matching is stable", {
    uM = matrix(runif(6), nrow = 3, ncol = 2)
    uW = matrix(runif(6), nrow = 2, ncol = 3)
    matching = galeShapley.collegeAdmissions(uM, uW, slots = 2, studentOptimal = FALSE)
    expect_true(checkStability(uW, uM, matching$proposals, matching$engagements))
})

test_that(
    "Check if using preferences as inputs yields the same results as when using cardinal utilities as inputs", {
        uM = matrix(runif(16 * 14), nrow = 14, ncol = 16)
        uW = matrix(runif(16 * 14), nrow = 16, ncol = 14)
        matching1 = galeShapley.marriageMarket(uM, uW)
        matching2 = galeShapley.marriageMarket(proposerPref = sortIndex(uM), reviewerPref = sortIndex(uW))
        expect_true(all(matching1$engagements == matching2$engagements))
    }
)

test_that(
    "Check if using preferences as inputs with R indices yields the same results as when using cardinal utilities as inputs", {
        uM = matrix(runif(16 * 14), nrow = 16, ncol = 14)
        uW = matrix(runif(16 * 14), nrow = 14, ncol = 16)
        matching1 = galeShapley.marriageMarket(uM, uW)
        matching2 = galeShapley.marriageMarket(proposerPref = sortIndex(uM) + 1, reviewerPref = sortIndex(uW) + 1)
        expect_true(all(matching1$engagements == matching2$engagements))
    }
)

test_that("Check if incorrect preference orders result in an error", {
    uM = matrix(runif(16 * 14), nrow = 16, ncol = 14)
    uW = matrix(runif(16 * 14), nrow = 14, ncol = 16)
    proposerPref = sortIndex(uM) + 1
    reviewerPref = sortIndex(uW) + 1

    proposerPrefPrime = proposerPref
    proposerPrefPrime[1,1] = 9999

    reviewerPrefPrime = reviewerPref
    reviewerPrefPrime[1,1] = 9999

    expect_error(
        galeShapley.marriageMarket(proposerPref = proposerPrefPrime, reviewerPref = reviewerPref),
        "proposerPref was defined by the user but is not a complete list of preference orderings"
    )
    expect_error(
        galeShapley.marriageMarket(proposerPref = proposerPref, reviewerPref = reviewerPrefPrime),
        "reviewerPref was defined by the user but is not a complete list of preference orderings"
    )
})

test_that("Check null inputs", {
    expect_error(galeShapley.marriageMarket(),
                 "missing proposer preferences")
    uM = matrix(runif(16 * 14), nrow = 16, ncol = 14)
    expect_error(galeShapley.marriageMarket(uM),
                 "missing reviewer utilities")
    expect_error(galeShapley.marriageMarket(proposerPref = sortIndex(uM)),
                 "missing reviewer utilities")
})

test_that("Check if incorrect dimensions result in error", {
    uM = matrix(runif(16 * 14), nrow = 16, ncol = 14)
    uW = matrix(runif(15 * 15), nrow = 15, ncol = 15)
    expect_error(galeShapley.marriageMarket(uM, uW), "preference orderings must be symmetric")
    expect_error(
        galeShapley.marriageMarket(proposerPref = sortIndex(uM), reviewerUtils = uW),
        "preference orderings must be symmetric"
    )
    uM = matrix(runif(16 * 16), nrow = 16, ncol = 16)
    uW = matrix(runif(15 * 16), nrow = 15, ncol = 16)
    expect_error(
        galeShapley.marriageMarket(proposerPref = sortIndex(uM), reviewerUtils = uW),
        "preference orderings must be symmetric"
    )
})

test_that("Check outcome from galeShapley.marriageMarket matching", {
    uM = matrix(c(0, 1,
                  1, 0,
                  0, 1), nrow = 2, ncol = 3)
    uW = matrix(c(0, 2, 1,
                  1, 0, 2), nrow = 3, ncol = 2)
    matching = galeShapley.marriageMarket(uM, uW)
    expect_true(all(matching$engagements == c(1,2) + 1))
    expect_true(all(matching$proposals == c(2, 0, 1) + 1))
})

test_that("Check outcome from student-optimal galeShapley.collegeAdmissions matching", {
    uM = matrix(c(0, 1,
                  1, 0,
                  0, 1), nrow = 2, ncol = 3)
    uW = matrix(c(0, 2, 1,
                  1, 0, 2), nrow = 3, ncol = 2)
    matching = galeShapley.collegeAdmissions(uM, uW, slots = 2)
    expect_true(all(matching$engagements == c(1,2, 3, 0) + 1))
    expect_true(all(matching$proposals == c(1, 0, 1) + 1))
})

test_that("Check outcome from collge-optimal galeShapley.collegeAdmissions matching", {
    uM = matrix(c(0, 1,
                  1, 0,
                  0, 1), nrow = 2, ncol = 3)
    uW = matrix(c(0, 2, 1,
                  1, 0, 2), nrow = 3, ncol = 2)
    matching = galeShapley.collegeAdmissions(uW, uM, slots = 2, studentOptimal = FALSE)
    expect_true(all(matching$engagements == c(1,2) + 1))
    expect_true(all(matching$proposals == c(2, 2, 2, 2, 0, 1) + 1))
})

test_that("Check checkStability", {
    # define preferences
    uM = matrix(c(0, 1,
                  1, 0,
                  0, 1), nrow = 2, ncol = 3)
    uW = matrix(c(0, 2, 1,
                  1, 0, 2), nrow = 3, ncol = 2)
    # define matchings (this one is correct)
    matching = list("engagements" = as.matrix(c(1,2) + 1),
                    "proposals" = as.matrix(c(2, 0, 1) + 1))
    # check if the matching is stable
    expect_true(checkStability(uM, uW, matching$proposals, matching$engagements))
    # swap proposals and engagements (this one isn't stable)
    expect_false(suppressWarnings(checkStability(uM, uW, matching$engagements, matching$proposals)))
})


test_that("Assortative matching?", {
    uM = matrix(runif(16), nrow = 4, ncol = 4)
    uW = matrix(runif(16), nrow = 4, ncol = 4)
    diag(uM)[] = 2
    diag(uW)[] = 2
    matching = galeShapley.marriageMarket(uM, uW)
    expect_true(all(matching$proposals == 1:4))
    expect_true(all(matching$engagements == 1:4))
})

test_that("Check if we can store preferences in row-major order:", {

    # simulate preferences
    uM = matrix(runif(12), nrow = 4, ncol = 3)
    uW = matrix(runif(12), nrow = 3, ncol = 4)
    prefM = sortIndex(uM)
    prefW = sortIndex(uW)

    # use payoff matrices to define preferences
    set.row.major()
    matching.row.major = galeShapley.marriageMarket(t(uM), t(uW))
    set.column.major()
    matching.column.major = galeShapley.marriageMarket(uM, uW)
    expect_true(identical(matching.column.major$proposals, matching.row.major$proposals))
    expect_true(identical(matching.column.major$engagements, matching.row.major$engagements))

    # repeat the same thing with preference orders as arguments
    set.row.major()
    matching.row.major = galeShapley.marriageMarket(proposerPref = t(prefM), reviewerPref = t(prefW))
    set.column.major()
    matching.column.major = galeShapley.marriageMarket(proposerPref = prefM, reviewerPref = prefW)
    expect_true(identical(matching.column.major$proposals, matching.row.major$proposals))
    expect_true(identical(matching.column.major$engagements, matching.row.major$engagements))
})
