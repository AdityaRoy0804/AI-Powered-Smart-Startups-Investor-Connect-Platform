# AI-Powered-Smart-Startups-Investor-Connect-Platform
An interactive startup investment analysis and suggestion system built using R Shiny, designed to assist investors in discovering high-growth startups based on real-time inputs like valuation, growth rate, and industry. The app performs data preprocessing, model training, and provides insightful visualizations for data-driven decision-making.

🧩 Key Functionalities
📥 1. Data Loading & Preprocessing
Loads CSV dataset with error handling.

Cleans and standardizes column names.

Calculates additional features like:

Age of startup

Revenue as a function of investment and growth rate.

Selects and restructures relevant columns for modeling and analysis.

🧠 2. Model Building
Trains a linear regression model using the caret package.

Target variable: Growth_Rate____

Features used: Valuation, Industry, Investment Amount, and Number of Investors.

💡 3. Startup Suggestion Engine
Based on investor-defined:

Minimum valuation

Minimum growth rate

Preferred industry

Filters and ranks top 10 startups dynamically using dplyr.

📊 4. Data Visualization
Industry Overview Panel:

Polar bar plot showing distribution of startups across industries.

Performance Insight Panel:

4 dynamic plots using plotly:

Funding Rounds vs Valuation

Revenue vs Valuation

Year Founded vs Investment

Age vs Growth Rate

🎯 Goal
To build a community-focused investor dashboard that allows quick filtering and comparison of startups based on performance metrics. The system leverages statistical modeling and interactive data exploration to highlight promising investment opportunities.

🖥️ Built With
R – Data manipulation, modeling

Shiny – Web application interface

ggplot2 – Static visualizations

plotly – Interactive dashboards

dplyr – Data wrangling

caret – Model training and evaluation

shinythemes & shinyjs – UI enhancements

