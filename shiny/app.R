library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(here)
library(tibble)

circuits <- read.csv("data/clean-data/circuits.csv")
constructors <- read.csv("data/clean-data/constructors.csv")
drivers <- read.csv("data/clean-data/drivers.csv")
lap_times <- read.csv("data/clean-data/lap_times.csv")
races <- read.csv("data/clean-data/races.csv")
results <- read.csv("data/clean-data/results.csv")
status <- read.csv("data/clean-data/status.csv")
stints <- read.csv("data/clean-data/stints.csv")
win_prob <- read.csv("data/clean-data/win_prob.csv")

addResourcePath("assets", "assets")

points_table <- c(25, 18, 15, 12, 10, 8, 6, 4, 2, 1)

get_image_path <- function(base_path, id, default_path = "assets/default.jpg") {
  if (is.na(id) || id == "") {
    return(default_path)
  }
  full_path <- file.path(base_path, paste0(id, ".jpg"))

  if (file.exists(full_path)) {
    return(full_path)
  } else {
    message(paste("File not found:", full_path))
    return(default_path)
  }
}

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "assets/styles.css"),
    tags$style(HTML("body { font-family: Formula1Font, sans-serif; }")),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css")
  ),

  tags$div(
    id = "infoButton",
    style = "position: fixed; bottom: 20px; right: 20px; z-index: 1000;",
    actionButton("infoBtn", "?", class = "info-btn")
  ),

  tags$div(
    id = "githubButton",
    style = "position: fixed; bottom: 20px; right: 80px; z-index: 1000;",
    tags$a(
      href = "https://github.com/sethlors/data-drivers",
      target = "_blank",
      class = "github-btn",
      tags$img(
        src = "assets/icons/github.png",
        alt = "GitHub",
        style = "width: 30px; height: 30px;"
      )
    )
  ),

  div(class = "container-fluid",
      div(class = "row",
          div(class = "col-12 text-center",
              h2("F1 Race Analysis")
          )
      ),

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

      div(class = "row",
          div(class = "col-12",
              uiOutput("statsBar")
          )
      ),

      verbatimTextOutput("debugInfo"),

      uiOutput("podiumVisualization"),

      div(class = "row",
          div(class = "col-12",
              div(class = "plot-container",
                  tableOutput("raceResults")
              )
          )
      ),

      div(class = "row",
          div(class = "col-12",
              div(class = "plot-container",
                  plotlyOutput("tireStrategyPlot", height = "600px")
              )
          )
      ),

      div(class = "row",
          div(class = "col-12",
              div(class = "plot-container",
                  plotlyOutput("winProbPlot")
              )
          )
      )
  )
)

server <- function(input, output, session) {

  # Helper Functions
  format_milliseconds <- function(ms) {
    if (is.na(ms)) return("--:--:---")
    total_seconds <- ms / 1000
    minutes <- floor(total_seconds / 60)
    seconds <- floor(total_seconds %% 60)
    milliseconds <- round((total_seconds - floor(total_seconds)) * 1000)
    sprintf("%d:%02d.%03d", minutes, seconds, milliseconds)
  }

  adjustColor <- function(hexColor) {
    if (is.na(hexColor) || hexColor == "") {
      return("#333333") # Default color if missing
    }
    return(hexColor)
  }

  # Reactive Values & Data Preparation
  selected_race_id <- reactive({
    req(input$year, input$track)
    selected_race <- races[races$year == input$year & races$name == input$track,]
    if (nrow(selected_race) > 0) {
      return(selected_race$raceId[1])
    } else {
      return(NULL)
    }
  })

  race_data <- reactive({
    race_id <- selected_race_id()
    req(race_id)

    results_filtered <- results[results$raceId == race_id,]
    if (nrow(results_filtered) == 0) return(NULL)

    race_results <- merge(results_filtered, drivers, by = "driverId")
    race_results$time <- ifelse(race_results$time == "\\N", NA, race_results$time)
    race_results$position <- ifelse(race_results$position == "\\N", NA, race_results$position)
    race_results$position <- suppressWarnings(as.numeric(as.character(race_results$position)))

    race_results <- merge(race_results, status, by = "statusId", all.x = TRUE)
    race_results <- merge(race_results, constructors, by = "constructorId", all.x = TRUE)

    race_results$time <- ifelse(!is.na(race_results$time), race_results$time, race_results$status)
    race_results$Driver <- paste(race_results$forename, race_results$surname)
    race_results <- race_results[order(race_results$position, na.last = TRUE),]

    race_results$Points <- ifelse(race_results$position >= 1 & race_results$position <= 10,
                                  points_table[race_results$position], 0)
    race_results$Points[race_results$Points > 0] <- paste0("+", race_results$Points[race_results$Points > 0])
    race_results$Points[race_results$Points == 0] <- "0" # Handle 0 points explicitly

    constructor_col <- if ("name.y" %in% colnames(race_results)) "name.y" else if ("name.1" %in% colnames(race_results)) "name.1" else "name"
    race_results$Driver_Code <- race_results$code

    race_results$formatted_position <- sapply(race_results$position, function(pos) {
      if (is.na(pos)) {
        return("DNF")
      } else {
        pos_int <- as.integer(pos)
        if (pos_int %% 100 %in% 11:13) {
          suffix <- "th"
        } else {
          suffix <- switch(as.character(pos_int %% 10), "1" = "st", "2" = "nd", "3" = "rd", "th")
        }
        return(paste0(pos_int, suffix))
      }
    })

    race_results$Constructor_Image <- sapply(race_results$constructorId, get_image_path, base_path = "assets/constructor-images/")
    race_results$Driver_Image <- sapply(race_results$driverId, get_image_path, base_path = "assets/driver-images/")

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
      constructorColor = race_results$color,
      stringsAsFactors = FALSE
    )

    return(result_subset)
  })

  fastest_lap_data <- reactive({
    race_id <- selected_race_id()
    req(race_id)

    race_lap_times <- lap_times[lap_times$raceId == race_id,]
    if (nrow(race_lap_times) == 0) return(NULL)

    fastest_lap <- race_lap_times[which.min(race_lap_times$milliseconds),]
    if (nrow(fastest_lap) == 0) return(NULL)

    driver_info <- drivers[drivers$driverId == fastest_lap$driverId,]
    lap_time <- format_milliseconds(fastest_lap$milliseconds)

    list(
      driver_code = if (nrow(driver_info) > 0) driver_info$code else "N/A",
      lap_time = lap_time,
      lap_number = fastest_lap$lap
    )
  })

  circuit_info <- reactive({
    race_id <- selected_race_id()
    req(race_id)

    race_info <- races[races$raceId == race_id,]
    if (nrow(race_info) == 0) return(NULL)

    circuit_details <- circuits[circuits$circuitId == race_info$circuitId,]
    if (nrow(circuit_details) == 0) return(NULL)

    circuit_name <- circuit_details$name
    simplified_name <- gsub(" Grand Prix Circuit| International Circuit| Circuit", "", circuit_name)

    list(
      circuit_name = simplified_name,
      location = circuit_details$location,
      country = circuit_details$country
    )
  })

  tire_data <- reactive({
    race_id <- selected_race_id()
    req(race_id)

    race_stints <- stints[stints$raceId == race_id,]

    if (nrow(race_stints) > 0) {
      latest_stint <- race_stints[which.max(race_stints$lap),]
      compound <- latest_stint$tireCompound
      age <- latest_stint$tyreLife
    } else {
      compound <- "UNKNOWN"
      age <- NA
    }

    list(
      compound = compound,
      age = age
    )
  })

  tire_stints <- reactive({
    race_id <- selected_race_id()
    req(race_id)

    results_order <- race_data()
    if (is.null(results_order) || nrow(results_order) == 0) return(NULL)

    race_stints_data <- stints[stints$raceId == race_id,]
    if (nrow(race_stints_data) == 0) return(NULL)

    driver_info <- merge(race_stints_data, drivers, by = "driverId", all.x = TRUE)
    driver_info$Driver <- paste(driver_info$forename, driver_info$surname)
    driver_info$Driver_Code <- driver_info$code
    driver_info <- driver_info[!is.na(driver_info$Driver),]
    if (nrow(driver_info) == 0) return(NULL)

    driver_info <- driver_info %>%
      arrange(driverId, lap) %>%
      group_by(driverId) %>%
      mutate(
        tire_prev = lag(tireCompound, default = "NONE"),
        new_stint = tireCompound != tire_prev | is.na(tireCompound) != is.na(tire_prev),
        stint_number = cumsum(new_stint)
      ) %>%
      ungroup()

    stint_summary <- driver_info %>%
      filter(!is.na(tireCompound)) %>%
      group_by(driverId, Driver, Driver_Code, stint_number, tireCompound, compoundColor) %>%
      summarise(
        start_lap = min(lap),
        end_lap = max(lap),
        .groups = "drop"
      ) %>%
      mutate(laps = end_lap - start_lap + 1)

    driver_levels <- rev(results_order$Driver)
    driver_codes <- rev(results_order$Code)

    # Create a mapping from Driver to Code based on results_order
    driver_to_code_map <- setNames(results_order$Code, results_order$Driver)

    # Ensure Driver_Code consistency using the map
    stint_summary$Driver_Code <- driver_to_code_map[stint_summary$Driver]

    # Filter out any stints where the driver isn't in the final results (e.g., DNS)
    stint_summary <- stint_summary[!is.na(stint_summary$Driver_Code),]

    # Factor ordering for plot
    stint_summary$Driver_Name <- stint_summary$Driver
    stint_summary$Driver <- factor(stint_summary$Driver, levels = driver_levels)

    # Ensure Driver_Code factor levels match the desired order
    ordered_codes <- driver_codes[driver_codes %in% unique(stint_summary$Driver_Code)]
    stint_summary$Driver_Code <- factor(stint_summary$Driver_Code, levels = ordered_codes)

    stint_summary$visual_width <- pmax(stint_summary$laps, 2)
    stint_summary$label_x_adj <- ifelse(stint_summary$laps == 1, 0.5, 0)

    return(stint_summary)
  })


  # Observers
  observeEvent(input$year, {
    req(input$year)
    updateSelectInput(session, "track", choices = NULL, selected = NULL)
    races_for_year <- races[races$year == input$year,]
    available_tracks <- setNames(races_for_year$name, paste0(races_for_year$name, " - R", races_for_year$round))
    updateSelectInput(session, "track", choices = available_tracks)
  })

  observeEvent(input$infoBtn, {
    showModal(
      modalDialog(
        title = span("F1 Race Analysis Dashboard", style = "color: white;"),
        size = "l",
        easyClose = TRUE,
        footer = NULL,
        HTML('
        <div style="max-height: 500px; overflow-y: auto; color: white;">
          <h4>About This Dashboard</h4>
          <p>Welcome to our F1 Race Analysis Dashboard. This application visualizes Formula 1 race data to provide insights on race results, driver performance, and race strategies.</p>
          <h4>Dashboard Features</h4>
          <ul>
            <li><b>Race Selection:</b> Choose a season and Grand Prix from the dropdown menus at the top.</li>
            <li><b>Stats Bar:</b> Key race information including fastest lap, circuit name, and tire details.</li>
            <li><b>Podium Visualization:</b> The top three finishers with their team colors, finishing positions, and time differences.</li>
            <li><b>Race Results Table:</b> Finishing order with drivers, teams, and timing information.</li>
            <li><b>Tire Strategy Plot:</b> Visual representation of each driver\'s tire compound choices throughout the race, showing stint lengths and tire changes.</li>
            <li><b>Win Probability Chart:</b> How each driver\'s chances of winning evolved throughout the race based on position, pace, and other factors.</li>
          </ul>
          <h4>Understanding the Data</h4>
          <p>The dashboard combines official race results with tire strategy data to provide a comprehensive view of race dynamics.</p>
          <h4>Common F1 Terms</h4>
          <ul>
            <li><b>Pit Stop:</b> A stop during the race for tire changes, repairs, or adjustments.</li>
            <li><b>Stint:</b> A period of the race between pit stops, typically on the same set of tires.</li>
            <li><b>Undercut/Overcut:</b> Strategic pit stop timing to gain track position over competitors.</li>
            <li><b>Pole Position:</b> The first starting position, awarded to the fastest qualifier.</li>
            <li><b>DRS:</b> Drag Reduction System, a mechanism to reduce drag and increase speed.</li>
          </ul>
          <h4>Tire Compounds</h4>
          <ul>
            <li><b>Soft (Red):</b> Fastest but shortest lifespan.</li>
            <li><b>Medium (Yellow):</b> Balance of speed and durability.</li>
            <li><b>Hard (White):</b> Slowest but most durable.</li>
            <li><b>Intermediate (Green):</b> For damp conditions.</li>
            <li><b>Wet (Blue):</b> For heavy rain conditions.</li>
            <li>(Older compounds like Supersoft, Ultrasoft, Hypersoft may appear in historical data)</li>
          </ul>
        </div>
      ')
      )
    )
  })

  output$statsBar <- renderUI({
    fastest <- fastest_lap_data()
    circuit <- circuit_info()
    tires <- tire_data()

    req(fastest, circuit, tires)

    fastest$driver_code <- ifelse(is.null(fastest$driver_code) || fastest$driver_code == "N/A", "---", fastest$driver_code)
    fastest$lap_time <- ifelse(is.null(fastest$lap_time) || fastest$lap_time == "--:--:---", "--:--.---", fastest$lap_time)
    fastest$lap_number <- ifelse(is.null(fastest$lap_number), "?", fastest$lap_number)

    circuit$circuit_name <- ifelse(is.null(circuit$circuit_name), "Unknown Circuit", circuit$circuit_name)

    tires$compound <- ifelse(is.null(tires$compound) || tires$compound == "UNKNOWN", "UNKNOWN", tires$compound)
    tires$age <- ifelse(is.na(tires$age), "?", tires$age)

    compound_colors <- c(
      "HARD" = "#FFFFFF", "MEDIUM" = "#FFDA00", "SOFT" = "#E80600",
      "INTERMEDIATE" = "#4DDB30", "WET" = "#00AFFF",
      "SUPERSOFT" = "#DA0640", "ULTRASOFT" = "#A9479E", "HYPERSOFT" = "#FEB4C3",
      "UNKNOWN" = "#808080"
    )
    tire_color <- compound_colors[tires$compound]
    if (is.na(tire_color)) tire_color <- compound_colors["UNKNOWN"]

    div(class = "stats-bar",
        div(class = "stats-item",
            tags$div(class = "stats-icon", tags$i(class = "fas fa-stopwatch")),
            div(div(class = "stats-label", "FASTEST LAP"),
                div(class = "stats-value", paste0(fastest$lap_time, " - ", fastest$driver_code)))
        ),
        div(class = "stats-item",
            tags$div(class = "stats-icon", tags$i(class = "fas fa-flag-checkered")),
            div(div(class = "stats-label", "CIRCUIT"),
                div(class = "stats-value", circuit$circuit_name))
        ),
        div(class = "stats-item",
            div(div(class = "stats-label", "Fastest Lap On"),
                div(class = "stats-value", paste("Lap", fastest$lap_number)))
        ),
        div(class = "stats-item",
            div(div(class = "stats-label", "Last Known Tire"),
                div(class = "stats-value", tags$span(style = paste0("color: ", tire_color, "; font-weight: bold;"), tires$compound)))
        ),
        div(class = "stats-item",
            div(div(class = "stats-label", "Tire Age"),
                div(class = "stats-value", paste(tires$age, "laps")))
        )
    )
  })

  output$podiumVisualization <- renderUI({
    results_df <- race_data()
    req(results_df)

    if (nrow(results_df) == 0) {
      return(div(class = "error-message", "No race data available for podium."))
    }

    podium <- results_df %>%
      filter(position %in% 1:3) %>%
      arrange(position)

    if (nrow(podium) != 3 || !all(podium$position == 1:3)) {
      return(div(class = "error-message", "Podium data incomplete (Positions 1, 2, 3 not found)."))
    }

    position_labels <- c("P1", "P2", "P3")
    time_diffs <- c(
      "Leader",
      ifelse(is.na(podium$Time[2]) ||
               podium$Time[2] == "Finished" ||
               grepl("\\+", podium$Time[2]), podium$Time[2], paste0("+", podium$Time[2])),
      ifelse(is.na(podium$Time[3]) ||
               podium$Time[3] == "Finished" ||
               grepl("\\+", podium$Time[3]), podium$Time[3], paste0("+", podium$Time[3]))
    )

    time_diffs[2] <- ifelse(is.na(time_diffs[2]) &
                              !is.na(podium$Time[2]) &
                              podium$Time[2] %in% status$status, podium$Time[2], time_diffs[2])
    time_diffs[3] <- ifelse(is.na(time_diffs[3]) &
                              !is.na(podium$Time[3]) &
                              podium$Time[3] %in% status$status, podium$Time[3], time_diffs[3])


    create_podium_box <- function(driver_data, pos_label, time_diff) {
      column(4,
             div(class = "podium-box",
                 style = paste0("background-color: ", adjustColor(driver_data$constructorColor), ";"),
                 div(class = "box-gradient"),
                 img(class = "driver-img", src = driver_data$Driver_Image),
                 img(class = "constructor-img", src = driver_data$Constructor_Image),
                 div(class = "glass-footer",
                     div(class = "driver-code", driver_data$Code),
                     div(class = "position-label", pos_label),
                     div(class = "time-diff", time_diff)
                 )
             )
      )
    }

    fluidRow(
      class = "podium-row",
      create_podium_box(podium[1,], position_labels[1], time_diffs[1]),
      create_podium_box(podium[2,], position_labels[2], time_diffs[2]),
      create_podium_box(podium[3,], position_labels[3], time_diffs[3])
    )
  })

  output$raceResults <- renderUI({
    results_df <- race_data()
    req(results_df)

    if (nrow(results_df) == 0) {
      return(div(class = "error-message", "No race results available."))
    }

    rows <- apply(results_df, 1, function(row) {
      constructor_img <- tags$img(src = row[["Constructor_Image"]], height = "25", style = "margin-right: 8px; vertical-align: middle;")
      tags$tr(
        tags$td(row[["Position"]]),
        tags$td(row[["Driver"]]),
        tags$td(row[["Code"]]),
        tags$td(div(style = "display: flex; align-items: center;", constructor_img, row[["Constructor"]])),
        tags$td(row[["Time"]]),
        tags$td(row[["Points"]])
      )
    })

    table_tag <- tags$table(
      class = "table race-results-table",
      tags$thead(
        tags$tr(
          tags$th("Pos"), tags$th("Driver"), tags$th("Code"),
          tags$th("Constructor"), tags$th("Time/Status"), tags$th("Points")
        )
      ),
      tags$tbody(rows)
    )

    div(class = "race-results-container", table_tag)
  })

  output$tireStrategyPlot <- renderPlotly({
    stints_plot_data <- tire_stints()
    req(stints_plot_data)

    if (nrow(stints_plot_data) == 0) {
      return(plotly_empty(type = "scatter", mode = "markers") %>%
               layout(title = "Tire Strategy Data Not Available", paper_bgcolor = "#181F28", plot_bgcolor = "#181F28", font = list(family = "Formula1Font", color = "white")) %>%
               config(displayModeBar = FALSE))
    }

    tire_colors <- c(
      "HARD" = "#F0F0F0", "MEDIUM" = "#FFDA00", "SOFT" = "#E80600",
      "INTERMEDIATE" = "#4DDB30", "WET" = "#00AFFF",
      "SUPERSOFT" = "#DA0640", "ULTRASOFT" = "#A9479E", "HYPERSOFT" = "#FEB4C3"
    )
    max_lap <- max(stints_plot_data$end_lap, na.rm = TRUE)

    stints_plot_data <- stints_plot_data %>%
      mutate(
        hover_text = paste0(Driver_Name, "<br>", tireCompound, ": ", laps, " Laps<br>", "Laps ", start_lap, "-", end_lap),
        x_start = start_lap - 0.5,
        x_end = end_lap + 0.5,
        text_x = start_lap + (laps / 2) - 0.5
      )

    p <- ggplot(stints_plot_data, aes(y = Driver_Code)) +
      geom_rect(
        aes(xmin = x_start, xmax = x_end, fill = tireCompound,
            ymin = as.numeric(Driver_Code) - 0.4,
            ymax = as.numeric(Driver_Code) + 0.4,
            text = hover_text),
        color = NA, size = 0
      ) +
      geom_text(
        aes(x = text_x, label = laps),
        color = "black", size = 3, fontface = "bold", family = "Formula1Font"
      ) +
      scale_fill_manual(values = tire_colors, name = "Tire Compound", na.value = "grey50") +
      scale_x_continuous(
        breaks = seq(0, max_lap + (15 - max_lap %% 15), by = 15),
        limits = c(0, max_lap + 1),
        expand = c(0.005, 0.005)
      ) +
      labs(title = "TIRE STRATEGY", x = "LAP", y = NULL) +
      theme_minimal(base_family = "Formula1Font") +
      theme(
        plot.title = element_text(hjust = 0, face = "bold", colour = "white", size = 14, margin = margin(b = 15, t = 10)),
        plot.background = element_rect(fill = "#181F28", color = NA),
        panel.background = element_rect(fill = "#181F28", color = NA),
        panel.grid = element_blank(),
        axis.text.y = element_text(colour = "white", size = 9, face = "bold"),
        axis.text.x = element_text(colour = "white", size = 9),
        axis.title.x = element_text(colour = "white", size = 10, face = "bold", margin = margin(t = 10)),
        axis.ticks = element_line(colour = "grey50"),
        axis.ticks.length = unit(0.2, "cm"),
        axis.line.x = element_line(colour = "grey50"),
        axis.line.y = element_blank(),
        legend.position = "bottom"
      )

    plotly_plot <- ggplotly(p, tooltip = "text") %>%
      layout(
        paper_bgcolor = "#181F28",
        plot_bgcolor = "#181F28",
        font = list(family = "Formula1Font", color = "white"),
        xaxis = list(fixedrange = TRUE, zeroline = FALSE, showgrid = FALSE,
                     tickfont = list(color = "white", size = 13),
                     titlefont = list(color = "white", size = 13, face = "bold")),
        yaxis = list(fixedrange = TRUE, zeroline = FALSE, showgrid = FALSE,
                     tickfont = list(color = "white", size = 13, face = "bold")),
        legend = list(orientation = "h", xanchor = 'center', x = 0.5, yanchor = 'top', y = -0.15,
                      bgcolor = '#181F28', bordercolor = '#181F28',
                      font = list(color = "white", size = 13),
                      title = list(text = "Tire Compound", font = list(color = "white", size = 10, face = "bold"))),
        margin = list(l = 50, r = 20, t = 50, b = 70)
      ) %>%
      config(displayModeBar = FALSE)

    plotly_plot
  })

  output$winProbPlot <- renderPlotly({
    race_id <- selected_race_id()
    req(race_id)

    win_prob_filtered <- win_prob[win_prob$raceId == race_id,]

    if (is.null(win_prob_filtered) || nrow(win_prob_filtered) == 0) {
      return(plotly_empty(type = "scatter", mode = "markers") %>%
               layout(title = "Win Probability Data Not Available", paper_bgcolor = "#181F28", plot_bgcolor = "#181F28", font = list(family = "Formula1Font", color = "white")) %>%
               config(displayModeBar = FALSE))
    }

    driver_colors <- win_prob_filtered %>%
      select(driver, team_color) %>%
      distinct() %>%
      deframe()

    last_lap <- win_prob_filtered %>%
      group_by(driver) %>%
      filter(lap == max(lap)) %>%
      ungroup()

    driver_order <- last_lap %>%
      arrange(desc(win_prob)) %>%
      pull(driver)

    win_prob_filtered <- win_prob_filtered %>%
      mutate(driver = factor(driver, levels = driver_order))

    plot_width <- session$clientData$output_winProbPlot_width
    num_breaks <- ifelse(is.null(plot_width), 10, max(5, floor(plot_width / 100)))

    p <- ggplot(win_prob_filtered, aes(
      x = lap, y = win_prob, color = driver, group = driver,
      text = paste0("Driver: ", driver, "<br>Lap: ", lap, "<br>Win Prob: ", scales::percent(win_prob, accuracy = 0.1))
    )) +
      geom_line(linewidth = 1) +
      scale_color_manual(values = driver_colors, name = "Driver") +
      scale_x_continuous(breaks = scales::pretty_breaks(n = num_breaks), expand = c(0.01, 0.01)) +
      scale_y_continuous(limits = c(0, 1), labels = scales::percent_format(accuracy = 1), expand = c(0.01, 0.01)) +
      labs(title = "WIN PROBABILITY", x = "LAP NUMBER", y = "WIN PROBABILITY", color = "Driver") +
      theme_minimal(base_family = "Formula1Font") +
      theme(
        plot.title = element_text(hjust = 0, face = "bold", colour = "white", size = 14, margin = margin(b = 15, t = 10)),
        plot.background = element_rect(fill = "#181F28", color = NA),
        panel.background = element_rect(fill = "#181F28", color = NA),
        panel.grid.major = element_line(color = "#333333"),
        panel.grid.minor = element_blank(),
        axis.text = element_text(colour = "white", size = 9),
        axis.title = element_text(colour = "white", size = 10, face = "bold"),
        axis.title.x = element_text(margin = margin(t = 10)),
        axis.title.y = element_text(margin = margin(r = 10)),
        axis.ticks = element_line(colour = "grey50"),
        axis.ticks.length = unit(0.2, "cm"),
        axis.line = element_line(colour = "grey50"),
        legend.position = "bottom"
      )

    plotly_plot <- ggplotly(p, tooltip = "text") %>%
      layout(
        paper_bgcolor = "#181F28",
        plot_bgcolor = "#FFF",
        font = list(family = "Formula1Font", color = "white"),
        xaxis = list(fixedrange = TRUE, zeroline = FALSE, showgrid = TRUE, gridcolor = "#333333",
                     tickfont = list(color = "white", size = 12),
                     titlefont = list(color = "white", size = 13, face = "bold")),
        yaxis = list(fixedrange = TRUE, zeroline = FALSE, showgrid = TRUE, gridcolor = "#333333", tickformat = '.0%',
                     tickfont = list(color = "white", size = 12),
                     titlefont = list(color = "white", size = 13, face = "bold")),
        legend = list(orientation = "h", xanchor = 'center', x = 0.5, yanchor = 'top', y = -0.25,
                      bgcolor = '#181F28', bordercolor = '#181F28',
                      font = list(color = "white", size = 13),
                      title = list(text = "DRIVER", font = list(color = "white", size = 13, face = "bold")),
                      traceorder = 'normal'),
        margin = list(l = 60, r = 20, t = 50, b = 100)
      ) %>%
      config(displayModeBar = FALSE)

    plotly_plot
  })
}

shinyApp(ui = ui, server = server)