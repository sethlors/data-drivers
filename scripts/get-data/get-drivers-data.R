# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set year
year <- 2024

# Define directories
raw_data_dir <- here::here("data", "raw-data")
drivers_data_dir <- file.path(raw_data_dir, "drivers-data")

# Ensure directories exist
dir.create(drivers_data_dir, recursive = TRUE, showWarnings = FALSE)

# Ensure sessions_df exists
if (!exists("sessions_df")) {
  stop("sessions_df is missing. Make sure to run `get-sessions-data.R` first.")
}

# Function to fetch driver data for a session
get_drivers_for_session <- function(session_key) {
  url <- paste0("https://api.openf1.org/v1/drivers?session_key=", session_key)

  for (attempt in 1:3) {
    response <- GET(url)
    if (status_code(response) == 200) {
      return(fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE))
    }
    Sys.sleep(3)
  }

  return(NULL)
}

# Fetch all drivers
all_drivers_data <- lapply(sessions_df$session_key, get_drivers_for_session)
all_drivers_df <- bind_rows(Filter(Negate(is.null), all_drivers_data))

# Save results
if (nrow(all_drivers_df) > 0) {
  drivers_file_path <- file.path(drivers_data_dir, paste0("drivers_", year, ".csv"))
  write.csv(all_drivers_df, file = drivers_file_path, row.names = FALSE)
  message("Driver data saved to ", drivers_file_path)
} else {
  message("No driver data fetched.")
}