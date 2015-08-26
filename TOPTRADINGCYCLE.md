## [Top Trading Cycle Algorithm: How does it work?](https://www.youtube.com/watch?v=OvmvxAcT_Yc)

Roughly speaking, the top trading cycle algorithm proceeds by identifying cycles of agents, then eliminating those cycles until no agents remain. A cycle is a sequence of agents such that each agent most prefers the next agent's home (out of the remaining unmmatched agents), and the last agent in the sequence most prefers the first agent in the sequence's home. 

```
4,  4,  2,  4 
2,  1,  1,  1 
1,  2,  3,  3 
3,  3,  4,  2 
```

For example, for the above preference matrix, when all the agents are unmmatched, the only rotation is `{4}`, representing the fact that agent `4` most prefers his own house. Therefore, the algorithm begins by matching agent `4` to himself, and then removing him from the pool:

```
        2
2,  1,  1 
1,  2,  3 
3,  3,    
```

Now, a rotation is `{1, 2}`, because `1` most prefers `2`s house, and `2` most prefers `1`s house. So agents `1` and `2` will swap homes, leaving agent `3` all by his lonesome. 

```
         
          
        3 
          
```

Therefore, the final matching is that agent `1` swaps with agent `2`, and agents `3` and `4` keep their own homes. 