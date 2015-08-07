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

# Startup message
.onAttach = function(libname, pkgname) {

    packageStartupMessage(paste("=================================\n",
                                "matchingR 1.1 Update Information:\n",
                                "=================================\n",
                                "With this update, we changed the layout of ",
                                "payoff and preference order matrices. In the ",
                                "matrix `u`, element [i,j] now refers to the ",
                                "utility that agent [j] receives from being ",
                                "matched to agent [i]. Similarly, in the matrix ",
                                "`pref`, element [i,j] refers to the id of the ",
                                "individual that agent `j` ranks at position ",
                                "`i`. I.e., we store payoffs and preference orders in",
                                "column-major order instead of row-major order.",
                                sep = ""))

}
