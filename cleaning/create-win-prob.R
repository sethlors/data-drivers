library(dplyr)
library(tidyr)
library(here)
library(ranger)
library(readr)

# Load in necessary data sets
races <- read.csv(here("shiny","data", "clean-data", "races.csv"))
status <- read.csv(here("shiny","data", "clean-data", "status.csv"))
standings <- read.csv(here("shiny","data", "clean-data", "driver_standings.csv"))
circuits <- read.csv(here("shiny","data", "clean-data", "circuits.csv"))
drivers <- read.csv(here("shiny","data", "clean-data", "drivers.csv"))
stints <- read.csv(here("shiny","data", "clean-data", "stints.csv"))
laptimes <- read.csv(here("shiny","data", "clean-data", "lap_times.csv"))
pits <- read.csv(here("shiny","data", "clean-data", "pit_stops.csv"))
results <- read.csv(here("shiny","data", "clean-data", "results.csv"))
constructors <- read.csv(here("shiny","data", "clean-data", "constructors.csv"))

# Join standings with races to get season standings and points before each race
standingsj <- standings |>
  inner_join(races,by = "raceId") |>
  arrange(driverId, raceId) |>
  group_by(driverId,year) |>
  mutate(
    points_before = lag(points),
    position_before = lag(position)
  ) |>
  ungroup()

# If it is the first race make the season points before 0
standingsj[is.na(standingsj$points_before),]$points_before <- 0

# Calculate the amount of points each racer is behind the leader and
# select only the columns wanted for the final data set
standingsj <- standingsj |>
  group_by(year, raceId) |>
  mutate(
    leader_points = max(points_before, na.rm = TRUE),
    points_behind = leader_points - points_before
  ) |>
  ungroup() |>
  select(raceId,driverId,points_before,position_before,points_behind)

# Make driver name one column and select columns wanted
driversj <- drivers |>
  mutate(driver = paste(forename,surname,sep = " ")) |>
  select(driverId,driver)

# Determine if a racer won the race by checking if their time is not a "+ or \N"
results <- results |>
  mutate(temp = substr(time,1,1)) |>
  mutate(winner = ifelse(temp != "+" & temp != "\\",
                         1, 0)) |>
  select(raceId,driverId,winner,positionOrder,grid)

# Cleane constructors for joining
constructorsj <- constructors |>
  select(constructorId,color) |>
  rename(team_color = color)

# Calculate total time in order to calculate time behind for each racer
laptimes <- laptimes |>
  mutate(id = paste(as.character(raceId),as.character(driverId),sep = "-")) |>
  arrange(id, lap) |>
  group_by(id) |>
  mutate(total_time = cumsum(milliseconds)) |>
  ungroup() |>
  group_by(raceId, lap) |>
  mutate(
    leader_time = min(total_time, na.rm = TRUE),
    time_back = total_time - leader_time
  ) |>
  ungroup()

# Only want to join the circuit name
circuits <- circuits |>
  select(circuitId,name)

# Join all the data sets together
f1 <- stints |>
  inner_join(laptimes, by = c("raceId","driverId", "lap")) |>
  select(-sector1Time,-sector2Time,-sector3Time,-time,-compoundColor) |>
  inner_join(races, by = "raceId") |>
  inner_join(circuits, by = "circuitId") |>
  inner_join(results, by = c("raceId","driverId")) |>
  inner_join(driversj, by = "driverId") |>
  left_join(constructorsj, by = "constructorId") |>
  left_join(standingsj, by = c("raceId","driverId")) |>
  select(-date,-time,-name.y,-leader_time,-total_time,-id)

# Set columns as factors
f1 <- f1 |>
  mutate(trackStatus = as.factor(trackStatus),
         driverId = as.factor(driverId),
         tireCompound = as.factor(tireCompound),
         raceId = as.factor(raceId),
         circuitId = as.factor(circuitId),
         constructorId = as.factor(constructorId)) |>
  select(-milliseconds)

# Create laps left column and clean some columns
f1 <- f1 |>
  group_by(raceId) |>
  mutate(total_laps = max(lap),
         laps_left = total_laps-lap) |>
  ungroup() |>
  mutate(winner = if_else(laps_left == 0 & position == 1,1,winner)) |>
  mutate(winner = if_else(laps_left == 0 & position != 1,0,winner)) |>
  mutate(position_before = if_else(is.na(position_before),grid,position_before)) |>
  filter(total_laps > 1)

# Create training data for each year
ftrain19 <- f1 |>
  filter(year != 2019)
ftrain20 <- f1 |>
  filter(year != 2020)
ftrain21 <- f1 |>
  filter(year != 2021)
ftrain22 <- f1 |>
  filter(year != 2022)
ftrain23 <- f1 |>
  filter(year != 2023)
ftrain24 <- f1 |>
  filter(year != 2024)

# Create testing data for each year
ftest19 <- f1 |>
  filter(year == 2019)
ftest20 <- f1 |>
  filter(year == 2020)
ftest21 <- f1 |>
  filter(year == 2021)
ftest22 <- f1 |>
  filter(year == 2022)
ftest23 <- f1 |>
  filter(year == 2023)
ftest24 <- f1 |>
  filter(year == 2024)


winprob19 <- ranger(winner~.-year-driver-raceId-driverId-team_color-lap-points_before-constructorId-points_behind-name.x-positionOrder-trackStatus, 
                    data=ftrain19, num.trees = 1000,
                    min.node.size = 100, importance = "impurity")
f119pred <- predict(winprob19, data = ftest19)
test19 <- cbind(ftest19, f119pred)
test19 <- test19 |>
  group_by(raceId, lap) |>
  mutate(win_prob = prediction / sum(prediction)) |>
  ungroup()

winprob20 <- ranger(winner~.-year-driver-raceId-driverId-team_color-lap-points_before-constructorId-points_behind-name.x-positionOrder-trackStatus, 
                    data=ftrain20, num.trees = 1000,
                    min.node.size = 100, importance = "impurity")
f120pred <- predict(winprob20, data = ftest20)
test20 <- cbind(ftest20, f120pred)
test20 <- test20 |>
  group_by(raceId, lap) |>
  mutate(win_prob = prediction / sum(prediction)) |>
  ungroup()

winprob21 <- ranger(winner~.-year-driver-raceId-driverId-team_color-lap-points_before-constructorId-points_behind-name.x-positionOrder-trackStatus, 
                    data=ftrain21, num.trees = 1000,
                    min.node.size = 100, importance = "impurity")
f121pred <- predict(winprob21, data = ftest21)
test21 <- cbind(ftest21, f121pred)
test21 <- test21 |>
  group_by(raceId, lap) |>
  mutate(win_prob = prediction / sum(prediction)) |>
  ungroup()

winprob22 <- ranger(winner~.-year-driver-raceId-driverId-team_color-lap-points_before-constructorId-points_behind-name.x-positionOrder-trackStatus, 
                    data=ftrain22, num.trees = 1000,
                    min.node.size = 100, importance = "impurity")
f122pred <- predict(winprob22, data = ftest22)
test22 <- cbind(ftest22, f122pred)
test22 <- test22 |>
  group_by(raceId, lap) |>
  mutate(win_prob = prediction / sum(prediction)) |>
  ungroup()

winprob23 <- ranger(winner~.-year-driver-raceId-driverId-team_color-lap-points_before-constructorId-points_behind-name.x-positionOrder-trackStatus, 
                    data=ftrain23, num.trees = 1000,
                    min.node.size = 100, importance = "impurity")
f123pred <- predict(winprob23, data = ftest23)
test23 <- cbind(ftest23, f123pred)
test23 <- test23 |>
  group_by(raceId, lap) |>
  mutate(win_prob = prediction / sum(prediction)) |>
  ungroup()

winprob24 <- ranger(winner~.-year-driver-raceId-driverId-team_color-lap-points_before-constructorId-points_behind-name.x-positionOrder-trackStatus, 
                    data=ftrain24, num.trees = 1000,
                    min.node.size = 100, importance = "impurity")
f124pred <- predict(winprob24, data = ftest24)
test24 <- cbind(ftest24, f124pred)
test24 <- test24 |>
  group_by(raceId, lap) |>
  mutate(win_prob = prediction / sum(prediction)) |>
  ungroup()

win_prob <- rbind(test19,test20,test21,test22,test23,test24)
write_csv(win_prob, here("shiny","data", "clean-data", "win_prob.csv"))
