# Load necessary libraries
library(httr)
library(jsonlite)
library(dplyr)

# Set the year and load the sessions data
year <- 2024
sessions_file <- file.path("../data/sessions-data", paste0("sessions_", year, ".csv"))
sessions_df <- read.csv(sessions_file)

# Define data directory for drivers
drivers_data_dir <- file.path(getwd(), "../data/drivers-data")
if (!dir.exists(drivers_data_dir)) {
  dir.create(drivers_data_dir, recursive = TRUE)
}

# Define retry parameters
max_retries <- 3
retry_delay <- 3  # seconds

# Function to fetch driver data for a given session_key with retry logic
get_drivers_for_session <- function(session_key) {
  url <- paste0("https://api.openf1.org/v1/drivers?session_key=", session_key)

  # Retry loop
  for (retry in 1:max_retries) {
    response <- GET(url)

    # If the request is successful
    if (status_code(response) == 200) {
      # Parse JSON response
      drivers_data <- content(response, "text", encoding = "UTF-8")

      # Check if the response is valid JSON
      if (startsWith(drivers_data, "[")) {
        drivers_df <- fromJSON(drivers_data, flatten = TRUE)
        return(drivers_df)
      } else {
        message(paste("Invalid JSON response for session:", session_key))
        return(NULL)
      }
    } else {
      # Log the error and wait before retrying
      message("Rate-limited (429). Retrying session: ", session_key, " (Retry ", retries, " of ", max_retries, ")")
      Sys.sleep(retry_delay)
    }
  }

  # If the request failed after retries
  message(paste("API request failed for session:", session_key, "after", max_retries, "retries"))
  return(NULL)
}

# Initialize a list to store driver data for all sessions
all_drivers_data <- list()

# Keep track of failed sessions for logging
failed_sessions <- c()

# Iterate over sessions and fetch drivers data
for (session_key in sessions_df$session_key) {
  drivers_data <- get_drivers_for_session(session_key)

  if (!is.null(drivers_data)) {
    all_drivers_data[[length(all_drivers_data) + 1]] <- drivers_data
  } else {
    failed_sessions <- c(failed_sessions, session_key)
  }
}

# Combine all driver data into one dataframe
if (length(all_drivers_data) > 0) {
  all_drivers_df <- bind_rows(all_drivers_data)

  # Save the combined driver data to CSV
  drivers_file_path <- file.path(drivers_data_dir, paste0("drivers_", year, ".csv"))
  write.csv(all_drivers_df, file = drivers_file_path, row.names = FALSE)

  message(paste("Driver data for year", year, "saved to", drivers_file_path))

} else {
  message("No driver data fetched.")
}

# Check failed sessions
if (length(failed_sessions) > 0) {
  message("The following sessions failed to fetch driver data:")
  print(failed_sessions)
}

# Display a preview of the combined driver data
if (exists("all_drivers_df")) {
  head(all_drivers_df)
}