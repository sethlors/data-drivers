library(shiny)
library(dplyr)
library(ggplot2)
library(here)

# Load data
status <- read.csv(here("data", "clean-data", "status.csv"))
races <- read.csv(here("data", "clean-data", "races.csv"))
drivers <- read.csv(here("data", "clean-data", "drivers.csv"))
results <- read.csv(here("data", "clean-data", "results.csv"))
constructors <- read.csv(here("data", "clean-data", "constructors.csv"))
stints <- read.csv(here("data", "clean-data", "stints.csv"))

# Points Allocation based on Position
points_table <- c(25, 18, 15, 12, 10, 8, 6, 4, 2, 1)  # Points for positions 1-10

ui <- fluidPage(
  titlePanel("F1 Race Analysis"),
  
  fluidRow(
    column(6,
           selectInput("year", "Year", choices = unique(races$year), selected = NULL)
    ),
    column(6,
           selectInput("track", "Track", choices = NULL)
    )
  ),
  
  # Display results table
  h3("Race Results"),
  tableOutput("raceResults"),
  
  # Display tire strategy chart
  h3("Tire Strategy"),
  plotOutput("tireStrategyPlot", height = "600px")
)

server <- function(input, output, session) {
  observeEvent(input$year, {
    # Reset the track selection when year changes
    updateSelectInput(session, "track", choices = NULL, selected = NULL)
    # Filter races for the selected year
    races_for_year <- races[races$year == input$year, ]
    # Create named choices (Display: "Race Name - Round X", Actual Value: "Race Name")
    available_tracks <- setNames(races_for_year$name, paste0(races_for_year$name, " - Round ", races_for_year$round))
    updateSelectInput(session, "track", choices = available_tracks)
  })
  
  selected_race_id <- reactive({
    req(input$year, input$track)
    selected_race <- races[races$year == input$year & races$name == input$track, ]
    if(nrow(selected_race) > 0) {
      return(selected_race$raceId[1])
    } else {
      return(NULL)
    }
  })
  
  race_data <- reactive({
    req(selected_race_id())
    
    results_filtered <- results[results$raceId == selected_race_id(), ]
    race_results <- merge(results_filtered, drivers, by = "driverId")
    
    # Replace '\\N' with NA for time columns and clean up position column
    race_results$time <- ifelse(race_results$time == "\\N", NA, race_results$time)
    race_results$position <- ifelse(race_results$position == "\\N", NA, race_results$position)
    
    # Merge with status and constructors
    race_results <- merge(race_results, status, by = "statusId", all.x = TRUE)
    race_results <- merge(race_results, constructors, by = "constructorId", all.x = TRUE)
    
    # Convert position to numeric
    race_results$position <- as.numeric(race_results$position)
    
    # For non-finishing positions, replace with the actual status message
    race_results$time <- ifelse(!is.na(race_results$time), race_results$time, race_results$status)
    
    # Create the Driver column
    race_results$Driver <- paste(race_results$forename, race_results$surname)
    
    # Sort by position
    race_results <- race_results[order(race_results$position), ]
    
    # Assign points based on position
    race_results$Points <- ifelse(race_results$position >= 1 & race_results$position <= 10,
                                  points_table[race_results$position], 0)
    race_results$Points <- paste0("+", race_results$Points)
    
    # Check which constructor name column exists
    constructor_col <- ifelse("name.y" %in% colnames(race_results), "name.y", 
                              ifelse("name.1" %in% colnames(race_results), "name.1", "name"))
    
    # Create a subset with only needed columns
    # Use dynamic column referencing to avoid errors
    result_subset <- data.frame(
      Position = race_results$position,
      Driver = race_results$Driver,
      Time = race_results$time,
      Constructor = race_results[[constructor_col]],
      Points = race_results$Points,
      driverId = race_results$driverId
    )
    
    return(result_subset)
  })
  
  # Prepare tire stints data
  tire_stints <- reactive({
    req(selected_race_id())
    
    # Get race results for driver order
    results_order <- race_data()
    if(is.null(results_order) || nrow(results_order) == 0) return(NULL)
    
    # Get all stints for this race
    race_stints <- stints[stints$raceId == selected_race_id(), ]
    if(nrow(race_stints) == 0) return(NULL)
    
    # Get driver info and create a Driver column
    driver_info <- merge(race_stints, drivers, by = "driverId", all.x = TRUE)
    driver_info$Driver <- paste(driver_info$forename, driver_info$surname)
    
    # Filter out NA Driver values
    driver_info <- driver_info[!is.na(driver_info$Driver), ]
    
    # Process the stint data - identify tire changes
    # We'll consider each sequence of laps with the same compound as one stint
    driver_info <- driver_info %>%
      arrange(driverId, lap) %>%
      group_by(driverId) %>%
      mutate(
        tire_prev = lag(tireCompound, default = "NONE"),
        new_stint = tireCompound != tire_prev | is.na(tireCompound) != is.na(tire_prev),
        stint_number = cumsum(new_stint)
      ) %>%
      ungroup()
    
    # Summarize stint information
    stint_summary <- driver_info %>%
      filter(!is.na(tireCompound)) %>%
      group_by(driverId, Driver, stint_number, tireCompound, compoundColor) %>%
      summarise(
        start_lap = min(lap),
        end_lap = max(lap),
        laps = end_lap - start_lap + 1,
        .groups = "drop"
      )
    
    # Order drivers according to race finish position
    stint_summary$Driver <- factor(stint_summary$Driver, levels = results_order$Driver)
    
    return(stint_summary)
  })
  
  # Output the race results table
  output$raceResults <- renderTable({
    results <- race_data()
    if(is.null(results)) return(NULL)
    
    # Remove driverId column for display
    results$driverId <- NULL
    return(results)
  })
  
  # Output the tire strategy plot
  output$tireStrategyPlot <- renderPlot({
    stints <- tire_stints()
    if(is.null(stints) || nrow(stints) == 0) {
      return(NULL)
    }
    
    tire_colors <- c(
      "HARD" = "#FFFFFF",
      "MEDIUM" = "#FED218",
      "SOFT" = "#DD0741",
      "SUPERSOFT" = "#DA0640",
      "ULTRASOFT" = "#A9479E",
      "HYPERSOFT" = "#FEB4C3",
      "INTERMEDIATE" = "#45932F",
      "WET" = "#2F6ECE"
    )
    
    
    
    # Create the plot with dark theme
    ggplot(stints, aes(xmin = start_lap, xmax = end_lap, y = Driver, fill = tireCompound)) +
      geom_rect(aes(ymin = as.numeric(Driver) - 0.4, ymax = as.numeric(Driver) + 0.4), color = "#444444") +
      geom_text(aes(x = start_lap + (end_lap - start_lap)/2, y = Driver, label = laps), 
                color = "black", size = 3) +
      scale_fill_manual(values = tire_colors, name = "Tire Compound") +
      labs(
        title = paste("Tire Strategy:", input$track, input$year),
        x = "Lap",
        y = ""
      ) +
      theme_dark() +
      theme(
        plot.background = element_rect(fill = "#121212", color = "#121212"),
        panel.background = element_rect(fill = "#121212", color = "#121212"),
        panel.grid.major = element_line(color = "#333333"),
        panel.grid.minor = element_blank(),
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold", color = "white"),
        axis.text = element_text(color = "white"),
        axis.title = element_text(color = "white"),
        axis.text.y = element_text(size = 12),
        legend.background = element_rect(fill = "#121212"),
        legend.text = element_text(color = "white"),
        legend.title = element_text(color = "white"),
        legend.position = "bottom",
        legend.key = element_rect(color = "#333333")
      ) +
      scale_x_continuous(
        breaks = seq(0, max(stints$end_lap, na.rm = TRUE) + 5, by = 5),
        limits = c(0, max(stints$end_lap, na.rm = TRUE) + 5)
      )
  })
}

shinyApp(ui = ui, server = server)
