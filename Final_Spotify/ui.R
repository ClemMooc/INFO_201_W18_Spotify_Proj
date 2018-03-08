library("shiny")
library("shinythemes")
library("plotly")

## Variables
year <- as.numeric(format(Sys.Date(), "%Y"))

## User Interface
ui <- fluidPage(theme = shinytheme("superhero"),
                fluidRow(column(1,h1("SpotR"))),
                fluidRow(h1()),
                ## ---------- Main Page Layout -----------
                pageWithSidebar(
                  headerPanel(""),
                  ## --------- Sidebar Panel ----------
                  sidebarPanel(
                    width = 3,
                    ## -------- Panel for Tab 1; About SpotR ---------
                    conditionalPanel(
                      h3("SpotR:"),
                      h4("A Spotify Infographics Application"),
                      condition = "input.conditionedPanels == 1"
                    ),
                    ## -------- Panel for Tab 2; Your Music ---------
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
                        max = year-2006,
                        value = (year-2006),
                        sep = ""
                      )
                    )
                  ),
                  
                  ## -------- Main Panel Where Data is Displayed ---------
                  mainPanel(tabsetPanel(
                    ## ---------- Tab 1: About SpotR -----------
                    tabPanel("About SpotR",
                             h3(),
                             ## -------- Description of SpotR --------
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
                    
                    ## ---------- Tab 2: Your Music -----------
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
                               ),
                               column(
                                 6,
                                 plotOutput(outputId = "radar", width = 450)
                               )
                             ),
                             value = 2),
                    
                    id = "conditionedPanels"
                    ## ---------------------------------------
                    
                  ))
                ))
