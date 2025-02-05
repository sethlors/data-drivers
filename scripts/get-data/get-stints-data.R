# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set the year
year <- 2024

# Define directories
raw_data_dir <- here::here("data", "raw-data")
stints_data_dir <- file.path(raw_data_dir, "stints-data")

# Ensure directories exist
dir.create(stints_data_dir, recursive = TRUE, showWarnings = FALSE)

# Ensure sessions_df exists
if (!exists("sessions_df")) {
  stop("sessions_df is missing. Make sure to run `get-sessions-data.R` first.")
}

# Ensure drivers_df is available
drivers_file <- file.path(raw_data_dir, "drivers-data", paste0("drivers_", year, ".csv"))

if (!file.exists(drivers_file)) {
  stop("Drivers data file not found. Run `get-drivers-data.R` first.")
}

drivers_df <- read.csv(drivers_file)

# Function to fetch stint data
get_stints_for_session <- function(session_key) {
  url <- paste0("https://api.openf1.org/v1/stints?session_key=", session_key)

  for (attempt in 1:3) {
    response <- GET(url)
    if (status_code(response) == 200) {
      return(fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE))
    }
    Sys.sleep(3)
  }

  return(NULL)
}

# Fetch all stints
all_stints_data <- lapply(sessions_df$session_key, get_stints_for_session)
all_stints_df <- bind_rows(Filter(Negate(is.null), all_stints_data))

# Save results
if (nrow(all_stints_df) > 0) {
  stints_file_path <- file.path(stints_data_dir, paste0("stints_", year, ".csv"))
  write.csv(all_stints_df, file = stints_file_path, row.names = FALSE)
  message("Stints data saved to ", stints_file_path)
} else {
  message("No stints data fetched.")
}