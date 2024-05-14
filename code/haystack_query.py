# pip install farm-haystack

from io import StringIO
import os
import pandas as pd

from haystack.document_stores import InMemoryDocumentStore
from haystack.utils import build_pipeline, add_example_data, print_answers

provider = "openai"

document_store = InMemoryDocumentStore(use_bm25=True)

add_example_data(document_store, "/Users/sethberry/Documents/UDA/data/last_statements")

pipeline = build_pipeline(provider, API_KEY, document_store)

result = pipeline.run(query="Why are people sorry?")

print_answers(result, details="medium")
