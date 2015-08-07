### The Gale-Shapley Algorithm in Action: Additional Examples
#### Marriage Market
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

#### College Admissions Problem
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
