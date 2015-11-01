# matchingR 1.2.1

This is a minor update. 

 * Fixed bug in galeShapley.checkStability that resulted in UBSAN throwing an error

# matchingR 1.2

 * Fixed a bug in the stable roommate matching algorithm that caused
   problems on Mac OS X / clang
 * Changed function names throughout the package (deprecated old function names)
 * Updated documentation
 * Added tests
 * Removed option to define preferences in row major order

# matchingR 1.1.1

This is a minor update. 
    
 * It fixes a memory leak warning in the stable roommate algorithm.
 * It includes minor edits of the vignettes and documentation.
 * We have substantially shortened the computational performance vignette 
   so that the package can be built and checked faster


# matchingR 1.1

This is a major update that added additional algorithms to the package.

 * Added algorithm to compute a solution to the stable roommate problem 
   (`roommate`)
 * Added top trading cycle algorithm (`toptrading`)
 * Switched the layout of preference matrices from row order to column order 
   to make the code faster
 * Added two vignettes: An introductory vignette to the package in general 
   and a computational performance vignette

# matchingR 1.0.1

Initial release that computes two versions of the Gale-Shapley algorithm:
    
 * Stable Marriage Problem
 * College Admissions Problem  
