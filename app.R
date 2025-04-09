library(shiny)
library(dplyr)
library(ggplot2)
library(caret)
library(shinythemes)
library(shinyjs)
library(plotly)

# Load dataset with error handling
load_data <- function(file_path) {
  if (!file.exists(file_path)) {
    stop("File does not exist: ", file_path)
  }
  df <- read.csv(file_path, stringsAsFactors = FALSE)
  colnames(df) <- make.names(colnames(df))
  colnames(df) <- gsub("[.()]", "_", colnames(df))  # Replace dots and parentheses with underscores
  return(df)
}

# Data Preprocessing
preprocess_data <- function(df) {
  df$Industry <- as.factor(df$Industry)
  df$Year_Founded <- as.numeric(df$Year_Founded)
  df$Age <- 2025 - df$Year_Founded
  df$Revenue <- df$Investment_Amount__USD_ * df$Growth_Rate____ / 100  # Revenue Calculation
  df <- df %>%
    select(Startup_Name, Valuation__USD_, Growth_Rate____, Industry, Investment_Amount__USD_, Number_of_Investors, Year_Founded, Funding_Rounds, Revenue, Age)
  return(df)
}

# Train Regression Model
train_model <- function(df) {
  set.seed(123)
  train_index <- createDataPartition(df$Valuation__USD_, p = 0.8, list = FALSE)
  train_data <- df[train_index, ]
  model <- lm(Growth_Rate____ ~ Valuation__USD_ + Industry + Investment_Amount__USD_ + Number_of_Investors, data = train_data)
  return(model)
}

# Suggest Startups Based on Valuation and Growth Rate
suggest_startups <- function(df, valuation_threshold, growth_rate_threshold, industry_type) {
  suggested_startups <- df %>%
    filter(Valuation__USD_ >= valuation_threshold & Growth_Rate____ >= growth_rate_threshold & Industry == industry_type) %>%
    arrange(desc(Growth_Rate____)) %>%
    head(10)
  return(suggested_startups)
}

# UI Definition
ui <- fluidPage(
  titlePanel("Startup Growth Investment Suggestions"),
  useShinyjs(),
  theme = shinytheme("darkly"),
  sidebarLayout(
    sidebarPanel(
      selectInput("industry_type", "Select Industry Type:", 
                  choices = c("AI", "Biotech", "Blockchain", "E-commerce", "EdTech", "Fintech", "HealthTech", "SaaS"), 
                  selected = "AI"),
      numericInput("valuation_threshold", "Valuation Threshold (USD):", value = 100000000),
      numericInput("growth_rate_threshold", "Growth Rate Threshold (%):", value = 80),
      actionButton("submit", "Get Suggestions")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Suggested Startups", tableOutput("suggested_startups")),
        tabPanel("Industry Overview", plotOutput("industry_plot", height = "600px")),
        tabPanel("Performance Insight", plotlyOutput("combined_plots", height = "700px"))
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  file_path <- "startup_growth_investment_data.csv"  # Change this to your file path
  df <- load_data(file_path)
  df <- preprocess_data(df)
  model <- train_model(df)
  
  observeEvent(input$submit, {
    suggested_startups <- suggest_startups(df, input$valuation_threshold, input$growth_rate_threshold, input$industry_type)
    output$suggested_startups <- renderTable({
      suggested_startups
    })
    
    output$industry_plot <- renderPlot({
      industry_counts <- df %>%
        group_by(Industry) %>%
        summarise(Count = n())
      
      ggplot(industry_counts, aes(x = "", y = Count, fill = Industry)) +
        geom_bar(stat = "identity", width = 1) +
        coord_polar("y", start = 0) +
        theme_minimal() +
        theme(plot.background = element_rect(fill = "#f0f0f0"))
    })
    
    output$combined_plots <- renderPlotly({
      p1 <- ggplot(suggested_startups, aes(x = Funding_Rounds, y = Valuation__USD_)) +
        geom_line(color = "blue") +
        geom_point() +
        theme_minimal() +
        theme(plot.background = element_rect(fill = "#e6f7ff"))
      
      p2 <- ggplot(suggested_startups, aes(x = Revenue, y = Valuation__USD_)) +
        geom_line(color = "purple") +
        geom_point() +
        theme_minimal() +
        theme(plot.background = element_rect(fill = "#fff0f5"))
      
      p3 <- ggplot(suggested_startups, aes(x = Year_Founded, y = Investment_Amount__USD_)) +
        geom_line(color = "red") +
        geom_point() +
        theme_minimal() +
        theme(plot.background = element_rect(fill = "#f5f5f5"))
      
      p4 <- ggplot(suggested_startups, aes(x = Age, y = Growth_Rate____)) +
        geom_line(color = "green") +
        geom_point() +
        theme_minimal() +
        theme(plot.background = element_rect(fill = "#f0fff0"))
      
      subplot(ggplotly(p1), ggplotly(p2), ggplotly(p3), ggplotly(p4), nrows = 2)
    })
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
