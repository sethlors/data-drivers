
library(lubridate)
library(dplyr)
library(httr)
library(jsonlite)

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
    df <- as.data.frame(parsed_data, stringsAsFactors = FALSE)
    
    # Convert 'date' column to POSIXct while keeping milliseconds
    df$date <- as.POSIXct(df$date, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
    
    # Compute time difference between consecutive pit stops in milliseconds
    df <- df %>%
      arrange(driver_number, date) %>%
      group_by(driver_number) %>%
      mutate(time_diff = round(as.numeric(difftime(date, lag(date), units = "secs")), 3))
    
    
    return(df)
  } else {
    message("No pit stop data found for the given parameters.")
    return(NULL)
  }
  
  
  
}



