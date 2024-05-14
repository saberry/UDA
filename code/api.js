let request = new XMLHttpRequest()
request.open("GET", "https://zippopotam.us/US/TX/Dallas")
request.send()
request.status
request.responseText

let output = [];

console.log(output);

fetch("https://api.openai.com/v1/chat/completions", {
  method: "POST",
  body: JSON.stringify({
    model: "gpt-3.5-turbo",
     messages: [{"role": "user", "content": "Tell me a funny joke, ideally dirty!"}],
     temperature: 0.7
  }),
  headers: {
    "Content-type": "application/json", 
    "Authorization": "Bearer " + my_key
  }
}).then((response) => response.json()).then((json) => output = json);

output;

console.log(output);

chat_result = output.choices[0].message.content.toString();

Qualtrics.SurveyEngine.addEmbeddedData("chat_result",  chat_result);