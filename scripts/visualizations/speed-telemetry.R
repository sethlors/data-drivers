# Load necessary libraries
library(ggplot2)
library(dplyr)

# Example data frame (assuming you have the merged data as 'laps')
# Assuming 'laps' contains the data for lap times, tire compounds, and tyre life
laps <- data.frame(
  tyre_life = c(1, 2, 3, 4, 5, 6),
  lap_time = c(83, 80, 78, 79, 82, 85),  # Sample lap times in seconds
  compound = c("HARD", "SOFT", "MEDIUM", "SOFT", "HARD", "MEDIUM")
)

# Use theme_dark_f1 if you have this theme installed or use a default dark theme
# Customizing the ggplot according to your desired style
ggplot(laps, aes(tyre_life, lap_time, color = compound)) +
  geom_line() +  # Line graph showing lap times over tyre life
  geom_point() +  # Points to show individual lap times
  theme_minimal() +  # Use a minimal theme to replicate a clean look
  labs(
    color = "Tyre Compound",
    y = "Lap Time (Seconds)",
    x = "Tyre Life (Laps)"
  ) +
  scale_color_manual(
    values = c("white", "yellow", "red")  # Custom colors for each tire compound
  ) +
  scale_y_continuous(breaks = seq(75, 85, 1)) +  # Custom y-axis breaks for readability
  theme(
    legend.position = "right",  # Position the legend to the right
    axis.text = element_text(size = 12),  # Customize axis text size
    axis.title = element_text(size = 14),  # Customize axis title size
    plot.title = element_text(size = 16, hjust = 0.5)  # Customize plot title size and centering
  ) +
  labs(
    title = "Tyre Life vs Lap Time",  # Title of the plot
  )