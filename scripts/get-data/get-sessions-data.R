# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set the year variable
year <- 2024

# Define directories
raw_data_dir <- here::here("data", "raw-data")
sessions_data_dir <- file.path(raw_data_dir, "sessions-data")

# Ensure the sessions-data subdirectory exists
dir.create(sessions_data_dir, recursive = TRUE, showWarnings = FALSE)

# Function to fetch session data for a given year
get_sessions <- function(year) {
  url <- paste0("https://api.openf1.org/v1/sessions?year=", year)
  response <- GET(url)

  if (status_code(response) != 200) {
    stop(paste("API request failed for year:", year, "Status:", status_code(response)))
  }

  sessions_data <- content(response, "text", encoding = "UTF-8")

  if (!startsWith(sessions_data, "[")) {
    stop("Invalid JSON response. Expected an array of sessions.")
  }

  sessions_df <- fromJSON(sessions_data, flatten = TRUE)

  if (nrow(sessions_df) == 0) {
    stop("No sessions data found for the specified year.")
  }

  file_path <- file.path(sessions_data_dir, paste0("sessions_", year, ".csv"))
  write.csv(sessions_df, file = file_path, row.names = FALSE)

  message(paste("Sessions data saved to", file_path))
  return(sessions_df)
}

# Run and return result
sessions_df <- get_sessions(year)
sessions_df  # Make sure it returns the data