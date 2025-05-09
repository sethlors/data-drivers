required_packages <- c(
  "dplyr",
  "ggplot2",
  "lubridate",
  "plotly",
  "ranger",
  "readr",
  "shiny",
  "stringr",
  "tibble",
  "tidyr",
  "tidyverse"
)

install_if_missing <- function(packages) {
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      cat("Installing package:", pkg, "\n")
      install.packages(pkg, dependencies = FALSE)
    }
  }
}

install_if_missing(required_packages)

cat("All specified dependencies have been installed successfully!\n")