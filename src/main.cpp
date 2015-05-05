#include <queue>
#include <matchingR.h>

// [[Rcpp::depends(RcppArmadillo)]]

#include "main.h"

//' Compute the Gale-Shapley Algorithm
//'
//' This function computes the Gale-Shapley Algorithm with one-to-one matching 
//' when both sides of the market are of the same size and everybody gets 
//' matched.
//'
//' @param prefM is a matrix with the preference order of the proposing side of 
//' the market
//' @param uW is matrix with cardinal utilities of the courted side of the 
//' market
//' @return A list with the successful proposals and engagements. 
//' \code{proposals} is a vector whose nth element contains the id of the female 
//' that male n is matched to. 
//' \code{engagements} is a vector whose nth element contains the id of the male 
//' that female n is matched to.  
// [[Rcpp::export]]
List galeShapleyMatching(const umat prefM, const mat uW) {
    
    int N = prefM.n_cols;
    // initialize engagements, proposals
    vec engagements(N), proposals(N);
    queue<int> bachelors;
    // set all engagements to N (aka no engagements)
    engagements.fill(N);
    // every man is a bachelor
    for(int iX=N-1;iX>=0;iX--) {
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
            if(engagements(wX)==N) {
                engagements(wX) = proposer;
                proposals(proposer) = wX;
                break;
            }
            // check if the most preferred woman can be poached
            if(uW(wX, proposer) > uW(wX, engagements(wX))) {
                // make the guy who was just dropped a bachelor again
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

// [[Rcpp::export]]
umat sortIndex(const mat u) {
    int N = u.n_cols;
    umat sortedIdx(N,N);
    for(int jX=0;jX<N;jX++) {
        sortedIdx.row(jX) = sort_index(u.row(jX), "descend");
    }
    return sortedIdx;
}

// [[Rcpp::export]]
bool checkStability(const mat uM, const mat uW, const uvec proposals, const uvec engagements) {
    const int N = uM.n_cols;
    for(int mX=0; mX<N; mX++) {
        for(int wX=0; wX<N; wX++) {
            if(uM(mX, wX) > uM(mX, proposals(mX)) && uW(wX, mX) > uW(wX, engagements(wX))) {
                Rprintf("matching is not stable; man %d would rather be matched to woman %d and vice versa.\n", mX, wX);
                return false;
            } 
        }
    }
    return true;
}
