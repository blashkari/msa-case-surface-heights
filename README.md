# msa-numerical-example
Code and data for the case study application.
This repository complements the methods described in our paper:

📄 *A Comprehensive Framework for Statistical Inference in Measurement System Assessment Studies* ([arXiv:2501.18037](https://arxiv.org/abs/2501.18037))

## 📊 Example Data
The example dataset (`example_data.csv`) contains measurements over five days, with each day corresponding to an individual manufacturing cycle. 
During each cycle, three items were printed, all derived from the same computer-aided design and utilizing the same setup on the manufacturing platform. 
The key surface texture characteristics are the 'arithmetic mean height' (sa) and 'maximum height' (sz), collected from 14 consistently identical locations across all manufactured items.  

| Column     | Description                                  |
|------------|----------------------------------------------|
| `day`      | Identifier for each unique day (or cycle)    |
| `sample`   | Printed items in each day (1, 2, or 3)       |
| `location` | Identifier of the location       (1 to 14)   |
| `sa`       | measured value of the arithmetic mean height |
| `sz`       | measured value of the maximum height         |

## 🔧 Surface Texture Model
This is an analysis of variance problem involving $5$ days ($5$ cycles) and $3$ printed items each day. The underlying model for the texture roughness indicator at location $x$ is given by,
$Y_{ij}(x) = \mu(x) + U_{i}(x) + \epsilon_{ij}(x),$ for $i=1,\ldots,5$ and $j=1,\ldots,3$.


##  📈 Analysis Overview
### Location-wise analysis

We initially applied a one-way ANOVA model, detailed in the paper, to the roughness measurements at all $14$ locations.
We demonstrate how to:
- Estimate variance components: $\sigma^2_u$ (between-unit) and $\sigma^2_\epsilon$ (within-unit)
- Compute $\rho = \sigma^2_u / \sigma^2_\epsilon$


