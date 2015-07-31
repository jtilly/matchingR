#ifndef utils_h
#define utils_h

umat sortIndex(const mat& u);
bool checkStabilityRoommate(umat& pref, umat& matchings);
umat rankIndex(const umat& sortedIdx);

#endif
