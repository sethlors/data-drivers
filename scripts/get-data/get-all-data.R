# Load necessary libraries
library(here)

# Define script paths
script_dir <- here::here("scripts", "get-data")

# Fetch session data
message("Fetching session data...")
source(file.path(script_dir, "get-sessions-data.R"))

# Fetch driver data
message("Fetching driver data...")
source(file.path(script_dir, "get-drivers-data.R"))

# Fetch stint data
message("Fetching stint data...")
source(file.path(script_dir, "get-stints-data.R"))

# Fetch intervals data
message("Fetching intervals data...")
source(file.path(script_dir, "get-intervals-data.R"))

# Fetch laps data
message("Fetching laps data...")
source(file.path(script_dir, "get-laps-data.R"))

# Fetch meetings data
message("Fetching meetings data...")
source(file.path(script_dir, "get-meetings-data.R"))

# Fetch pit data
message("Fetching pit data...")
source(file.path(script_dir, "get-pit-data.R"))

# Fetch position data
message("Fetching position data...")
source(file.path(script_dir, "get-position-data.R"))

# Fetch team radio data
message("Fetching team radio data...")
source(file.path(script_dir, "get-team-radio-data.R"))

# Fetch weather data
message("Fetching weather data...")
source(file.path(script_dir, "get-weather-data.R"))