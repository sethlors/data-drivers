# Load necessary packages
library(shiny)
library(ggplot2)

# Generate sample F1 tire compound data
set.seed(42)
data <- data.frame(
  Compound = factor(rep(c("Soft", "Medium", "Hard"), each = 50)), # Ensure Compound is a factor
  LapTime = c(rnorm(50, mean = 1.25, sd = 0.05),
              rnorm(50, mean = 1.30, sd = 0.05),
              rnorm(50, mean = 1.35, sd = 0.05)),
  TireLife = c(runif(50, min = 5, max = 15),
               runif(50, min = 10, max = 25),
               runif(50, min = 20, max = 40))
)

# Define UI
ui <- fluidPage(
  titlePanel("F1 Tire Compound Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectInput("compound", "Select Tire Compound:",
                  choices = levels(data$Compound),
                  selected = "Soft") # Default selection
    ),
    mainPanel(
      plotOutput("lapTimePlot"),
      plotOutput("boxPlot"),
      plotOutput("scatterPlot")
    )
  )
)

# Define Server
server <- function(input, output) {

  # Debugging: Print selected compound
  observe({
    print(paste("Selected Compound:", input$compound))
  })

  # Filter data based on selected compound
  filtered_data <- reactive({
    req(input$compound) # Ensure input is not NULL
    data[data$Compound == input$compound, ]
  })

  output$lapTimePlot <- renderPlot({
    ggplot(filtered_data(), aes(x = LapTime)) +
      geom_histogram(binwidth = 0.01, fill = "steelblue", color = "black") +
      labs(title = paste("Lap Time Distribution for", input$compound, "Tires"),
           x = "Lap Time (seconds)", y = "Frequency") +
      theme_minimal()
  })

  output$boxPlot <- renderPlot({
    ggplot(data, aes(x = Compound, y = LapTime, fill = Compound)) +
      geom_boxplot() +
      labs(title = "Lap Time Comparison by Tire Compound",
           x = "Tire Compound", y = "Lap Time (seconds)") +
      theme_minimal()
  })

  output$scatterPlot <- renderPlot({
    ggplot(filtered_data(), aes(x = TireLife, y = LapTime)) +
      geom_point(color = "red") +
      geom_smooth(method = "lm", se = FALSE, color = "blue") +
      labs(title = paste("Tire Life vs Lap Time for", input$compound, "Tires"),
           x = "Tire Life (laps)", y = "Lap Time (seconds)") +
      theme_minimal()
  })
}

# Run the application
shinyApp(ui = ui, server = server)