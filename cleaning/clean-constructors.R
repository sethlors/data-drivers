cat("Cleaning constructors data...\n")
# Load necessary libraries
library(dplyr)
library(readr)

# Read CSV files
constructors <- read_csv("../data/raw-data/constructors.csv")
constructor_results <- read_csv("../data/raw-data/constructor_results.csv")
races <- read_csv("../data/raw-data/races.csv")

# Filter races from 2018 to 2024
races_filtered <- races %>%
  filter(year >= 2018 & year <= 2024) %>%
  select(raceId) %>%
  distinct()

# Filter constructor results to include only races from 2018 to 2024
constructor_results_filtered <- constructor_results %>%
  semi_join(races_filtered, by = "raceId") %>%
  select(constructorId) %>%
  distinct()

# Keep only constructors that appeared in filtered races
constructors_clean <- constructors %>%
  semi_join(constructor_results_filtered, by = "constructorId")

# Save cleaned CSV
write_csv(constructors_clean, "../data/clean-data/constructors.csv")

# Print first few rows
head(constructors_clean)
cat("Constructors data cleaned and saved.\n")