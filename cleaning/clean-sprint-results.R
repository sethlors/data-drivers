cat("Cleaning sprint results data...\n")
# Load necessary libraries
library(dplyr)
library(readr)

# Read CSV files
sprint_results <- read_csv("data/raw-data/sprint_results.csv")
races <- read_csv("data/raw-data/races.csv")

# Filter races from 2018 to 2024
races_filtered <- races %>%
  filter(year >= 2018 & year <= 2024) %>%
  select(raceId)

# Keep only sprint results that appear in filtered races
sprint_results_clean <- sprint_results %>%
  semi_join(races_filtered, by = "raceId")

# Save cleaned CSV
write_csv(sprint_results_clean, "data/clean-data/sprint_results.csv")

# Print first few rows
head(sprint_results_clean)
cat("Sprint results data cleaned and saved.\n")