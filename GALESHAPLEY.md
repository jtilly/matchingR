## Gale-Shapley Algorithm: How does it work?
Consider a market with three men and three women. The men's preferences are given by
```{r}
prefM = matrix(c(1, 3, 3,
                 2, 1, 2,
                 3, 2, 1), nrow = 3, ncol = 3, byrow = TRUE)
```
`prefM` states that man `1` prefers woman `1` over woman `2` over woman `3`. Man `2` prefers woman `3` over woman `1` over woman `2`. Man `3` prefers woman `3` over woman `2` over woman `1`. The women's preferences are given by
```{r}
prefW = matrix(c(3, 1, 3,
                 2, 3, 2,
                 1, 2, 1), nrow = 3, ncol = 3, byrow = TRUE)
```
`prefW` states that woman `1` prefers man `3` over man `2` over man `1`, etc. 

We can now compute the Gale-Shapley Algorithm by hand. For the preferences defined in `prefM` and `prefW` it takes five rounds until all men (and women) are matched. 

1. Man `1` proposes to woman `1`, his most-preferred choice. 
    Unmatched men: `2`, `3`.
2. Man `2` proposes to woman `3`, his most-preferred choice. 
    Unmatched men: `3`.
3. Man `3` proposes to woman `3`, his most-preferred choice. 
    Woman `3` now dumps man `2`. 
    Unmatched men: `2`.
4. Man `2` proposes to woman `1`, his most-preferred *available* choice.  
    Woman `1` now dumps man `1`. 
    Unmatched men: `1`.
5. Man `1` proposes to woman `2`, his most-preferred *available* choice. 
    All men are now matched.

The male-optimal stable matching is therefore:

|   Man  |  Woman   |
|--------|----------|
|  Man 1 |  Woman 2 |
|  Man 2 |  Woman 1 |
|  Man 3 |  Woman 3 |

This matching can be computed using
```{r}
results = one2one(proposerPref = prefM, reviewerPref = prefW)
```
The original Gale-Shapley algorithm can be easily modified to accommodate unequal numbers of participants on each side of the market as well as one-to-many matchings, i.e. the matching of workers to multi-worker firms or the matching of students to colleges.

## Examples
### Marriage Market
The following is an example of `one2one` with different numbers of participants on each side of the market. By construction, 500 men will remain unmatched.
```{r}
# set seed
set.seed(1)

# set number of men
nmen = 2500

# set number of women
nwomen = 2000

# generate preferences
uM = matrix(runif(nmen*nwomen), nrow=nwomen, ncol=nmen) 
uW = matrix(runif(nmen*nwomen), nrow=nmen, ncol=nwomen) 

# male optimal matching
resultsM = matchingR::one2one(uM, uW)
# female optimal matching
resultsW = matchingR::one2one(uW, uM)

# check if matchings are stable
matchingR::checkStability(uM, uW, resultsM$proposals, resultsM$engagements)
matchingR::checkStability(uW, uM, resultsW$proposals, resultsW$engagements)
```

### College Admissions Problem
The following is an example of `one2many` where 1,000 students get matched to 400 colleges, where each college has two slots. By construction, 200 students will remain unmatched.
```{r}
# set seed
set.seed(1)

# set number of students
nstudents = 1000

# set number of colleges
ncolleges = 400

# generate preferences
uStudents = matrix(runif(ncolleges*nstudents), nrow=ncolleges, ncol=nstudents) 
uColleges = matrix(runif(nstudents*ncolleges), nrow=nstudents, ncol=ncolleges) 

# worker optimal matching
results = matchingR::one2many(uStudents, uColleges, slots=2)

# check if matching is stable
matchingR::checkStability(uStudents, uColleges, results$proposals, results$engagements)
```
