# msa-numerical-example
Code and data for the illustrative case study application

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


## 🔧 Analysis Overview
We demonstrate how to:
- Estimate variance components: $\sigma^2_u$ (between-unit) and $\sigma^2_\epsilon$ (within-unit)
- Compute $\rho = \sigma^2_u / (\sigma^2_u + \sigma^2_\epsilon)$


