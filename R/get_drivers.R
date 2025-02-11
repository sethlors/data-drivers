

library(httr)
library(jsonlite)

get_drivers <- function(driver_number = NULL, meeting_key = NULL, session_key = NULL, first_name = NULL, 
                        last_name = NULL, full_name = NULL, team_name = NULL, country_code = NULL, name_acronym = NULL) {
  
  # Construct the base API URL
  base_url <- "https://api.openf1.org/v1/drivers"
  query_params <- list()
  
  # Add optional filters
  if (!is.null(driver_number)) query_params$driver_number <- paste(driver_number, collapse = ",")
  if (!is.null(meeting_key)) query_params$meeting_key <- paste(meeting_key, collapse = ",")
  if (!is.null(session_key)) query_params$session_key <- paste(session_key, collapse = ",")
  
  if (!is.null(first_name)) query_params$first_name <- paste(first_name, collapse = ",")
  if (!is.null(last_name)) query_params$last_name <- paste(last_name, collapse = ",")
  if (!is.null(full_name)) query_params$full_name <- paste(full_name, collapse = ",")
  
  if (!is.null(team_name)) query_params$team_name <- paste(team_name, collapse = ",")
  if (!is.null(country_code)) query_params$last_name <- paste(last_name, collapse = ",")
  if (!is.null(name_acronym)) query_params$name_acronym <- paste(name_acronym, collapse = ",")
  
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
    message("No driver data found for the given parameters.")
    return(NULL)
  }
}

