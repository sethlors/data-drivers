# R/ui-elements.R

# Creates the main control panel for year and track selection
create_control_panel <- function(id, years) {
  ns <- NS(id)
  div(class = "control-panel",
      div(class = "row",
          div(class = "col-md-6",
              selectInput(ns("year"), "Year", choices = years, selected = years[1])
          ),
          div(class = "col-md-6",
              selectInput(ns("track"), "Track", choices = NULL) # Populated dynamically
          )
      )
  )
}

# Creates the podium visualization UI placeholder
create_podium_output <- function(id) {
  ns <- NS(id)
  uiOutput(ns("podiumVisualization"))
}

# Creates the race results table UI placeholder
create_results_table_output <- function(id) {
  ns <- NS(id)
  div(class = "table-container",
      tableOutput(ns("raceResultsTable"))
  )
}

# Creates the tire strategy plot UI placeholder
create_tire_plot_output <- function(id) {
  ns <- NS(id)
  plotOutput(ns("tireStrategyPlot"), height = "600px")
}

# Creates the CSS and JS includes for the head
create_html_head <- function() {
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    # Add shinyjs use
    shinyjs::useShinyjs(),
    # Keep essential JS snippets if needed, like the enter key press
    tags$script(HTML("
      // Allow pressing Enter in text input to trigger send button
      $(document).on('keypress', '#chatbot-user_input', function(e) {
          if (e.which == 13) {
              $('#chatbot-send').click();
              return false; // Prevent default form submission
          }
      });
      // Make chat log read-only (can also be done server-side)
      $(document).on('shiny:connected', function(event) {
          $('#chatbot-chat_log').prop('readonly', true);
      });
    "))
    # Note: The custom message handler logic is better placed in server.R or chatbot module
  )
}

# Creates the podium box for a single driver
create_podium_box <- function(driver_data, position_label, time_diff) {
    col_width <- 4 # Assuming 3 boxes in a row
    column(col_width,
           div(class = "podium-box",
               style = paste0("background-color: ", adjustColor(driver_data$constructorColor), ";"),
               div(class = "box-gradient"), # Gradient overlay
               img(class = "driver-img", src = driver_data$Driver_Image),
               img(class = "constructor-img", src = driver_data$Constructor_Image),
               div(class = "glass-footer",
                   div(class = "driver-code", driver_data$Code),
                   div(class = "position-label", position_label),
                   div(class = "time-diff", time_diff)
               )
           )
    )
}