# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set year
year <- 2023

# Define directories
raw_data_dir <- here::here("data", "raw-data")
sessions_data_dir <- file.path(raw_data_dir, "sessions-data")
weather_data_dir <- file.path(raw_data_dir, "weather-data")

# Ensure the weather-data subdirectory exists
cat(Sys.time(), "- Ensuring weather data directory exists...\n")
dir.create(weather_data_dir, recursive = TRUE, showWarnings = FALSE)

# Load the sessions data
sessions_file_path <- file.path(sessions_data_dir, paste0("sessions_", year, ".csv"))
if (!file.exists(sessions_file_path)) stop("ERROR: Sessions data file not found!")

cat(Sys.time(), "- Loading sessions data from", sessions_file_path, "\n")
sessions_df <- read.csv(sessions_file_path)

# Function to fetch weather data for a session
get_weather_for_meeting <- function(meeting_key) {
  url <- paste0("https://api.openf1.org/v1/weather?meeting_key=", meeting_key)
  cat(Sys.time(), "- Fetching weather data for meeting key:", meeting_key, "\n")

  for (attempt in 1:3) {
    response <- GET(url)
    if (status_code(response) == 200) {
      cat(Sys.time(), "- Weather data fetched successfully for meeting key:", meeting_key, "\n")
      return(fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE))
    } else {
      cat(Sys.time(), "- WARNING: Attempt", attempt, "- Failed to fetch weather data for meeting key:", meeting_key, "Status code:", status_code(response), "\n")
    }
    Sys.sleep(3)  # Wait before retrying
  }

  cat(Sys.time(), "- ERROR: Failed to fetch weather data for meeting key:", meeting_key, "after 3 attempts.\n")
  return(NULL)
}

# Fetch weather data for all sessions
cat(Sys.time(), "- Fetching weather data for all sessions...\n")
all_weather_data <- lapply(sessions_df$meeting_key, get_weather_for_meeting)

# Filter out unsuccessful fetches and bind the data into a single data frame
cat(Sys.time(), "- Filtering out unsuccessful fetches and binding data...\n")
valid_weather_data <- Filter(Negate(is.null), all_weather_data)

if (length(valid_weather_data) > 0) {
  all_weather_df <- bind_rows(valid_weather_data)

  if (nrow(all_weather_df) > 0) {
    weather_file_path <- file.path(weather_data_dir, paste0("weather_", year, ".csv"))
    write.csv(all_weather_df, file = weather_file_path, row.names = FALSE)
    cat(Sys.time(), "- Weather data saved successfully to", weather_file_path, "\n")
  } else {
    cat(Sys.time(), "- No valid weather data to save.\n")
  }
} else {
  cat(Sys.time(), "- No weather data fetched.\n")
}