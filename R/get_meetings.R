

# Load necessary libraries
library(httr)
library(jsonlite)

# Function to get meeting data from OpenF1 API
get_meetings <- function(circuit_key = NULL, meeting_key = NULL, country_code = NULL, country_key = NULL, country_name = NULL,
                        location = NULL, year = NULL) {
  
  # Construct base API URL
  base_url <- "https://api.openf1.org/v1/meetings"
  query_params <- list()
  
  # Add optional filters if provided
  
  if (!is.null(circuit_key)) query_params$circuit_key <- paste(circuit_key, collapse = ",")
  if (!is.null(meeting_key)) query_params$meeting_key <- paste(meeting_key, collapse = ",")
  if (!is.null(country_code)) query_params$country_code <- paste(country_code, collapse = ",")
  if (!is.null(country_key)) query_params$country_key <- paste(country_key, collapse = ",")
  if (!is.null(country_name)) query_params$country_name <- paste(country_name, collapse = ",")
  if (!is.null(location)) query_params$location <- paste(location, collapse = ",")
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
    stop("Error: API request failed")
  }
  
  # Parse JSON response
  parsed_data <- fromJSON(content(response, "text"), flatten = TRUE)
  
  # Convert to DataFrame
  if (length(parsed_data) > 0) {
    df <- as.data.frame(parsed_data, stringsAsFactors = FALSE)
    
    
    # Convert date column to proper datetime format with milliseconds
    df$date_start <- as.POSIXct(df$date_start, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
    
    # Rename date_start to meeting_start for easier clarity when joining to other tables
    df <- df %>% rename(meeting_start = date_start)
    
    return(df)
  } else {
    message("No meeting data found for the given parameters.")
    return(NULL)
  }
}


meetings <- get_meetings()



