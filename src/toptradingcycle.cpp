//  matchingR -- Matching Algorithms in R and C++
//
//  Copyright (C) 2015  Jan Tilly <jtilly@econ.upenn.edu>
//                      Nick Janetos <njanetos@econ.upenn.edu>
//
//  This file is part of matchingR.
//
//  matchingR is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 2 of the License, or
//  (at your option) any later version.
//
//  matchingR is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

#include "toptradingcycle.h"

// [[Rcpp::depends(RcppArmadillo)]]

//' Computes the top trading cycle algorithm
//'
//' This is the C++ wrapper for the top trading cycle algorithm. Users should not
//' call this function directly, but instead use
//' \code{\link{toptrading}}.
//'
//' This function uses the top trading cycle algorithm to find a stable trade
//' between agents, each with some indivisible good, and with preferences over
//' the goods of other agents. Each agent is matched to one other agent, and
//' matchings are not necessarily two-way. Agents may be matched with
//' themselves.
//'
//' @param pref is a matrix with the preference order of all individuals in the
//'   market. If there are \code{n} individuals, then this matrix will be of
//'   dimension \code{n} by \code{n}. The \code{i,j}th element refers to
//'   \code{j}'s \code{i}th most favorite partner. Preference orders must be
//'   specified using C++ indexing (starting at 0).
//' @return A vector of length \code{n} corresponding to the matchings being
//'   made, so that e.g. if the \code{4}th element is \code{5} then agent
//'   \code{4} was matched to agent \code{6}. This vector uses C++ indexing that
//'   starts at 0.
//' @export
// [[Rcpp::export]]
uvec cpp_wrapper_ttc(const umat pref) {

    // maximum value of uword
    uword NULL_VAL = static_cast<uword>(-1);

    // the number of participants
    uword N = pref.n_cols;


    // a vector of zeros and ones, encodes whether a
    // participant has been matched or not
    // everyone begins unmatched.
    uvec is_matched(N);
    is_matched.zeros();

    // the vector of matchings to be returned
    uvec matchings(N);
    matchings.fill(NULL_VAL);

    // used for the algorithm below
    uword current_agent = NULL_VAL;


    // loop until everyone's been matched
    while (true) {

        // if current_agent = -1, then set current_agent to be the first unmatched guy
        if (current_agent == NULL_VAL) {
            // find the first unmatched guy
            current_agent = as_scalar(find(is_matched == 0, 1));
        }


        // now identify rotations
        while(true) {
            // start cycling through preferences, starting with current_agent

            // find current_agent's most preferred, unmatched outcome, p
            // provisionally match current_agent to p by setting matchings[current_agent] = p
            for (uword i = 0; i < N; ++i) {
            if (is_matched(pref(i, current_agent)) == 0) {
                    matchings(current_agent) = pref(i, current_agent);
                    break;
                }
            }

            // check if p has already shown up in this chain by checking if
            // matchings[p] is larger than -1. if it is larger than -1, then
            // that agent, who we know is unmatched, must already have shown up
            // somewhere in this loop. if matchings[p] is equal to -1, then that agent
            // has never shown up in a loop and we can continue

            // if matchings is larger than -1, then we have a rotation, starting
            // with p, and ending with current_agent, so break
            if (matchings(matchings(current_agent)) != NULL_VAL) {
                break;
            }

            // otherwise, continue looking for a rotation by setting current_agent to the next guy
            current_agent = matchings(current_agent);
        }

        // loop through, starting with p, then matchings[p], etc., and
        // ending with current_agent. for each agent, set is_matched to
        // 1.
        for (uword i = matchings(current_agent); i != current_agent; i = matchings(i)) {
            is_matched(i) = 1;
        }
        is_matched(current_agent) = 1;

        for (uword i = 0; i < N; i++) {
        }

        // check if everyone's matched, if so, we're done, so break
        if (sum(is_matched) == N) break;

        // otherwise, we need to set current_agent in such a way so as to continue
        // looking for rotations

        // one way to do this would be to check if (1-is_matched) .* matchings = -1*sum(1-is_matched)
        // if true, then set current_agent equal to -1 to reset the rotation finding process
        if (sum((1-is_matched)%matchings) == -1*sum(1-is_matched)) {
            current_agent = -1;
        } else {
            // otherwise, we just cut off the 'tail' when we removed the rotation, and the body
            // can be used to find a new rotation
            // in this case, set current_agent to be the last agent in the head, i.e., the agent who we
            // matched to matchings(matchings(current_agent)), but who was not actually matched.
            for (uword i = 0; i < N; ++i) {
                if (matchings(i) == matchings(current_agent) && is_matched(i) == 0) {
                    current_agent = i;
                    break;
                }
            }
        }
    }

    return matchings;
}

//' Check if a one-sided matching for the top trading cycle algorithm is stable
//'
//' @param pref is a matrix with the preference order of all individuals in the
//'   market. If there are \code{n} individuals, then this matrix will be of
//'   dimension \code{n} by \code{n}. The \code{i,j}th element refers to
//'   \code{j}'s \code{i}th most favorite partner. Preference orders must be
//'   specified using C++ indexing (starting at 0).
//' @param matchings is a vector of length \code{n} corresponding to the
//'   matchings being made, so that e.g. if the \code{4}th element is \code{5}
//'   then agent \code{4} was matched to agent \code{6}. This vector uses C++
//'   indexing that starts at 0.
//' @return true if the matching is stable, false otherwise
//' @export
// [[Rcpp::export]]
bool cpp_wrapper_ttc_check_stability(umat pref, uvec matchings) {

    // loop through everyone and check whether there's anyone else
    // who they'd rather be with
    for (uword i=0; i<pref.n_cols; i++) {
        for (uword j=i; j<pref.n_cols; j++) {

            // do i, j prefer to switch?
            bool i_prefers = false;
            bool j_prefers = false;

            // i?
            for (uword k=0; k<pref.n_rows; k++) {
                if (pref(k, i) == matchings(i)) break;
                if (pref(k, i) == j) i_prefers = true;
            }

            // j?
            for (uword k=0; k<pref.n_rows; k++) {
                if (pref(k, j) == matchings(j)) break;
                if (pref(k, j) == i) j_prefers = true;
            }

            // do they both want to switch?
            if (i_prefers && j_prefers) {
                return false;
            }
        }
    }

    return true;

}
