
![](http://www.josesep.nl/wp-content/uploads/2017/06/spotify-logo.png)


# About SpotR

**SpotR** [SpotR App Link](https://ktwong27.shinyapps.io/final_spotify/) is an interactive web application that creates visual graphics out of your playlist data. 

In order to view graphics of your own music playlist data, enter your Spotify user ID (URI) under the 'Your Music' tab. These graphics serve as a visualization of how different aspects of the user's music consumption have changed over the course of their Spotify subscription. You may change how many of the past years of data is used in creating the graphics by moving the slider. The slider defaults at 12 years, which is how old Spotify is. With this app, we give Spotify users **the power to visualize their music playlist consumption.**

 To get the data for this app, we directly source the [Spotify Web Api](https://developer.spotify.com/web-api/) for track and playlist data. 

 Through the Spotify Web Api, we are able to source:

- Artists
- Playlists
- Tracks
- Release Date
- Explicit/Non-Explicit
- Advanced audio analysis

# How it Works

We utilized the **HTTR**, **JSONLITE**, and **DPLYR** packages to access, retrieve, and wrangle the Spotify data. By compiling data frames with song and playlist info, we then utilized packages **PLOTLY** and **FMSB** to generate standard data charts (scatterplots and pie charts), and more sophisticated charts that required more than 2 lists of data (radar charts). Finally, with the **SHINY** package, we compiled everything up to make our data interactive with users.

# How to get user URI  

On the spotify desktop application:
1. Go to User page, which can be found my searching for a specific user or through the signed-in account.
2. Select the ellipses, click share, and copy spotify URI
3. Your user ID is everything after the second colon.  

On iOS mobile application:
1. Select settings
2. Select account

# The Team
- **Kris Wong**  

- **Clem Mooc**  

- **Thomas Penner**  

- **Gyubeom (Jason) Kim**  
