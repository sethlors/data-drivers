cat("Cleaning circuits data...\n")

# Load necessary libraries
library(dplyr)
library(readr)

# Read CSV files
circuits <- read_csv("raw-data/circuits.csv")
races <- read_csv("raw-data/races.csv")

# Filter races from 2018 to 2024
races_filtered <- races %>%
  filter(year >= 2018 & year <= 2024) %>%
  select(circuitId) %>%
  distinct()  # Remove duplicates

# Keep only circuits that appear in filtered races
circuits_clean <- circuits %>%
  semi_join(races_filtered, by = "circuitId")

# Save cleaned CSV
write_csv(circuits_clean, "shiny/data/clean-data/circuits.csv")

# Print first few rows
head(circuits_clean)
cat("Circuits data cleaned successfully!\n")