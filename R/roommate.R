#' Compute matching for one-sided markets
#'
#' This function returns a stable roommate matching for a one-sided market
#' using Irving (1985)'s algorithm. Stable matchings are neither guaranteed
#' to exist, nor to be unique. If no stable matching exists, 0 is returned.
#'
#' @param pref An n-1xn matrix, with each column representing the cardinal
#' utilities of each agent over matches with the other agents, so that, e.g.,
#' if element (4, 6) of this matrix is 2, then agent 4 ranks agent 2 6th. The
#' matrix accepts either 0-based indexing (C++ style) or 1-based indexing (R
#' style).
#' @param prefUtil An n-1xn matrix, each column representing ordinal preferences
#' of each agent over agents 1, 2, ..., i-1, i+1, i+2, ... n. For example, if
#' element (4, 6) of this matrix is 2, then agent 4 gets utility 2 from agent
#' 6.
#' @return A list of length n corresponding to the matchings being made, so that
#' e.g. if the 4th element is 6 then agent 4 was matched with agent 6.
#' @examples
#' results = onesided(prefUtil = replicate(4, rnorm(3)))
onesided = function(pref = NULL, prefUtil = NULL) {
    args = validateInputsOneSided(pref = pref, prefUtil = prefUtil);
    res = stableRoommateMatching(args);
    return(res$matchings);
}


#' Input validation for one-sided markets
#'
#' This function parses and validates the arguments for one sided preferences
#' for the function onesided. If it uses R-style indexing (i.e., beginning at
#' 1), then it re-numbers the preference matrix to use C++ style indexing.
#'
#' @param pref is an n-1xn matrix, with each row representing an ordinal ranking.
#' @param prefUtil if an n-1xn matrix, with each row representing the cardinal preferences
#' of the agents.
#' @return The validated inputs, ready to be sent to C++ code.
validateInputsOneSided = function(pref = NULL, prefUtil = NULL) {

    # Convert cardinal utility to ordinal, if necessary
    if (is.null(pref) && !is.null(prefUtil)) {
        pref = sortIndexOneSided(as.matrix(prefUtil))
    }

    # check inputs
    if (NROW(prefUtil)+1 != NCOL(prefUtil)) {
        stop("preference matrix must be n-1xn")
    }

    if (NROW(pref)+1 != NCOL(pref)) {
        stop("preference matrix must be n-1xn")
    }

    pref = checkPreferenceOrderOnesided(pref)
    if (is.null(pref)) {
        stop(
            "preferences are not a complete list of preference orderings"
        )
    }

    return(pref)
}
