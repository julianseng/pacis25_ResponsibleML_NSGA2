# A Tailored NSGA-II Approach for Responsible Managerial ML Optimization on Imbalanced Data

# NSGA-2 Algorithm Modifications for Fair Balancing

This document describes modifications to the NSGA-2 algorithm (a heuristic optimization algorithm for multi-objective problems) to make it suitable for fair balancing procedures.

#### Modified Crowding Distance Calculation
- Calculates crowding distance within each repeated fitness calculation
- Averages crowding distance across all evaluations
- Uses collective voting strategy to determine extreme solutions
- Forms a hypercube measure by multiplying distances across all dimensions

#### Modified Selection Operator
- Based on solution ranks and crowding distance
- Aggregates ranks from each replicate using Borda count
- Selects solutions with larger hypercube values when ranks are equal

The modifications ensure optimization of both objective values and solution diversity while handling mixed parameter types and stochastic outcomes.


+---------------------------------------------------------------------------------------------------------+
| Crowding Distance Pseudo Code                                                                           |
+:========================================================================================================+
| **Input:** Population P, Number of Dimensions D, Number of Replicates R, Number of Individuals I        |
+---------------------------------------------------------------------------------------------------------+
| **Output:** Crowding Distance for each individual in the population                                     |
+---------------------------------------------------------------------------------------------------------+
| For each dimension $d$                                                                                  |
+--+------------------------------------------------------------------------------------------------------+
|  | For each replicate $r$                                                                               |
+--+--+---------------------------------------------------------------------------------------------------+
|  |  | Sort the population by the fitness values in dimension $d$ and determine its rank j               |
+--+--+---------------------------------------------------------------------------------------------------+
|  |  | For each individual $i$ in the sorted population:                                                 |
+--+--+--+------------------------------------------------------------------------------------------------+
|  |  |  |$$                                                                                              |
|  |  |  |   \text{Counter}_i^{\text{up}} := \begin{cases}                                                |
|  |  |  |   + 1 & \text{if } i \text{ has best rank} \\                                                  |
|  |  |  |   - 1 & \text{if } i \text{ has worst rank} \\                                                 |
|  |  |  |    0 &  \text{ else}                                                                           |
|  |  |  |   \end{cases}                                                                                  |
|  |  |  |  $$                                                                                            |
+--+--+--+------------------------------------------------------------------------------------------------+
|  |  |  |                                                                                                |
|  |  |  | $$                                                                                             |
|  |  |  |  \text{Counter}_i^{\text{low}} := \begin{cases}                                                |
|  |  |  |  + 1 & \text{if } i \text{ has worst rank} \\                                                  |
|  |  |  |    - 1 & \text{if } i \text{ has best rank} \\                                                 |
|  |  |  |   0 &  \text{ else}                                                                            |
|  |  |  |  \end{cases}                                                                                   |
|  |  |  |  $$                                                                                            |
|  |  |  |                                                                                                |
+--+--+--+------------------------------------------------------------------------------------------------+
|  |  |  | Calculate the crowding distance for individual $i$                                             |
+--+--+--+------------------------------------------------------------------------------------------------+
|  |  | **End For**                                                                                       |
+--+--+---------------------------------------------------------------------------------------------------+
|  | **End For**                                                                                          |
+--+------------------------------------------------------------------------------------------------------+
|  | Assign $\infty$ to the individuals with the highest voting count                                     |
+--+------------------------------------------------------------------------------------------------------+
| **End For**                                                                                             |
+---------------------------------------------------------------------------------------------------------+
: Pseudo code for calculating the crowding distance in NSGA-2 {#tbl-crowding-distance}



The modified crowding distance is calculated as follows:

$$
\text{Mod. Crowd. Dist.}_\text{i,d} = 
\frac{1}{R} \cdot \sum_{r=1}^{R} \frac{\Delta f_{i,d,r}}{f_{\text{d,r}}^{\text{max}} - f_{\text{d,r}}^{\text{min}}}
$$

The factor 2 in the case of smallest/largest fitness is used to account for that the distance is calculated between the two intermediate solutions, having one gap between the two individuals whose distance is calculated, whereas in the other cases the distance is calculated between the $(i+1)$-th and $(i-1)$-th solution, having two gaps between the solutions whose distance is calculated. 


$$
\Delta f_{i,d,r} = \begin{cases} 
2 \cdot (f(2){\text{d,r}} - f(1){\text{d,r}}), & \text{if } j = 1 , (\text{smallest fitness})  \\
f(j+1){\text{d,r}} - f(j-1){\text{d,r}}, & \text{if } 2 \leq j \leq I-1  \\
2 \cdot (f(I){\text{d,r}} - f(I-1){\text{d,r}}), & \text{if } j = I , (\text{largest fitness}) \end{cases}
$$

The formulation above ensures that the crowding distance is properly normalized within each replicate and dimension. 

Besides the averaged crowding distance we also use a novel criteria to determine the most diverse solutions in the solution space. Keeping diverse solution is inherent property of the calculation of the base crowding distance and is used for keeping individuals that have *extreme phenotype* in the solution space. This is important as the extreme solutions are often the most interesting solutions for the decision maker. In the base version of the crodwing distance extreme solutions, i.e., the ones on the borders of pareto front, receive a crowding distance of infinity and are so automatically forwarded in the next iteration. However, the base version of the mechanism does not lend itself to the case of there are repeated calculations of the fitness functions and in every re-calculation a different solution could be the most extreme. Instead of the mechanism in the base version of the crowding distance, as we have $R$ different such extreme solutions we use a collective voting strategy over the $R$ replicates to determine the extreme solutions. The voting strategy assigns a point to a solution if it has the best value for fitness in the $d$-th dimension i.e. $f_{d,r}^{\text{max}}$ or $f_{d,r}^{\text{min}}$. The solution gets subtracted a point if it has the worst value for fitness in the $d$-th dimension. The procedure for the lowest value in the $d$-th dimension is analogously. In the base version of the crowding distance, the extreme points get directly assigned a crowding distance of infinity to keep these solutions in the solution space. Instead of making this decision directly we use the voting strategy to determine the extreme solutions and the solutions that have the highest voting count get assigned infinity distance.


After calculating the aggregated crowding distance in every dimension of the fitness vector, a single measure of the distance is obtained  for individual $i$ by the product of the crowding distances over all dimensions which forms the *hypercube* in the objective space surrounding that solutions:
$$
\text{Hypercube}_\text{i} = \prod_{d=1}^{D}\text{Crowd. Dist.}_\text{i,d}
$$

The larger the hypercube formed by the crowding distance of individual $i$, the better the diversity of the solution as it is further away from its neighbors. The crowding distance is used during the selection operator to chose between two solutions with the same rank in the solution space. The solution from solutions with the same rank is used that has the larger hypercube.
This ensures that the population is improved in terms of both the objective values and the diversity of the solutions.

The *selection operator* in NSGA-2 is based on the rank of the solutions and the crowding distance. The rank is calculated based on the dominance of the solutions in the objective space. A solution is said to dominate another solution if it is better in at least one objective and not worse in any other objective. Concretely, fast non-dominated sorting is used to assign ranks to the solutions (Debb xxx) in each replicate $r$. The rank from each replicate is the aggregated by using *borda count* to assign the final rank to the solution. 

$$
\text{Borda Count}(i) := \sum_{r=1}^{R} \text{Rank}(i)_\text{r}
$$
