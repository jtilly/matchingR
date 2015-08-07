#include <queue>
#include <matchingR.h>

#include "utils.h"
#include "galeshapley.h"

// [[Rcpp::depends(RcppArmadillo)]]

//' Compute the Gale-Shapley Algorithm
//'
//' This function computes the Gale-Shapley Algorithm with one-to-one matching.
//' This function requires very specific types of arguments. It might be more
//' convenient to call the function \code{one2one()} instead that allows for
//' more flexible input choices.
//'
//' @param proposerPref is a matrix with the preference order of the proposing side of
//' the market
//' @param reviewerUtils is a matrix with cardinal utilities of the courted side of the
//' market
//' @return A list with the successful proposals and engagements.
//' \code{proposals} is a vector whose nth element contains the id of the reviewer
//' that proposer n is matched to.
//' \code{engagements} is a vector whose nth element contains the id of the proposer
//' that reviewer n is matched to.
// [[Rcpp::export]]
List galeShapleyMatching(const umat& proposerPref, const mat& reviewerUtils) {

    // number of proposers (men)
    int M = proposerPref.n_cols;
    // number of reviewers (women)
    int N = proposerPref.n_rows;
    // initialize engagements, proposals
    vec engagements(N), proposals(M);
    // create an integer queue of bachelors
    queue<int> bachelors;
    // set all proposals to N (aka no proposals)
    proposals.fill(N);
    // set all engagements to M (aka no engagements)
    engagements.fill(M);
    // every proposer starts out as a bachelor
    for(int iX=M-1; iX >= 0; iX--) {
        bachelors.push(iX);
    }

    // loop until there are no proposals to be made
    while (!bachelors.empty()) {
        // get the index of the proposer
        int proposer = bachelors.front();
        // get the proposer's preferences
        const uword * proposerPrefcol = proposerPref.colptr(proposer);
        // find the best available match
        for(int jX=0;jX<N;jX++) {
            // index of the reviewer that the proposer is interested in
            const uword wX = *proposerPrefcol++;
            // check if wX is available
            if(engagements(wX)==M) {
                engagements(wX) = proposer;
                proposals(proposer) = wX;
                break;
            }
            // check if the wX can be poached
            if(reviewerUtils(proposer, wX) > reviewerUtils(engagements(wX), wX)) {
                // make the guy who was just dropped a bachelor again
                proposals(engagements(wX)) = N;
                // and put him back into the bachelor queue
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


//' Check if a two-sided matching is stable
//'
//' This function checks if a given matching is stable for a particular set of
//' preferences. This function can check if a given check one-to-one,
//' one-to-many, or many-to-one matching is stable.
//'
//' @param proposerUtils is a matrix with cardinal utilities of the proposing side of the
//' market
//' @param reviewerUtils is a matrix with cardinal utilities of the courted side of the
//' market
//' @param proposals is a matrix that contains the id of the reviewer that a given
//' proposer is matched to: the first row contains the id of the reviewer that is
//' matched with the first proposer, the second row contains the id of the reviewer
//' that is matched with the second proposer, etc. The column dimension accommodates
//' proposers with multiple slots.
//' @param engagements is a matrix that contains the id of the proposer that a given
//' reviewer is matched to. The column dimension accommodates reviewers with multiple
//' slots
//' @return true if the matching is stable, false otherwise
// [[Rcpp::export]]
bool checkStability(mat proposerUtils, mat reviewerUtils, umat proposals, umat engagements) {

    // number of workers
    const int M = proposerUtils.n_cols;
    // number of firms
    const int N = proposerUtils.n_rows;
    // number of slots per firm
    const int slotsReviewers = engagements.n_cols;
    // number of slots per worker
    const int slotsProposers = proposals.n_cols;

    // turn proposals into C++ indices
    proposals = proposals-1;
    // turn engagements into C++ indices
    engagements = engagements-1;

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
