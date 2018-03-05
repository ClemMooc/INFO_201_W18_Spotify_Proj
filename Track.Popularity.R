library('httr')
library('dplyr')
library('jsonlite')
library('httpuv')
library("ggplot2")
library("plotly")

#setup
spotify.token = "BQA0TAszmTxaa0itX8cH67cBONW_XPj7t8gCA1sdab5NQmBaJelhPN2ZiuQEYT2d4xc4U97WdF8N7BcSp6g"

source('Final_Spotify/data/keys.R')
my_headers<-add_headers(c(Authorization=paste('Bearer',spotify.token,sep=' ')))

#user and playlist ID
user.id = "1262636354"
playlist.id = "4tz2nN7WoGGLvv7OBDDCDD"

#playlist request, takes user ID and public playlist ID
playlist.request = GET(paste0("https://api.spotify.com","/v1/users/",user.id,"/playlists/",playlist.id), my_headers)
playlist.body = content(playlist.request, "text")
playlist.data = fromJSON(playlist.body)
playlist.tracks = as.data.frame(playlist.data$tracks$items$track)

    

#plotly of year vs. popularity
playlist.date.tracks <- data.frame(date = playlist.tracks$album$release_date, popularity = playlist.tracks$popularity)
visual2 = plot_ly(data = playlist.date.tracks, x = ~date, y = ~popularity, type = 'scatter',
        marker = list(size = 10,
                      color = 'rgba(255, 182, 193, .9)',
                      line = list(color = 'rgba(152, 0, 0, .8)',
                                  width = 2))) %>%
  layout(title = 'Popularity & Release Date',
         yaxis = list(zeroline = FALSE),
         xaxis = list(zeroline = FALSE))


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

