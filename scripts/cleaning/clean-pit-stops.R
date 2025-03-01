cat("Cleaning pit stops data...\n")
# Load necessary libraries
library(dplyr)
library(readr)

# Read CSV files
races <- read_csv("data/clean-data/races.csv")  # Use cleaned races.csv
pit_stops <- read_csv("data/raw-data/pit_stops.csv")

# Keep only pit stops for races from 2018 to 2024
pit_stops_clean <- pit_stops %>%
  semi_join(races, by = "raceId")

# Save cleaned CSV
write_csv(pit_stops_clean, "data/clean-data/pit_stops.csv")

# Print first few rows
head(pit_stops_clean)
cat("Pit stops data cleaned and saved.\n")