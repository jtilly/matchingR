# test_helper.R
# test some of the helper functions

test_that("Check if sortIndex and rankIndex offset each other", {
  u <- matrix(runif(12), nrow = 4, ncol = 3)
  expect_true(all(sortIndex(-rankIndex(sortIndex(u))) == sortIndex(u)))
})

test_that("Check if sortIndex works", {
  u <- matrix(c(3, 2, 8, 1, 12, 2, 9, 2, 13, 5, 3.1, 2.1), nrow = 4, ncol = 3)
  expect_true(all(sortIndex(u) == c(3, 1, 2, 4, 1, 3, 2, 4, 1, 2, 3, 4) - 1))
})

test_that("Check if rankIndex works", {
  u <- matrix(c(2, 2, 1, 2, 1, 0, 0, 1, 0, 1, 2, 0), nrow = 3, ncol = 4, byrow = TRUE)
  expect_true(all(rankIndex(u) == matrix(c(2, 1, 1, 2, 1, 2, 0, 1, 0, 0, 2, 0), nrow = 3, ncol = 4, byrow = TRUE)))
})

test_that("Check reprow", {
  x <- matrix(c(
    2, 4, 5,
    3, 2, 1
  ), ncol = 3, byrow = TRUE)

  y <- reprow(x, 2)
  expect_true(identical(y, rbind(x[1, ], x[1, ], x[2, ], x[2, ])))

  y <- reprow(x, c(2, 2))
  expect_true(identical(y, rbind(x[1, ], x[1, ], x[2, ], x[2, ])))

  y <- reprow(x, c(2, 1))
  expect_true(identical(y, rbind(x[1, ], x[1, ], x[2, ])))
})

test_that("Check repcol", {
  x <- matrix(c(
    2, 4, 5,
    3, 2, 1
  ), ncol = 3, byrow = TRUE)

  y <- repcol(x, 2)
  expect_true(identical(y, cbind(x[, 1], x[, 1], x[, 2], x[, 2], x[, 3], x[, 3])))

  y <- repcol(x, c(2, 2, 2))
  expect_true(identical(y, cbind(x[, 1], x[, 1], x[, 2], x[, 2], x[, 3], x[, 3])))

  y <- repcol(x, c(2, 3, 1))
  expect_true(identical(y, cbind(x[, 1], x[, 1], x[, 2], x[, 2], x[, 2], x[, 3])))
})
