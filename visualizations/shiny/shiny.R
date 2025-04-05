library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(here)

# Load data files from the clean-data directory
status <- read.csv(here("data", "clean-data", "status.csv"))
races <- read.csv(here("data", "clean-data", "races.csv"))
drivers <- read.csv(here("data", "clean-data", "drivers.csv"))
results <- read.csv(here("data", "clean-data", "results.csv"))
constructors <- read.csv(here("data", "clean-data", "constructors.csv"))
stints <- read.csv(here("data", "clean-data", "stints.csv"))

# Points allocation for positions 1-10
points_table <- c(25, 18, 15, 12, 10, 8, 6, 4, 2, 1)

# UI Definition
ui <- fluidPage(
  # Link to external CSS file in www directory
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),

  # App title
  titlePanel(
    "F1 Race Analysis"
  ),

  # Year and track selection inputs
  fluidRow(
    column(6,
           selectInput("year", "Year", choices = unique(races$year), selected = NULL)
    ),
    column(6,
           selectInput("track", "Track", choices = NULL)
    )
  ),

  # Results table section
  h3("Race Results"),
  tableOutput("raceResults"),

  # Tire strategy visualization section
  h3("Tire Strategy"),
  plotlyOutput("tireStrategyPlot", height = "600px")
)

# Server logic
server <- function(input, output, session) {
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
    race_results <- merge(results_filtered, drivers, by = "driverId")

    # Clean up missing values
    race_results$time <- ifelse(race_results$time == "\\N", NA, race_results$time)
    race_results$position <- ifelse(race_results$position == "\\N", NA, race_results$position)

    # Add status and constructor information
    race_results <- merge(race_results, status, by = "statusId", all.x = TRUE)
    race_results <- merge(race_results, constructors, by = "constructorId", all.x = TRUE)

    # Convert position to numeric
    race_results$position <- as.numeric(race_results$position)

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

    # Create 3-letter driver codes
    race_results$Driver_Code <- toupper(substr(race_results$surname, 1, 3))

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

    # Create final dataset for display
    result_subset <- data.frame(
      Position = race_results$formatted_position,
      Driver = race_results$Driver,
      Code = race_results$Driver_Code,
      Time = race_results$time,
      Constructor = race_results[[constructor_col]],
      Points = race_results$Points,
      driverId = race_results$driverId
    )

    return(result_subset)
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

    # Create 3-letter driver codes
    driver_info$Driver_Code <- toupper(substr(driver_info$surname, 1, 3))

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
    driver_levels <- results_order$Driver
    driver_codes <- results_order$Code

    # Prepare data for visualization
    stint_summary$Driver_Name <- stint_summary$Driver  # Keep full name for hover
    stint_summary$Driver <- factor(stint_summary$Driver, levels = driver_levels)  # For ordering
    stint_summary$Driver_Code <- factor(stint_summary$Driver_Code,
                                        levels = driver_codes[match(driver_levels, results_order$Driver)])

    # Adjust visual properties for short stints
    stint_summary$visual_width <- pmax(stint_summary$laps, 2)  # Minimum visual width
    stint_summary$label_x_adj <- ifelse(stint_summary$laps == 1, 0.5, 0)  # Adjust label position

    return(stint_summary)
  })

  # Render results table
  output$raceResults <- renderTable({
    results <- race_data()
    if (is.null(results)) return(NULL)

    # Remove driver ID column before display
    results$driverId <- NULL

    results
  }, striped = TRUE, hover = TRUE, bordered = TRUE)

  # Render tire strategy plot
  output$tireStrategyPlot <- renderPlotly({
    stints <- tire_stints()
    if (is.null(stints) || nrow(stints) == 0) {
      return(NULL)
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

    # Create hover text for interactive display
    stints$hover_text <- paste0(
      stints$Driver_Name, "<br>",  # Use full name in the hover
      stints$tireCompound, ": ", stints$laps, " Laps<br>",
      "Laps ", stints$start_lap, "-", stints$end_lap
    )

    # Adjust visual width for short stints
    stints$visual_end_lap <- ifelse(stints$laps == 1,
                                    stints$start_lap + 1.5,  # Make 1-lap stints wider
                                    stints$end_lap + 1)      # Normal end lap + 1

    # Create strategy visualization with ggplot
    p <- ggplot(stints, aes(xmin = start_lap, xmax = visual_end_lap, y = Driver_Code, fill = tireCompound)) +
      # Draw rectangles for tire stints
      geom_rect(aes(ymin = as.numeric(Driver_Code) - 0.4,
                    ymax = as.numeric(Driver_Code) + 0.4,
                    text = hover_text),
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
        plot.background = element_rect(fill = "#121212", color = "#121212"),
        panel.background = element_rect(fill = "#121212", color = "#121212"),
        panel.grid.major.x = element_line(color = "#333333", size = 0.2),
        panel.grid.major.y = element_line(color = "#333333", size = 0.2),
        panel.grid.minor = element_blank(),
        plot.title = element_text(hjust = 0.5, size = 18, face = "bold", color = "white", margin = margin(b = 10)),
        plot.subtitle = element_text(hjust = 0.5, size = 12, color = "#cccccc", margin = margin(b = 20)),
        axis.text = element_text(color = "white", size = 10),
        axis.title = element_text(color = "white", size = 12),
        axis.text.y = element_text(size = 11, face = "bold", margin = margin(r = 5)),
        legend.background = element_rect(fill = "#121212"),
        legend.text = element_text(color = "white"),
        legend.title = element_text(color = "white", face = "bold"),
        legend.position = "bottom",
        legend.key = element_rect(color = NA),
        legend.key.size = unit(1, "cm"),
        plot.margin = margin(20, 20, 20, 20)
      ) +
      # Set x-axis breaks and limits
      scale_x_continuous(
        breaks = seq(0, max_lap + 5, by = 5),
        limits = c(0, max_lap + 2)
      )

    # Convert to interactive plotly visualization
    ggplotly(p, tooltip = "text") %>%
      layout(
        hoverlabel = list(
          bgcolor = "black",
          bordercolor = "white",
          font = list(family = "Titillium Web", size = 12, color = "white")
        ),
        legend = list(
          orientation = "h",
          y = -0.15
        )
      ) %>%
      config(displayModeBar = FALSE)
  })
}

# Start the Shiny app
shinyApp(ui = ui, server = server)