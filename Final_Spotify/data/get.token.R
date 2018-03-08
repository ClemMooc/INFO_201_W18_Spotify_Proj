spotify.client_id <- "140034d1ea6d4b2d9cb369aa69d63bb6"
spotify.secret <- "45a6d20a538d4ba083eb5f478b916c5b"

id_secret <- RCurl::base64(paste(spotify.client_id, spotify.secret, sep = ":"))

my_headers<-add_headers(c(Authorization=paste('Basic',id_secret,sep=' ')))

my_body<-list(grant_type='client_credentials')

spotify <- POST('https://accounts.spotify.com/api/token',
                my_headers,
                body = my_body,
                encode = 'form')
token <- content(spotify)

spotify.token <- token$access_token

#print(token)
