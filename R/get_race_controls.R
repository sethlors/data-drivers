

library(lubridate)
library(dplyr)
library(httr)
library(jsonlite)
library(data.table)

get_race_controls <- function(driver_number = NULL, meeting_key = NULL, session_key = NULL, category = NULL, 
                             lap_number = NULL, flag = NULL, scope = NULL, sector = NULL) {
  
  # Ensure at least one driver_number and one session_key are provided
  #if (is.null(driver_number) | is.null(session_key)) {
  #stop("Error: You must provide at least one driver_number and one session_key.")
  #}
  
  # Construct base API URL
  base_url <- "https://api.openf1.org/v1/race_control"
  query_params <- list()
  
  # Add optional filters if provided
  if (!is.null(driver_number)) query_params$driver_number <- paste(driver_number, collapse = ",")
  if (!is.null(meeting_key)) query_params$meeting_key <- paste(meeting_key, collapse = ",")
  if (!is.null(session_key)) query_params$session_key <- paste(session_key, collapse = ",")
  if (!is.null(category)) query_params$category <- paste(category, collapse = ",")
  if (!is.null(lap_number)) query_params$lap_number <- paste(lap_number, collapse = ",")
  if (!is.null(flag)) query_params$flag <- paste(flag, collapse = ",")
  if (!is.null(scope)) query_params$scope <- paste(scope, collapse = ",")
  if (!is.null(sector)) query_params$sector <- paste(sector, collapse = ",")
  
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
    
    dt[, race_control_timestamp := date]
    
    
    # Sort and compute time differences
    dt <- dt[order(date)]
    
    setnames(dt, "driver_number", "rc_driver_number")
    
    return(dt)
  } else {
    message("No race control data found for the given parameters.")
    return(NULL)
  }
}

#race_controls <- get_race_controls(session_key = 9078)


