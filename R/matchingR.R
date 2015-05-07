# matchingR.R

#' Compute the one-to-one matching
#'
#' This function returns the one-to-one matching. The function needs some 
#' description of individuals preferences as inputs. That can be in the form of 
#' cardinal utilities or preference orders (or both). It is computational most 
#' efficient to provide preference orders for the proposers \code{proposerPref} 
#' and cardinal utilities for the reviewers \code{reviewerPref}.
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing 
#' side of the market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side 
#' of the market
#' @param proposerPref is a matrix with the preference order of the proposing 
#' side of the market (only required when \code{uM} is not provided)
#' @param reviewerPref is a matrix with the preference order of the courted side
#' of the market (only required when \code{prefW} is not provided)
#' @return A list with the successful proposals and engagements: 
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
        proposerPref = sortIndex(as.matrix(proposerUtils))
    } 
    if(is.null(reviewerUtils) && !is.null(reviewerPref)) {
        reviewerUtils = -rankIndex(as.matrix(reviewerPref))
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
    res = galeShapleyMatching(as.matrix(proposerPref), as.matrix(reviewerUtils))
    
    M = length(res$proposals)
    N = length(res$engagements)
    
    res = c(res, list("single.proposers" = seq(from=0, to=M-1)[res$proposals==N],
                      "single.reviewers" = seq(from=0, to=N-1)[res$engagements==M]))
    
    res$proposals = matrix(res$proposals, ncol=1)
    res$engagements = matrix(res$engagements, ncol=1)
    
    return(res)
}


#' Compute the one-to-many matching
#'
#' This function returns the one-to-many matching. Workers are making proposals.
#' The function needs some description of individuals preferences as inputs. 
#' That can be in the form of cardinal utilities or preference orders (or both). 
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing 
#' side of the market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side 
#' of the market
#' @param proposerPref is a matrix with the preference order of the proposing 
#' side of the market (only required when \code{uM} is not provided)
#' @param reviewerPref is a matrix with the preference order of the courted 
#' side of the market (only required when \code{prefW} is not provided)
#' @param slots is an integer with the number slots per firm
#' @return A list with the successful proposals and engagements:
#' \code{proposals} is a vector whose nth element contains the id of the firm 
#' that worker n is matched to. 
#' \code{engagements} is a matrix whose nth row contains the ids of the workers 
#' that firm n is matched to.  
#' \code{single.proposers} is a vector that lists the ids of remaining unmatched
#' workers
#' \code{single.reviewers} is a vector that lists the ids of remaining vacant
#' firms (if a firm is two vacancies it will be listed twice)
one2many = function(proposerUtils = NULL, 
                    reviewerUtils = NULL, 
                    proposerPref = NULL, 
                    reviewerPref = NULL,
                    slots = 1) {
    
    # parse inputs
    if(is.null(proposerUtils) && !is.null(proposerPref)) {
        proposerUtils = -rankIndex(as.matrix(proposerPref))
    } 
    if(is.null(reviewerUtils) && !is.null(reviewerPref)) {
        reviewerUtils = -rankIndex(as.matrix(reviewerPref))
    }
    if(is.null(proposerUtils)) {
        stop("missing proposer utilities")   
    }
    if(is.null(reviewerUtils)) {
        stop("missing reviewer utilities")   
    }
    
    # check inputs
    if(NROW(proposerUtils)!=NCOL(reviewerUtils)) {
        stop("preference orderings must be symmetric")
    }
    if(NCOL(proposerUtils)!=NROW(reviewerUtils)) {
        stop("preference orderings must be symmetric")
    }
    
    # number of firms
    number_of_firms = NROW(reviewerUtils)
    
    # expand cardinal utilities corresponding to the slot size
    proposerUtils = repcol(proposerUtils, slots)
    reviewerUtils = reprow(reviewerUtils, slots)
    
    # create preference ordering
    proposerPref = sortIndex(as.matrix(proposerUtils));
    
    # use galeShapleyMatching to compute matching
    res = galeShapleyMatching(as.matrix(proposerPref), as.matrix(reviewerUtils))
    
    # number of workers
    M = length(res$proposals)
    
    # number of positions
    N = length(res$engagements)
    
    # collect results
    res = c(res, list("single.proposers" = seq(from=0, to=M-1)[res$proposals==N],
                      "single.reviewers" = seq(from=0, to=N-1)[res$engagements==M]))
    
    # collapse engagements
    res$engagements = matrix(res$engagements, ncol=slots, byrow = TRUE)
    
    # translate proposals into the id of the original firm
    firm.ids = reprow(matrix(seq(from=0, to=number_of_firms), ncol=1), slots)
    res$proposals = matrix(firm.ids[res$proposals+1], ncol=1)
    
    # translate single reviewers into the id of the original firm
    res$single.reviewers = firm.ids[res$single.reviewers+1]
    
    return(res)
}

#' Compute the many-to-one matching
#'
#' This function returns the many-to-many matching. Multi-worker firms make 
#' proposals to workers. The function needs some description of individuals 
#' preferences as inputs. That can be in the form of cardinal utilities or 
#' preference orders (or both). 
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing 
#' side of the market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side 
#' of the market
#' @param proposerPref is a matrix with the preference order of the proposing 
#' side of the market (only required when \code{uM} is not provided)
#' @param reviewerPref is a matrix with the preference order of the courted side
#' of the market (only required when \code{prefW} is not provided)
#' @param slots is an integer with the number slots per firm
#' @return A list with the successful proposals and engagements: 
#' \code{proposals} is a vector whose nth element contains the id of the firm 
#' that worker n is matched to. 
#' \code{engagements} is a matrix whose nth row contains the ids of the workers 
#' that firm n is matched to.  
#' \code{single.proposers} is a vector that lists the ids of remaining unmatched
#' workers
#' \code{single.reviewers} is a vector that lists the ids of remaining vacant
#' firms (if a firm is two vacancies it will be listed twice)
many2one = function(proposerUtils = NULL, 
                    reviewerUtils = NULL, 
                    proposerPref = NULL, 
                    reviewerPref = NULL,
                    slots = 1) {
    
    # parse inputs
    if(is.null(proposerUtils) && !is.null(proposerPref)) {
        proposerUtils = -rankIndex(proposerPref)
    } 
    if(is.null(reviewerUtils) && !is.null(reviewerPref)) {
        reviewerUtils = -rankIndex(as.matrix(reviewerPref))
    }
    if(is.null(proposerUtils)) {
        stop("missing proposer utilities")   
    }
    if(is.null(reviewerUtils)) {
        stop("missing reviwer utilities")   
    }
    
    # check inputs
    if(NROW(proposerUtils)!=NCOL(reviewerUtils)) {
        stop("preference orderings must be symmetric")
    }
    if(NCOL(proposerUtils)!=NROW(reviewerUtils)) {
        stop("preference orderings must be symmetric")
    }
    
    # number of firms
    number_of_firms = NROW(proposerUtils)
    
    # expand cardinal utilities corresponding to the slot size
    proposerUtils = reprow(proposerUtils, slots)
    reviewerUtils = repcol(reviewerUtils, slots)
    
    # create preference ordering
    proposerPref = sortIndex(as.matrix(proposerUtils));
    
    # use galeShapleyMatching to compute matching
    res = galeShapleyMatching(as.matrix(proposerPref), as.matrix(reviewerUtils))
    
    # number of firms
    M = length(res$proposals)
    
    # number of workers
    N = length(res$engagements)
    
    # collect results
    res = c(res, list("single.proposers" = seq(from=0, to=M-1)[res$proposals==N],
                      "single.reviewers" = seq(from=0, to=N-1)[res$engagements==M]))
    
    # collapse proposals
    res$proposals = matrix(res$proposals, ncol=slots, byrow = TRUE)
    
    # translate engagements into the id of the original firm
    firm.ids = reprow(matrix(seq(from=0, to=number_of_firms), ncol=1), slots)
    res$engagements = matrix(firm.ids[res$engagements+1], ncol=1)
    
    # translate single proposers into the id of the original firm
    res$single.proposers = firm.ids[res$single.proposers+1]
    
    return(res)
}
