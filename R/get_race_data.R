library(data.table)

# Set working directory to the folder containing the scripts
setwd("/Users/maxwellskinner/Documents/GitHub/data-drivers/R")  # Replace with your actual path

# List all R script files in the directory
scripts <- list.files(pattern = "\\.R$", full.names = TRUE)

# Source scripts one by one to find the problematic one
for (script in scripts) {
  cat("Sourcing:", script, "\n")
  tryCatch({
    source(script)
  }, error = function(e) {
    cat("Error in", script, ":", e$message, "\n")
  })
}

# Source all scripts
lapply(scripts, source)


get_race_data <- function(driver_number, session_key, meeting_key,
                          include_car_details = FALSE,
                          include_interval_data = FALSE,
                          include_lap_data = FALSE,
                          include_location_data = FALSE,
                          include_position_data = FALSE, 
                          include_team_radio_data = FALSE, 
                          include_pit_data = FALSE,
                          include_stint_data = FALSE,
                          include_weather_data = FALSE,
                          include_race_control_data = FALSE) {
  
  options(digits.secs = 6)  # Ensure milliseconds are displayed
  
  # Load base driver data
  df <- copy(get_drivers(meeting_key = meeting_key, driver_number = driver_number, session_key = session_key))
  #cat("Loaded get_drivers():", nrow(df), "rows,", ncol(df), "columns\n")
  
  # Join with session and meeting data
  df <- get_sessions(session_key = session_key)[get_meetings(meeting_key = meeting_key)[df, on = "meeting_key", nomatch = 0], 
                                                on = c("session_key", "meeting_key"), nomatch = 0]
  #cat("After joining get_sessions and get_meetings:", nrow(df), "rows,", ncol(df), "columns\n")
  
  
  time_series_functions <- list(
    car_details = include_car_details,
    intervals = include_interval_data,
    laps = include_lap_data,
    location = include_location_data,
    position = include_position_data,
    team_radio = include_team_radio_data,
    weather = include_weather_data,
    race_controls = include_race_control_data
  )
  
  # Iterate through time series tables and join if flag is TRUE
  for (table_name in names(time_series_functions)) {
    if (time_series_functions[[table_name]]) {
      #message("Joining ", table_name)
      
      # Construct the function name
      func_name <- paste0("get_", table_name)
      
      # Record rows and columns before join
      #before_rows <- nrow(df)
      #before_cols <- ncol(df)
      
      # Special handling for weather and race_controls (no driver_number)
      if (table_name %in% c("weather", "race_controls")) {
        temp_data <- do.call(func_name, list(session_key = session_key))
        df <- temp_data[df, roll = TRUE, on = c("session_key", "meeting_key", "date")]
      } else {
        temp_data <- do.call(func_name, list(session_key = session_key, driver_number = driver_number))
        
        # Check for 'date' column before joining
        if ("date" %in% names(df) && "date" %in% names(temp_data)) {
          df <- temp_data[df, roll = TRUE, on = c("driver_number", "session_key", "meeting_key", "date")]
        } else {
          df <- temp_data[df, roll = TRUE, on = c("driver_number", "session_key", "meeting_key")]
        }
      }
      
      # Rows and columns after join
      #after_rows <- nrow(df)
      #after_cols <- ncol(df)
      
      #cat("After joining", table_name, ":", after_rows, "rows,", after_cols, "columns\n")
      #cat("Change: ", after_rows - before_rows, " rows,", after_cols - before_cols, " columns\n")
    }
  }
  
  # Handle pit_data with lap_number logic
  if (include_pit_data) {
    #message("Joining pit_data")
    #before_rows <- nrow(df)
    #before_cols <- ncol(df)
    
    df <- if ("lap_number" %in% names(df)) {
      get_pit_data(session_key = session_key, driver_number = driver_number)[
        df, on = c("session_key", "meeting_key", "driver_number", "lap_number"), nomatch = NA
      ]
    } else {
      get_pit_data(session_key = session_key, driver_number = driver_number)[
        df, on = c("session_key", "meeting_key", "driver_number"), nomatch = NA
      ]
    }
    
    #after_rows <- nrow(df)
    #after_cols <- ncol(df)
    #cat("After joining pit_data:", after_rows, "rows,", after_cols, "columns\n")
    #cat("Change: ", after_rows - before_rows, " rows,", after_cols - before_cols, " columns\n")
    
  }
  
  # Handle stint_data with lap range logic
  if (include_stint_data) {
    #message("Joining stint_data")
    #before_rows <- nrow(df)
    #before_cols <- ncol(df)
    
    df <- if ("lap_number" %in% names(df)) {
      df <- get_stints(session_key = session_key, driver_number = driver_number)[
        df, on = .(driver_number, meeting_key, session_key, lap_start <= lap_number, lap_end >= lap_number), nomatch = NA
      ]
      setnames(df, "lap_start", "lap_number")
      df[, c("lap_end") := NULL]
      
      #setnames(df, "lap_start", "lap_number")
      #setnames(df, "i.lap_start", "date")
      #df[, c("lap_end") := NULL]
      
    } else {
      get_stints(session_key = session_key, driver_number = driver_number)[
        df, on = .(driver_number, meeting_key, session_key), nomatch = NA
      ]
    }
    
    
    #after_rows <- nrow(df)
    #after_cols <- ncol(df)
    #cat("After joining stint_data:", after_rows, "rows,", after_cols, "columns\n")
    #cat("Change: ", after_rows - before_rows, " rows,", after_cols - before_cols, " columns\n")
  }
  
  # Remove columns starting with "i."
  #before_count <- ncol(df)
  i_cols <- grep("^i\\.", names(df), value = TRUE)
  
  if (length(i_cols) > 0) {
    df[, (i_cols) := NULL]
    #after_count <- ncol(df)
    #cat("Removed", length(i_cols), "'i.' columns. New column count:", after_count, "\n")
  } #else {
    #cat("No 'i.' columns found.\n")
  #}
  
  # Filter based on session_start and session_end
  if ("date" %in% names(df) && "session_start" %in% names(df) && "session_end" %in% names(df)) {
    
    # Count rows before filtering
    #before_filter_rows <- nrow(df)
    #cat("Number of rows before filtering:", before_filter_rows, "\n")
    
    # Apply the correct filter
    #df <- df[date >= session_start & date <= session_end]
    df <- df[driver_timestamp >= session_start]
    
    # Count rows after filtering
    #after_filter_rows <- nrow(df)
    #cat("Number of rows after filtering:", after_filter_rows, "\n")
    
    # Report the number of rows filtered out
    #message("Filtered out ", before_filter_rows - after_filter_rows, " rows outside session boundaries.")
  }
  
  return(df)
}

# Example call to the function
master_data <- get_race_data(meeting_key = 1219, driver_number = 1, session_key = 9165,
                             include_car_details = TRUE,
                             include_interval_data = TRUE,
                             include_lap_data = TRUE,
                             include_location_data = TRUE,
                             include_position_data = TRUE,
                             include_team_radio_data = TRUE,
                             include_pit_data = TRUE,
                             include_stint_data = TRUE,
                             include_weather_data = TRUE,
                             include_race_control_data = TRUE)
