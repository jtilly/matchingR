#include <matchingR.h>

#include "utils.h"

// [[Rcpp::depends(RcppArmadillo)]]

//' Sort indices of a matrix within a column
//'
//' Within each column of a matrix, this function returns the indices of each
//' element in descending order
//'
//' @param u is the input matrix
//' @return a matrix with sorted indicies
//'
// [[Rcpp::export]]
umat sortIndex(const mat& u) {
    int N = u.n_rows;
    int M = u.n_cols;
    umat sortedIdx(N,M);
    for(int jX=0;jX<M;jX++) {
        sortedIdx.col(jX) = sort_index(u.col(jX), "descend");
    }
    return sortedIdx;
}

//' Ranks elements with column of a matrix, assuming a one-sided market.
//'
//' Returns the rank of each element with each column of a matrix. So,
//' if row 34 is the highest number for column 3, then the first row of
//' column 3 will be 34 -- unless it is column 34, in which case it will
//' be 35, to adjust for the fact that this is a single-sided market.
//'
//' @param u A matrix with agent's cardinal preferences. Column i is agent i's preferences.
//' @return A list with the matchings made.
// [[Rcpp::export]]
umat sortIndexOneSided(const mat& u) {
    uword N = u.n_rows;
    uword M = u.n_cols;
    umat sortedIdx(N,M);
    for(uword jX=0;jX<M;jX++) {
        sortedIdx.col(jX) = sort_index(u.col(jX), "descend");
    }
    
    for (uword iX=0;iX<M;iX++) {
        for (uword iY=0;iY<N;iY++) {
            if (sortedIdx(iY, iX) >= iX) {
                ++sortedIdx(iY, iX);
            }
        }
    }
    
    return sortedIdx;
}

//' Rank elements within column of a matrix
//'
//' This function returns the rank of each element within each column of a matrix.
//' The highest element receives the highest rank.
//'
//' @param sortedIdx is the input matrix
//' @return a rank matrix
//'
// [[Rcpp::export]]
umat rankIndex(const umat& sortedIdx) {
    int N = sortedIdx.n_rows;
    int M = sortedIdx.n_cols;
    umat rankedIdx(N,M);
    for(int iX=0; iX<N; iX++) {
        for(int jX=0; jX<M; jX++) {
            rankedIdx.at(sortedIdx.at(iX,jX), jX) = iX;
        }
    }
    return rankedIdx;
}