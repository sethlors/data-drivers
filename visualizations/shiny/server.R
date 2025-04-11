# server.R

server <- function(input, output, session) {

  # --- Reactive Values ---
  # Stores dynamic context summary for the chatbot
  app_context <- reactiveVal(list(
    year = NULL,
    track = NULL,
    race_summary = NULL,
    podium = NULL,
    tire_summary = NULL
  ))

  # --- Dynamic UI Updates ---
  # Update track selection based on chosen year, sorted by round
  observeEvent(input$`controls-year`, {
    # Ensure the year input is available and valid before proceeding
    req(input$`controls-year`)

    # Get the selected year value from the input
    year_selected <- input$`controls-year`

    # Filter the global 'races' data frame for the selected year
    races_for_year <- races[races$year == year_selected,]

    # --- Sort the filtered data frame by the 'round' column ---
    # This ensures the tracks are ordered chronologically
    races_for_year <- races_for_year[order(races_for_year$round),]

    # Create the named list for the dropdown choices
    # The 'values' (what Shiny receives when selected) are the track names (races_for_year$name)
    # The 'names' (what the user sees) are formatted as "Track Name - Round X"
    available_tracks <- setNames(
      races_for_year$name, # Values
      paste0(races_for_year$name, " - Round ", races_for_year$round) # Display Names
    )

    # Update the 'controls-track' selectInput with the new choices
    updateSelectInput(
      session,                          # The Shiny session object
      "controls-track",                 # The ID of the input to update
      choices = available_tracks,       # The sorted list of choices
      selected = if (length(available_tracks) > 0) available_tracks[1] else NULL
      # Automatically select the first track (Round 1) from the sorted list
      # Handles cases where a year might have no races (returns NULL)
    )
  }) # End observeEvent for year input

  # --- Core Data Reactives ---
  # Get the selected race ID
  selected_race_id <- reactive({
    req(input$`controls-year`, input$`controls-track`, nzchar(input$`controls-track`))
    # Find the raceId based on year and the selected track name (value part of selectInput)
    selected_race <- races[races$year == input$`controls-year` & races$name == input$`controls-track`,]
    if (nrow(selected_race) > 0) {
      return(selected_race$raceId[1])
    } else {
      return(NULL)
    }
  })

  # Reactive for processed race results data
  race_data <- reactive({
    req(selected_race_id())
    process_race_results(selected_race_id(), results, drivers, status, constructors)
  })

  # Reactive for processed tire stint data
  tire_stints_data <- reactive({
    req(selected_race_id())
    # Pass race_data() to order drivers correctly in the plot
    process_stint_data(selected_race_id(), stints, drivers, race_data())
  })

  # --- Update App Context ---
  # Observe changes in race/tire data and update the context summary
  observe({
    # Depend on the core data reactives
    current_race_results <- race_data()
    current_tire_data <- tire_stints_data()
    selected_year <- input$`controls-year`
    selected_track <- input$`controls-track`

    # Generate the summary structure
    context_summary <- generate_context_summary(current_race_results, current_tire_data)

    # Update the main reactiveVal
    app_context(list(
      year = selected_year,
      track = selected_track,
      race_summary = context_summary$race_summary,
      podium = context_summary$podium,
      tire_summary = context_summary$tire_summary
    ))
  })


  # --- Render Outputs ---

  # Render Podium UI (within the "podium" namespace)
  output$`podium-podiumVisualization` <- renderUI({
    results_df <- race_data()
    req(results_df, nrow(results_df) >= 3) # Need at least 3 finishers

    podium <- results_df %>%
      filter(position %in% 1:3) %>%
      arrange(position)

    # Basic validation
    if (nrow(podium) != 3 || !all(podium$position == 1:3)) {
      return(div(class = "error-message", "Podium data incomplete or unavailable."))
    }

    # Time differences (simplified - assumes 'Time' column holds interval for P2/P3)
    # Requires Time column to be processed correctly in process_race_results
    # This might need refinement based on how 'Time' is actually structured (total time vs interval)
    time_diffs <- c(
      "Winner", # P1
      podium$Time[2] %||% "+ N/A", # P2 interval (needs '+' prefix if not included)
      podium$Time[3] %||% "+ N/A"  # P3 interval
    )
    # Ensure '+' prefix if it's just a number
    time_diffs[2:3] <- sapply(time_diffs[2:3], function(t) {
      if (!is.na(t) &&
        !startsWith(t, "+") &&
        !startsWith(t, "N/A") &&
        !grepl("[a-zA-Z]", t)) paste0("+", t) else t
    })


    fluidRow(
      class = "podium-row",
      create_podium_box(podium[1,], "P1", time_diffs[1]),
      create_podium_box(podium[2,], "P2", time_diffs[2]),
      create_podium_box(podium[3,], "P3", time_diffs[3])
    )
  })

  # Render Race Results Table (within the "results" namespace)
  output$`results-raceResultsTable` <- renderTable({
    results_df <- race_data()
    req(results_df)

    # Prepare display table, including images within the Constructor column
    display_results <- results_df %>%
      select(Position, Driver, Code, Constructor, Time, Points, Constructor_Image) %>%
      mutate(
        # Embed image HTML directly into the Constructor column
        Constructor = paste0(
          '<div style="display: flex; align-items: center;">', # Flex container for alignment
          '<img src="', Constructor_Image, '" height="25" style="margin-right: 8px; vertical-align: middle;"> ', # Image
          '<span style="vertical-align: middle;">', Constructor, '</span>', # Text
          '</div>'
        )
      ) %>%
      select(-Constructor_Image) # Remove the now redundant image path column

    display_results

  },
    sanitize.text.function = function(x) x, # Allow HTML rendering
    striped = TRUE, hover = FALSE, bordered = TRUE, align = 'c', width = "100%", class = "table-custom")


  # Render Tire Strategy Plot (within the "tires" namespace)
  output$`tires-tireStrategyPlot` <- renderPlot({
    plot_data <- tire_stints_data()

    if (is.null(plot_data) || nrow(plot_data) == 0) {
      # No change needed for the error plot part
      return(ggplot() +
               annotate("text", x = 0.5, y = 0.5, label = "No tire strategy data available for this race.",
                        # Use Inter for error message consistency
                        family = "Inter", color = "white", size = 5) +
               theme_void() +
               theme(plot.background = element_rect(fill = "#0a0a0a", color = NA),
                     panel.background = element_rect(fill = "#0a0a0a", color = NA)))
    }

    max_lap <- max(plot_data$end_lap, na.rm = TRUE)

    # --- START ggplot code ---
    ggplot(plot_data, aes(y = Driver_Code)) +
      geom_rect(aes(xmin = start_lap - 0.5,
                    xmax = end_lap + 0.5,
                    fill = tireCompound,
                    ymin = as.numeric(Driver_Code) - 0.4,
                    ymax = as.numeric(Driver_Code) + 0.4),
                color = "#222222", size = 0.2) +
      geom_text(aes(x = start_lap + laps / 2,
                    label = laps),
                # Use Inter for the lap numbers inside bars
                family = "Inter",
                color = "black", # Keep black for contrast on light tires
                size = 3.0,
                fontface = "bold",
                data = subset(plot_data, laps > 1)) +
      scale_fill_manual(
        values = TIRE_COLORS,
        name = "Tire Compound",
        na.value = TIRE_COLORS["UNKNOWN"],
        guide = guide_legend(
          override.aes = list(size = 5),
          keywidth = unit(20, "mm"),
          keyheight = unit(10, "mm")
        )
      ) +
      scale_x_continuous(
        breaks = seq(0, max_lap + 5, by = 5),
        limits = c(0, max_lap + 2)
      ) +
      labs(
        # Keep title structure, font family will be set in theme()
        title = paste("Tire Strategy:", input$`controls-track` %||% "N/A", input$`controls-year` %||% "N/A"),
        subtitle = "Laps per stint shown. Driver order reflects finishing position (Top to Bottom = P1 onwards).",
        x = "Lap Number",
        y = ""
      ) +
      # Use theme_minimal as a base, then customize
      theme_minimal(base_size = 11, base_family = "Inter") + # Set base font to Inter
      theme(
        # Override specific elements with Titillium Web where desired
        plot.title = element_text(family = "Titillium Web", hjust = 0.5, size = 16, face = "bold", color = "white", margin = margin(b = 5)),
        plot.subtitle = element_text(family = "Inter", hjust = 0.5, size = 10, color = "#cccccc", margin = margin(b = 15)),

        # Axis text and titles inherit base_family ('Inter') unless overridden
        axis.text = element_text(color = "white", size = 9),
        axis.title = element_text(color = "white", size = 11),
        # Make driver codes bold Inter
        axis.text.y = element_text(size = 10, face = "bold"), # Inherits Inter

        # Legend customization - fixed to prevent overlapping
        legend.text = element_text(color = "white", size = 9, margin = margin(r = 10)),
        legend.title = element_text(color = "white", face = "bold"),
        legend.background = element_rect(fill = "#0a0a0a", color = NA),
        legend.key = element_rect(fill = NA, color = NA),
        legend.position = "bottom",
        legend.box.margin = margin(t = 10),
        legend.spacing.x = unit(10, "mm"),

        # Backgrounds and Gridlines
        plot.background = element_rect(fill = "#0a0a0a", color = NA),
        panel.background = element_rect(fill = "#0a0a0a", color = NA),
        panel.grid.major = element_line(color = "#333333", size = 0.3),
        panel.grid.minor = element_blank(),

        # Give more space at the bottom for the legend
        plot.margin = margin(15, 15, 25, 15)
      )
    # --- END ggplot code ---

  }, bg = "transparent", height = 600) # Use transparent bg with showtext/ragg


  # --- Call Chatbot Module Server ---
  # Pass the reactive app_context
  chatbotServer("chatbot", current_context_reactive = app_context)

}

# End server function