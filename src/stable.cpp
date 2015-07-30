#include <queue>
#include <matchingR.h>
#include <c_logger.h>
#include "stable.h"

// [[Rcpp::depends(RcppArmadillo)]]

//' Computes a stable roommate matching
//'
//' This function computes the Irving (1985) algorithm for finding
//' a stable matching in a one-sided matching market. Note that neither
//' existence nor uniqueness is guaranteed, this algorithm finds one
//' matching, not all of them.
//'
//' @param pref A matrix with agent's cardinal preferences. Column i is agent i's preferences.
//' @return A list with the matchings made. Unmatched agents are 'matched' to N.
// [[Rcpp::export]]
List stableRoommateMatching(const umat pref) {

    log().configure(WARNINGS);

    // Number of participants
    size_t N = pref.n_cols;

    // Proposals to
    std::vector<size_t> proposal_to(N);
    // Proposals froms
    std::vector<size_t> proposal_from(N);
    std::vector<size_t> proposed_to(N);

    // All participants begin unmatched having proposed to nobody
    std::fill(proposal_to.begin(), proposal_to.end(), N);
    std::fill(proposal_from.begin(), proposal_from.end(), N);
    std::fill(proposed_to.begin(), proposed_to.end(), 0);

    // Empty matchings
    std::vector<int> matchings;

    bool stable = false;
    while (!stable) {
        stable = true;
        log().info() << "Iterating through players.";
        for (size_t n = 0; n < N; ++n) {
            // n proposes to the next best guy if has no proposal accepted
            // and if he hasn't proposed to everyone else
            if (proposed_to[n] == N) { log().warning() << "No stable matching exists."; return List::create(_["matchings"] = matchings); }

            if (proposal_to[n] == N) {
                // find the proposee
                size_t proposee = pref(proposed_to[n], n);

                // proposee's preferences
                const unsigned int * prop_call = pref.colptr(proposee);

                // proposee's opinion of the proposer (lower is better)
                size_t op = find(prop_call, prop_call + N, n) - prop_call;

                // opinion of his current match
                size_t op_curr = find(prop_call, prop_call + N, proposal_from[proposee]) - prop_call;

                log().info() << n << " is proposing to " << proposee;
                log().info() << proposee << " ranks " << n << " at " << op;

                // if the next best guy likes him he accepts
                if (op < op_curr) {

                    log().info() << "He accepted!";

                    // make the proposal
                    proposal_to[n] = proposee;
                    // reject the proposee's proposer's proposal
                    if (proposal_from[proposee] != N) {
                        log().info() << proposee << " is rejecting the proposal from  " << proposal_from[proposee];
                        proposal_to[proposal_from[proposee]] = N;
                    }
                    proposal_from[proposee] = n;
                }

                // iterate n's proposal forward
                ++proposed_to[n];

                // not stable yet
                stable = false;
            }
        }
    }

    log().info() << "All players have made proposals.";

    for (size_t n = 0; n < N; ++n) {
        log().info() << "Player " << n << " is proposing to " << proposal_to[n] << ".";
        log().info() << "Player " << n << " has a proposal from " << proposal_from[n] << ".";
    }

    // Generate table
    std::vector< std::vector<size_t> > table(N);
    std::vector< std::vector<size_t> > to_delete(N);
    for (size_t n = 0; n < N; ++n) {
        for (size_t i = 0; i < N-1; ++i) {
            table[n].push_back(pref(i, n));
        }
    }

    // Delete entries we eliminated in round 1
    for (size_t n = 0; n < N; ++n) {
        for (int i = table[n].size()-1; i >= 0; --i) {
            if (table[n][i] == proposal_from[n]) {
                break;
            } else {
                if (table[n].size() == 0) { log().warning() << "No stable matching exists."; return List::create(_["matchings"] = matchings); }
                deleteValueWithWarning(&table[table[n].back()], n);
                table[n].pop_back();
            }
        }
    }

    // Check if anything is empty
    if (isEmpty(&table)) { log().warning() << "No stable matching exists."; return List::create(_["matchings"] = matchings); } else { log().info() << "Table nonempty."; }

    log().info() << "Eliminating rotations.";

    // Eliminate rotations
    stable = false;
    while(!stable) {
        stable = true;
        for (size_t n = 0; n < N; ++n) {
            if (table[n].size() > 1) {
                log().info() << "Starting with " << n;
                stable = false;
                std::vector<size_t> x;
                std::vector<size_t> index;

                size_t new_index = n;
                size_t rot_tail = -1;

                while (rot_tail == (size_t) (index.end() - index.begin() - 1)) {
                    int new_x = table[new_index][1];
                    new_index = table[new_x].back();

                    // Check for a rotation
                    rot_tail = find(index.begin(), index.end(), new_index) - index.begin();

                    x.push_back(new_x);
                    index.push_back(new_index);
                }

                log().info() << "Rotations: ";
                log().info() << index;
                log().info() << x;

                // Delete the rotation
                for (size_t i = rot_tail + 1; i < index.size(); ++i) {
                    while(table[x[i]].back() != index[i-1]) {
                        // Check whether empty
                        if (table[x[i]].size() == 0) { log().warning() << "No stable matching exists."; return List::create(_["matchings"]   = matchings); }
                        deleteValueWithWarning(&table[table[x[i]].back()], x[i]);
                        table[x[i]].pop_back();
                    }
                }

                for (size_t i = 0; i < N; ++i) {
                    log().info() << table[i];
                }
            }
        }
    }

    // Check if anything is empty
    if (isEmpty(&table)) { return List::create(_["matchings"] = matchings); } else { log().info() << "Table nonempty."; }

    // Create the matchings
    matchings.resize(N);
    for (size_t n = 0; n < N; ++n) {
        matchings[n] = table[n][0];
    }

    return List::create(_["matchings"] = matchings);
}

//' Ranks elements with column of a matrix, assuming a one-sided market.
//'
//' Returns the rank of each element with each column of a matrix. So,
//' if row 34 is the highest number for column 3, then the first row of
//' column 3 will be 34 -- unless it is column 34, in which case it will
//' be 35, to adjust for the fact that this is a single-sided market.
//'
//' @param pref A matrix with agent's cardinal preferences. Column i is agent i's preferences.
//' @return A list with the matchings made.
// [[Rcpp::export]]
umat sortIndexOneSided(const mat& u) {
    size_t N = u.n_rows;
    size_t M = u.n_cols;
    umat sortedIdx(N,M);
    for(size_t jX=0;jX<M;jX++) {
        sortedIdx.col(jX) = sort_index(u.col(jX), "descend");
    }
    
    for (size_t iX=0;iX<M;iX++) {
        for (size_t iY=0;iY<N;iY++) {
            if (sortedIdx(iY, iX) >= iX) {
                ++sortedIdx(iY, iX);
            }
        }
    }
    
    return sortedIdx;
}

bool isEmpty(std::vector< std::vector<size_t> > *table) {
    for (size_t n = 0; n < table->size(); ++n) {
        if (table->at(n).empty()) return true;
    }
    return false;
}

void deleteValueWithWarning(std::vector<size_t> *vec, size_t val) {
  std::vector<size_t>::iterator ind = find(vec->begin(), vec->end(), val);
  if (ind != vec->end()) {
    vec->erase(ind);
  }
}


