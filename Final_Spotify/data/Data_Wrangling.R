library('httr')
library('dplyr')
library('jsonlite')
library("plotly")

get.data.frame <- function(user.id, token) {
  
  # Sets up API authorization 
  my_headers <- add_headers(c(Authorization = paste('Bearer', token, sep = ' ')))
  
  ## ------------ Gets all public playlists a user has made or follows ------------
  playlist.request <-GET(paste0("https://api.spotify.com/v1/users/", user.id, "/playlists?limit=50"), my_headers)
  playlist.data <-  fromJSON(content(playlist.request, "text"))
  if(length(playlist.data$items) == 0){
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
      playlist.request_i = GET(paste0("https://api.spotify.com/v1/users/",id,"/playlists/",playlists$id[a],"/tracks?offset=", i * 100), my_headers)
      
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
    dfs_50_songs[[i]][7] <- features.data$audio_features$danceability
    dfs_50_songs[[i]][8] <- features.data$audio_features$energy
    dfs_50_songs[[i]][9] <- features.data$audio_features$valence
    dfs_50_songs[[i]][10] <- features.data$audio_features$tempo
    dfs_50_songs[[i]][11] <-
      features.data$audio_features$instrumentalness
    
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
        instrumentalness = V11
      )
  }
  ## ------------ Recombining Data Frames and improving readability ------------
  
  song_info <- data_frame()
  for (i in 1:number_of_chunks) {
    song_info <- bind_rows(song_info, dfs_50_songs[[i]])
  }
  
  
  # Combines all data frames back together to create one big dataframe
  song_info <- data_frame()
  for (i in 1:number_of_chunks) {
    song_info <- bind_rows(song_info, dfs_50_songs[[i]])
  }
  
  song_info <-
    mutate(song_info,
           added_date = gsub("\\T.*", "", song_info$date_songs_added)) %>%
    select(
      name,
      added_date,
      release.date,
      explicit,
      popularity,
      danceability,
      energy,
      valence,
      tempo,
      instrumentalness
    )
  
  #View(song_info)
  # song_info is the final dataframe.
}
#
# explicit.yes = (sum(song_info$explicit == "TRUE"))
# explicit.no = (sum(song_info$explicit == "FALSE"))
#
# explicit.df = data.frame("Explicit" = explicit.yes, "Clean" = explicit.no)
# explicit.values = c(explicit.yes, explicit.no)
# explicit.label = c(colnames(explicit.df)[1], colnames(explicit.df)[2])
#
# x <- plot_ly(data = explicit.df, labels = ~explicit.label, values = ~explicit.values, type = 'pie',
#         textposition = 'inside',
#         textinfo = 'label+percent',
#         insidetextfont = list(color = "white"),
#         marker = list(colors = c('#1DB954', 'black'), line = list(color = '#1DB954', width = 1))
# ) %>%
#   layout(title = paste0('Ratio of Explicit and Non-Explicit tracks in Playlist'),
#          yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
#          xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
# 