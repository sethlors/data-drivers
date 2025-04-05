cat("Cleaning lap times data...\n")
# Load necessary libraries
library(dplyr)
library(readr)

# Read CSV files
lap_times <- read_csv("../data/raw-data/lap_times.csv")
races <- read_csv("../data/clean-data/races.csv")  # Already filtered for 2018-2024

# Extract relevant race IDs
lap_times_filtered <- lap_times %>%
  semi_join(races, by = "raceId")  # Keep only lap times for races in 2018-2024

# Save cleaned CSV
write_csv(lap_times_filtered, "../data/clean-data/lap_times.csv")

# Print first few rows
head(lap_times_filtered)
cat("Lap times data cleaned and saved.\n")