#include "toptradingcycle.h"

// [[Rcpp::depends(RcppArmadillo)]]

//' Computes the top trading cycle algorithm
//'
//' This function uses the top trading cycle algorithm to find a stable trade between participants,
//' each with some indivisible good, and with preferences over the goods of other participants.
//'
//' @param pref A matrix with agent's cardinal preferences. Column i is agent i's preferences.
//' @return A list with the matchings made. The matchings are encoded as follows: The first value
//' in the list is the individual to whom agent 1 will be giving his good, the second value in the list
//' is the individual to whom agent 2 will be giving his good, etc. 
// [[Rcpp::export]]
List topTradingCycle(const umat pref) {
    
    // the number of participants
    uword N = pref.n_cols;
    
    // a vector of zeros and ones, encodes whether a
    // participant has been matched or not
    // everyone begins unmmatched.
    uvec is_matched(N);
    is_matched.zeros();
    
    // the vector of matchings to be returned
    uvec matchings(N);
    matchings.fill(-1);
    
    // used for the algorithm below
    uword current_agent;
    
    // loop until everyone's been matched
    while (true) {
        
        // identify rotations, maximum length of N
        while(true) {
            // start cycling through preferences, starting with the first unmatched guy
            
            // find the agent's most preferred, unmatched outcome
            
            // check if that guy has already shown up in this chain by checking if
            // matchings is larger than -1
            
            // if matchings is larger than -1, then we have a rotation, starting
            // with the value of matchings, and ending with this agent
        }
        
        // loop through, and set is_matched to 1 for everyone in
        // the rotation
        
        // check if everyone's matched
        if (sum(unmatched) == N) break;
        
        // otherwise, set current_agent back and start again
    }
    
    return 0;
}
