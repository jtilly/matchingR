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

#' Deprecated Functions in matchingR
#'
#' These functions are provided for compatibility with older version of
#' the matchingR package. Eventually, these functions will be removed.
#'
#' @rdname matchingR-deprecated
#' @name matchingR-deprecated
#' @param ... generic set of parameters --- see documentation of new functions
#' @docType package
#' @aliases validateInputs checkStability checkPreferenceOrder one2many many2one
#'   one2one galeShapleyMatching stableRoommateMatching onesided
#'   checkStabilityRoommate validateInputsOneSided checkPreferenceOrderOnesided
#'   topTradingCycle checkStabilityTopTradingCycle
#' @section Details:
#' \tabular{rl}{
#'   \code{validateInputs} \tab was replaced by \code{\link{galeShapley.validate}}\cr
#'   \code{checkStability} \tab was replaced by \code{\link{galeShapley.checkStability}}\cr
#'   \code{checkPreferenceOrder} \tab was replaced by \code{\link{galeShapley.checkPreferences}}\cr
#'   \code{one2many} \tab now mapped into \code{\link{galeShapley.collegeAdmissions}}\cr
#'   \code{many2one} \tab now mapped into \code{\link{galeShapley.collegeAdmissions}}\cr
#'   \code{one2one} \tab was replaced by \code{\link{galeShapley.marriageMarket}}\cr
#'   \code{galeShapleyMatching} \tab was replaced by \code{\link{cpp_wrapper_galeshapley}}\cr
#'   \code{stableRoommateMatching} \tab was replaced by \code{\link{cpp_wrapper_irving}}\cr
#'   \code{onesided} \tab was replaced by \code{\link{roommate}}\cr
#'   \code{checkStabilityRoommate} \tab was replaced by \code{\link{cpp_wrapper_irving_check_stability}}\cr
#'   \code{validateInputsOneSided} \tab was replaced by \code{\link{roommate.validate}}\cr
#'   \code{checkPreferenceOrderOnesided} \tab was replaced by \code{\link{roommate.checkPreferences}}\cr
#'   \code{topTradingCycle} \tab was replaced by \code{\link{cpp_wrapper_ttc}}\cr
#'   \code{checkStabilityTopTradingCycle} \tab was replaced by \code{\link{cpp_wrapper_ttc_check_stability}}\cr
#' }
#'
validateInputs = function(...) {
    .Deprecated("galeShapley.validate")
    galeShapley.validate(...)
}
checkStability = function(...) {
    .Deprecated("galeShapley.checkStability")
    galeShapley.checkStability(...)
}
checkPreferenceOrder = function(...) {
    .Deprecated("galeShapley.checkPreferences")
    galeShapley.checkPreferences(...)
}
one2many = function(...) {
    .Deprecated("galeShapley.collegeAdmissions")
    galeShapley.collegeAdmissions(..., studentOptimal = TRUE)
}
many2one = function(...) {
    .Deprecated("galeShapley.collegeAdmissions")
    galeShapley.collegeAdmissions(..., studentOptimal = FALSE)
}
one2one = function(...) {
    .Deprecated("galeShapley.marriageMarket")
    galeShapley.marriageMarket(...)
}
galeShapleyMatching = function(...) {
    .Deprecated("cpp_wrapper_galeshapley")
    cpp_wrapper_galeshapley(...)
}
stableRoommateMatching = function(...) {
    .Deprecated("cpp_wrapper_irving")
    cpp_wrapper_irving(...)
}
onesided = function(...) {
    .Deprecated("roommate")
    roommate(...)
}
checkStabilityRoommate = function(...) {
    .Deprecated("cpp_wrapper_irving_check_stability")
    cpp_wrapper_irving_check_stability(...)
}
validateInputsOneSided = function(...) {
    .Deprecated("roommate.validate")
    roommate.validate(...)
}
checkPreferenceOrderOnesided = function(...) {
    .Deprecated("roommate.checkPreferences")
    roommate.checkPreferences(...)
}
topTradingCycle = function(...) {
    .Deprecated("cpp_wrapper_ttc")
    cpp_wrapper_ttc(...)
}
checkStabilityTopTradingCycle = function(...) {
    .Deprecated("cpp_wrapper_ttc_check_stability")
    toptrading.checkStability(...)
}
toptrading = function(...) {
    .Deprecated("toptrading")
    toptrading(...)
}
NULL
