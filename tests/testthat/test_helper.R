# test_helper.R
# test some of the helper functions

test_that("Check if sortIndex and rankIndex offset each other", {
    u = matrix(runif(12), nrow=4, ncol=3)
    expect_true(all(sortIndex(-rankIndex(sortIndex(u))) == sortIndex(u)))
})

test_that("Check if sortIndex works", {
    u = matrix(c(3, 2, 8, 1, 12, 2, 9, 2, 13, 5, 3.1, 2.1), nrow=4, ncol=3)
    expect_true(all(sortIndex(u) == c(2, 2, 1, 2, 1, 0, 0, 1, 0, 1, 2, 0)))
})

test_that("Check if rankIndex works", {
    u = matrix(c(2, 2, 1, 2, 1, 0, 0, 1, 0, 1, 2, 0), nrow=4, ncol=3)
    expect_true(all(rankIndex(u) == c(2, 1, 1, 2, 1, 2, 0, 1, 0, 0, 2, 0)))
})
