

library(lubridate)
library(dplyr)
library(httr)
library(jsonlite)

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
    df <- as.data.frame(parsed_data, stringsAsFactors = FALSE)
    
    # Convert date column to proper datetime format with milliseconds
    df$date_start <- as.POSIXct(df$date_start, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
    df$date_end <- as.POSIXct(df$date_end, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
    
    df <- df %>% rename(session_start = date_start, session_end = date_end)
    
    #df <- df %>%
    #arrange(driver_number, date) %>%
    #group_by(driver_number) %>%
    #mutate(time_diff = round(as.numeric(difftime(date, lag(date), units = "secs")), 3))
    
    return(df)
  } else {
    message("No session data found for the given parameters.")
    return(NULL)
  }
}


sessions <- get_sessions()
