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
