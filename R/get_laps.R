

library(lubridate)
library(dplyr)
library(httr)
library(jsonlite)

# Function to get all lap data or filter by driver_number, meeting_key, session_key, or lap_number
get_laps <- function(driver_number = NULL, meeting_key = NULL, session_key = NULL, lap_number = NULL, is_pit_out_lap = NULL) {
  
  
  if (is.null(driver_number) & is.null(meeting_key) & is.null(session_key)) {
    stop("Error: You must provide at least one of driver_number, meeting_key, or session_key.")
  }
  
  # Construct the base API URL
  base_url <- "https://api.openf1.org/v1/laps"
  query_params <- list()
  
  # Add optional filters
  if (!is.null(driver_number)) query_params$driver_number <- paste(driver_number, collapse = ",")
  if (!is.null(meeting_key)) query_params$meeting_key <- paste(meeting_key, collapse = ",")
  if (!is.null(session_key)) query_params$session_key <- paste(session_key, collapse = ",")
  if (!is.null(lap_number)) query_params$lap_number <- paste(lap_number, collapse = ",")
  
  # Ensure is_pit_out_lap is properly filtered as a boolean
  if (!is.null(is_pit_out_lap)) {
    if (!is.logical(is_pit_out_lap)) {
      stop("Error: is_pit_out_lap must be a boolean (TRUE or FALSE).")
    }
    query_params$is_pit_out_lap <- tolower(as.character(is_pit_out_lap))  # Convert to "true"/"false" for API
  }
  
  # Send GET request with error handling
  response <- tryCatch({
    GET(base_url, query = query_params, timeout(30))
  }, error = function(e) {
    message("Error: API request failed. Please check your filters.")
    return(NULL)
  })
  
  # Check for valid response
  if (is.null(response) || status_code(response) != 200) {
    stop("Error: API request failed. Check session_key, driver_number, meeting_key, or lap_number.")
  }
  
  # Parse JSON response
  parsed_data <- fromJSON(content(response, "text"), flatten = TRUE)
  
  # Convert to DataFrame
  if (length(parsed_data) > 0) {
    df <- as.data.frame(parsed_data, stringsAsFactors = FALSE)
    
    # Convert 'date' column to POSIXct while keeping milliseconds
    df$date_start <- as.POSIXct(df$date_start, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
    
    # Compute time difference between consecutive pit stops in milliseconds
    df <- df %>%
      arrange(driver_number, date_start) %>%
      group_by(driver_number) %>%
      mutate(time_diff = round(as.numeric(difftime(date_start, lag(date_start), units = "secs")), 3)) %>%
      rename(lap_start = date_start, prev_lap_duration = lap_duration)
    
    return(df)
  } else {
    message("No lap data found for the given parameters.")
    return(NULL)
  }
}

# Example query
laps <- get_laps(driver_number = 63, meeting_key = 1219)

#str(laps)
