#ifndef main_h
#define main_h

List galeShapleyMatching(umat prefM, mat rankW);
umat sortIndex(mat u);
umat rankIndex(umat sortedIdx);
umat sortIndexSingle(const mat u);
bool checkStability(mat uM, mat uW, umat proposals, umat engagements);
List stableRoommateMatching(const umat pref);
void print_table(std::vector< std::vector<size_t> >);
void deleteValueWithWarning(std::vector<size_t> *vec, size_t val);
void throwError(std::string error);
void log(std::string val);

#endif
