library('dplyr')
library('plotly')
library('httr')
library('fmsb')
library('lubridate')


## Source files
source("data/get.token.R")
source("data/Data_Wrangling.R")
## Global Variables
user.id <- ""
token <- spotify.token
song_info <- data.frame()
isData <- FALSE
hasPlaylist <- FALSE
current.year <- as.numeric(format(Sys.Date(), "%Y"))



my_headers <-
  add_headers(c(Authorization = paste('Bearer', token, sep = ' ')))


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
    
    

    ##------ Create Pie chart of explicit and safe tracks

    output$explicit <- renderPlotly({
      if (isData & hasPlaylist) {
        ex.date.df <- song_info %>%
          filter(current.year - input$slider <= song_info$added_date)
        explicit.yes = (sum(ex.date.df$explicit == "TRUE"))
        explicit.no = (sum(ex.date.df$explicit == "FALSE"))
        
        explicit.df = data.frame("Explicit" = explicit.yes, "Clean" = explicit.no)
        explicit.values = c(explicit.yes, explicit.no)
        explicit.label = c(colnames(explicit.df)[1], colnames(explicit.df)[2])
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
            title = paste0('Explicit and Clean Tracks in Playlists'),
            titlefont = list(size = 15, color = "white"),
            plot_bgcolor = '#2c3e4f',
            paper_bgcolor = '#2c3e4f',
            yaxis = list(
              showgrid = FALSE,
              zeroline = FALSE,
              showticklabels = FALSE
            ),
            xaxis = list(
              showgrid = FALSE,
              zeroline = FALSE,
              showticklabels = FALSE
            ),
            displayModeBar = FALSE
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

    ##-------- Create scatterplot with release data as x axis and popularity as y axis

    output$scatter <- renderPlotly({
      if (isData & hasPlaylist) {
        pop.date.df <- song_info %>%
          filter(current.year - input$slider <= song_info$added_date)
        
        track_date_pop <-
          data.frame(
            date = pop.date.df$year,
            popularity = pop.date.df$popularity,
            name = pop.date.df$name,
            release.date = pop.date.df$release.date
          )
        
        start <-
          floor(min(track_date_pop$year))
        
        
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
          text = ~ paste(
            name,
            '\n Release Date: ',
            release.date,
            '\n Popularity: ',
            popularity
          )
        ) %>%
          layout(
            title = 'How Obscure Is Your Music?',
            yaxis = list(zeroline = FALSE,
                         title = "Popularity from 0 to 100"),
            xaxis = list(
              autotick = FALSE,
              ticks = "outside",
              tick0 = start,
              dtick = 2,
              tickcolor = "white",
              title = "Release Date"
            ),
            titlefont = list(size = 15, color = "white"),
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
      } else if (isData) {
        plotly_empty() %>%
          layout(
            title = "This user has no playlists",
            width = 300,
            titlefont = list(size = 16, color = "white"),
            plot_bgcolor = '#2c3e4f',
            paper_bgcolor = '#2c3e4f',
            margin = list(t = 35)
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
    
   #-----radar chart including daneability, energy, valence, loudness, and tempo
     output$radar <- renderPlot({
      
      if (isData & hasPlaylist) {
        rad.date.df <- song_info %>%
          filter(current.year - input$slider <= song_info$added_date)
        
        d <- median(rad.date.df$danceability) * 100
        e <- median(rad.date.df$energy) * 100
        v <- median(rad.date.df$valence) * 100
        l <- median(rad.date.df$loudness)
        t <- median(rad.date.df$tempo)
        
        radarplot <- data.frame(d, e, v, l, t)
        
        colnames(radarplot) = c("Danceability" ,
                                "Enegy" ,
                                "Valence",
                                "Loudness",
                                "Tempo")
        
        radarplot = rbind(rep(100, 50), rep(0, 50) , df)
        
        par(bg = "#2c3e4f")
        par(col.lab = "white")
        radarchart(
          radarplot,
          axistype = 1 ,
          
          pcol = rgb(0.2, 0.5, 0.5, 0.9),
          pfcol = rgb(0.2, 0.5, 0.5, 0.5),
          plwd = 4,
          #custom the grid
          cglcol = "white",
          cglty = 2,
          cglwd = 0.8,
          axislabcol = "white",
          caxislabels = seq(0, 100, 25),
          #custom labels
          vlcex = 1
        )
        
        title(main = "Danceability VS Energy VS Valence VS Loudness VS Tempo", col.main =
                "white")
        
        
      } else {
        par(bg = "#2c3e4f")
        frame()
      }
    })
  })
}