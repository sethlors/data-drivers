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


### Project Progress:


 ### Exploratory:
