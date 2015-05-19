Gale-Shapley in R
===============
[![Build Status](https://travis-ci.org/jtilly/matchingR.png)](https://travis-ci.org/jtilly/matchingR) 
[![Coverage Status](https://coveralls.io/repos/jtilly/matchingR/badge.svg?branch=master)](https://coveralls.io/r/jtilly/matchingR?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/matchingR)](http://cran.r-project.org/web/packages/matchingR)


[![You know that I'll never leave you. Not as long as she's with someone.](http://imgs.xkcd.com/comics/all_the_girls.png)](http://xkcd.com/770/)


`matchingR` is an R Package that efficiently computes the [Gale-Shapley Algorithm](http://en.wikipedia.org/wiki/Stable_marriage_problem) for large matching markets. The package can be useful when the number of market participants is large or when very many matchings need to be computed (e.g. for extensive simulations or for estimation purposes). The package has successfully been used to simulate preferences and compute the matching with 30,000 participants on each side of the market.

Installation
------------

`matchingR` can be installed from [CRAN](http://cran.r-project.org/web/packages/matchingR/):
```{r}
install.packages("matchingR")
```

## Documentation
* [Reference Manual](http://jtilly.io/matchingR/matchingR-documentation.pdf)
* [Vignette: Introduction to matchingR](http://jtilly.io/matchingR/matchingR-intro.pdf)

## Gale-Shapley Algorithm: How does it work?
Consider a market with three men and three women. The men's preferences are given by
```{r}
prefM = matrix(c(1, 2, 3,
                 3, 1, 2,
                 3, 2, 1), nrow = 3, ncol = 3, byrow = TRUE)
```
Man `1` prefers woman `1` over woman `2` over woman `3`, etc.
The women's preferences are given by
```{r}
prefW = matrix(c(3, 2, 1,
                 1, 3, 2,
                 3, 2, 1), nrow = 3, ncol = 3, byrow = TRUE)
```
Woman `1` prefers man `3` over man `2` over man `1`, etc. 

We can now compute the Gale-Shapley Algorithm by hand:

 1. * Man `1` proposes to woman `1`, his most-preferred choice.
    * Unmatched men: `2`, `3`
 2. * Man `2` proposes to woman `3`, his most-preferred choice. 
    * Unmatched men: `3`
 3. * Man `3` proposes to woman `3`, his most-preferred choice.
    * Woman `3` now dumps man `2`. 
    * Unmatched men: `2`
 4. * Man `2` proposes to woman `1`, his most-preferred available choice. 
    * Woman `1` now dumps man `1`. 
    * Unmatched men: `1`
 5. * Man `1` proposes to woman `2`, his most-preferred available choice. 
    * All men are now matched.
 
 The male-optimal stable matching is thefore:
 
 |-------|---------|
 | Man 1 | Woman 2 |
 | Man 2 | Woman 1 |
 | Man 3 | Woman 3 |

### Example: Marriage Market
The following is an example of `one2one` with different numbers of participants on each side of the market. By construction, 500 men will remain unmatched.
```{r}
# set seed
set.seed(1)

# set number of men
nmen = 2500

# set number of women
nwomen = 2000

# generate preferences
uM = matrix(runif(nmen*nwomen), nrow=nmen, ncol=nwomen) 
uW = matrix(runif(nmen*nwomen), nrow=nwomen, ncol=nmen) 

# male optimal matching
resultsM = one2one(uM, uW)
# female optimal matching
resultsW = one2one(uW, uM)

# check if matchings are stable
checkStability(uM, uW, resultsM$proposals, resultsM$engagements)
checkStability(uW, uM, resultsW$proposals, resultsW$engagements)
```

### Example: College Admissions Problem
The following is an example of `one2many` where 1000 students get matched to 400 colleges, where each college has two slots. By construction, 200 students will remain unmatched.
```{r}
# set seed
set.seed(1)

# set number of students
nstudents = 1000

# set number of colleges
ncolleges = 400

# generate preferences
uStudents = matrix(runif(ncolleges*nstudents), nrow=nstudents, ncol=ncolleges) 
uColleges = matrix(runif(nstudents*ncolleges), nrow=ncolleges, ncol=nstudents) 

# worker optimal matching
results = one2many(uStudents, uColleges, slots=2)

# check if matching is stable
checkStability(uStudents, uColleges, results$proposals, results$engagements)
```
