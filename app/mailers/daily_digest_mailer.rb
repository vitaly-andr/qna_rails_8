class DailyDigestMailer < ApplicationMailer
  def digest(user, questions)
    @questions = questions
    mail(to: user.email, subject: 'Your Daily Digest')
  end
end