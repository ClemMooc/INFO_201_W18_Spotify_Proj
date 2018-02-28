library('dplyr')
library('plotly')

server <- function(input, output) {
  df <- data.frame(
    group = c("Male", "Female", "Child"),
    value = c(25, 25, 50)
  )
  
  output$pieChart <- renderPlotly({
    
    plot_ly(df, labels = ~group, values = ~value, type = 'pie') %>%
      layout(title = 'Top 25 Artists', 
             font = list(size = 12, color = "white"), 
             plot_bgcolor='#222222', 
             paper_bgcolor='#222222',
             width = 275,
             height = 300,
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)
      )
     
    # ggplot(df, aes(x="", y=value, fill=group))+
    #   geom_bar(width = 1, stat = "identity") +
    #   coord_polar("y", start=0) +
    #   theme(plot.background = element_rect(fill = "#303030"))
  })
  output$pieChart2 <- renderPlotly({
    plot_ly(df, labels = ~group, values = ~value, type = 'pie') %>%
      layout(title = 'Genre',
             font = list(size = 12, color = "white"), 
             plot_bgcolor='#222222', 
             paper_bgcolor='#222222',
             width = 275,
             height = 300,
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)
      )
    })
}