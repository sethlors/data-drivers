cat("Cleaning all data...\n")

# Source all cleaning scripts
source("scripts/cleaning/clean-circuits.R")
source("scripts/cleaning/clean-constructor-results.R")
source("scripts/cleaning/clean-constructor-standings.R")
source("scripts/cleaning/clean-constructors.R")
source("scripts/cleaning/clean-driver-standings.R")
source("scripts/cleaning/clean-drivers.R")
source("scripts/cleaning/clean-fastf1-sessions.R")
source("scripts/cleaning/clean-lap-times.R")
source("scripts/cleaning/clean-pit-stops.R")
source("scripts/cleaning/clean-qualifying.R")
source("scripts/cleaning/clean-races.R")
source("scripts/cleaning/clean-results.R")
source("scripts/cleaning/clean-seasons.R")
source("scripts/cleaning/clean-sprint-results.R")
source("scripts/cleaning/clean-status.R")

# Print message when complete
cat("All cleaning scripts have been executed successfully!\n")