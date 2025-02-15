

library(lubridate)
library(dplyr)
library(httr)
library(jsonlite)


# Function to collect car data from OpenF1 API
get_car_data <- function(driver_number = NULL, meeting_key = NULL, session_key = NULL, 
                         n_gear = NULL, speed = NULL, throttle = NULL, rpm = NULL) {
  
  # Ensure at least one driver_number and one session_key are provided
  if (is.null(driver_number) || is.null(session_key)) {
    stop("Error: You must provide at least one driver_number and one session_key.")
  }
  
  # Construct the API URL dynamically
  base_url <- "https://api.openf1.org/v1/car_data"
  query_params <- list()
  
  # Add parameters if they are provided
  if (!is.null(driver_number)) query_params$driver_number <- paste(driver_number, collapse = ",")
  if (!is.null(meeting_key)) query_params$meeting_key <- paste(meeting_key, collapse = ",")
  if (!is.null(session_key)) query_params$session_key <- paste(session_key, collapse = ",")
  if (!is.null(n_gear)) query_params$n_gear <- n_gear
  if (!is.null(speed)) query_params$speed <- speed
  if (!is.null(throttle)) query_params$throttle <- throttle
  if (!is.null(rpm)) query_params$rpm <- rpm
  
  # Send GET request with timeout handling
  response <- tryCatch({
    GET(base_url, query = query_params, timeout(30))  # Increase timeout to 30s
  }, error = function(e) {
    message("Error: API request timed out. Please try again later.")
    return(NULL)
  })
  
  # Check for valid response
  if (is.null(response) || status_code(response) != 200) {
    stop("Error: API request failed. Check session_key, driver_number, or meeting_key.")
  }
  
  # Parse JSON data
  parsed_data <- fromJSON(content(response, "text"), flatten = TRUE)
  
  # Convert to DataFrame
  if (length(parsed_data) > 0) {
    df <- as.data.frame(parsed_data, stringsAsFactors = FALSE)
    
    # Convert 'date' column to POSIXct while keeping milliseconds
    #df$date <- as.POSIXct(df$date, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
    df$date <- ymd_hms(df$date, tz = "UTC")
    
    # Compute time difference between consecutive pit stops in milliseconds
    df <- df %>%
      arrange(driver_number, date) %>%
      group_by(driver_number) %>%
      mutate(time_diff = round(as.numeric(difftime(date, lag(date), units = "secs")), 3))
    
    
    return(df)
  } else {
    message("No car data found for the given parameters.")
    return(NULL)
  }
}


