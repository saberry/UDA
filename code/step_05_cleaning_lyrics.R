#######################
### Cleaning Lyrics ###
#######################

library(stringdist)
library(stringr)

load("data/all_lyrics.RData")

lyric_cleaner <- function(lyrics) {
  song_lyrics <- gsub("([a-z])([A-Z])", "\\1 \\2", lyrics)
  
  song_lyrics <- gsub("\\[(.*?)\\]", " ", song_lyrics)
  
  song_lyrics <- gsub("([0-9]{1,}?)Embed.*", " ", song_lyrics)
  
  song_lyrics <- gsub("[[:punct:]]", "", song_lyrics)
  
  song_lyrics <- gsub("^\\s|\\s$|\\s{2, }", "", song_lyrics)
  
  song_lyrics <- tolower(song_lyrics)
  
  return(song_lyrics)
}

all_lyrics_info$lyrics <- lyric_cleaner(all_lyrics_info$lyrics)

all_lyrics_info$artist_dist <- stringdist(tolower(all_lyrics_info$searched_artist), 
                                          tolower(all_lyrics_info$returned_artist), 
                                          method = "jw")
