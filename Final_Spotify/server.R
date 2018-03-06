library('dplyr')
library('plotly')
library('httr')
library('openssl')

# Get Access Token
source('data/get.token.R')
my_headers<-add_headers(c(Authorization=paste('Bearer',spotify.token,sep=' ')))

server <- function(input, output) {
  
  df <- data.frame(
    group = c("Male", "Female", "Child"),
    value = c(25, 25, 50)
  )
  # observeEvent(input$action, {
  #   spotify_app <- oauth_app("Info_Spotify", key = spotify.client_id, secret = spotify.secret, redirect_uri = 'http://localhost:8888/callback')
  #   end <- oauth_endpoint(authorize = "https://accounts.spotify.com/authorize?client_id=9b82e79f3ec84c59986bf458d342b593&response_type=code&redirect_uri=http%3A%2F%2Flocalhost%3A8888%2Fcallback&scope=user-top-read",
  #                         access = "")
  #   x <- oauth2.0_token(end, app = spotify_app)
  # })
  observeEvent(input$action, {
    if(input$text == ""){
      output$name <- renderText({"Please Enter A Valid User ID"})
      
    } else {
      user <- GET(paste0("https://api.spotify.com/v1/users/", input$text), my_headers)
      user.data  <- fromJSON(content(user, "text"))
    
    if(!is.null(user.data$error$message)){
      output$name <- renderText({user.data$error$message})
    } else {
      output$name <- renderText({user.data$display_name})
    }
    }
    #output$Hi <- renderText({"hello"})
  })
  
 # xyz <- fromJSON(content(user_info, "text"))
  output$pieChart <- renderPlotly({
    
    plot_ly(df, labels = ~group, values = ~value, type = 'pie', height = 300, width = 275) %>%
      layout(title = 'Top 25 Artists', 
             font = list(size = 12, color = "white"), 
             plot_bgcolor='#222222', 
             paper_bgcolor='#222222',
             #width = 275,
             #height = 300,
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)
      )
     
  })
  
  
}