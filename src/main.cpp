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
//' Within each row of a matrix, this function return the indices of each 
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
//' This function assigns the rank to each element within each row of a matrix.
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
//' @param proposals is a vector that contains the id of the female that a given
//' man is matched to: the first row contains the id of the female that is 
//' matched with the first man, the second row contains the id of the female 
//' that is matched with the second man, etc.
//' @param engagements is a vector that contains the id of the male that a given
//' female is matched to
//' @return true if the matching is stable, false otherwise
// [[Rcpp::export]]
bool checkStability(mat uM, mat uW, const uvec proposals, const uvec engagements) {
    const int M = uM.n_rows;
    const int N = uM.n_cols;
    // check which side of the market is bigger
    if(N>M) {
        uW.insert_cols(M, 1);
        uW.col(M).fill(-1e10);
    }
    if(M>N) {
        uM.insert_cols(N, 1);
        uM.col(N).fill(-1e10);
    }
    for(int mX=0; mX<M; mX++) {
        for(int wX=0; wX<N; wX++) {
            if(uW(wX, mX) > uW(wX, engagements(wX)) && uM(mX, wX) > uM(mX, proposals(mX))) {
                Rprintf("matching is not stable; man %d would rather be matched to woman %d and vice versa.\n", mX, wX);
                return false;
            } 
        }
    }
    return true;
}
