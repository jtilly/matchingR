#  matchingR -- Matching Algorithms in R and C++
#
#  Copyright (C) 2015  Jan Tilly <jtilly@econ.upenn.edu>
#                      Nick Janetos <njanetos@econ.upenn.edu>
#
#  This file is part of matchingR.
#
#  matchingR is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  matchingR is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#' @name matchingR-package
#' @docType package
#' @title matchingR: Matching Algorithms in R and C++
#' @description matchingR is an R package which quickly computes a variety of
#'   matching algorithms for one-sided and two-sided markets. This package
#'   implements
#'   \itemize{
#'   \item{the Gale-Shapley Algorithm to compute the stable matching for
#'   two-sided markets, such as the stable marriage problem and the
#'   college-admissions problem}
#'   \item{Irving's Algorithm to compute the stable matching for one-sided
#'   markets such as the stable roommates problem}
#'   \item{the top trading cycle algorithm for the indivisible goods trading
#'   problem.}
#'   }
#'
#'   All matching algorithms are implemented in \code{C++} and can therefore be
#'   computed quickly. The package may be useful when the number of market
#'   participants is large or when many matchings need to be computed (e.g. for
#'   extensive simulations or for estimation purposes). The Gale-Shapley
#'   function of this package has successfully been used to simulate preferences
#'   and compute the matching with 30,000 participants on each side of the
#'   market.
#'
#'   Matching markets are common in practice and widely studied by
#'   economists. Popular examples include
#'   \itemize{
#'   \item{the National Resident Matching Program that matches graduates from
#'   medical school to residency programs at teaching hospitals throughout the
#'   United States}
#'   \item{the matching of students to schools including the New York City High
#'   School Match or the the Boston Public School Match (and many more)}
#'   \item{the matching of kidney donors to recipients in kidney exchanges.}
#'   }
#' @author Jan Tilly, Nick Janetos
#' @references Gale, D. and Shapley, L.S. (1962). College admissions and the
#'   stability of marriage. \emph{The American Mathematical Monthly}, 69(1):
#'   9--15.
#' @references Irving, R. W. (1985). An efficient algorithm for the "stable
#'   roommates" problem. \emph{Journal of Algorithms}, 6(4): 577--595
#' @references Shapley, L., & Scarf, H. (1974). On cores and indivisibility.
#'   \emph{Journal of Mathematical Economics}, 1(1), 23-37.
#' @examples
#' # stable marriage problem
#' set.seed(1)
#' nmen = 25
#' nwomen = 20
#' uM = matrix(runif(nmen*nwomen), nrow=nwomen, ncol=nmen)
#' uW = matrix(runif(nwomen*nmen), nrow=nmen, ncol=nwomen)
#' results = galeShapley.marriageMarket(uM, uW)
#' galeShapley.checkStability(uM, uW, results$proposals, results$engagements)
#'
#' # college admissions problem
#' nstudents = 25
#' ncolleges = 5
#' uStudents = matrix(runif(nstudents*ncolleges), nrow=ncolleges, ncol=nstudents)
#' uColleges = matrix(runif(nstudents*ncolleges), nrow=nstudents, ncol=ncolleges)
#' results = galeShapley.collegeAdmissions(studentUtils = uStudents,
#'                                         collegeUtils = uColleges,
#'                                         slots = 4)
#' results
#' # check stability
#' galeShapley.checkStability(uStudents,
#'                            uColleges,
#'                            results$matched.students,
#'                            results$matched.colleges)
#'
#' # stable roommate problem
#' set.seed(2)
#' N = 10
#' u = matrix(runif(N^2),  nrow = N, ncol = N)
#' results = roommate(utils = u)
#' results
#' # check stability
#' roommate.checkStability(utils = u, matching = results)
#'
#' # top trading cycle algorithm
#' N = 10
#' u = matrix(runif(N^2),  nrow = N, ncol = N)
#' results = toptrading(utils = u)
#' results
#' # check stability
#' toptrading.checkStability(utils = u, matching = results)
NULL
