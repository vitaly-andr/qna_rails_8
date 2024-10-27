require 'faraday'
require 'json'

class OpenAiClient
  def self.generate_answer(question_title, length_type)
    api_key = Rails.application.credentials.dig(:openai, :api_key)
    raise "OpenAI API key not configured" unless api_key

    prompt = "Provide a #{length_type} answer for the following question: #{question_title}"

    Rails.logger.debug "API Key is present, proceeding with request to OpenAI"
    Rails.logger.debug "Prompt for answer: #{prompt}"

    response = Faraday.post('https://api.openai.com/v1/chat/completions') do |req|
      req.headers['Authorization'] = "Bearer #{api_key}"
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        model: "gpt-4",
        messages: [
          { role: "system", content: "You are a helpful assistant." },
          { role: "user", content: prompt }
        ],
        max_tokens: 150, # можно увеличить для более длинных ответов
        temperature: 0.7
      }.to_json
    end

    Rails.logger.debug "OpenAI API response status: #{response.status}"
    Rails.logger.debug "OpenAI API response body: #{response.body}"

    if response.success?
      result = JSON.parse(response.body)
      content = result.dig("choices", 0, "message", "content")

      if content
        Rails.logger.info "Generated answer: #{content.strip}"
        content.strip
      else
        Rails.logger.warn "No content found in the response."
        nil
      end
    else
      Rails.logger.error "Error: #{response.status} - #{response.body}"
      nil
    end
  rescue => e
    Rails.logger.error "Exception occurred: #{e.message}"
    nil
  end
  def self.generate_question(prompt)
    api_key = Rails.application.credentials.dig(:openai, :api_key)
    raise "OpenAI API key not configured" unless api_key

    Rails.logger.debug "API Key is present, proceeding with request to OpenAI"
    Rails.logger.debug "Prompt: #{prompt}"

    response = Faraday.post('https://api.openai.com/v1/chat/completions') do |req|
      req.headers['Authorization'] = "Bearer #{api_key}"
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

    Rails.logger.debug "OpenAI API response status: #{response.status}"
    Rails.logger.debug "OpenAI API response body: #{response.body}"

    if response.success?
      result = JSON.parse(response.body)
      content = result.dig("choices", 0, "message", "content")

      if content
        Rails.logger.info "Generated content: #{content.strip}"
        content.strip
      else
        Rails.logger.warn "No content found in the response."
        nil
      end
    else
      Rails.logger.error "Error: #{response.status} - #{response.body}"
      nil
    end
  rescue => e
    Rails.logger.error "Exception occurred: #{e.message}"
    nil
  end
end
