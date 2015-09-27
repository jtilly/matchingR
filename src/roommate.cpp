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
//' @return A vector with the matchings made. Unmatched agents are 'matched' to N.
// [[Rcpp::export]]
uvec cpp_wrapper_irving(const umat pref) {

    // Number of participants
    uword N = pref.n_cols;

    uvec proposal_to(N);
    uvec proposal_from(N);
    uvec proposed_to(N);

    // All participants begin unmatched having proposals accepted by nobody (=N)...
    proposal_to.fill(N);
    // having accepted proposals from nobody (=N)...
    proposal_from.fill(N);
    // and having proposed to nobody.
    proposed_to.zeros();

    // Empty matchings
    uvec matchings(N);

    bool stable = false;
    while (!stable) {
        // set stable to false later if anyone hasn't proposed / been proposed to
        stable = true;
        for (uword n = 0; n < N; n++) {
            // n proposes to the next best guy if he hasn't proposed to everyone already...
            if (proposed_to(n) >= N-1) { return matchings.zeros(); }

            // or if he has no proposals accepted by anyone.
            if (proposal_to(n) == N) {

                // find the player he is proposing to next
                uword proposee = pref(proposed_to(n), n);

                // proposee's preferences
                //const uword * prop_call = pref.colptr(proposee);
                const uvec prop_call = pref.col(proposee);

                // find proposee's opinion of the proposer (lower is better)
                uword op = N;
                for (uword i = 0; i < prop_call.n_elem; i++) {
                    if (prop_call(i) == n) {
                        op = i;
                        break;
                    }
                }

                if (op == N) {
                    stop("Invalid preference matrix: Incomplete preferences.");
                }

                // find proposee's opinion of his current match
                // lower is better
                // unmmatched is N
                uword op_curr = N;
                for (uword i = 0; i < prop_call.n_elem; i++) {
                    if (prop_call(i) == proposal_from(proposee)) {
                        op_curr = i;
                        break;
                    }
                }

                // if the next best guy likes him he accepts
                if (op < op_curr) {

                    // make the proposal
                    proposal_to(n) = proposee;
                    // reject the proposee's original proposer's proposal
                    // got it!?
                    if (proposal_from(proposee) != N) {
                        proposal_to(proposal_from(proposee)) = N;
                        // someone has proposed to nobody, we're not stabler yet
                        stable = false;
                    }
                    // record the proposal
                    proposal_from(proposee) = n;
                } else {
                    // offer was rejected, we're not stable yet
                    stable = false;
                }

                // iterate n's proposal forward
                proposed_to(n)++;
            }
        }
    }

    // Generate tables, initially of length N
    std::vector< std::deque<uword> > table(N, std::deque<uword>(N-1));
    for (uword n = 0; n < N; ++n) {
        for (uword i=0; i<N-1; i++) {
            // fill in the table with preferences
            table[n][i] = pref(i, n);
        }
    }

    // Delete entries we eliminated in round 1
    for (uword n = 0; n < N; n++) {
        for (int i = table[n].size()-1; i>= 0; i--) {
            if (table[n][i] == proposal_from(n)) {
                break;
            } else {
                if (table[n].size() == 0) { return matchings.zeros(); }
                // find and erase from the table
                bool erased = false;
                for (uword j = 0; j < table[table[n].back()].size(); j++) {
                    if (table[table[n].back()][j] == n) {
                        table[table[n].back()].erase(table[table[n].back()].begin() + j);
                        erased = true;
                        break;
                    }
                }
                if (!erased) { return matchings.zeros(); }
                table[n].pop_back();
            }
        }
    }

    // Eliminate rotations
    // A 'rotation' is a series of individuals and preference pairs which satisfy
    // a relationship specified in Irving (1985). Removing a rotation maintains the
    // status of the table as a 'stable' table, meaning everyone's most preferred
    // feasible option hates them.
    stable = false;
    while(!stable) {
        stable = true;
        for (uword n = 0; n < N; n++) {
            if (table[n].size() > 1) {
                stable = false;
                std::vector<uword> x;
                std::vector<uword> index;

                uword new_index = n;
                // Unassigned for now, so assign to the maximum value
                uword rot_tail = static_cast<uword>(-1);

                while (rot_tail == (uword) (index.end() - index.begin() - 1)) {
                    int new_x = table[new_index][1];
                    new_index = table[new_x].back();

                    // Check for a rotation
                    rot_tail = find(index.begin(), index.end(), new_index) - index.begin();

                    x.push_back(new_x);
                    index.push_back(new_index);
                }

                // Delete the rotation
                for (uword i = rot_tail + 1; i < index.size(); i++) {
                    while(table[x[i]].back() != index[i-1]) {
                        // find and erase from the table
                        bool erased = false;
                        for (uword j = 0; j < table[table[x[i]].back()].size(); j++) {
                            if (table[table[x[i]].back()][j] == x[i]) {
                                table[table[x[i]].back()].erase(table[table[x[i]].back()].begin() + j);
                                erased = true;
                                break;
                            }
                        }
                        if (!erased) { return matchings.zeros(); }
                        table[x[i]].pop_back();
                    }
                }
            }
        }
    }

    // Check if anything is empty
    for (uword i = 0; i < table.size(); i++) {
        if (table[i].empty()) {
            return matchings.zeros();
        }
    }

    // Create the matchings
    matchings.resize(N);
    for (uword n = 0; n < N; n++) {
        matchings[n] = table[n][0];
    }

    matchings = matchings + 1;
    return matchings;
}

//' Check if a matching solves the stable roommate problem
//'
//' This function checks if a given matching is stable for a particular set of
//' preferences. This function checks if there's an unmatched pair that would
//' rather be matched with each other than with their assigned partners.
//'
//' @param pref is a matrix with ordinal rankings of the participants
//' @param matchings is an nx1 matrix encoding who is matched to whom using
//' C++ style indexing
//' @return true if the matching is stable, false otherwise
// [[Rcpp::export]]
bool cpp_wrapper_irving_check_stability(umat& pref, umat& matchings) {

    // loop through everyone and check whether there's anyone else
    // who they'd rather be with
    for (uword i=0; i<pref.n_cols; i++) {
        for (uword j=i+1; j<pref.n_cols; j++) {

            // do i, j prefer to switch?
            bool i_prefers = false;
            bool j_prefers = false;

            // i?
            for (uword k=0; k<pref.n_rows; k++) {
                if (pref(k, i) == j) i_prefers = true;
                if (pref(k, i) == matchings(i)) break;
            }

            // j?
            for (uword k=0; k<pref.n_rows; k++) {
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
