# utils.R

#' Repeat each column of a matrix n times
#'
#' This function repeats each column of a matrix n times
#' 
#' @param x is the input matrix
#' @param n is the number of repetitions
#' @return matrix with repeated columns
repcol<-function(x,n){
    s = NCOL(x)
    matrix(x[,rep(1:s, each=n)], nrow=NROW(x), ncol=NCOL(x)*n)
}

#' Repeat each row of a matrix n times
#'
#' This function repeats each row of a matrix n times
#' 
#' @param x is the input matrix
#' @param n is the number of repetitions
#' @return matrix with repeated rows
reprow<-function(x,n){
    s = NROW(x)
    matrix(x[rep(1:s, each=n),], nrow=NROW(x)*n, ncol=NCOL(x))
}

#' Check if preference order is complete
#'
#' This function checks if a given preference ordering is complete. If needed
#' it transforms the indices from R indices (starting at 1) to C++ indices
#' (starting at zero).
#' 
#' @param pref is a matrix with a preference ordering
#' @return a matrix with preference orderings with proper C++ indices or NULL 
#' if the preference order is not complete.
checkPreferenceOrder = function(pref) {
    
    # check if pref is using R instead of C++ indexing
    if(all(apply(pref,2,sort) == array(1:(NROW(pref)), dim = dim(pref)))) {
        return(pref-1)
    }
    
    # check if pref has a complete listing otherwise given an error
    if(all(apply(pref,2,sort) == (array(1:(NROW(pref)), dim = dim(pref)))-1)) {
        return(pref)
    }  
    
    return(NULL)
}