library('dplyr')
library('plotly')
library('httr')
library('openssl')

server <- function(input, output) {
  df <- data.frame(
    group = c("Male", "Female", "Child"),
    value = c(25, 25, 50)
  )
  observeEvent(input$action, {
 
    user_id <- input$text
    user_id <- 1262636354
    source('Final_Spotify/data/keys.R')
    source('Data_Wrangling.R')
    spotify.token = "BQA0TAszmTxaa0itX8cH67cBONW_XPj7t8gCA1sdab5NQmBaJelhPN2ZiuQEYT2d4xc4U97WdF8N7BcSp6g"
    my_headers<-add_headers(c(Authorization=paste('Bearer',spotify.token,sep=' ')))
    
    ##gets playlist ids based on user
    playlists_url <- paste0("https://api.spotify.com/v1/users/",userid,"/playlists")
    x <- GET(playlists_url, my_headers)
    playlists <- fromJSON(content(x,"text"))
    playlist_id <- gsub(".*:","",playlists$items$uri)
    
    ##gets tracks based on user's selected playlist
    ## getting Error: length(url) == 1 is not TRUE
    i = 1
    track_list <- list()
    for (val in playlist_id) {
      tracks_url <- paste0("https://api.spotify.com/v1/users/",user_id,"/playlists/",playlist_id,"/tracks")
      get.track <- GET(tracks_url, my_headers)
      tracks <- fromJSON(content(get.track, "text"))
      track_id <- as.data.frame(tracks$items$track$id)
      track_list[i] <- 
      i = i + 1
    }                       
    
    tracks_url <- paste0("https://api.spotify.com/v1/users/",userid,"/playlists/",playlist_id,"/tracks")
    get.track <- GET(tracks_url, my_headers)
    tracks <- fromJSON(content(get.track, "text"))
    track_data <- as.data.frame(tracks$items$track)
    get.album.id <- gsub(".*:","",track_data$album$id[1])
    
    album_url <- paste0("https://api.spotify.com/v1/albums/", get.album.id)
    get.albums <- GET(album_url, my_headers)
    albums <- fromJSON(content(get.albums,"text"))
    get.artist.id <- gsub(".*:","",albums$artists$id[1])
    
    artist_url <- paste0("https://api.spotify.com/v1/artists/",get.artist.id)
    get.artist <- GET(artist_url, my_headers)
    artists <- fromJSON(content(get.artist, "text"))
    genres <- as.data.frame(artists$genres)
    
    #get global top 50 
    global50 <- GET("https://api.spotify.com/v1/users/spotifycharts/playlists/37i9dQZEVXbMDoHDwVN2tF", my_headers)
    global50.data <- fromJSON(content(global50,"text"))
    global50.name = as.data.frame(global50.data$tracks$items$track$name)
    
    #get usa top 50 
    usa50 <- GET("https://api.spotify.com/v1/users/spotifycharts/playlists/37i9dQZEVXbLRQDuF5jeBp", my_headers)
    usa50.data <- fromJSON(content(usa50,"text"))
    usa50.name = as.data.frame(usa50.data$tracks$items$track$name)
    
  })
  ##renders basic scatterplot based on track popularity and release date
  track_release_dates <- as.data.frame(track_data$album$release_date)
  track_date_pop <- data.frame(date = track_data$album$release_date, popularity = track_data$popularity)
  
  output$scatter <- renderPlotly({
    plot_ly(data = track_date_pop, x = ~date, y = ~popularity, type = 'scatter',
            marker = list(size = 10,
                          color = 'rgba(255, 182, 193, .9)',
                          line = list(color = 'rgba(152, 0, 0, .8)',
                                      width = 2))) %>%
      layout(title = 'How Obscure Is Your Music?',
             yaxis = list(zeroline = FALSE, title = "<-- Unpopular                           Popular-->"),
             xaxis = list(zeroline = FALSE, title = "<-- Old                                 New-->"))
  )
  })
  #render pie chart of explicit and non-explicit songs in playlist
  output$pie <- renderPlotly({
    
    explicit = song_info$explicit
    explicit.yes = (sum(explicit == "TRUE"))
    explicit.no = (sum(explicit == "FALSE"))
    
    explicit.df = data.frame("Explicit" = explicit.yes, "Clean" = explicit.no)
    explicit.values = c(explicit.yes, explicit.no)
    explicit.label = c(colnames(explicit.df)[1], colnames(explicit.df)[2])
    
    plot_ly(data = explicit.df, labels = ~explicit.label, values = ~explicit.values, type = 'pie',
                      textposition = 'inside',
                      textinfo = 'label+percent',
                      insidetextfont = list(color = "white"),
                      marker = list(colors = c('#1DB954', 'black'), line = list(color = '#1DB954', width = 1)) 
    ) %>%
      layout(title = paste0('Ratio of Explicit and Non-Explicit tracks in Playlist'),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  })
  
}

