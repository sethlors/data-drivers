# DS 4010 Report: 05/14/2025

By: Seth Lors, Ryan Riebesehl, Maxwell Skinner, Zack Swayne

### Goal

The goal of this dashboard is to turn complex F1 race data into a form comprehensible format. We present race results at a glance, displaying podium finishers, their time gaps, and points earned. This dashboard also aims to highlight key performance metrics, including fastest lap, tire strategies, and win probabilities over time. Our dashboard also aims to allow easy comparison between drivers like tire usage or time gaps and show how each F1 race evolved lap by lap. Our final goal was to make F1 data more easily accessible, turning complex measurements, sometimes up to multiple records per second per driver, into easily readable images and charts rather than just relying on tables of numbers.

The intended audience for this dashboard is a mix of casual F1 fans and those who are more interested in the data side of things. The visuals are very accessible and easy to understand with driver photos, team logos, and podium graphics, which would appeal to fans who might not read raw stats but want to understand who won, by how much, and who led the race. We also include more detailed analytics, including tire strategy and win probability over time, which would cater to the more data-centric fans of the sport. This is NOT for complicated analysis as much, if not all, of our statistics and metrics are summarized and simplified.

### Data collection (ETL)

For our project, we used the OpenF1 API (<https://openf1.org/>) as our primary data source. OpenF1 provides real-time historical Formula 1 data from the 2019-2024 seasons. Data was obtained using R scripts that interacted with the OpenF1 API through GET requests. These scripts are designed to automate the download of specific datasets such as weather conditions, pit stops, lap times, stint details, and driver positions. The data was then saved locally as CSV files, organized by year, to allow for efficient storage and retrieval.

To streamline the ETL process, we created reusable R functions that wrap the API calls and output clean, consistent data frames for analysis. These functions are stored in our team's GitHub repository under the 'cleaning' folder, allowing easy access and reproducibility. During the data cleaning phase, we filtered the datasets to focus only on relevant races, laps, and drivers to reduce noise within the data. We also checked for and handled missing or incomplete records. For instance, if certain laps lacked corresponding weather or tire data, we flagged those for exclusion or imputation depending on the severity and frequency of the gaps. Another thing we did was standardize date-time formats and column names to enable seamless merging across datasets.

Multiple datasets were joined using common keys such as 'session_key', 'driver_number', and 'lap_number'. Key decisions during this process involved prioritizing high-resolution lap-by-lap data and aligning all records to a consistent flow. In some cases, joins require temporal interpolation (ex, matching weather data to lap timestamps). The cleaned and merged datasets were stored as CSV files for version control and performance purposes. This format allows for compatibility with R, which is what we used for our modeling. For our dashboard, we used R Shiny to design the storage format to balance load time and memory efficiency. Especially since some visualizations required rendering a large number of observations. Below is an example code chunk of joining the separate tables:

``` r
race_data <- stints %>%
  inner_join(laptimes, by = c("raceId","driverId", "lap")) %>%
  select(-sector1Time,-sector2Time,-sector3Time,-time,-compoundColor) %>%
  inner_join(races, by = "raceId") %>%
  inner_join(circuits, by = "circuitId") %>%
  inner_join(results, by = c("raceId","driverId")) %>%
  inner_join(driversj, by = "driverId") %>%
  left_join(constructorsj, by = "constructorId") %>%
  left_join(standingsj, by = c("raceId","driverId"))
```

### Modeling

Our first idea for a potential model was to try to predict a racer's tire strategy throughout the race. We thought about using weather data, historical track strategies, position, and other factors to model what tires teams would use throughout a race. However, we were unable to move forward with this model as we switched data sources multiple times, and our final data set did not contain the weather data that a previous one had. Since it is very likely that weather would have a huge impact on a tire strategy model, we decided to move forward with other ideas.

Another modeling idea we explored was predicting lap time or fastest lap time using linear regression. We tested predictors like position, tire compound, track, year, and others, but none of our models met the constant variance assumption. We attempted to remedy this by using log transformations, but the problem remained. We concluded that a linear regression model would not be an effective choice of model since drivers are constantly battling one another for spots, so each driver’s individual lap times would not be independent of each other.

The final model we settled on for the dashboard was a random forest regression model that predicts in-race driver win probability. This idea came from previous work at Iowa State in Lock & Nettleton (1), who used a random forest to predict the in-game win probability for National Football League games. A random forest regression model creates a large number of decision trees that each predict a value. The output of the model is then the average of the predictions of all the trees. Each decision tree makes its prediction using a bootstrapped sample of the training data on a random subset of the predictors. The tree then uses the predictors to split the data set in pairs repeatedly using a variance splitting method.

The data set used to train the model has rows that correspond to the ending of a lap for each driver in each race. The explanatory variables are tire type, the number of laps since the last pit, position in the race, time back from the leader, the track itself, the pole position, the driver’s current position in the season standings, and the laps remaining in the race. The response variable the model was trained on is a simple 0 or 1 indicator of whether or not the driver went on to win the race. However, instead of treating this variable as a factor, it is predicted as a number. This results in the model predicting values from 0 to 1 for each lap by each driver in each race. To make the results more interpretable, we then normalized the values so that for each lap in each race, all of the probabilities sum up to one. The model was fit using the ranger package in R with the following code:

``` r
winprob <- ranger(winner~tireCompound+tireLife+freshTire+position+time_back+
                    circuitId+grid+total_laps+laps_left+position_before
                  , data=ftrain, num.trees = 500,
                min.node.size = 100, importance = "impurity")
```

An example of a win probability plot is shown below:

![image](https://github.com/user-attachments/assets/7af319cc-bada-4fd0-aa74-f245de7d0a07)

The models used in the dashboard are all pre-estimated. Users have the ability to select races from 2019-2024, so six separate models were created such that the training data for each year is all of the race data from the other five years. This was done to avoid making predictions on data that the model was trained on. The results of these models were then stored in a data frame that was written into a CSV file that can be accessed by the dashboard.

### Dashboard

Our F1 Race Analysis Dashboard uses R Shiny to visualize Formula 1 races as a single-page interface that guides users through a complete race. It starts with race statistics in the header and stats bar, followed by a podium visualization, race results, tire strategy analysis, and win probability evolution charts:

<img src="https://github.com/user-attachments/assets/824327d9-c29b-4ee2-a0c4-0705c5c32fcd" alt="v6_1a4266fb8be6507a4cc5d5e49572f3d69b83bf50" width="1422"/>

User interaction is designed through two straightforward selection inputs: a year dropdown filtering seasons from 2019-2024 and a dynamically populated track selector that adjusts based on the chosen year. This approach to navigation lets the user easily sift through historical data while being able to compare between races at the same circuit across different seasons. The dashboard’s five reactive outputs: fastest lap statistics, podium visualization, race results table, tire strategy plot, and win probability chart all respond instantly to these selections, following F1's official color schemes and branding elements.

The technical implementation combines R Shiny's reactive framework with dplyr for data transformation, ggplot2 and Plotly for interactive visualizations, and then custom CSS styling to create an authentic Formula 1 aesthetic. We paid extra attention to the visual details, including team-specific color coding, custom F1 typography, and racing iconography that significantly enhances user engagement. When creating the dashboard, we focused on creating a consistent F1 visual identity while maintaining analytical depth.

### Learning

Throughout the process of working on the dashboard and modeling components, we learned a lot about the limitations and potential of using real-world racing data. Especially from a live API like OpenF1. One of the main takeaways was understanding how complex and fragmented F1 data can be, even when coming from a single source. Each dataset, whether it be weather, pit stops, stints, or lap data, captures only a piece of the race. Aligning them properly required thoughtful data wrangling and clear assumptions.

One major choice we made was to separate the ETL process by year and data type, storing the results as CSV files. This gave us control over what data we were analyzing and helped us avoid constantly pinging the API during development. We also had to make decisions about how to handle missing data, such as removing laps without complete context (no tire or weather info) and whether to fill in those missing values or just exclude those records.

In terms of modeling, our early work focused on exploratory data analysis rather than predictive modeling. Our goal is to identify trends and relationships, like whether certain weather conditions lead to faster pit stops or whether stint length correlates with lap performance. The models and visualizations we built were closely aligned with our goals. While the limited data range (only 2019-2024) presents challenges for making strong generalizations, the modeling still supports our objective of building an insightful, educational dashboard for our targeted audience. The patterns we uncovered will help shape more advanced modeling steps, such as predicting optimal pit stop windows or analyzing tire degradation over time.

As we progressed through the semester, our understanding of Formula 1 deepened significantly beyond the surface-level excitement of fast cars. We learned that F1 is a complex and technical sport where success hinges on the strategic decisions involving multiple variables. Our analysis of tire management data revealed how different compounds (soft, medium, hard) offer varying levels of grip and durability, creating a fundamental strategic trade-off. Teams must constantly balance the speed advantage of softer compounds against their shorter lifespan, often making race-defining decisions under pressure. The data highlighted how critical pit stop windows are, with teams making split-second decisions based on competitor actions, weather changes, and tire degradation patterns that can determine race outcomes. We also learned that different circuit characteristics (high-speed, technical, street circuits) demand entirely different approaches to race management, with some tracks clearly favoring certain teams' car designs based on their aerodynamic and mechanical properties.

Finally, our project illuminated the growing role of data science in modern motorsport. We learned how F1 teams process terabytes of telemetry data during races to optimize strategy in real-time, making this perhaps the most data-driven sport in existence. Pre-race modeling and simulation have become essential competitive tools, with teams running thousands of race scenarios before even arriving at a circuit. The increasing sophistication of predictive analytics extends beyond race performance to areas like driver talent evaluation, parts reliability modeling, and even market engagement strategies. These insights not only enhanced our technical implementation but also gave us a deeper appreciation for how data science is transforming this high-performance sport, blending human skill, mechanical engineering, and computational analysis in a unique competitive environment. Formula 1 represents a perfect case study of how data-driven decision-making can provide competitive advantages in complex, dynamic systems where milliseconds matter. These insights not only enhanced our technical implementation but also gave us a deeper appreciation for how data science is transforming this high-performance sport, blending human skill, mechanical engineering, and computational analysis in a unique competitive environment.

### Next steps

If we had more time to work on this dashboard, there are several key areas we would focus on to improve the overall quality and impact of our project. First, we would try to obtain more comprehensive data. Since the OpenF1 API currently only provides data from 2019-2024, adding even older seasons (either by scraping archived data or using another data source) would strengthen the predictive model we built by providing more historical context and variability.

Additionally, we would work on building more sophisticated models. Especially for predicting pit stop timing and tire strategy. Currently, our analysis is mainly exploratory, but with more time and data, we could move towards additional machine learning approaches that classify or predict race events based on weather and lap time trends. From a user experience perspective, we would enhance the dashboard design to make it even more interactive. Given our use of R Shiny, we have already made it able to handle large datasets and produce dynamic visualizations. However, there is still room to optimize performance and guide users through the insights of F1 (through a video game) more effectively.

Something unique to our group, we chose to use R Shiny over other tools like Tableau or Power BI. This allowed us to manage and visualize large volumes of data more efficiently, while also making the dashboard accessible to our targeted audience. Our project also stands out due to the scale of the data we worked with. Lap-by-lap information across multiple sessions allowed us to treat this as a client-facing product, with real value for future DS 4010 students as an educational tool.

### Availability

The F1 dashboard project, a comprehensive data visualization tool for Formula 1 statistics and analytics, is housed in Seth Lors' GitHub repository (<https://github.com/sethlors/data-drivers>), where all source code is publicly available. Regarding maintenance, Seth has established a four-year commitment to actively maintain the codebase, during which he will conduct regular functionality checks, ensure all features operate properly, implement necessary updates, and resolve any emerging issues. Following this active maintenance period, the repository will transition to an archived status, remaining publicly accessible for reference and forking purposes, though no longer receiving updates. For user access, the dashboard is currently hosted on Posit Connect Cloud, providing convenient browser-based interaction without requiring local installation or execution. This hosting arrangement will continue as long as usage remains within the free tier limitations of Posit Connect Cloud. Should usage eventually exceed these thresholds, the dashboard will require local execution, whereupon users would need to clone the repository and run the application on their own machines. This dual approach to hosting ensures the dashboard's long-term availability and accessibility for researchers, fans, and analysts interested in F1 data visualization.

### References

(1) Lock, D., & Nettleton, D. (2014). Using random forests to estimate win probability before each play of an NFL game. Journal of Quantitative Analysis in Sports, 10(2), 197-205.
