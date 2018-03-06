library('httr')
library('dplyr')
library('jsonlite')
library('httpuv')
library("ggplot2")
library("plotly")
library('rlist')

#setup
source('/Users/kristoferwong/Documents/INFO201Git/Final/Final_Spotify/data/keys.R')
my_headers<-add_headers(c(Authorization=paste('Bearer', spotify.token, sep=' ')))

#user and playlist ID
user.id = "12158467793"#'12170429496'

#playlist request, takes user ID and public playlist ID
playlist.request = GET(paste0("https://api.spotify.com/v1/users/",user.id,"/playlists?limit=50"), my_headers)

playlist.body = content(playlist.request, "text")
playlist.data = fromJSON(playlist.body)
playlists.owner <- playlist.data$items$owner %>%
  select(id)
playlists.info <- playlist.data$items %>%
  select(name, id)
playlists <- bind_cols(playlists.info, playlists.owner) %>%
  rename(owner = id1)

## ---- Creates a list of all songs a person listens to in all their playlists. Also a list of albums ----

all_songs <- c()
all_albums <- c()
 for(i in 1:length(rownames(playlists))){
    id <- ifelse(playlists$owner[i] == user.id, user.id, playlists$owner[i])
    playlist.request_i = GET(paste0("https://api.spotify.com/v1/users/", id, "/playlists/", playlists$id[i], "/tracks"), my_headers)
    playlist_i = fromJSON(content(playlist.request_i, "text"))
    songs_from_playlist <- playlist_i$items$track$id
    albums_from_playlist <- playlist_i$items$track$album$id
    all_albums <- union(all_albums, albums_from_playlist)
    all_songs <- union(all_songs, songs_from_playlist)
 }
print(all_songs)
print(all_albums)

#playlist.request2 = GET(paste0("https://api.spotify.com/v1/users/",user.id,"/playlists/", playlists$id, "/tracks"), my_headers)
#print(playlist.request2)
# playlist.body2 = content(playlist.request2, "text")
# playlist.data2 = fromJSON(playlist.body)
# playlists <- (playlist.data$items) %>%
#   select(name, id)
# # 
# #plotly of year vs. popularity
# playlist.date.tracks <- data.frame(date = playlist.tracks$album$release_date, popularity = playlist.tracks$popularity)
# visual2 = plot_ly(data = playlist.date.tracks, x = ~date, y = ~popularity, type = 'scatter',
#         marker = list(size = 10,
#                       color = 'rgba(255, 182, 193, .9)',
#                       line = list(color = 'rgba(152, 0, 0, .8)',
#                                   width = 2))) %>%
#   layout(title = 'Popularity & Release Date',
#          yaxis = list(zeroline = FALSE),
#          xaxis = list(zeroline = FALSE))
# 
# 
# #get average popularity of songs in library
# playlist.pop.avg = round(sum(playlist.data$tracks$items$track$popularity)/(nrow(playlist.tracks)),2)
# 
# #get your listener persona based on average
# listener.persona = ""
# 
# if(playlist.pop.avg > 75){
#   listener.persona = "Mainstream"
# } else if(75 > playlist.pop.avg && playlist.pop.avg > 50){
#   listener.persona = "In-betweener"
# } else if(50 > playlist.pop.avg && playlist.pop.avg > 25){
#   listener.persona = "Underground"
# } else{
#   listener.persona = "Mongolian Throat Singing"
# }
# 
# #print their popularity of playlist
# print(paste0("Based on your tracks in playlist: ", playlist.data$name, ", we see that your songs had a ", playlist.pop.avg, "% popularity. As a result, you're a ", listener.persona, " listener."))
# 
