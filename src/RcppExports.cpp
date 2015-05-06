// This file was generated by Rcpp::compileAttributes
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include "../inst/include/matchingR.h"
#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// galeShapleyMatching
List galeShapleyMatching(const umat prefM, const mat uW);
RcppExport SEXP matchingR_galeShapleyMatching(SEXP prefMSEXP, SEXP uWSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< const umat >::type prefM(prefMSEXP);
    Rcpp::traits::input_parameter< const mat >::type uW(uWSEXP);
    __result = Rcpp::wrap(galeShapleyMatching(prefM, uW));
    return __result;
END_RCPP
}
// sortIndex
umat sortIndex(const mat u);
RcppExport SEXP matchingR_sortIndex(SEXP uSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< const mat >::type u(uSEXP);
    __result = Rcpp::wrap(sortIndex(u));
    return __result;
END_RCPP
}
// rankIndex
umat rankIndex(const umat sortedIdx);
RcppExport SEXP matchingR_rankIndex(SEXP sortedIdxSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< const umat >::type sortedIdx(sortedIdxSEXP);
    __result = Rcpp::wrap(rankIndex(sortedIdx));
    return __result;
END_RCPP
}
// checkStability
bool checkStability(mat uM, mat uW, const uvec proposals, const uvec engagements);
RcppExport SEXP matchingR_checkStability(SEXP uMSEXP, SEXP uWSEXP, SEXP proposalsSEXP, SEXP engagementsSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< mat >::type uM(uMSEXP);
    Rcpp::traits::input_parameter< mat >::type uW(uWSEXP);
    Rcpp::traits::input_parameter< const uvec >::type proposals(proposalsSEXP);
    Rcpp::traits::input_parameter< const uvec >::type engagements(engagementsSEXP);
    __result = Rcpp::wrap(checkStability(uM, uW, proposals, engagements));
    return __result;
END_RCPP
}
