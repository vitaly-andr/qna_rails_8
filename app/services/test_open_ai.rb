require 'faraday'
require 'json'

def generate_question(prompt)
  response = Faraday.post('https://api.openai.com/v1/chat/completions') do |req|
    req.headers['Authorization'] = "Bearer #{ENV['OPENAI_API_KEY']}"
    req.headers['Content-Type'] = 'application/json'
    req.body = {
      model: "gpt-4o-mini-2024-07-18",
      messages: [
        { role: "system", content: "You are a helpful assistant." },
        { role: "user", content: prompt }
      ],
      max_tokens: 100,
      temperature: 0.7
    }.to_json
  end

  if response.success?
    result = JSON.parse(response.body)
    # Access the content in the new response structure
    if result["choices"] && result["choices"][0]["message"]["content"]
      result["choices"][0]["message"]["content"].strip
    else
      puts "No content found in the response."
      nil
    end
  else
    puts "Error: #{response.status} - #{response.body}"
    nil
  end
end

# Test the function
puts generate_question("Create a question related to Ruby on Rails in a Q&A system.")
