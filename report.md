# Report Rubric

The intended audience for the report is new DS 4010 students. 
Approximately 75% of the report should be devoted to behind the scenes data 
pipeline content while the remaining 25% should be devoted to the application. 
Throughout the report include visualizations and tables that will help the 
reader understand the process you used. 

Please mention anything that was unique to your group where relevant in the 
report. For example, the size of you data set. 
Also describe investigated approaches that were ultimately not used. 


## Format

With the targt audience being new DS 4010 students, what would be an appropriate
format?

- md/html?
- Word/pdf?

Ultimately this should live in your repository

## Length

The writing should be 3-5 pages, 
but including pictures and tables may make the report longer. 


### Data Pipeline



#### Data collection (ETL) - Ryan

Describe how the data were collected, cleaned, and transformed into a suitable
format for use in the project.

Address the following questions:

- What data sources were used?
  - If relevant, provide references/urls for the sources.
  - How were the data obtain?
    - Downloaded as Excel/csv? Used an API? If API, what software?
    - Describe the process
- How were the data cleaned? 
  - Were the data filtered to a subset?
  - Was there missing data? If yes, how was this dealt with?
- If multiple data sources were used, how were the data joined?
  - What decisions were made in this combining?
- How were the data stored for use in the dashboard?
  - How was efficiency (hard drive, load time, etc) considered in storage?
  
#### Modeling - Zack

Describe the modeling used in the project include modeling attempts that were
not (ultimately) included in the dashboard. 

- How does the modeling effort support the project goal?
  - What is the purpose of the model? prediction? understanding?
- What models were used?
  - Response (dependent) variable(s)
  - Explanatory (independent variable(s))
  - What is the name of the model?
  - Describe the model used. (it is not enough to simply name the model)
    - Perhaps include the mathematics or algorithm behind the model.
- What software is used to implement the model? 
  - What packages were used? 
  - Provide realistic, but simplified code.
- Are models created in real-time or pre-estimated?
  - If real-time, what can a user specify?
  - If pre-estimated, how are model results stored?

#### Dashboard - Seth

The F1 Race Analysis Dashboard uses R Shiny to visualize complex Formula 1 race data into an intuitive and comprehensive visualization page. It is a single-page vertical scrolling interface that guides users through a complete race narrative, beginning with essential race statistics in the header and stats bar, progressing to a podium visualization, and culminating in detailed race results, tire strategy analysis, and win probability evolution charts. The dashboard's architecture allows both casual fans and data enthusiasts to explore race stories across multiple factors while maintaining a cohesive visual experience.

User interaction is streamlined through two straightforward selection inputs: a year dropdown filtering seasons from 2019-2024 and a dynamically populated track selector that adjusts based on the chosen year. This focused approach to navigation enables intuitive exploration of historical data while facilitating meaningful comparisons between races at the same circuit across different seasons. The dashboard's five reactive outputs: fastest lap statistics, podium visualization, race results table, tire strategy plot, and win probability chart which respond instantly to these selections, creating a seamless analytical experience enhanced by F1's official color schemes and branding elements.

The technical implementation combines R Shiny's reactive framework with dplyr for efficient data transformation, ggplot2 and Plotly for interactive visualizations, and custom CSS styling to create an authentic Formula 1 aesthetic. Particular attention has been paid to visual details, including team-specific color coding, custom F1 typography, and racing iconography that significantly enhances user engagement. When creating the dashboard, we focused on creating a consistent F1 visual identity while maintaining analytical depth, implementing interactive elements that reveal contextual data on demand, and providing graceful error handling for cases with missing or incomplete information. This blend of analytical capability and branded styling delivers an engaging tool that transforms raw race data into compelling visual narratives that appeal to the full spectrum of Formula 1 enthusiasts.

### Application

Application, in this context, refers to the scientific question of interest and
the intended audience.

#### Goal - Max

Early in the report, likely before any data is discussed, describe the goal
for the project.

- What is the goal for the project?
  - What are you trying to achieve with the project?
- Who is the intended audience?
  - Who would be interested in your project?
  
#### Learning

- What did you learn about your application? 
  - What choices did you make? 
- How well does the modeling support your project goals?


### Discussion - Seth

As we progressed through the semester, our understanding of Formula 1 deepened significantly beyond the surface-level excitement of fast cars. We discovered that F1 is a complex technical sport where success hinges on intricate strategic decisions involving multiple variables. Our analysis of tire management data revealed how different compounds (soft, medium, hard) offer varying levels of grip and durability, creating a fundamental strategic trade-off. Teams must constantly balance the speed advantage of softer compounds against their shorter lifespan, often making race-defining decisions under pressure. The data highlighted how critical pit stop windows are, with teams making split-second decisions based on competitor actions, weather changes, and tire degradation patterns that can determine race outcomes. We also learned that different circuit characteristics (high-speed, technical, street circuits) demand entirely different approaches to race management, with some tracks clearly favoring certain teams' car designs based on their aerodynamic and mechanical properties.

Finally, our project illuminated the growing role of data science in modern motorsport. We learned how F1 teams process terabytes of telemetry data during races to optimize strategy in real-time, making this perhaps the most data-driven sport in existence. Pre-race modeling and simulation have become essential competitive tools, with teams running thousands of race scenarios before even arriving at a circuit. The increasing sophistication of predictive analytics extends beyond race performance to areas like driver talent evaluation, parts reliability modeling, and even market engagement strategies. These insights not only enhanced our technical implementation but gave us a deeper appreciation for how data science is transforming this high-performance sport, blending human skill, mechanical engineering, and computational analysis in a unique competitive environment. Formula 1 represents a perfect case study of how data-driven decision making can provide competitive advantages in complex, dynamic systems where milliseconds matter.
These insights not only enhanced our technical implementation but gave us a deeper appreciation for how data science is transforming this high-performance sport, blending human skill, mechanical engineering, and computational analysis in a unique competitive environment.

#### Next steps - Ryan

- What would you have done if you had more time? 
  - Would you have...
    - obtained more/better data?
    - built more sophisticated models?
    - improved the user experience?
  - How would you have made these changes?
- Remind reader of unique aspects for your group
  - PowerBi
  - Large data
  - Client
  
#### Availability - Seth

The F1 dashboard project, a comprehensive data visualization tool for Formula 1 statistics and analytics, is housed in Seth Lors' GitHub repository (https://github.com/sethlors/data-drivers), where all source code is publicly available. Regarding maintenance, Seth has established a four-year commitment to actively maintain the codebase, during which he will conduct regular functionality checks, ensure all features operate properly, implement necessary updates, and resolve any emerging issues. Following this active maintenance period, the repository will transition to an archived status, remaining publicly accessible for reference and forking purposes, though no longer receiving updates. For user access, the dashboard is currently hosted on Posit Connect Cloud, providing convenient browser-based interaction without requiring local installation or execution. This hosting arrangement will continue as long as usage remains within the free tier limitations of Posit Connect Cloud. Should usage eventually exceed these thresholds, the dashboard will require local execution, whereupon users would need to clone the repository and run the application on their own machines. This dual approach to hosting ensures the dashboard's long-term availability and accessibility for researchers, fans, and analysts interested in F1 data visualization.
