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