d <- mean(song_info$danceability) * 100
e <- mean(song_info$energy) * 100
v <- mean(song_info$valence) * 100
l <- mean(song_info$loudness)
t <- mean(song_info$tempo) 

df <- data.frame(d,e,v,l,t)

colnames(df) = c("Danceability" , "Enegy" , "Valence", "Loudness", "Tempo")

df = rbind(rep(100,50), rep(0,50) , df)

par(bg = "#fcfcfc")
par(col.lab="black")
radarchart(df, axistype=1 ,
           pcol=rgb(0.2,0.5,0.5,0.9), 
           pfcol=rgb(0.2,0.5,0.5,0.5), 
           plwd=4,
           
           #custom the grid
           cglcol="dark grey", 
           cglty=2, 
           cglwd=0.8,
           axislabcol = "dark grey",
           #custom labels
           vlcex=1
) 
title(main="Danceability VS Energy VS Valence VS Loudness VS Tempo", col.main="black") 