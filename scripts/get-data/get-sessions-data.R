# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set the year variable
year <- 2023

# Define directories
raw_data_dir <- here::here("data", "raw-data")
sessions_data_dir <- file.path(raw_data_dir, "sessions-data")

# Ensure the sessions-data subdirectory exists
cat(Sys.time(), "- Ensuring sessions data directory exists...\n")
dir.create(sessions_data_dir, recursive = TRUE, showWarnings = FALSE)

# Function to fetch session data for a given year
get_sessions <- function(year) {
  url <- paste0("https://api.openf1.org/v1/sessions?year=", year)
  cat(Sys.time(), "- Fetching session data from:", url, "\n")

  response <- GET(url)
  status <- status_code(response)

  if (status != 200) {
    stop(paste(Sys.time(), "- ERROR: API request failed for year:", year, "Status:", status))
  }

  cat(Sys.time(), "- API request successful. Processing data...\n")

  sessions_data <- content(response, "text", encoding = "UTF-8")

  if (!startsWith(sessions_data, "[")) {
    stop(paste(Sys.time(), "- ERROR: Invalid JSON response. Expected an array of sessions."))
  }

  sessions_df <- fromJSON(sessions_data, flatten = TRUE)

  if (nrow(sessions_df) == 0) {
    stop(paste(Sys.time(), "- ERROR: No sessions data found for the specified year."))
  }

  file_path <- file.path(sessions_data_dir, paste0("sessions_", year, ".csv"))
  cat(Sys.time(), "- Saving sessions data to", file_path, "\n")
  write.csv(sessions_df, file = file_path, row.names = FALSE)

  cat(Sys.time(), "- Sessions data saved successfully.\n")
  return(sessions_df)
}

# Run and return result
cat(Sys.time(), "- Starting session data retrieval...\n")
sessions_df <- get_sessions(year)
cat(Sys.time(), "- Session data retrieval completed.\n")

# Return the result
sessions_df