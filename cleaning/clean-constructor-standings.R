cat("Cleaning constructor standings data...\n")
# Load necessary libraries
library(dplyr)
library(readr)

# Read CSV files
constructor_standings <- read_csv("raw-data/constructor_standings.csv")
races <- read_csv("raw-data/races.csv")

# Filter races from 2018 to 2024
races_filtered <- races %>%
  filter(year >= 2018 & year <= 2024) %>%
  select(raceId) %>%
  distinct()  # Remove duplicates

# Keep only constructor standings that appear in filtered races
constructor_standings_clean <- constructor_standings %>%
  semi_join(races_filtered, by = "raceId")

# Save cleaned CSV
write_csv(constructor_standings_clean, "shiny/data/clean-data/constructor_standings.csv")

# Print first few rows
head(constructor_standings_clean)
cat("Constructor standings data cleaned and saved.\n")