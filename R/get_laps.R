

library(lubridate)
library(dplyr)
library(httr)
library(jsonlite)
library(data.table)

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
    # Convert to data.table
    dt <- as.data.table(parsed_data)
    
    # Convert 'date_start' to POSIXct while keeping milliseconds
    dt[, date_start := as.POSIXct(date_start, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")]
    
    # Sort by driver_number and date_start for correct time difference calculation
    setorder(dt, driver_number, date_start)
    
    setnames(dt, "date_start", "date")
    dt[, lap_start_timestamp := date]
    
    # Compute time difference between consecutive pit stops (rounded to milliseconds)
    #dt[, time_diff := round(as.numeric(difftime(date_start, shift(date_start), units = "secs")), 3), 
    #   by = driver_number]
    
    # Rename columns: date_start -> lap_start, lap_duration -> prev_lap_duration
    #setnames(dt, c("date_start", "lap_duration"), c("lap_start", "prev_lap_duration"))
    
    #dt[, lapstart_timestamp := lap_start]
    
    #setkey(lap_data, driver_number, session_key, lap_start)
    
    return(dt)
  } else {
    message("No lap data found for the given parameters.")
    return(NULL)
  }
}

# Example query
#laps <- get_laps(session_key = 9165)

#str(laps)
