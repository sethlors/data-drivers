
library(dplyr)

#Trying to join all datasets together

driver_data <- get_car_data(driver_number = 55, session_key = 9165)

session_data <- get_sessions(session_key = 9165)

driver_info_data <- get_drivers(driver_number = 55, session_key = 9165)

#available during races only, updates every 4 seconds
interval_data <- get_intervals(session_key = 9165, driver_number = 55)

lap_data <- get_laps(session = 9165, driver_number = 55)

location_data <- get_location(session_key = 9165, driver_number = 55)

meeting_data <- get_meetings(meeting_key = 1219)

pit_data <- get_pit_data(session_key = 9165, driver_number = 55)

stint_data <- get_stints(session_key = 9165, driver_number = 55)

options(digits.secs = 6)  # Ensure milliseconds are displayed

# Perform an inner join on session_key and filter by date range
filtered_driver_data <- driver_data %>%
  left_join(meeting_data, by = "meeting_key") %>%
  left_join(session_data, by = "session_key") %>%   # Join on session_key
  left_join(driver_info_data, by = c("session_key", "driver_number"))
  #left_join(lap_data, by = c("session_key", "driver_number", "date" = "date_start")) %>%
  #left_join(location_data, by = c("session_key", "driver_number"))
  #filter(date >= date_start & date <= date_end)     # Keep only records within session time



library(data.table)

# Convert to data.table
setDT(driver_data)
setDT(location_data)

setDT(lap_data)
setDT(stint_data)

# Set keys for indexing
setkey(driver_data, driver_number, session_key, date)
setkey(location_data, driver_number, session_key, date)
setkey(lap_data, driver_number, session_key, lap_start)
setkey(stint_data, driver_number)

lap_data[, lap_start := fifelse(is.na(lap_start), min(lap_start, na.rm = TRUE), lap_start), by = .(driver_number, session_key)]

# Match each location_data timestamp to the closest driver_data timestamp
#joined_data <- lap_data[driver_data, roll = TRUE, on = c("driver_number", "session_key", "lap_start" = "date")]
joined_data <- location_data[driver_data, roll = TRUE, on = c("driver_number", "session_key", "date")]

setkey(joined_data, driver_number, session_key, date)


# Matching lap information with the previous join. Note: the "date" column from the joined_data is now "lap_start" but has the same values as date
final_data <- lap_data[joined_data, roll = TRUE, on = c("driver_number", "session_key", "lap_start" = "date")]
setnames(final_data, "lap_start", "date")


# Perform a non-equi join to match lap_start within the stint range
final_final_data <- stint_data[final_data, 
                         on = .(driver_number, session_key, lap_start <= lap_number, lap_end >= lap_number), 
                         nomatch = 0L]  # Remove rows that don't match

setnames(final_final_data, "lap_end", "stint_lap_end")




library(dplyr)

# Check if each driver_data date falls within the correct lap interval
validation_check <- joined_data %>%
  arrange(driver_number, session_key, date) %>%
  mutate(next_lap_start = lead(lap_start)) %>%  # Get the next lap start time
  filter(date < lap_start | (!is.na(next_lap_start) & date >= next_lap_start))

# View rows that fail the check
print(validation_check)

# View results
head(joined_data)


# View the result
head(filtered_driver_data)
