require 'rails_helper'

RSpec.describe SubscriptionMailer, type: :mailer do
  describe '#new_answer_notification' do
    let(:subscriber) { create(:user) }
    let(:question) { create(:question) }
    let(:answer) { create(:answer, question: question) }
    let(:mail) { SubscriptionMailer.new_answer_notification(answer, subscriber) }

    it 'renders the headers' do
      expect(mail.subject).to eq("New Answer to '#{question.title}'")
      expect(mail.to).to eq([subscriber.email])
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(answer.body)
      expect(mail.body.encoded).to include(question.title)
      expect(mail.body.encoded).to include(question_url(question, anchor: "answer_#{answer.id}"))
    end
  end
end
