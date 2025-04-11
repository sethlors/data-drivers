# R/utils.R

# Function to get image path for HTML src, handling missing files
get_image_path <- function(base_rel_path_for_src, id, default_src_path = DEFAULT_IMAGE) {
  # base_rel_path_for_src is the path relative to www, e.g., "assets/constructor-images/"
  # id is the constructorId or driverId
  # default_src_path is also relative to www, e.g., "assets/default.jpg"

  # Construct the path relative to www - this is what the HTML src attribute needs
  src_path <- file.path(base_rel_path_for_src, paste0(id, ".jpg")) # Assumes .jpg extension

  # Construct the path relative to the APP's root directory to check file existence
  # This looks inside the 'www' subfolder for the actual file
  check_path <- file.path("www", src_path)

  # Check if ID is valid and the file actually exists at the check_path location
  if (!is.na(id) && id != "" && file.exists(check_path)) {
    return(src_path) # Return the path relative to www (e.g., "assets/...")
  } else {
    # If primary image doesn't exist, check if the default image exists
    if (file.exists(file.path("www", default_src_path))) {
      return(default_src_path) # Return the default path relative to www
    } else {
      warning("Default image file not found at: ", file.path("www", default_src_path))
      # Return an empty string if even the default is missing, prevents broken image links
      return("")
    }
  }
}

# Function to adjust color (e.g., ensure valid hex)
adjustColor <- function(hexColor) {
  # Basic check for valid hex color format
  if (is.na(hexColor) || !grepl("^#[0-9A-Fa-f]{6}$", hexColor)) {
    return("#333333") # Return a default dark grey if invalid
  }
  return(hexColor)
}

# Function to format position number with ordinal suffix
format_position <- function(pos) {
  if (is.na(pos) || !is.numeric(pos)) {
    return("DNF") # Or maybe NA? Depends on desired output
  }
  pos <- as.integer(pos)
  if (pos <= 0) return(as.character(pos)) # Handle 0 or negative if needed

  if (pos %% 100 %in% 11:13) {
    suffix <- "th"
  } else {
    suffix <- switch(
      as.character(pos %% 10),
      "1" = "st",
      "2" = "nd",
      "3" = "rd",
      "th"
    )
  }
  return(paste0(pos, suffix))
}

# Define tire colors (moved from server logic)
TIRE_COLORS <- c(
    "HARD" = "#FFFFFF",      # White
    "MEDIUM" = "#FED218",    # Yellow
    "SOFT" = "#DD0741",      # Red
    "SUPERSOFT" = "#DA0640", # Red (Often same as Soft visually)
    "ULTRASOFT" = "#A9479E", # Purple
    "HYPERSOFT" = "#FEB4C3", # Pink
    "INTERMEDIATE" = "#45932F", # Green
    "WET" = "#2F6ECE",        # Blue
    "UNKNOWN" = "#808080"     # Grey for unknown/missing
)

# Function to format context for the chatbot
format_chatbot_context <- function(app_context) {
  context <- app_context # Assumes app_context is a reactiveVal list

  if (is.null(context$year) || is.null(context$track)) {
    return("No race selected yet.")
  }

  context_text <- paste0(
    "CURRENT DATA CONTEXT:\n",
    "Race: ", context$track, " Grand Prix ", context$year, "\n\n"
  )

  if (!is.null(context$race_summary) && is.list(context$race_summary)) {
    context_text <- paste0(
      context_text,
      "Race Results Summary:\n",
      "- Total drivers: ", context$race_summary$total_drivers %||% "N/A", "\n",
      "- Finished: ", context$race_summary$finished %||% "N/A", " drivers\n",
      "- DNF/Not classified: ", context$race_summary$dnf %||% "N/A", " drivers\n\n"
    )
  } else {
     context_text <- paste0(context_text, "Race Results Summary: Not available.\n\n")
  }

  if (!is.null(context$podium) && is.list(context$podium)) {
    context_text <- paste0(
      context_text,
      "Podium:\n",
      "- Winner: ", context$podium$winner %||% "N/A", "\n",
      "- Top 3 Drivers: ", context$podium$drivers %||% "N/A", "\n",
      "- Top 3 Constructors: ", context$podium$constructors %||% "N/A", "\n\n"
    )
  } else {
      context_text <- paste0(context_text, "Podium Information: Not available.\n\n")
  }

  if (!is.null(context$tire_summary) && is.list(context$tire_summary)) {
    context_text <- paste0(
      context_text,
      "Tire Strategy Summary:\n",
      "- Compounds used: ", paste(context$tire_summary$compounds_used %||% "N/A", collapse = ", "), "\n",
      "- Most common compound: ", context$tire_summary$most_common %||% "N/A", "\n",
      "- Pit stop range: ", context$tire_summary$min_pit_stops %||% "?", " to ", context$tire_summary$max_pit_stops %||% "?", "\n",
      "- Drivers with most stops (", context$tire_summary$max_pit_stops %||% "?", "): ", context$tire_summary$drivers_with_most_stops %||% "N/A", "\n"
    )
  } else {
      context_text <- paste0(context_text, "Tire Strategy Summary: Not available.\n")
  }

  return(context_text)
}