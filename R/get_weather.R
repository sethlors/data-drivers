library(lubridate)
library(dplyr)
library(httr)
library(jsonlite)

get_weather <- function(meeting_key = NULL, session_key = NULL) {
  
  base_url <- "https://api.openf1.org/v1/weather"
  query_params <- list()
  
  if (!is.null(meeting_key)) query_params$meeting_key <- paste(meeting_key, collapse = ",")
  if (!is.null(session_key)) query_params$session_key <- paste(session_key, collapse = ",")
  
  # Ensure at least one driver_number and one session_key are provided
  #if (is.null(driver_number) | is.null(session_key) | is.null(meeting_key)) {
    #stop("Error: You must provide at least one driver_number, session_key, or meeting_key.")
  #}
  
  
  # Send GET request with error handling
  response <- tryCatch(
    GET(base_url, query = query_params, timeout(60)),
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
    df$date <- as.POSIXct(df$date, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
    
    df <- df %>%
      arrange(session_key, date) %>%
      group_by(session_key) %>%
      mutate(time_diff = round(as.numeric(difftime(date, lag(date), units = "secs")), 3))
    
    return(df)
  } else {
    message("No weather found for the given parameters.")
    return(NULL)
  }
}

#weather <- get_weather()
