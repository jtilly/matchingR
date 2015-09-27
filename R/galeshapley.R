#' Computes Gale-Shapley algorithm to find solution to the stable marriage
#' problem
#'
#' This function returns the one-to-one matching. The function needs some
#' description of individuals preferences as inputs. That can be in the form of
#' cardinal utilities or preference orders (or both).
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing
#'   side of the market. If there are \code{n} proposers and \code{m} reviewers
#'   in the market, then this matrix will be of dimension \code{m} by \code{n}.
#'   The \code{i,j}th element refers to the payoff that individual \code{j}
#'   receives from being matched to individual \code{i}.
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side
#'   of the market. If there are \code{n} proposers and \code{m} reviewers
#'   in the market, then this matrix will be of dimension \code{n} by \code{m}.
#'   The \code{i,j}th element refers to the payoff that individual \code{j}
#'   receives from being matched to individual \code{i}.
#' @param proposerPref is a matrix with the preference order of the proposing
#'   side of the market (only required when \code{proposerUtils} is not
#'   provided). If there are \code{n} proposers and \code{m} reviewers
#'   in the market, then this matrix will be of dimension \code{m} by \code{n}.
#'   The \code{i,j}th element refers to the ID of individual \code{j}'s
#'   \code{i}th most favorite partner.
#' @param reviewerPref is a matrix with the preference order of the courted side
#'   of the market (only required when \code{reviewerUtils} is not provided). If
#'   there are \code{n} proposers and \code{m} reviewers in the market, then
#'   this matrix will be of dimension \code{n} by \code{m}. The \code{i,j}th
#'   element refers to the ID of individual \code{j}'s \code{i}th most favorite
#'   partner.
#' @return  A list with the successful proposals and engagements:
#'   \code{proposals} is a vector whose nth element contains the id of the
#'   reviewer that proposer n is matched to. \code{engagements} is a vector
#'   whose nth element contains the id of the proposer that reviewer n is
#'   matched to. \code{single.proposers} is a vector that lists the ids of
#'   remaining single proposers. \code{single.reviewers} is a vector that lists
#'   the ids of remaining single reviewers.
#' @examples
#' nmen = 5
#' nwomen = 4
#' uM = matrix(runif(nmen*nwomen), nrow = nwomen, ncol = nmen)
#' uW = matrix(runif(nwomen*nmen), nrow = nmen, ncol = nwomen)
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
    args = galeShapley.validate(proposerUtils, reviewerUtils, proposerPref, reviewerPref)

    # use galeShapleyMatching to compute matching
    res = cpp_wrapper_galeshapley(args$proposerPref, args$reviewerUtils)

    # number of proposals
    M = length(res$proposals)

    # number of engagements
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
#'   of the market. If there are \code{n} students and \code{m} colleges
#'   in the market, then this matrix will be of dimension \code{m} by \code{n}.
#'   The \code{i,j}th element refers to the payoff that student \code{j}
#'   receives from being matched to college \code{i}.
#' @param collegeUtils is a matrix with cardinal utilities of the courted side
#'   of the market. If there are \code{n} students and \code{m} colleges
#'   in the market, then this matrix will be of dimension \code{n} by \code{m}.
#'   The \code{i,j}th element refers to the payoff that college \code{j}
#'   receives from being matched to student \code{i}.
#' @param studentPref is a matrix with the preference order of the students
#'   (only required when \code{studentUtils} is not provided). If there are
#'   \code{n} students and \code{m} colleges in the market, then this matrix
#'   will be of dimension \code{m} by \code{n}. The \code{i,j}th element refers
#'   to the ID of student \code{j}'s \code{i}th most favorite college.
#' @param collegePref is a matrix with the preference order of the colleges
#'   (only required when \code{collegeUtils} is not provided).  If there are
#'   \code{n} students and \code{m} colleges in the market, then this matrix
#'   will be of dimension \code{n} by \code{m}. The \code{i,j}th element refers
#'   to the ID of college \code{j}'s \code{i}th most favorite student
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

    if (studentOptimal) {

        # validate the inputs
        args = galeShapley.validate(studentUtils, collegeUtils, studentPref, collegePref)

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
        args = galeShapley.validate(collegeUtils, studentUtils, collegePref, studentPref)

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
galeShapley.validate = function(proposerUtils, reviewerUtils, proposerPref, reviewerPref) {

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
        reviewerPref = galeShapley.checkPreferences(reviewerPref)
        if (is.null(reviewerPref)) {
            stop(
                "reviewerPref was defined by the user but is not a complete list of preference orderings"
            )
        }
    }

    if (!is.null(proposerPref)) {
        proposerPref = galeShapley.checkPreferences(proposerPref)
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

#' Check if a two-sided matching is stable
#'
#' This function checks if a given matching is stable for a particular set of
#' preferences. This function can check if a given check one-to-one,
#' one-to-many, or many-to-one matching is stable.
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing side of the
#' market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side of the
#' market
#' @param proposals is a matrix that contains the id of the reviewer that a given
#' proposer is matched to: the first row contains the id of the reviewer that is
#' matched with the first proposer, the second row contains the id of the reviewer
#' that is matched with the second proposer, etc. The column dimension accommodates
#' proposers with multiple slots.
#' @param engagements is a matrix that contains the id of the proposer that a given
#' reviewer is matched to. The column dimension accommodates reviewers with multiple
#' slots
#' @return true if the matching is stable, false otherwise
galeShapley.checkStability = function(proposerUtils, reviewerUtils, proposals, engagements) {
    # turn proposals and engagements into C++ style indexing
    proposals = proposals - 1
    engagements = engagements - 1
    cpp_wrapper_galeshapley_check_stability(proposerUtils, reviewerUtils, proposals, engagements)
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
galeShapley.checkPreferences = function(pref) {

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

#' Input validation (Deprecated)
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
    .Deprecated(galeShapley.validate)
    galeShapley.validate(proposerUtils, reviewerUtils, proposerPref, reviewerPref)
}


#' Check if a two-sided matching is stable (Deprecated)
#'
#' This function checks if a given matching is stable for a particular set of
#' preferences. This function can check if a given check one-to-one,
#' one-to-many, or many-to-one matching is stable.
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing side of the
#' market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side of the
#' market
#' @param proposals is a matrix that contains the id of the reviewer that a given
#' proposer is matched to: the first row contains the id of the reviewer that is
#' matched with the first proposer, the second row contains the id of the reviewer
#' that is matched with the second proposer, etc. The column dimension accommodates
#' proposers with multiple slots.
#' @param engagements is a matrix that contains the id of the proposer that a given
#' reviewer is matched to. The column dimension accommodates reviewers with multiple
#' slots
#' @return true if the matching is stable, false otherwise
checkStability = function(proposerUtils, reviewerUtils, proposals, engagements) {
    .Deprecated(galeShapley.checkStability)
}


#' Check if preference order is complete (Deprecated)
#'
#' This function checks if a given preference ordering is complete. If needed
#' it transforms the indices from R indices (starting at 1) to C++ indices
#' (starting at zero).
#'
#' @param pref is a matrix with a preference ordering
#' @return a matrix with preference orderings with proper C++ indices or NULL
#' if the preference order is not complete.
checkPreferenceOrder = function(pref) {
    .Deprecated(galeShapley.checkPreferences)
    galeShapley.checkPreferences(pref)
}


#' Compute the one-to-many matching (Deprecated)
#'
#' This function is deprecated. Please use \code{galeShapley.marriageMarket}
#' instead. This function returns the one-to-many matching. The function needs
#' some description of individuals preferences as inputs. That can be in the
#' form of cardinal utilities or preference orders (or both). It is
#' computationally most efficient to provide cardinal utilities for the
#' proposers \code{proposerUtils} and cardinal utilities for the reviewers
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
one2many = function(proposerUtils = NULL,
                    reviewerUtils = NULL,
                    proposerPref = NULL,
                    reviewerPref = NULL,
                    slots = 1) {

    .Deprecated("galeShapley.collegeAdmissions")
    galeShapley.collegeAdmissions(proposerUtils, reviewerUtils, proposerPref, reviewerPref, slots, studentOptimal = TRUE)

}


#' Compute the many-to-one matching (Deprecated)
#'
#' This function is deprecated. Please use \code{galeShapley.collegeAdmissions}
#' instead. This function returns the many-to-one matching. The function needs
#' some description of individuals preferences as inputs. That can be in the
#' form of cardinal utilities or preference orders (or both). It is
#' computationally most efficient to provide cardinal utilities for the
#' proposers \code{proposerUtils} and cardinal utilities for the reviewers
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
many2one = function(proposerUtils = NULL,
                    reviewerUtils = NULL,
                    proposerPref = NULL,
                    reviewerPref = NULL,
                    slots = 1) {

    .Deprecated("galeShapley.collegeAdmissions")
    galeShapley.collegeAdmissions(reviewerUtils, proposerUtils, reviewerPref, proposerPref, slots, studentOptimal = FALSE)
}


#' Compute one-to-one matching (Deprecated)
#'
#' This function is deprecated. Please use \code{galeShapley.collegeAdmissions}
#' instead. This function returns the proposer-optimal one-to-one matching. The
#' function needs some description of individuals preferences as inputs. That
#' can be in the form of cardinal utilities or preference orders (or both).
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
one2one = function(proposerUtils = NULL,
                   reviewerUtils = NULL,
                   proposerPref = NULL,
                   reviewerPref = NULL) {

    .Deprecated("galeShapley.marriageMarket")
    galeShapley.marriageMarket(proposerUtils, reviewerUtils, proposerPref, reviewerPref)

}


#' C++ wrapper for Gale-Shapley algorithm (Deprecated)
#'
#' This function is deprecated. Please use \code{cpp_wrapper_galeshapley}
#' instead. This function provides an R wrapper for the C++ backend. Users
#' should not call this function directly and instead use
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
