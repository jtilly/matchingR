#ifndef galeshapley_h
#define galeshapley_h

List cpp_wrapper_galeshapley(umat& prefM, mat& rankW);
bool cpp_wrapper_galeshapley_check_stability(mat& uM, mat& uW, umat& proposals, umat& engagements);

#endif
