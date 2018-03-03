library('httr')
library('dplyr')
library('jsonlite')
library('httpuv')

source('Final_Spotify/data/keys.R')
my_headers<-add_headers(c(Authorization=paste('Bearer',spotify.token,sep=' ')))

x <- GET("https://api.spotify.com/v1/users/12170429496/playlists", my_headers)
abc <- fromJSON(content(x,"text"))

tracks <- GET("https://api.spotify.com/v1/albums/2wart5Qjnvx1fd7LPdQxgJ", my_headers)
aaa <- fromJSON(content(tracks,"text"))

tracks2 <- GET("https://api.spotify.com/v1/tracks/2daZovie6pc2ZK7StayD1K", my_headers)
bbb <- fromJSON(content(tracks2,"text"))

artist <- GET("https://api.spotify.com/v1/artists/12Chz98pHFMPJEknJQMWvI", my_headers)
c <- fromJSON(content(artist,"text"))
