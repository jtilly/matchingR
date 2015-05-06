# matchingR.R

#' Compute the one-to-one matching
#'
#' This function returns the one-to-one matching. The function needs some 
#' description of individuals preferences as inputs. That can be in the form of 
#' cardinal utilities or preference orders (or both). It is computational most 
#' efficient to provide preference orders for the proposers \code{proposerPref} 
#' and cardinal utilities for the reviewers \code{reviewerPref}.
#'
#' @param uM is a matrix with cardinal utilities of the proposing side of the 
#' market
#' @param uW is a matrix with cardinal utilities of the courted side of the 
#' market
#' @param prefM is a matrix with the preference order of the proposing side of 
#' the market (only required when \code{uM} is not provided)
#' @param prefW is a matrix with the preference order of the courted side of 
#' the market (only required when \code{prefW} is not provided)
#' @return A list with the successful proposals and engagements. 
#' \code{proposals} is a vector whose nth element contains the id of the female 
#' that male n is matched to. 
#' \code{engagements} is a vector whose nth element contains the id of the male 
#' that female n is matched to.  
#' \code{single.proposers} is a vector that lists the ids of remaining single 
#' proposers
#' \code{single.reviewers} is a vector that lists the ids of remaining single
#' reviewers
one2one = function(proposerUtils = NULL, 
                   reviewerUtils = NULL, 
                   proposerPref = NULL, 
                   reviewerPref = NULL) {
        
    # parse inputs
    if(is.null(proposerPref) && !is.null(proposerUtils)) {
        proposerPref = sortIndex(proposerUtils)
    } 
    if(is.null(reviewerUtils) && !is.null(reviewerPref)) {
        reviewerUtils = rankIndex(reviewerPref)
    }
    if(is.null(proposerPref)) {
        stop("missing proposer preferences")   
    }
    if(is.null(reviewerUtils)) {
        stop("missing reviwer utilities")   
    }
    
    # check inputs
    if(NROW(proposerPref)!=NCOL(reviewerUtils)) {
        stop("preference orderings must be symmetric")
    }
    if(NCOL(proposerPref)!=NROW(reviewerUtils)) {
        stop("preference orderings must be symmetric")
    }
    
    # use galeShapleyMatching to compute matching
    res = galeShapleyMatching(proposerPref, reviewerUtils)
    
    M = length(res$proposals)
    N = length(res$engagements)
    
    res = c(res, list("single.proposers" = (1:M)[res$proposals==N],
                      "single.reviewers" = (1:N)[res$engagements==M]))
}