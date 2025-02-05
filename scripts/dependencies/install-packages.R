# Define a vector of required packages
required_packages <- c("rprojroot", "httr", "here", "jsonlite", "dplyr")

# Function to install missing packages
install_if_missing <- function(packages) {
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg)  # Install if not already installed
    }
  }
}

# Install missing packages
install_if_missing(required_packages)

# Load the packages
lapply(required_packages, library, character.only = TRUE)