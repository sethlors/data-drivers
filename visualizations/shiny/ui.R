# ui.R

source("global.R", local = TRUE)
source("R/utils.R", local = TRUE)
source("R/ui-elements.R", local = TRUE)
source("R/chatbot-module.R", local = TRUE)

ui <- fluidPage(
  # Add head elements (CSS, JS)
  create_html_head(),

  div(class = "container-fluid",
      # Header
      div(class = "row",
          div(class = "col-12 text-center",
              h2("F1 Race Analysis")
          )
      ),

      # Control Panel (Year/Track)
      div(class = "row",
          div(class = "col-12",
              # Use a namespace for the main controls if needed, e.g., "controls"
              create_control_panel("controls", AVAILABLE_YEARS)
          )
      ),

      # Podium Visualization Output (Give it an ID like "podium")
      create_podium_output("podium"), # Use uiOutput for dynamic rendering

      # Results and Assistant Section
      div(class = "row",
          div(class = "col-12",
              h3("Race Results & Assistant") # Section Header
          )
      ),
      div(class = "row",
          # Results Table Column
          div(class = "col-md-8",
              # Use ID "results"
              create_results_table_output("results")
          ),
          # Chatbot Column
          div(class = "col-md-4",
              # Call the chatbot UI module function
              chatbotUI("chatbot") # Use ID "chatbot"
          )
      ),

      # Tire Strategy Section
      div(class = "row",
          div(class = "col-12",
              h3("Tire Strategy") # Section Header
          )
      ),
      div(class = "row",
          div(class = "col-12",
              # Use ID "tires"
              create_tire_plot_output("tires")
          )
      )
  ) # End container-fluid
) # End fluidPage