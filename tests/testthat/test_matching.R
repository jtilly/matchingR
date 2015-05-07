# test_matching.R
# test the matching algorithms

test_that("Check if one2one matching is stable", {
    uM = matrix(runif(12), nrow=4, ncol=3)
    uW = matrix(runif(12), nrow=3, ncol=4)
    matching = one2one(uM, uW)
    expect_true(checkStability(uM, uW, matching$proposals, matching$engagements))
})

test_that("Check if one2many matching is stable", {
    uM = matrix(runif(12), nrow=4, ncol=2)
    uW = matrix(runif(8), nrow=2, ncol=4)
    matching = one2many(uM, uW, slots=2)
    expect_true(checkStability(uM, uW, matching$proposals, matching$engagements))
})

test_that("Check if many2one matching is stable", {
    uM = matrix(runif(6), nrow=2, ncol=3)
    uW = matrix(runif(6), nrow=3, ncol=2)
    matching = many2one(uM, uW, slots=2)
    expect_true(checkStability(uM, uW, matching$proposals, matching$engagements))
})

test_that("Check if using preferences as inputs yields the same results as when using cardinal utilities as inputs", {
    uM = matrix(runif(16*14), nrow=16, ncol=14)
    uW = matrix(runif(16*14), nrow=14, ncol=16)
    matching1 = one2one(uM, uW)
    matching2 = one2one(proposerPref = sortIndex(uM), reviewerPref = sortIndex(uW))
    expect_true(all(matching1$engagements==matching2$engagements))
})

test_that("Check outcome from one2one matching", {
    uM = matrix(c(0, 1, 
                  1, 0, 
                  0, 1), byrow = TRUE, nrow=3, ncol=2)  
    uW = matrix(c(0, 2, 1, 
                  1, 0, 2), byrow = TRUE, nrow=2, ncol=3)
    matching = one2one(uM, uW)
    expect_true(all(matching$engagements == c(1,2)))
    expect_true(all(matching$proposals == c(2, 0, 1)))
})

test_that("Check outcome from one2many matching", {
    uM = matrix(c(0, 1, 
                  1, 0, 
                  0, 1), byrow = TRUE, nrow=3, ncol=2)  
    uW = matrix(c(0, 2, 1, 
                  1, 0, 2), byrow = TRUE, nrow=2, ncol=3)
    matching = one2many(uM, uW, slots=2)
    expect_true(all(matching$engagements == c(1,2, 3, 0)))
    expect_true(all(matching$proposals == c(1, 0, 1)))
})

test_that("Check outcome from many2one matching", {
    uM = matrix(c(0, 1, 
                  1, 0, 
                  0, 1), byrow = TRUE, nrow=3, ncol=2)  
    uW = matrix(c(0, 2, 1, 
                  1, 0, 2), byrow = TRUE, nrow=2, ncol=3)
    matching = many2one(uM, uW, slots=2)
    expect_true(all(matching$engagements == c(1,2)))
    expect_true(all(matching$proposals == c(2, 2, 2, 2, 0, 1)))
})
