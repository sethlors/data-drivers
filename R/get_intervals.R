

library(httr)
library(jsonlite)

get_intervals <- function(driver_number = NULL, meeting_key = NULL, session_key = NULL, gap_to_leader = NULL, interval = NULL) {
  
  
  if (is.null(driver_number) & is.null(meeting_key) & is.null(session_key)) {
    stop("Error: You must provide at least one of driver_number, meeting_key, or session_key.")
  }
  
  # Construct the base API URL
  base_url <- "https://api.openf1.org/v1/intervals"
  query_params <- list()
  
  # Add optional filters
  if (!is.null(driver_number)) query_params$driver_number <- paste(driver_number, collapse = ",")
  if (!is.null(meeting_key)) query_params$meeting_key <- paste(meeting_key, collapse = ",")
  if (!is.null(session_key)) query_params$session_key <- paste(session_key, collapse = ",")
  
  if (!is.null(gap_to_leader)) query_params$gap_to_leader <- paste(gap_to_leader, collapse = ",")
  if (!is.null(interval)) query_params$interval <- paste(interval, collapse = ",")
 
  # Send GET request with error handling
  response <- tryCatch({
    GET(base_url, query = query_params, timeout(30))
  }, error = function(e) {
    message("Error: API request failed. Please check your filters.")
    return(NULL)
  })
  
  # Check for valid response
  if (is.null(response) || status_code(response) != 200) {
    stop("Error: API request failed. Check session_key, driver_number, or meeting_key.")
  }
  
  # Parse JSON response
  parsed_data <- fromJSON(content(response, "text"), flatten = TRUE)
  
  # Convert to DataFrame
  if (length(parsed_data) > 0) {
    df <- as.data.frame(parsed_data, stringsAsFactors = FALSE)
    return(df)
  } else {
    message("No interval data found for the given parameters.")
    return(NULL)
  }
}

