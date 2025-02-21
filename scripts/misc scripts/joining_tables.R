

# Set working directory to the folder containing the scripts
#setwd("/Users/maxwellskinner/Documents/GitHub/data-drivers/R")  # Replace with your actual path

# List all R script files in the directory
scripts <- list.files(pattern = "\\.R$", full.names = TRUE)
scripts <- scripts[!grepl("joining_tables\\.R$", scripts)]

# Source scripts one by one to find the problematic one
for (script in scripts) {
  cat("Sourcing:", script, "\n")
  tryCatch({
    source(script)
  }, error = function(e) {
    cat("Error in", script, ":", e$message, "\n")
  })
}

# Source all scripts
lapply(scripts, source)

library(data.table)
library(dplyr)

options(digits.secs = 6)  # Ensure milliseconds are displayed

# Load datasets
driver_data <- get_car_details(driver_number = 1, session_key = 9165)
session_data <- get_sessions(session_key = 9165)
driver_info_data <- get_drivers(driver_number = 1, session_key = 9165)
interval_data <- get_intervals(session_key = 9165, driver_number = 1)
lap_data <- get_laps(session = 9165, driver_number = 1)
location_data <- get_location(session_key = 9165, driver_number = 1)
meeting_data <- get_meetings(meeting_key = 1219)
pit_data <- get_pit_data(session_key = 9165, driver_number = 1)
stint_data <- get_stints(session_key = 9165, driver_number = 1)
weather_data <- get_weather(session_key = 9165)
race_control_data <- get_race_controls(session_key = 9165)

# Helper function for printing rows and columns
print_stats <- function(df, description) {
  cat(paste0(description, ": ", nrow(df), " rows, ", ncol(df), " columns\n"))
}

# Session summary table
print_stats(session_data, "Session Data")
print_stats(driver_info_data, "Driver Info Data")
driver_session_stats <- session_data[driver_info_data, on = c("meeting_key", "session_key"), nomatch = 0]
print_stats(driver_session_stats, "After Joining Driver Info with Session Data")

driver_session_stats <- meeting_data[driver_session_stats, on = "meeting_key", nomatch = 0]
print_stats(driver_session_stats, "After Joining Meeting Data")

# Location Data Join
print_stats(driver_data, "Driver Data Before Location Join")
df <- location_data[driver_data, roll = TRUE, on = c("driver_number", "session_key", "meeting_key", "date")]
print_stats(df, "After Joining Location Data")

# Interval Data Join
df <- interval_data[df, roll = TRUE, on = c("driver_number", "session_key", "meeting_key", "date")]
print_stats(df, "After Joining Interval Data")

# Lap Data Join
df <- lap_data[df, roll = TRUE, on = c("driver_number", "session_key", "meeting_key", "date")]
print_stats(df, "After Joining Lap Data")

# Stint Data Join (Non-equi join)
df <- stint_data[df, on = .(driver_number, meeting_key, session_key, lap_start <= lap_number, lap_end >= lap_number), nomatch = 0L]
setnames(df, "lap_start", "lap_number")
#setnames(df, "i.lap_start", "date")
df[, c("lap_end") := NULL]
print_stats(df, "After Joining Stint Data")


# Rename lap_start and lap_end from stint_data to avoid overwrites
setnames(stint_data, c("lap_start", "lap_end"), c("stintlap_start", "stintlap_end"))

# Perform non-equi join while preserving lap_number in df
df <- stint_data[df, 
                 on = .(driver_number, 
                        meeting_key, 
                        session_key, 
                        stintlap_start <= lap_number, 
                        stintlap_end >= lap_number), 
                 nomatch = 0L]

# Verify if the laps are correctly assigned
unique(df[, .(lap_number, stint_number, stintlap_start, stintlap_end)])


# Pit Data Join
df <- pit_data[df, on = c("session_key", "meeting_key", "driver_number", "lap_number")]
print_stats(df, "After Joining Pit Data")

# Weather Data Join
df <- weather_data[df, roll = TRUE, on = c("session_key", "meeting_key", "date")]
print_stats(df, "After Joining Weather Data")

# Driver Session Stats Join
df <- driver_session_stats[df, on = c("session_key", "meeting_key"), nomatch = 0]
print_stats(df, "After Joining Driver Session Stats")

# Final Output
cat("Final DataFrame Shape:\n")
print_stats(df, "Final Data")
