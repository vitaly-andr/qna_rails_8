require 'faraday'
require 'json'

class OpenAiClient
  def self.generate_question(prompt)
    api_key = Rails.application.credentials.dig(:openai, :api_key)
    raise "OpenAI API key not configured" unless api_key

    response = Faraday.post('https://api.openai.com/v1/chat/completions') do |req|
      req.headers['Authorization'] = "Bearer #{api_key}"
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        model: "gpt-4",
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
      if result.dig("choices", 0, "message", "content")
        Rails.logger.info "Generated content: #{result.dig('choices', 0, 'message', 'content').strip}"
        result.dig("choices", 0, "message", "content").strip
      else
        Rails.logger.warn "No content found in the response."
        nil
      end
    else
      Rails.logger.error "Error: #{response.status} - #{response.body}"
      nil
    end
  end
end
