#ifndef toptradingcycle_h
#define toptradingcycle_h

#include "matchingR.h"

List cpp_wrapper_ttc(const umat pref);
bool checkStabilityTopTradingCycle(umat pref, umat matchings);

#endif
