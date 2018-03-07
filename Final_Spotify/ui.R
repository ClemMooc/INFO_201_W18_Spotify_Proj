library("shiny")
library("shinythemes")
library("plotly")
library('knitr')
library('markdown')
#source('data/global.R')
## Variables
year <- as.numeric(format(Sys.Date(), "%Y"))

ui <- fluidPage(theme = shinytheme("superhero"),
                fluidRow(column(1,h1("Spotify"))),
                fluidRow(h1()),

                pageWithSidebar(
                  headerPanel(""),
                  sidebarPanel(
                    width = 3,
                    conditionalPanel(
                      h2("About SpotR"),
                      condition = "input.conditionedPanels == 1"
                    ),
                    
                    conditionalPanel(
                      condition = "input.conditionedPanels == 2",
                      textInput(
                        inputId = "text",
                        label = h4("Specify Spotify User"),
                        placeholder = "Enter username..."
                      ),
                      actionButton("action", label = "Submit Username")
                    )
                    
                    # conditionalPanel(
                    #   condition = "input.conditionedPanels == 3",
                    #   sliderInput(
                    #     inputId = "slider",
                    #     label = h4("Number of Top Songs"),
                    #     min = 0,
                    #     max = 100,
                    #     value = 100,
                    #     step = 10
                    #   )
                    # )
                  ),
                  
                  mainPanel(tabsetPanel(
                    tabPanel("About SpotR",
                             h3(),
                             fluidRow(
                               column(
                                 6
                               #  includeHTML(rmarkdown::render("about.spotify.rmd"))
                                 ## Ruins the tabs
                               )
                             ),
                             value = 1),
                    
                    tabPanel("Your Music",
                             h2(textOutput("name")),
                             h3(),
                             
                             fluidRow(
                               column(
                                 6,
                                 plotlyOutput(outputId = "scatter")
                               )
                             ), 
                             fluidRow(
                               column(
                                 6,
                                 plotlyOutput(outputId = "explicit")
                                 ####----------
                                 ##
                                 ## THIS IS NOT SHOWING UP ANYMORE IDK WHY
                                 ##
                                 ## ----------
                               ),
                               column(
                                 6,
                                 plotOutput(outputId = "radar",height = 300, width = 400)
                               )
                             ),
                             value = 2),
                    
                    # tabPanel("Trending",
                    #          h2("What's Trending?"),
                    #          h3(),
                    #          
                    #          ## NEED DATA HERE
                    #          value = 3),
                    
                    id = "conditionedPanels"
                  ))
                ))
