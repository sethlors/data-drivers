## **Overview**

The `raw-data` directory is the central location in this project for storing unprocessed and raw data fetched
from [openF1.org](https://openf1.org). This creates a clear separation between raw data and any derived or processed
results, allowing for better data management and reproducibility.

## **Directory Structure**

The `raw-data` directory is organized into the following subdirectories:

1. **`sessions-data`**
   This folder contains raw session data pulled from an API. It stores race session information for a given year in CSV format.
    - **Example file**: `sessions_YYYY.csv`
      Files in this directory store session information for a specific year (e.g., `sessions_2024.csv`).
    - **Purpose**: These files include session data, such as race details or session keys required to fetch
      additional data like driver performance metrics.

2. **`drivers-data`**
   This folder contains raw driver data, which is fetched for specific sessions. Each file consolidates all driver
   records for a given year.
    - **Example file**: `drivers_YYYY.csv`
      Files in this directory store driver data for a specific year (e.g., `drivers_2024.csv`).
    - **Purpose**: These files include data such as driver identifiers, session performance, and other session-specific
      metrics.


## **Example Directory Structure**

Below is an example of what the `raw-data` directory will look like after running the data-fetching processes:

``` 
raw-data/
├── sessions-data/
│   ├── sessions_2024.csv
│   ├── sessions_2023.csv
│   └── ...
├── drivers-data/
│   ├── drivers_2024.csv
│   ├── drivers_2023.csv
│   └── ...
├── stints-data/
│   ├── stints_2024.csv
│   ├── stints_2023.csv
│   └── ...
```
