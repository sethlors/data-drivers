# Load necessary libraries
library(shiny)
library(ggplot2)
library(dplyr)

# Load data from URLs
race_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/feature/restructure-repo/data/clean-data/races.csv"
lap_time_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/feature/restructure-repo/data/clean-data/lap_times.csv"
drivers_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/feature/restructure-repo/data/clean-data/drivers.csv"
circuits_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/feature/restructure-repo/data/clean-data/circuits.csv"

# Read CSV files
races <- read.csv(race_url)
lap_times <- read.csv(lap_time_url)
drivers <- read.csv(drivers_url)
circuits <- read.csv(circuits_url)

# Select relevant columns and join data
races <- races %>% select(raceId, year, round, circuitId, date)
df <- lap_times %>%
  left_join(drivers, by = "driverId") %>%
  left_join(races, by = "raceId") %>%
  left_join(circuits, by = "circuitId") %>%
  select(raceId, driverId, driverRef, year, round, 
         circuitId, name, lap, milliseconds)

# Convert milliseconds to MM:SS.sss format
df <- df %>%
  mutate(time = sprintf("%02d:%06.3f", milliseconds %/% 60000, (milliseconds %% 60000) / 1000)) %>%
  mutate(time_seconds = milliseconds / 1000)  # Convert ms → seconds

# Define UI
ui <- fluidPage(
  titlePanel("F1 Lap Time Progression"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("selected_circuit", "Select Circuit:", choices = unique(df$name), selected = unique(df$name)[1]),
      uiOutput("race_selector"),  # Dynamic race selection
      uiOutput("year_selector"),  # Dynamic year selection
      uiOutput("driver_selector"),  # Dynamic driver selection
      uiOutput("lap_selector")  # Optional lap selection
    ),
    
    mainPanel(
      plotOutput("lap_time_plot")
    )
  )
)

# Define Server
server <- function(input, output, session) {
  
  # Update available races based on selected circuit
  output$race_selector <- renderUI({
    races_filtered <- df %>% filter(name == input$selected_circuit)
    selectInput("selected_race", "Select Race ID:", choices = unique(races_filtered$raceId))
  })
  
  # Update available years based on selected race
  output$year_selector <- renderUI({
    req(input$selected_race)  # Ensure a race is selected first
    years_available <- df %>% filter(raceId == input$selected_race) %>% pull(year) %>% unique()
    selectInput("selected_year", "Select Year:", choices = years_available, selected = min(years_available))
  })
  
  output$driver_selector <- renderUI({
    req(input$selected_race)  # Ensure a race is selected first
    drivers_available <- df %>% filter(raceId == input$selected_race) %>% pull(driverRef) %>% unique()
    selectInput("selected_drivers", "Select Drivers:", 
                choices = drivers_available, 
                selected = drivers_available,  # Default to all drivers selected
                multiple = TRUE)
  })
  
  # Allow filtering of laps, but show all initially
  output$lap_selector <- renderUI({
    req(input$selected_race)  # Ensure a race is selected first
    laps_available <- df %>% filter(raceId == input$selected_race) %>% pull(lap) %>% unique()
    selectInput("selected_laps", "Filter Laps (Optional):", choices = laps_available, selected = laps_available, multiple = TRUE)
  })
  
  filtered_data <- reactive({
    req(input$selected_race, input$selected_year, input$selected_drivers)  # Ensure all selections exist
    
    df %>%
      filter(
        raceId == input$selected_race,
        year == input$selected_year,
        driverRef %in% input$selected_drivers,  # Ensure this line is filtering properly
        lap %in% input$selected_laps  # Ensure lap filtering is also applied
      )
  })
  
  # Render Lap Time Plot
  output$lap_time_plot <- renderPlot({
    data <- filtered_data()
    
    ggplot(data, aes(x = lap, y = time_seconds, color = driverRef, group = driverRef)) +
      geom_line() +  # Line for each driver
      geom_point() +  # Points for each lap
      geom_point(data = data %>% filter(time_seconds == min(time_seconds)), 
                 aes(x = lap, y = time_seconds), 
                 color = "red", size = 3) +  # Highlight fastest lap
      labs(title = paste("Lap Time Progression -", input$selected_circuit, "Race", input$selected_race, "(", input$selected_year, ")"),
           x = "Lap Number", 
           y = "Lap Time (Milliseconds)", 
           color = "Driver") +
      theme_minimal()
  })
}

# Run the app
shinyApp(ui = ui, server = server)