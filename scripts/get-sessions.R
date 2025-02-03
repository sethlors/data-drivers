# Load necessary libraries
library(httr)
library(jsonlite)
library(dplyr)

# Set the year variable (modify as needed)
year <- 2024

# Define data directory for sessions
data_dir <- file.path(getwd(), "../data/sessions-data")
if (!dir.exists(data_dir)) {
  dir.create(data_dir, recursive = TRUE)
}

# Function to fetch session data for a given year
get_sessions <- function(year) {
  # Define API URL
  url <- paste0("https://api.openf1.org/v1/sessions?year=", year)

  # Fetch data
  response <- GET(url)

  # Check if the request was successful
  if (status_code(response) != 200) {
    stop(paste("API request failed for year:", year, "Status:", status_code(response)))
  }

  # Parse JSON response
  sessions_data <- content(response, "text", encoding = "UTF-8")

  # Validate the response format
  if (!startsWith(sessions_data, "[")) {
    stop("Invalid JSON response. Expected an array of sessions.")
  }

  sessions_df <- fromJSON(sessions_data, flatten = TRUE)

  # Check if sessions data is empty
  if (length(sessions_df) == 0) {
    stop("No sessions data found for the specified year.")
  }

  # Save to CSV
  file_path <- file.path(data_dir, paste0("sessions_", year, ".csv"))
  write.csv(sessions_df, file = file_path, row.names = FALSE)

  message(paste("Sessions data for year", year, "saved to", file_path))

  return(sessions_df)
}

# Fetch session data for the specified year
sessions_df <- get_sessions(year)

# Display the fetched sessions data
head(sessions_df)