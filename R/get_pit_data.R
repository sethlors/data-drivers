
library(lubridate)
library(dplyr)
library(httr)
library(jsonlite)
library(data.table)

# Function to get pit data from OpenF1 API with optional filters
get_pit_data <- function(driver_number = NULL, meeting_key = NULL, session_key = NULL, 
                         lap_number = NULL, pit_duration = NULL) {
  
  # Construct base API URL
  base_url <- "https://api.openf1.org/v1/pit"
  query_params <- list()
  
  # Add optional filters if provided
  if (!is.null(driver_number)) query_params$driver_number <- paste(driver_number, collapse = ",")
  if (!is.null(meeting_key)) query_params$meeting_key <- paste(meeting_key, collapse = ",")
  if (!is.null(session_key)) query_params$session_key <- paste(session_key, collapse = ",")
  if (!is.null(lap_number)) query_params$lap_number <- paste(lap_number, collapse = ",")
  if (!is.null(pit_duration)) query_params$pit_duration <- paste(pit_duration, collapse = ",")
  
  # Send GET request with error handling
  response <- tryCatch(
    GET(base_url, query = query_params, timeout(30)),
    error = function(e) {
      message("Error: API request failed. Please check your filters.")
      return(NULL)
    }
  )
  
  # Check for valid response
  if (is.null(response) || status_code(response) != 200) {
    stop("Error: API request failed. Check the provided parameters.")
  }
  
  # Parse JSON response
  parsed_data <- fromJSON(content(response, "text"), flatten = TRUE)
  
  # Convert to DataFrame
  if (length(parsed_data) > 0) {
    
    dt <- as.data.table(parsed_data)
    
    
    dt[, date := ymd_hms(date, tz = "UTC")]
    
    dt[, pit_date := date]
    
    #setnames(dt, "date", "pit_date")
    
    
    # Sort and compute time differences
    dt <- dt[order(driver_number, date)]
    
    # Calculate time difference in seconds (rounded to milliseconds)
    #dt[, time_diff := round(as.numeric(difftime(date, shift(date), units = "secs")), 3), 
    #   by = driver_number]
    
    setkey(dt, session_key, meeting_key, driver_number, lap_number)
    
    return(dt)
    
  } else {
    message("No pit stop data found for the given parameters.")
    return(NULL)
  }
}

#pit <- get_pit_data(meeting_key = 1219, driver_number = 1, session_key = 9165)


