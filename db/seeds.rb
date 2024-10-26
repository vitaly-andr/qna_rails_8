require 'ffaker'
require 'openai'

Rails.logger.info "Seeding database..."

client = OpenAI::Client.new(
  access_token: Rails.application.credentials.dig(:openai, :api_key),
  log_errors: true
)

def generate_with_retry(client, prompt, max_retries = 3, wait_time = 2)
  retries = 0

  begin
    response = client.chat(parameters: prompt)
    response.dig("choices", 0, "message", "content").strip
  rescue => e
    if (retries += 1) <= max_retries
      Rails.logger.warn "Retry ##{retries} due to error: #{e.message}. Retrying in #{wait_time} seconds..."
      sleep(wait_time)
      retry
    else
      Rails.logger.error "Failed after #{max_retries} retries: #{e.message}"
      nil
    end
  end
end

def generate_question(client, topic)
  prompt = {
    model: "gpt-4",
    messages: [
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: "Create a question related to #{topic} in a Q&A system." }
    ],
    temperature: 0.7,
    max_tokens: 100
  }
  result = generate_with_retry(client, prompt)
  Rails.logger.info "Generated question: #{result}" if result
  result
end

def generate_answer(client, question_title, length_type)
  max_tokens = case length_type
                 when :short
                   50
                 when :medium
                   100
                 when :detailed
                   200
               end

  prompt = {
    model: "gpt-4",
    messages: [
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: "Provide a #{length_type} answer to the question: #{question_title}" }
    ],
    temperature: 0.7,
    max_tokens: max_tokens
  }

  result = generate_with_retry(client, prompt)
  Rails.logger.info "Generated answer (#{length_type}): #{result}" if result
  result
end

# Создаем пользователей
10.times do |n|
  User.create!(
    email: "user#{n + 1}@example.com",
    password: "password#{n + 1}",
    password_confirmation: "password#{n + 1}",
    confirmed_at: Time.now,
    name: FFaker::Name.name
  )
end

Rails.logger.info "10 users created with emails 'user1@example.com' - 'user10@example.com'."

topics = ['Ruby on Rails', 'Elasticsearch', 'Stimulus.js', 'Active Storage']

GIST_URL = 'https://gist.github.com/vitaly-andr/83bdcd7a1a1282cb17085714494ded2a'
REAL_URLS = [
  'https://www.rubyonrails.org/',
  'https://www.github.com/',
  'https://www.stackoverflow.com/',
  'https://guides.rubyonrails.org/',
  'https://www.google.com/'
]

# Генерация вопросов и ответов
3.times do
  question_title = generate_question(client, topics.sample)
  next unless question_title

  question_body = generate_question(client, "Provide more details about the question: #{question_title}")
  sleep(2)
  question = Question.create!(
    title: question_title,
    body: question_body,
    author: User.all.sample
  )

  question.links.create!([
                           { name: 'Gist Link', url: GIST_URL },
                           { name: FFaker::Lorem.word, url: REAL_URLS.sample }
                         ])

  [:short, :medium, :detailed].each do |length_type|
    answer_body = generate_answer(client, question.title, length_type)
    next unless answer_body

    answer = question.answers.create!(
      body: answer_body,
      author: User.all.sample
    )

    answer.links.create!([
                           { name: 'Gist Link', url: GIST_URL },
                           { name: FFaker::Lorem.word, url: REAL_URLS.sample }
                         ])
  end

  sleep(2)
end

Rails.logger.info "Seeding complete!"
