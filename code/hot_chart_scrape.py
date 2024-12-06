from bs4 import BeautifulSoup
import pandas as pd
import requests

# Billboad Hot 100 can go back to 1950
# https://www.billboard.com/charts/hot-100/2024-11-16/

# R&B / HipHop can go back to 1960
# https://www.billboard.com/charts/r-b-hip-hop-songs/1960-11-09/

# Alternative can go to June 2020
# https://www.billboard.com/charts/hot-alternative-songs/2011-11-09/

# Christian can go to June 2003
# https://www.billboard.com/charts/christian-songs/1980-11-09/

# Country can go to 1960
# https://www.billboard.com/charts/country-songs/1960-11-09/

# Rock/Alternative can go to June 2009
# https://www.billboard.com/charts/rock-songs/2009-06-13/

headers = {
    'Host': 'www.billboard.com', 
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:130.0) Gecko/20100101 Firefox/130.0'
}

bb_req = requests.get('https://www.billboard.com/charts/hot-100/2024-11-16/', headers=headers)

bb_soup = BeautifulSoup(bb_req.content)



song = bb_soup.css.select(".o-chart-results-list-row-container ul.o-chart-results-list-row h3#title-of-a-story")
artist = bb_soup.css.select(".o-chart-results-list-row-container ul.o-chart-results-list-row h3#title-of-a-story+span.c-label")

def artist_song(soup):
    song = bb_soup.select(".o-chart-results-list-row-container ul.o-chart-results-list-row h3#title-of-a-story")
    song = [song[x].text for x in range(len(song))]
    artist = bb_soup.select(".o-chart-results-list-row-container ul.o-chart-results-list-row h3#title-of-a-story+span.c-label")
    artist = [artist[x].text for x in range(len(artist))]
    result = pd.DataFrame(data={'song': song, 'artist': artist})
    result['rank'] = range(1, len(result)+1)
    result['week'] = ""
    return result

artist_song(bb_soup)
