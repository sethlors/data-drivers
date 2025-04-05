cat("Cleaning driver standings data...\n")
# Load necessary libraries
library(dplyr)
library(readr)

# Read CSV files
driver_standings <- read_csv("../data/raw-data/driver_standings.csv")
races <- read_csv("../data/raw-data/races.csv")

# Filter races from 2018 to 2024
races_filtered <- races %>%
  filter(year >= 2018 & year <= 2024) %>%
  select(raceId) %>%
  distinct()

# Keep only driver standings for races in 2018-2024
driver_standings_clean <- driver_standings %>%
  semi_join(races_filtered, by = "raceId")

# Save cleaned CSV
write_csv(driver_standings_clean, "../data/clean-data/driver_standings.csv")

# Print first few rows
head(driver_standings_clean)
cat("Driver standings data cleaned and saved.\n")