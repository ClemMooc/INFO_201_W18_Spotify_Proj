library("shiny")
library("shinythemes")
library("plotly")
library('knitr')
library('markdown')
#source('data/global.R')
## Variables
year <- as.numeric(format(Sys.Date(), "%Y"))

ui <- fluidPage(theme = shinytheme("superhero"),
                fluidRow(column(1,h1("SpotR"))),
                fluidRow(h1()),

                pageWithSidebar(
                  headerPanel(""),
                  sidebarPanel(
                    width = 3,
                    conditionalPanel(
                      h3("SpotR:"),
                      h4("A Spotify Infographics Application"),
                      condition = "input.conditionedPanels == 1"
                    ),
                    
                    conditionalPanel(
                      condition = "input.conditionedPanels == 2",
                      textInput(
                        inputId = "text",
                        label = h3("Specify Spotify User"),
                        placeholder = "Enter username..."
                      ),
                      actionButton("action", label = "Submit Username", style = "color: #4f5d6b; background-color: #1DB954"),
                      
                      tags$style(HTML(".js-irs-0 .irs-single, .js-irs-0 .irs-bar-edge, .js-irs-0 .irs-bar {background: #1DB954}")),
                      sliderInput(
                        inputId = "slider",
                        label = h3("Display data from the past how many years?"),
                        min = 1,
                        max = year-2010,
                        value = (year-2010),
                        sep = ""
                      )
                    )
                  ),
                  
                  mainPanel(tabsetPanel(
                    tabPanel("About SpotR",
                             h3(),
                             fluidRow(
                                 h2("SpotR"),
                                  h3("SpotR is an interactive web app that creates visual graphics out of your playlist data. We directly source track and playlist data from the Spotify Web Api. With SpotR, users can enter a specific Spotify User id, and bring up visuals regarding their playlist information. With this app, we give Spotify users the power to visualize their music playlist consumption."),
                                  h3("Through the Spotify Web Api, we are able to source:"),

                                     h3("- Artists"),
                                     h3("- Playlists"),
                                     h3("- Tracks"),
                                     h3("- Release Date"),
                                     h3("- Explicit/Non-Explicit"),
                                  
                                  h2("How it Works"),
                                     h3("We utilized the HTTR, JSONLITE, and DPLYR packages to access, retrieve, and wrangle the Spotify data. By compiling data frames with song and playlist info, we then utilized packages PLOTLY and FMSB to generate standard data charts (scatterplots and pie charts), and more sophisticated charts that required more than 2 lists of data (radar charts). Finally, with the SHINY package, we compiled everything up to make our data interactive with users."),

                                  h2("The Team"),
                                     h3("- Kris Wong"),


                                     h3("- Clem Mooc"),


                                     h3("- Thomas Penner"),


                                     h3("- Gyubeom (Jason) Kim")
                               
                             ),
                             value = 1),
                    
                    tabPanel("Your Music",
                             h2(textOutput("name")),
                             h3(),
                             
                             fluidRow(
                               column(
                                 6,
                                 plotlyOutput(outputId = "scatter", width = 300)
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
                                 plotOutput(outputId = "radar",height = 350, width = 600)
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
