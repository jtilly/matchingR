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
    uword current_agent = -1;
    
    // loop until everyone's been matched
    while (true) {
        
        // if current_agent = -1, then set current_agent to be
        // the first unmmatched guy
        
        // now identify rotations
        while(true) {
            // start cycling through preferences, starting with current_agent
            
            // find current_agent's most preferred, unmatched outcome, p
            
            // set matchings[current_agent] = p
            
            // check if p has already shown up in this chain by checking if
            // matchings[p] is larger than -1. if it is larger than -1, then
            // that agent, who we know is unmmatched, must already have shown up
            // somewhere in this loop. if matchings[p] is equal to -1, then that agent
            // has never shown up in a loop and we can continue
            
            // if matchings is larger than -1, then we have a rotation, starting
            // with p, and ending with current_agent, so break
            
            // otherwise, continue looking for a rotation
        }
        
        // loop through, starting with p, then matchings[p], etc., and
        // ending with current_agent. for each agent, set is_matched to
        // 1. 
        
        // check if everyone's matched, if so, we're done, so break
        if (sum(unmatched) == N) break;
        
        // otherwise, we need to set current_agent in such a way so as to continue
        // looking for rotations
        
        // one way to do this would be to check if (1-is_matched) .* matchings = -1*sum(1-is_matched)
        // if true, then set current_agent equal to the first unmmatched agent
        // otherwise, we just cut off the 'tail' when we removed the rotation, and the body
        // can be used to find a new rotation
        // in this case, set current_agent to be the last agent in the head, i.e., the agent who we 
        // matched to p. 
    }
    
    return 0;
}
