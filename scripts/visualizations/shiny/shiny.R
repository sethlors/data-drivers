library(shiny)
library(dplyr)
library(here)

status <- read.csv(here("data", "clean-data", "status.csv"))
races <- read.csv(here("data", "clean-data", "races.csv"))
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
  
  race_data <- reactive({
    selected_race <- races[races$year == input$year, ]
    selected_race_name <- input$track  # Get selected race name from input
    
    race_ids <- selected_race$raceId[selected_race$name == selected_race_name]
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
}

shinyApp(ui = ui, server = server)
