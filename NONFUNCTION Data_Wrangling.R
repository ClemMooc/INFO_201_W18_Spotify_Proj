library('httr')
library('dplyr')
library('jsonlite')
library("plotly")

#setup
source("get.token.R")
my_headers<-add_headers(c(Authorization=paste('Bearer', spotify.token, sep=' ')))

# User id, to be made into a variable that depends on input.
user.id = "12170429496"

# playlists request, takes user ID
playlist.request <- GET(paste0("https://api.spotify.com/v1/users/",user.id,"/playlists?limit=50"), my_headers)

playlist.data <-  fromJSON(content(playlist.request, "text"))

playlists.info <- playlist.data$items %>%
  select(name, id)
playlists.owner <- playlist.data$items$owner %>%
  select(id)
# The final dataframe to be used to get info from. Includes the playlist name, id, and owner id.
playlists <- bind_cols(playlists.info, playlists.owner) %>%
  rename(owner = id1)

## ---- Creates a list of all songs a person listens to in all their playlists. Also a list of albums ----

# The number of tracks in each playlist
number_of_tracks <- playlist.data$items$tracks$total

# Create empty data frame for the songs and dates
all_songs <- data_frame()

# Create empty vector for artists
all_artists <- c()

# Create empty vector for genres
all_genres <- c()

# Creat empty data frame for the genres
all_artists_genres <- data_frame()

## For each playlist...
for (a in 1:length(rownames(playlists))) {
  
  # The number of times that the endpoint must be accessed to get all of the tracks
  number_of_calls <- ceiling(number_of_tracks[a] / 100)
  
  # The playlist author's id
  id <- ifelse(playlists$owner[a] == user.id, user.id, playlists$owner[a])
  
  # Access the endpoint as many times as necessary to get all the songs from the API
  for (i in 0:(number_of_calls-1)) {
    # Access endpoint
    playlist.request_i = GET(
      paste0("https://api.spotify.com/v1/users/", id, "/playlists/", playlists$id[a], "/tracks?offset=", i*100),
      my_headers
    )
    
    # Access data from the JSON content recieved from the endpoint
    playlist_i = fromJSON(content(playlist.request_i, "text"))
    
    # Add all artists ids into the all_artists vector
    for (n in 1:length(playlist_i$items$track$artists)){
      all_artists <- union(all_artists, playlist_i$items$track$artists[[n]]$id)
    }
    
    ## Add genres into the all_genres vector
    #for (c in 1:length(all_artists)) {
      get.artist_url <- GET(paste0("https://api.spotify.com/v1/artists/",all_artists[5]), my_headers)
      artists <- fromJSON(content(get.artist_url,"text"))
      genres <- paste0(unlist(artists$genres), collapse = ",")
      all_genres <- union(all_genres, genres)
      artists$followers
    #}
    
    # Add song ids and dates added in playlist to vectors
    songs_from_playlist <- playlist_i$items$track$id
    date_songs_added <- playlist_i$items$added_at
    
    # Put vectors in a dataframe
    songs <- data.frame(songs_from_playlist, date_songs_added)
    
    # Put vectors in a dataframe
    artists_genres <- data.frame(all_artists, all_genres)
    
    # Gets rid of coersion warnings
    songs$songs_from_playlist <- as.character(songs$songs_from_playlist)
    songs$date_songs_added <- as.character(songs$date_songs_added)
    
    # Gets rid of coersion warnings
    artists_genres$all_artists <- as.character(artists_genres$all_artists)
    artists_genres$all_genres <- as.character(artists_genres$all_genres)
    
    # Add this playlist's songs and dates to the main dataframe
    all_songs <- bind_rows(all_songs, songs)
    
    # Add this artists and genres to the main datafram
    all_artists_genres <- bind_rows(all_artists_genres, artists_genres)
  }
}

## ----------------- Getting the tracks information ------------------
# Since the tracks endpoint can only accept 50 songs at a time, 
# we must have a list of dataframes containing only 50 songs.

# Create an empty list of data frames
dfs_50_songs <- list()

# The number of dataframes to create
number_of_chunks <- ceiling(length(rownames(all_songs))/50)


# Splits the dataframe of song ids into 50 song dataframes and puts into list
for(i in 1:number_of_chunks){
  start <- ((50*i) - 49)
  stop <- (50*i)
  dfs_50_songs[[i]] <- slice(all_songs, start:stop)
}

# Gets track information 50 songs at a time
for(i in 1:number_of_chunks){
  tracks <- GET(paste0("https://api.spotify.com/v1/tracks?ids=", gsub(" ", "", toString(dfs_50_songs[[i]]$songs_from_playlist))), my_headers)
  tracks.data <- fromJSON(content(tracks, "text"))
  features <- GET(paste0("https://api.spotify.com/v1/audio-features?ids=", gsub(" ", "", toString(dfs_50_songs[[i]]$songs_from_playlist))), my_headers)
  features.data <- fromJSON(content(features, "text"))
  
  dfs_50_songs[[i]][3] <- tracks.data$tracks$album$release_date
  dfs_50_songs[[i]][4] <- tracks.data$tracks$explicit
  dfs_50_songs[[i]][5] <- tracks.data$tracks$popularity
  dfs_50_songs[[i]][6] <- tracks.data$tracks$name
  dfs_50_songs[[i]][7] <- features.data$audio_features$danceability
  dfs_50_songs[[i]][8] <- features.data$audio_features$energy
  dfs_50_songs[[i]][9] <- features.data$audio_features$valence
  dfs_50_songs[[i]][10] <- features.data$audio_features$tempo
  dfs_50_songs[[i]][11] <- features.data$audio_features$loudness
  
  
  dfs_50_songs[[i]] <- rename(dfs_50_songs[[i]], release.date = V3, explicit = V4, popularity = V5, name = V6, danceability = V7, energy = V8, valence = V9, tempo = V10, loudness = V11)
}

# Combines all data frames back together to create one big dataframe
song_info <- data_frame()
for (i in 1:number_of_chunks) {
  song_info <- bind_rows(song_info, dfs_50_songs[[i]])
}

song_info <-
  mutate(song_info,
         added_date = gsub("\\T.*", "", song_info$date_songs_added))


song_info$year.na <- decimal_date(as.Date(song_info$release.date))

song_info$year <- song_info$year.na
my.na <- is.na(song_info$year.na)
song_info$year[my.na] <- song_info$release.date[my.na]

fast <- max(song_info$tempo)
song_info$tempo <- song_info$tempo/fast*100
song_info$loudness <- song_info$loudness+100

song_info <- select(song_info,
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
)

View(song_info)


  explicit.yes = (sum(song_info$explicit == "TRUE"))
  explicit.no = (sum(song_info$explicit == "FALSE"))

  explicit.df = data.frame("Explicit" = explicit.yes, "Clean" = explicit.no)
  explicit.values = c(explicit.yes, explicit.no)
  explicit.label = c(colnames(explicit.df)[1], colnames(explicit.df)[2])

  x <- plot_ly(data = explicit.df, labels = ~explicit.label, values = ~explicit.values, type = 'pie',
          textposition = 'inside',
          textinfo = 'label+percent',
          insidetextfont = list(color = "white"),
          marker = list(colors = c('#1DB954', 'black'), line = list(color = '#1DB954', width = 1))
  ) %>%
    layout(title = paste0('Ratio of Explicit and Non-Explicit tracks in Playlist'),
           yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
           xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
