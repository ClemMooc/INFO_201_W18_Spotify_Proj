library('httr')
library('dplyr')
library('jsonlite')
library("plotly")

#setup
source('Final_Spotify/data/keys.R')
my_headers<-add_headers(c(Authorization=paste('Bearer', spotify.token, sep=' ')))

# User id, to be made into a variable that depends on input.
user.id = "12158467793"#"12170429496"

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
    
    # Add song ids and dates added in playlist to vectors
    songs_from_playlist <- playlist_i$items$track$id
    date_songs_added <- playlist_i$items$added_at
    
    # Put vectors in a dataframe
    songs <- data.frame(songs_from_playlist, date_songs_added)
    
    # Gets rid of coersion warnings
    songs$songs_from_playlist <- as.character(songs$songs_from_playlist)
    songs$date_songs_added <- as.character(songs$date_songs_added)
    
    # Add this playlist's songs and dates to the main dataframe
    all_songs <- bind_rows(all_songs, songs)
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
  trackslist <- fromJSON(content(tracks, "text"))
  dfs_50_songs[[i]][3] <- trackslist$tracks$album$release_date
  dfs_50_songs[[i]][4] <- trackslist$tracks$explicit
  dfs_50_songs[[i]][5] <- trackslist$tracks$popularity
  dfs_50_songs[[i]][6] <- trackslist$tracks$name
  dfs_50_songs[[i]] <- rename(dfs_50_songs[[i]], release.date = V3, explicit = V4, popularity = V5, name = V6)
}

# Combines all data frames back together to create one big dataframe
song_info <- data_frame()
for(i in 1:number_of_chunks){
  song_info <- bind_rows(song_info, dfs_50_songs[[i]])
}

# song_info is the final dataframe.