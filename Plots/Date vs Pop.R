track_date_pop <-
  data.frame(
    date = song_info$year,
    popularity = song_info$popularity,
    name = song_info$name
  )
##
#  This requires the Data_Wrangling.R to create the year column. year can be replaced by release.date, but the plot looks way worse.
## 
start <-
  floor(min(track_date_pop$year)) - (floor(min(track_date_pop$year)) %% 5)

plot_ly(
  data = track_date_pop,
  x = ~ year,
  y = ~ popularity,
  marker = list(
    size = 10,
    color = 'rgba(255, 182, 193, .9)',
    line = list(color = 'rgba(152, 0, 0, .8)', width = 1)
  ),
  hoverinfo = 'text',
  text = ~ paste(name,
                 '\n Release Date: ', date,
                 '\n Popularity: ', popularity)
) %>%
  layout(
    title = 'How Obscure Is Your Music?',
    yaxis = list(zeroline = FALSE,
                 title = "Popularity from 0 to 100"),
    xaxis = list(
      autotick = FALSE,
      ticks = "outside",
      tick0 = start,
      dtick = 10,
      tickcolor = "black",
      title = "Release Date"
    ),
    titlefont = list(size = 15, color = "#fcfcfc"),
    plot_bgcolor = '#fcfcfc',
    paper_bgcolor = '#fcfcfc',
    width = 800,
    height = 450,
    font = list(color = "dark grey"),
    margin = list(
      l = 150,
      r = 20,
      b = 150,
      t = 50
    )
  )