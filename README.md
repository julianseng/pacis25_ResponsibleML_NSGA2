# A Tailored NSGA-II Approach for Responsible Managerial ML Optimization on Imbalanced Data

## Modified NSGA-II Algorithm for Fair Balancing

This document outlines key modifications to the NSGA-II algorithm to enhance its suitability for fair balancing with imbalanced data.

### 1. Modified Crowding Distance Calculation

The modified crowding distance is calculated as:

$$
\text{Mod. Crowd. Dist.}_\text{i,d} = 
\frac{1}{R} \cdot \sum_{r=1}^{R} \frac{\Delta f_{i,d,r}}{f_{\text{d,r}}^{\text{max}} - f_{\text{d,r}}^{\text{min}}}
$$

Where:
$$
\Delta f_{i,d,r} = \begin{cases} 
2 \cdot (f(2){\text{d,r}} - f(1){\text{d,r}}), & \text{if } j = 1 \text{ (smallest fitness)}  \\
f(j+1){\text{d,r}} - f(j-1){\text{d,r}}, & \text{if } 2 \leq j \leq I-1  \\
2 \cdot (f(I){\text{d,r}} - f(I-1){\text{d,r}}), & \text{if } j = I \text{ (largest fitness)} \end{cases}
$$

Key improvements:
- Calculates and averages crowding distance across all evaluations
- Normalizes within each replicate and dimension

### 2. Extreme Solution Handling

Instead of assigning infinity to extreme solutions, we implement a collective voting strategy:
- Solutions receive +1 point when having best fitness in dimension d
- Solutions receive -1 point when having worst fitness in dimension d
- Solutions with highest voting counts receive infinity distance

### 3. Hypercube Diversity Measure

A single diversity measure for individual i is calculated as:
$$
\text{Hypercube}_\text{i} = \prod_{d=1}^{D}\text{Crowd. Dist.}_\text{i,d}
$$

### 4. Modified Selection Operator

- Based on solution ranks and hypercube diversity measure
- Aggregates ranks from replicates using Borda count:
$$
\text{Borda Count}(i) := \sum_{r=1}^{R} \text{Rank}(i)_\text{r}
$$
- Selects solutions with larger hypercube values when ranks are equal

These modifications optimize both objective values and solution diversity while effectively handling mixed parameter types and stochastic outcomes.
