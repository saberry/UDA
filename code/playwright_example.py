from playwright.sync_api import sync_playwright, Playwright

pw = sync_playwright().start()

chrome = pw.chromium.launch(headless=False)

page = chrome.new_page()

page.goto("https://www.ultimate-guitar.com/explore?tonality[]=20")

key_content = page.locator('h1') 

key = key_content.inner_text()

page_content = page.locator('.LQUZJ')

text_contents = page_content.all_inner_texts()

output = []
for i in range(1, page_content.__len__()):
    row_info = text_contents[i]
    row_info = re.sub(r',', '', row_info)
    row_info = re.sub(r'\n', ',', row_info)        
    row_df = pd.read_csv(StringIO(row_info), header=None)
    if row_df.shape[1] == 4:
        row_df.columns = ['ARTIST', 'SONG', 'RATING', 'HITS']
    else:
        row_df.columns = ['ARTIST', 'SONG', 'HITS']
        row_df['RATING'] = np.nan
    output.append(row_df)


chrome.close()

pw.stop()