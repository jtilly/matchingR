#include "roommate.h"

// [[Rcpp::depends(RcppArmadillo)]]

//' Computes a stable roommate matching
//'
//' This is the C++ wrapper for the stable roommate problem. Users should not
//' call this function directly, but instead use
//' \code{\link{roommate.matching}}.
//' 
//' The algorithm works in two stages. In the first stage, all participants begin
//' unmmatched, then, in sequence, begin making proposals to other potential roommates,
//' beginning with their most preferred roommate. If a roommate receives a proposal,
//' he either accepts it if he has no other proposal which is better, or rejects it
//' otherwise. If this stage ends with a roommate who has no proposals, then there
//' is no stable matching and the algorithm terminates.
//' 
//' In the second stage, the algorithm proceeds by finding and eliminating 
//' rotations. Roughly speaking, a rotation is a sequence of pairs of agents,
//' such that the first agent in each pair is least preferred by the second
//' agent in that pair (of all the agents remaining to be matched), the second
//' agent in each pair is most preferred by the first agent in each pair (of
//' all the agents remaining to be matched) and the second agent in the 
//' successive pair is the second most preferred agent (of the agents 
//' remaining to be matched) of the first agent in the succeeding 
//' pair, where here 'successive' is taken to mean 'modulo \code{m}',
//' where \code{m} is the length of the rotation. Once a rotation has been
//' identified, it can be eliminated in the following way: For each pair, the
//' second agent in the pair rejects the first agent in the pair (recall that the
//' second agent hates the first agent, while the first agent loves the second
//' agent), and the first agent then proceeds to propose to the second agent
//' in the succeeding pair. If at any point during this process, an agent
//' no longer has any agents left to propose to or be proposed to from, then
//' there is no stable matching and the algorithm terminates.
//' 
//' Otherwise, at the end, every agent is left proposing to an agent who is also
//' proposing back to them, which results in a stable matching. 
//'
//' @param pref is a matrix with the preference order of each individual in the
//'   market. If there are \code{n} individuals, then this matrix will be of
//'   dimension \code{n-1} by \code{n}. The \code{i,j}th element refers to
//'   \code{j}'s \code{i}th most favorite partner. Preference orders must be
//'   specified using C++ indexing (starting at 0). The matrix \code{pref} must
//'   be of dimension \code{n-1} by \code{n}.
//' @return A vector of length \code{n} corresponding to the matchings that were
//'   formed (using C++ indexing). E.g. if the \code{4}th element of this vector
//'   is \code{0} then individual \code{4} was matched with individual \code{1}.
//'   If no stable matching exists, then this function returns a vector of
//'   zeros.
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

                if (op == N) { stop("Invalid preference matrix: Incomplete preferences."); }

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
                        // x[i] needs to be removed from  table[table[x[i]].back()], and
                        // table[table[x[i]].back()][x[i]] needs to be removed from
                        // table[x[i]].
                        uword tab_size = table[table[x[i]].back()].size();

                        // Remove x[i] from table[table[x[i]].back()]
                        // If x[i] is not in table[table[x[i]].back()], then it should remove
                        // nothing.
                        // This uses an 'erase-remove' idiom from the std library.
                        table[table[x[i]].back()].erase(std::remove(table[table[x[i]].back()].begin(),
                                                        table[table[x[i]].back()].end(),
                                                        x[i]),
                                                        table[table[x[i]].back()].end());

                        // Check to see if it removed x[i] or not (whether the table's the same size)
                        if (tab_size == table[table[x[i]].back()].size()) { return matchings.zeros(); }

                        // Check to see if there's only one element remaining (if so, no stable matching.)
                        if (table[x[i]].size() == 1) { return matchings.zeros(); }

                        // Remove table[table[x[i]].back()][x[i]] from table[x[i]] (it should be at the end).
                        table[x[i]].pop_back();
                    }
                }
            }
        }
    }

    // Check if anything is empty
    for (uword i = 0; i < table.size(); i++) {
        if (table[i].empty()) { return matchings.zeros(); }
    }

    // Create the matchings
    matchings.resize(N);
    for (uword n = 0; n < N; n++) {
        matchings[n] = table[n][0];
    }

    return matchings;
}

//' Check if a matching solves the stable roommate problem
//'
//' This function checks if a given matching is stable for a particular set of
//' preferences. This function checks if there's an unmatched pair that would
//' rather be matched with each other than with their assigned partners.
//'
//' @param pref is a matrix with the preference order of each individual in the
//'   market. If there are \code{n} individuals, then this matrix will be of
//'   dimension \code{n-1} by \code{n}. The \code{i,j}th element refers to
//'   \code{j}'s \code{i}th most favorite partner. Preference orders must be
//'   specified using C++ indexing (starting at 0). The matrix \code{pref} must
//'   be of dimension \code{n-1} by \code{n}.
//' @param matchings is a vector of length \code{n} corresponding to the
//'   matchings that were formed (using C++ indexing). E.g. if the \code{4}th
//'   element of this vector is \code{0} then individual \code{4} was matched
//'   with individual \code{1}. If no stable matching exists, then this function
//'   returns a vector of zeros.
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
            if (i_prefers && j_prefers) { return false; }
        }
    }

    return true;

}
