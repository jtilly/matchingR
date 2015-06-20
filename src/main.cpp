#include <queue>
#include <matchingR.h>

// [[Rcpp::depends(RcppArmadillo)]]

#include "main.h"

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
List galeShapleyMatching(const umat proposerPref, const mat reviewerUtils) {
    
    // number of proposers (men)
    int M = proposerPref.n_rows;
    // number of reviewers (women)
    int N = proposerPref.n_cols;
    // initialize engagements, proposals
    vec engagements(N), proposals(M);
    // create an integer queue of bachelors
    queue<int> bachelors;
    // set all proposals to N (aka no proposals)
    proposals.fill(N);
    // set all engagements to M (aka no engagements)
    engagements.fill(M);
    // every proposer starts out as a bachelor
    for(int iX=M-1;iX>=0;iX--) {
        bachelors.push(iX);
    }
    
    // loop until there are no proposals to be made
    while (!bachelors.empty()) {
        // get the index of the proposer
        int proposer = bachelors.front();
        // get the proposer's preferences
        urowvec proposerPrefrow = proposerPref.row(proposer);
        // find the best available match
        for(int jX=0;jX<N;jX++) {
            // index of the reviewer that the proposer is interested in
            int wX = proposerPrefrow(jX);
            // check if wX is available
            if(engagements(wX)==M) {
                engagements(wX) = proposer;
                proposals(proposer) = wX;
                break;
            }
            // check if the wX can be poached
            if(reviewerUtils(wX, proposer) > reviewerUtils(wX, engagements(wX))) {
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
//' @param sortedIdx is the input matrix
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
    const int M = proposerUtils.n_rows;
    // number of firms
    const int N = proposerUtils.n_cols;
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
        reviewerUtils.insert_cols(M, 1);
        reviewerUtils.col(M).fill(-1e10);
    }
    // more workers than jobs (add utility from being unmatched to workers' preferences)
    if(M*slotsProposers>N*slotsReviewers) {
        proposerUtils.insert_cols(N, 1);
        proposerUtils.col(N).fill(-1e10);
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
                    if(reviewerUtils(fX, wX) > reviewerUtils(fX, engagements(fX, sfX)) && proposerUtils(wX, fX) > proposerUtils(wX, proposals(wX, swX))) {
                        Rprintf("matching is not stable; worker %d would rather be matched to firm %d and vice versa.\n", wX, fX);
                        return false;
                    } 
                }
            }
        }
    }
    return true;
}


//' Computes a stable roommate matching
//'
//' This function computes the Irving (1985) algorithm.
//'
//' @param pref A matrix with agent's cardinal preferences. Column i is agent i's preferences.
//' @return A list with the matchings made.
// [[Rcpp::export]]
List stableRoommateMatching(const umat pref) {

    // Number of participants
    int N = pref.n_cols;

    // Proposals to
    std::vector<int> proposal_to(N);
    // Proposals froms
    std::vector<int> proposal_from(N);
    std::vector<int> proposed_to(N);
    
    // All participants begin unmatched having proposed to nobody
    std::fill(proposal_to.begin(), proposal_to.end(), N);
    std::fill(proposal_from.begin(), proposal_from.end(), N);
    std::fill(proposed_to.begin(), proposed_to.end(), 0);

    bool stable = false;
    while (!stable) {
        stable = true;
        for (size_t n = 0; n < N; ++n) {
            // n proposes to the next best guy if has no proposal accepted
            if (proposal_to[n] == N) {
                
                // find the proposee
                int proposee = pref(proposed_to[n], n);

                // proposee's preferences
                const uint * prop_call = pref.colptr(proposee);

                // proposee's opinion of the proposer (lower is better)
                int op = find(prop_call, prop_call + N, n) - prop_call;

                // if the next best guy likes him he accepts
                if (op < proposal_from[proposee]) {
                    // make the proposal
                    proposal_to[n] = proposee;
                    // reject the proposee's proposer's proposal
                    if (proposal_from[proposee] != N) {
                        proposal_to[proposal_from[proposee]] = N;
                    }
                    proposal_from[proposee] = n;
                }

                // regardless of whether he was matched or not, iterate n's proposal forward
                proposed_to[n] < N ? ++proposed_to[n] : proposed_to[n] = N;

                // not stable yet
                stable = false;
            }
        }
    }

    // Generate table
    std::vector< std::vector<int> > table(N);
    std::vector< std::vector<int> > to_delete(N);
    for (size_t n = 0; n < N; ++n) {
        for (size_t i = 0; i < N-1; ++i) {
            table[n].push_back(pref(i, n));
        }
    }
    
    for (size_t n = 0; n < N; ++n) {
        for (size_t i = N-2; i >= 0; --i) {
            if (pref(i, n) == proposal_from[n]) {
                break;
            } else {
                to_delete[table[n].back()].push_back(n);
                table[n].pop_back();
            }
        }
    }
    
    for (size_t n = 0; n < N; ++n) {
        for (size_t i = 0; i < to_delete[n].size(); ++i) {
            table[n].erase(find(table[n].begin(), table[n].end(), to_delete[n][i]));
        }
    }
    
    // Eliminate rotations
    stable = false;
    while(!stable) {
        stable = true;
        for (size_t n = 0; n < N; ++n) {
            if (table[n].size() > 1) {
                stable = false;
                std::vector<size_t> x;
                std::vector<size_t> index;

                size_t new_index = n;
                size_t rot_tail = -1;
                
                while (rot_tail == index.end()-index.begin()-1) {
                    int new_x = table[new_index][1];
                    new_index = table[new_x].back();
                    
                    // Check for a rotation
                    rot_tail = find(index.begin(), index.end(), new_index) - index.begin();
                    
                    x.push_back(new_x);
                    index.push_back(new_index);
                }

                // Delete the rotation
                for (size_t i = rot_tail + 1; i < index.size(); ++i) {
                    bool finished = false;
                    while(table[x[i]].back() != index[i-1]) {
                        table[table[x[i]].back()].erase(find(table[table[x[i]].back()].begin(), table[table[x[i]].back()].end(), x[i]));
                        table[x[i]].pop_back();
                    }
                }
            }
        }
    }

    // Check if anything is empty
    for (size_t n = 0; n < N; ++n) {
        if (table[n].empty()) {
            stop("No stable matching exists.");
        }
    }
    
    // Create the matchings
    std::vector<int> matchings(N);
    for (size_t n = 0; n < N; ++n) {
        matchings[n] = table[n][0];
    }
    
    return List::create(
      _["matchings"]   = matchings);
}
