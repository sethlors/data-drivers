
library(httr)
library(jsonlite)

# Function to collect stint data from OpenF1 API
get_stints <- function(meeting_key = NULL, session_key = NULL, driver_number = NULL, 
                       lap_start = NULL, lap_end = NULL, compound = NULL, tyre_age_at_start = NULL) {
  
  # Construct the API URL dynamically
  base_url <- "https://api.openf1.org/v1/stints"
  query_params <- list()
  
  # Add optional filters if provided
  if (!is.null(session_key)) {
    query_params$session_key <- session_key
  }
  if (!is.null(tyre_age_at_start)) {
    query_params$tyre_age_at_start <- tyre_age_at_start
  }
  if (!is.null(driver_number)) {
    query_params$driver_number <- driver_number
  }
  if (!is.null(lap_start)) {
    query_params$lap_start <- lap_start
  }
  if (!is.null(lap_end)) {
    query_params$lap_end <- lap_end
  }
  if (!is.null(compound)) {
    query_params$compound <- compound
  }
  
  # Send GET request
  response <- GET(base_url, query = query_params)
  
  # Check for valid response
  if (status_code(response) != 200) {
    stop("Error: API request failed. Check session_key or parameters.")
  }
  
  # Parse JSON data
  parsed_data <- fromJSON(content(response, "text"), flatten = TRUE)
  
  # Convert JSON response into a DataFrame
  if (length(parsed_data) > 0) {
    df <- as.data.frame(parsed_data, stringsAsFactors = FALSE)
    return(df)
  } else {
    message("No stint data found for the given parameters.")
    return(NULL)
  }
}



