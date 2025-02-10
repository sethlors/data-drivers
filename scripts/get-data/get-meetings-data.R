# Load necessary libraries
source(here::here("scripts", "dependencies", "load-libraries.R"))

# Set the year
year <- 2023

# Define directories
raw_data_dir <- here::here("data", "raw-data")
meetings_data_dir <- file.path(raw_data_dir, "meetings-data")

# Ensure the meetings-data subdirectory exists
cat("Ensuring meetings data directory exists...\n")
dir.create(meetings_data_dir, recursive = TRUE, showWarnings = FALSE)

# Function to fetch meetings data for a given year
get_meetings <- function(year) {
  url <- paste0("https://api.openf1.org/v1/meetings?year=", year)
  cat("Fetching meetings data for year:", year, "\n")
  response <- GET(url)

  if (status_code(response) != 200) {
    stop(paste("API request failed for year:", year, "Status:", status_code(response)))
  }

  cat("API request successful. Parsing response...\n")
  meetings_data <- content(response, "text", encoding = "UTF-8")

  if (!startsWith(meetings_data, "[")) {
    stop("Invalid JSON response. Expected an array of meetings.")
  }

  meetings_df <- fromJSON(meetings_data, flatten = TRUE)

  if (length(meetings_df) == 0) {
    stop("No meetings data found for the specified year.")
  }

  file_path <- file.path(meetings_data_dir, paste0("meetings_", year, ".csv"))
  cat("Saving meetings data to", file_path, "\n")
  write.csv(meetings_df, file = file_path, row.names = FALSE)

  cat("Meetings data saved successfully to", file_path, "\n")
  return(meetings_df)
}

# Fetch the meetings data
cat("Fetching and saving meetings data...\n")
meetings_df <- get_meetings(year)

# Display the first few rows of the fetched data
cat("Displaying first few rows of the fetched meetings data:\n")
head(meetings_df)