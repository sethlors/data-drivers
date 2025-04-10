library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(here)
library(httr)
library(jsonlite)

# Set concise style prompt for the chatbot
style_prompt <- "Please respond concisely in less than 5 sentences. You know everything about Formula 1 AND the data currently shown in the app. Reference the data in your responses whenever relevant.\n"

# Start Ollama (run in background without blocking)
system("ollama run llama3:8b", wait = FALSE)

# Reactive value to store chat history
chat_history <- reactiveVal("🤖 Ask me about Formula 1 or the data shown in the charts!\n")

# Load data files from the clean-data directory
status <- read.csv(here("data", "clean-data", "status.csv"))
races <- read.csv(here("data", "clean-data", "races.csv"))
drivers <- read.csv(here("data", "clean-data", "drivers.csv"))
results <- read.csv(here("data", "clean-data", "results.csv"))
constructors <- read.csv(here("data", "clean-data", "constructors.csv"))
stints <- read.csv(here("data", "clean-data", "stints.csv"))

# Points allocation for positions 1-10
points_table <- c(25, 18, 15, 12, 10, 8, 6, 4, 2, 1)

# Helper function to check if image exists and provide fallback
get_image_path <- function(base_path, id, default_path = "assets/default.jpg") {
  if (is.na(id) || id == "") {
    return(default_path)
  }
  full_path <- paste0(base_path, id, ".jpg")
  www_path <- file.path("www", full_path)
  if (file.exists(www_path)) {
    return(full_path)
  } else {
    # Print debug info for missing files
    message(paste("File not found:", www_path))
    return(default_path)
  }
}

# UI Definition
ui <- fluidPage(
  # Link to external CSS file in www directory
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    # Include all required styles
    tags$style(HTML("
    /* Make sure table uses the full width */
    .table-container {
      width: 100%;
      overflow-x: auto;  /* Allow horizontal scrolling on small screens */
    }
    
    /* Chatbot specific styles */
    #chat_log {
      background-color: #1a1a1a;
      color: #e0e0e0;
      border: 1px solid #333;
      border-radius: 8px;
      font-family: 'Titillium Web', sans-serif;
      margin-bottom: 10px;
      resize: none;
    }
    
    #user_input {
      background-color: #1a1a1a;
      color: #e0e0e0;
      border: 1px solid #333;
      border-radius: 8px;
      margin-bottom: 10px;
      width: 100% !important; /* Force 100% width */
      box-sizing: border-box; /* Include padding and border in width calculation */
    }
    
    #send {
      background-color: #e10600;
      border-color: #e10600;
      color: white;
      font-weight: bold;
      border-radius: 8px;
      transition: all 0.3s ease;
      width: 100%;
    }
    
    #send:hover {
      background-color: #ff0000;
      border-color: #ff0000;
    }
    
    .control-panel h4 {
      color: white;
      margin-bottom: 15px;
      text-align: center;
      font-weight: bold;
    }
    
    /* Section headers */
    h3 {
      color: white;
      font-weight: bold;
      margin-top: 30px;
      margin-bottom: 20px;
      border-bottom: 2px solid #e10600;
      padding-bottom: 10px;
    }
    
    /* Example question buttons */
    .example-questions {
      margin-top: 10px;
      display: flex;
      flex-wrap: wrap;
      gap: 5px;
    }
    
    .example-question-btn {
      background-color: #333;
      color: white;
      border: none;
      border-radius: 15px;
      padding: 5px 10px;
      font-size: 0.8em;
      cursor: pointer;
      transition: all 0.3s ease;
    }
    
    .example-question-btn:hover {
      background-color: #e10600;
    }
    
    /* Assistant suggestions */
    .assistant-tip {
      font-size: 0.8em;
      color: #aaa;
      font-style: italic;
      margin-top: 5px;
    }
  "))
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
      
      # Podium visualization
      uiOutput("podiumVisualization"),
      
      # Results table and chatbot side by side
      div(class = "row",
          div(class = "col-12",
              h3("Race Results & Assistant")
          )
      ),
      div(class = "row",
          # Results table on the left
          div(class = "col-md-8",
              div(class = "table-container",
                  tableOutput("raceResults")
              )
          ),
          # Chatbot on the right
          div(class = "col-md-4",
              div(class = "control-panel",
                  h4("F1 Assistant"),
                  textAreaInput("chat_log", NULL, value = isolate(chat_history()), rows = 12, width = "100%"),
                  tags$script(HTML("$('#chat_log').prop('readonly', true);")),
                  
                  # Example questions the user can click
                  div(class = "example-questions",
                      actionButton("q_winner", "Race winner?", class = "example-question-btn"),
                      actionButton("q_tires", "Tire strategy?", class = "example-question-btn"),
                      actionButton("q_compare", "Compare drivers?", class = "example-question-btn"),
                      actionButton("q_facts", "Track facts?", class = "example-question-btn")
                  ),
                  
                  div(class = "assistant-tip", "I know about the race data above and below!"),
                  
                  textInput("user_input", NULL, placeholder = "Ask about the race data or F1...", width = "100%"),
                  tags$script(HTML("
          $(document).ready(function() {
            $('#user_input').keypress(function(event) {
              if (event.keyCode === 13) {
                $('#send').click();
                return false;
              }
            });
          });
        ")),
                  actionButton("send", "Send", icon = icon("paper-plane"))
              )
          )
      ),
      
      # Tire strategy visualization section
      div(class = "row",
          div(class = "col-12",
              h3("Tire Strategy")
          )
      ),
      div(class = "row",
          div(class = "col-12",
              plotOutput("tireStrategyPlot", height = "600px")
          )
      )
  )
)

# Server logic
server <- function(input, output, session) {
  # Store the current app data context
  app_context <- reactiveVal(list(
    year = NULL,
    track = NULL,
    race_details = NULL,
    race_summary = NULL,
    tire_summary = NULL
  ))
  
  # Update track dropdown when year is selected
  observeEvent(input$year, {
    updateSelectInput(session, "track", choices = NULL, selected = NULL)
    races_for_year <- races[races$year == input$year,]
    available_tracks <- setNames(races_for_year$name, paste0(races_for_year$name, " - Round ", races_for_year$round))
    updateSelectInput(session, "track", choices = available_tracks)
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
      paste0("+ ", ifelse(is.na(podium_order$Time[2]) || podium_order$position[2] == 1, "0.000", podium_order$Time[2])),
      paste0("+ ", ifelse(is.na(podium_order$Time[3]) || podium_order$position[3] == 1, "0.000", podium_order$Time[3]))
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
  output$raceResults <- renderTable({
    results <- race_data()
    if (is.null(results) || nrow(results) == 0) return(NULL)
    
    # Create a formatted version for display
    display_results <- results %>%
      select(Position, Driver, Code, Constructor, Time, Points) %>%
      mutate(
        Constructor = paste0(
          '<div style="display: flex; align-items: center; justify-content: center;">',
          '<img src="', results$Constructor_Image, '" height="30" style="margin-right: 10px;"> ',
          Constructor,
          '</div>'
        )
      )
    
    # Return the results with HTML formatting
    display_results
  },
  sanitize.text.function = function(x) x,
  striped = TRUE,
  hover = TRUE,
  bordered = TRUE,
  align = 'c',
  width = "100%",  # Ensure table uses full width available
  class = "table-custom")  # Add a custom class for styling
  
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
    
    # Use actual driver code
    driver_info$Driver_Code <- driver_info$code
    
    # Remove rows with missing driver info
    driver_info <- driver_info[!is.na(driver_info$Driver),]
    
    # Identify tire changes to determine stint boundaries
    driver_info <- driver_info %>%
      arrange(driverId, lap) %>%
      group_by(driverId) %>%
      mutate(
        tire_prev = lag(tireCompound, default = "NONE"),
        new_stint = tireCompound != tire_prev | is.na(tireCompound) != is.na(tire_prev),
        stint_number = cumsum(new_stint)
      ) %>%
      ungroup()
    
    # Summarize stint information (start lap, end lap, compound)
    stint_summary <- driver_info %>%
      filter(!is.na(tireCompound)) %>%
      group_by(driverId, Driver, Driver_Code, stint_number, tireCompound, compoundColor) %>%
      summarise(
        start_lap = min(lap),
        end_lap = max(lap),
        laps = end_lap - start_lap + 1,
        .groups = "drop"
      )
    
    # Order drivers according to race finish position
    driver_levels <- rev(results_order$Driver)
    driver_codes <- rev(results_order$Code)
    
    # Prepare data for visualization
    stint_summary$Driver_Name <- stint_summary$Driver  # Keep full name for hover
    stint_summary$Driver <- factor(stint_summary$Driver, levels = driver_levels)  # For ordering
    stint_summary$Driver_Code <- factor(stint_summary$Driver_Code,
                                        levels = driver_codes[match(driver_levels, results_order$Driver[order(results_order$position, decreasing = TRUE)])])
    
    # Adjust visual properties for short stints
    stint_summary$visual_width <- pmax(stint_summary$laps, 2)  # Minimum visual width
    stint_summary$label_x_adj <- ifelse(stint_summary$laps == 1, 0.5, 0)  # Adjust label position
    
    return(stint_summary)
  })
  
  # Render tire strategy plot
  output$tireStrategyPlot <- renderPlot({
    stints <- tire_stints()
    if (is.null(stints) || nrow(stints) == 0) {
      # Create an empty ggplot for when no data is available
      return(ggplot() +
               annotate("text", x = 0.5, y = 0.5, label = "No tire strategy data available",
                        color = "white", size = 6) +
               theme_void() +
               theme(
                 plot.background = element_rect(fill = "#0a0a0a", color = NA),
                 panel.background = element_rect(fill = "#0a0a0a", color = NA)
               ))
    }
    
    # Define F1 tire compound colors
    tire_colors <- c(
      "HARD" = "#FFFFFF",      # White
      "MEDIUM" = "#FED218",    # Yellow
      "SOFT" = "#DD0741",      # Red
      "SUPERSOFT" = "#DA0640", # Red
      "ULTRASOFT" = "#A9479E", # Purple
      "HYPERSOFT" = "#FEB4C3", # Pink
      "INTERMEDIATE" = "#45932F", # Green
      "WET" = "#2F6ECE"        # Blue
    )
    
    max_lap <- max(stints$end_lap, na.rm = TRUE)
    
    # Adjust visual width for short stints
    stints$visual_end_lap <- ifelse(stints$laps == 1,
                                    stints$start_lap + 1.5,  # Make 1-lap stints wider
                                    stints$end_lap + 1)      # Normal end lap + 1
    
    # Create strategy visualization with ggplot
    ggplot(stints, aes(xmin = start_lap, xmax = visual_end_lap, y = Driver_Code, fill = tireCompound)) +
      # Draw rectangles for tire stints
      geom_rect(aes(ymin = as.numeric(Driver_Code) - 0.4,
                    ymax = as.numeric(Driver_Code) + 0.4),
                color = "#222222", size = 0.1) +
      # Add lap count labels
      geom_text(aes(
        x = ifelse(laps <= 2,
                   start_lap + 0.75,  # Center text for short stints
                   start_lap + (end_lap - start_lap) / 2),  # Center text for normal stints
        y = Driver_Code,
        label = laps
      ),
      color = "black", size = 3.5, fontface = "bold") +
      # Apply tire colors
      scale_fill_manual(values = tire_colors, name = "Tire Compound") +
      # Add labels
      labs(
        title = paste("Tire Strategy:", input$track, input$year),
        subtitle = "Showing number of laps per compound",
        x = "Lap",
        y = ""
      ) +
      # Apply dark theme
      theme_minimal() +
      theme(
        text = element_text(family = "Titillium Web"),
        plot.background = element_rect(fill = "#0a0a0a", color = "#0a0a0a"),
        panel.background = element_rect(fill = "#0a0a0a", color = "#0a0a0a"),
        panel.grid.major.x = element_line(color = "#333333", size = 0.2),
        panel.grid.major.y = element_line(color = "#333333", size = 0.2),
        panel.grid.minor = element_blank(),
        plot.title = element_text(hjust = 0.5, size = 18, face = "bold", color = "white", margin = margin(b = 10)),
        plot.subtitle = element_text(hjust = 0.5, size = 12, color = "#cccccc", margin = margin(b = 20)),
        axis.text = element_text(color = "white", size = 10),
        axis.title = element_text(color = "white", size = 12),
        axis.text.y = element_text(size = 11, face = "bold", margin = margin(r = 5)),
        legend.background = element_rect(fill = "#0a0a0a"),
        legend.text = element_text(color = "white"),
        legend.title = element_text(color = "white", face = "bold"),
        legend.position = "bottom",
        legend.key = element_rect(color = NA),
        legend.key.size = unit(1, "cm"),
        plot.margin = margin(20, 20, 20, 20)
      ) +
      # Set x-axis breaks and limits
      scale_x_continuous(
        breaks = seq(1, max_lap + 5, by = 5),
        limits = c(1, max_lap + 2)
      )
  }, bg = "#0a0a0a", height = 600)
  
  # Update the app context whenever data changes
  observe({
    # Only run this when we have valid race data
    req(input$year, input$track)
    race_results <- race_data()
    tire_data <- tire_stints()
    
    if (is.null(race_results) || nrow(race_results) == 0) {
      race_summary <- "No race results available"
      podium_info <- NULL
    } else {
      # Get podium details
      podium <- race_results[race_results$position <= 3, ]
      if (nrow(podium) > 0) {
        podium_drivers <- paste(podium$Driver, collapse = ", ")
        winner <- podium$Driver[1]
        podium_info <- list(
          winner = winner,
          drivers = podium_drivers,
          constructors = paste(unique(podium$Constructor), collapse = ", ")
        )
      } else {
        podium_info <- NULL
      }
      
      # Create race summary stats
      finished_count <- sum(!is.na(race_results$position))
      dnf_count <- nrow(race_results) - finished_count
      
      race_summary <- list(
        total_drivers = nrow(race_results),
        finished = finished_count,
        dnf = dnf_count
      )
    }
    
    # Tire strategy summary
    if (!is.null(tire_data) && nrow(tire_data) > 0) {
      # Most used compound
      compounds_used <- table(tire_data$tireCompound)
      most_used_compound <- names(compounds_used)[which.max(compounds_used)]
      
      # Get pit stop counts by driver
      pit_stops <- tire_data %>%
        group_by(Driver) %>%
        summarize(
          pit_stops = max(stint_number) - 1,  # First stint doesn't count as a pit stop
          .groups = "drop"
        )
      
      max_pit_stops <- max(pit_stops$pit_stops)
      min_pit_stops <- min(pit_stops$pit_stops)
      
      drivers_with_most_stops <- pit_stops %>%
        filter(pit_stops == max_pit_stops) %>%
        pull(Driver)
      
      tire_summary <- list(
        compounds_used = names(compounds_used),
        most_common = most_used_compound,
        max_pit_stops = max_pit_stops,
        min_pit_stops = min_pit_stops,
        drivers_with_most_stops = paste(drivers_with_most_stops, collapse = ", ")
      )
    } else {
      tire_summary <- NULL
    }
    
    # Update the app_context reactive value
    app_context(list(
      year = input$year,
      track = input$track,
      race_summary = race_summary,
      podium = podium_info,
      tire_summary = tire_summary
    ))
  })
  
  # Create chatbot context information based on current app state
  format_chatbot_context <- reactive({
    context <- app_context()
    
    if (is.null(context$year) || is.null(context$track)) {
      return("No race selected yet.")
    }
    
    # Start with basic race information
    context_text <- paste0(
      "CURRENT DATA CONTEXT:\n",
      "Race: ", context$track, " Grand Prix ", context$year, "\n\n"
    )
    
    # Add race results information if available
    if (!is.null(context$race_summary) && !is.character(context$race_summary)) {
      context_text <- paste0(
        context_text,
        "Race Results:\n",
        "- Total drivers: ", context$race_summary$total_drivers, "\n",
        "- Finished: ", context$race_summary$finished, " drivers\n",
        "- DNF: ", context$race_summary$dnf, " drivers\n\n"
      )
    }
    
    # Add podium information if available
    if (!is.null(context$podium)) {
      context_text <- paste0(
        context_text,
        "Podium:\n",
        "- Winner: ", context$podium$winner, "\n",
        "- Top 3: ", context$podium$drivers, "\n\n"
      )
    }
    
    # Add tire strategy information if available
    if (!is.null(context$tire_summary)) {
      context_text <- paste0(
        context_text,
        "Tire Strategy:\n",
        "- Compounds used: ", paste(context$tire_summary$compounds_used, collapse = ", "), "\n",
        "- Most used compound: ", context$tire_summary$most_common, "\n",
        "- Pit stops: range from ", context$tire_summary$min_pit_stops, " to ", context$tire_summary$max_pit_stops, "\n",
        "- Drivers with most pit stops (", context$tire_summary$max_pit_stops, "): ", context$tire_summary$drivers_with_most_stops, "\n"
      )
    }
    
    return(context_text)
  })
  
  # Chatbot functionality
  observeEvent(input$send, {
    req(input$user_input)
    
    user_msg <- paste0("🏎️ You: ", input$user_input, "\n")
    updated_history <- paste0(chat_history(), user_msg)
    
    # Add data context and prompt prefix for consistent tone
    current_context <- format_chatbot_context()
    full_prompt <- paste0(style_prompt, current_context, "\n\n", updated_history, "🤖 F1 Bot:")
    
    # Formula 1 filter logic
    if (!grepl("\\bFormula 1\\b|\\bF1\\b|driver|team|race|Grand Prix|constructor|circuit|tire|tyre|pit|lap|championship|qualifying|podium|corner|DRS|penalty|engine|Ferrari|Mercedes|Red Bull|McLaren|Williams|Aston Martin|Alpine|strategy|fastest|pole|winner|track|session|points|helmet|steering|flag|safety car|Sprint|aero|downforce|drag|brake|brake bias|fuel|power unit|hybrid|turbo|engine mapping|ERS|MGU-K|MGU-H|battery|chassis|suspension|gearbox|wheel|pit stop|refueling|racecraft|lap time|time penalty|race director|virtual safety car|track limits|yellow flag|red flag|blue flag|green flag|white flag|black flag|team radio|strategy call|undercut|overcut|outlap|inlap|cold tire|warm-up lap|tyre compound|soft tire|medium tire|hard tire|wet tire|intermediate tire|super-soft tire|hard compound|scrubbed tire|tire wear|tire degradation|pit crew|pit wall|driver's briefing|team principal|race engineer|crew chief|onboard|telemetry|FIA|race weekend|practice session|free practice|Q1|Q2|Q3|race result|grid|starting grid|race distance|formation lap|track surface|circuit layout|sector time|split time|fuel load|reliability|engine failure|gearbox failure|retirement|constructor's championship|driver's championship|team orders|podium finish|ferrari driver|red bull driver|mercedes driver|overtake|defending|braking point|slipstream|DRS zone|traction|stint|race pace|lap record|track evolution|rain|wet conditions|dry conditions|slicks|pit strategy|track position|race simulation|long run|short run|team radio message|grid penalty|engine penalty|race debut|rookie|veteran|team principal|technical director|F1 fan|F1 media|F1 broadcast|Pirelli|FIA steward|FIA safety|F1 calendar|F1 season|trophy|trackside|pit lane|sector|double-stack|race marshal|F1 testing|pre-season testing|driver swap|team test|pre-season|post-race|team evaluation|practice pace|qualifying pace|race pace|race incident|race ban|weather conditions|race suspension|engine mode|clutch|launch control|cornering|aerodynamic balance|track position|runoff|gravel trap|curb|apex|racing line|car setup|car balance|toe|camber|downforce levels|drag reduction|tire pressures|tire temperature|brake temperature|brake balance|fuel strategy|fuel saving|brake duct|carbon fiber|weight distribution|rear wing|front wing|diffuser|undertray|sidepod|bargeboard|monocoque|floor|skid block|coasting|traction control|exhaust gases|throttle response|stability control|ABS|active suspension|electronic mapping|traction assist|launch phase|counter-steer|backmarker|position swap|race craft|wheel to wheel|qualifying lap|one-shot qualifying|lap time delta|team battle|engine mapping|fuel saving|pit lane exit|tire compound selection|F1 regulations|F1 rulebook|constructor penalty|driver penalty|race decision|penalty points|track limits violation",
               input$user_input, ignore.case = TRUE)) {
      bot_msg <- "🤖 F1 Bot: Sorry, I only know about Formula 1. Please ask me something F1-related.\n\n"
    } else {
      # Call Ollama API
      res <- tryCatch({
        POST(
          url = "http://localhost:11434/api/generate",
          body = list(
            model = "llama3:8b",
            prompt = full_prompt,
            stream = FALSE,
            num_predict = 150
          ),
          encode = "json",
          timeout(20)
        )
      }, error = function(e) {
        NULL
      })
      
      # Parse or show error
      if (!is.null(res) && status_code(res) == 200) {
        content <- content(res, "parsed", simplifyVector = TRUE)
        reply <- content$response
        bot_msg <- paste0("🤖 F1 Assistant: ", reply, "\n\n")
      } else {
        bot_msg <- "🤖 F1 Assistant: ⚠️ Error: Unable to connect to Gemma3. Is Ollama running?\n\n"
      }
    }
    
    chat_history(paste0(updated_history, bot_msg))
    
    # Update UI
    updateTextInput(session, "user_input", value = "")
    updateTextAreaInput(session, "chat_log", value = isolate(chat_history()))
  })
  
  # Handle example question button clicks
  observeEvent(input$q_winner, {
    updateTextInput(session, "user_input", value = "Who won this race?")
    # Trigger send button click after a slight delay to allow UI to update
    invalidateLater(100)
    session$sendCustomMessage(type = 'click_send', message = 'click')
  })
  
  observeEvent(input$q_tires, {
    updateTextInput(session, "user_input", value = "What tire strategies were used?")
    invalidateLater(100)
    session$sendCustomMessage(type = 'click_send', message = 'click')
  })
  
  observeEvent(input$q_compare, {
    updateTextInput(session, "user_input", value = "Compare the podium finishers' performance")
    invalidateLater(100)
    session$sendCustomMessage(type = 'click_send', message = 'click')
  })
  
  observeEvent(input$q_facts, {
    updateTextInput(session, "user_input", value = "Tell me some facts about this track")
    invalidateLater(100)
    session$sendCustomMessage(type = 'click_send', message = 'click')
  })
  
  # JavaScript to trigger the send button click
  observeEvent(input$send, {
    # This is just to make sure the send button exists in the DOM before we try to click it
    # The actual clicking is handled by the client-side JavaScript
  })
  
  # Add JavaScript to handle custom messages for button clicking
  session$onFlushed(function() {
    session$sendCustomMessage(type = 'initialize_click_handler', message = 'init')
  })
}

# Add custom JavaScript handler to the UI
ui <- tagList(
  ui,
  tags$script(HTML("
    Shiny.addCustomMessageHandler('click_send', function(message) {
      $('#send').click();
    });
    
    Shiny.addCustomMessageHandler('initialize_click_handler', function(message) {
      // This ensures the handler is set up once the UI is fully rendered
    });
  "))
)

# Start the Shiny app
shinyApp(ui = ui, server = server)



