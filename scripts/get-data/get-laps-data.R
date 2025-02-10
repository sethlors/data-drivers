# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set year
year <- 2023

# Define directories
raw_data_dir <- here::here("data", "raw-data")
sessions_data_dir <- file.path(raw_data_dir, "sessions-data")
laps_data_dir <- file.path(raw_data_dir, "laps-data")

# Ensure the laps-data subdirectory exists
cat("Ensuring laps data directory exists...\n")
dir.create(laps_data_dir, recursive = TRUE, showWarnings = FALSE)

# Load the sessions data
sessions_file_path <- file.path(sessions_data_dir, paste0("sessions_", year, ".csv"))
if (!file.exists(sessions_file_path)) stop("Sessions data file not found")

cat("Loading sessions data...\n")
sessions_df <- read.csv(sessions_file_path)

# Function to fetch lap data for a session
get_laps_for_session <- function(session_key) {
  url <- paste0("https://api.openf1.org/v1/laps?session_key=", session_key)

  for (attempt in 1:3) {
    cat("Fetching lap data for session:", session_key, "Attempt:", attempt, "\n")
    response <- GET(url)
    if (status_code(response) == 200) {
      cat("Data fetched successfully for session:", session_key, "\n")
      df <- fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE)

      # Ensure df is a data frame
      if (!is.data.frame(df)) {
        cat("Warning: Data is not a valid data frame for session:", session_key, "\n")
        return(NULL)
      }

      # Identify columns that are lists (avoid errors if sapply returns NULL)
      list_cols <- sapply(df, is.list)
      if (any(list_cols, na.rm = TRUE)) {
        cat("Converting list columns to JSON strings...\n")
        df[list_cols] <- lapply(df[list_cols], function(col) sapply(col, toJSON, auto_unbox = TRUE))
      }

      return(df)
    }
    cat("Failed attempt", attempt, "for session:", session_key, "\n")
    Sys.sleep(3)
  }
  cat("Failed to fetch data for session:", session_key, "\n")
  return(NULL)
}

# Fetch lap data for all sessions
cat("Fetching lap data for all sessions...\n")
all_laps_data <- lapply(sessions_df$session_key, get_laps_for_session)

# Filter out unsuccessful fetches and bind the data into a single data frame
cat("Binding lap data...\n")
valid_laps_data <- Filter(Negate(is.null), all_laps_data)
if (length(valid_laps_data) > 0) {
  all_laps_df <- bind_rows(valid_laps_data)

  # Save the results to a CSV file
  laps_file_path <- file.path(laps_data_dir, paste0("laps_", year, ".csv"))
  cat("Saving laps data to", laps_file_path, "\n")
  write.csv(all_laps_df, file = laps_file_path, row.names = FALSE)
  cat("Laps data saved successfully.\n")
} else {
  cat("No valid lap data fetched.\n")
}