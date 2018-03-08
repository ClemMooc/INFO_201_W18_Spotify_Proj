source("/Users/kristoferwong/Documents/INFO201Git/Final/Final_Spotify/data/Data_Wrangling.R")
source("/Users/kristoferwong/Documents/INFO201Git/Final/Final_Spotify/data/get.token.R")
songs <- get.data.frame("12158467793", spotify.token)
View(songs)