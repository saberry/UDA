
from openai import OpenAI
client = OpenAI(api_key = my_key)

completion = client.chat.completions.create(
  model="gpt-4",
  messages=[
    {"role": "system", "content": "You are a skilled data analyst who can write any code to solve problems"},
    {"role": "user", "content": "I need to access an API to get data from a website. Can you give me an example in Python?"},
  ]
)

print(completion.choices[0].message.content)


