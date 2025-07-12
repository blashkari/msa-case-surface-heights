#-----------------------------------------------------------
# File: casestudy_msa_variance_estimation.R
# Purpose: 
#     Estimate variance components (sigma2_u, sigma2_e) and SNR
#     for 'sa' and 'sz' surface measurements across 14 locations
#     over 5 days and 3 samples per day.

#     The analysis is performed using base R (no external packages)
#     and follows a classical random effects model framework.
#
# Data structure:
#   - 5 manufacturing cycles (days)
#   - 3 samples per cycle
#   - 14 surface texture measurements per sample
#   - Measurements: 'sa' (arithmetic mean height)
#
# Main steps:
#   1. Reshape long-format measurement data to wide-format matrix
#   2. Compute group means, overall mean, and two mean squares matrices
#   3. Decompose total variation into between- and within-day components
#   4. Estimate sigma2_u, sigma2_e using MLE formula
#   5. Compute SNR per measurement location

# Output:
#   - A data frame (`estimates_df`) with 14 rows (locations) and:
#       * sigma2_u : Between-day variance estimate
#       * sigma2_e : Within-day (residual) variance estimate
#       * SNR      : Signal-to-noise ratio# Output: Data frame of estimated variance components and SNR
#
# Set the working directory to the folder where your dataset (e.g., "surface_data.csv") is stored.
# Author: Banafsheh Lashkari 
# Date: 2025-07-10

#-----------------------------------------------------------

# Modify the path below to match your local file system.
setwd("C:/Users/your_name/your_folder/")
rm(list = ls())

#library(readr)
data <- read.csv("surface_data.csv")

a<- 5
r<- 3

#-----------------------------------------------------------
# Reshape data: convert long-format measurements to a wide-format
# matrix with one row per printed item (day x sample),
# and one column per measurement location (1 to 14)
#-----------------------------------------------------------

row_index <- 1
data_profile <- matrix(nrow = 15, ncol = 16)
for (d in 1:5){
  for (s in 1:3){
    subset_data <- data[data$day == d & data$sample == s, ]
    
    
    data_profile[row_index,] <- c(d,s,subset_data$sa) 
    # Use 'subset_data$sa' instead of 'sz' if analyzing 'sa' values
    row_index <- row_index + 1
  }
}

data_df <- as.data.frame(data_profile)
colnames(data_df) <- c("day", "sample", paste0("loc_", 1:14))

# Use 'data$sz' instead of 'sz' if analyzing 'sa' values
data_matrix <- matrix(data$sa, nrow = 15, byrow = TRUE)

#-----------------------------------------------------------
# Compute group means: mean profile of 14 locations for each day
# Overall mean: grand average profile across all items
#-----------------------------------------------------------

row_index <- 1
groupmean_profile <- matrix(nrow = 5, ncol = 14)
for (d in 1:5){
  subset_data <- data_df[data_df$day == d, ]
  subset_data <- subset_data[,-(1:2)]  # removing columns 1 and 2
  
  groupmean_profile[row_index,] <-colMeans(subset_data)
  row_index <- row_index + 1
}


overalmean <- colMeans(groupmean_profile)

#-----------------------------------------------------------
# Compute sums of squares:
# SS_u: due to day-to-day variation in mean profiles
# SS_e: due to variation within each day (item-to-item)
# SS_t: total variation across all printed items
#-----------------------------------------------------------

SS_u <- r * colSums((groupmean_profile - matrix(rep(overalmean, a), nrow = a, byrow = TRUE))^2)
SS_e <- colSums((data_matrix -groupmean_profile[rep(1:a, each=3),])^2)
SS_t <- colSums((data_matrix -matrix(rep(overalmean, a*r), nrow = a*r, byrow = TRUE))^2)

#-----------------------------------------------------------
# Compute MLEs of variance components:
# - MS_u: mean square for day effect
# - MS_e: mean square for residual/error
# - sigma2_u: between-day variance component
# - sigma2_e: within-day variance component
# - SNR: signal-to-noise ratio per location
#-----------------------------------------------------------

MS_u <- SS_u/(a-1)
MS_e <- SS_e/(a*(r-1))
beta <- a/(a-1)
sigma2_u = pmax(0, (beta^{-1}*MS_u - MS_e)/r)
sigma2_e = pmin(SS_t/(a*r), MS_e)
SNR_MLE =  sqrt(pmax(0,(1/r*(beta^{-1}*MS_u/MS_e-1))))


#-----------------------------------------------------------
# Combine and export estimates
#-----------------------------------------------------------
# 'estimates_df' contains location-wise variance estimates
# and signal-to-noise ratios. This can be visualized or
# saved for further analysis.

estimates_df <- data.frame(
  location = 1:14,
  sigma2_u = sigma2_u,
  sigma2_e = sigma2_e,
  SNR = SNR_MLE
)

#------------------------------------------------------------
# Plot SNR estimates across 14 locations
#------------------------------------------------------------
# Install ggplot2 if not already installed
# install.packages("ggplot2")

# Load the library
library(ggplot2)

# Create the plot
# Add a horizontal dashed red reference line at SNR = 2
# This value serves as a benchmark threshold for acceptable signal-to-noise ratio


ggplot(estimates_df, aes(x = location, y = SNR)) +
  geom_line(color = "blue", size = 1.0) +
  geom_point(color = "blue", size = 2.5) +
  geom_hline(yintercept = 2, linetype = "dashed", color = "red", size = 1) +
  scale_x_continuous(breaks = seq(2, 14, by = 2)) +
  scale_y_continuous(
    breaks = seq(0, 2.5, by = 0.5),  # Adjust grid breaks
    limits = c(0, 2.5)              # Set y-axis range from 0 to 2.5
  ) +
  labs(
    title = "SNR Estimates Across Locations",
    x = "Location",
    y = "SNR Estimates"
  ) +
  theme_minimal(base_size = 16)
