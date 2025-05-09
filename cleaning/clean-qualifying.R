cat("Cleaning qualifying data...\n")
# Load necessary libraries
library(dplyr)
library(readr)

# Read CSV files
races <- read_csv("shiny/data/clean-data/races.csv")  # Use cleaned races.csv
qualifying <- read_csv("raw-data/qualifying.csv")

# Keep only qualifying results for races from 2018 to 2024
qualifying_clean <- qualifying %>%
  semi_join(races, by = "raceId")

# Save cleaned CSV
write_csv(qualifying_clean, "shiny/data/clean-data/qualifying.csv")

# Print first few rows
head(qualifying_clean)
cat("Qualifying data cleaned and saved.\n")