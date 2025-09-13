# -----------------------------------------------------------
# File: casestudy_msa_variance_estimation.py
# Purpose:
#     Estimate variance components (sigma2_u, sigma2_e) and SNR
#     for 'sa' and 'sz' surface measurements across 14 locations
#     over 5 days and 3 samples per day.
#
# Data structure:
#   - 5 manufacturing cycles (days)
#   - 3 samples per cycle
#   - 14 surface texture measurements per sample
#   - Measurements: 'sa' (arithmetic mean height) and 'sz' (maximum height)
#
# Author: Banafsheh Lashkari
# Date: 2025-07-10
# -----------------------------------------------------------

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import scienceplots


# -----------------------------------------------------------
# Load data
# -----------------------------------------------------------
# Change this path to where your CSV file is located
data = pd.read_csv("surface_data.csv")

a = 5   # number of days
r = 3   # number of samples per day

# -----------------------------------------------------------
# Reshape data to wide format (15 rows = 5*3, 14 cols for locations)
# -----------------------------------------------------------
data_profile = []

for d in range(1, a + 1):
    for s in range(1, r + 1):
        subset_data = data[(data["day"] == d) & (data["sample"] == s)]
        row = [d, s] + subset_data["sa"].tolist()   # use "sz" if analyzing sz
        data_profile.append(row)

columns = ["day", "sample"] + [f"loc_{i}" for i in range(1, 15)]
data_df = pd.DataFrame(data_profile, columns=columns)

# Matrix form (15 x 14)
data_matrix = data_df.iloc[:, 2:].values

# -----------------------------------------------------------
# Compute group means per day (5 x 14) and overall mean
# -----------------------------------------------------------
groupmean_profile = []

for d in range(1, a + 1):
    subset = data_df[data_df["day"] == d].iloc[:, 2:]
    groupmean_profile.append(subset.mean().values)

groupmean_profile = np.vstack(groupmean_profile)   # (5 x 14)
overallmean = groupmean_profile.mean(axis=0)       # (14,)

# -----------------------------------------------------------
# Compute sums of squares
# -----------------------------------------------------------
SS_u = r * np.sum((groupmean_profile - overallmean) ** 2, axis=0)

rep_groupmean = np.repeat(groupmean_profile, r, axis=0)
SS_e = np.sum((data_matrix - rep_groupmean) ** 2, axis=0)

rep_overallmean = np.tile(overallmean, (a * r, 1))
SS_t = np.sum((data_matrix - rep_overallmean) ** 2, axis=0)

# -----------------------------------------------------------
# Variance components (MLE)
# -----------------------------------------------------------
MS_u = SS_u / (a - 1)
MS_e = SS_e / (a * (r - 1))
beta = a / (a - 1)

sigma2_u = np.maximum(0, ((1 / beta) * MS_u - MS_e) / r)
sigma2_e = np.minimum(SS_t / (a * r), MS_e)
SNR_MLE = np.sqrt(np.maximum(0, (1 / r) * ((1 / beta) * MS_u / MS_e - 1)))

# -----------------------------------------------------------
# Combine into DataFrame
# -----------------------------------------------------------
estimates_df = pd.DataFrame({
    "location": np.arange(1, 15),
    "sigma2_u": sigma2_u,
    "sigma2_e": sigma2_e,
    "SNR": SNR_MLE
})

print(estimates_df)

# -----------------------------------------------------------
# Plot SNR estimates
# -----------------------------------------------------------

plt.rcParams.update({
    "text.usetex": True,
    "font.family": "serif",
    "font.serif": ["Times"],
})
    

with plt.style.context(['science', 'ieee', 'grid']):
    plt.figure(figsize=(1.5, 1.25))  # same size as before

    # Main line plot
    plt.plot(estimates_df["location"], estimates_df["SNR"], marker="o", markersize=1,
             color="blue", linewidth=0.5, label='SNR')

    # Horizontal reference line
    plt.axhline(y=2, color="red", linestyle="--", linewidth=0.5, label='Reference')

    # Axis limits
    plt.xlim([estimates_df["location"].min(), estimates_df["location"].max()])
    plt.ylim([0, 3])

    # Axis labels
    plt.xlabel(r'Location', fontsize=4)
    plt.ylabel(r'$\widehat{\textrm{SNR}}$', fontsize=4)

    # Tick labels and ticks
    plt.xticks(np.arange(2, 15, 2))
    plt.yticks(np.arange(0, 2.6, 0.5))
    plt.tick_params(axis='both', labelsize=4)
    plt.minorticks_off()  # remove minor ticks
    

    # Grid
    ax = plt.gca()
    ax.grid(True, linestyle='-', linewidth=0.5, color='lightgray')  # light gray solid grid

    # Legend
    legend = ax.legend(loc='upper right', fontsize=4, handletextpad=0.4, labelspacing=0.1)
    legend.get_frame().set_linewidth(0.5)
    legend.get_frame().set_edgecolor('black')

    #plt.tight_layout()
    plt.title(r'SNR estimates for arithmetic mean height data (sa)', fontsize=4)
    plt.tight_layout(pad=0.5)  # increase pad if needed
    plt.show()
    plt.savefig("SNR_sa.jpg",  dpi=300, bbox_inches='tight')