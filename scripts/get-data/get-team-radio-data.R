# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set year
year <- 2023

# Define directories
raw_data_dir <- here::here("data", "raw-data")
sessions_data_dir <- file.path(raw_data_dir, "sessions-data")
team_radio_data_dir <- file.path(raw_data_dir, "team-radio-data")

# Ensure the team-radio-data subdirectory exists
cat(Sys.time(), "- Ensuring team radio data directory exists...\n")
dir.create(team_radio_data_dir, recursive = TRUE, showWarnings = FALSE)

# Load the sessions data
sessions_file_path <- file.path(sessions_data_dir, paste0("sessions_", year, ".csv"))
if (!file.exists(sessions_file_path)) stop("ERROR: Sessions data file not found!")

cat(Sys.time(), "- Loading sessions data from", sessions_file_path, "\n")
sessions_df <- read.csv(sessions_file_path)

# Function to fetch team radio data for a session
get_team_radio_for_session <- function(session_key) {
  url <- paste0("https://api.openf1.org/v1/team_radio?session_key=", session_key)
  cat(Sys.time(), "- Fetching team radio data for session key:", session_key, "\n")

  for (attempt in 1:3) {
    response <- GET(url)
    if (status_code(response) == 200) {
      cat(Sys.time(), "- Team radio data fetched successfully for session key:", session_key, "\n")
      return(fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE))
    } else {
      cat(Sys.time(), "- WARNING: Attempt", attempt, "- Failed to fetch team radio data for session key:", session_key, "Status code:", status_code(response), "\n")
    }
    Sys.sleep(3)  # Wait before retrying
  }

  cat(Sys.time(), "- ERROR: Failed to fetch team radio data for session key:", session_key, "after 3 attempts.\n")
  return(NULL)
}

# Fetch team radio data for all sessions
cat(Sys.time(), "- Fetching team radio data for all sessions...\n")
all_team_radio_data <- lapply(sessions_df$session_key, get_team_radio_for_session)

# Filter out unsuccessful fetches and bind the data into a single data frame
cat(Sys.time(), "- Filtering out unsuccessful fetches and binding data...\n")
valid_team_radio_data <- Filter(Negate(is.null), all_team_radio_data)

if (length(valid_team_radio_data) > 0) {
  all_team_radio_df <- bind_rows(valid_team_radio_data)

  if (nrow(all_team_radio_df) > 0) {
    team_radio_file_path <- file.path(team_radio_data_dir, paste0("team_radio_", year, ".csv"))
    write.csv(all_team_radio_df, file = team_radio_file_path, row.names = FALSE)
    cat(Sys.time(), "- Team radio data saved successfully to", team_radio_file_path, "\n")
  } else {
    cat(Sys.time(), "- No valid team radio data to save.\n")
  }
} else {
  cat(Sys.time(), "- No team radio data fetched.\n")
}