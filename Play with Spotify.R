library('httr')
library('dplyr')
library('jsonlite')
library('httpuv')

source('Final_Spotify/data/keys.R')
my_headers<-add_headers(c(Authorization=paste('Bearer',spotify.token,sep=' ')))
userid <- 12170429496
  
playlists_url <- paste0("https://api.spotify.com/v1/users/",userid,"/playlists")
x <- GET(playlists_url, my_headers)
playlists <- fromJSON(content(x,"text"))
playlist_id <- gsub(".*:","",playlists$items$uri[1])

tracks_url <- paste0("https://api.spotify.com/v1/users/",userid,"/playlists/",playlist_id,"/tracks")
get.track <- GET(tracks_url, my_headers)
tracks <- fromJSON(content(get.track, "text"))
track_data <- as.data.frame(tracks$items$track)
get.album.id <- gsub(".*:","",track_data$album$id[1])

album_url <- paste0("https://api.spotify.com/v1/albums/", get.album.id)
get.alums <- GET(album_url, my_headers)
albums <- fromJSON(content(get.alums,"text"))
get.artist.id <- gsub(".*:","",albums$artists$id[1])

artist_url <- paste0("https://api.spotify.com/v1/artists/",get.artist.id)
get.artist <- GET(artist_url, my_headers)
artists <- fromJSON(content(get.artist, "text"))
genres <- as.data.frame(artists$genres)
print(genres)
