# test_toptradingcycle.R
# test the top trading cycle algorithm

test_that("Stable?", {
    set.seed(1)
    for (i in c(4, 8, 16, 32, 128, 256)) {
        utils = replicate(i, rnorm(i))
        results = toptrading(utils = utils)
        expect_true(toptrading.checkStability(utils = utils, matchings = results))
    }
})

test_that("Check stability function when it should break", {
  
    utils = structure(c(-0.626453810742332, 0.183643324222082, -0.835628612410047, 
                        1.59528080213779, 0.329507771815361, -0.820468384118015, 0.487429052428485, 
                        0.738324705129217, 0.575781351653492, -0.305388387156356, 1.51178116845085, 
                        0.389843236411431, -0.621240580541804, -2.2146998871775, 1.12493091814311, 
                        -0.0449336090152309), .Dim = c(4L, 4L))
    results = c(1,2,3,4)
    expect_false(toptrading.checkStability(utils = utils, matchings = results))
    
})