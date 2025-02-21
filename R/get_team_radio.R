library(lubridate)
library(dplyr)
library(httr)
library(jsonlite)
library(data.table)

get_team_radio <- function(meeting_key = NULL, session_key = NULL, driver_number = NULL) {
  
  base_url <- "https://api.openf1.org/v1/team_radio"
  query_params <- list()
  
  if (!is.null(meeting_key)) query_params$meeting_key <- paste(meeting_key, collapse = ",")
  if (!is.null(session_key)) query_params$session_key <- paste(session_key, collapse = ",")
  if (!is.null(driver_number)) query_params$driver_number <- paste(driver_number, collapse = ",")
  
  # Ensure at least one driver_number and one session_key are provided
  #if (is.null(driver_number) | is.null(session_key) | is.null(meeting_key)) {
  #stop("Error: You must provide at least one driver_number, session_key, or meeting_key.")
  #}
  
  
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
    
    dt[, team_radio_timestamp := date]
    
    dt <- dt[order(date)]
    
    return(dt)
    
    
  } else {
    message("No team radio data found for the given parameters.")
    return(NULL)
  }
}


#team_radio <- get_team_radio(driver_number = 1, session_key = 9078)


#team_radio <- get_team_radio()

