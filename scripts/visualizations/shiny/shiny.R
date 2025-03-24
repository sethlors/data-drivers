library(shiny)
library(dplyr)
library(f1dataR)
library(here)


# Sample Data (replace with your actual data)

status <- read.csv(here("data", "clean-data", "status.csv"))
races <- read.csv(here("data", "clean-data", "races.csv"))
circuits <- read.csv(here("data", "clean-data", "circuits.csv"))
drivers <- read.csv(here("data", "clean-data", "drivers.csv"))
results <- read.csv(here("data", "clean-data", "results.csv"))
constructors <- read.csv(here("data", "clean-data", "constructors.csv"))


# Points Allocation based on Position
points_table <- c(25, 18, 15, 12, 10, 8, 6, 4, 2, 1)  # Points for positions 1-10

ui <- fluidPage(
  titlePanel("F1 Race Results with Points"),
  
  fluidRow(
    column(6, 
           selectInput("year", "Year", choices = unique(races$year), selected = NULL)
    ),
    column(6,
           selectInput("track", "Track", choices = NULL)
    )
  ),
  
  tableOutput("raceResults"),
  plotOutput("fastestLapPlot")  # Add the plot output for fastest lap
)

server <- function(input, output, session) {
  
  observe({
    most_recent_year <- max(races$year)
    updateSelectInput(session, "year", selected = most_recent_year)
    
    races_for_year <- races[races$year == most_recent_year, ]
    
    most_recent_race <- races_for_year[which.max(races_for_year$raceId), ]
    selected_track <- circuits[circuits$circuitId == most_recent_race$circuitId, "name"]
    
    updateSelectInput(session, "track", choices = circuits[circuits$circuitId %in% races_for_year$circuitId, "name"], selected = selected_track)
  })
  
  race_data <- reactive({
    selected_race <- races[races$year == input$year, ]
    selected_circuit <- circuits[circuits$name == input$track, ]
    
    race_ids <- selected_race$raceId[selected_race$circuitId == selected_circuit$circuitId]
    if (length(race_ids) == 0) {
      return(NULL)
    }
    
    results_filtered <- results[results$raceId %in% race_ids, ]
    
    race_results <- merge(results_filtered, drivers, by = "driverId")
    
    # Replace '\\N' with NA for time columns and clean up position column
    race_results$time <- gsub("\\\\N", NA, race_results$time)
    race_results$position <- gsub("\\\\N", NA, race_results$position)
    
    race_results <- merge(race_results, status, by = "statusId", all.x = TRUE)
    race_results <- merge(race_results, constructors, by = "constructorId", all.x = TRUE)
    
    # Convert position to numeric
    race_results$position <- as.numeric(race_results$position)
    
    # For "DNF" positions, replace with the actual status message instead of "DNF"
    race_results$time <- ifelse(!is.na(race_results$time), race_results$time, race_results$status)
    
    # Create the Driver column
    race_results$Driver <- paste(race_results$forename, race_results$surname)
    
    race_results$position <- as.integer(race_results$position)
    
    # Sort by position
    race_results <- race_results[order(race_results$position), ]
    
    # Assign points based on position
    race_results$Points <- ifelse(race_results$position >= 1 & race_results$position <= 10, 
                                  points_table[race_results$position], 0)
    
    # Convert points to a string (e.g., "+25", "+18")
    race_results$Points <- paste0("+", race_results$Points)
    
    # Keep only relevant columns and rename them
    race_results <- race_results[, c("position", "Driver", "time", "name", "Points")]
    colnames(race_results) <- c("Position", "Driver", "Time", "Constructor", "Points")
    
    return(race_results)
  })
  
  output$raceResults <- renderTable({
    race_data()
  })
  
  # Function to find the driver with the fastest lap in a given race
  get_fastest_driver <- function(season, round) {
    selected_race <- races[races$year == season & races$round == round, ]
    
    if (nrow(selected_race) == 0) {
      return(NULL)  # If no race is found, return NULL
    }
    
    selected_results <- results[results$raceId == selected_race$raceId, ]
    
    if (nrow(selected_results) == 0) {
      return(NULL)  # If no results are found, return NULL
    }
    
    # Find the driver with the fastest lap time (min value)
    fastest_lap_driver_id <- selected_results[which.min(selected_results$fastestLap), ]$driverId
    fastest_driver <- drivers[drivers$driverId == fastest_lap_driver_id, ]
    
    if (nrow(fastest_driver) == 0) {
      return(NULL)  # If no fastest driver is found, return NULL
    }
    
    return(fastest_driver$forename)
  }
  
  # Render the fastest lap plot using plot_fastest from f1dataR
  output$fastestLapPlot <- renderPlot({
    season <- input$year
    round <- as.integer(input$track)  # Assuming track corresponds to round for plotting
    
    driver <- "VER"
    
    if (is.null(driver)) {
      return(NULL)  # If no driver is found, don't plot anything
    }
    
    # Use f1dataR's plot_fastest function with the necessary parameters
    plot_fastest(season = season, 
                 round = round, 
                 session = "R", 
                 driver = driver, 
                 color = "speed")
  })
}

shinyApp(ui = ui, server = server)