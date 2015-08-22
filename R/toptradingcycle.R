#' Compute the top trading cycle algorithm
#'
#' @param pref An nxn matrix, each column representing each agent's ordinal preferences 
#' over other agents. E.g., if the jth row of the ith column is 4, then agent i ranks 
#' agent 4 jth.
#' @param util An nxn matrix, each column representing each agent's cardinal preferences
#' over other agents. E.g., if the jth row of the ith column is 2.3, then agent i gets
#' utility of 2.3 from being matched to agent j. 
#' @return A vector of length n corresponding to the matchings being made, so that
#' e.g. if the 4th element is 6 then agent 4 was matched with agent 6. This vector
#' uses R style indexing. If no stable matching exists, it returns NULL.
#' @examples
#' results = toptrading(utils = replicate(4, rnorm(4)))
toptrading = function(pref = NULL, utils = NULL) {
    args = validateInputs(proposerPref = pref, reviewerPref = pref, proposerUtils = utils, reviewerUtils = utils)$proposerPref
    topTradingCycle(args)
}
