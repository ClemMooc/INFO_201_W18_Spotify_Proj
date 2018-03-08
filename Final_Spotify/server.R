library('dplyr')
library('plotly')
library('httr')
library('jsonlite')
library('lubridate')
library('fmsb')

## Source files
source("data/get.token.R")

## Global Variables
user.id <- ""
token <- spotify.token
song_info <- data.frame()
isData <- FALSE
hasPlaylist <- FALSE
current.year <- as.numeric(format(Sys.Date(), "%Y"))

## ---------- Get Data Frame ------------
get.data.frame <- function(user.id, token) {
  # Sets up API authorization
  my_headers <-
    add_headers(c(Authorization = paste('Bearer', token, sep = ' ')))
  
  ## ------------ Gets all public playlists a user has made or follows ------------
  playlist.request <-
    GET(
      paste0(
        "https://api.spotify.com/v1/users/",
        user.id,
        "/playlists?limit=50"
      ),
      my_headers
    )
  playlist.data <-  fromJSON(content(playlist.request, "text"))
  if (length(playlist.data$items) == 0) {
    return(data.frame())
  }
  playlists.info <- playlist.data$items %>%
    select(name, id)
  playlists.owner <- playlist.data$items$owner %>%
    select(id)
  # The final dataframe to be used to get info from. Includes the playlist name, id, and owner id.
  playlists <- bind_cols(playlists.info, playlists.owner) %>%
    rename(owner = id1)
  
  ## ------------ Creates a list of all song ids of a person's playlists ------------
  
  # The number of tracks in each playlist
  number_of_tracks <- playlist.data$items$tracks$total
  
  # Create empty data frame for the songs and dates
  all_songs <- data_frame()
  
  ## For each playlist...
  for (a in 1:length(rownames(playlists))) {
    # The number of times that the endpoint must be accessed to get all of the tracks
    number_of_calls <- ceiling(number_of_tracks[a] / 100)
    
    # The playlist author's id
    id <-
      ifelse(playlists$owner[a] == user.id, user.id, playlists$owner[a])
    
    # Access the endpoint as many times as necessary to get all the songs from the API
    for (i in 0:(number_of_calls - 1)) {
      # Access endpoint
      playlist.request_i = GET(
        paste0(
          "https://api.spotify.com/v1/users/",
          id,
          "/playlists/",
          playlists$id[a],
          "/tracks?offset=",
          i * 100
        ),
        my_headers
      )
      
      # Access data from the JSON content recieved from the endpoint
      playlist_i = fromJSON(content(playlist.request_i, "text"))
      
      # Add song ids and dates added in playlist to vectors
      songs_from_playlist <- playlist_i$items$track$id
      date_songs_added <- playlist_i$items$added_at
      
      # Put vectors in a dataframe
      songs <- data.frame(songs_from_playlist, date_songs_added)
      
      # Gets rid of coersion warnings
      songs$songs_from_playlist <-
        as.character(songs$songs_from_playlist)
      songs$date_songs_added <- as.character(songs$date_songs_added)
      
      # Add this playlist's songs and dates to the main dataframe
      all_songs <- bind_rows(all_songs, songs)
    }
  }
  
  ## ------------ Getting the tracks information ------------
  # Since the tracks endpoint can only accept 50 songs at a time,
  # we must have a list of dataframes containing only 50 songs.
  
  # Create an empty list of data frames
  dfs_50_songs <- list()
  
  # The number of dataframes to create
  number_of_chunks <- ceiling(length(rownames(all_songs)) / 50)
  
  
  # Splits the dataframe of song ids into 50 song dataframes and puts into list
  for (i in 1:number_of_chunks) {
    start <- ((50 * i) - 49)
    stop <- (50 * i)
    dfs_50_songs[[i]] <- slice(all_songs, start:stop)
  }
  
  # Gets track information 50 songs at a time
  for (i in 1:number_of_chunks) {
    tracks <-
      GET(paste0(
        "https://api.spotify.com/v1/tracks?ids=",
        gsub(" ", "", toString(dfs_50_songs[[i]]$songs_from_playlist))
      ),
      my_headers)
    tracks.data <- fromJSON(content(tracks, "text"))
    features <-
      GET(paste0(
        "https://api.spotify.com/v1/audio-features?ids=",
        gsub(" ", "", toString(dfs_50_songs[[i]]$songs_from_playlist))
      ),
      my_headers)
    features.data <- fromJSON(content(features, "text"))
    
    dfs_50_songs[[i]][3] <- tracks.data$tracks$album$release_date
    dfs_50_songs[[i]][4] <- tracks.data$tracks$explicit
    dfs_50_songs[[i]][5] <- tracks.data$tracks$popularity
    dfs_50_songs[[i]][6] <- tracks.data$tracks$name
    dfs_50_songs[[i]][7] <-
      features.data$audio_features$danceability
    dfs_50_songs[[i]][8] <- features.data$audio_features$energy
    dfs_50_songs[[i]][9] <- features.data$audio_features$valence
    dfs_50_songs[[i]][10] <- features.data$audio_features$tempo
    dfs_50_songs[[i]][11] <- features.data$audio_features$loudness
    
    dfs_50_songs[[i]] <-
      rename(
        dfs_50_songs[[i]],
        release.date = V3,
        explicit = V4,
        popularity = V5,
        name = V6,
        danceability = V7,
        energy = V8,
        valence = V9,
        tempo = V10,
        loudness = V11
      )
  }
  ## ------------ Recombining Data Frames and improving readability ------------
  
  song_info <- data_frame()
  for (i in 1:number_of_chunks) {
    song_info <- bind_rows(song_info, dfs_50_songs[[i]])
  }
  
  song_info <-
    mutate(song_info,
           added_date = gsub("\\T.*", "", song_info$date_songs_added))
  
  song_info$added_date <-
    decimal_date(lubridate::ymd(song_info$added_date))
  
  song_info$year <-
    decimal_date(lubridate::ymd(song_info$release.date))
  
  my.na <- is.na(song_info$year.na)
  song_info$year[my.na] <- song_info$release.date[my.na]
  song_info$year <- as.numeric(song_info$year)
  
  fast <- max(song_info$tempo)
  song_info$tempo <- song_info$tempo / fast * 100
  song_info$loudness <- song_info$loudness + 80
  
  song_info <- select(
    song_info,
    name,
    added_date,
    year,
    release.date,
    explicit,
    popularity,
    danceability,
    energy,
    valence,
    tempo,
    loudness
  ) %>%
    filter(!is.na(name))
  
  return(song_info)
  
}
## -----------------

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
    
    ##------ Create Pie chart of explicit and safe tracks
    
    output$explicit <- renderPlotly({
      if (hasPlaylist) {
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
    
    #-----radar chart including daneability, energy, valence, loudness, and tempo
    d <- mean(song_info$danceability) * 100
    e <- mean(song_info$energy) * 100
    v <- mean(song_info$valence) * 100
    l <- mean(song_info$loudness)
    t <- mean(song_info$tempo)
    
    df <- data.frame(d, e, v, l, t)
    
    colnames(df) = c("Danceability" , "Enegy" , "Valence", "Loudness", "Tempo")
    
    df = rbind(rep(100, 50), rep(0, 50) , df)
    output$radar <- renderPlot({
      if (isData & hasPlaylist) {
        par(bg = "#2c3e4f")
        par(col.lab = "white")
        radarchart(
          df,
          axistype = 1 ,
          
          pcol = rgb(0.2, 0.5, 0.5, 0.9),
          pfcol = rgb(0.2, 0.5, 0.5, 0.5),
          plwd = 4,
          
          #custom the grid
          cglcol = "white",
          cglty = 2,
          cglwd = 0.8,
          axislabcol = "white",
          #custom labels
          vlcex = 1
        )
        title(main = "What Type of Music Do You Like?", col.main =
                "white")
      } else {
        par(bg = "#2c3e4f")
        frame()
      }
    })
  })
}
