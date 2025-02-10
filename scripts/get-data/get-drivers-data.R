# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set year
year <- 2023

# Define directories
raw_data_dir <- here::here("data", "raw-data")
drivers_data_dir <- file.path(raw_data_dir, "drivers-data")

# Ensure directories exist
cat(Sys.time(), "- Ensuring drivers data directory exists...\n")
dir.create(drivers_data_dir, recursive = TRUE, showWarnings = FALSE)

# Ensure sessions_df exists
if (!exists("sessions_df")) {
  stop(Sys.time(), "- ERROR: sessions_df is missing. Make sure to run `get-sessions-data.R` first.\n")
}
cat(Sys.time(), "- sessions_df exists, proceeding...\n")

# Function to fetch driver data for a session
get_drivers_for_session <- function(session_key) {
  url <- paste0("https://api.openf1.org/v1/drivers?session_key=", session_key)
  cat(Sys.time(), "- Fetching driver data for session key:", session_key, "\n")

  for (attempt in 1:3) {
    response <- GET(url)
    if (status_code(response) == 200) {
      cat(Sys.time(), "- Driver data fetched successfully for session key:", session_key, "\n")
      return(fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE))
    } else {
      cat(Sys.time(), "- WARNING: Attempt", attempt, "- Failed to fetch driver data for session key:", session_key, "Status code:", status_code(response), "\n")
    }
    Sys.sleep(3)  # Wait before retrying
  }

  cat(Sys.time(), "- ERROR: Failed to fetch driver data for session key:", session_key, "after 3 attempts.\n")
  return(NULL)
}

# Fetch all drivers
cat(Sys.time(), "- Fetching driver data for all sessions...\n")
all_drivers_data <- lapply(sessions_df$session_key, get_drivers_for_session)
cat(Sys.time(), "- Filtering out unsuccessful fetches and binding data...\n")
all_drivers_df <- bind_rows(Filter(Negate(is.null), all_drivers_data))

# Save results
if (nrow(all_drivers_df) > 0) {
  drivers_file_path <- file.path(drivers_data_dir, paste0("drivers_", year, ".csv"))
  cat(Sys.time(), "- Saving driver data to", drivers_file_path, "\n")
  write.csv(all_drivers_df, file = drivers_file_path, row.names = FALSE)
  message("Driver data saved to ", drivers_file_path)
} else {
  cat(Sys.time(), "- No driver data fetched.\n")
}