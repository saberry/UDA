from haystack.document_stores import InMemoryDocumentStore
from haystack import Document
from haystack.pipelines import Pipeline
from haystack.nodes import PromptNode 
from haystack.nodes import AnswerParser
from haystack.schema import Document



prompt_node = PromptNode(
  model_name_or_path="gpt-4", 
  api_key=API_KEY
  )

document_store = InMemoryDocumentStore(use_bm25=True)

add_example_data(
  document_store, "/Users/sethberry/Documents/UDA/data/last_statements"
  )
  
prompt_temp = PromptTemplate(
  prompt="Create an emotional last statement, but also make it defiant. "
            "Use only the  given documents for inspiration. "
            "Be emotional, occasionally funny, and possibly combative. Do not repeat text. "
            "{join(documents, delimiter=new_line, pattern=new_line+'Document[$idx]: $content', str_replace={new_line: ' ', '[': '(', ']': ')'})} \n Question: {query}; Answer: ",
            output_parser=AnswerParser(reference_pattern=r"Document\[(\d+)\]")
        )

result = prompt_node.prompt(query="Give me a last statement from someone who is innocent.", 
                            documents=document_store,
                            prompt_template=prompt_temp)

print(result)

result[0]
