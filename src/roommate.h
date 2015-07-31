#ifndef roommate_h
#define roommate_h

#include <queue>
#include <deque>
#include "matchingR.h"
#include "c_logger.h"

List stableRoommateMatching(const umat pref);
bool checkStabilityRoommate(umat& pref, umat& matchings);

#endif
