library(shiny)
library(shinythemes)
library(plotly)
#source('data/global.R')
## Variables
year <- as.numeric(format(Sys.Date(), "%Y"))

ui <- fluidPage(theme = shinytheme("darkly"),
                fluidRow(column(1,h1("Spotify"))),
                fluidRow(h1()),
                pageWithSidebar(
                  headerPanel(""),
                  
                  sidebarPanel(
                    width = 4,
                    
                    conditionalPanel(
                      condition = "input.conditionedPanels == 1",
                      h3("Hello World!")
                    ),
                    
                    conditionalPanel(
                      condition = "input.conditionedPanels == 2",
                      textInput(
                        inputId = "text",
                        label = h4("Specify Spotify User"),
                        placeholder = "Enter username..."
                      ),
                      actionButton("action", label = "Submit Username"),
                      # x <- Year account created (from server output)
                      # if(x == 2018){
                      sliderInput(
                        inputId = "slider",
                        label = h4("Year Range"),
                        min = 2006, # x,
                         # Change to year account created
                        max = year,
                        value = c(year-1, year),
                        sep = ""
                      )
                      # } else {
                      #     h4(paste("Results for", year, sep = " "))
                      # }
                    ),
                    
                    conditionalPanel(
                      condition = "input.conditionedPanels == 3",
                      sliderInput(
                        inputId = "slider",
                        label = h4("Number of Top Songs"),
                        min = 0,
                        max = 100,
                        value = 100,
                        step = 10
                      )
                    )
                  ),
                  
                  mainPanel(tabsetPanel(
                    tabPanel("README",
                             h3(),
                             value = 1),
                    
                    tabPanel("Your Music",
                             h2(textOutput("name")),
                             h3(),
                             fluidRow(
                               column(
                               4,
                               plotlyOutput(outputId = "explicit"),
                               height = 50
                             )),
                             value = 2),
                    
                    tabPanel("Trending",
                             h2("What's Trending?"),
                             h3(),
                             value = 3),
                    
                    id = "conditionedPanels"
                  ))
                ))