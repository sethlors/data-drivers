library(dplyr)
library(lubridate)

circuits_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/circuits.csv"
  
constructor_results_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/constructor_results.csv"
  
constructor_standings_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/constructor_standings.csv"
  
constructors_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/constructors.csv"

drivers_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/drivers.csv"
  
qualifying_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/qualifying.csv"

results_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/results.csv"

seasons_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/seasons.csv"

sprint_results_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/sprint_results.csv"

status_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/status.csv"

lap_time_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/f1_lap_data_2018_2024.csv"

driver_standing_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/driver_standings.csv"

pit_stop_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/pit_stops.csv"

race_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/races.csv"

circuits <- read.csv(circuits_url)

circuits <- circuits %>% rename(circuit_name = name, circuit_location = location, circuit = position)

constructor_results <- read.csv(constructor_results_url)

constructor_standings <- read.csv(constructor_standings_url)

constructors <- read.csv(constructors_url)

drivers <- read.csv(drivers_url)

qualifying <- read.csv(qualifying_url)

results <- read.csv(results_url)

seasons <- read.csv(seasons_url)

sprint_results <- read.csv(sprint_results_url)

status <- read.csv(status_url)

lap_times <- read.csv(lap_time_url)

driver_standings <- read.csv(driver_standing_url)

pit_stops <- read.csv(pit_stop_url)

races <- read.csv(race_url)


#df <- left_join(races, circuits, by = "")

#lap_times <- lap_times %>% rename(lap_time = time, lap_time_miliseconds = milliseconds, lap_position = position)

#driver_standings <- read.csv(driver_standing_url)

#race_info <- read.csv(race_url)


#df <- lap_times %>% left_join()

if (FALSE) {


# Define primary key columns that should NOT be renamed
key_columns <- c("raceId", "driverId", "constructorId", "circuitId")

# Function to rename only non-key columns if they exist in a previous table
rename_columns <- function(df, table_name, used_columns) {
  new_colnames <- colnames(df)
  
  for (i in seq_along(new_colnames)) {
    # Only rename if the column is NOT a key and already exists in used_columns
    if (new_colnames[i] %in% used_columns && !(new_colnames[i] %in% key_columns)) {
      new_colnames[i] <- paste0(table_name, "_", new_colnames[i])
    }
  }
  
  colnames(df) <- new_colnames
  return(df)
}

# List to track used column names
used_columns <- key_columns  # Start with keys to prevent renaming them

# Apply renaming function to all tables
circuits <- rename_columns(circuits, "circuits", used_columns)
used_columns <- c(used_columns, colnames(circuits))

constructor_results <- rename_columns(constructor_results, "constructor_results", used_columns)
used_columns <- c(used_columns, colnames(constructor_results))

constructor_standings <- rename_columns(constructor_standings, "constructor_standings", used_columns)
used_columns <- c(used_columns, colnames(constructor_standings))

constructors <- rename_columns(constructors, "constructors", used_columns)
used_columns <- c(used_columns, colnames(constructors))

driver_standings <- rename_columns(driver_standings, "driver_standings", used_columns)
used_columns <- c(used_columns, colnames(driver_standings))

drivers <- rename_columns(drivers, "drivers", used_columns)
used_columns <- c(used_columns, colnames(drivers))

lap_times <- rename_columns(lap_times, "lap_times", used_columns)
used_columns <- c(used_columns, colnames(lap_times))

pit_stops <- rename_columns(pit_stops, "pit_stops", used_columns)
used_columns <- c(used_columns, colnames(pit_stops))

qualifying <- rename_columns(qualifying, "qualifying", used_columns)
used_columns <- c(used_columns, colnames(qualifying))

races <- rename_columns(races, "races", used_columns)
used_columns <- c(used_columns, colnames(races))



}



