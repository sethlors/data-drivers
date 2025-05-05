library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(here)
library(tibble)

circuits <- read.csv("data/clean-data/circuits.csv")
constructors <- read.csv("data/clean-data/constructors.csv")
drivers <- read.csv("data/clean-data/drivers.csv")
lap_times <- read.csv("data/clean-data/lap_times.csv")
races <- read.csv("data/clean-data/races.csv")
results <- read.csv("data/clean-data/results.csv")
status <- read.csv("data/clean-data/status.csv")
stints <- read.csv("data/clean-data/stints.csv")
win_prob <- read.csv("data/clean-data/win_prob.csv")

addResourcePath("assets", "assets")

points_table <- c(25, 18, 15, 12, 10, 8, 6, 4, 2, 1)

get_image_path <- function(base_path, id, default_path = "assets/default.jpg") {
  if (is.na(id) || id == "") {
    return(default_path)
  }
  full_path <- file.path(base_path, paste0(id, ".jpg"))

  if (file.exists(full_path)) {
    return(full_path)
  } else {
    message(paste("File not found:", full_path))
    return(default_path)
  }
}

# UI Definition
ui <- fluidPage(
  # Link to external CSS file in www directory
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "assets/styles.css"),
    tags$style(HTML("body { font-family: Formula1Font, sans-serif; }")),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css")
  ),

  tags$div(
    id = "infoButton",
    style = "position: fixed; bottom: 20px; right: 20px; z-index: 1000;",
    actionButton("infoBtn", "?", class = "info-btn")
  ),

  tags$div(
    id = "githubButton",
    style = "position: fixed; bottom: 20px; right: 80px; z-index: 1000;",
    tags$a(
      href = "https://github.com/sethlors/data-drivers",
      target = "_blank",
      class = "github-btn",
      tags$img(
        src = "assets/icons/github.png",
        alt = "GitHub",
        style = "width: 30px; height: 30px;"
      )
    )
  ),

  # App title
  div(class = "container-fluid",
      div(class = "row",
          div(class = "col-12 text-center",
              h2("F1 Race Analysis")
          )
      ),

      # Year and track selection inputs
      div(class = "row",
          div(class = "col-12",
              div(class = "control-panel",
                  div(class = "row",
                      div(class = "col-md-6",
                          selectInput("year", "Year", choices = sort(unique(races$year), decreasing = TRUE), selected = 2024)
                      ),
                      div(class = "col-md-6",
                          selectInput("track", "Track", choices = NULL)
                      )
                  )
              )
          )
      ),

      div(class = "row",
          div(class = "col-12",
              uiOutput("statsBar")
          )
      ),

      # Debug info (can be removed in production)
      verbatimTextOutput("debugInfo"),

      # Podium visualization
      uiOutput("podiumVisualization"),

      div(class = "row",
          div(class = "col-12",
              div(class = "plot-container",
                  tableOutput("raceResults")
              )
          )
      ),
      div(class = "row",
          div(class = "col-12",
              div(class = "plot-container",
                  plotlyOutput("tireStrategyPlot", height = "600px")
              )
          )
      ),
      div(class = "row",
          div(class = "col-12",
              div(class = "plot-container",
                  plotlyOutput("winProbPlot", height = "600px")
              )
          )
      )
  )
)

# Server logic
server <- function(input, output, session) {
  # Update track dropdown when year is selected
  observeEvent(input$year, {
    # Exclude 2018 from the dropdown
    filtered_races <- races[races$year != 2018,]

    # Update the track dropdown based on the selected year
    updateSelectInput(session, "track", choices = NULL, selected = NULL)
    races_for_year <- filtered_races[filtered_races$year == input$year,]
    available_tracks <- setNames(races_for_year$name, paste0(races_for_year$name, " - R", races_for_year$round))
    updateSelectInput(session, "track", choices = available_tracks)
  })

  # Update the year dropdown to exclude 2018
  updateSelectInput(session, "year", choices = sort(unique(races$year[races$year != 2018]), decreasing = TRUE), selected = 2024)

  fastest_lap_data <- reactive({
    req(selected_race_id())

    # Get the lap times for this race
    race_lap_times <- lap_times[lap_times$raceId == selected_race_id(),]

    if (nrow(race_lap_times) == 0) {
      return(NULL)
    }

    # Find the fastest lap
    fastest_lap <- race_lap_times[which.min(race_lap_times$milliseconds),]

    if (nrow(fastest_lap) == 0) {
      return(NULL)
    }

    # Get driver info for the fastest lap
    driver_info <- drivers[drivers$driverId == fastest_lap$driverId,]

    # Format time MM:SS.sss
    lap_time <- format_milliseconds(fastest_lap$milliseconds)

    list(
      driver_code = driver_info$code,
      lap_time = lap_time,
      lap_number = fastest_lap$lap
    )
  })

  # Helper function to format milliseconds as MM:SS.sss
  format_milliseconds <- function(ms) {
    if (is.na(ms)) return("--:--:---")
    total_seconds <- ms / 1000
    minutes <- floor(total_seconds / 60)
    seconds <- floor(total_seconds %% 60)
    milliseconds <- round((total_seconds - floor(total_seconds)) * 1000)

    sprintf("%d:%02d.%03d", minutes, seconds, milliseconds)
  }

  # Get circuit info
  circuit_info <- reactive({
    req(selected_race_id())

    # Get circuit ID for this race
    race_info <- races[races$raceId == selected_race_id(),]

    if (nrow(race_info) == 0) {
      return(NULL)
    }

    # Get circuit details
    circuit_details <- circuits[circuits$circuitId == race_info$circuitId,]

    if (nrow(circuit_details) == 0) {
      return(NULL)
    }

    # Get the shorthand name for the circuit
    circuit_name <- circuit_details$name

    # Create simplified name for display purposes (optional)
    simplified_name <- gsub(" Grand Prix Circuit", "", circuit_name)
    simplified_name <- gsub(" International Circuit", "", simplified_name)
    simplified_name <- gsub(" Circuit", "", simplified_name)

    list(
      circuit_name = simplified_name,
      location = circuit_details$location,
      country = circuit_details$country
    )
  })

  # Get tire data - showing mock data for demonstration
  tire_data <- reactive({
    req(selected_race_id())

    # Get all tire stints for this race from your stints table
    race_stints <- stints[stints$raceId == selected_race_id(),]

    # Find the most recent compound
    if (nrow(race_stints) > 0) {
      latest_stint <- race_stints[which.max(race_stints$lap),]
      compound <- latest_stint$tireCompound
      age <- latest_stint$tyreLife
    } else {
      # Default values if no data
      compound <- "MEDIUM"
      age <- 2
    }

    list(
      compound = compound,
      age = age
    )
  })

  # Render the stats bar
  output$statsBar <- renderUI({
    fastest <- fastest_lap_data()
    circuit <- circuit_info()
    tires <- tire_data()

    if (is.null(fastest) || is.null(circuit)) {
      return(NULL)
    }

    # Default values for missing data
    fastest$driver_code <- ifelse(is.null(fastest$driver_code), "---", fastest$driver_code)
    fastest$lap_time <- ifelse(is.null(fastest$lap_time), "--:--.---", fastest$lap_time)
    fastest$lap_number <- ifelse(is.null(fastest$lap_number), "?", fastest$lap_number)

    circuit$circuit_name <- ifelse(is.null(circuit$circuit_name), "Unknown Circuit", circuit$circuit_name)

    tires$compound <- ifelse(is.null(tires$compound), "UNKNOWN", tires$compound)
    tires$age <- ifelse(is.null(tires$age), "?", tires$age)

    # Compound to color mapping
    compound_colors <- c(
      "HARD" = "#FFFFFF",
      "MEDIUM" = "#FFDA00",
      "SOFT" = "#E80600",
      "INTERMEDIATE" = "#4DDB30",
      "WET" = "#00AFFF",
      "SUPERSOFT" = "#DA0640",
      "ULTRASOFT" = "#A9479E",
      "HYPERSOFT" = "#FEB4C3"
    )

    tire_color <- compound_colors[tires$compound]
    if (is.na(tire_color)) tire_color <- "#FFFFFF" # Default to white if unknown compound

    # Create the stats bar
    div(class = "stats-bar",

        # Fastest lap section
        div(class = "stats-item",
            tags$div(class = "stats-icon",
                     tags$div(style = "font-size: 24px; margin-right: 10px;",
                              tags$i(class = "fas fa-stopwatch"))
            ),
            div(
              div(class = "stats-label", "FASTEST LAP"),
              div(class = "stats-value",
                  paste0(fastest$lap_time, " - ", fastest$driver_code)
              )
            )
        ),

        # Circuit section
        div(class = "stats-item",
            tags$div(class = "stats-icon",
                     tags$div(style = "font-size: 24px; margin-right: 10px;",
                              tags$i(class = "fas fa-flag-checkered"))
            ),
            div(
              div(class = "stats-label", "CIRCUIT"),
              div(class = "stats-value", circuit$circuit_name)
            )
        ),

        # Lap section
        div(class = "stats-item",
            div(
              div(class = "stats-label", "Completed On"),
              div(class = "stats-value", paste("Lap", fastest$lap_number))
            )
        ),

        # Tire compound section - with colored text
        div(class = "stats-item",
            div(
              div(class = "stats-label", "Used Tires"),
              div(class = "stats-value",
                  tags$span(style = paste0("color: ", tire_color, ";"), tires$compound))
            )
        ),

        # Tire age section - no icon
        div(class = "stats-item",
            div(
              div(class = "stats-label", "Tire Age"),
              div(class = "stats-value", paste(tires$age, "laps"))
            )
        )
    )
  })

  # Get race ID based on selected year and track
  selected_race_id <- reactive({
    req(input$year, input$track)
    selected_race <- races[races$year == input$year & races$name == input$track,]
    if (nrow(selected_race) > 0) {
      return(selected_race$raceId[1])
    } else {
      return(NULL)
    }
  })

  # Info button
  observeEvent(input$infoBtn, {
    showModal(
      modalDialog(
        title = span("ABOUT THIS DASHBOARD", style = "color: white;"),
        size = "l",
        easyClose = TRUE,
        footer = NULL,

        # Adding explicit HTML content with app information
        HTML('
        <div style="max-height: 500px; overflow-y: auto; color: white;">
          <p>Hi! 👋</p>
          <p>This dashboard visualizes Formula 1 race data to provide insights on race results, driver performance, and race strategies.</p>

          <h4>WHAT IS FORMULA 1?</h4>
          <ul>
            <li><b>Drivers – 20 total drivers (there can be more, but typically there are only 20 in a season)
            <li><b>Teams – Companies, or constructors (like Ferrari, Mercedes, and Red Bull), who build the cars and manage the racing operations.
            <li><b>Cars – There are different classes of Formula racing: Formula 4, 3, 2, and what we are working with, Formula 1. F1 uses the fastest cars.
            <li><b>Circuits – Tracks where the races are held, including both permanent racetracks and temporary street circuits all around the world.
          </ul>

          <h4>HOW TO USE THE DASHBOARD</h4>
          <ul>
            <li><b>Race Selection:</b> Choose a season and Grand Prix from the dropdown menus at the top.</li>
            <li><b>Podium Visualization:</b> The top three finishers with their team colors, finishing positions, and time differences.</li>
            <li><b>Race Results Table:</b> Finishing order with drivers, teams, and timing information.</li>
            <li><b>Tire Strategy Plot:</b> Visual representation of each driver\'s tire compound choices throughout the race, showing stint lengths and tire changes.</li>
              <ul>
                <li><b>Soft (Red):</b> Fastest speed, but shortest lifespan.</li>
                <li><b>Medium (Yellow):</b> Balance of speed and durability.</li>
                <li><b>Hard (White):</b> Slowest, but most durable.</li>
                <li><b>Intermediate (Green):</b> For damp conditions.</li>
                <li><b>Wet (Blue):</b> For heavy rain conditions.</li>
               </ul>
            <li><b>Win Probability Chart:</b> How each driver\'s chances of winning evolved throughout the race based on position, pace, and other factors.</li>
          </ul>

          <h4>Common F1 Terms</h4>
          <ul>
            <li><b>Pit Stop:</b> A stop during the race for tire changes, repairs, or adjustments.</li>
            <li><b>Stint:</b> A period of the race between pit stops, typically on the same set of tires.</li>
            <li><b>Undercut/Overcut:</b> Strategic pit stop timing to gain track position over competitors.</li>
            <li><b>Pole Position:</b> The first starting position, awarded to the fastest qualifier.</li>
            <li><b>DRS:</b> Drag Reduction System, a mechanism to reduce drag and increase speed.</li>
          </ul>

        </div>
      ')
      )
    )
  })

  # Prepare race results data
  race_data <- reactive({
    req(selected_race_id())

    # Get results for the selected race and merge with driver information
    results_filtered <- results[results$raceId == selected_race_id(),]

    # Check if we have results data
    if (nrow(results_filtered) == 0) {
      return(NULL)
    }

    # Merge with driver information
    race_results <- merge(results_filtered, drivers, by = "driverId")

    # Clean up missing values
    race_results$time <- ifelse(race_results$time == "\\N", NA, race_results$time)
    race_results$position <- ifelse(race_results$position == "\\N", NA, race_results$position)

    # Add status information
    race_results <- merge(race_results, status, by = "statusId", all.x = TRUE)

    # Add constructor information including color
    race_results <- merge(race_results, constructors, by = "constructorId", all.x = TRUE)

    # Convert position to numeric - ensure proper conversion
    race_results$position <- suppressWarnings(as.numeric(as.character(race_results$position)))

    # Use status message for DNF entries
    race_results$time <- ifelse(!is.na(race_results$time), race_results$time, race_results$status)

    # Create driver full name
    race_results$Driver <- paste(race_results$forename, race_results$surname)

    # Sort by finishing position
    race_results <- race_results[order(race_results$position, na.last = TRUE),]

    # Calculate points earned
    race_results$Points <- ifelse(race_results$position >= 1 & race_results$position <= 10,
                                  points_table[race_results$position], 0)
    race_results$Points <- paste0("+", race_results$Points)

    # Handle different column name variations from merges
    constructor_col <- ifelse("name.y" %in% colnames(race_results), "name.y",
                              ifelse("name.1" %in% colnames(race_results), "name.1", "name"))

    # Use actual driver code from the data rather than generating from surname
    race_results$Driver_Code <- race_results$code

    # Format positions with ordinals (1st, 2nd, etc.) or DNF
    race_results$formatted_position <- sapply(race_results$position, function(pos) {
      if (is.na(pos)) {
        return("DNF")
      } else {
        suffix <- switch(
          as.character(pos %% 10),
          "1" = if (pos %% 100 == 11) "th" else "st",
          "2" = if (pos %% 100 == 12) "th" else "nd",
          "3" = if (pos %% 100 == 13) "th" else "rd",
          "th"
        )
        return(paste0(pos, suffix))
      }
    })

    # Add image paths for constructors and drivers with path validation
    race_results$Constructor_Image <- sapply(race_results$constructorId, function(id) {
      get_image_path("assets/constructor-images/", id, "assets/default.jpg")
    })

    race_results$Driver_Image <- sapply(race_results$driverId, function(id) {
      get_image_path("assets/driver-images/", id, "assets/default.jpg")
    })

    # Create final dataset for display
    result_subset <- data.frame(
      Position = race_results$formatted_position,
      Driver = race_results$Driver,
      Code = race_results$Driver_Code,
      Time = race_results$time,
      Constructor = race_results[[constructor_col]],
      Constructor_Image = race_results$Constructor_Image,
      Driver_Image = race_results$Driver_Image,
      Points = race_results$Points,
      driverId = race_results$driverId,
      position = race_results$position,
      constructorId = race_results$constructorId,
      constructorColor = race_results$color
    )

    return(result_subset)
  })

  # Function to adjust colors for better visibility if needed
  adjustColor <- function(hexColor) {
    # Function to adjust color brightness if needed
    if (is.na(hexColor) || hexColor == "") {
      return("#333333") # Default color if missing
    }
    return(hexColor)
  }

  # Render podium visualization with improved error handling
  output$podiumVisualization <- renderUI({
    results <- race_data()
    if (is.null(results) || nrow(results) == 0) {
      return(div(class = "error-message", "No race data available"))
    }

    # Get top 3 drivers
    podium <- results[results$position <= 3,]

    # Check if we have enough drivers for podium
    if (nrow(podium) < 3) {
      return(div(class = "error-message", "Not enough drivers finished in top 3 positions to display podium"))
    }

    # Make sure positions are correctly ordered
    podium <- podium[order(podium$position),]

    # Check if we have exactly positions 1, 2, and 3
    expected_positions <- c(1, 2, 3)
    actual_positions <- sort(podium$position[1:3])

    if (!all(actual_positions == expected_positions)) {
      return(div(class = "error-message",
                 paste("Expected positions 1, 2, 3, but found:",
                       paste(actual_positions, collapse = ", "))))
    }

    # Use natural order (1st, 2nd, 3rd) instead of traditional podium layout
    podium_order <- podium[c(1, 2, 3),]

    # Create position labels and time differences
    position_labels <- c("P1", "P2", "P3")
    time_diffs <- c(
      ifelse(podium_order$position[1] == 1, "Leader", ""),
      paste0("", ifelse(is.na(podium_order$Time[2]) || podium_order$position[2] == 1, "0.000", podium_order$Time[2])),
      paste0("", ifelse(is.na(podium_order$Time[3]) || podium_order$position[3] == 1, "0.000", podium_order$Time[3]))
    )

    # Create the podium boxes
    fluidRow(
      class = "podium-row",

      # P1 - First Place (Left)
      column(4,
             div(class = "podium-box",
                 style = paste0("background-color: ", adjustColor(podium_order$constructorColor[1]), ";"),
                 div(class = "box-gradient"),
                 img(class = "driver-img", src = podium_order$Driver_Image[1]),
                 img(class = "constructor-img", src = podium_order$Constructor_Image[1]),
                 div(class = "glass-footer",
                     div(class = "driver-code", podium_order$Code[1]),
                     div(class = "position-label", position_labels[1]),
                     div(class = "time-diff", time_diffs[1])
                 )
             )
      ),

      # P2 - Second Place (Middle)
      column(4,
             div(class = "podium-box",
                 style = paste0("background-color: ", adjustColor(podium_order$constructorColor[2]), ";"),
                 div(class = "box-gradient"),
                 img(class = "driver-img", src = podium_order$Driver_Image[2]),
                 img(class = "constructor-img", src = podium_order$Constructor_Image[2]),
                 div(class = "glass-footer",
                     div(class = "driver-code", podium_order$Code[2]),
                     div(class = "position-label", position_labels[2]),
                     div(class = "time-diff", time_diffs[2])
                 )
             )
      ),

      # P3 - Third Place (Right)
      column(4,
             div(class = "podium-box",
                 style = paste0("background-color: ", adjustColor(podium_order$constructorColor[3]), ";"),
                 div(class = "box-gradient"),
                 img(class = "driver-img", src = podium_order$Driver_Image[3]),
                 img(class = "constructor-img", src = podium_order$Constructor_Image[3]),
                 div(class = "glass-footer",
                     div(class = "driver-code", podium_order$Code[3]),
                     div(class = "position-label", position_labels[3]),
                     div(class = "time-diff", time_diffs[3])
                 )
             )
      )
    )
  })

  # Render results table with formatted HTML content
  output$raceResults <- renderUI({
    results <- race_data()
    if (is.null(results) || nrow(results) == 0) {
      return(div(class = "error-message", "No race data available"))
    }

    # Generate HTML table rows
    rows <- apply(results, 1, function(row) {
      constructor_img <- tags$img(src = row[["Constructor_Image"]], height = "30", style = "margin-right:10px;")

      tags$tr(
        tags$td(row[["Position"]]),
        tags$td(row[["Driver"]]),
        tags$td(row[["Code"]]),
        tags$td(div(constructor_img, row[["Constructor"]])),
        tags$td(row[["Time"]]),
        tags$td(row[["Points"]])
      )
    })

    # Build the table
    table_tag <- tags$table(
      class = "table race-results-table",
      tags$thead(
        tags$tr(
          tags$th("Pos"), tags$th("Driver"), tags$th("Code"),
          tags$th("Constructor"), tags$th("Time"), tags$th("Points")
        )
      ),
      tags$tbody(rows)
    )

    # Wrap the table in a styled container
    div(
      class = "race-results-container",
      table_tag
    )
  })

  # Prepare tire strategy data
  tire_stints <- reactive({
    req(selected_race_id())

    # Get race results for driver order
    results_order <- race_data()
    if (is.null(results_order) || nrow(results_order) == 0) return(NULL)

    # Get tire stints for the selected race
    race_stints <- stints[stints$raceId == selected_race_id(),]
    if (nrow(race_stints) == 0) return(NULL)

    # Add driver information to stints
    driver_info <- merge(race_stints, drivers, by = "driverId", all.x = TRUE)
    driver_info$Driver <- paste(driver_info$forename, driver_info$surname)
    driver_info$Driver_Code <- driver_info$code
    driver_info <- driver_info[!is.na(driver_info$Driver),]

    # Identify tire changes
    driver_info <- driver_info %>%
      arrange(driverId, lap) %>%
      group_by(driverId) %>%
      mutate(
        tire_prev = lag(tireCompound, default = "NONE"),
        new_stint = tireCompound != tire_prev | is.na(tireCompound) != is.na(tire_prev),
        stint_number = cumsum(new_stint)
      ) %>%
      ungroup()

    # Summarize stint data
    stint_summary <- driver_info %>%
      filter(!is.na(tireCompound)) %>%
      group_by(driverId, Driver, Driver_Code, stint_number, tireCompound, compoundColor) %>%
      summarise(
        start_lap = min(lap),
        end_lap = max(lap),
        laps = end_lap - start_lap + 1,
        .groups = "drop"
      )

    # Order for plotting
    driver_levels <- rev(results_order$Driver)
    driver_codes <- rev(results_order$Code)

    stint_summary$Driver_Name <- stint_summary$Driver
    stint_summary$Driver <- factor(stint_summary$Driver, levels = driver_levels)
    stint_summary$Driver_Code <- factor(
      stint_summary$Driver_Code,
      levels = driver_codes[match(driver_levels, results_order$Driver[order(results_order$position, decreasing = TRUE)])]
    )

    stint_summary$visual_width <- pmax(stint_summary$laps, 2)
    stint_summary$label_x_adj <- ifelse(stint_summary$laps == 1, 0.5, 0)

    return(stint_summary)
  })

  output$tireStrategyPlot <- renderPlotly({
    stints_data <- tire_stints() # This has 'Driver_Code'
    results_order <- race_data() # This has 'Code'

    # Check if data is available
    if (is.null(stints_data) ||
      nrow(stints_data) == 0 ||
      is.null(results_order) ||
      nrow(results_order) == 0) {
      return(plotly_empty(type = "scatter", mode = "markers") %>%
               layout(title = "Tire Strategy Data Not Available",
                      paper_bgcolor = "#181F28",
                      plot_bgcolor = "#181F28",
                      font = list(family = "Formula1Font", color = "white")) %>%
               config(displayModeBar = FALSE))
    }

    driver_positions <- results_order %>%
      select(Driver_Code = Code, position) %>%
      filter(!is.na(position)) %>%
      arrange(position)

    stints_plot_data <- stints_data %>%
      inner_join(driver_positions, by = "Driver_Code") %>%
      arrange(position, start_lap) %>%
      mutate(Driver_Code = factor(Driver_Code, levels = rev(unique(driver_positions$Driver_Code))))

    if (nrow(stints_plot_data) == 0) {
      return(plotly_empty(type = "scatter", mode = "markers") %>%
               layout(title = "No Matching Stint Data for Classified Drivers",
                      paper_bgcolor = "#181F28",
                      plot_bgcolor = "#181F28",
                      font = list(family = "Formula1Font", color = "white")) %>%
               config(displayModeBar = FALSE))
    }

    tire_colors <- c(
      "HARD" = "#F0F0F0", "MEDIUM" = "#FFDA00", "SOFT" = "#E80600",
      "INTERMEDIATE" = "#4DDB30", "WET" = "#00AFFF",
      "SUPERSOFT" = "#DA0640", "ULTRASOFT" = "#A9479E", "HYPERSOFT" = "#FEB4C3"
    )

    max_lap <- max(stints_plot_data$end_lap, na.rm = TRUE)

    # --- Prepare hover text & coordinates (Same as before) ---
    stints_plot_data$hover_text <- paste0(
      stints_plot_data$Driver_Name, "<br>",
      stints_plot_data$tireCompound, ": ", stints_plot_data$laps, " Laps<br>",
      "Laps ", stints_plot_data$start_lap, "-", stints_plot_data$end_lap
    )
    stints_plot_data$x_start <- stints_plot_data$start_lap - 0.5
    stints_plot_data$x_end <- stints_plot_data$end_lap + 0.5
    stints_plot_data$text_x <- stints_plot_data$start_lap + (stints_plot_data$laps / 2) - 0.5

    # --- Create ggplot ---
    p <- ggplot(stints_plot_data, aes(y = Driver_Code)) +
      geom_rect( # Rect remains the same (no gaps)
        aes(xmin = x_start, xmax = x_end, fill = tireCompound,
            ymin = as.numeric(Driver_Code) - 0.4,
            ymax = as.numeric(Driver_Code) + 0.4,
            text = hover_text),
        color = NA,
        size = 0
      ) +
      geom_text( # Text remains the same
        aes(x = text_x, label = laps),
        color = "black", size = 3, fontface = "bold", family = "Formula1Font"
      ) +
      # --- MODIFICATION: Re-enable Legend in Scale ---
      scale_fill_manual(
        values = tire_colors,
        name = "Tire Compound", # Set legend title (optional)
        na.value = "grey50"
        # guide = "none"  <-- REMOVED this line
      ) +
      # --- End Modification ---
      scale_x_continuous( # X Axis remains the same
        breaks = seq(0, max_lap + (15 - max_lap %% 15), by = 15),
        limits = c(0, max_lap + 1),
        expand = c(0.005, 0.005)
      ) +
      labs( # Labels remain the same
        title = "TIRE STRATEGY",
        x = "LAP",
        y = NULL
      ) +
      theme_minimal(base_family = "Formula1Font") +
      # --- MODIFICATION: Adjust Theme for Legend ---
      theme(
        plot.title = element_text(hjust = 0, face = "bold", colour = "white", size = 14, margin = margin(b = 15, t = 10)),
        plot.background = element_rect(fill = "#181F28", color = "#181F28"),
        panel.background = element_rect(fill = "#181F28", color = "#181F28"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.y = element_text(colour = "white", size = 9, face = "bold"),
        axis.text.x = element_text(colour = "white", size = 9),
        axis.title.x = element_text(colour = "white", size = 10, face = "bold", margin = margin(t = 10)),
        axis.ticks = element_line(colour = "grey50"),
        axis.ticks.length = unit(0.2, "cm"),
        axis.line.x = element_line(colour = "grey50"),
        axis.line.y = element_blank(),
        legend.position = "bottom",  # Position legend at the bottom
        legend.background = element_rect(fill = "#181F28", color = NA), # Match plot bg
        legend.key = element_rect(fill = "#181F28", color = NA),        # Match plot bg for key area
        legend.title = element_text(colour = "white", size = 10, face = "bold"), # Style legend title
        legend.text = element_text(colour = "white", size = 9)             # Style legend text
      )
    # --- End Modification ---

    # --- Convert to Plotly & ADD Legend Layout ---
    plotly_plot <- ggplotly(p, tooltip = "text") %>%
      layout(
        paper_bgcolor = "#181F28",
        plot_bgcolor = "#181F28",
        font = list(family = "Formula1Font", color = "white"),
        xaxis = list( # X axis layout remains the same
          fixedrange = TRUE, zeroline = FALSE, showgrid = FALSE,
          tickfont = list(color = "white", size = 13),
          titlefont = list(color = "white", size = 13, face = "bold")
        ),
        yaxis = list( # Y axis layout remains the same
          fixedrange = TRUE, zeroline = FALSE, showgrid = FALSE,
          tickfont = list(color = "white", size = 13, face = "bold")
        ),
        # --- ADDITION: Plotly Legend Styling ---
        legend = list(
          orientation = "h",      # Horizontal items
          xanchor = 'center',     # Anchor point on legend is center
          x = 0.5,                # Position legend center at 50% of plot width
          yanchor = 'top',        # Anchor point on legend is top
          y = -0.15,              # Position legend top slightly below x-axis title (adjust if needed)
          bgcolor = '#181F28',    # Legend background color
          bordercolor = '#181F28', # Legend border color
          font = list(color = "white", size = 13) # Styling for legend item text
        ),
        # --- End Addition ---
        margin = list(l = 50, r = 20, t = 50, b = 70) # Adjusted bottom margin slightly for legend space
      ) %>%
      config(displayModeBar = FALSE)

    plotly_plot
  })

  output$winProbPlot <- renderPlotly({
    req(selected_race_id())

    win_prob_filtered <- win_prob[win_prob$raceId == selected_race_id(),]

    # Check if data is available
    if (is.null(win_prob_filtered) || nrow(win_prob_filtered) == 0) {
      return(plotly_empty(type = "scatter", mode = "markers") %>%
               layout(title = "Win Probability Data Not Available",
                      paper_bgcolor = "#181F28",
                      plot_bgcolor = "#181F28",
                      font = list(family = "Formula1Font", color = "white")) %>%
               config(displayModeBar = FALSE))
    }

    # Create a named vector: names are drivers, values are colors
    driver_colors <- win_prob_filtered %>%
      select(driver, team_color) %>%
      distinct() %>%
      deframe()

    # Find the last lap for each driver
    last_lap <- win_prob_filtered %>%
      group_by(driver) %>%
      filter(lap == max(lap)) %>%
      ungroup()

    # Get order of drivers based on final prediction for legend order (optional but nice)
    driver_order <- last_lap %>%
      arrange(desc(win_prob)) %>%
      pull(driver)

    # Reorder the driver factor in your dataset
    win_prob_filtered <- win_prob_filtered %>%
      mutate(driver = factor(driver, levels = driver_order))

    # Dynamically calculate the number of breaks based on window size
    plot_width <- session$clientData$output_winProbPlot_width
    num_breaks <- ifelse(is.null(plot_width), 10, max(5, floor(plot_width / 100)))

    # Create the win probability plot
    p <- ggplot(win_prob_filtered, aes(
      x = lap,
      y = win_prob,
      color = driver,
      group = driver,
      text = paste0("Driver: ", driver, # Tooltip text definition
                    "<br>Lap: ", lap,
                    "<br>Win Prob: ", scales::percent(win_prob, accuracy = 0.1))
    )) +
      geom_line(linewidth = 1) +
      # --- MODIFICATION: Removed guide = "none" to allow legend ---
      scale_color_manual(
        values = driver_colors,
        name = "Driver" # Set legend title for ggplot (Plotly might override)
      ) +
      # --- End Modification ---
      scale_x_continuous(
        breaks = scales::pretty_breaks(n = num_breaks),
        expand = c(0.01, 0.01)
      ) +
      scale_y_continuous(
        limits = c(0, 1),
        labels = scales::percent_format(accuracy = 1),
        expand = c(0.01, 0.01)
      ) +
      labs(
        title = "WIN PROBABILITY",
        x = "LAP NUMBER",
        y = "WIN PROBABILITY",
        color = "DRIVER" # Legend title (used by ggplot, can be overridden by Plotly)
      ) +
      theme_minimal(base_family = "Formula1Font") +
      theme(
        plot.title = element_text(hjust = 0, face = "bold", colour = "white", size = 14, margin = margin(b = 15, t = 10)),
        plot.background = element_rect(fill = "#181F28", color = "#181F28"),
        panel.background = element_rect(fill = "#181F28", color = "#181F28"),
        panel.grid.major = element_line(color = "#333333"),
        panel.grid.minor = element_blank(),
        axis.text.y = element_text(colour = "white", size = 9),
        axis.text.x = element_text(colour = "white", size = 9),
        axis.title.x = element_text(colour = "white", size = 10, face = "bold", margin = margin(t = 10)),
        axis.title.y = element_text(colour = "white", size = 10, face = "bold", margin = margin(r = 10)),
        axis.ticks = element_line(colour = "grey50"),
        axis.ticks.length = unit(0.2, "cm"),
        axis.line = element_line(colour = "grey50"),
        legend.background = element_rect(fill = "#181F28", color = NA),
        legend.key = element_rect(fill = "#181F28", color = NA),
        legend.title = element_text(colour = "white", size = 10, face = "bold"),
        legend.text = element_text(colour = "white", size = 12) # Increased text size
      )

    # Convert to a plotly interactive
    plotly_plot <- ggplotly(p, tooltip = "text") %>%
      layout(
        paper_bgcolor = "#181F28",
        plot_bgcolor = "#FFF",
        font = list(family = "Formula1Font", color = "white"),
        xaxis = list(
          fixedrange = TRUE, zeroline = FALSE, showgrid = TRUE,
          gridcolor = "#333333",
          tickfont = list(color = "white", size = 12),
          titlefont = list(color = "white", size = 13, face = "bold")
        ),
        yaxis = list(
          fixedrange = TRUE, zeroline = FALSE, showgrid = TRUE,
          gridcolor = "#333333",
          tickformat = '.0%',
          tickfont = list(color = "white", size = 12),
          titlefont = list(color = "white", size = 13, face = "bold")
        ),
        legend = list(
          orientation = "h",
          xanchor = 'center',
          x = 0.5,
          yanchor = 'top',
          y = -0.25,  # Adjusted to move the legend further down
          bgcolor = '#181F28',
          bordercolor = '#181F28',
          font = list(color = "white", size = 13),
          title = list(text = "Driver", font = list(color = "white", size = 10, family = "Formula1Font", face = "bold")),
          traceorder = 'normal'
        ),
        margin = list(l = 60, r = 20, t = 50, b = 100)  # Increased bottom margin for space
      ) %>%
      config(displayModeBar = FALSE)

    plotly_plot
  })

}

# Start the Shiny app
shinyApp(ui = ui, server = server)