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
                                 
                                 h2("How to get user URI"),
                                  h3("On the spotify desktop application:"),
                                    h3("1. Go to User page, which can be found my searching for a specific user or through the signed-in account."),
                                     h3("2. Select the ellipses, click share, and copy spotify URI"),
                                     h3("3. Your user ID is everything after the second colon."),
                                     h3("On iOS mobile application:"),
                                     h3("1. Select settings"),
                                     h3("2. Select account"),

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
                                 plotOutput(outputId = "radar",height = 300, width = 600)
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
