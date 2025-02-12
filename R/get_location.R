

library(lubridate)
library(dplyr)
library(httr)
library(jsonlite)

# Function to get location data
get_location <- function(driver_number = NULL, session_key = NULL, meeting_key = NULL) {
  
  # Construct the base API URL
  base_url <- "https://api.openf1.org/v1/location"
  query_params <- list()
  
  # Ensure at least one filter is provided
  if (is.null(driver_number) & is.null(session_key) & is.null(meeting_key)) {
    stop("Error: You must provide at least one of driver_number, session_key, or meeting_key.")
  }
  
  # Add optional filters if provided
  if (!is.null(driver_number)) query_params$driver_number <- paste(driver_number, collapse = ",")
  if (!is.null(session_key)) query_params$session_key <- paste(session_key, collapse = ",")
  if (!is.null(meeting_key)) query_params$meeting_key <- paste(meeting_key, collapse = ",")
  
  #if (!is.null(z)) query_params$z <- paste(z, collapse = ",")
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
    stop("Error: API request failed. Check session_key, driver_number, or meeting_key.")
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
      filter(x != 0, y != 0) %>%  # Exclude rows where x or y equals 0
      arrange(session_key, driver_number, date) %>%
      group_by(session_key, driver_number) %>%
      mutate(time_diff = round(as.numeric(difftime(date, lag(date), units = "secs")), 3))
    
    return(df)
  } else {
    message("No location data found for the given parameters.")
    return(NULL)
  }
}

# Example usage:
# Retrieve location data for driver 81 in session 9161 within a date range

#location_data <- get_location(driver_number = 81, session_key = 9161)




#library(ggplot2)

#if (!is.null(location_data)) {
  
  # Create a scatter plot of x and y coordinates
  #ggplot(location_data, aes(x = x, y = y)) +
    #geom_point(color = "blue", alpha = 0.5, size = 1) +  # Scatter plot points
    #geom_path(color = "red", alpha = 0.8) +  # Line connecting points to show movement
    #theme_minimal() +  # Use a clean theme
    #labs(title = "Driver's Location on Track",
         #x = "X Coordinate",
         #y = "Y Coordinate") +
    #theme(plot.title = element_text(hjust = 0.5))  # Center title
  
#} else {
  #print("No location data found for the given parameters.")
#}
