#  matchingR -- Matching Algorithms in R and C++
#
#  Copyright (C) 2015  Jan Tilly <jtilly@econ.upenn.edu>
#                      Nick Janetos <njanetos@econ.upenn.edu>
#
#  This file is part of matchingR.
#
#  matchingR is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  matchingR is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#' Gale-Shapley Algorithm: Stable Marriage Problem
#'
#' This function computes the Gale-Shapley algorithm and finds a solution to the
#' stable marriage problem.
#'
#' The Gale-Shapley algorithm works as follows: Single men ("the proposers")
#' sequentially make proposals to each of their most preferred available women
#' ("the reviewers"). A woman can hold on to at most one proposal at a time. A
#' single woman will accept any proposal that is made to her. A woman that
#' already holds on to a proposal will reject any proposal by a man that she
#' values less than her current match. If a woman receives a proposal from a man
#' that she values more than her current match, then she will accept the
#' proposal and her previous match will join the line of bachelors. This process
#' continues until all men are matched to women.
#'
#' The Gale-Shapley Algorithm requires a complete specification of proposers'
#' and reviewers' preferences over each other. Preferences can be
#' passed on to the algorithm in ordinal form (e.g. man 3 prefers woman 1 over
#' woman 3 over woman 2) or in cardinal form (e.g. man 3 receives payoff 3.14 from
#' being matched to woman 1, payoff 2.51 from being matched to woman 3, and payoff
#' 2.15 from being matched to woman 2). Preferences must be complete, i.e.
#' all proposers must have fully specified preferences over all reviewers and
#' vice versa.
#'
#' In the version of the algorithm that is implemented here, all individuals --
#' proposers and reviewers -- prefer being matched to anyone to not being
#' matched at all.
#'
#' The algorithm still works with an unequal number of proposers and reviewers.
#' In that case some agents will remain unmatched.
#'
#' This function can also be called using \code{galeShapley}.
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing
#'   side of the market. If there are \code{n} proposers and \code{m} reviewers,
#'   then this matrix will be of dimension \code{m} by \code{n}. The
#'   \code{i,j}th element refers to the payoff that proposer \code{j} receives
#'   from being matched to proposer \code{i}.
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side
#'   of the market. If there are \code{n} proposers and \code{m} reviewers, then
#'   this matrix will be of dimension \code{n} by \code{m}. The \code{i,j}th
#'   element refers to the payoff that reviewer \code{j} receives from being
#'   matched to proposer \code{i}.
#' @param proposerPref is a matrix with the preference order of the proposing
#'   side of the market. This argument is only required when
#'   \code{proposerUtils} is not provided. If there are \code{n} proposers and
#'   \code{m} reviewers in the market, then this matrix will be of dimension
#'   \code{m} by \code{n}. The \code{i,j}th element refers to proposer \code{j}'s
#'   \code{i}th most favorite reviewer. Preference orders can either be specified
#'   using R-indexing (starting at 1) or C++ indexing (starting at 0).
#' @param reviewerPref is a matrix with the preference order of the courted side
#'   of the market. This argument is only required when \code{reviewerUtils} is
#'   not provided. If there are \code{n} proposers and \code{m} reviewers in the
#'   market, then this matrix will be of dimension \code{n} by \code{m}. The
#'   \code{i,j}th element refers to reviewer \code{j}'s \code{i}th most
#'   favorite proposer. Preference orders can either be specified using
#'   R-indexing (starting at 1) or C++ indexing (starting at 0).
#' @return  A list with elements that specify who is matched to whom and who
#'   remains unmatched. Suppose there are \code{n} proposers and \code{m}
#'   reviewers. The list contains the following items:
#'   \itemize{
#'    \item{\code{proposals} is a vector of length \code{n} whose \code{i}th
#'    element contains the number of the reviewer that proposer \code{i} is
#'    matched to. Proposers that remain unmatched will be listed as being
#'    matched to \code{NA}.}
#'    \item{\code{engagements} is a vector of length \code{m} whose \code{j}th
#'    element contains the number of the proposer that reviewer \code{j} is
#'    matched to. Reviwers that remain unmatched will be listed as being matched
#'    to \code{NA}.}
#'    \item{\code{single.proposers} is a vector that lists the remaining single
#'    proposers. This vector will be empty whenever \code{n<=m}}.
#'    \item{\code{single.reviewers} is a vector that lists the remaining single
#'    reviewers. This vector will be empty whenever \code{m<=n}}.
#'   }
#' @examples
#' nmen = 5
#' nwomen = 4
#' # generate cardinal utilities
#' uM = matrix(runif(nmen*nwomen), nrow = nwomen, ncol = nmen)
#' uW = matrix(runif(nwomen*nmen), nrow = nmen, ncol = nwomen)
#' # run the algorithm using cardinal utilities as inputs
#' results = galeShapley.marriageMarket(uM, uW)
#' results
#'
#' # transform the cardinal utilities into preference orders
#' prefM = sortIndex(uM)
#' prefW = sortIndex(uW)
#' # run the algorithm using preference orders as inputs
#' results = galeShapley.marriageMarket(proposerPref = prefM, reviewerPref = prefW)
#' results
#' @seealso \code{\link{galeShapley.collegeAdmissions}}
#' @aliases galeShapley
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

    # return unmatched proposers and reviewers as matched to NA
    res$proposals[res$proposals == (N + 1)] = NA
    res$engagements[res$engagements == (M + 1)] = NA

    return(res)
}

# see galeShapley.marriageMarket
galeShapley = function(proposerUtils = NULL,
                       reviewerUtils = NULL,
                       proposerPref = NULL,
                       reviewerPref = NULL) {

    return(galeShapley.marriageMarket(proposerUtils = proposerUtils,
                                      reviewerUtils = reviewerUtils,
                                      proposerPref = proposerPref,
                                      reviewerPref = reviewerPref))
}


#' Gale-Shapley Algorithm: College Admissions Problem
#'
#' This function computes the Gale-Shapley algorithm and finds a solution to the
#' college admissions problem. In the student-optimal college admissions
#' problem, \code{n} students apply to \code{m} colleges, where each college has
#' \code{s} slots.
#'
#' The algorithm works analogously to \link{galeShapley.marriageMarket}. The
#' Gale-Shapley algorithm works as follows: Students ("the proposers")
#' sequentially make proposals to each of their most preferred available
#' colleges ("the reviewers"). A college can hold on to at most \code{s}
#' proposals at a time. A college with an open slot will accept any application
#' that it receives. A college that already holds on to \code{s} applications
#' will reject any application by a student that it values less than her current
#' set of applicants. If a college receives an application from a student that
#' it values more than its current set of applicants, then it will accept the
#' application and drop its least preferred current applicant. This process
#' continues until all students are matched to colleges.
#'
#' The Gale-Shapley Algorithm requires a complete specification of students' and
#' colleges' preferences over each other. Preferences can be passed on to the
#' algorithm in ordinal form (e.g. student 3 prefers college 1 over college 3
#' over college 2) or in cardinal form (e.g. student 3 receives payoff 3.14 from
#' being matched to college 1, payoff 2.51 from being matched to college 3 and
#' payoff 2.13 from being matched to college 2). Preferences must be complete,
#' i.e. all students must have fully specified preferences over all colleges and
#' vice versa.
#'
#' In the version of the algorithm that is implemented here, all individuals --
#' colleges and students -- prefer being matched to anyone to not being matched
#' at all.
#'
#' The algorithm still works with an unequal number of students and slots. In
#' that case some students will remain unmatched or some slots will remain open.
#'
#' @param studentUtils is a matrix with cardinal utilities of the students. If
#'   there are \code{n} students and \code{m} colleges, then this matrix will be
#'   of dimension \code{m} by \code{n}. The \code{i,j}th element refers to the
#'   payoff that student \code{j} receives from being matched to college
#'   \code{i}.
#' @param collegeUtils is a matrix with cardinal utilities of colleges. If there
#'   are \code{n} students and \code{m} colleges, then this matrix will be of
#'   dimension \code{n} by \code{m}. The \code{i,j}th element refers to the
#'   payoff that college \code{j} receives from being matched to student
#'   \code{i}.
#' @param studentPref is a matrix with the preference order of the proposing
#'   side of the market (only required when \code{studentUtils} is not
#'   provided). If there are \code{n} students and \code{m} colleges in the
#'   market, then this matrix will be of dimension \code{m} by \code{n}. The
#'   \code{i,j}th element refers to student \code{j}'s \code{i}th most favorite
#'   college. Preference orders can either be specified using R-indexing
#'   (starting at 1) or C++ indexing (starting at 0).
#' @param collegePref is a matrix with the preference order of the courted side
#'   of the market (only required when \code{collegeUtils} is not provided). If
#'   there are \code{n} students and \code{m} colleges in the market, then this
#'   matrix will be of dimension \code{n} by \code{m}. The \code{i,j}th element
#'   refers to individual \code{j}'s \code{i}th most favorite partner.
#'   Preference orders can either be specified using R-indexing (starting at 1)
#'   or C++ indexing (starting at 0).
#' @param slots is the number of slots that each college has available. If this
#'   is 1, then the algorithm is identical to
#'   \code{\link{galeShapley.marriageMarket}}.
#' @param studentOptimal is \code{TRUE} if students apply to colleges. The
#'   resulting match is student-optimal. \code{studentOptimal} is \code{FALSE}
#'   if colleges apply to students. The resulting match is college-optimal.
#' @return  A list with elements that specify which student is matched to which
#'   college and who remains unmatched. Suppose there are \code{n} students and
#'   \code{m} colleges with \code{s} slots. The list contains the following
#'   items:
#'   \itemize{
#'    \item{\code{matched.students} is a vector of length \code{n} whose \code{i}th
#'    element contains college that student \code{i} is
#'    matched to. Students that remain unmatched will be listed as being
#'    matched to college \code{NA}.}
#'    \item{\code{matched.colleges} is a matrix of dimension \code{m} by
#'    \code{s} whose \code{j}th row contains the students that were admitted to
#'    college \code{j}. Slots that remain open show up as being matched to
#'    student to \code{NA}.}
#'    \item{\code{unmatched.students} is a vector that lists the remaining unmatched
#'    students This vector will be empty whenever \code{n<=m*s}}.
#'    \item{\code{unmatched.colleges} is a vector that lists colleges with open
#'    slots. If a college has multiple open slots, it will show up multiple
#'    times. This vector will be empty whenever \code{m*s<=n}}.
#'   }
#' @examples
#' ncolleges = 10
#' nstudents = 25
#'
#' # randomly generate cardinal preferences of colleges and students
#' collegeUtils = matrix(runif(ncolleges*nstudents), nrow=nstudents, ncol=ncolleges)
#' studentUtils = matrix(runif(ncolleges*nstudents), nrow=ncolleges, ncol=nstudents)
#'
#' # run the student-optimal algorithm
#' results.studentoptimal = galeShapley.collegeAdmissions(studentUtils = studentUtils,
#'                               collegeUtils = collegeUtils,
#'                               slots = 2,
#'                               studentOptimal = TRUE)
#' results.studentoptimal
#'
#' # run the college-optimal algorithm
#' results.collegeoptimal = galeShapley.collegeAdmissions(studentUtils = studentUtils,
#'                               collegeUtils = collegeUtils,
#'                               slots = 2,
#'                               studentOptimal = FALSE)
#' results.collegeoptimal
#'
#' # transform the cardinal utilities into preference orders
#' collegePref = sortIndex(collegeUtils)
#' studentPref = sortIndex(studentUtils)
#'
#' # run the student-optimal algorithm
#' results.studentoptimal = galeShapley.collegeAdmissions(studentPref = studentPref,
#'                              collegePref = collegePref,
#'                              slots = 2,
#'                              studentOptimal = TRUE)
#' results.studentoptimal
#'
#' # run the college-optimal algorithm
#' results.collegeoptimal = galeShapley.collegeAdmissions(studentPref = studentPref,
#'                              collegePref = collegePref,
#'                              slots = 2,
#'                              studentOptimal = FALSE)
#' results.collegeoptimal
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
        res$matched.colleges = matrix(res$engagements, ncol = slots, byrow = TRUE) + 1
        res$engagements = NULL

        # translate proposals into the id of the original firm (turn these into R indices by adding +1)
        college.ids = reprow(matrix(seq(from = 0, to = number_of_colleges), ncol = 1), slots)
        res$matched.students = matrix(college.ids[res$proposals + 1], ncol = 1) + 1
        res$proposals = NULL

        # translate single colleges into the id of the original college (turn these into R indices by adding +1)
        res$unmatched.colleges = college.ids[res$unmatched.colleges] + 1

        # unmatched students / colleges are matched to NA
        res$matched.colleges[res$matched.colleges == (M + 1)] = NA
        res$matched.students[res$matched.students == (N/slots + 1)] = NA

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
            "unmatched.colleges" = seq(from = 0, to = M - 1)[res$proposals == N] + 1,
            "unmatched.students" = seq(from = 0, to = N - 1)[res$engagements == M] + 1
        ))

        # collapse proposals (turn these into R indices by adding +1)
        res$matched.colleges = matrix(res$proposals, ncol = slots, byrow = TRUE) + 1
        res$proposals = NULL

        # translate engagements into the id of the original firm (turn these into R indices by adding +1)
        college.ids = reprow(matrix(seq(from = 0, to = number_of_colleges), ncol = 1), slots)
        res$matched.students = matrix(college.ids[res$engagements + 1], ncol = 1) + 1
        res$engagements = NULL

        # translate unmatched college slots into the id of the original college (turn these into R indices by adding +1)
        res$unmatched.colleges = college.ids[res$unmatched.colleges] + 1

        # unmatched students / colleges are matched to NA
        res$matched.colleges[res$matched.colleges == (N + 1)] = NA
        res$matched.students[res$matched.students == (M/slots + 1)] = NA

    }


    return(res)
}


#' Input validation of preferences
#'
#' This function parses and validates the arguments that are passed on to the
#' Gale-Shapley Algorithm. In particular, it checks if user-defined preference
#' orders are complete and returns an error otherwise. If user-defined orderings
#' are given in terms of R indices (starting at 1), then these are transformed
#' into C++ indices (starting at zero).
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing
#'   side of the market. If there are \code{n} proposers and \code{m} reviewers,
#'   then this matrix will be of dimension \code{m} by \code{n}. The
#'   \code{i,j}th element refers to the payoff that proposer \code{j} receives
#'   from being matched to reviewer \code{i}.
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side
#'   of the market. If there are \code{n} proposers and \code{m} reviewers, then
#'   this matrix will be of dimension \code{n} by \code{m}. The \code{i,j}th
#'   element refers to the payoff that reviewer \code{j} receives from being
#'   matched to proposer \code{i}.
#' @param proposerPref is a matrix with the preference order of the proposing
#'   side of the market (only required when \code{proposerUtils} is not
#'   provided). If there are \code{n} proposers and \code{m} reviewers in the
#'   market, then this matrix will be of dimension \code{m} by \code{n}. The
#'   \code{i,j}th element refers to proposer \code{j}'s \code{i}th most favorite
#'   reviewer. Preference orders can either be specified using R-indexing
#'   (starting at 1) or C++ indexing (starting at 0).
#' @param reviewerPref is a matrix with the preference order of the courted side
#'   of the market (only required when \code{reviewerUtils} is not provided). If
#'   there are \code{n} proposers and \code{m} reviewers in the market, then
#'   this matrix will be of dimension \code{n} by \code{m}. The \code{i,j}th
#'   element refers to reviewer \code{j}'s \code{i}th most favorite proposer.
#'   Preference orders can either be specified using R-indexing (starting at 1)
#'   or C++ indexing (starting at 0).
#' @return a list containing \code{proposerUtils}, \code{reviewerUtils},
#'   \code{proposerPref} (\code{reviewerPref} are not required after they are
#'   translated into \code{reviewerUtils}).
#' @examples
#' # market size
#' nmen = 5
#' nwomen = 4
#'
#' # generate cardinal utilities
#' uM = matrix(runif(nmen*nwomen), nrow = nwomen, ncol = nmen)
#' uW = matrix(runif(nwomen*nmen), nrow = nmen, ncol = nwomen)
#'
#' # turn cardinal utilities into ordinal preferences
#' prefM = sortIndex(uM)
#' prefW = sortIndex(uW)
#'
#' # validate cardinal preferences
#' preferences = galeShapley.validate(uM, uW)
#' preferences
#'
#' # validate ordinal preferences
#' preferences = galeShapley.validate(proposerPref = prefM, reviewerPref = prefW)
#' preferences
#'
#' # validate ordinal preferences when these are in R style indexing
#' # (instead of C++ style indexing)
#' preferences = galeShapley.validate(proposerPref = prefM + 1, reviewerPref = prefW + 1)
#' preferences
#'
#' # validate preferences when proposer-side is cardinal and reviewer-side is ordinal
#' preferences = galeShapley.validate(proposerUtils = uM, reviewerPref = prefW)
#' preferences
galeShapley.validate = function(proposerUtils = NULL, reviewerUtils = NULL, proposerPref = NULL, reviewerPref = NULL) {

    if (!is.null(reviewerPref)) {
        reviewerPref = galeShapley.checkPreferences(reviewerPref)
        if (is.null(reviewerPref)) {
            stop(
                "reviewerPref was defined by the user but is not a complete list of preference orderings."
            )
        }
    }

    if (!is.null(proposerPref)) {
        proposerPref = galeShapley.checkPreferences(proposerPref)
        if (is.null(proposerPref)) {
            stop("proposerPref was defined by the user but is not a complete list of preference orderings.")
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
        stop("The number of rows in the matrix of proposers' ",
             "preferences must equal the number of columns in ",
             "the matrix of reviewers' preferences")
    }

    if (NCOL(proposerPref) != NROW(reviewerUtils)) {
        stop("The number of columns in the matrix of proposers' ",
             "preferences must equal the number of rows in the ",
             "matrix of reviewers' preferences")
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
#' preferences. This stability check can be applied to both the stable marriage
#' problem and the college admission problem. The function requires preferences
#' to be specified in cardinal form. If necessary, the function
#' \code{\link{rankIndex}} can be used to turn ordinal preferences into cardinal
#' utilities.
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing
#'   side of the market. If there are \code{n} proposers and \code{m} reviewers,
#'   then this matrix will be of dimension \code{m} by \code{n}. The
#'   \code{i,j}th element refers to the payoff that proposer \code{j} receives
#'   from being matched to reviewer \code{i}.
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side
#'   of the market. If there are \code{n} proposers and \code{m} reviewers, then
#'   this matrix will be of dimension \code{n} by \code{m}. The \code{i,j}th
#'   element refers to the payoff that reviewer \code{j} receives from being
#'   matched to proposer \code{i}.
#' @param proposals is a matrix that contains the number of the reviewer that a
#'   given proposer is matched to: the first row contains the reviewer that is
#'   matched to the first proposer, the second row contains the reviewer that is
#'   matched to the second proposer, etc. The column dimension accommodates
#'   proposers with multiple slots.
#' @param engagements is a matrix that contains the number of the proposer that
#'   a given reviewer is matched to. The column dimension accommodates reviewers
#'   with multiple slots.
#' @return true if the matching is stable, false otherwise
#' @examples
#' # define cardinal utilities
#' uM = matrix(c(0.52, 0.85,
#'               0.96, 0.63,
#'               0.82, 0.08,
#'               0.55, 0.34), nrow = 4, byrow = TRUE)
#' uW = matrix(c(0.76, 0.88, 0.74, 0.02,
#'               0.32, 0.21, 0.02, 0.79), ncol = 4, byrow = TRUE)
#' # define matching
#' results = list(
#'      proposals = matrix(c(2, 1), ncol = 1),
#'      engagements = matrix(c(2, 1, NA, NA), ncol = 1))
#' # check stability
#' galeShapley.checkStability(uM, uW, results$proposals, results$engagements)
#'
#' # if preferences are in ordinal form, we can use galeShapley.validate
#' # to transform them into cardinal form and then use checkStability()
#' prefM = matrix(c(2, 1,
#'                  3, 2,
#'                  4, 4,
#'                  1, 3), nrow = 4, byrow = TRUE)
#' prefW = matrix(c(1, 1, 1, 2,
#'                  2, 2, 2, 1), ncol = 4, byrow = TRUE)
#' # define matching
#' results = list(proposals = matrix(c(2, 1), ncol = 1),
#'                engagements = matrix(c(2, 1, NA, NA), ncol = 1))
#' # check stability
#' pref.validated = galeShapley.validate(proposerPref = prefM,
#'                                       reviewerPref = prefW)
#' galeShapley.checkStability(pref.validated$proposerUtils,
#'                            pref.validated$reviewerUtils,
#'                            results$proposals,
#'                            results$engagements)
galeShapley.checkStability = function(proposerUtils, reviewerUtils, proposals, engagements) {

    # replace NA for unmatched proposers (they are now matched to the number of reviewers + 1)
    proposals[is.na(proposals)] = NROW(proposerUtils) + 1

    # replace NA for unmatched reviewers (they are now matched to the number of proposers + 1)
    engagements[is.na(engagements)] = NROW(reviewerUtils) + 1

    # turn proposals and engagements into C++ style indexing
    proposals = proposals - 1
    engagements = engagements - 1

    # call the C++ wrapper
    cpp_wrapper_galeshapley_check_stability(proposerUtils, reviewerUtils, proposals, engagements)
}

#' Check if preference order is complete
#'
#' This function checks if a given preference ordering is complete. If needed,
#' it transforms the indices from R indices (starting at 1) to C++ indices
#' (starting at zero).
#'
#' @param pref is a matrix with ordinal preference orderings for one side of the
#'   market. Suppose that \code{pref} refers to the preferences of \code{n}
#'   women over \code{m} men. In that case, \code{pref} will be of dimension
#'   \code{m} by \code{n}.  The \code{i,j}th element refers to woman \code{j}'s
#'   \code{i}th most favorite man. Preference orders can either be specified
#'   using R-indexing (starting at 1) or C++ indexing (starting at 0).
#' @return a matrix with ordinal preference orderings with proper C++ indices or
#'   NULL if the preference order is not complete.
#' @examples
#' # preferences in proper C++ indexing: galeShapley.checkPreferences(pref)
#' # will return pref
#' pref = matrix(c(0, 1, 0,
#'                 1, 0, 1), nrow = 2, ncol = 3, byrow = TRUE)
#' pref
#' galeShapley.checkPreferences(pref)
#'
#' # preferences in R indexing: galeShapley.checkPreferences(pref)
#' # will return pref-1
#' pref = matrix(c(1, 2, 1,
#'                 2, 1, 2), nrow = 2, ncol = 3, byrow = TRUE)
#' pref
#' galeShapley.checkPreferences(pref)
#'
#' # incomplete preferences: galeShapley.checkPreferences(pref)
#' # will return NULL
#' pref = matrix(c(3, 2, 1,
#'                 2, 1, 2), nrow = 2, ncol = 3, byrow = TRUE)
#' pref
#' galeShapley.checkPreferences(pref)
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
