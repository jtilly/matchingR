#' Compute matching for one-sided markets
#'
#' This function returns a stable roommate matching for a one-sided market
#' using Irving (1985)'s algorithm. Stable matchings are neither guaranteed
#' to exist, nor to be unique. If no stable matching exists, 0 is returned.
#'
#' @param pref An n-1xn matrix, with each column representing the ordinal
#' utilities of each agent over matches with the other agents, so that, e.g.,
#' if element (4, 6) of this matrix is 2, then agent 4 ranks agent 2 6th. The
#' matrix accepts either 0-based indexing (C++ style) or 1-based indexing (R
#' style).
#' @param utils An n-1xn matrix, each column representing cardinal preferences
#' of each agent over agents 1, 2, ..., i-1, i+1, i+2, ... n. For example, if
#' element (4, 6) of this matrix is 2, then agent 4 gets utility 2 from agent
#' 6.
#' @return A vector of length n corresponding to the matchings being made, so that
#' e.g. if the 4th element is 6 then agent 4 was matched with agent 6. This vector
#' uses R style indexing. If no stable matching exists, it returns NULL.
#' @examples
#' results = roommate.matching(utils = replicate(4, rnorm(3)))
roommate.matching = function(pref = NULL, utils = NULL) {
    pref.validated = roommate.validate(pref = pref, utils = utils);
    res = cpp_wrapper_irving(pref.validated);
    if (all(res == 0)) {
        return(NULL)
    } else {
        return(res + 1)
    }
}

#' Input validation for one-sided markets
#'
#' This function parses and validates the arguments for one sided preferences
#' for the function onesided. If it uses R-style indexing (i.e., beginning at
#' 1), then it re-numbers the preference matrix to use C++ style indexing.
#'
#' @param pref is an n-1xn matrix, with each row representing an ordinal ranking.
#' @param utils if an n-1xn matrix, with each row representing the cardinal preferences
#' of the agents.
#' @return The validated inputs, ready to be sent to C++ code.
roommate.validate = function(pref = NULL, utils = NULL) {

    if(get("column.major", envir = pkg.env) == FALSE) {
        if(!is.null(pref)) {
            pref = t(pref)
        }
        if(!is.null(utils)) {
            utils = t(utils)
        }
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
#' @param pref An n-1xn matrix, with each column representing the ordinal
#' utilities of each agent over matches with the other agents, so that, e.g.,
#' if element (4, 6) of this matrix is 2, then agent 4 ranks agent 2 6th. The
#' matrix accepts either 0-based indexing (C++ style) or 1-based indexing (R
#' style).
#' @param matching is a matrix with matchings (R style indexing)
#' @param utils A n-1xn matrix with each column representing the cardinal
#'   utilities of each agent over matches with the other agents
#' @return true if stable, false if not
roommate.checkStability = function(pref=NULL, matching, utils=NULL) {
    pref.validated = roommate.validate(pref = pref, utils = utils);
    cpp_wrapper_irving_check_stability(pref.validated, matching)
}

#' Check if preference order for a one-sided market is complete.
#'
#' @param pref is a matrix with a preference ordering for a one-sided market.
#' If necessary transforms the indices from R indices (starting at 1) to C++
#' indices (starting at 0).
#' @return a matrix with preference orderings with proper C++ indices or NULL
#' if the preference order is not complete.
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

