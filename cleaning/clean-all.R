cat("Cleaning all data...\n")

# Source all cleaning scripts
source("clean-circuits.R")
source("clean-constructor-results.R")
source("clean-constructor-standings.R")
source("clean-constructors.R")
source("clean-driver-standings.R")
source("clean-drivers.R")
source("clean-fastf1-sessions.R")
source("clean-lap-times.R")
source("clean-pit-stops.R")
source("clean-qualifying.R")
source("clean-races.R")
source("clean-results.R")
source("clean-seasons.R")
source("clean-sprint-results.R")
source("clean-status.R")

# Print message when complete
cat("All cleaning scripts have been executed successfully!\n")