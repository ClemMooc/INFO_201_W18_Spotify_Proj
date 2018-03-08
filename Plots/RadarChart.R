# source("/Users/kristoferwong/Documents/INFO201Git/Final/Final_Spotify/data/Data_Wrangling.R")
# source("/Users/kristoferwong/Documents/INFO201Git/Final/Final_Spotify/data/get.token.R")
# song_info <- get.data.frame("12158467793", spotify.token)
# 
# d <- 5# mean(song_info$danceability) * 100
# e <- 6 #mean(song_info$energy) * 100
# v <- 12#mean(song_info$valence) * 100
# l <-  18#mean(song_info$loudness)
# t <- 10#mean(song_info$tempo) 
# 
# #df <- data.frame(d,e,v,l,t)
# 
# #colnames(df) = c("Danceability" , "Enegy" , "Valence", "Loudness", "Tempo")
# 
# #df = rbind(rep(100,50), rep(0,50) , df)
# 
# #par(bg = "#fcfcfc")
# #par(col.lab="black")
# p <- plot_ly(
#   type = 'scatterpolar',
#   r = c(d, e, v, l, t, d),
#   theta = c('A','B','C', 'D', 'E', 'A'),
#   fill = 'toself'
# ) %>%
#   layout(
#     polar = list(
#       radialaxis = list(
#         visible = TRUE,
#         range = c(0,30)
#       )
#     ),
#     showlegend = FALSE
#   )


p <- plot_ly(
  type = 'scatterpolar',
  fill = 'toself'
) %>%
  add_trace(
    r = c(39, 28, 8, 7, 28, 39),
    theta = c('A','B','C', 'D', 'E', 'A'),
    name = 'Group A'
  ) %>%
  add_trace(
    r = c(1.5, 10, 39, 31, 15, 1.5),
    theta = c('A','B','C', 'D', 'E', 'A'),
    name = 'Group B'
  ) %>%
  layout(
    polar = list(
      radialaxis = list(
        visible = T,
        range = c(0,50)
      )
    )
  )

# radarchart(df, axistype=1 ,
#            pcol=rgb(0.2,0.5,0.5,0.9), 
#            pfcol=rgb(0.2,0.5,0.5,0.5), 
#            plwd=4,
#            
#            #custom the grid
#            cglcol="dark grey", 
#            cglty=2, 
#            cglwd=0.8,
#            axislabcol = "dark grey",
#            #custom labels
#            vlcex=1
# ) 
# title(main="Danceability VS Energy VS Valence VS Loudness VS Tempo", col.main="black") 