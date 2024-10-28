class SubscriptionMailer < ApplicationMailer
  def new_answer_notification(answer, subscriber)
    @answer = answer
    @question = answer.question
    @subscriber = subscriber

    @answer_url = question_url(@question, anchor: "answer_#{@answer.id}")

    mail(
      to: @subscriber.email,
      subject: "New Answer to '#{@question.title}'"
    )
  end
end
