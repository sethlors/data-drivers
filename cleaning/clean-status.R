cat("Cleaning status data...\n")
# Load necessary libraries
library(readr)

# Read the status file
status <- read_csv("raw-data/status.csv")

# Save it to the clean directory
write_csv(status, "shiny/data/clean-data/status.csv")

# Print first few rows
head(status)
cat("Status data cleaned and saved.\n")