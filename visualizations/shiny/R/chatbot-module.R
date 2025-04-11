# R/chatbot-module.R

#' Chatbot Module UI
#'
#' @param id Character string defining the namespace ID for the module.
#'
#' @return A UI definition for the chatbot section.
#' @import shiny
#' @import shinyjs
chatbotUI <- function(id) {
  ns <- NS(id) # Create a namespace function using the provided id

  tagList(
    # Auto-resize script for textareas
    tags$script('
  $(document).on("shiny:connected", function() {
    function autoResizeTextarea(textarea) {
      // Reset height to calculate proper scrollHeight
      textarea.style.height = "auto";
      // Set new height based on content (with slight padding to prevent scrollbar flicker)
      textarea.style.height = (textarea.scrollHeight + 2) + "px";

      // Also update container positioning if needed
      var inputArea = textarea.closest(".input-area");
      if (inputArea) {
        // Ensure the send button stays aligned at the bottom right
        var sendBtn = inputArea.querySelector(".btn-send");
        if (sendBtn) {
          sendBtn.style.bottom = "5px";
        }
      }
    }

    // Apply to existing textareas
    document.querySelectorAll("textarea.auto-resize").forEach(function(textarea) {
      // Initial resize
      autoResizeTextarea(textarea);

      // Add input event listener
      textarea.addEventListener("input", function() {
        autoResizeTextarea(this);
      });

      // Add keydown listener for special keys
      textarea.addEventListener("keydown", function() {
        // Small delay to catch content after key processing
        setTimeout(function() {
          autoResizeTextarea(textarea);
        }, 0);
      });
    });

    // Observer for dynamically added elements
    const observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        mutation.addedNodes.forEach(function(node) {
          if (node.nodeType === 1) { // Element node
            node.querySelectorAll("textarea.auto-resize").forEach(function(textarea) {
              autoResizeTextarea(textarea);
              textarea.addEventListener("input", function() {
                autoResizeTextarea(this);
              });
            });
          }
        });
      });
    });

    observer.observe(document.body, { childList: true, subtree: true });
  });
'),

    # Add custom CSS for suggestion buttons and input area
    tags$style(HTML('
      .suggestion-item {
        white-space: normal !important; /* Allow text to wrap */
        text-align: left;
        padding: 10px 15px;
        margin: 5px;
        border-radius: 15px;
        display: inline-flex;
        align-items: center;
        background-color: #222;
        color: #fff;
        border: 1px solid #444;
        cursor: pointer;
        width: calc(50% - 15px); /* Make buttons fit two per row with margins */
        min-height: 50px; /* Ensure consistent height */
        overflow: hidden;
        box-sizing: border-box;
      }

      .suggestion-item i {
        margin-right: 8px;
      }

      .input-area {
        position: relative;
      }

      .input-area textarea {
        resize: none;
        overflow: hidden;
        min-height: 44px;
        max-height: 120px; /* Maximum height before scrolling */
        width: 100%;
        padding-right: 50px; /* Space for the send button */
        padding: 10px 50px 10px 15px;
        border-radius: 22px;
        border: 1px solid #444;
        background-color: #222;
        color: #fff;
      }

      .btn-send {
        position: absolute;
        right: 5px;
        bottom: 5px;
        width: 36px;
        height: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        background-color: #e63946;
        color: white;
        border: none;
      }
    ')),

    # Container for the whole chatbot UI
    div(class = "chatbot-container panel", # Use panel class for styling consistency
        # Chat Log Display Area (using uiOutput for dynamic rendering)
        # Add a wrapper div for scrolling control
        div(id = ns("chat_log_div"), class = "chat-log-area",
            # Welcome element (shown when no messages exist)
            div(id = ns("welcome_container"), class = "welcome-container",
                div(class = "welcome-message",
                    h3("Welcome to the F1 Race Insights Assistant"),
                    p("I can help you analyze race data, understand strategies, and explore F1 insights. Try asking me about:"),
                    div(class = "welcome-suggestions",
                        # Convert div elements to actionButtons with better sizing
                        actionButton(ns("sugg_results"), label = span(icon("trophy"), "Race results and performances"),
                                     class = "suggestion-item"),
                        actionButton(ns("sugg_lap_times"), label = span(icon("gauge-high"), "Lap times and race pace"),
                                     class = "suggestion-item"),
                        actionButton(ns("sugg_comparisons"), label = span(icon("car-side"), "Driver and team comparisons"),
                                     class = "suggestion-item"),
                        # Shortened text to better fit
                        actionButton(ns("sugg_track"), label = span(icon("road"), "Track info & strategy"),
                                     class = "suggestion-item")
                    ),
                    p("Click an example question below or type your own F1 question to get started.")
                )
            ),
            # Chat history (empty initially)
            uiOutput(ns("chatLogOutput")) # Renders the chat history HTML
        ),

        # Thinking Indicator (hidden initially)
        shinyjs::hidden(
          div(id = ns("thinking"), class = "thinking-indicator",
              "Thinking",
              span(class = "dot"), span(class = "dot"), span(class = "dot")
          )
        ),

        # Example Questions Buttons
        div(class = "example-questions",
            actionButton(ns("q_winner"), "Race winner?", class = "example-question-btn"),
            actionButton(ns("q_tires"), "Tire strategy?", class = "example-question-btn"),
            actionButton(ns("q_compare"), "Compare drivers?", class = "example-question-btn"),
            actionButton(ns("q_facts"), "Track facts?", class = "example-question-btn")
        ),

        # Input Area (Using textAreaInput instead of textInput for vertical expansion)
        div(class = "input-area",
            tags$textarea(
              id = ns("user_input"),
              class = "auto-resize",
              placeholder = "Ask about F1...",
              rows = 1
            ),
            actionButton(ns("send"), label = icon("paper-plane"), class = "btn-send")
        )
    ) # End chatbot-container div
  ) # End tagList
}

# --- F1 Topic Detection Helper Functions ---
# [Keep all the existing F1 topic detection functions unchanged]
F1_DRIVERS <- c(
  "Hamilton", "Lewis Hamilton", "Verstappen", "Max Verstappen",
  "Leclerc", "Charles Leclerc", "Sainz", "Carlos Sainz",
  "Russell", "George Russell", "Norris", "Lando Norris",
  "Piastri", "Oscar Piastri", "Perez", "Sergio Perez", "Checo",
  "Alonso", "Fernando Alonso", "Stroll", "Lance Stroll",
  "Ocon", "Esteban Ocon", "Gasly", "Pierre Gasly",
  "Bottas", "Valtteri Bottas", "Zhou", "Guanyu Zhou",
  "Tsunoda", "Yuki Tsunoda", "Albon", "Alex Albon", "Alexander Albon",
  "Sargeant", "Logan Sargeant", "Hulkenberg", "Nico Hulkenberg",
  "Magnussen", "Kevin Magnussen", "Bearman", "Oliver Bearman", "Ollie Bearman",
  "Lawson", "Liam Lawson", "Ricciardo", "Daniel Ricciardo"
)

F1_TEAMS <- c(
  "Mercedes", "Red Bull", "Ferrari", "McLaren",
  "Aston Martin", "Alpine", "Williams", "AlphaTauri", "RB", "VCARB",
  "Alfa Romeo", "Haas", "Sauber"
)

F1_TRACKS <- c(
  "Silverstone", "Monza", "Monaco", "Spa", "Spa-Francorchamps",
  "Imola", "Interlagos", "Montreal", "Suzuka", "Melbourne",
  "Singapore", "Baku", "Jeddah", "Miami", "Las Vegas", "Austin", "COTA",
  "Zandvoort", "Barcelona", "Hungaroring", "Budapest", "Bahrain", "Sakhir",
  "Abu Dhabi", "Yas Marina", "Albert Park", "Gilles Villeneuve",
  "Lusail", "Qatar", "Paul Ricard", "Portimao", "Shanghai"
)

F1_TERMS <- c(
  "Formula 1", "F1", "driver", "team", "race", "Grand Prix", "GP", "constructor",
  "circuit", "tire", "tyre", "pit", "lap", "championship", "qualifying", "quali",
  "podium", "corner", "DRS", "penalty", "engine", "strategy", "fastest",
  "pole", "winner", "track", "session", "points", "helmet", "steering",
  "flag", "safety car", "SC", "VSC", "Sprint", "aero", "downforce", "drag",
  "brake", "fuel", "power unit", "PU", "hybrid", "turbo", "ERS", "MGU-K",
  "MGU-H", "battery", "chassis", "suspension", "gearbox", "wheel", "pit stop",
  "box", "pit in", "pit out", "racecraft", "lap time", "time penalty",
  "race director", "yellow flag", "red flag", "blue flag", "green flag",
  "team radio", "strategy", "undercut", "overcut", "outlap", "inlap",
  "compound", "soft", "medium", "hard", "wet", "intermediate", "inter",
  "inters", "slick", "slicks", "pit crew", "pit wall", "briefing",
  "team principal", "TP", "race engineer", "onboard", "telemetry", "FIA",
  "race weekend", "practice", "FP1", "FP2", "FP3", "P1", "P2", "P3",
  "Q1", "Q2", "Q3", "grid", "formation lap", "sector", "split time",
  "constructor's", "driver's", "WDC", "WCC", "team orders", "overtake",
  "defending", "braking", "slipstream", "traction", "stint", "pace",
  "record", "evolution", "rain", "wet", "dry", "penalty", "debut",
  "rookie", "veteran", "Pirelli", "steward", "calendar", "season",
  "trophy", "marshal", "testing", "incident", "ban", "weather",
  "suspension", "clutch", "launch", "cornering", "balance", "runoff",
  "gravel", "curb", "kerb", "apex", "racing line", "setup", "wing",
  "diffuser", "floor", "sidepod", "bargeboard", "coasting", "backmarker",
  "delta", "regulations", "rules", "F1 news", "standings", "classification",
  "position", "retires", "retirement", "DNF", "DNS", "DSQ", "fastest lap", "FL"
)

# Combined list for faster lookup
ALL_F1_KEYWORDS <- c(F1_DRIVERS, F1_TEAMS, F1_TRACKS, F1_TERMS)

# Common F1 question patterns that might not contain specific keywords
F1_QUESTION_PATTERNS <- c(
  "^who won", "^when is the next", "^what time", "^where is",
  "^how many laps", "^why did", "^can you tell me about",
  "^what's the current", "^who is leading", "^who leads",
  "^how fast", "^what position", "^who qualified", "^tell me more",
  "^who's your favorite", "^who do you think", "^what happened",
  "^compare", "^show me", "^explain", "^what was the result"
)

is_f1_related <- function(query, min_score = 0.3, context_history = NULL) {
  # Empty or very short queries are considered not F1-related
  if (is.null(query) || nchar(trimws(query)) < 3) {
    return(FALSE)
  }

  query <- tolower(trimws(query))

  # Method 1: Direct keyword matching
  for (keyword in ALL_F1_KEYWORDS) {
    keyword_pattern <- paste0("\\b", tolower(keyword), "\\b")
    if (grepl(keyword_pattern, query, ignore.case = TRUE)) {
      return(TRUE)
    }
  }

  # Method 2: Check common F1 question patterns
  for (pattern in F1_QUESTION_PATTERNS) {
    if (grepl(pattern, query, ignore.case = TRUE)) {
      # If in a conversation context, these patterns are more likely F1-related
      if (!is.null(context_history) && nchar(context_history) > 0) {
        return(TRUE)
      }
      # Otherwise, they contribute to the score but don't immediately qualify
      min_score <- min_score * 0.9  # Lower the threshold slightly for pattern matches
    }
  }

  # Method 3: Scoring approach for more complex cases
  # Split the query into words
  query_words <- unlist(strsplit(query, "\\W+"))
  query_words <- query_words[query_words != ""]

  if (length(query_words) == 0) {
    return(FALSE)
  }

  # Calculate a relevance score
  matched_count <- 0
  total_weight <- 0

  for (word in query_words) {
    if (nchar(word) <= 2) next  # Skip very short words
    word_weight <- 1  # Default weight

    # Common words get lower weight
    common_words <- c("the", "and", "for", "that", "this", "with", "what", "who", "how", "when", "where", "why")
    if (word %in% common_words) {
      word_weight <- 0.2
    }

    # Important question words get medium weight
    if (word %in% c("race", "driver", "team", "track", "car", "lap")) {
      word_weight <- 0.7
    }

    total_weight <- total_weight + word_weight
    word_matched <- FALSE

    # Check word against all keywords
    for (keyword in ALL_F1_KEYWORDS) {
      keyword <- tolower(keyword)

      # Exact match
      if (word == keyword) {
        matched_count <- matched_count + word_weight
        word_matched <- TRUE
        break
      }

      # Partial match (word is part of keyword or keyword is part of word)
      if (grepl(word, keyword, fixed = TRUE) || grepl(keyword, word, fixed = TRUE)) {
        matched_count <- matched_count + (word_weight * 0.7)  # 70% credit for partial match
        word_matched <- TRUE
        break
      }

      # Check for potential typos using a simple approach
      # For production, consider using a string distance function
      if (nchar(word) >= 4 && abs(nchar(word) - nchar(keyword)) <= 2) {
        # Check first and last characters as a heuristic
        if (substr(word, 1, 1) == substr(keyword, 1, 1) &&
          substr(word, nchar(word), nchar(word)) == substr(keyword, nchar(keyword), nchar(keyword))) {
          matched_count <- matched_count + (word_weight * 0.4)  # 40% credit for possible typo
          word_matched <- TRUE
          break
        }
      }
    }

    # Context boost: If previous messages were F1-related, give some credit even for unmatched words
    if (!word_matched &&
      !is.null(context_history) &&
      nchar(context_history) > 0) {
      matched_count <- matched_count + (word_weight * 0.1)  # Small boost from context
    }
  }

  # Avoid division by zero
  if (total_weight == 0) {
    return(FALSE)
  }

  # Calculate final score
  score <- matched_count / total_weight
  return(score >= min_score)
}

generate_non_f1_response <- function(query) {
  # Avoid mentioning the exact query to prevent repeating potentially unsuitable content
  responses <- c(
    "I'm designed to help with Formula 1 topics only. Could you ask me something about F1 racing, drivers, teams, or recent races?",
    "Sorry, I can only discuss Formula 1 topics. Please ask an F1-related question about drivers, teams, races, or strategies.",
    "I'm your F1 racing assistant. I'd be happy to discuss anything F1-related, but can't help with other topics.",
    "My knowledge is limited to Formula 1. Try asking about race results, driver stats, team strategies, or F1 history.",
    "I specialize in Formula 1 racing information. Please ask me about F1 drivers, teams, tracks, or regulations instead."
  )

  # Select a random response
  sample(responses, 1)
}

#' Chatbot Server Function
#'
#' @param id Module ID
#' @param current_context_reactive Reactive expression providing current race context
#' @param style_prompt Optional prompt to set the chatbot's response style
#'
#' @return Server function for chatbot module
#' @import shiny
#' @import httr
#' @import shinyjs
chatbotServer <- function(id, current_context_reactive, style_prompt = STYLE_PROMPT) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns # Get the namespace function for convenience
    chat_history <- reactiveVal(INITIAL_CHAT_HISTORY) # Internal state for chat history

    # Convenience function to append to chat history and update display
    append_to_chat <- function(message, is_user = FALSE, is_error = FALSE) {
      if (is_user) {
        prefix <- "🏎️ You: "
      } else if (is_error) {
        prefix <- "⚠️ Error: "
      } else {
        prefix <- "🤖 F1 Assistant: "
      }

      updated_history <- paste0(isolate(chat_history()), prefix, message, "\n\n")
      chat_history(updated_history)

      # Auto-scroll chat log
      shinyjs::delay(50,
                     shinyjs::runjs(sprintf('
          var chatLogArea = document.getElementById("%s");
          if (chatLogArea) { chatLogArea.scrollTop = chatLogArea.scrollHeight; }
        ', ns("chat_log_div")))
      )
    }

    # --- Render Chat Log as HTML ---
    output$chatLogOutput <- renderUI({
      history_lines <- strsplit(chat_history(), "\n\n")[[1]] # Split messages by double newline
      history_lines <- history_lines[nzchar(history_lines)]

      message_tags <- lapply(history_lines, function(line) {
        line <- trimws(line)
        if (startsWith(line, "🏎️ You:")) {
          tags$div(class = "message user-message",
                   tags$div(class = "message-content", sub("🏎️ You:", "", line, fixed = TRUE))
          )
        } else if (startsWith(line, "🤖 F1 Assistant:")) {
          tags$div(class = "message bot-message",
                   tags$div(class = "message-content", sub("🤖 F1 Assistant:", "", line, fixed = TRUE))
          )
        } else if (startsWith(line, "⚠️ Error:")) {
          tags$div(class = "message error-message",
                   tags$div(class = "message-content", sub("⚠️ Error:", "", line, fixed = TRUE))
          )
        } else {
          # Fallback for initial message or other lines
          tags$div(class = "message system-message", tags$pre(line))
        }
      })
      tagList(message_tags)
    })

    # --- Handle Send Event ---
    observeEvent(input$send, {
      user_input_value <- input$user_input
      req(user_input_value, nzchar(trimws(user_input_value)))

      # Clear input field and add user message to chat
      updateTextAreaInput(session, "user_input", value = "")
      # Also use javascript to reset the textarea height
      shinyjs::runjs('
        var textarea = document.getElementById("user_input");
        if (textarea) {
          textarea.style.height = "auto";
          textarea.style.height = textarea.scrollHeight + "px";
        }
      ')

      append_to_chat(user_input_value, is_user = TRUE)

      # Disable inputs and show thinking indicator
      shinyjs::disable("user_input")
      shinyjs::disable("send")
      shinyjs::show("thinking")

      # Get current conversation context
      current_chat_history <- isolate(chat_history())

      # Check if query is F1-related
      f1_related <- is_f1_related(
        user_input_value,
        min_score = 0.25,  # Slightly lower threshold to be more permissive
        context_history = current_chat_history
      )

      if (!f1_related) {
        # Handle non-F1 query with a friendly response
        bot_msg_content <- generate_non_f1_response(user_input_value)
        append_to_chat(bot_msg_content)

        # Re-enable inputs and hide thinking indicator
        shinyjs::hide("thinking")
        shinyjs::enable("user_input")
        shinyjs::enable("send")

        return()
      }

      # Query is F1-related, proceed with Ollama API call
      current_context_text <- format_chatbot_context(current_context_reactive())
      full_prompt <- paste0(
        style_prompt,
        "\n",
        current_context_text,
        "\n\nPREVIOUS CHAT:\n",
        isolate(chat_history()),
        "\n🤖 F1 Assistant:"
      )

      print("Sending prompt to Ollama...")

      api_response <- tryCatch({
        POST(
          url = OLLAMA_URL,
          body = list(
            model = OLLAMA_MODEL,
            prompt = full_prompt,
            stream = FALSE
          ),
          encode = "json",
          timeout(OLLAMA_TIMEOUT)
        )
      }, error = function(e) {
        message("Error calling Ollama API: ", e$message)
        NULL
      })

      if (!is.null(api_response) && status_code(api_response) == 200) {
        content <- content(api_response, "parsed", simplifyVector = TRUE)
        reply <- trimws(content$response %||% "Sorry, I couldn't generate a response.")
        append_to_chat(reply)
        print("Ollama response received.")
      } else {
        status <- if (is.null(api_response)) "Timeout or Connection Error" else status_code(api_response)
        error_msg <- paste0(
          "Unable to reach the AI assistant (Status: ", status, "). ",
          "Please check if Ollama is running and accessible at ", OLLAMA_URL, "."
        )
        append_to_chat(error_msg, is_error = TRUE)
        print(paste("Ollama API failed. Status:", status))
      }

      # Re-enable inputs and hide thinking indicator
      shinyjs::hide("thinking")
      shinyjs::enable("user_input")
      shinyjs::enable("send")
    }, ignoreInit = TRUE)

    # --- Handle Enter key press in textarea ---
    # Add an observer for handling the Enter key to send messages
    observeEvent(input$user_input, {
      # Check if input contains a newline character at the end
      # (this indicates Enter was pressed)
      if (input$user_input != "" &&
        substr(input$user_input, nchar(input$user_input), nchar(input$user_input)) == "\n") {
        # Remove the trailing newline
        clean_input <- substr(input$user_input, 1, nchar(input$user_input) - 1)
        # Update the input field
        updateTextAreaInput(session, "user_input", value = clean_input)
        # Check if it wasn't just an empty line
        if (trimws(clean_input) != "") {
          # Trigger the send button
          shinyjs::click("send")
        }
      }
    }, ignoreInit = TRUE)

    # --- Handle Welcome Suggestion Button Clicks ---
    # Add new observers for the welcome suggestion buttons
    observeEvent(input$sugg_results, {
      updateTextAreaInput(session, "user_input", value = "Show me the race results and top performers")
      shinyjs::delay(50, shinyjs::click(ns("send")))
    })

    observeEvent(input$sugg_lap_times, {
      updateTextAreaInput(session, "user_input", value = "What were the fastest lap times in the race?")
      shinyjs::delay(50, shinyjs::click(ns("send")))
    })

    observeEvent(input$sugg_comparisons, {
      updateTextAreaInput(session, "user_input", value = "Compare the performance of the top two drivers")
      shinyjs::delay(50, shinyjs::click(ns("send")))
    })

    observeEvent(input$sugg_track, {
      updateTextAreaInput(session, "user_input", value = "What are key strategy considerations for this track?")
      shinyjs::delay(50, shinyjs::click(ns("send")))
    })

    # Return reactive values that might be needed by parent modules
    return(list(
      chat_history = chat_history
    ))
  }) # End moduleServer
}