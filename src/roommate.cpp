#include "roommate.h"

// [[Rcpp::depends(RcppArmadillo)]]

//' Computes a stable roommate matching
//'
//' This function computes the Irving (1985) algorithm for finding
//' a stable matching in a one-sided matching market. Note that neither
//' existence nor uniqueness is guaranteed, this algorithm finds one
//' matching, not all of them. If no matching exists, returns 0.
//'
//' @param pref A matrix with agent's cardinal preferences. Column i is agent i's preferences.
//' @return A list with the matchings made. Unmatched agents are 'matched' to N.
// [[Rcpp::export]]
List stableRoommateMatching(const umat pref) {

    log().configure(QUIET);

    // Number of participants
    uword N = pref.n_cols;

    // Proposals to
    umat proposal_to(N, 1);
    // Proposals froms
    umat proposal_from(N, 1);
    umat proposed_to(N, 1);
    
    // All participants begin unmatched having proposed to nobody
    proposal_to = proposal_to.ones()*N;
    proposal_from = proposal_from.ones()*N;
    proposed_to = proposed_to.zeros();
    
    // Empty matchings
    umat matchings(N, 1);

    bool stable = false;
    while (!stable) {
        stable = true;
        log().info() << "Iterating through players.";
        for (uword n = 0; n < N; ++n) {
            // n proposes to the next best guy if has no proposal accepted
            // and if he hasn't proposed to everyone else
            if (proposed_to(n) == N) { log().warning() << "No stable matching exists."; return List::create(_["matchings"] = 0); }

            if (proposal_to(n) == N) {
                // find the proposee
                uword proposee = pref(proposed_to(n), n);

                // proposee's preferences
                const uword * prop_call = pref.colptr(proposee);

                // proposee's opinion of the proposer (lower is better)
                uword op = find(prop_call, prop_call + N, n) - prop_call;

                // opinion of his current match
                uword op_curr = find(prop_call, prop_call + N, proposal_from(proposee)) - prop_call;

                log().info() << n << " is proposing to " << proposee;
                log().info() << proposee << " ranks " << n << " at " << op;

                // if the next best guy likes him he accepts
                if (op < op_curr) {

                    log().info() << "He accepted!";

                    // make the proposal
                    proposal_to(n) = proposee;
                    // reject the proposee's proposer's proposal
                    if (proposal_from(proposee) != N) {
                        log().info() << proposee << " is rejecting the proposal from  " << proposal_from(proposee);
                        proposal_to(proposal_from(proposee)) = N;
                    }
                    proposal_from(proposee) = n;
                }

                // iterate n's proposal forward
                ++proposed_to(n);

                // not stable yet
                stable = false;
            }
        }
    }

    log().info() << "All players have made proposals.";

    for (uword n = 0; n < N; ++n) {
        log().info() << "Player " << n << " is proposing to " << proposal_to(n) << ".";
        log().info() << "Player " << n << " has a proposal from " << proposal_from(n) << ".";
    }

    // Generate table
    std::vector< std::deque<uword> > table(N);
    std::vector< std::deque<uword> > to_delete(N);
    for (uword n = 0; n < N; ++n) {
        for (uword i=0;i<N-1;++i) {
            table[n].push_back(pref(i, n));
        }
    }
    
    // Delete entries we eliminated in round 1
    for (uword n = 0; n < N; ++n) {
        for (int i = table[n].size()-1;i>= 0;--i) {
            if (table[n][i] == proposal_from(n)) {
                break;
            } else {
                if (table[n].size() == 0) { log().warning() << "No stable matching exists."; return List::create(_["matchings"] = 0); }
                // find and erase from the table
                bool erased = false;
                for (uword j = 0; j < table[table[n].back()].size(); ++j) {
                    if (table[table[n].back()][j] == n) {
                        table[table[n].back()].erase(table[table[n].back()].begin() + j);
                        erased = true;
                        break;
                    }
                }
                if (!erased) { log().warning() << "No stable matching exists."; return List::create(_["matchings"]   = 0); }
                table[n].pop_back();
            }
        }
    }
    
    log().info() << "Eliminating rotations.";

    // Eliminate rotations
    stable = false;
    while(!stable) {
        stable = true;
        for (uword n = 0; n < N; ++n) {
            if (table[n].size() > 1) {
                log().info() << "Starting with " << n;
                stable = false;
                std::vector<uword> x;
                std::vector<uword> index;

                uword new_index = n;
                uword rot_tail = -1;

                while (rot_tail == (uword) (index.end() - index.begin() - 1)) {
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
                for (uword i = rot_tail + 1; i < index.size(); ++i) {
                    while(table[x[i]].back() != index[i-1]) {
                        // find and erase from the table
                        bool erased = false;
                        for (uword j = 0; j < table[table[x[i]].back()].size(); ++j) {
                            if (table[table[x[i]].back()][j] == x[i]) {
                                table[table[x[i]].back()].erase(table[table[x[i]].back()].begin() + j);
                                erased = true;
                                break;
                            }
                        }
                        if (!erased) { log().warning() << "No stable matching exists."; return List::create(_["matchings"]   = 0); }
                        table[x[i]].pop_back();
                    }
                }

                for (uword i = 0; i < N; ++i) {
                    log().info() << table[i];
                }
            }
        }
    }

    // Check if anything is empty
    for (uword i = 0; i < table.size(); ++i) {
        if (table[i].empty()) {
            return List::create(_["matchings"] = 0);
        }
    }

    // Create the matchings
    matchings.resize(N);
    for (uword n = 0; n < N; ++n) {
        matchings[n] = table[n][0];
    }

    return List::create(_["matchings"] = matchings);
}

//' Check if a two-sided matching is stable
//'
//' This function checks if a given matching is stable for a particular set of
//' preferences. This function can check if a given check one-to-one,
//' one-to-many, or many-to-one matching is stable.
//'
//' @param pref is a matrix with ordinal rankings of the participants
//' @param matchings is an nx1 matrix encoding who is matched to whom
//' @return true if the matching is stable, false otherwise
// [[Rcpp::export]]
bool checkStabilityRoommate(umat& pref, umat& matchings) {
    
    // loop through everyone and check whether there's anyone else
    // who they'd rather be with
    for (uword i=0;i<pref.n_cols;++i) {
        for (uword j=i+1;j<pref.n_cols;++j) {

            // do i, j prefer to switch?
            bool i_prefers = false;
            bool j_prefers = false;
            
            // i?
            for (uword k=0;k<pref.n_rows;++k) {
                if (pref(k, i) == j) i_prefers = true;
                if (pref(k, i) == matchings(i)) break;
            }
            
            // j?
            for (uword k=0;k<pref.n_rows;++k) {
                if (pref(k, j) == j) j_prefers = true;
                if (pref(k, j) == matchings(j)) break;
            }
            
            // do they both want to switch?
            if (i_prefers && j_prefers) {
                return false;
            }
        }
    }
    
    return true;
    
}