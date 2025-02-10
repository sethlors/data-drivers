# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set the year variable
year <- 2023

# Define directories
raw_data_dir <- here::here("data", "raw-data")
pit_data_dir <- file.path(raw_data_dir, "pit-data")

# Ensure the pit-data subdirectory exists
cat(Sys.time(), "- Ensuring pit stop data directory exists...\n")
dir.create(pit_data_dir, recursive = TRUE, showWarnings = FALSE)

# Function to fetch pit stop data for a session
get_pit_data_for_session <- function(session_key) {
  url <- paste0("https://api.openf1.org/v1/pit?session_key=", session_key)
  cat(Sys.time(), "- Fetching pit stop data for session key:", session_key, "\n")

  response <- GET(url)
  if (status_code(response) == 200) {
    cat(Sys.time(), "- Pit stop data fetched successfully for session key:", session_key, "\n")
    return(fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE))
  } else {
    cat(Sys.time(), "- WARNING: Failed to fetch pit stop data for session key:", session_key, "\n")
    return(NULL)
  }
}

# Load session keys
sessions_file_path <- file.path(raw_data_dir, "sessions-data", paste0("sessions_", year, ".csv"))
if (!file.exists(sessions_file_path)) stop("Sessions data file not found")

cat(Sys.time(), "- Loading session keys...\n")
sessions_df <- read.csv(sessions_file_path)

# Fetch pit stop data for all sessions
cat(Sys.time(), "- Fetching pit stop data for all sessions...\n")
all_pit_data <- lapply(sessions_df$session_key, get_pit_data_for_session)

# Filter out NULL values
cat(Sys.time(), "- Filtering out unsuccessful fetches and binding data...\n")
valid_pit_data <- Filter(Negate(is.null), all_pit_data)

# Ensure data type consistency before binding
if (length(valid_pit_data) > 0) {
  # Convert `lap_number` to numeric for all data frames
  valid_pit_data <- lapply(valid_pit_data, function(df) {
    if ("lap_number" %in% names(df)) {
      df$lap_number <- as.numeric(df$lap_number)  # Convert to numeric
    }
    return(df)
  })

  # Bind all pit stop data into a single data frame
  all_pit_df <- bind_rows(valid_pit_data)

  # Save to CSV if there is valid data
  if (nrow(all_pit_df) > 0) {
    pit_file_path <- file.path(pit_data_dir, paste0("pit_", year, ".csv"))
    cat(Sys.time(), "- Saving pit stop data to", pit_file_path, "\n")
    write.csv(all_pit_df, file = pit_file_path, row.names = FALSE)
    cat(Sys.time(), "- Pit stop data saved successfully.\n")
  } else {
    cat(Sys.time(), "- No valid pit stop data fetched.\n")
  }
} else {
  cat(Sys.time(), "- No valid pit stop data available to bind.\n")
}