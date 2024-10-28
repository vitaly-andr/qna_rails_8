class DailyDigestJob < ApplicationJob
  queue_as :default

  def perform
    users = User.all
    questions = Question.where('created_at >= ?', 1.day.ago).map do |question|
      {
        title: question.title,
        url: Rails.application.routes.url_helpers.question_url(question, host: 'qna8.andrianoff.online')
      }
    end

    users.each do |user|
      DailyDigestMailer.digest(user, questions).deliver_later
    end
  end
end
