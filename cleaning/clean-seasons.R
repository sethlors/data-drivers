cat("Cleaning seasons data...\n")
# Load necessary libraries
library(dplyr)
library(readr)

# Read CSV file
seasons <- read_csv("data/raw-data/seasons.csv")

# Filter seasons from 2018 to 2024
seasons_clean <- seasons %>%
  filter(year >= 2018 & year <= 2024)

# Save cleaned CSV
write_csv(seasons_clean, "data/clean-data/seasons.csv")

# Print first few rows
head(seasons_clean)
cat("Seasons data cleaned and saved.\n")