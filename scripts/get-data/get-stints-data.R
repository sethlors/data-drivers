# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set the year
year <- 2023

# Define directories
raw_data_dir <- here::here("data", "raw-data")
stints_data_dir <- file.path(raw_data_dir, "stints-data")

# Ensure directories exist
cat(Sys.time(), "- Ensuring stints data directory exists...\n")
dir.create(stints_data_dir, recursive = TRUE, showWarnings = FALSE)

# Ensure sessions_df exists
if (!exists("sessions_df")) {
  stop("ERROR: sessions_df is missing. Make sure to run `get-sessions-data.R` first.")
}

# Ensure drivers_df is available
drivers_file <- file.path(raw_data_dir, "drivers-data", paste0("drivers_", year, ".csv"))

if (!file.exists(drivers_file)) {
  stop("ERROR: Drivers data file not found. Run `get-drivers-data.R` first.")
}

cat(Sys.time(), "- Loading drivers data from", drivers_file, "\n")
drivers_df <- read.csv(drivers_file)

# Function to fetch stint data
get_stints_for_session <- function(session_key) {
  url <- paste0("https://api.openf1.org/v1/stints?session_key=", session_key)
  cat(Sys.time(), "- Fetching stints data for session key:", session_key, "\n")

  for (attempt in 1:3) {
    response <- GET(url)
    if (status_code(response) == 200) {
      cat(Sys.time(), "- Stints data fetched successfully for session key:", session_key, "\n")
      return(fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE))
    } else {
      cat(Sys.time(), "- WARNING: Attempt", attempt, "- Failed to fetch stints data for session key:", session_key, "Status code:", status_code(response), "\n")
    }
    Sys.sleep(3)
  }

  cat(Sys.time(), "- ERROR: Failed to fetch stints data for session key:", session_key, "after 3 attempts.\n")
  return(NULL)
}

# Fetch all stints
cat(Sys.time(), "- Fetching stints data for all sessions...\n")
all_stints_data <- lapply(sessions_df$session_key, get_stints_for_session)

# Filter out NULL responses
cat(Sys.time(), "- Filtering out unsuccessful fetches and binding data...\n")
valid_stints_data <- Filter(Negate(is.null), all_stints_data)

# Bind data if available
if (length(valid_stints_data) > 0) {
  all_stints_df <- bind_rows(valid_stints_data)

  if (nrow(all_stints_df) > 0) {
    stints_file_path <- file.path(stints_data_dir, paste0("stints_", year, ".csv"))
    write.csv(all_stints_df, file = stints_file_path, row.names = FALSE)
    cat(Sys.time(), "- Stints data saved successfully to", stints_file_path, "\n")
  } else {
    cat(Sys.time(), "- No valid stints data to save.\n")
  }
} else {
  cat(Sys.time(), "- No stints data fetched.\n")
}