library(dplyr)

# Replace with your actual raw URL from GitHub
#lap_time_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/lap_times.csv"

lap_time_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/f1_lap_data_2018_2024.csv"

driver_standing_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/driver_standings.csv"

pit_stop_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/pit_stops.csv"

race_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/main/data/raw-data/ergast-db/races.csv"

lap_times <- read.csv(lap_time_url)

lap_times <- lap_times %>% rename(lap_time = time, lap_time_miliseconds = milliseconds, lap_position = position)

driver_standings <- read.csv(driver_standing_url)

pit_stops <- read.csv(pit_stop_url)

race_info <- read.csv(race_url)


df <- lap_times %>% left_join()
