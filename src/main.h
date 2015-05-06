#ifndef main_h
#define main_h

List galeShapleyMatching(umat prefM, mat rankW);
umat sortIndex(mat u);
umat rankIndex(umat sortedIdx);
bool checkStability(mat uM, mat uW, uvec proposals, uvec engagements);

#endif
