#' Compute the top trading cycle algorithm
#'
#' @param pref An nxn matrix, each column representing each agent's ordinal preferences
#' over other agents. E.g., if the jth row of the ith column is 4, then agent i ranks
#' agent 4 jth.
#' @param utils An nxn matrix, each column representing each agent's cardinal preferences
#' over other agents. E.g., if the jth row of the ith column is 2.3, then agent i gets
#' utility of 2.3 from being matched to agent j.
#' @return A vector of length n corresponding to the matchings being made, so that
#' e.g. if the 4th element is 6 then agent 4 was matched to agent 6. This vector
#' uses R style indexing.
#' @examples
#' results = toptrading.matching(utils = replicate(4, rnorm(4)))
toptrading.matching = function(pref = NULL, utils = NULL) {
    args = galeShapley.validate(proposerPref = pref, reviewerPref = pref, proposerUtils = utils, reviewerUtils = utils)
    cpp_wrapper_ttc(args$proposerPref)
}

#' Check if a one-sided matching for the top trading cycle algorithm is stable
#'
#' @param pref is a matrix with ordinal rankings of the participants
#' @param matchings is an nx1 matrix encoding who is matched to whom using
#' R style indexing
#' @return true if the matching is stable, false otherwise
toptrading.checkStability = function(pref, matchings) {
    args = galeShapley.validate(proposerPref = pref, reviewerPref = pref, proposerUtils = NULL, reviewerUtils = NULL)
    cpp_wrapper_ttc_check_stability(args$proposerPref, matchings-1)
}

#' C++ wrapper for top trading cycle algorithm (Deprecated)
#'
#' This function uses the top trading cycle algorithm to find a stable trade between agents,
#' each with some indivisible good, and with preferences over the goods of other agents. Each
#' agent is matched to one other agent, and matchings are not necessarily two-way. Agents may
#' be matched with themselves.
#'
#' @param pref A matrix with agent's cardinal preferences. Column i is agent i's preferences.
#' @return A list with the matchings made. The matchings are encoded as follows: The first value
#' in the list is the individual to whom agent 1 will be giving his good, the second value in the list
#' is the individual to whom agent 2 will be giving his good, etc.
topTradingCycle = function(pref) {
    .Deprecated("cpp_wrapper_ttc")
    cpp_wrapper_ttc(pref)
}

#' Check if a one-sided matching for the top trading cycle algorithm is stable (Deprecated)
#'
#' @param pref is a matrix with ordinal rankings of the participants
#' @param matchings is an nx1 matrix encoding who is matched to whom using
#' R style indexing
#' @return true if the matching is stable, false otherwise
checkStabilityTopTradingCycle = function(pref, matchings) {
    .Deprecated("cpp_wrapper_ttc_check_stability")
}
