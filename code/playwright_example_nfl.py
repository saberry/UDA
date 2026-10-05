import pandas as pd
from playwright.sync_api import Page, expect, sync_playwright

with sync_playwright() as pw:
    browser = pw.chromium.launch(headless=False)
    context = browser.new_context(viewport={"width": 1920, "height": 1080})
    page = context.new_page()

    page.goto("https://nextgenstats.nfl.com/stats/receiving#yards")  
    page.wait_for_selector("table.el-table__header")  
    
    output = pd.read_html(page.content())
