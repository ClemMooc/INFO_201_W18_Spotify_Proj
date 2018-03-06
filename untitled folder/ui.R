library(shiny)
library(shinythemes)
library(plotly)

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
                      sliderInput(
                        inputId = "slider",
                        label = h4("Number of Top Songs"),
                        min = 0,
                        max = 100,
                        value = 100,
                        step = 10
                      )
                    ),
                  
                    conditionalPanel(
                      condition = "input.conditionedPanels == 2",
                      textInput(
                        inputId = "text",
                        label = h4("Specify Spotify User"),
                        placeholder = "Enter username..."
                      ),
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
                        inputId = "slider2",
                        label = h4("Year Range"),
                        min = 2006,
                        max = year,
                        value = c(2006, year),
                        sep = ""
                      )
                    )
                  ),
                  
                  mainPanel(
                    tabsetPanel(
                      tabPanel(
                        "Trending",
                        h2("What's Trending?"),
                        h3(),
                        
                        actionButton("action", label = "Action"),
                        ## Plot charts showing top artists, songs, genres, etc
                        ## Trending in each country??/state
                        ## 
                        value = 1
                      ),
                      
                      tabPanel(
                        "Your Music",
                        h2("Your Music"),
                        h3(),
                        ## Plot charts showing top artists, songs, genres, etc
                        ## Based on inputted user name, maybe based on slider somehow
                        
                        ## Songs/artists/genres listened to per season bargraph
                        
                        fluidRow(column(
                          6,
                          plotlyOutput(outputId = "pie"),
                          height = 50
                        ),
                        column(6,
                               plotlyOutput(outputId = "pieChart2"))),
                        value = 2
                      ),
                      
                      tabPanel(
                        "Music Map",
                        h2("Most Popular Genres Around America"),
                        h3(),
                        ## Plot a map where you can hover over it and show most popular genre in area.
                        ## Only if API has such information.
                        value = 3
                      ),
                      
                      id = "conditionedPanels"
                    )
                  )
                ))