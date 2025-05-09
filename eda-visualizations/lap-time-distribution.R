lap_times <- read.csv("shiny/data/clean-data/lap_times.csv")

ggplot(lap_times, aes(x = milliseconds)) +
  geom_histogram(binwidth = 500, fill = "blue", alpha = 0.6) +
  labs(title = "Distribution of Lap Times",
       x = "Lap Time (ms)",
       y = "Count") +
  theme_minimal()