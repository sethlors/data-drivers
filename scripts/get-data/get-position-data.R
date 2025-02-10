# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set year
year <- 2023

# Define directories
raw_data_dir <- here::here("data", "raw-data")
sessions_data_dir <- file.path(raw_data_dir, "sessions-data")
position_data_dir <- file.path(raw_data_dir, "position-data")

# Ensure the position-data subdirectory exists
cat("Ensuring position data directory exists...\n")
dir.create(position_data_dir, recursive = TRUE, showWarnings = FALSE)

# Load the sessions data
sessions_file_path <- file.path(sessions_data_dir, paste0("sessions_", year, ".csv"))
cat("Loading sessions data from:", sessions_file_path, "\n")

if (!file.exists(sessions_file_path)) stop("Sessions data file not found")

sessions_df <- read.csv(sessions_file_path)

# Extract unique meeting keys
meeting_keys <- unique(sessions_df$meeting_key)
cat("Extracting unique meeting keys...\n")
cat("Total unique meeting keys:", length(meeting_keys), "\n")

# Function to fetch position data for a meeting
get_position_for_meeting <- function(meeting_key) {
  url <- paste0("https://api.openf1.org/v1/position?meeting_key=", meeting_key)
  cat("Fetching position data for meeting key:", meeting_key, "\n")

  for (attempt in 1:3) {
    response <- GET(url)
    if (status_code(response) == 200) {
      cat("Position data fetched successfully for meeting key:", meeting_key, "\n")
      return(fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE))
    }
    cat("Attempt", attempt, "failed for meeting key:", meeting_key, ". Retrying...\n")
    Sys.sleep(3)
  }
  cat("Failed to fetch position data for meeting key:", meeting_key, "\n")
  return(NULL)
}

# Fetch position data for all meeting keys
cat("Fetching position data for all meeting keys...\n")
all_position_data <- lapply(meeting_keys, get_position_for_meeting)

# Filter out unsuccessful fetches and bind the data into a single data frame
cat("Filtering out unsuccessful fetches and binding data...\n")
all_position_df <- bind_rows(Filter(Negate(is.null), all_position_data))

# Save the results to a CSV file
if (nrow(all_position_df) > 0) {
  position_file_path <- file.path(position_data_dir, paste0("position_", year, ".csv"))
  cat("Saving position data to:", position_file_path, "\n")
  write.csv(all_position_df, file = position_file_path, row.names = FALSE)
  cat("Position data saved successfully.\n")
} else {
  cat("No position data to save.\n")
}