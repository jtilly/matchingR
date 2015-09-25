#' Uses the Gale-Shapley Algorithm to find solution to the stable marriage
#' problem
#'
#' This function returns the proposer-optimal one-to-one matching. The function
#' needs some description of individuals preferences as inputs. That can be in
#' the form of cardinal utilities or preference orders (or both).
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing
#'   side of the market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side
#'   of the market
#' @param proposerPref is a matrix with the preference order of the proposing
#'   side of the market (only required when \code{proposerUtils} is not
#'   provided)
#' @param reviewerPref is a matrix with the preference order of the courted side
#'   of the market (only required when \code{reviewerUtils} is not provided)
#' @return  A list with the successful proposals and engagements:
#'   \code{proposals} is a vector whose nth element contains the id of the
#'   reviewer that proposer n is matched to. \code{engagements} is a vector
#'   whose nth element contains the id of the proposer that reviewer n is
#'   matched to. \code{single.proposers} is a vector that lists the ids of
#'   remaining single proposers. \code{single.reviewers} is a vector that lists
#'   the ids of remaining single reviewers.
#' @examples
#' nmen = 25
#' nwomen = 20
#' uM = matrix(runif(nmen*nwomen), nrow=nwomen, ncol=nmen)
#' uW = matrix(runif(nwomen*nmen), nrow=nmen, ncol=nwomen)
#' results = galeShapley.marriageMarket(uM, uW)
#'
#' prefM = sortIndex(uM)
#' prefW = sortIndex(uW)
#' results = galeShapley.marriageMarket(proposerPref = prefM, reviewerPref = prefW)
galeShapley.marriageMarket = function(proposerUtils = NULL,
                   reviewerUtils = NULL,
                   proposerPref = NULL,
                   reviewerPref = NULL) {
    # validate the inputs
    args = validateInputs(proposerUtils, reviewerUtils, proposerPref, reviewerPref)

    # use galeShapleyMatching to compute matching
    res = cpp_wrapper_galeshapley(args$proposerPref, args$reviewerUtils)

    M = length(res$proposals)
    N = length(res$engagements)

    # turn these into R indices by adding +1
    res = c(res, list(
        "single.proposers" = seq(from = 0, to = M - 1)[res$proposals == N] + 1,
        "single.reviewers" = seq(from = 0, to = N - 1)[res$engagements == M] + 1
    ))

    res$proposals = matrix(res$proposals, ncol = 1) + 1
    res$engagements = matrix(res$engagements, ncol = 1) + 1

    return(res)
}


#' Uses the Gale-Shapley Algorithm to find solution to the college admission
#' problem
#'
#' This function uses the Gale-Shapley algorithm to compute the solution to the
#' college admissions problem. The function needs some description of
#' individuals preferences as inputs. That can be in the form of cardinal
#' utilities or preference orders (or both).
#'
#' @param studentUtils is a matrix with cardinal utilities of the proposing side
#'   of the market
#' @param collegeUtils is a matrix with cardinal utilities of the courted side
#'   of the market
#' @param studentPref is a matrix with the preference order of the students
#'   (only required when \code{studentUtils} is not provided)
#' @param collegePref is a matrix with the preference order of the colleges
#'   (only required when \code{collegeUtils} is not provided)
#' @param slots is the number of slots per college (this is an integer, i.e. all
#'   colleges have the same number of slots)
#' @param studentOptimal is a boolean indicating the proposing side in this
#'   market. If true, students propose and the resulting allocation will be
#'   student-optimal. If false, colleges propose and the resulting allocation
#'   will be college-optimal.
#' @return A list with the successful proposals and engagements:
#'   \code{proposals} is a vector whose nth element contains the id of the
#'   reviewer that proposer n is matched to. \code{engagements} is a vector
#'   whose nth element contains the id of the proposer that reviewer n is
#'   matched to. \code{unmatched.students} is a vector that lists the ids of
#'   remaining unmatched students \code{unmatched.colleges} is a vector that
#'   lists the ids of remaining unmatched colleges (if a college has two slots
#'   left it will be listed twice)
#' @examples
#' ncolleges = 10
#' nstudents = 25
#' collegeUtils = matrix(runif(ncolleges*nstudents), nrow=nstudents, ncol=ncolleges)
#' studentUtils = matrix(runif(ncolleges*nstudents), nrow=ncolleges, ncol=nstudents)
#' results.studentoptimal = galeShapley.collegeAdmissions(studentUtils = studentUtils,
#'                                                        collegeUtils = collegeUtils,
#'                                                        slots = 2,
#'                                                        studentOptimal = TRUE)
#' results.collegeoptimal = galeShapley.collegeAdmissions(studentUtils = studentUtils,
#'                                                        collegeUtils = collegeUtils,
#'                                                        slots = 2,
#'                                                        studentOptimal = FALSE)
galeShapley.collegeAdmissions = function(studentUtils = NULL,
                    collegeUtils = NULL,
                    studentPref = NULL,
                    collegePref = NULL,
                    slots = 1,
                    studentOptimal = TRUE) {

    if(studentOptimal) {

        # validate the inputs
        args = validateInputs(studentUtils, collegeUtils, studentPref, collegePref)

        # number of colleges
        number_of_colleges = NROW(args$reviewerUtils)

        # expand cardinal utilities corresponding to the slot size
        proposerUtils = reprow(args$proposerUtils, slots)
        reviewerUtils = repcol(args$reviewerUtils, slots)

        # create preference ordering
        proposerPref = sortIndex(as.matrix(proposerUtils));

        # use galeShapleyMatching to compute matching
        res = cpp_wrapper_galeshapley(proposerPref, reviewerUtils)

        # number of workers
        M = length(res$proposals)

        # number of positions
        N = length(res$engagements)

        # collect results
        res = c(res, list(
            "unmatched.students" = seq(from = 0, to = M - 1)[res$proposals == N] + 1,
            "unmatched.colleges" = seq(from = 0, to = N - 1)[res$engagements == M] + 1
        ))

        # collapse engagements (turn these into R indices by adding +1)
        res$engagements = matrix(res$engagements, ncol = slots, byrow = TRUE) + 1

        # translate proposals into the id of the original firm (turn these into R indices by adding +1)
        college.ids = reprow(matrix(seq(from = 0, to = number_of_colleges), ncol = 1), slots)
        res$proposals = matrix(college.ids[res$proposals + 1], ncol = 1) + 1

        # translate single reviewers into the id of the original firm (turn these into R indices by adding +1)
        res$unmatched.colleges = college.ids[res$unmatched.colleges] + 1

    } else {

        # validate the inputs
        args = validateInputs(collegeUtils, studentUtils, collegePref, studentPref)

        # number of colleges
        number_of_colleges = NROW(args$proposerUtils)

        # expand cardinal utilities corresponding to the slot size
        proposerUtils = repcol(args$proposerUtils, slots)
        reviewerUtils = reprow(args$reviewerUtils, slots)

        # create preference ordering
        proposerPref = sortIndex(as.matrix(proposerUtils));

        # use galeShapleyMatching to compute matching
        res = cpp_wrapper_galeshapley(as.matrix(proposerPref), as.matrix(reviewerUtils))

        # number of firms
        M = length(res$proposals)

        # number of workers
        N = length(res$engagements)

        # collect results
        res = c(res, list(
            "unmatched.colleges" = seq(from = 0, to = M - 1)[res$proposals == N],
            "unmatched.students" = seq(from = 0, to = N - 1)[res$engagements == M]
        ))

        # collapse proposals (turn these into R indices by adding +1)
        res$proposals = matrix(res$proposals, ncol = slots, byrow = TRUE) + 1

        # translate engagements into the id of the original firm (turn these into R indices by adding +1)
        college.ids = reprow(matrix(seq(from = 0, to = number_of_colleges), ncol = 1), slots)
        res$engagements = matrix(college.ids[res$engagements + 1], ncol = 1) + 1

        # translate single proposers into the id of the original firm (turn these into R indices by adding +1)
        res$unmatched.colleges = college.ids[res$unmatched.colleges + 1] + 1

    }

    return(res)
}


#' Input validation
#'
#' This function parses and validates the arguments that are passed on to the
#' functions one2one, one2many, and many2one. In particular, it checks if
#' user-defined preference orders are complete. If user-defined orderings are
#' given in terms of R indices (starting at 1), then these are transformed into
#' C++ indices (starting at zero).
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing
#'   side of the market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side
#'   of the market
#' @param proposerPref is a matrix with the preference order of the proposing
#'   side of the market (only required when \code{proposerUtils} is not
#'   provided)
#' @param reviewerPref is a matrix with the preference order of the courted side
#'   of the market (only required when \code{reviewerUtils} is not provided)
#' @return a list containing proposerUtils, reviewerUtils, proposerPref
#'   (reviewerPref are not required after they are translated into
#'   reviewerUtils).
validateInputs = function(proposerUtils, reviewerUtils, proposerPref, reviewerPref) {

    if(get("column.major", envir = pkg.env) == FALSE) {
        if(!is.null(proposerUtils)) {
            proposerUtils = t(proposerUtils)
        }
        if(!is.null(reviewerUtils)) {
            reviewerUtils = t(reviewerUtils)
        }
        if(!is.null(proposerPref)) {
            proposerPref = t(proposerPref)
        }
        if(!is.null(reviewerPref)){
            reviewerPref = t(reviewerPref)
        }
    }

    if (!is.null(reviewerPref)) {
        reviewerPref = checkPreferenceOrder(reviewerPref)
        if (is.null(reviewerPref)) {
            stop(
                "reviewerPref was defined by the user but is not a complete list of preference orderings"
            )
        }
    }

    if (!is.null(proposerPref)) {
        proposerPref = checkPreferenceOrder(proposerPref)
        if (is.null(proposerPref)) {
            stop(
                "proposerPref was defined by the user but is not a complete list of preference orderings"
            )
        }
    }

    # parse inputs
    if (is.null(proposerPref) && !is.null(proposerUtils)) {
        proposerPref = sortIndex(as.matrix(proposerUtils))
    }

    if (is.null(proposerUtils) && !is.null(proposerPref)) {
        proposerUtils = -rankIndex(as.matrix(proposerPref))
    }

    if (is.null(reviewerUtils) && !is.null(reviewerPref)) {
        reviewerUtils = -rankIndex(as.matrix(reviewerPref))
    }

    if (is.null(proposerPref)) {
        stop("missing proposer preferences")
    }

    if (is.null(reviewerUtils)) {
        stop("missing reviewer utilities")
    }

    # check inputs
    if (NROW(proposerPref) != NCOL(reviewerUtils)) {
        stop("preference orderings must be symmetric")
    }
    if (NCOL(proposerPref) != NROW(reviewerUtils)) {
        stop("preference orderings must be symmetric")
    }

    return(
        list(
            proposerPref = as.matrix(proposerPref),
            proposerUtils = as.matrix(proposerUtils),
            reviewerUtils = as.matrix(reviewerUtils)
        )
    )
}


#' Check if preference order is complete
#'
#' This function checks if a given preference ordering is complete. If needed
#' it transforms the indices from R indices (starting at 1) to C++ indices
#' (starting at zero).
#'
#' @param pref is a matrix with a preference ordering
#' @return a matrix with preference orderings with proper C++ indices or NULL
#' if the preference order is not complete.
checkPreferenceOrder = function(pref) {

    # check if pref is using R instead of C++ indexing
    if(all(apply(pref,2,sort) == array(1:(NROW(pref)), dim = dim(pref)))) {
        return(pref-1)
    }

    # check if pref has a complete listing otherwise given an error
    if(all(apply(pref,2,sort) == (array(1:(NROW(pref)), dim = dim(pref)))-1)) {
        return(pref)
    }

    return(NULL)
}


#' Compute the one-to-many matching
#'
#' This function returns the one-to-many matching. The function needs some
#' description of individuals preferences as inputs. That can be in the form of
#' cardinal utilities or preference orders (or both). It is computationally most
#' efficient to provide cardinal utilities for the proposers
#' \code{proposerUtils} and cardinal utilities for the reviewers
#' \code{reviewerUtils}.
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing
#'   side of the market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side
#'   of the market
#' @param proposerPref is a matrix with the preference order of the proposing
#'   side of the market (only required when \code{proposerUtils} is not
#'   provided)
#' @param reviewerPref is a matrix with the preference order of the courted side
#'   of the market (only required when \code{reviewerUtils} is not provided)
#' @param slots is the number of slots per reviewer
#' @return A list with the successful proposals and engagements:
#'   \code{proposals} is a vector whose nth element contains the id of the
#'   reviewer that proposer n is matched to. \code{engagements} is a vector
#'   whose nth element contains the id of the proposer that reviewer n is
#'   matched to. \code{single.proposers} is a vector that lists the ids of
#'   remaining single proposers \code{single.reviewers} is a vector that lists
#'   the ids of remaining single reviewers (if a reviewer has two vacancies left
#'   it will be listed twice)
#' @examples
#' nfirms = 10
#' nworkers = 25
#' uFirms = matrix(runif(nfirms*nworkers), nrow=nworkers, ncol=nfirms)
#' uWorkers = matrix(runif(nfirms*nworkers), nrow=nfirms, ncol=nworkers)
#' results = one2many(uWorkers, uFirms, slots=2)
one2many = function(proposerUtils = NULL,
                    reviewerUtils = NULL,
                    proposerPref = NULL,
                    reviewerPref = NULL,
                    slots = 1) {

    .Deprecated("galeShapley.collegeAdmissions")
    galeShapley.collegeAdmissions(proposerUtils, reviewerUtils, proposerPref, reviewerPref, slots, studentOptimal = TRUE)

}


#' Compute the many-to-one matching
#'
#' This function returns the many-to-one matching. The function needs some
#' description of individuals preferences as inputs. That can be in the form of
#' cardinal utilities or preference orders (or both). It is computationally most
#' efficient to provide cardinal utilities for the proposers
#' \code{proposerUtils} and cardinal utilities for the reviewers
#' \code{reviewerUtils}.
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing
#'   side of the market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side
#'   of the market
#' @param proposerPref is a matrix with the preference order of the proposing
#'   side of the market (only required when \code{proposerUtils} is not
#'   provided)
#' @param reviewerPref is a matrix with the preference order of the courted side
#'   of the market (only required when \code{reviewerUtils} is not provided)
#' @param slots is the number of slots per proposer
#' @return A list with the successful proposals and engagements:
#'   \code{proposals} is a vector whose nth element contains the id of the
#'   reviewer that proposer n is matched to. \code{engagements} is a vector
#'   whose nth element contains the id of the proposer that reviewer n is
#'   matched to. \code{single.proposers} is a vector that lists the ids of
#'   remaining single proposers (if a proposer has two vacancies left it will be
#'   listed twice) \code{single.reviewers} is a vector that lists the ids of
#'   remaining single reviewers
#' @examples
#' nfirms = 10
#' nworkers = 25
#' uFirms = matrix(runif(nfirms*nworkers), nrow=nworkers, ncol=nfirms)
#' uWorkers = matrix(runif(nfirms*nworkers), nrow=nfirms, ncol=nworkers)
#' results = many2one(uFirms, uWorkers, slots=2)
many2one = function(proposerUtils = NULL,
                    reviewerUtils = NULL,
                    proposerPref = NULL,
                    reviewerPref = NULL,
                    slots = 1) {

    .Deprecated("galeShapley.collegeAdmissions")
    galeShapley.collegeAdmissions(reviewerUtils, proposerUtils, reviewerPref, proposerPref, slots, studentOptimal = FALSE)
}


#' Compute one-to-one matching
#'
#' This function returns the proposer-optimal one-to-one matching. The function
#' needs some description of individuals preferences as inputs. That can be in
#' the form of cardinal utilities or preference orders (or both).
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing
#'   side of the market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side
#'   of the market
#' @param proposerPref is a matrix with the preference order of the proposing
#'   side of the market (only required when \code{proposerUtils} is not
#'   provided)
#' @param reviewerPref is a matrix with the preference order of the courted side
#'   of the market (only required when \code{reviewerUtils} is not provided)
#' @return  A list with the successful proposals and engagements:
#'   \code{proposals} is a vector whose nth element contains the id of the
#'   reviewer that proposer n is matched to. \code{engagements} is a vector
#'   whose nth element contains the id of the proposer that reviewer n is
#'   matched to. \code{single.proposers} is a vector that lists the ids of
#'   remaining single proposers. \code{single.reviewers} is a vector that lists
#'   the ids of remaining single reviewers.
#' @examples
#' nmen = 25
#' nwomen = 20
#' uM = matrix(runif(nmen*nwomen), nrow=nwomen, ncol=nmen)
#' uW = matrix(runif(nwomen*nmen), nrow=nmen, ncol=nwomen)
#' results = one2one(uM, uW)
#'
#' prefM = sortIndex(uM)
#' prefW = sortIndex(uW)
#' results = one2one(proposerPref = prefM, reviewerPref = prefW)
one2one = function(proposerUtils = NULL,
                   reviewerUtils = NULL,
                   proposerPref = NULL,
                   reviewerPref = NULL) {

    .Deprecated("galeShapley.marriageMarket")
    galeShapley.marriageMarket(proposerUtils, reviewerUtils, proposerPref, reviewerPref)

}


#' C++ wrapper for Gale-Shapley algorithm
#'
#' This function provides an R wrapper for the C++ backend. Users should not
#' call this function directly and instead use
#' \code{galeShapley.marriageMarket} or \code{galeShapley.collegeAdmissions}.
#'
#' @param proposerPref is a matrix with the preference order of the proposing
#'   side of the market (using C++ indexing that starts at zero)
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side
#'   of the market
#' @return A list with the successful proposals and engagements.
#'   \code{proposals} is a vector whose nth element contains the id of the
#'   reviewer that proposer n is matched to (using C++ indexing that starts at
#'   zero). \code{engagements} is a vector whose nth element contains the id of
#'   the proposer that reviewer n is matched to (using C++ indexing that starts
#'   at zero).
galeShapleyMatching = function(proposerPref, reviewerUtils) {
    .Deprecated("cpp_wrapper_galeshapley")
    cpp_wrapper_galeshapley(proposerPref, reviewerUtils)
}
