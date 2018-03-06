library('httr')
library('jsonlite')

spotify.client_id <- "9b82e79f3ec84c59986bf458d342b593"
spotify.secret <- "bd2fb69dd1ac4c54bc16704c4eed8100"

id_secret <- RCurl::base64(paste(spotify.client_id, spotify.secret, sep = ":"))

my_headers<-add_headers(c(Authorization=paste('Basic',id_secret,sep=' ')))

my_body<-list(grant_type='client_credentials')

spotify <- POST('https://accounts.spotify.com/api/token',
                my_headers,
                body = my_body,
                encode = 'form')
token <- content(spotify)

spotify.token <- token$access_token

print(spotify.token)
