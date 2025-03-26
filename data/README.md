# Formula 1 Data Repository

## Overview
This repository contains **Formula 1 data** used for analysis, modeling, and visualizations. The dataset includes historical Formula 1 information, sourced from **OpenF1** and **Ergast**, free and open-source APIs.

## Data Source
We obtain our F1 data from both **[OpenF1](https://openf1.org/)** and **[Ergast](https://ergast.com/downloads/f1db_csv.zip)**, both offer real-time and historical insights, including:
- **Lap timings**
- **Car telemetry (speed, throttle, brake, etc.)**
- **Pit stop data**
- **Radio communications**
- **Weather conditions**
- And more.

## Data/Directory Structure

- `data-drivers`: The root directory of the repository.
  - `f1-explanation.md`: Explanation of key concepts in Formula 1.
  - `Info.md`: Information on how to clone the repository and contribute.
  - `milestones.md`: Documentation on milestones and goals for the project.
  - `README.md`: The main README file with an overview of the repository.
  - `data/`: Contains the raw and cleaned data files.
    - `raw_data/`: Contains raw CSV files obtained directly from the data sources.
      - `circuit.csv`: Information about F1 circuits.
      - `constructor_results.csv`: Results for each constructor in a season.
      - `constructor_standings.csv`: Constructor standings for each season.
      - `constructors.csv`: Information about constructors.
      - `driver_standings.csv`: Driver standings for each season.
      - `drivers.csv`: Information about drivers.
      - `fastf1-sessions.csv`: Session data from FastF1 API.
      - `lap_times.csv`: Lap times for each driver.
      - `pit_stops.csv`: Pit stop data for each.
      - `qualifying.csv`: Qualifying results.
      - `races.csv`: Information about each race.
      - `results.csv`: Race results.
      - `seasons.csv`: Information about F1 seasons.
      - `sprint_results.csv`: Sprint results.
      - `status.csv`: Status codes for cars/drivers.
    
    - `cleaned_data/`: Contains cleaned and preprocessed data ready for analysis.
      - `circuit.csv`: Information about F1 circuits.
      - `constructor_results.csv`: Results for each constructor in a season.
      - `constructor_standings.csv`: Constructor standings for each season.
      - `constructors.csv`: Information about constructors.
      - `driver_standings.csv`: Driver standings for each season.
      - `drivers.csv`: Information about drivers.
      - `lap_times.csv`: Lap times for each driver.
      - `pit_stops.csv`: Pit stop data for each.
      - `qualifying.csv`: Qualifying results.
      - `races.csv`: Information about each race.
      - `results.csv`: Race results.
      - `seasons.csv`: Information about F1 seasons.
      - `sprint_results.csv`: Sprint results.
      - `status.csv`: Status codes for cars/drivers.
      - `stints.csv`: Data on driver stints during races.
  - `scripts/`: Contains R scripts for data cleaning, preprocessing, visualizations, and analysis.
    - `cleaning/`: Contains scripts for cleaning raw data files.
      - `clean_all.R`: Script to clean all raw data files at once.
      - `clean-circuits.R`: Script to clean circuit data.
      - `clean-constructor-results.R`: Script to clean constructor results data.
      - `clean-constructor-standings.R`: Script to clean constructor standings data.
      - `clean-constructors.R`: Script to clean constructor data.
      - `clean-driver-standings.R`: Script to clean driver standings data.
      - `clean-drivers.R`: Script to clean driver data.
      - `clean-lap-times.R`: Script to clean lap times data.
      - `clean-pit-stops.R`: Script to clean pit stop data.
      - `clean-qualifying.R`: Script to clean qualifying data.
      - `clean-races.R`: Script to clean races data.
      - `clean-results.R`: Script to clean results data.
      - `clean-seasons.R`: Script to clean seasons data.
      - `clean-sprint-results.R`: Script to clean sprint results data.
      - `clean-status.R`: Script to clean status data.
    - `visualizations/`: Contains scripts for creating visualizations.
      - `plots/`: Contains scripts for creating static plots.
        - `plot-circuit-map.R`: Script to plot F1 circuits on a map.
        - `plot-lap-times.R`: Script to plot lap times for drivers.
        - `plot-pit-stops.R`: Script to plot pit stops for drivers.
        - `plot-qualifying.R`: Script to plot qualifying results
      - `shiny/`: Contains scripts for creating interactive visualizations using Shiny.
        - `shiny.R`: Script to run the Shiny app.
      
