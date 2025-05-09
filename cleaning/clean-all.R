cat("Cleaning all data...\n")

# Source all cleaning scripts
source("cleaning/clean-circuits.R")
source("cleaning/clean-constructor-results.R")
source("cleaning/clean-constructor-standings.R")
source("cleaning/clean-constructors.R")
source("cleaning/clean-driver-standings.R")
source("cleaning/clean-drivers.R")
source("cleaning/clean-fastf1-sessions.R")
source("cleaning/clean-lap-times.R")
source("cleaning/clean-pit-stops.R")
source("cleaning/clean-qualifying.R")
source("cleaning/clean-races.R")
source("cleaning/clean-results.R")
source("cleaning/clean-seasons.R")
source("cleaning/clean-sprint-results.R")
source("cleaning/clean-status.R")

# Print message when complete
cat("All cleaning scripts have been executed successfully!\n")