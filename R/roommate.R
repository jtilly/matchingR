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

#' Compute matching for one-sided markets
#' 
#' This function computes the Irving (1985) algorithm for finding a stable
#' matching in a one-sided matching market.
#' 
#' Consider the following example: A set of \code{n} potential roommates, each 
#' with ranked preferences over all the other potential roommates, are to be 
#' matched to rooms, two roommates per room. A matching is stable if there is no
#' roommate \code{r1} that would rather be matched to some other roommate 
#' \code{d2} than to his current roommate \code{r2} and the other roommate 
#' \code{d2} would rather be matched to \code{r1} than to his current roommate 
#' \code{d1}.
#' 
#' The algorithm works in two stages. In the first stage, all participants begin
#' unmatched, then, in sequence, begin making proposals to other potential roommates,
#' beginning with their most preferred roommate. If a roommate receives a proposal,
#' he either accepts it if he has no other proposal which is better, or rejects it
#' otherwise. If this stage ends with a roommate who has no proposals, then there
#' is no stable matching and the algorithm terminates.
#' 
#' In the second stage, the algorithm proceeds by finding and eliminating 
#' rotations. Roughly speaking, a rotation is a sequence of pairs of agents,
#' such that the first agent in each pair is least preferred by the second
#' agent in that pair (of all the agents remaining to be matched), the second
#' agent in each pair is most preferred by the first agent in each pair (of
#' all the agents remaining to be matched) and the second agent in the 
#' successive pair is the second most preferred agent (of the agents 
#' remaining to be matched) of the first agent in the succeeding 
#' pair, where here 'successive' is taken to mean 'modulo \code{m}',
#' where \code{m} is the length of the rotation. Once a rotation has been
#' identified, it can be eliminated in the following way: For each pair, the
#' second agent in the pair rejects the first agent in the pair (recall that the
#' second agent hates the first agent, while the first agent loves the second
#' agent), and the first agent then proceeds to propose to the second agent
#' in the succeeding pair. If at any point during this process, an agent
#' no longer has any agents left to propose to or be proposed to from, then
#' there is no stable matching and the algorithm terminates.
#' 
#' Otherwise, at the end, every agent is left proposing to an agent who is also
#' proposing back to them, which results in a stable matching. 
#' 
#' Note that neither existence nor uniqueness is guaranteed, this algorithm 
#' finds one matching, not all of them. If no matching exists, this function
#' returns \code{NULL}.
#'
#' @param utils is a matrix with cardinal utilities for each individual in the 
#'   market. If there are \code{n} individuals, then this matrix will be of 
#'   dimension \code{n-1} by \code{n}. Column \code{j} refers to the payoff that
#'   individual \code{j} receives from being matched to individual \code{1, 2, 
#'   ..., j-1, j+1, ...n}. If a square matrix is passed as \code{utils}, then 
#'   the main diagonal will be removed.
#' @param pref is a matrix with the preference order of each individual in the 
#'   market. This argument is only required when \code{utils} is not provided. 
#'   If there are \code{n} individuals, then this matrix will be of dimension 
#'   \code{n-1} by \code{n}. The \code{i,j}th element refers to \code{j}'s 
#'   \code{i}th most favorite partner. Preference orders can either be specified
#'   using R-indexing (starting at 1) or C++ indexing (starting at 0). The
#'   matrix \code{pref} must be of dimension \code{n-1} by \code{n}. Otherwise,
#'   the function will throw an error.
#' @return A vector of length \code{n} corresponding to the matchings that were
#'   formed. E.g. if the \code{4}th element of this vector is \code{6} then
#'   individual \code{4} was matched with individual \code{6}. If no stable
#'   matching exists, then this function returns \code{NULL}.
#' @examples
#' # example using cardinal utilities
#' utils = matrix(c(-1.63, 0.69, -1.38, -0.03, 
#'                   2.91, -0.52, 0.52, 0.22, 
#'                   0.53, -0.52, -1.18, 0.53), byrow=TRUE, ncol = 4, nrow = 3)
#' utils
#' results = roommate(utils = utils)
#' results
#' 
#' # example using preference orders
#' pref = matrix(c(3, 1, 2, 3, 
#'                 4, 3, 4, 2, 
#'                 2, 4, 1, 1), byrow = TRUE, ncol = 4)
#' pref
#' results = roommate(pref = pref)                 
#' results
roommate = function(utils = NULL, pref = NULL) {
    pref.validated = roommate.validate(pref = pref, utils = utils);
    res = cpp_wrapper_irving(pref.validated);
    
    # if the C++ code returns all zeros, then no matching exists, return NULL
    # otherwise, add one to turn C++ indexing into R style indexing
    ifelse (all(res == 0), return(NULL), return(res + 1))

}

#' Input validation for one-sided markets
#' 
#' This function parses and validates the arguments for the function
#' \code{\link{roommate}}. It returns the validates arguments. This function 
#' is called as part of \code{\link{roommate}}. Only one of the
#' arguments needs to be provided.
#'
#' @param utils is a matrix with cardinal utilities for each individual in the 
#'   market. If there are \code{n} individuals, then this matrix will be of 
#'   dimension \code{n-1} by \code{n}. Column \code{j} refers to the payoff that
#'   individual \code{j} receives from being matched to individual \code{1, 2, 
#'   ..., j-1, j+1, ...n}. If a square matrix is passed as \code{utils}, then 
#'   the main diagonal will be removed.
#' @param pref is a matrix with the preference order of each individual in the 
#'   market. This argument is only required when \code{utils} is not provided. 
#'   If there are \code{n} individuals, then this matrix will be of dimension 
#'   \code{n-1} by \code{n}. The \code{i,j}th element refers to \code{j}'s 
#'   \code{i}th most favorite partner. Preference orders can either be specified
#'   using R-indexing (starting at 1) or C++ indexing (starting at 0). The
#'   matrix \code{pref} must be of dimension \code{n-1} by \code{n}. Otherwise,
#'   the function will throw an error.
#' @return The validated preference ordering using C++ indexing. 
roommate.validate = function(utils = NULL, pref = NULL) {
    
    # Convert cardinal utility to ordinal, if necessary
    if (is.null(utils) && is.null(pref)) {
        stop("Preferences need to be specified: either utils or pref must be provided.")
    }
    
    # Convert cardinal utility to ordinal, if necessary
    if (!is.null(utils) && !is.null(pref)) {
        warning("Preferences were specified using both cardinal utilities ",
                "and ordinal preferences. The algorithm will proceed by ",
                "only using the ordinal preferences.")
    }

    # Convert cardinal utility to ordinal, if necessary
    if (is.null(pref) && !is.null(utils)) {

        # remove main diagonal from matrix if NROW = NCOL
        if (NROW(utils) == NCOL(utils)) {
            utils = matrix(
                utils[-c(seq(from = 1, to = NROW(utils) ^ 2, length.out = NROW(utils)))],
                nrow = NROW(utils) - 1, ncol = NCOL(utils))
        }

        if (NROW(utils) + 1 != NCOL(utils)) {
            stop("preference matrix must be n-1xn")
        }

        pref = sortIndexOneSided(as.matrix(utils))
    }

    if (NROW(pref) + 1 != NCOL(pref)) {
        stop("preference matrix must be n-1xn")
    }

    pref = roommate.checkPreferences(pref)
    if (is.null(pref)) {
        stop(
            "preferences are not a complete list of preference orderings"
        )
    }

    return(pref)
}

#' Check if a roommate matching is stable
#' 
#' This function checks if a particular roommate matching is stable. A matching
#' is stable if there is no roommate \code{r1} that would rather be matched to
#' some other roommate \code{d2} than to his current roommate \code{r2} and the
#' other roommate \code{d2} would rather be matched to \code{r1} than to his
#' current roommate \code{d1}.
#' 
#' @param utils is a matrix with cardinal utilities for each individual in the 
#'   market. If there are \code{n} individuals, then this matrix will be of 
#'   dimension \code{n-1} by \code{n}. Column \code{j} refers to the payoff that
#'   individual \code{j} receives from being matched to individual \code{1, 2, 
#'   ..., j-1, j+1, ...n}. If a square matrix is passed as \code{utils}, then 
#'   the main diagonal will be removed.
#' @param pref is a matrix with the preference order of each individual in the 
#'   market. This argument is only required when \code{utils} is not provided. 
#'   If there are \code{n} individuals, then this matrix will be of dimension 
#'   \code{n-1} by \code{n}. The \code{i,j}th element refers to \code{j}'s 
#'   \code{i}th most favorite partner. Preference orders can either be specified
#'   using R-indexing (starting at 1) or C++ indexing (starting at 0). The 
#'   matrix \code{pref} must be of dimension \code{n-1} by \code{n}. Otherwise, 
#'   the function will throw an error.
#' @param matching is a vector of length \code{n} corresponding to the matchings
#'   that were formed. E.g. if the \code{4}th element of this vector is \code{6}
#'   then individual \code{4} was matched with individual \code{6}.
#' @return true if stable, false if not
#' @examples
#' # define preferences
#' pref = matrix(c(3, 1, 2, 3, 
#'                 4, 3, 4, 2, 
#'                 2, 4, 1, 1), byrow = TRUE, ncol = 4)
#' pref
#' # compute matching
#' results = roommate(pref = pref)                 
#' results
#' # check if matching is stable
#' roommate.checkStability(pref = pref, matching = results)
roommate.checkStability = function(utils = NULL, pref = NULL, matching) {
    pref.validated = roommate.validate(pref = pref, utils = utils);
    cpp_wrapper_irving_check_stability(pref.validated, matching)
}

#' Check if preference order for a one-sided market is complete
#' 
#' @param pref is a matrix with the preference order of each individual in the 
#'   market. This argument is only required when \code{utils} is not provided. 
#'   If there are \code{n} individuals, then this matrix will be of dimension 
#'   \code{n-1} by \code{n}. The \code{i,j}th element refers to \code{j}'s 
#'   \code{i}th most favorite partner. Preference orders can either be specified
#'   using R-indexing (starting at 1) or C++ indexing (starting at 0). The 
#'   matrix \code{pref} must be of dimension \code{n-1} by \code{n}. Otherwise, 
#'   the function will throw an error.
#' @return a matrix with preference orderings with proper C++ indices or NULL if
#'   the preference order is not complete.
roommate.checkPreferences = function(pref) {

    # check if pref is using R instead of C++ indexing
    if (all(apply(rbind(pref, c(1:NCOL(pref))), 2, sort) ==
                matrix(1:NCOL(pref), nrow = NCOL(pref), ncol = NCOL(pref)))) {
        return(pref - 1)
    }

    comp = array(1:(NROW(pref)), dim = dim(pref)) - 1
    for (i in 1:NROW(comp)) {
        for (j in 1:NCOL(comp)) {
            if (i >= j) {
                comp[i, j] = comp[i, j] + 1;
            }
        }
    }

    # check if pref has a complete listing otherwise given an error
    if (all(apply(pref,2,sort) == comp)) {
        return(pref)
    }

    return(NULL)
}

