library('dplyr')
library('plotly')
library('httr')
library('fmsb')
library('lubridate')
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
        View(song_info)
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
        plot_ly(data = explicit.df, labels = ~explicit.label, values = ~explicit.values, type = 'pie', height = 300, width = 300,
                     textposition = 'inside',
                     textinfo = 'label+percent',
                     insidetextfont = list(color = "white"),
                     marker = list(colors = c('#1DB954', 'black'), line = list(color = '#1DB954', width = 1))
        ) %>%
          layout(title = paste0('Explicit and Clean Tracks in Playlists'),
                 titlefont = list(size = 15, color = "white"),
                 plot_bgcolor = '#2c3e4f',
                 paper_bgcolor = '#2c3e4f',
                 yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                 xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        
      } else if (isData) {
        plotly_empty() %>%
          layout(
            title = "This user has no playlists",
            width = 200,
            titlefont = list(size = 15, color = "white"),
            plot_bgcolor = '#2c3e4f',
            paper_bgcolor = '#2c3e4f'
          ) 
        
         
      } else {
        plotly_empty() %>%
          layout(
            width = 10,
            plot_bgcolor = '#2c3e4f',
            paper_bgcolor = '#2c3e4f'
          ) 
      }
    })
    ##-------- 
    
     track_date_pop <-
       data.frame(date = song_info$year,
                  popularity = song_info$popularity,
                  name = song_info$name,
                  release.date = song_info$release.date)
  
    start <- floor(min(track_date_pop$year)) - (floor(min(track_date_pop$year))%%5)

    output$scatter <- renderPlotly({
      if (isData & hasPlaylist) {
        plot_ly(
          data = track_date_pop,
          x = ~ date,
          y = ~ popularity,
          type = "scatter",
          marker = list(
            size = 10,
            color = '#1DB954',
            line = list(color = 'light grey', width = 1)
          ),
          hoverinfo = 'text',
          text = ~ paste(name,
                         '\n Release Date: ', release.date,
                         '\n Popularity: ', popularity)
        ) %>%
          layout(
            title = 'How Obscure Is Your Music?',
            yaxis = list(zeroline = FALSE,
                         title = "Popularity from 0 to 100"),
            xaxis = list(
              autotick = FALSE,
              ticks = "outside",
              tick0 = start,
              dtick = 10,
              tickcolor = "white",
              title = "Release Date"
            ),
            titlefont = list(size = 15, color = "#2c3e4f"),
            plot_bgcolor = '#2c3e4f',
            paper_bgcolor = '#2c3e4f',
            width = 800,
            height = 450,
            font = list(color = "white"),
            margin = list(
              l = 150,
              r = 20,
              b = 150,
              t = 50
            )
          )
        
      } else {
        plotly_empty() %>%
          layout(
            width = 10,
            plot_bgcolor = '#2c3e4f',
            paper_bgcolor = '#2c3e4f'
          ) 
      }
    })
    
    d <- mean(song_info$danceability) * 100
    e <- mean(song_info$energy) * 100
    v <- mean(song_info$valence) * 100
    l <- mean(song_info$loudness)
    t <- mean(song_info$tempo) 
   
    df <- data.frame(d,e,v,l,t)
    
    colnames(df) = c("Danceability" , "Enegy" , "Valence", "Loudness", "Tempo")
    
    df = rbind(rep(100,50), rep(0,50) , df)
    output$radar <- renderPlot({
      
      if (isData & hasPlaylist) {
        par(bg = "#2c3e4f")
        par(col.lab="white")
        radarchart(df, axistype=1 ,
                   
                   
                   
                   pcol=rgb(0.2,0.5,0.5,0.9), 
                   pfcol=rgb(0.2,0.5,0.5,0.5), 
                   plwd=4,
                   
                   #custom the grid
                   cglcol="white", 
                   cglty=2, 
                   cglwd=0.8,
                   axislabcol = "white",
                   #custom labels
                   vlcex=1
        ) 
        
        title(main="Danceability VS Energy VS Valence VS Loudness VS Tempo", col.main="white") 
        
        
      } else {
        par(bg = "#2c3e4f")
        frame()
      }
    })
    ##-------
  })
  ## ----------- Other info ----------
  
  
  
}