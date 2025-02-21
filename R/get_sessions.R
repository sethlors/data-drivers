

library(lubridate)
library(dplyr)
library(httr)
library(jsonlite)
library(data.table)

get_sessions <- function(meeting_key = NULL, session_key = NULL, circuit_key = NULL, country_code = NULL, 
                         country_key = NULL, country_name = NULL, location = NULL, session_name = NULL, 
                         session_type = NULL, year = NULL) {
  
  
  base_url <- "https://api.openf1.org/v1/sessions"
  query_params <- list()
  
  # Add optional filters if provided
  if (!is.null(meeting_key)) query_params$meeting_key <- paste(meeting_key, collapse = ",")
  if (!is.null(session_key)) query_params$session_key <- paste(session_key, collapse = ",")
  if (!is.null(circuit_key)) query_params$circuit_key <- paste(circuit_key, collapse = ",")
  if (!is.null(country_code)) query_params$country_code <- paste(country_code, collapse = ",")
  if (!is.null(country_key)) query_params$country_key <- paste(country_key, collapse = ",")
  if (!is.null(country_name)) query_params$country_name <- paste(country_name, collapse = ",")
  if (!is.null(location)) query_params$location <- paste(location, collapse = ",")
  if (!is.null(session_name)) query_params$session_name <- paste(session_name, collapse = ",")
  if (!is.null(session_type)) query_params$session_type <- paste(session_type, collapse = ",")
  if (!is.null(year)) query_params$year <- paste(year, collapse = ",")
  
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
    
    dt[, date_start := ymd_hms(date_start, tz = "UTC")]
    dt[, date_end := ymd_hms(date_end, tz = "UTC")]
    
    setnames(dt, "date_start", "session_start")
    setnames(dt, "date_end", "session_end")
    
    dt <- dt[order(session_start)]
    
    setkey(dt, session_key, meeting_key)
    
    return(dt)
  } else {
    message("No session data found for the given parameters.")
    return(NULL)
  }
}


#sessions <- get_sessions()
