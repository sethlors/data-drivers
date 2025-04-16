constructor_standings <- read.csv("../data/clean-data/constructor_standings.csv")
constructors <- read.csv("../data/clean-data/constructors.csv")

constructor_standings %>%
  inner_join(races, by = "raceId") %>%
  inner_join(constructors, by = "constructorId") %>%
  mutate(year = lubridate::year(date)) %>%
  ggplot(aes(x = date, y = points, color = name, group = name)) +
  geom_line() +
  facet_wrap(~year, scales = "free_x") +  # Separate graphs per year
  labs(title = "Constructor Standings Over Time",
       x = "Race Date",
       y = "Points",
       color = "Constructor") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))