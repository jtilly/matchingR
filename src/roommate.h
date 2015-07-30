#ifndef roommate_h
#define roommate_h

List stableRoommateMatching(const umat pref);
void deleteValueWithWarning(std::vector<size_t> *vec, size_t val);
bool isEmpty(std::vector< std::vector<size_t> > *table);

#endif
