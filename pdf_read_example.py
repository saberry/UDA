import requests
import pandas as pd
match_link = "https://www.cagematch.net/?id=111&view=statistics"

pd.read_html(match_link, header = 0)

pip install camelot-py

import camelot
import pandas as pd
import re
from io import StringIO

abc = camelot.read_pdf("/Users/sethberry/Downloads/DRF2021Codebook.docx.pdf") 

from PyPDF2 import PdfReader 

pdf = PdfReader("/Users/sethberry/Downloads/untitled folder/DRF2021Codebook.docx.pdf")
# Decrease 1 from the actual page number
page = pdf.pages[173] 
text = page.extract_text() 
text = re.sub(r'\n(?=[0-9])', '_', text)
text = re.sub(r'(?<=[0-9])\n(?=[A-Z])', ':', text)
text = re.sub(r'\s', '', text)
text = re.sub(r'\n', ' ', text)
text = re.sub(r'([a-z])([A-Z])', '\\1 \\2', text)
text = re.sub(
  r'Appendix D:Universeof Doctorate Granting Institutionsfor_2021:SEDIPEDSIDInstitution Name_', 
  '', 
  text
)
text = re.sub('_', '\n', text)
text_pd = pd.read_csv(StringIO(text), sep=":")


numbers = [10, 20, 30, 40, 50]
for i, number in enumerate(numbers):
    if number % 4 == 0:
        continue
    print(i, number)
    
    
