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

#include <queue>
#include <matchingR.h>

#include "utils.h"
#include "galeshapley.h"

// [[Rcpp::depends(RcppArmadillo)]]

//' C++ wrapper for Gale-Shapley Algorithm
//'
//' This function provides an R wrapper for the C++ backend. Users should not
//' call this function directly and instead use
//' \code{\link{galeShapley.marriageMarket}} or
//' \code{\link{galeShapley.collegeAdmissions}}.
//'
//' @param proposerPref is a matrix with the preference order of the proposing
//'   side of the market. If there are \code{n} proposers and \code{m} reviewers
//'   in the market, then this matrix will be of dimension \code{m} by \code{n}.
//'   The \code{i,j}th element refers to \code{j}'s \code{i}th most favorite
//'   partner. Preference orders must be complete and specified using C++
//'   indexing (starting at 0).
//' @param reviewerUtils is a matrix with cardinal utilities of the courted side
//'   of the market. If there are \code{n} proposers and \code{m} reviewers, then
//'   this matrix will be of dimension \code{n} by \code{m}. The \code{i,j}th
//'   element refers to the payoff that individual \code{j} receives from being
//'   matched to individual \code{i}.
//'  @return  A list with elements that specify who is matched to whom. Suppose
//'    there are \code{n} proposers and \code{m} reviewers. The list contains
//'    the following items:
//'   \itemize{
//'    \item{\code{proposals} is a vector of length \code{n} whose \code{i}th
//'    element contains the number of the reviewer that proposer \code{i} is
//'    matched to using C++ indexing. Proposers that remain unmatched will be
//'    listed as being matched to \code{m}.}
//'    \item{\code{engagements} is a vector of length \code{m} whose \code{j}th
//'    element contains the number of the proposer that reviewer \code{j} is
//'    matched to using C++ indexing. Reviwers that remain unmatched will be
//'    listed as being matched to \code{n}.}
//'   }
// [[Rcpp::export]]
List cpp_wrapper_galeshapley(const umat& proposerPref, const mat& reviewerUtils) {

    // number of proposers (men)
    int M = proposerPref.n_cols;
    
    // number of reviewers (women)
    int N = proposerPref.n_rows;
    
    // initialize engagements, proposals
    vec engagements(N), proposals(M);
    
    // create an integer queue of bachelors 
    // the idea of using queues for this problem is borrowed from
    // http://rosettacode.org/wiki/Stable_marriage_problem#C.2B.2B
    queue<int> bachelors;
    
    // set all proposals to N (aka no proposals)
    proposals.fill(N);
    
    // set all engagements to M (aka no engagements)
    engagements.fill(M);
    
    // every proposer starts out as a bachelor
    for(int iX=M-1; iX >= 0; iX--) {
        bachelors.push(iX);
    }

    // loop until there are no more proposals to be made
    while (!bachelors.empty()) {
        
        // get the index of the proposer
        int proposer = bachelors.front();
        
        // get the proposer's preferences: we use a raw pointer to the memory 
        // used by the column `proposer` for performance reasons (this is to avoid
        // making a copy of the proposers vector of preferences)
        const uword * proposerPrefcol = proposerPref.colptr(proposer);
        
        // find the best available match for proposer
        for(int jX=0; jX<N; jX++) {
        
            // get the index of the reviewer that the proposer is interested in
            // by dereferencing the pointer; increment the pointer after use (not its value)
            const uword wX = *proposerPrefcol++;
        
            // check if wX is available (`M` means unmatched)
            if(engagements(wX)==M) {
        
                // if available, then form a match
                engagements(wX) = proposer;
                proposals(proposer) = wX;
        
                // go to the next proposer
                break;
            }
          
            // wX is already matched, let's see if wX can be poached
            if(reviewerUtils(proposer, wX) > reviewerUtils(engagements(wX), wX)) {
          
                // wX's previous partner becomes unmatched (`N` means unmatched)
                proposals(engagements(wX)) = N;
                bachelors.push(engagements(wX));
          
                // proposer and wX form a match
                engagements(wX) = proposer;
                proposals(proposer) = wX;
          
                // go to the next proposer
                break;
            }
        }
        
        // remove proposer from bachelor queue: proposer will remain unmatched
        bachelors.pop();
    }

    return List::create(
      _["proposals"]   = proposals,
      _["engagements"] = engagements);
}


//' C++ Wrapper to Check Stability of Two-sided Matching
//'
//' This function checks if a given matching is stable for a particular set of
//' preferences. This function provides an R wrapper for the C++ backend. Users
//' should not call this function directly and instead use
//' \code{\link{galeShapley.checkStability}}.
//'
//' @param proposerUtils is a matrix with cardinal utilities of the proposing
//'   side of the market. If there are \code{n} proposers and \code{m} reviewers,
//'   then this matrix will be of dimension \code{m} by \code{n}. The
//'   \code{i,j}th element refers to the payoff that individual \code{j} receives
//'   from being matched to individual \code{i}.
//' @param reviewerUtils is a matrix with cardinal utilities of the courted side
//'   of the market. If there are \code{n} proposers and \code{m} reviewers, then
//'   this matrix will be of dimension \code{n} by \code{m}. The \code{i,j}th
//'   element refers to the payoff that individual \code{j} receives from being
//'   matched to individual \code{i}.
//' @param proposals is a matrix that contains the number of the reviewer that a
//'   given proposer is matched to: the first row contains the number of the
//'   reviewer that is matched with the first proposer (using C++ indexing), the
//'   second row contains the id of the reviewer that is matched with the second
//'   proposer, etc. The column dimension accommodates proposers with multiple
//'   slots.
//' @param engagements is a matrix that contains the number of the proposer that
//'   a given reviewer is matched to (using C++ indexing). The column dimension
//'   accommodates reviewers with multiple slots.
//' @return true if the matching is stable, false otherwise
// [[Rcpp::export]]
bool cpp_wrapper_galeshapley_check_stability(mat proposerUtils, mat reviewerUtils, umat proposals, umat engagements) {

    // number of workers
    const int M = proposerUtils.n_cols;
    
    // number of firms
    const int N = proposerUtils.n_rows;
    
    // number of slots per firm
    const int slotsReviewers = engagements.n_cols;
    
    // number of slots per worker
    const int slotsProposers = proposals.n_cols;

    // more jobs than workers (add utility from being unmatched to firms' preferences)
    if(N*slotsReviewers>M*slotsProposers) {
        reviewerUtils.insert_rows(M, 1);
        reviewerUtils.row(M).fill(-1e10);
    }
    // more workers than jobs (add utility from being unmatched to workers' preferences)
    if(M*slotsProposers>N*slotsReviewers) {
        proposerUtils.insert_rows(N, 1);
        proposerUtils.row(N).fill(-1e10);
    }
    
    // loop over workers
    for(int wX=0; wX<M; wX++) {
    
        // loop over firms
        for(int fX=0; fX<N; fX++) {
    
            // loop over multiple "slots" at the same worker
            for(int swX=0;swX<slotsProposers;swX++) {
    
                // loop over multiple slots at the same firm
                for(int sfX=0;sfX<slotsReviewers;sfX++) {
    
                    // check if wX and fX would rather be matched with each other than with their actual matches
                    if(reviewerUtils(wX, fX) > reviewerUtils(engagements(fX, sfX), fX) && proposerUtils(fX, wX) > proposerUtils(proposals(wX, swX), wX)) {
                        ::Rf_warning("matching is not stable; worker %d would rather be matched to firm %d and vice versa.\n", wX, fX);
                        return false;
                    }
                }
            }
        }
    }
    return true;
}
