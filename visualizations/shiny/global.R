# global.R

# Load Libraries
library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(here)
library(httr)
library(jsonlite)
library(shinyjs)
library(showtext)

font_add_google("Titillium Web", "Titillium Web")
font_add_google("Inter", "Inter")

showtext_auto()

# --- Configuration ---
OLLAMA_URL <- "http://localhost:11434/api/generate"
OLLAMA_MODEL <- "llama3:8b"
OLLAMA_TIMEOUT <- 20 # seconds
STYLE_PROMPT <- "Please respond concisely in less than 5 sentences. You know everything about Formula 1 AND the data currently shown in the app. Every response should be in a paragraph form, do not split  your answer using bullet points.\n"
POINTS_TABLE <- c(25, 18, 15, 12, 10, 8, 6, 4, 2, 1)
DEFAULT_IMAGE <- "assets/driver-images/default.jpg"
CONSTRUCTOR_IMG_PATH <- "assets/constructor-images/"
DRIVER_IMG_PATH <- "assets/driver-images/"

# --- Load Data ---
# Consider adding error handling here (e.g., check if files exist)
status <- read.csv(here("data", "clean-data", "status.csv"))
races <- read.csv(here("data", "clean-data", "races.csv"))
drivers <- read.csv(here("data", "clean-data", "drivers.csv"))
results <- read.csv(here("data", "clean-data", "results.csv"))
constructors <- read.csv(here("data", "clean-data", "constructors.csv"))
stints <- read.csv(here("data", "clean-data", "stints.csv"))

# Add color information to constructors data if it's not already there
# This assumes 'constructors.csv' has a 'color' column.
# If not, you might need to define colors manually or merge from another source.
# Example placeholder if color is missing:
if (!"color" %in% colnames(constructors)) {
  warning("Constructors data missing 'color' column. Using default grey.")
  constructors$color <- "#808080" # Default grey
}

# --- Source Helper Functions and Modules ---
source("R/utils.R", local = TRUE)
source("R/data-processing.R", local = TRUE)
source("R/ui-elements.R", local = TRUE)
source("R/chatbot-module.R", local = TRUE)

# --- External Processes (Optional) ---
# Consider managing Ollama externally rather than starting it from R
system("ollama run llama3:8b", wait = FALSE)
# Check if Ollama is running instead? Or provide instructions.
print("Checking Ollama status...")
ollama_status <- tryCatch({
  res <- GET(gsub("/api/generate", "", OLLAMA_URL), timeout(2))
  status_code(res) == 200
}, error = function(e) {
  FALSE
})

if (!ollama_status) {
  warning("Ollama server not detected at ", OLLAMA_URL, ". Chatbot functionality may fail.")
} else {
  print("Ollama server detected.")
}

# --- Initial Values ---
INITIAL_CHAT_HISTORY <- ""
AVAILABLE_YEARS <- sort(unique(races$year), decreasing = TRUE)