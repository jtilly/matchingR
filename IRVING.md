## Irving's Stable Roommate Algorithm: How does it work?

Preferences of potential roommates are summarized by an `n-1 x n` dimensional matrix, e.g., if `n = 6`, 
```{r}
pref = matrix(c(3, 6, 2, 5, 3, 5,
                4, 5, 4, 2, 1, 1,
                2, 4, 5, 3, 2, 3,
                6, 1, 1, 6, 4, 4,
                5, 3, 6, 1, 6, 2), nrow = 5, ncol = 6, byrow = TRUE)
```
Column `i` represents the preferences of the `i`th roommate, and row `j` represents the ranking of the roommate whose index is encoded in that row. For example, in the above preference matrix, roommate `1` most prefers to be matched with roommate `3`, followed by `4`, followed by `2`.

The algorithm proceeds in two phases.

### Phase 1

In phase 1, potential roommates take turns sequentially proposing to the other roommates. Each roommate who is proposed to can accept or reject the proposal. A roommate accepts if he currently has made no better proposal which was accepted to another roommate. If a roommate has accepted a proposal, and then receives a better proposal, he rejects the old proposal and substitutes in the new proposal. 

In the above example, 

1. Roommate `1` begins by proposing to roommate `3`, his most preferred roommate. `3`, having no better offers, accepts.
2. `2` proposes to `6`, who accepts.
3. `3` proposes to `2`, who accepts.
4. `4` proposes to `5`, who accepts.
5. `5` proposes to `3`, who accepts. `3` cancels his proposal from `1`.
6. `1`, having no proposal, proposes to `4`, who accepts.
7. `6` proposes to `5`, who rejects, having a better proposal from `4`.
8. `6` proposes to `1`, who accepts.

### Phase 2

In phase 2, we begin by eliminating all potential roommate matches which are worse than the current proposals held. For example, in the above example, `3` has a proposal from `5`, and so we eliminate `1` and `6` from `3`'s column, and symmetrically eliminate `3` from `1` and `6`'s column. This results in the following 'reduced' preference listing:
```
   6, 2, 5, 3,  
4, 5, 4, 2,    1
2, 4, 5, 3, 2,  
6, 1,    6, 4, 4
   3,    1,    2
```
These preferences form what is called a 'stable' table, or, 's-table'. ('Stable' for short.) The defining characteristic of a stable table is that if `i` is the most preferred roommate on `j`s list, then `j` is the least preferred roommate on `i`s list. For example, `1` most prefers `4`, but `4` least prefers `1`. 

The algorithm proceeds by finding and eliminating 'rotations'. A rotation is a sequence of pairs of roommates, such that there is a distinct roommate in the first position of each pair, the second roommate in each pair least prefers the roommate he is paired with, the first roommate in each pair most prefers the roommate he is paired with, and finally, the first roommate in each pair ranks the second roommate in the following pair second (modulo the number of pairs, that is, the first roommate in the last pair ranks the second roommate in the first pair second) Once a rotation has been identified, removing it results in another stable table.

For example, `(1, 4), (3, 2)` is a rotation in the above table, because `1` loves `4`, `3` loves `2`, `4` hates `1`, `2` hates `3`, `2` is second on `1`s list, and `4` is second on `3`'s list. Eliminating this rotation involves `2` rejecting `3`, `4` rejecting `1`, and then we remove every successive potential roommate as well to preserve the stable table property, resulting in
```
   6,    5, 3,  
   5, 4, 2,    1
2, 4, 5, 3, 2,  
6, 1,    6, 4, 4
               2
```
A further rotation is `(1, 2), (2, 6), (4, 5)`. Eliminating it yields
```
            3,  
   5, 4, 2,    1
   4, 5, 3, 2,  
6,              
```
A final rotation is `(2, 5), (3, 4)`. Eliminating it yields
```
            3,  
         2,    1
   4, 5,        
6,              

```
Therefore, a stable matching is for `1` and `6` to match, `2` and `4` to match, and `3` and `5` to match. 
```{r}
results = onesided(pref = pref - 1)
results
```
