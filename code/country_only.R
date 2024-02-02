library(rvest)
country_link <- "https://www.billboard.com/charts/country-songs/"

first_date <- as.Date("1970-01-01")

current_date <- Sys.Date()

saturday_dates <- seq.Date(first_date, current_date, by = "week")

general_scrape_function <- function(link) {
  
  # Never a bad idea to throw a little random time out in
  # when scraping a lot of links from the same place:
  
  Sys.sleep(runif(n = 1, min = 0, max = 1))
  # You need to be defensive when scraping a lot of links. 
  # One error and the whole thing crashes, so best to throw it
  # into an exception handler:
  try_out <- tryCatch({
    initial_read <- read_html(link)
    # We need to do some checking with what is in the link -- the layout varies
    # across different page types, so we need to be a bit defensive about it.
    
    # We will grab both layout types. One should return the proper length
    # and the other will be a nodeset of 0.
    
    hot_layout <- html_nodes(initial_read, ".chart-results-list")
    
    regular_layout <- html_nodes(initial_read, ".chart-list-item")
    
    if(length(hot_layout) != 0) {
      song <- initial_read |> 
        html_nodes("li.o-chart-results-list__item h3#title-of-a-story") |> 
        html_text()
      
      song <- gsub("\n|\t", "", song)
      
      artist <- initial_read |> 
        html_nodes("li.o-chart-results-list__item:first-child .c-label:last-child") |> 
        html_text()
      
      artist <- gsub("\n|\t", "", artist)
      
      artist <- artist[!grepl("RE-ENTRY|\\bNEW\\b", artist)]
      
      complete <- data.frame(song = song, 
                             artist = artist, 
                             link = link)
    } else {
      song <- regular_layout |> 
        html_nodes(".chart-list-item__title-text") |> 
        html_text()
      
      artist <- regular_layout |> 
        html_nodes(".chart-list-item__artist") |> 
        html_text()
      
      complete <- data.frame(song = song, 
                             artist = artist, 
                             link = link)
    }
    
    #return(complete)  
  }, error = function(e) {
    return(data.frame(song = NA, 
                      artist = NA, 
                      link = link))
  })
  return(try_out)  
}


weekly_links <- sapply(country_link, function(x) paste0(x, saturday_dates), 
                       simplify = TRUE)

general_scrape_function(weekly_links[[1]])

plan("future::multisession", workers = availableCores() - 1)

all_hot_songs <- future_map_dfr(unlist(weekly_links), general_scrape_function, 
                                .progress = TRUE)

all_goat_songs <- future_map_dfr(unlist(goat_links), general_scrape_function)

plan("sequential")

save(all_hot_songs, #all_goat_songs,
     file = "data/country_only_70_24.RData")

load("data/country_only_70_24.RData")

text_cleaning <- function(text_variable) {
  cleaning <- gsub("\n", "", text_variable)
  cleaning <- gsub("\\s{2,}", "", cleaning)
  clearning <- gsub("^\\s+|\\s+$", "", cleaning)
  return(cleaning)
}

all_hot_songs[, 
              colnames(all_hot_songs)] <- lapply(all_hot_songs, 
                                                 function(x) {
                                                   text_cleaning(x)
                                                 })

# When we scraped the data originally, we could have put 
# the genre and the date into the data. Instead, I tend
# to prefer to pull them out of a link. Purely a matter
# of preference, but I would opt to process on the back
# end, as opposed to handling it on the front.

all_hot_songs$week <- stringr::str_extract(all_hot_songs$link, "[0-9]{4}.*$")

# I'd like to make life easy, so I need to check something first:
# Does every link contain the word "-songs"?

sum(!is.na(all_hot_songs$link)) == sum(grepl("-songs", all_hot_songs$link))

# That returns a TRUE, so I can safely make that assumption
# and reduce my cleaning by a step

# Here is a compound look around.
# Look behind charts/ (but don't include it)
# Look ahead of -song (but don't include it)

all_hot_songs$genre <- stringr::str_extract(all_hot_songs$link, 
                                   "(?<=charts/).*(?=-song)")

save(all_hot_songs, 
     file = "data/country_only_70_24.RData")

load("data/country_only_70_24.RData")

text_cleaning <- function(text) {
  cleaned <- gsub("Featuring.*", 
                  "", 
                  text)
  cleaned <- gsub("[[:punct:]]", "", cleaned)
  cleaned <- gsub("^\\s|\\s$|\\s{2,}", "", cleaned)
  cleaned <- tolower(cleaned)
  cleaned <- gsub("\\s", "+", cleaned)
  return(cleaned)
}


all_hot_songs$clean_artist <- text_cleaning(all_hot_songs$artist)

all_hot_songs$clean_song <- text_cleaning(all_hot_songs$song)

all_hot_songs$artist_song_search <- paste(all_hot_songs$clean_artist, 
                                          all_hot_songs$clean_song, 
                                          sep = "+")

all_hot_songs_links <- all_hot_songs[!duplicated(all_hot_songs$artist_song_search), ]

lyric_links <- function(song, artist, search, original_link) {
  link <- paste0("https://genius.com/api/search/multi?per_page=1&q=", 
                 search)
  
  out <- tryCatch({
    Sys.sleep(runif(1, .1, .2))
    
    link_request <- GET(link)
    
    lyric_return <- jsonlite::fromJSON(content(link_request, as = "text"))
    
    lyric_path <- lyric_return$response$sections$hits[[1]]$result$path[1]
    
    lyric_link <- paste0("https://genius.com", lyric_path)[1]
    
    returned_artist <- 
      lyric_return$response$sections$hits[[1]]$result$primary_artist$name[1]
    
    returned_song <- lyric_return$response$sections$hits[[1]]$result$title[1]
    
    returned_data <- data.frame(searched_song = song, 
                                returned_song = returned_song, 
                                searched_artist = artist, 
                                returned_artist = returned_artist, 
                                lyric_link = lyric_link, 
                                original_link = original_link)
    
    return(returned_data)
  }, 
  error = function(e) {
    data.frame(searched_song = song, 
               returned_song = NA, 
               searched_artist = artist, 
               returned_artist = NA, 
               lyric_link = link, 
               original_link)
  })
  return(out)
}

debugonce(lyric_links)

lyric_links(all_hot_songs$song[10], 
            all_hot_songs$artist[10], 
            all_hot_songs$artist_song_search[10], 
            all_hot_songs$link[10])

plan("future::multisession", workers = availableCores())

all_lyric_links <- furrr::future_pmap_dfr(list(all_hot_songs_links$song, 
                                               all_hot_songs_links$artist, 
                                               all_hot_songs_links$artist_song_search, 
                                               all_hot_songs_links$link), 
                                          lyric_links, .progress = TRUE)

plan("sequential")

all_lyric_links <- na.omit(all_lyric_links)

all_lyric_links <- all_lyric_links[!duplicated(all_lyric_links$lyric_link), ]

all_lyric_links$distance <- stringdist::stringdist(
  tolower(all_lyric_links$searched_song), 
  tolower(all_lyric_links$returned_song), 
  method = "jw"
)

all_lyric_links <- all_lyric_links[all_lyric_links$distance <= 0.2800000, ]

save(all_hot_songs, all_lyric_links, 
     file = "data/country_only_70_24.RData")

load("data/country_only_70_24.RData")

all_lyric_links <- na.omit(all_lyric_links)

lyricGetter <- function(link, artist, song, og) {
  
  Sys.sleep(runif(1, .1, .3))
  
  out = tryCatch({
    
    lyrics <- read_html(link) |> 
      html_elements("#lyrics-root") |> 
      html_text()
    
    res <- data.frame(artist = artist, 
                      song = song,
                      lyrics = lyrics, 
                      link = link, 
                      og = og)
    
    return(res)
  }, error = function(e) {
    data.frame(artist = artist, 
               song = song,
               lyrics = NA, 
               link = link, 
               og = og)
  })
  
  return(out)
}

lyricGetter(
  all_lyric_links$lyric_link[20], 
  all_lyric_links$searched_artist[20], 
  all_lyric_links$searched_song[20], 
  all_lyric_links$original_link[20]
)

plan("future::multisession", workers = availableCores())

all_lyrics <- future_pmap_dfr(list(all_lyric_links$lyric_link, 
                                   all_lyric_links$searched_artist, 
                                   all_lyric_links$searched_song, 
                                   all_lyric_links$original_link), 
                              lyricGetter, .progress = TRUE)

plan("sequential")

save(all_lyrics, 
     file = "data/country_only_70_24.RData")

load("data/country_only_70_24.RData")


lyric_cleaner <- function(lyrics) {
  song_lyrics <- gsub("([a-z])([A-Z])", "\\1 \\2", lyrics)
  
  song_lyrics <- gsub("\\[(.*?)\\]", " ", song_lyrics)
  
  song_lyrics <- gsub("([0-9]{1,}?)Embed.*", " ", song_lyrics)
  
  song_lyrics <- gsub("[[:punct:]]", "", song_lyrics)
  
  song_lyrics <- gsub("^\\s|\\s$|\\s{2, }", "", song_lyrics)
  
  song_lyrics <- tolower(song_lyrics)
  
  return(song_lyrics)
}

artist_cleaner <- function(artist) {
  clean_artist <- gsub("^\\s|\\s$|\\s{2, }", "", artist)
  
  clean_artist <- tolower(clean_artist)
  
  return(clean_artist)
}

all_lyrics$lyrics <- lyric_cleaner(all_lyrics$lyrics)

all_lyrics$artist <- artist_cleaner(all_lyrics$artist)

save(all_lyrics, 
     file = "data/country_only_70_24.RData")
