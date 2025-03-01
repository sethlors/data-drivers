cat("Cleaning races data...\n")
# Load necessary libraries
library(dplyr)
library(readr)

# Read the raw races CSV
races <- read_csv("data/raw-data/races.csv")

# Filter for races from 2018 to 2024 and select relevant columns
races_clean <- races %>%
  filter(year >= 2018 & year <= 2024) %>%
  select(raceId, year, round, circuitId, date, time)  # Keeping essential columns

# Save cleaned CSV
write_csv(races_clean, "data/clean-data/races.csv")

# Print first few rows
head(races_clean)
cat("Races data cleaned and saved.\n")