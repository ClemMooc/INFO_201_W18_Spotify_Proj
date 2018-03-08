source('/Users/kristoferwong/Documents/INFO201Git/Final/Final_Spotify/data/get.token.R')
source('/Users/kristoferwong/Documents/INFO201Git/Final/Final_Spotify/data/Data_Wrangling.R')
library('fmsb')
song_info <- get.data.frame('12170429496', spotify.token)
View(song_info)
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
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))