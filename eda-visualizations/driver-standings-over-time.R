library(ggplot2)
library(dplyr)

driver_standings <- read.csv("shiny/data/clean-data/driver_standings.csv")
races <- read.csv("shiny/data/clean-data/races.csv")
drivers <- read.csv("shiny/data/clean-data/drivers.csv")

driver_standings %>%
  inner_join(races, by = "raceId") %>%
  inner_join(drivers, by = "driverId") %>%
  ggplot(aes(x = date, y = points, color = surname, group = surname)) +
  geom_line() +
  labs(title = "Driver Standings Over Time",
       x = "Race Date",
       y = "Points",
       color = "Driver") +
  theme_minimal()