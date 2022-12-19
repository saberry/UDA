from bs4 import BeautifulSoup
import boto3
import pandas as pd
import requests

txex = requests.get("https://www.tdcj.texas.gov/death_row/dr_executed_offenders.html")

texas_soup = BeautifulSoup(txex.content)

image_links = texas_soup.select("a[href*='jpg']")

df_list = []

for links in image_links:
  result = pd.DataFrame(
    {'name': [links.get("title")], 
    'link': [links.get("href")]})
    
  df_list.append(result)
  
image_df = pd.concat(df_list)

image_df['name'] = image_df['name'].str.replace('Inmate Information for ', '')

image_df['link'] = "https://www.tdcj.texas.gov/death_row/" + image_df['link']

image_test = requests.get("https://www.tdcj.texas.gov/death_row/dr_info/_coble.jpg", verify=False)

imageBytes = bytearray(image_test.content)

textract = boto3.client('textract')

response = textract.detect_document_text(Document={'Bytes': imageBytes})

text = []
for item in response["Blocks"]:
    if item["BlockType"] == "LINE":
         text.append(item["Text"])

' '.join(text)
