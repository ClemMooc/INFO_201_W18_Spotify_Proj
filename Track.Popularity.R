library('httr')
library('dplyr')
library('jsonlite')
library('httpuv')
library("ggplot2")

#setup
source('Final_Spotify/data/keys.R')
my_headers<-add_headers(c(Authorization=paste('Bearer',spotify.token,sep=' ')))

#user and playlist ID
user.id = "1262636354"
playlist.id = "4tz2nN7WoGGLvv7OBDDCDD"

#playlist request, takes user ID and public playlist ID
playlist.request = GET(paste0("https://api.spotify.com","/v1/users/",user.id,"/playlists/",playlist.id), my_headers)
playlist.body = content(playlist.request, "text")
playlist.data = fromJSON(playlist.body)
playlist.tracks = playlist.data$tracks$items$track

#ggplot of Tracks vs. Popularity. dataset = playlist.tracks
visual = function(dataset){
  ggplot(dataset, aes(x=name, y = popularity, color="orange")) +
    labs(x = "Tracks", y = "Popularity") +
    geom_point(stat = "identity", fill = "orange") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("Playlist tracks")
}

#get average popularity of songs in library
playlist.pop.avg = round(sum(playlist.data$tracks$items$track$popularity)/(nrow(playlist.tracks)),2)

#get your listener persona based on average
listener.persona = ""

if(playlist.pop.avg > 75){
  listener.persona = "Mainstream"
} else if(75 > playlist.pop.avg && playlist.pop.avg > 50){
  listener.persona = "In-betweener"
} else if(50 > playlist.pop.avg && playlist.pop.avg > 25){
  listener.persona = "Underground"
} else{
  listener.persona = "Mongolian Throat Singing"
}

#print their popularity of playlist
print(paste0("Based on your tracks in playlist: ", playlist.data$name, ", we see that your songs had a ", playlist.pop.avg, "% popularity. As a result, you're a ", listener.persona, " listener."))

