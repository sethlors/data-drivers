cat("Cleaning drivers data...\n")
# Load necessary libraries
library(dplyr)
library(readr)

# Read CSV files
drivers <- read_csv("raw-data/drivers.csv")
driver_standings <- read_csv("shiny/data/clean-data/driver_standings.csv")  # Already filtered for 2018-2024

# Extract unique driver IDs from filtered standings
drivers_filtered <- drivers %>%
  semi_join(driver_standings, by = "driverId")  # Keep only matching drivers

# Save cleaned CSV
write_csv(drivers_filtered, "shiny/data/clean-data/drivers.csv")

# Print first few rows
head(drivers_filtered)
cat("Drivers data cleaned and saved.\n")