
"
Line Chart (Lap Time Progression)
- Plot each driver's lap times across the race.
- Add color-coded lines for each driver.
- Highlight fastest laps with markers.
"


# Load data from URLs
race_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/feature/restructure-repo/data/clean-data/races.csv"
lap_time_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/feature/restructure-repo/data/clean-data/lap_times.csv"
drivers_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/feature/restructure-repo/data/clean-data/drivers.csv"
circuits_url <- "https://raw.githubusercontent.com/sethlors/data-drivers/refs/heads/feature/restructure-repo/data/clean-data/circuits.csv"

# Read CSV files
races <- read.csv(race_url)
lap_times <- read.csv(lap_time_url)
drivers <- read.csv(drivers_url)
circuits <- read.csv(circuits_url)
circuits <- read.csv(circuits_url)
lap_times <- read.csv(lap_time_url)

races <- races %>% select(raceId, year, round, circuitId, date)

df <- lap_times %>%
  left_join(drivers, by = "driverId") %>%
  left_join(races, by = "raceId") %>%
  left_join(circuits, by = "circuitId") %>% 
  select(raceId, driverId, driverRef, year, round, 
         circuitId, name, lap, milliseconds)

df <- df %>% 
  mutate(time = sprintf("%02d:%06.3f", milliseconds %/% 60000, (milliseconds %% 60000) / 1000)) %>%
  mutate(time_seconds = milliseconds / 1000)  # Convert ms → seconds


ggplot(df, aes(x = driverRef, y = time_seconds, fill = driverRef)) +
  geom_boxplot(alpha = 0.7, outlier.color = "red", outlier.size = 2) +  # Boxplot with outliers highlighted
  labs(
    title = "Lap Time Distribution by Driver",
    x = "Driver",
    y = "Lap Time (Seconds)",
    fill = "Driver"
  ) +
  theme_minimal() +
  theme(legend.position = "none")




"

Line Chart (Lap Time Progression)
- Plot each driver's lap times across the race.
- Add color-coded lines for each driver.
- Highlight fastest laps with markers.

- Bonus: Add a moving average line to smooth out pit stops or outliers


Delta Chart (Lap Time Differences)
- Show the time difference between each lap and fastest lap
- Helps in identifying consistency and performance drops.

Use case: Spot when drivers were stuck in traffic or on fresher tires


Heatmap (Lap Consistency)
- Rows = Drivers
- Columns = Laps

- Color intensity = Lap time (darker for slower, lighter for faster)

Insight: Quickly shows tire degradation, safety car periods, or strategy shifts


Cumulative Time Plot 
- Plot cumulative race time per lap for each driver
- Overtakes, pit stops, and safety cars become visible as 'kinks' in the lines


Boxplot (Lap Time Distribution)
- Show variability in lap times for each driver
- Compare consistency --especially useful for team strategies


6. Track Map Animation (if GPS data is available)
	•	Animate driver positions over time.
	•	Highlight overtakes, pit stops, and gaps visually.

Tools: Use libraries like Plotly or Matplotlib with animation features.

7. Battle Graphs (Head-to-Head)
	•	Compare two drivers’ lap times directly.
	•	Highlight when one driver gains or loses time relative to the other.


 8. Violin Plots (Lap Time Density)
	•	Show distribution and frequency of lap times.
	•	Reveals whether a driver was consistently fast or had mixed performance.


9. Strategy Timeline
	•	Horizontal bars showing tire compounds and pit stops over the race duration.
	•	Add overlays for safety cars and virtual safety cars.
	
	
0. Gap Chart (Race Gaps Over Time)
	•	Y-axis: Time gap to race leader
	•	X-axis: Lap number
	•	Visualizes how gaps between drivers evolve over the race.





"

races <- races %>% select(raceId, year, round, circuitId, date)

df <- lap_times %>%
  left_join(drivers, by = "driverId") %>%
  left_join(races, by = "raceId") %>%
  left_join(circuits, by = "circuitId") %>% 
  select(raceId, driverId, driverRef, year, round, 
         circuitId, name, lap, milliseconds)

df <- df %>% 
  mutate(time = sprintf("%02d:%06.3f", milliseconds %/% 60000, (milliseconds %% 60000) / 1000))
