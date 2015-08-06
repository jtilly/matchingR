# matchingR.R

#' @name matchingR-package
#' @docType package
#' @title matchingR: Efficient Computation of the Gale-Shapley Algorithm in R 
#'   and C++
#' @description matchingR is an R Package that quickly computes the Gale-Shapley
#'   Algorithm for large scale matching markets. This package can be useful when
#'   the number of market participants is large or when very many matchings need
#'   to be computed (e.g. for extensive simulations or for estimation purposes).
#'   The package has successfully been used to simulate preferences and compute 
#'   the matching with 30,000 participants on each side of the market. The
#'   algorithm computes the solution to the
#'   \href{http://en.wikipedia.org/wiki/Stable_matching}{stable marriage
#'   problem} and to the
#'   \href{http://en.wikipedia.org/wiki/Hospital_resident}{college admission
#'   problem}.
#' @author Jan Tilly
#' @references Gale, D. and Shapley, L.S. (1962). College admissions and the
#'   stability of marriage. \emph{The American Mathematical Monthly},
#'   69(1):9--15.
#' @examples
#' # stable marriage problem
#' nmen = 25
#' nwomen = 20
#' uM = matrix(runif(nmen*nwomen), nrow=nwomen, ncol=nmen)
#' uW = matrix(runif(nwomen*nmen), nrow=nmen, ncol=nwomen)
#' results = one2one(uM, uW)
#' checkStability(uM, uW, results$proposals, results$engagements)
#' 
#' # college admissions problem
#' nstudents = 25
#' ncolleges = 5
#' uStudents = matrix(runif(nstudents*ncolleges), nrow=ncolleges, ncol=nstudents)
#' uColleges = matrix(runif(nstudents*ncolleges), nrow=nstudents, ncol=ncolleges)
#' results = one2many(uStudents, uColleges, slots=4)
#' checkStability(uStudents, uColleges, results$proposals, results$engagements)
NULL

#' Compute one-to-one matching
#'
#' This function returns the proposer-optimal one-to-one matching. The function
#' needs some description of individuals preferences as inputs. That can be in
#' the form of cardinal utilities or preference orders (or both).
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing
#'   side of the market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side
#'   of the market
#' @param proposerPref is a matrix with the preference order of the proposing
#'   side of the market (only required when \code{proposerUtils} is not
#'   provided)
#' @param reviewerPref is a matrix with the preference order of the courted side
#'   of the market (only required when \code{reviewerUtils} is not provided)
#' @aliases  A list with the successful proposals and engagements:
#'   \code{proposals} is a vector whose nth element contains the id of the
#'   reviewer that proposer n is matched to. \code{engagements} is a vector
#'   whose nth element contains the id of the proposer that reviewer n is
#'   matched to. \code{single.proposers} is a vector that lists the ids of
#'   remaining single proposers. \code{single.reviewers} is a vector that lists
#'   the ids of remaining single reviewers.
#' @examples
#' nmen = 25
#' nwomen = 20
#' uM = matrix(runif(nmen*nwomen), nrow=nwomen, ncol=nmen)
#' uW = matrix(runif(nwomen*nmen), nrow=nmen, ncol=nwomen)
#' results = one2one(uM, uW)
#'
#' prefM = sortIndex(uM)
#' prefW = sortIndex(uW)
#' results = one2one(proposerPref = prefM, reviewerPref = prefW)
one2one = function(proposerUtils = NULL,
                   reviewerUtils = NULL,
                   proposerPref = NULL,
                   reviewerPref = NULL) {
    # validate the inputs
    args = validateInputs(proposerUtils, reviewerUtils, proposerPref, reviewerPref)
    
    # use galeShapleyMatching to compute matching
    res = galeShapleyMatching(args$proposerPref, args$reviewerUtils)
    
    M = length(res$proposals)
    N = length(res$engagements)
    
    # turn these into R indices by adding +1
    res = c(res, list(
      "single.proposers" = seq(from = 0, to = M - 1)[res$proposals == N] + 1,
      "single.reviewers" = seq(from = 0, to = N - 1)[res$engagements == M] + 1
    ))
    
    res$proposals = matrix(res$proposals, ncol = 1) + 1
    res$engagements = matrix(res$engagements, ncol = 1) + 1
    
    return(res)
}


#' Compute the one-to-many matching
#'
#' This function returns the one-to-many matching. The function needs some
#' description of individuals preferences as inputs. That can be in the form of
#' cardinal utilities or preference orders (or both). It is computationally most
#' efficient to provide cardinal utilities for the proposers
#' \code{proposerUtils} and cardinal utilities for the reviewers
#' \code{reviewerUtils}.
#'
#' @param proposerUtils is a matrix with cardinal utilities of the proposing
#'   side of the market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side
#'   of the market
#' @param proposerPref is a matrix with the preference order of the proposing
#'   side of the market (only required when \code{proposerUtils} is not
#'   provided)
#' @param reviewerPref is a matrix with the preference order of the courted side
#'   of the market (only required when \code{reviewerUtils} is not provided)
#' @param slots is the number of slots per reviewer
#' @return A list with the successful proposals and engagements:
#'   \code{proposals} is a vector whose nth element contains the id of the
#'   reviewer that proposer n is matched to. \code{engagements} is a vector
#'   whose nth element contains the id of the proposer that reviewer n is
#'   matched to. \code{single.proposers} is a vector that lists the ids of
#'   remaining single proposers \code{single.reviewers} is a vector that lists
#'   the ids of remaining single reviewers (if a reviewer has two vacancies left
#'   it will be listed twice)
#' @examples
#' nfirms = 10
#' nworkers = 25
#' uFirms = matrix(runif(nfirms*nworkers), nrow=nworkers, ncol=nfirms)
#' uWorkers = matrix(runif(nfirms*nworkers), nrow=nfirms, ncol=nworkers)
#' results = one2many(uWorkers, uFirms, slots=2)
one2many = function(proposerUtils = NULL,
                    reviewerUtils = NULL,
                    proposerPref = NULL,
                    reviewerPref = NULL,
                    slots = 1) {
    # validate the inputs
    args = validateInputs(proposerUtils, reviewerUtils, proposerPref, reviewerPref)
    
    # number of firms
    number_of_firms = NROW(args$reviewerUtils)
    
    # expand cardinal utilities corresponding to the slot size
    proposerUtils = reprow(args$proposerUtils, slots)
    reviewerUtils = repcol(args$reviewerUtils, slots)
    
    # create preference ordering
    proposerPref = sortIndex(as.matrix(proposerUtils));
    
    # use galeShapleyMatching to compute matching
    res = galeShapleyMatching(proposerPref, reviewerUtils)
    
    # number of workers
    M = length(res$proposals)
    
    # number of positions
    N = length(res$engagements)
    
    # collect results
    res = c(res, list(
      "single.proposers" = seq(from = 0, to = M - 1)[res$proposals == N] + 1,
      "single.reviewers" = seq(from = 0, to = N - 1)[res$engagements == M] + 1
    ))
    
    # collapse engagements (turn these into R indices by adding +1)
    res$engagements = matrix(res$engagements, ncol = slots, byrow = TRUE) + 1
    
    # translate proposals into the id of the original firm (turn these into R indices by adding +1)
    firm.ids = reprow(matrix(seq(from = 0, to = number_of_firms), ncol = 1), slots)
    res$proposals = matrix(firm.ids[res$proposals + 1], ncol = 1) + 1
    
    # translate single reviewers into the id of the original firm (turn these into R indices by adding +1)
    res$single.reviewers = firm.ids[res$single.reviewers] + 1
    
    return(res)
}

#' Compute the many-to-one matching
#' 
#' This function returns the many-to-many matching. The function needs some 
#' description of individuals preferences as inputs. That can be in the form of 
#' cardinal utilities or preference orders (or both). It is computationally most
#' efficient to provide cardinal utilities for the proposers
#' \code{proposerUtils} and cardinal utilities for the reviewers
#' \code{reviewerUtils}.
#' 
#' @param proposerUtils is a matrix with cardinal utilities of the proposing 
#'   side of the market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side 
#'   of the market
#' @param proposerPref is a matrix with the preference order of the proposing 
#'   side of the market (only required when \code{proposerUtils} is not
#'   provided)
#' @param reviewerPref is a matrix with the preference order of the courted side
#'   of the market (only required when \code{reviewerUtils} is not provided)
#' @param slots is the number of slots per proposer
#' @return A list with the successful proposals and engagements: 
#'   \code{proposals} is a vector whose nth element contains the id of the
#'   reviewer that proposer n is matched to. \code{engagements} is a vector
#'   whose nth element contains the id of the proposer that reviewer n is
#'   matched to. \code{single.proposers} is a vector that lists the ids of
#'   remaining single proposers (if a proposer has two vacancies left it will be
#'   listed twice) \code{single.reviewers} is a vector that lists the ids of
#'   remaining single reviewers
#' @examples
#' nfirms = 10
#' nworkers = 25
#' uFirms = matrix(runif(nfirms*nworkers), nrow=nworkers, ncol=nfirms)
#' uWorkers = matrix(runif(nfirms*nworkers), nrow=nfirms, ncol=nworkers)
#' results = many2one(uFirms, uWorkers, slots=2)
many2one = function(proposerUtils = NULL,
                    reviewerUtils = NULL,
                    proposerPref = NULL,
                    reviewerPref = NULL,
                    slots = 1) {
    # validate the inputs
    args = validateInputs(proposerUtils, reviewerUtils, proposerPref, reviewerPref)
    
    # number of firms
    number_of_firms = NROW(args$proposerUtils)
    
    # expand cardinal utilities corresponding to the slot size
    proposerUtils = repcol(args$proposerUtils, slots)
    reviewerUtils = reprow(args$reviewerUtils, slots)
    
    # create preference ordering
    proposerPref = sortIndex(as.matrix(proposerUtils));
    
    # use galeShapleyMatching to compute matching
    res = galeShapleyMatching(as.matrix(proposerPref), as.matrix(reviewerUtils))
    
    # number of firms
    M = length(res$proposals)
    
    # number of workers
    N = length(res$engagements)
    
    # collect results
    res = c(res, list(
      "single.proposers" = seq(from = 0, to = M - 1)[res$proposals == N],
      "single.reviewers" = seq(from = 0, to = N - 1)[res$engagements == M]
    ))
    
    # collapse proposals (turn these into R indices by adding +1)
    res$proposals = matrix(res$proposals, ncol = slots, byrow = TRUE) + 1
    
    # translate engagements into the id of the original firm (turn these into R indices by adding +1)
    firm.ids = reprow(matrix(seq(from = 0, to = number_of_firms), ncol = 1), slots)
    res$engagements = matrix(firm.ids[res$engagements + 1], ncol = 1) + 1
    
    # translate single proposers into the id of the original firm (turn these into R indices by adding +1)
    res$single.proposers = firm.ids[res$single.proposers + 1] + 1
    
    return(res)
}

#' Compute matching for one-sided markets
#'
#' This function returns a stable roommate matching for a one-sided market
#' using Irving (1985)'s algorithm. Stable matchings are neither guaranteed 
#' to exist, nor to be unique. If no stable matching exists, 0 is returned.
#'
#' @param pref An n-1xn matrix, with each column representing the cardinal 
#' utilities of each agent over matches with the other agents, so that, e.g.,
#' if element (4, 6) of this matrix is 2, then agent 4 ranks agent 2 6th. The
#' matrix accepts either 0-based indexing (C++ style) or 1-based indexing (R 
#' style).
#' @param prefUtil An n-1xn matrix, each column representing ordinal preferences
#' of each agent over agents 1, 2, ..., i-1, i+1, i+2, ... n. For example, if 
#' element (4, 6) of this matrix is 2, then agent 4 gets utility 2 from agent
#' 6. 
#' @return A list of length n corresponding to the matchings being made, so that
#' e.g. if the 4th element is 6 then agent 4 was matched with agent 6.
#' @examples
#' results = onesided(prefUtil = replicate(4, rnorm(3)))
onesided = function(pref = NULL, prefUtil = NULL) {
    args = validateInputsOneSided(pref = pref, prefUtil = prefUtil);
    res = stableRoommateMatching(args);
    return(res$matchings);
}

#' Input validation
#' 
#' This function parses and validates the arguments that are passed on to the 
#' functions one2one, one2many, and many2one. In particular, it checks if 
#' user-defined preference orders are complete. If user-defined orderings are
#' given in terms of R indices (starting at 1), then these are transformed into
#' C++ indices (starting at zero).
#' 
#' @param proposerUtils is a matrix with cardinal utilities of the proposing 
#'   side of the market
#' @param reviewerUtils is a matrix with cardinal utilities of the courted side 
#'   of the market
#' @param proposerPref is a matrix with the preference order of the proposing 
#'   side of the market (only required when \code{proposerUtils} is not
#'   provided)
#' @param reviewerPref is a matrix with the preference order of the courted side
#'   of the market (only required when \code{reviewerUtils} is not provided)
#' @return a list containing proposerUtils, reviewerUtils, proposerPref 
#'   (reviewerPref are not required after they are translated into
#'   reviewerUtils).
validateInputs = function(proposerUtils, reviewerUtils, proposerPref, reviewerPref) {
    if (!is.null(reviewerPref)) {
        reviewerPref = checkPreferenceOrder(reviewerPref)
        if (is.null(reviewerPref)) {
            stop(
                "reviewerPref was defined by the user but is not a complete list of preference orderings"
            )
        }
    }
    
    if (!is.null(proposerPref)) {
        proposerPref = checkPreferenceOrder(proposerPref)
        if (is.null(proposerPref)) {
            stop(
                "proposerPref was defined by the user but is not a complete list of preference orderings"
            )
        }
    }
    
    # parse inputs
    if (is.null(proposerPref) && !is.null(proposerUtils)) {
        proposerPref = sortIndex(as.matrix(proposerUtils))
    }
    
    if (is.null(proposerUtils) && !is.null(proposerPref)) {
        proposerUtils = -rankIndex(as.matrix(proposerPref))
    }
    
    if (is.null(reviewerUtils) && !is.null(reviewerPref)) {
        reviewerUtils = -rankIndex(as.matrix(reviewerPref))
    }
    
    if (is.null(proposerPref)) {
        stop("missing proposer preferences")
    }
    
    if (is.null(reviewerUtils)) {
        stop("missing reviewer utilities")
    }
    
    # check inputs
    if (NROW(proposerPref) != NCOL(reviewerUtils)) {
        stop("preference orderings must be symmetric")
    }
    if (NCOL(proposerPref) != NROW(reviewerUtils)) {
        stop("preference orderings must be symmetric")
    }
    
    return(
        list(
            proposerPref = as.matrix(proposerPref),
            proposerUtils = as.matrix(proposerUtils),
            reviewerUtils = as.matrix(reviewerUtils)
        )
    )
}

#' Input validation for one-sided markets
#' 
#' This function parses and validates the arguments for one sided preferences
#' for the function onesided. If it uses R-style indexing (i.e., beginning at
#' 1), then it re-numbers the preference matrix to use C++ style indexing. 
#' 
#' @param pref is an n-1xn matrix, with each row representing an ordinal ranking.
#' @param prefUtil if an n-1xn matrix, with each row representing the cardinal preferences 
#' of the agents.
#' @return The validated inputs, ready to be sent to C++ code. 
validateInputsOneSided = function(pref = NULL, prefUtil = NULL) {
    
    # Convert cardinal utility to ordinal, if necessary
    if (is.null(pref) && !is.null(prefUtil)) {
        pref = sortIndexOneSided(as.matrix(prefUtil))
    }
    
    # check inputs
    if (NROW(prefUtil)+1 != NCOL(prefUtil)) {
        stop("preference matrix must be n-1xn")
    }
    
    if (NROW(pref)+1 != NCOL(pref)) {
        stop("preference matrix must be n-1xn")
    }
    
    pref = checkPreferenceOrderOnesided(pref)
    if (is.null(pref)) {
        stop(
            "preferences are not a complete list of preference orderings"
        )
    }
    
    return(pref)
}

