source('/Users/kristoferwong/Documents/INFO201Git/Final/Final_Spotify/data/get.token.R')
source('/Users/kristoferwong/Documents/INFO201Git/Final/Final_Spotify/data/Data_Wrangling.R')
library('fmsb')
song_info <- get.data.frame('12170429496', spotify.token)

explicit.yes = (sum(song_info$explicit == "TRUE"))
explicit.no = (sum(song_info$explicit == "FALSE"))

explicit.df = data.frame("Explicit" = explicit.yes, "Clean" = explicit.no)
explicit.values = c(explicit.yes, explicit.no)
explicit.label = c(colnames(explicit.df)[1], colnames(explicit.df)[2])

pie <- plot_ly(data = explicit.df, labels = ~explicit.label, values = ~explicit.values, type = 'pie',
             textposition = 'inside',
             textinfo = 'label+percent',
             insidetextfont = list(color = "white"),
             marker = list(colors = c('#1DB954', 'black'), line = list(color = '#1DB954', width = 1))
) %>%
  layout(title = paste0('Ratio of Explicit and Non-Explicit tracks in Playlist'),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)) %>%
  config(displayModeBar = FALSE)

x <- mean(song_info$danceability) * 100
y <- mean(song_info$energy) * 100
z <- mean(song_info$valence) * 100
x_name <-"Danceablitiy"
y_name <-"Energy"
z_name <-"Valence"
df <- data.frame(x, y, z)
#colnames(df) <- c(x_name,y_name,z_name)

#Making Radar Chart
colnames(df) = c("Danceability" , "Enegy" , "Valence")

df = rbind(100, 0 , df)

radio <- radarchart(df, axistype=1 ,
                
                title = "Danceability VS Energy VS Valence",
                
                pcol=rgb(0.2,0.5,0.5,0.9) , pfcol=rgb(0.2,0.5,0.5,0.5) , plwd=4 ,
                
                #custom the grid
                cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,100,25), cglwd=0.8,
                
                #ustom labels
                vlcex=0.8
)