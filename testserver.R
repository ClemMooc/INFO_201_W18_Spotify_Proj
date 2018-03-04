library('dplyr')
library('plotly')
library('httr')
library('openssl')

server <- function(input, output) {
  df <- data.frame(
    group = c("Male", "Female", "Child"),
    value = c(25, 25, 50)
  )
  observeEvent(input$action, {
 
    user_id <- input$text
    user_id <- 1262636354
    source('keys.R')
    my_headers<-add_headers(c(Authorization=paste('Bearer',spotify.token,sep=' ')))
    
    playlists_url <- paste0("https://api.spotify.com/v1/users/",user_id,"/playlists")
    x <- GET(playlists_url, my_headers)
    playlists <- fromJSON(content(x,"text"))
    playlist_id <- gsub(".*:","",playlists$items$uri[1])
    
    tracks_url <- paste0("https://api.spotify.com/v1/users/",user_id,"/playlists/",playlist_id,"/tracks")
    y <- GET( tracks_url, my_headers)
    tracks <- fromJSON(content(y, "text"))
    track_data <- as.data.frame(tracks$items$track)
    track_release_dates <- as.data.frame(track_data$album$release_date)
    track_date_pop <- data.frame(date = track_data$album$release_date, popularity = track_data$popularity)

    
    
  })
  
  output$scatter <- renderPlotly({
    plot_ly(data = track_date_pop, x = ~date, y = ~popularity, type = 'scatter',
            marker = list(size = 10,
                          color = 'rgba(255, 182, 193, .9)',
                          line = list(color = 'rgba(152, 0, 0, .8)',
                                      width = 2))) %>%
      layout(title = 'Popularity & Release Date',
             yaxis = list(zeroline = FALSE),
             xaxis = list(zeroline = FALSE))
  })
}
