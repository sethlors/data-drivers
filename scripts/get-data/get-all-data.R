# Load required packages
source(here::here("scripts", "dependencies", "install-packages.R"))

# Define year
year <- 2024

# Fetch session data first and store it in a variable
message("Fetching session data...")
sessions_df <- source(here::here("scripts", "get-data", "get-sessions-data.R"))$value

# Ensure sessions_df exists
if (!exists("sessions_df") || nrow(sessions_df) == 0) {
  stop("Session data could not be loaded. Exiting.")
}

# Fetch driver data using the sessions_df
message("Fetching driver data...")
source(here::here("scripts", "get-data", "get-drivers-data.R"), local = TRUE)

# Fetch stint data using the sessions_df
message("Fetching stint data...")
source(here::here("scripts", "get-data", "get-stints-data.R"), local = TRUE)

message("All data has been fetched and stored in data/raw-data.")