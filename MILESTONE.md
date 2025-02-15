## 2025-02-17: Acquire Data Milestone


### Data Wrangling:



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
