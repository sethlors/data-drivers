cat("Cleaning results data...\n")
# Load necessary libraries
library(dplyr)
library(readr)

# Read CSV files
races <- read_csv("shiny/data/clean-data/races.csv")  # Use cleaned races.csv
results <- read_csv("raw-data/results.csv")

# Keep only results for races from 2018 to 2024
results_clean <- results %>%
  semi_join(races, by = "raceId")

# Save cleaned CSV
write_csv(results_clean, "shiny/data/clean-data/results.csv")

# Print first few rows
head(results_clean)
cat("Results data cleaned and saved.\n")