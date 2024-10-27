require 'ffaker'

Rails.logger.info "Seeding database..."

def generate_with_retry(prompt_method, max_retries = 3, wait_time = 2)
  retries = 0

  begin
    result = prompt_method.call
    Rails.logger.debug "Generated result: #{result.inspect}"
    result
  rescue => e
    if (retries += 1) <= max_retries.to_i
      Rails.logger.warn "Retry ##{retries} due to error: #{e.message}. Retrying in #{wait_time} seconds..."
      sleep(wait_time)
      retry
    else
      Rails.logger.error "Failed after #{max_retries} retries: #{e.message}"
      nil
    end
  end
end

# Создаем пользователей
Rails.logger.info "Creating users..."

10.times do |n|
  user = User.create!(
    email: "user#{n + 1}@example.com",
    password: "password#{n + 1}",
    password_confirmation: "password#{n + 1}",
    confirmed_at: Time.now,
    name: FFaker::Name.name
  )
  Rails.logger.info "User #{user.email} created with name #{user.name}."
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
Rails.logger.info "Creating questions and answers..."

3.times do
  topic = topics.sample

  question_title = generate_with_retry(-> { OpenAiClient.generate_question("Create a question title 5-10 words related to #{topic} in a Q&A system.") })

  if question_title
    Rails.logger.info "Generated question title: #{question_title}"

    question_body = generate_with_retry(-> { OpenAiClient.generate_question("Provide question description for the question title: #{question_title}") })
    Rails.logger.info "Generated question body: #{question_body}"

    question = Question.create!(
      title: question_title,
      body: question_body,
      author: User.all.sample
    )
    Rails.logger.info "Question '#{question.title}' created by user #{question.author.email}."

    question.links.create!([
                             { name: 'Gist Link', url: GIST_URL },
                             { name: FFaker::Lorem.word, url: REAL_URLS.sample }
                           ])
    Rails.logger.info "Links created for question '#{question.title}'."

    [:short, :medium, :detailed].each do |length_type|
      answer_body = generate_with_retry(-> { OpenAiClient.generate_answer(question.title, length_type) })

      if answer_body
        answer = question.answers.create!(
          body: answer_body,
          author: User.all.sample
        )
        Rails.logger.info "Answer created for question '#{question.title}' by user #{answer.author.email}."

        answer.links.create!([
                               { name: 'Gist Link', url: GIST_URL },
                               { name: FFaker::Lorem.word, url: REAL_URLS.sample }
                             ])
        Rails.logger.info "Links created for answer to question '#{question.title}'."
      end
    end

    sleep(2)
  end
end

Rails.logger.info "Seeding complete!"
