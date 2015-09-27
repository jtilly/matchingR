#ifndef toptradingcycle_h
#define toptradingcycle_h

#include "matchingR.h"

uvec cpp_wrapper_ttc(const umat pref);
bool cpp_wrapper_ttc_check_stability(umat pref, umat matchings);

#endif
