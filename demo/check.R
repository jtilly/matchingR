# check.R
# This script compares the implementation of this package to the output of the 
# function matchingMarkets::daa() 
library("matchingR")

# install package if needed
# devtools::install_github("thiloklein/matchingMarkets")
set.seed(123)

# students are proposing
nStudents = 14
# colleges are reviewing
nColleges = 12

# use matchingMarkets::da() to simulate preferences and compute the matching
matching1 = matchingMarkets::daa(nStudents = nStudents, nColleges = nColleges)
# make a vector of engagements: row n corresponds to the id of the student
# that college n is matched to
matching1$engagements = matrix(unlist(matching1$matches), ncol=1)

# now use my matchingR::one2one to compute the matching
matching2 = one2many(proposerPref = t(matching1$s.prefs)-1, reviewerPref = t(matching1$c.prefs)-1)
# adjust convention for unmatched colleges
matching2$engagements[matching2$engagements==nStudents]=-1
# add 1 to C++ indicies to make them comparable to R
matching2$engagements = matching2$engagements+1

# compare engagements
if(any(matching1$engagements != matching2$engagements)) {
    stop("the two packages produce different results.")
} else {
    print("The packages matchingR and matchingMarkets produce identitical results.")
}
