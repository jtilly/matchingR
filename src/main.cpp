#include <queue>
#include <matchingR.h>

// [[Rcpp::depends(RcppArmadillo)]]

#include "main.h"

//' Compute the Gale-Shapley Algorithm
//'
//' This function computes the Gale-Shapley Algorithm with one-to-one matching 
//'
//' @param prefM is a matrix with the preference order of the proposing side of 
//' the market
//' @param uW is a matrix with cardinal utilities of the courted side of the 
//' market
//' @return A list with the successful proposals and engagements. 
//' \code{proposals} is a vector whose nth element contains the id of the female 
//' that male n is matched to. 
//' \code{engagements} is a vector whose nth element contains the id of the male 
//' that female n is matched to.  
// [[Rcpp::export]]
List galeShapleyMatching(const umat prefM, const mat uW) {
    
    int M = prefM.n_rows;
    int N = prefM.n_cols;
    // initialize engagements, proposals
    vec engagements(N), proposals(M);
    queue<int> bachelors;
    // set all proposals to N (aka no proposals)
    proposals.fill(N);
    // set all engagements to M (aka no engagements)
    engagements.fill(M);
    // every man is a bachelor
    for(int iX=M-1;iX>=0;iX--) {
        bachelors.push(iX);
    }
    
    // loop until there are no proposals to be made
    while (!bachelors.empty()) {
        // get the index of the proposer
        int proposer = bachelors.front();
        // get the proposer's preferences
        urowvec prefMrow = prefM.row(proposer);
        // find the best match
        for(int jX=0;jX<N;jX++) {
            // index of the woman that the proposer is interested in
            int wX = prefMrow(jX);
            // check if the most preferred woman is available
            if(engagements(wX)==M) {
                engagements(wX) = proposer;
                proposals(proposer) = wX;
                break;
            }
            // check if the most preferred woman can be poached
            if(uW(wX, proposer) > uW(wX, engagements(wX))) {
                // make the guy who was just dropped a bachelor again
                proposals(engagements(wX)) = N;
                bachelors.push(engagements(wX));
                // hook up
                engagements(wX) = proposer;
                proposals(proposer) = wX;
                break;
            }
        }
        // pop at the end
        bachelors.pop();         
    }
    
    return List::create(
      _["proposals"]   = proposals,
      _["engagements"] = engagements);
}

//' Sort indices of a matrix within row
//' 
//' Within each row of a matrix, this function returns the indices of each 
//' element in descending order
//' 
//' @param u is the input matrix
//' @return a matrix with sorted indicies
//' 
// [[Rcpp::export]]
umat sortIndex(const mat u) {
    int N = u.n_cols;
    int M = u.n_rows;
    umat sortedIdx(M,N);
    for(int jX=0;jX<M;jX++) {
        sortedIdx.row(jX) = sort_index(u.row(jX), "descend");
    }
    return sortedIdx;
}

//' Rank elements within row of a matrix
//' 
//' This function returns the rank of each element within each row of a matrix.
//' The highest element receives the highest rank.
//' 
//' @param u is the input matrix
//' @return a rank matrix
//' 
// [[Rcpp::export]]
umat rankIndex(const umat sortedIdx) {
    int N = sortedIdx.n_cols;
    int M = sortedIdx.n_rows;
    umat rankedIdx(M,N);
    for(int jX=0; jX<M; jX++) {
        for(int iX=0; iX<N; iX++) {
            rankedIdx.at(jX, sortedIdx.at(jX,iX)) = iX;
        }
    }
    return rankedIdx;
}

//' Check if a matching is stable
//'
//' This function checks if a given matching is stable for a particular set of
//' preferences
//'
//' @param uM is a matrix with cardinal utilities of the proposing side of the 
//' market
//' @param uW is a matrix with cardinal utilities of the courted side of the 
//' market
//' @param proposals is a matrix that contains the id of the female that a given
//' man is matched to: the first row contains the id of the female that is 
//' matched with the first man, the second row contains the id of the female 
//' that is matched with the second man, etc. The column dimension accommodates
//' multi-worker firms.
//' @param engagements is a matrix that contains the id of the male that a given
//' female is matched to. The column dimension accommodates multi-worker firms.
//' @return true if the matching is stable, false otherwise
// [[Rcpp::export]]
bool checkStability(mat uWorkers, mat uFirms, const umat proposals, const umat engagements) {
    
    // number of workers
    const int M = uWorkers.n_rows;
    // number of firms
    const int N = uWorkers.n_cols;
    // number of slots per firm
    const int slotsFirms = engagements.n_cols;
    // number of slots per worker
    const int slotsWorkers = proposals.n_cols;
    
    // more jobs than workers (add utility from being unmatched to firms' preferences)
    if(N*slotsFirms>M*slotsWorkers) {
        uFirms.insert_cols(M, 1);
        uFirms.col(M).fill(-1e10);
    }
    // more workers than jobs (add utility from being unmatched to workers' preferences)
    if(M*slotsWorkers>N*slotsFirms) {
        uWorkers.insert_cols(N, 1);
        uWorkers.col(N).fill(-1e10);
    }
    // loop over workers
    for(int wX=0; wX<M; wX++) {
        // loop over firms
        for(int fX=0; fX<N; fX++) {
            // loop over multiple "slots" at the same worker
            for(int swX=0;swX<slotsWorkers;swX++) {
                // loop over multiple slots at the same firm
                for(int sfX=0;sfX<slotsFirms;sfX++) {
                    // check if wX and fX would rather be matched with each other than with their actual matches
                    if(uFirms(fX, wX) > uFirms(fX, engagements(fX, sfX)) && uWorkers(wX, fX) > uWorkers(wX, proposals(wX, swX))) {
                        Rprintf("matching is not stable; worker %d would rather be matched to firm %d and vice versa.\n", wX, fX);
                        return false;
                    } 
                }
            }
        }
    }
    return true;
}
