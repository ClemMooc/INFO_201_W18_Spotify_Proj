library('httr')
library('jsonlite')

source('Final_Spotify/data/keys.R')

id_secret  <- RCurl::base64(paste(spotify.client_id, spotify.secret, sep = ":"))

my_headers<-add_headers(c(Authorization=paste('Basic',id_secret,sep=' ')))

my_body<-list(grant_type='client_credentials')

spotify <- POST('https://accounts.spotify.com/api/token',
                my_headers,
                body = my_body,
                encode = 'form')
token <- content(spotify)
print(token$access_token)
spotify.token <- token$access_token
