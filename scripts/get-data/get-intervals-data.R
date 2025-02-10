# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set year
year <- 2023

# Define directories
raw_data_dir <- here::here("data", "raw-data")
sessions_data_dir <- file.path(raw_data_dir, "sessions-data")
intervals_data_dir <- file.path(raw_data_dir, "intervals-data")

# Ensure the intervals-data subdirectory exists
cat("Ensuring intervals data directory exists...\n")
dir.create(intervals_data_dir, recursive = TRUE, showWarnings = FALSE)

# Load the sessions data
sessions_file_path <- file.path(sessions_data_dir, paste0("sessions_", year, ".csv"))
if (!file.exists(sessions_file_path)) stop("Sessions data file not found")

cat("Loading sessions data...\n")
sessions_df <- read.csv(sessions_file_path, stringsAsFactors = FALSE, na.strings = c("", "NA"))

# Function to fetch interval data for a session
get_intervals_for_session <- function(session_key) {
  url <- paste0("https://api.openf1.org/v1/intervals?session_key=", session_key)

  for (attempt in 1:3) {
    cat("Fetching interval data for session:", session_key, "Attempt:", attempt, "\n")
    response <- GET(url)
    if (status_code(response) == 200) {
      cat("Data fetched successfully for session:", session_key, "\n")
      return(fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE))
    }
    cat("Failed attempt", attempt, "for session:", session_key, "\n")
    Sys.sleep(3)
  }
  cat("Failed to fetch data for session:", session_key, "\n")
  return(NULL)
}

# Fetch interval data for all sessions
cat("Fetching interval data for all sessions...\n")
all_intervals_data <- lapply(sessions_df$session_key, get_intervals_for_session)

# Standardize 'interval' and 'gap_to_leader' columns to numeric
cat("Standardizing interval and gap_to_leader column data types...\n")
all_intervals_data <- lapply(all_intervals_data, function(df) {
  if (!is.null(df)) {
    if ("interval" %in% names(df)) {
      df$interval <- suppressWarnings(as.numeric(df$interval))
    }
    if ("gap_to_leader" %in% names(df)) {
      df$gap_to_leader <- suppressWarnings(as.numeric(df$gap_to_leader))
    }
  }
  return(df)
})

# Filter out unsuccessful fetches and bind the data into a single data frame
cat("Binding data...\n")
all_intervals_df <- bind_rows(Filter(Negate(is.null), all_intervals_data))

# Save the results to a CSV file
if (nrow(all_intervals_df) > 0) {
  intervals_file_path <- file.path(intervals_data_dir, paste0("intervals_", year, ".csv"))
  cat("Saving intervals data to", intervals_file_path, "\n")
  write.csv(all_intervals_df, file = intervals_file_path, row.names = FALSE)
  cat("Intervals data saved successfully.\n")
} else {
  cat("No valid interval data fetched.\n")
}