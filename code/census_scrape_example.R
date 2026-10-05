library(rvest)

all_links <- read_html("https://www.census.gov/geographies/reference-files/time-series/geo/centers-population.html") %>% 
  html_elements("a[href*='_BG']") %>% 
  html_attr("href")

all_data <- purrr::map_df(all_links, ~data.table::fread(.x))



from bs4 import BeautifulSoup
import requests

census_link = requests.get("https://www.census.gov/geographies/reference-files/time-series/geo/centers-population.html")

census_soup = BeautifulSoup(census_link.content)

tract_links = census_soup.select("a[href*='_BG']")

links = []

for link in tract_links:
  links.append(link.get('href'))

frames = []

for link in links:
  df_out = pd.read_csv(link)
frames.append(df_out)

all_data = pd.concat(frames)  