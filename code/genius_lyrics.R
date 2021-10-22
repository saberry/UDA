##############################
### Scraping Genius Lyrics ###
##############################

library(future)
library(furrr)
library(rvest)

load("data/genius_lyric_links.RData")

drop_cols <- c("song", "artist")

all_lyric_links <- all_lyric_links[, 
                                   -which(names(all_lyric_links) %in% drop_cols)]

all_lyric_links <- na.omit(all_lyric_links)

lyricGetter <- function(link, artist, song) {
  
  Sys.sleep(runif(1, .1, 1))
  
  out = tryCatch({
    
    lyrics <- read_html(link) |> 
      html_elements("#lyrics-root") |> 
      html_text()
    
    res <- data.frame(artist = artist, 
                      song = song,
                      lyrics = lyrics)
    
    return(res)
  }, error = function(e) {
    data.frame(artist = artist, 
               song = song,
               lyrics = NA)
  })
  
  return(out)
}

plan("future::multisession", workers = availableCores() - 1)

all_lyrics <- future_pmap_dfr(list(all_lyric_links$lyric_link, 
                                   all_lyric_links$searched_artist, 
                                   all_lyric_links$searched_song), 
                              lyricGetter, .progress = TRUE)

plan("sequential")

save(all_lyrics, file = "data/all_lyrics.RData")