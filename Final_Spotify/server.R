library('dplyr')
library('plotly')
library('httr')

source('data/global.R')

my_headers <-
  add_headers(c(Authorization = paste('Bearer', token, sep = ' ')))
song_info <- data.frame()

server <- function(input, output) {
  
  ## ------ Provides data for user when user id entered ------
  observeEvent(input$action, {
    
    if (input$text == "") {
      output$name <- renderText({
        "Please Enter A Valid User ID"
      })
      isData <- FALSE
    } else {
      user <-
        GET(paste0("https://api.spotify.com/v1/users/", input$text),
            my_headers)
      user.data  <- fromJSON(content(user, "text"))
      if (!is.null(user.data$error$message)) {
        output$name <- renderText({
          user.data$error$message
        })
        isData <- FALSE
      } else {
        output$name <- renderText({
          user.data$display_name
        })
        user.id <- input$text
        song_info <- get.data.frame(user.id, token)
        if (nrow(song_info) > 0) {
          hasPlaylist <- TRUE
        }
        isData <- TRUE
      }
    }
    
    
    ## ----- Explicit Pie Chart ----
    explicit.yes = (sum(song_info$explicit == "TRUE"))
    explicit.no = (sum(song_info$explicit == "FALSE"))
    
    explicit.df = data.frame("Explicit" = explicit.yes, "Clean" = explicit.no)
    explicit.values = c(explicit.yes, explicit.no)
    explicit.label = c(colnames(explicit.df)[1], colnames(explicit.df)[2])
    
    output$explicit <- renderPlotly({
      if (isData & hasPlaylist) {
        plot_ly(
          data = explicit.df,
          labels = ~ explicit.label,
          values = ~ explicit.values,
          type = 'pie',
          height = 300,
          width = 300,
          textposition = 'inside',
          textinfo = 'label+percent',
          insidetextfont = list(color = "white"),
          marker = list(
            colors = c('#1DB954', 'black'),
            line = list(color = '#1DB954', width = 1)
          )
        ) %>%
          layout(
            title = paste0('Explicit vs Clean tracks in Playlists'),
            titlefont = list(size = 15, color = "white"),
            plot_bgcolor = '#222222',
            paper_bgcolor = '#222222',
            yaxis = list(
              showgrid = FALSE,
              zeroline = FALSE,
              showticklabels = FALSE
            ),
            xaxis = list(
              showgrid = FALSE,
              zeroline = FALSE,
              showticklabels = FALSE
            )
          ) %>%
          config(displayModeBar = FALSE)
        
      } else if (isData) {
        plotly_empty() %>%
          layout(
            title = "This user has no playlists",
            width = 200,
            titlefont = list(size = 15, color = "white"),
            plot_bgcolor = '#222222',
            paper_bgcolor = '#222222'
          ) %>%
          config(displayModeBar = FALSE)
        
      } else {
        plotly_empty() %>%
          layout(
            width = 10,
            plot_bgcolor = '#222222',
            paper_bgcolor = '#222222'
          ) %>%
          config(displayModeBar = FALSE)
      }
    })
    
    ##-------
  })
  ## ----------- Other info ----------
  
  
  
}