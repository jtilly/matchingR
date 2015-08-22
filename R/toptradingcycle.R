#' Compute the top trading cycle algorithm
#'
#' @param pref An nxn matrix.
#' @return A vector of length n corresponding to the matchings being made, so that
#' e.g. if the 4th element is 6 then agent 4 was matched with agent 6. This vector
#' uses R style indexing. If no stable matching exists, it returns NULL.
#' @examples
#' results = toptrading(utils = replicate(4, rnorm(4)))
toptrading = function(pref = NULL, utils = NULL) {
    args = validateInputs(proposerPref = pref, reviewerPref = pref, proposerUtils = utils, reviewerUtils = utils)$proposerPref
    
    topTradingCycle(args)
}
