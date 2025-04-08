cat("Cleaning fastf1-sessions data...\n")

# Load necessary libraries
library(dplyr)
library(stringr)
library(readr)

# Read CSV files
df <- read_csv("../data/raw-data/fastf1-sessions.csv")
drivers <- read_csv("../data/raw-data/drivers.csv")
constructors <- read_csv("../data/raw-data/constructors.csv")
races <- read_csv("../data/raw-data/races.csv")

# Function to convert time format to M:SS.sss
convert_time <- function(time_str) {
  if (is.na(time_str) || time_str == "") return(NA)  # Handle missing values

  # Extract only MM:SS.sss part
  time_str <- str_extract(time_str, "\\d{2}:\\d{2}\\.\\d{3}")
  if (is.na(time_str)) return(NA)  # Return NA if extraction fails

  # Split time into minutes, seconds, and milliseconds
  time_parts <- as.numeric(unlist(strsplit(time_str, "[:.]")))

  if (length(time_parts) == 3) {
    minutes <- time_parts[1]
    seconds <- time_parts[2]
    milliseconds <- time_parts[3]
  } else {
    return(NA)
  }

  # Convert to M:SS.sss format
  sprintf("%d:%02d.%03d", minutes, seconds, milliseconds)
}

# Vectorized function for mutate()
convert_time_vec <- Vectorize(convert_time)

# Define tire compound colors
tire_colors <- c(
  "HARD" = "#FFFFFF",
  "MEDIUM" = "#FED218",
  "SOFT" = "#FE2E2C",
  "SUPERSOFT" = "#FE2E2C",
  "ULTRASOFT" = "#AE4AA3",
  "HYPERSOFT" = "#9A6D77",
  "INTERMEDIATE" = "#45932F",
  "WET" = "#2F6ECE"
)

# Rename driver column for join
drivers <- drivers %>% select(driverId, code)

# Rename constructors to remove NA values in join
df <- df %>%
  mutate(Team = if_else(Team == "Red Bull Racing","Red Bull",Team),
         Team = if_else(Team == "Alpine","Alpine F1 Team",Team),
         Team = if_else(Team == "Kick Sauber","Sauber",Team),
         Team = if_else(Team == "Alfa Romeo Racing","Alfa Romeo",Team),
         Team = if_else(Team == "RB","RB F1 Team",Team))

# Rename constructor column for join
constructors <- constructors %>% select(constructorId, name) %>% rename(team = name)

# Rename race columns for join
races <- races %>% select(raceId, year, round)

# Process lap data
df_clean <- df %>%
  select(
    code = Driver,
    lap = LapNumber,
    sector1Time = Sector1Time,
    sector2Time = Sector2Time,
    sector3Time = Sector3Time,
    tireCompound = Compound,
    tyreLife = TyreLife,
    freshTyre = FreshTyre,
    trackStatus = TrackStatus,
    team = Team,
    year = Year,
    round = Round
  ) %>%
  mutate(across(starts_with("sector"), convert_time_vec)) %>%

  # Join with drivers to replace code with driverId
  left_join(drivers, by = "code") %>%
  select(-code) %>%  # Drop code column

  # Join with constructors to replace team with constructorId
  left_join(constructors, by = "team") %>%
  select(-team) %>%  # Drop team column

  # Join with races to get raceId and drop year/round
  left_join(races, by = c("year", "round")) %>%
  select(-year, -round) %>%  # Drop year and round

  # Add compound color
  mutate(CompoundColor = ifelse(is.na(tireCompound), "#000000", tire_colors[tireCompound])) %>%

  # Rename column to match lowercase style
  rename(compoundColor = CompoundColor)

# Save cleaned CSV to git repo
write_csv(df_clean, "../data/clean-data/stints.csv")

# Print first few rows
head(df_clean)
cat("Cleaning fastf1-sessions data complete.\n")