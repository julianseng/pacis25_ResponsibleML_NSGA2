# A Tailored NSGA-II Approach for Responsible Managerial ML Optimization on Imbalanced Data

## Modified NSGA-II Algorithm for Fair Balancing

This document outlines key modifications to the NSGA-II algorithm to enhance its suitability for fair balancing with imbalanced data.

### 1. Modified Crowding Distance Calculation

The modified crowding distance $$\text{Mod. Crowd. Dist.}_{i,d}$$ is calculated as:

$$1/R \sum_{r=1}^{R} \frac{\Delta f_{i,d,r}}{f_{d,r}^{\text{max}} - f_{d,r}^{\text{min}}}$$

Where:
- If j = 1 (smallest fitness): $$\Delta f_{i,d,r} = 2 \cdot \left( f_{d,r}(2) - f_{d,r}(1) \right)$$

- If $$2 \leq j \leq I-1$$: $$\Delta f_{i,d,r} = \left( f_{d,r}(j+1) - f_{d,r}(j-1) \right)$$

- If j = I (largest fitness): $$\Delta f_{i,d,r} = 2 \cdot \left( f_{d,r}(I) - f_{d,r}(I-1) \right)$$


In contrast to the standard crowing distance, there are several indiviual crowding distance for one parameter set due to repeated calculations as the underlying algorithms are stochastic. We normalizes within each replicate and dimension.

### 2. Extreme Solution Handling

Instead of assigning infinity to extreme solutions, we implement a collective voting strategy:
- Solutions receive +1 point when having best fitness in dimension d
- Solutions receive -1 point when having worst fitness in dimension d
- Solutions with highest voting counts receive infinity distance

### 3. Hypercube Diversity Measure

A single diversity measure for individual i is calculated as:
$$\prod_{d=1}^{D}\text{Crowd. Dist.}_{i,d}$$

### 4. Modified Selection Operator

- Based on solution ranks and hypercube diversity measure
- Aggregates ranks from replicates using Borda count:
$$\text{Borda Count}(i) := \sum_{r=1}^{R} \text{Rank}(i)_r$$
- Selects solutions with larger hypercube values when ranks are equal

These modifications optimize both objective values and solution diversity while effectively handling mixed parameter types and stochastic outcomes.
