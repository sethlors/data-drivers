# Define the function to get stints for all sessions with retry logic
get_all_stints_with_retry <- function(year, max_retries = 3, retry_delay = 5) {
  # Load sessions data for the specified year
  sessions_file <- file.path("../data/sessions-data", paste0("sessions_", year, ".csv"))
  sessions_df <- read.csv(sessions_file)

  # Initialize an empty list to store all stints data
  all_stints <- list()

  # Loop through each session in the sessions data
  for (i in 1:nrow(sessions_df)) {
    # Extract session_key and meeting_key for the current session
    session_key <- sessions_df$session_key[i]
    meeting_key <- sessions_df$meeting_key[i]

    # Define the API URL for stints
    url <- paste0("https://api.openf1.org/v1/stints?meeting_key=", meeting_key, "&session_key=", session_key)

    # Initialize retry counter
    retries <- 0
    success <- FALSE

    # Retry logic for API request
    while (retries < max_retries && !success) {
      # Fetch data from the API
      response <- GET(url)

      # Set encoding explicitly to avoid warnings
      content_response <- content(response, "text", encoding = "UTF-8")

      # Check if the request was successful (status 200)
      if (status_code(response) == 200) {
        # Parse the JSON response
        stints_data <- fromJSON(content_response, flatten = TRUE)

        # Convert the data to a dataframe
        stints_df <- as.data.frame(stints_data)

        # Add session-specific information (e.g., session_key) for identification
        stints_df$session_key <- session_key
        stints_df$meeting_key <- meeting_key

        # Append the stints data for this session to the list
        all_stints[[i]] <- stints_df

        # Set success to TRUE to break the retry loop
        success <- TRUE
      } else if (status_code(response) == 429) {
        # If rate-limited (status 429), retry after waiting
        retries <- retries + 1
        message("Rate-limited (429). Retrying session: ", session_key, " (Retry ", retries, " of ", max_retries, ")")

        # Wait before retrying
        Sys.sleep(retry_delay)
      } else {
        # For other errors, log and move to next session
        message("API request failed for session: ", session_key, " Status: ", status_code(response))
        break
      }
    }

    # If the request fails after all retries, log it
    if (!success) {
      message("Failed to fetch stints for session: ", session_key, " after ", max_retries, " retries.")
    }
  }

  # Combine all stints data into one dataframe
  combined_stints_df <- do.call(rbind, all_stints)

  # Define the data directory for stints
  stints_data_dir <- file.path(getwd(), "../data/stints-data")
  if (!dir.exists(stints_data_dir)) {
    dir.create(stints_data_dir, recursive = TRUE)
  }

  # Define the file path to save the combined stints data
  stints_file <- file.path(stints_data_dir, paste0("stints_", year, ".csv"))

  # Save the combined stints data to CSV
  write.csv(combined_stints_df, file = stints_file, row.names = FALSE)

  # Confirmation message
  message("Stints data saved to: ", stints_file)

  return(combined_stints_df)
}

# Example usage: fetch and save stints data for 2024 with retry logic
year <- 2024
stints_df <- get_all_stints_with_retry(year)

# Print the first few rows to confirm
head(stints_df)