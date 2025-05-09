## Team Formation

Once we were assigned to our groups at the beginning of the semester, our group first wanted to decide what our interests were and how we could apply them to our data exploration for the capstone project. Our group came to the conclusion that doing data analysis with Formula 1 data would be a great choice because we all either had previous F1 knowledge or were curious to learn more about it through creating the dashboard. When it was time to figure out what our team name should be shortly after, Ryan came up with the cool name "Data Drivers" on the spot, and that's what we ended up going with in the end as it relates to what our F1 data is about. Additionally, someone who doesn't know anything about our data analysis could easily tell from our name that our project must have something to do with cars. 

## 2025-02-17: Acquire Data Milestone


### Project Goals:

Ryan:

Our main project goal is still to create a data dashboard that explains and discovers new findings in the F1 datasets our team pulled from the F1 website. To break it down even more, some current goals are to find trends with the weather data, pit stop data, stints data, and laps data and join them to find correlations between them. So, the scientific question we are trying to address currently here is: Is there a correlation/trend between the x data set and the y data set? Knowing our audience is current and future DS 4010 students, if we do find any significant trends within our different datasets, our group will start to create rough drafts of data visualizations that we could potentially put in our final data dashboard.



### Team Evaluation:

Seth:

Our team is making steady progress toward our end-of-semester goal of developing a functioning dashboard for predicting F1 pit stops/tire strategies. We communicate effectively through Discord, regularly assigning tasks and ensuring that each member understands their responsibilities. By aiming to complete assignments a few days before their deadlines, we give ourselves time for revisions and troubleshooting. However, potential obstacles include data availability issues. Our current API only has data from 2023 and 2024 which could lead to weak prediction models. To overcome this, we as a class have set realistic milestones, and will remain flexible in adjusting our approach when needed. By staying proactive and collaborative, we are confident in achieving our final goal. 



### Technology Plan:

Maxwell: 

For data collection, we have used R to pull from the OpenF1 API. In addition to creating custom functions to pull data from the OpenF1 API, we have also looked closely at a previously published R package f1dataR for visualizations and pulling more comprehensive F1 data, this is still being scoped out how we are going to fully use this package as it is pulling F1 data from a different data source than OpenF1. For model creation, we plan to use R and Python to create a model to predict pit stops/tire strategies. For dashboarding, we will either use Tableau or create a R Shiny web app, we haven't fully decided as we are still researching if it is possible to implement R scripts inside of a Tableau dashboard and to be able to create dynamic visualizations of F1 data. 


### Data Wrangling:

Maxwell:

For data wrangling, we have primarily used the OpenF1 API to pull F1 racing data. We created R scripts that pulls the data into csv files separated by year. We have also created get methods to pull the data easily into data frames in R for better analysis, these methods can be found in the R folder on our github repo. Basic visualizations of driver's racing location on a given race has been created, but we plan to include dimensions like weather, tire material, lap information, position information, and pit stop data to be able to better flesh out these visualizations. Our current data source, OpenF1, has had some limitations for our project. There is only 2 years worth of racing data, the API lacks race and championship standings, schedules, starting grids, overtakes, undercuts/overcuts data, and tyre statistics. All get methods are pulling separate kinds of data, and work has begun on joining these different datasets together for further analysis. 



## 2025-02-24: Project Goals Milestone

### Project Goals

Seth: 

The target audience for this dashboard consists of beginner and casual F1 fans who are eager to enhance their understanding of the sport. The dashboard will be useful to provide insights for fans interested in exploring how various factors, such as weather conditions and tire compounds, impact F1 race outcomes. To effectively communicate the project’s findings and conclusions, a clear explanation of F1 principles and terminology is essential. In our final dashboard, we will have a quick explanation of what F1 is. During the research phase, we discovered a similar F1 dashboard created by Arizona State University, which is linked in our GitHub repository. One defined research question for this project is: What are the key variables that can help teams predict the optimal tire strategy for different race conditions?

### Exploratory Analysis:

Zack: Our exploratory analysis has begun and we have started with some driver location mapping using the f1data package. We are all currently working on creating more visualizations and sifting through our data searching for potential model predictors. One lead we have discovered is potentially using weather and race position to look at race time and tire selection. It was suggested to us that we look into how teams are selecting their tires so we have also begun analysis into finding variables that impact tire choice, potentially in both the race and qualifying stages of an event. In our initial analysis, we found that there is a strong correlation between weather and the type of tire used. The current goal moving forward in our exploratory analysis is to find some quirks or interesting patterns in the data set that we could move forward with.


### Modeling Plan:

For our Formula 1 data science project, time series models will likely be necessary due to the sequential nature of the data, capturing trends in tire performance over time. Additionally, regression models will be explored initially to identify correlations between variables. The key predictors include weather changes throughout the race, the driver’s placement, stint length, and lap times, as these factors may influence tire degradation. The response variable we aim to predict is the tire compound used at a given point in the race. One challenge we may face is that real-world conditions may not align perfectly with the assumptions of ideal models, such as constant track conditions or independent observations.

### Project Progress:

Ryan: After week 5 of our capstone project, each team member has contributed their unique strengths to this project to start finishing our exploratory data analysis portion of the data dashboard. Max has contributed several R and Python packages to help the exploratory data analysis process go much smoother and faster. Seth has started to look at different aspects of our cleaned data and then combined some data to make it more readable. Zack has also looked into combining different areas of our cleaned data as well. Ryan has kept the different markdown files up to date, ensuring that the cleaned data reflects what has been updated to GitHub. Each team member has tech stack ready on their local machines. The next steps for our team are to complete the exploratory data analysis for our F1 data and start creating data visuals for our dashboard. The team has communicated very well, and everyone has been extremely responsive, including on the weekends. Each team member has a different and unique plan moving forward to ensure that the dashboard data visuals are effective and have reliable meaning behind them.


## 2025-03-03: Exploratory Analysis Milestone

### Brainstorm Dashboard:
Ryan: The main message our group is trying to convey with the dashboard is to show the different trends/correlations in F1 racing and show how to be the most successful as an F1 driver on a particular racing day given the track, time, weather, etc. Our group wants to make sure there are at least basic, static plots in our dashboard that describe certain trends that are visually easy to see. We also want to incorporate interactive elements as well, especially with the different track maps/pit stop data through R Shiny, to show the percentage of drivers who stopped for a pit stop at a certain time during the race, given the race map and other additional features. Our group has already created rough drafts of visuals through R that could be potential candidates for our dashboard. We are still deciding if a machine-learning method should be used for our data. Next week, we plan to start creating a sketch of what we want our dashboard should look like and what different features it should have. We will most likely use a data dashboarding tool like Tableau to display the data.

### Data Report:
Seth: Right now, our data includes race metrics like lap times, tire stints, pit stops, and weather conditions. We used to only have the raw data files, but now have all of our data cleaned and ready for visualizations. The dataset appears comprehensive, but it’s worth considering if additional data such as degradation rates or stint lengths relative to tire age could improve predictions. If the current data sufficiently captures the impact of tire strategies, then we can proceed with analysis using statistical models and potentially machine learning. Some datasets, like the meetings file, may no longer be necessary if their information can be merged into existing table. Right now, we have separated all of our data in separate cleaned files but they are all easily joinable with unique keys. 

### Project Progress:
Zack: The biggest change the group had to overcome this week was switching our primary data source away from OpenF1 to Ergast. As part of this transition, we intend to update the structure of GitHub and provide the necessary details and metadata to make the data usable. The team has been communicating very well, making great use of the discord channel to share ideas, recommend changes, and post visualizations. Consistent in-class attendance has also ensured that the group remained focused and moving forward over this past week. Moving forward, the biggest step for the team is to be able to take the (mostly) clean data we have available and begin to craft a rough vision of what our dashboard should look like. Max intends to look into creating visualizations using location data to create visuals that show the track shape. Seth plans to work on the Github infrastructure and clean up the data processing methods in place. Ryan is working on updating the information present in markdown files and keeping the repo organized. Zack is working on early-stage visualizations and models to try to provide ideas for the dashboard.

### Exploratory Analysis:
 
Maxwell: After week 6 of our capstone prospect. We have made some major changes over time that has affected our project. We changed our main data source from OpenF1 to the Ergast dataset. Ergast has cleaner, more robust, and more historical F1 data to work with. We still plan on using some of OpenF1's data for our project, but that will likely extend to its location driver data and possibly the second by second breakdowns of the driver racing data during a given race. In terms of exploratory analysis, we have done a lot of work on focusing on driver pit stop durations and how it affects overrall lap times. Seth has done some great work in visualizing this data. There have been no major issues with the Ergast dataset compared to the OpenF1 previously. We are still looking at what predictors are the most important in determining lap times but we looking extensively at stint, pit stop, and car data to find these. An interesting problem we have run into is plotting lap times of all drivers across certain races, we found a lot of outliers that made the visualizations pretty misleading, but found that things like penalties would affect the lap times and thus we are working on looking at what outside factors that are normal to the race, could skew or extend a given driver's lap time and how do we accommodate that. 


## 2025-03-10: Brainstorm Dashboard Milestone

### Brainstorm Dashboard:

Ryan: The general message our group is trying to convey with the dashboard is to give the optimal strategy for winning a professional F1 race, given the current weather conditions and the track used for the race. Our group also wants to include fun statistics that our audience may find interesting. We want to include interactive pieces similar to the track and tire strategy data visuals found on https://rapit.com.br/ that do a good job of having interactive elements to see data at different times of the race. Our team plans to integrate this through R shiny so all of our data manipulation and visualizations are in one place. However, if R shiny does not do a good job for us, we will explore JavaScript instead to see if it fits the interactive aspect better. So far, our group has done an excellent job creating static data visuals (we have about 20 rough drafts). So far, the data has looked accurate and shows significant differences in the data models. The data we want to include the most in our dashboard are the stints, results, race, and weather data files because these have the most data, and there have been significant findings so far with these datasets. Our team is going off of this data dashboard we found from Arizona State University that mainly focuses on tire data (https://cisa.asu.edu/sites/default/files/2024-04/Mugge_E_Zandieh.pdf) as a blueprint/sketch for our dashboard that has very effective visuals and also concise explanations of what the data shows. The key functionality we want to use with our chosen dashboarding tool is to make sure the audience can hover over certain parts of a track or tire to see impactful data related to that section.

### Finalize Data Models

Zack: So far in our data analysis we have looked into a couple different types of models. Initial testing with simple linear regression attempting to predict lap time resulted in multiple model assumption violations. One potential solution we are looking into is performing analysis on qualifying data because each racer drives individually and is therefore, in theory, not affected by the attempts run by the other drivers. Due to the time based nature of the data we discussed potentially utilizing time series strategies to fit models but it was recommended that we attempt to avoid that due to the complicated nature of time series data. The models we are currently looking into involve trying to find if there is a way to model that ideal tire strategy for a race given weather conditions, position, etc. We have not attempted to use a model selection process yet but it may advantageous to do so because we have a decent amount of potentially important variables. 

### Project Progress:

Maxwell: The next steps of this project is to create a minimum viable project dashboard, as well as make some major steps towards the modeling component of the project. The team is communicating well either through discussions in class or frequent messaging in our discord channel. There have been no issues in terms of communication. Each team member is focusing on their own aspect of the project and is checking in continuously with the other members of the group on their progress. Since we are primarily focused on R and some Python, each member has the tech stack ready on their local machine. There are no current major roadblocks as we have successfully transferred data sources. 

Current work done by each team member: 

- Maxwell Skinner: Data cleaning/acquisition of OpenF1 data source. Completed visualizations of F1 race data from both OpenF1 and Ergast datasets. Created sample dashboards in both R Shiny and Tableau. 
- Seth Lors: Pulled all of the data needed from both datasets and cleaned them into csv files on the github repo. Has done considerable work on the strucure of the repo and organizing 
- Ryan Riebesehl: Kept markdown files up to date and ensured that the cleaned data reflects what has been updated to Github. Ryan has also done with on creating visualizations of the F1 data. 
- Zack S: Worked on early-stage visualizations and has done work on the modeling aspect of the project. Has also worked on combining different areas of the clean F1 data.  


### Custom Milestone: Dashboarding Tech

Seth: So far, we’ve explored various technologies for visualizing F1 data. Initially, R was the primary tool, leveraging packages like ggplot2 for static plots and plotly for interactive visualizations. Given the need for more dynamic and web-based visualizations, we considered JavaScript libraries such as D3.js and Chart.js, which offer powerful ways to render telemetry and lap time data. Additionally, React with frameworks like Recharts was explored for building interactive dashboards. Due to the complexity and time constraint of this project, we will probably end up with a R shiny app that displays all of the information we need. Future improvements could take the JavaScript approach and create the visualizations we will have in Shiny and make them more visually appealing and fit the Formula 1 design aesthetic.

## 2025-03-16: Finalize Data Models Milestone

### Finalize Data Models

Zack: We are considering using a random forest model, which is well-suited for handling non-linear relationships, multiple variables, and large datasets. To optimize the model, hyperparameters like tree depth and number of trees can be tuned using grid search or cross-validation to improve generalization. The dependent variable depends on our end goal. If we end up predicting lap times, it’s continuous; if classifying race outcomes, it’s categorical; and if predicting race completion, it’s binary. Key explanatory variables could include track conditions, driver stats, car performance, and tire strategy choices. Challenges include data quality issues (missing values, inconsistencies), feature selection (avoiding noise while keeping key factors), and computational efficiency, as random forests can be resource-intensive. Assumptions include having enough data for meaningful predictions and ensuring no single variable dominates results. If dealing with time-series data, incorporating lagged variables or rolling averages may be necessary. The model aims to answer questions like: What factors influence race performance? What’s the best tire strategy? How do conditions affect lap times? These answers will ultimately answer how we communicate this data to the people who use our dashboard. Right now, our dashboard will look something like this:

<img width="1366" alt="Screenshot 2025-03-16 at 6 52 00 PM" src="https://github.com/user-attachments/assets/fb723eec-4519-490a-a4d4-3c07e2e81c13" />

### Project Progress

Seth: The R environment is fully set up with necessary libraries like shiny, tidyverse, and f1dataR. CSV files are well-organized, and scripts are running without major compatibility issues. Moving forward, we plan to enhance documentation to make setting up the environment locally as seamless as possible. The immediate next steps involve implementing dropdown-based filtering and interactive plots to improve usability. The team is communicating effectively via Discord, successfully balancing both online and in-person collaboration. A key challenge we are currently facing is selecting a suitable model. Many of our approaches so far have been limited by various constraints, making it difficult to identify a successful model. Overcoming this roadblock will be a primary focus in the next phase of the project.

### Dashboard Sketch

Ryan: The problems that our project will solve will be illustrated by using both a static and non-static dashboard. Our static dashboard will be in the format of a PDF file, and our non-static dashboard will be in the form of a website URL so the target audience can reach them. We still plan to go off of this dashboard (https://cisa.asu.edu/sites/default/files/2024-04/Mugge_E_Zandieh.pdf) for our static dashboard and this website (https://rapit.com.br/) for implementing interactive elements in our non-static dashboard. The current layout our group is thinking about is like this,

<img width="1366" alt="Screenshot 2025-03-16 at 6 52 00 PM" src="https://github.com/user-attachments/assets/fb723eec-4519-490a-a4d4-3c07e2e81c13" />

where we have different interactive elements about a particular race. We will probably include 2-3 additional different tabs to jump from where users can look at different ML methods we used to predict certain features of the data. Having two different dashboards will definitely give us room for everything we need to include. We still plan to add the interactive pieces through R shiny using a website users can access. Our group will incorporate these models by clicking through a different list of races/dates to show the different trends that happened during that particular race. With the data we have and what we want to include, our dashboard will have many functional elements throughout. The current models our group plans to include are the fastest lap times for each driver, the tyre type strategy used on that race day, and any additional fun statistical differences we find important during that particular race. The only thing blocking us from implementing everything is gaining more knowledge on R Shiny and what different features we can learn about to implement it for our non-static dashboard. We plan to make the dashboard visually appealing using a wide variety of colors and aesthetics matching F1 racing culture. 

### Spring Break Plans

Max: Since the team is on track to finish before the deadline, we decided we do not need to spend time over Spring Break working on our F1 project. If we end up having time, we've assigned these tasks to each person: Max is going to work on ways to style our dashboard better to be more visually appealing, Ryan is going to come up with more ideas on how to organize and structure our dashboard, and Zack/Seth/Ryan are going to identify different variables to use in a Random Forest model.  

## 2025-03-30: Finalize Dashboard Sketch

Our F1 Data Dashboard is an interactive interface designed to provide insightful visualizations and analysis of Formula 1 race data. It offers dropdown menus for selecting seasons and race rounds, making it easy to navigate through historical data. The dashboard highlights key metrics like lap times, pit stop strategies, and driver performances. There is going to be a second part of our dashboard to predict the fastest lap for future sessions. It will use the metrics Driver, Track, and Year to help predict future fastest laps. By integrating multiple datasets, the dashboard enables fans and analysts to explore detailed race insights, compare driver strategies, and identify patterns across different circuits. With its responsive layout, the F1 Data Dashboard serves as a powerful tool for both casual fans and dedicated motorsport enthusiasts. We are also working on potential models to predict lap times for specific tracks based on race position, lap number, tire type, and other factors.

<img width="1366" alt="Screenshot 2025-03-16 at 6 52 00 PM" src="https://github.com/user-attachments/assets/fb723eec-4519-490a-a4d4-3c07e2e81c13" />

## 2025-04-06: Minimum Viable Dashboard

The current status of the F1 Race Analysis dashboard is designed to provide an interactive experience with a focus on race results and tire strategies. Users can input the year and track from dropdown menus, which dynamically updates the content displayed on the dashboard. Once a user selects a year and track, the race results and tire strategy for that specific race are shown. Features:

User Input:
Year: Users can choose a specific year from a list of available years.

Track: Based on the selected year, the track dropdown dynamically updates with relevant tracks for that year.

Dynamic Updates:

Race Results: When a user selects a year and track, the race results table is updated with driver information, race times, positions, and points based on the selected race.

Tire Strategy Visualization: The tire strategy plot visualizes the tire stints for each driver in the selected race. The plot updates dynamically when the user selects a different year or track, showing the number of laps completed on each tire compound for all drivers.

The user input directly influences the race data displayed, such as updating the results table with race outcomes and generating an updated tire strategy plot. This ensures that the dashboard is interactive and responsive to user selections.

Here is the link to instructions to run locally (https://github.com/sethlors/data-drivers/blob/main/Info.md)

## 2025-04-13: Add Models to Dashboard

The current state of the F1 Race Analysis dashboard is the same as reported in the previous week with the addition of the win probability plot using our random forest win probability model.

Model Overview: The win probability model used to create the plot is a random forest model. The training data is lap-by-lap data for each driver in each race. There are seven models trained for the seven years in the data set. Depending on which year is selected in the drop down menu, the predicted values correspond to the model in which that year was the testing data (to avoid over fitting/double dipping on training data) The model currently has 500 trees and a minimum node size of 200, but these numbers will likely change as we analyze which combinations perform the best.

Response Variable: Winner, a numeric value of 0 if the driver lost the race and 1 if the driver won the race.

Explanatory Variables:
- Laps Remaining: Laps left in the race
- Tire Compound: type of tire used by the driver in that lap; factor including hard,soft,medium,wet
- Track Status: Factor indicating if the track is clear, at a yellow flag, red flag, or other status
- Position: Place the driver currently is at in the race
- Time Back: Time back, in milliseconds, the driver is from first
- Circuit: The race track the race took place on
- Season Standing: The place in the overall driver's standings the driver was before the race

Future Plans: The win probability model is still a work in progress and we are working on cleaning the data and experimenting with other possible explanatory variables. We are also considering adding a similar random forest model that attempts to predict final position instead of simply winning or losing. The win probability model visualization plot also needs to be updated for usability. Overall, the group is in a good spot and the dashboard is nearly complete.

Here is the link to instructions to run locally (https://github.com/sethlors/data-drivers/blob/main/Info.md)

## 2025-04-20: Dashboard Peer Review
[This dashboard](https://lorsseth-data-drivers.share.connect.posit.cloud/) is supposed to help you visualize and understand how race strategies evolve over the course of the race selected. 
In the bottom right corner of the dashboard, there is an information button that will give a basic understanding of Formula 1 before using the dashboard. 

Here is a more in depth explanation:
[Formula 1 Explanation](https://github.com/sethlors/data-drivers/blob/main/f1-explanation.md)

## 2025-04-27: Finalize Dashboard Milestone

After we finalized our dashboard for peer review, we received valualbe feedback on what we could imrpove on the dashboard. As a team, we summarized the main points of feedback:

- *Audience Clarity:* Clarify whether the dashboard is meant for casual fans or dedicated F1 followers, and adjust the depth of insights accordingly (or explain your choice clearly in the introduction).
 
-	*Context and Definitions:* Add brief definitions for key terms like tire compounds and explain how win probability is calculated, either in tooltips, a glossary tab, or an info section.
 
-	*More Contextual Information:* Annotate major shifts in the win probability graph (e.g., crashes, penalties) to make the chart more meaningful.
 
-	*Expand Visuals:* Include a few more general stats (e.g., histogram of finish times, fastest laps) and possibly a full race results tab to avoid crowding the main page.
 
-	*Minor Layout Tweaks:* Improve how logos and portraits behave on vertical or mobile layouts to prevent overlap, and consider zoom or filter options for dense graphs like the win probability chart.

With this feedback, we will focus on making changes related to the "Audience Clarity". This will be the easiest of the feedback to improve on with the little amount of time left in the semester.
