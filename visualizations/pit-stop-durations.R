library(tidyverse)

drivers <- read.csv("data/clean-data/drivers.csv")
pit_stops <- read.csv("data/clean-data/pit_stops.csv")

# Ensure duration is numeric
pit_stops$duration <- as.numeric(pit_stops$duration)

# Join and calculate average pit stop duration per driver
pit_stops %>%
  inner_join(drivers, by = "driverId") %>%
  group_by(surname) %>%
  summarise(avg_duration = mean(duration, na.rm = TRUE)) %>%
  ggplot(aes(x = reorder(surname, avg_duration), y = avg_duration, fill = avg_duration)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "green", high = "red") +  # Gradient from yellow to red
  labs(x = "Driver", y = "Average Pit Stop Duration (seconds)", title = "Average Pit Stop Durations") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels


results <- read.csv("data/clean-data/results.csv")  # This links driverId to constructorId
constructors <- read.csv("data/clean-data/constructors.csv")

# Ensure duration is numeric
pit_stops$duration <- as.numeric(pit_stops$duration)

# Join datasets and compute average pit stop duration per team
pit_stops %>%
  inner_join(results, by = c("raceId", "driverId")) %>%  # Use results to link driverId to constructorId
  inner_join(constructors, by = "constructorId") %>%
  group_by(name) %>%  # Group by team (constructor name)
  summarise(avg_duration = mean(duration, na.rm = TRUE)) %>%
  ggplot(aes(x = reorder(name, avg_duration), y = avg_duration, fill = avg_duration)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "green", high = "red") +  # Green for faster, red for slower
  labs(x = "Team", y = "Average Pit Stop Duration (seconds)", title = "Average Pit Stop Duration by Team") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability


library(tidyverse)
# Ensure duration is numeric
pit_stops$duration <- as.numeric(pit_stops$duration)

# Filter for only 2024 races
races_2024 <- races %>% filter(substr(date, 1, 4) == "2024")

# Merge datasets
driver_pit_avg_2024 <- pit_stops %>%
  inner_join(results, by = c("raceId", "driverId")) %>%
  inner_join(drivers, by = "driverId") %>%
  inner_join(constructors, by = "constructorId") %>%
  inner_join(races_2024, by = "raceId") %>%
  group_by(name, surname, constructorId) %>%
  summarise(avg_duration = mean(duration, na.rm = TRUE), .groups = "drop")

# Order drivers within each constructor
driver_pit_avg_2024 <- driver_pit_avg_2024 %>%
  arrange(constructorId, avg_duration) %>%
  mutate(surname = factor(surname, levels = unique(surname)))  # Keep teammates together

# Plot average pit stop times per driver (teammates grouped together)
ggplot(driver_pit_avg_2024, aes(x = surname, y = avg_duration, fill = name)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "Driver", y = "Average Pit Stop Duration (seconds)", title = "2024 Average Pit Stop Duration by Driver") +
  scale_fill_brewer(palette = "Set3") +  # Different colors per team
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))