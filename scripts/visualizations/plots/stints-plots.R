setwd("/Users/ryanriebesehl/Desktop/DS 401/data-drivers/data/clean-data")
library(ggplot2)
library(dplyr)
library(lubridate)
library(readr)

stints <- read_csv("stints.csv")
names(stints)

# Convert sector times to seconds for easier plotting
stints <- stints %>%
  mutate(
    sector1Time_seconds = as.numeric(
      hour(hms(sector1Time)) * 3600 + minute(hms(sector1Time)) * 60 + second(hms(sector1Time))
    ),
    sector2Time_seconds = as.numeric(
      hour(hms(sector2Time)) * 3600 + minute(hms(sector2Time)) * 60 + second(hms(sector2Time))
    ),
    sector3Time_seconds = as.numeric(
      hour(hms(sector3Time)) * 3600 + minute(hms(sector3Time)) * 60 + second(hms(sector3Time))
    )
  )


# Check for NA values in sector times
sum(is.na(stints$sector1Time_seconds))
sum(is.na(stints$sector2Time_seconds))
sum(is.na(stints$sector3Time_seconds))

# Remove rows with NA sector times
stints_clean <- stints %>%
  filter(!is.na(sector1Time_seconds) & !is.na(sector2Time_seconds) & !is.na(sector3Time_seconds))


#Boxplot for Sector Times:
ggplot(stints, aes(x = tireCompound, y = sector1Time_seconds, fill = tireCompound)) +
  geom_boxplot() +
  labs(title = "Sector 1 Time by Tire Compound", x = "Tire Compound", y = "Sector 1 Time (seconds)") +
  theme_minimal()

ggplot(stints, aes(x = tireCompound, y = sector2Time_seconds, fill = tireCompound)) +
  geom_boxplot() +
  labs(title = "Sector 1 Time by Tire Compound", x = "Tire Compound", y = "Sector 2 Time (seconds)") +
  theme_minimal()

ggplot(stints, aes(x = tireCompound, y = sector3Time_seconds, fill = tireCompound)) +
  geom_boxplot() +
  labs(title = "Sector 1 Time by Tire Compound", x = "Tire Compound", y = "Sector 3 Time (seconds)") +
  theme_minimal()


#Fresh vs. Used Tires:
ggplot(stints_clean, aes(x = freshTyre, y = sector1Time_seconds, fill = freshTyre)) +
  geom_boxplot() +
  labs(title = "Sector 1 Time by Fresh vs. Used Tires", x = "Tire Status", y = "Sector 1 Time (seconds)") +
  scale_y_continuous(limits = c(1000, 3000)) +  
  theme_minimal()

ggplot(stints_clean, aes(x = freshTyre, y = sector2Time_seconds, fill = freshTyre)) +
  geom_boxplot() +
  labs(title = "Sector 2 Time by Fresh vs. Used Tires", x = "Tire Status", y = "Sector 2 Time (seconds)") +
  scale_y_continuous(limits = c(1000, 3000)) +  
  theme_minimal()

ggplot(stints_clean, aes(x = freshTyre, y = sector3Time_seconds, fill = freshTyre)) +
  geom_boxplot() +
  labs(title = "Sector 3 Time by Fresh vs. Used Tires", x = "Tire Status", y = "Sector 3 Time (seconds)") +
  scale_y_continuous(limits = c(1000, 3000)) +  
  theme_minimal()


#Driver Performace Comparisons:
ggplot(stints_clean, aes(x = factor(driverId), y = sector1Time_seconds, fill = factor(driverId))) +
  geom_boxplot() +
  labs(title = "Sector 1 Time by Driver", x = "Driver ID", y = "Sector 1 Time (seconds)") +
  scale_y_continuous(limits = c(1000, 3000)) + 
  theme_minimal()

ggplot(stints_clean, aes(x = factor(driverId), y = sector2Time_seconds, fill = factor(driverId))) +
  geom_boxplot() +
  labs(title = "Sector 2 Time by Driver", x = "Driver ID", y = "Sector 2 Time (seconds)") +
  scale_y_continuous(limits = c(1000, 3000)) + 
  theme_minimal()

ggplot(stints_clean, aes(x = factor(driverId), y = sector3Time_seconds, fill = factor(driverId))) +
  geom_boxplot() +
  labs(title = "Sector 3 Time by Driver", x = "Driver ID", y = "Sector 3 Time (seconds)") +
  scale_y_continuous(limits = c(1000, 3000)) + 
  theme_minimal()



#Color Distibution of Tire Compound:
ggplot(stints_clean, aes(x = compoundColor)) +
  geom_bar(fill = "skyblue") +
  labs(title = "Distribution of Tire Compound Colors", x = "Compound Color", y = "Count") +
  theme_minimal()


#Average Sector Times by Tire Compund:
stints_avg <- stints_clean %>%
  group_by(tireCompound) %>%
  summarise(
    avg_sector1 = mean(sector1Time_seconds),
    avg_sector2 = mean(sector2Time_seconds),
    avg_sector3 = mean(sector3Time_seconds)
  )

ggplot(stints_avg, aes(x = tireCompound)) +
  geom_bar(aes(y = avg_sector1), stat = "identity", fill = "blue") +
  geom_bar(aes(y = avg_sector2), stat = "identity", fill = "green", alpha = 0.6) +
  geom_bar(aes(y = avg_sector3), stat = "identity", fill = "red", alpha = 0.6) +
  labs(title = "Average Sector Times by Tire Compound", x = "Tire Compound", y = "Average Sector Time (seconds)") +
  theme_minimal()





