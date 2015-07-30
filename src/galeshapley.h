#ifndef galeshapley_h
#define galeshapley_h

List galeShapleyMatching(umat& prefM, mat& rankW);
bool checkStability(mat& uM, mat& uW, umat& proposals, umat& engagements);

#endif
