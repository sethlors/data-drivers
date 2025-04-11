# R/data-processing.R

# Processes results data for a given race ID
# R/data-processing.R

# R/data-processing.R

process_race_results <- function(race_id, results_df, drivers_df, status_df, constructors_df) {
  results_filtered <- results_df[results_df$raceId == race_id,]

  if (nrow(results_filtered) == 0) {
    return(NULL) # No results for this race
  }

  # Merge data
  race_results <- merge(results_filtered, drivers_df, by = "driverId")
  race_results <- merge(race_results, status_df, by = "statusId", all.x = TRUE)
  # Ensure constructor merge handles potential name conflicts if 'name' exists in race_results
  race_results <- merge(race_results, constructors_df, by = "constructorId", all.x = TRUE, suffixes = c("", ".constructor"))

  # Data cleaning and transformation
  # Use the original time column for NA check
  race_results$time <- ifelse(results_filtered$time[match(race_results$resultId, results_filtered$resultId)] == "\\N", NA, results_filtered$time[match(race_results$resultId, results_filtered$resultId)])

  # Clean position: Convert to numeric, \N becomes NA
  race_results$position <- suppressWarnings(as.numeric(as.character(race_results$position)))
  # Note: The original character version might be positionText if available and needed

  # Assign status to time only if position is NA (DNF/Not classified)
  # Important: Do this *after* converting position to numeric NA
  race_results$time_display <- ifelse(is.na(race_results$position), race_results$status, race_results$time)

  # Derived columns
  race_results$Driver <- paste(race_results$forename, race_results$surname)
  race_results$Driver_Code <- race_results$code # Assumes 'code' exists after driver merge

  # Points calculation using the numeric position
  race_results$Points <- ifelse(!is.na(race_results$position) &
                                  race_results$position >= 1 &
                                  race_results$position <= 10,
                                POINTS_TABLE[race_results$position], 0)

  # Image paths (Ensure get_image_path and global paths are correct)
  race_results$Constructor_Image <- sapply(race_results$constructorId, function(id) {
    get_image_path(CONSTRUCTOR_IMG_PATH, id)
  })
  race_results$Driver_Image <- sapply(race_results$driverId, function(id) {
    get_image_path(DRIVER_IMG_PATH, id)
  })

  # Format position using the numeric position column
  race_results$formatted_position <- sapply(race_results$position, format_position)

  # Determine correct constructor name column (handling suffix from merge)
  constructor_col_name <- if ("name.constructor" %in% colnames(race_results)) {
      "name.constructor"
    } else if ("name" %in% colnames(race_results)) {
      # Be careful if 'name' comes from somewhere else; ensure it's the constructor name
      "name"
    } else {
      NA # Constructor name column not found
    }

  # Determine correct constructor color column
   constructor_col_color <- if ("color.constructor" %in% colnames(race_results)) {
      "color.constructor"
    } else if ("color" %in% colnames(race_results)) {
      "color"
    } else {
      NA # Constructor color column not found
    }

  # --- SORT THE DATA FRAME BY NUMERIC POSITION ---
  # Ensure NAs (DNFs etc.) are last. Use the cleaned numeric 'position'.
  race_results <- race_results[order(race_results$position, na.last = TRUE), ]
  # --- END SORTING ---


  # Select and rename columns for final output
  result_subset <- data.frame(
    Position = race_results$formatted_position,
    Driver = race_results$Driver,
    Code = race_results$Driver_Code,
    # Use the time_display column which includes status for DNFs
    Time = ifelse(is.na(race_results$time_display), "N/A", race_results$time_display),
    # Use the identified constructor name column, default to NA if not found
    Constructor = if (!is.na(constructor_col_name)) race_results[[constructor_col_name]] else NA,
    Constructor_Image = race_results$Constructor_Image,
    Driver_Image = race_results$Driver_Image,
    # Format points with '+' sign
    Points = paste0("+", race_results$Points),
    driverId = race_results$driverId,
    position = race_results$position, # Keep numeric position
    constructorId = race_results$constructorId,
    # Use identified color column, apply default logic
    constructorColor = {
        color_source <- if (!is.na(constructor_col_color)) race_results[[constructor_col_color]] else NA
        ifelse(is.na(color_source) | !grepl("^#[0-9A-Fa-f]{6}$", color_source), "#808080", color_source)
      },
    stringsAsFactors = FALSE # Good practice
  )

  return(result_subset)
}


# Processes stint data for a given race ID
process_stint_data <- function(race_id, stints_df, drivers_df, results_order_df) {
  race_stints <- stints_df[stints_df$raceId == race_id,]
  if (nrow(race_stints) == 0) return(NULL) # No stint data

  # Merge with driver info
  driver_info <- merge(race_stints, drivers_df, by = "driverId", all.x = TRUE)
  driver_info <- driver_info[!is.na(driver_info$forename),] # Remove entries without driver match

  driver_info$Driver <- paste(driver_info$forename, driver_info$surname)
  driver_info$Driver_Code <- driver_info$code

  # Calculate stint number per driver
  driver_info <- driver_info %>%
    filter(!is.na(tireCompound)) %>% # Filter out laps with no tire data *before* grouping
    arrange(driverId, lap) %>%
    group_by(driverId) %>%
    mutate(
      tire_prev = lag(tireCompound, default = "START"), # Use "START" to ensure first lap is new stint
      new_stint = (tireCompound != tire_prev),
      stint_number = cumsum(new_stint)
    ) %>%
    ungroup()

  # Summarise each stint
  stint_summary <- driver_info %>%
    group_by(driverId, Driver, Driver_Code, stint_number, tireCompound) %>% # Removed compoundColor for now
    summarise(
      start_lap = min(lap),
      end_lap = max(lap),
      .groups = "drop"
    ) %>%
    mutate(laps = end_lap - start_lap + 1) %>%
    # Add color back based on compound
    mutate(compoundColor = TIRE_COLORS[tireCompound]) %>%
    # Handle unknown compounds
    mutate(compoundColor = ifelse(is.na(compoundColor), TIRE_COLORS["UNKNOWN"], compoundColor))


  # Order drivers based on race finish order
  if (!is.null(results_order_df) && nrow(results_order_df) > 0) {
    # Ensure results_order_df is sorted by numeric position
    results_order_df <- results_order_df %>% arrange(position)
    # Get driver codes in reverse finishing order (for plot)
    driver_codes_ordered <- rev(results_order_df$Code)
    # Apply factor levels
    stint_summary$Driver_Code <- factor(stint_summary$Driver_Code, levels = driver_codes_ordered)
    # Filter out stints for drivers not in the results table (optional, but good practice)
    stint_summary <- stint_summary %>% filter(Driver_Code %in% driver_codes_ordered)
  } else {
    # Fallback if results aren't available: order alphabetically or by ID
    stint_summary <- stint_summary %>% arrange(Driver)
    stint_summary$Driver_Code <- factor(stint_summary$Driver_Code, levels = rev(unique(stint_summary$Driver_Code)))
  }


  # Adjustments for plotting
  # Make very short stints visually wider, ensure label fits
  stint_summary$visual_width <- pmax(stint_summary$laps, 1.5) # Min width for visibility
  stint_summary$visual_end_lap <- stint_summary$start_lap + stint_summary$visual_width - 1 # Adjust end based on visual width

  return(stint_summary)
}

# Generate summary context for chatbot
generate_context_summary <- function(race_results, tire_data) {
  context <- list(
    race_summary = NULL,
    podium = NULL,
    tire_summary = NULL
  )

  if (!is.null(race_results) && nrow(race_results) > 0) {
    # Race Summary
    finished_count <- sum(!is.na(race_results$position))
    dnf_count <- nrow(race_results) - finished_count
    context$race_summary <- list(
      total_drivers = nrow(race_results),
      finished = finished_count,
      dnf = dnf_count
    )

    # Podium Info
    podium <- race_results %>%
      filter(position %in% 1:3) %>%
      arrange(position)
    if (nrow(podium) > 0) {
      context$podium <- list(
        winner = podium$Driver[podium$position == 1] %||% "N/A",
        drivers = paste(podium$Driver, collapse = ", ") %||% "N/A",
        constructors = paste(unique(podium$Constructor), collapse = ", ") %||% "N/A"
      )
    }
  }

  if (!is.null(tire_data) && nrow(tire_data) > 0) {
    # Tire Summary
    compounds_used <- table(tire_data$tireCompound)
    most_used_compound <- names(compounds_used)[which.max(compounds_used)]

    pit_stops <- tire_data %>%
      group_by(Driver) %>% # Use full driver name for clarity
      summarize(
        pit_stops = max(stint_number, na.rm = TRUE) - 1, # Max stint number - 1 = stops
        .groups = "drop"
      ) %>%
      # Ensure pit_stops is at least 0
      mutate(pit_stops = pmax(0, pit_stops))

    max_pit_stops <- max(pit_stops$pit_stops, na.rm = TRUE)
    min_pit_stops <- min(pit_stops$pit_stops, na.rm = TRUE)

    drivers_with_most_stops <- pit_stops %>%
      filter(pit_stops == max_pit_stops) %>%
      pull(Driver)

    context$tire_summary <- list(
      compounds_used = names(compounds_used) %||% list(), # Ensure it's a list/vector
      most_common = most_used_compound %||% "N/A",
      max_pit_stops = max_pit_stops %||% "N/A",
      min_pit_stops = min_pit_stops %||% "N/A",
      drivers_with_most_stops = paste(drivers_with_most_stops %||% "N/A", collapse = ", ")
    )
  }

  return(context)
}