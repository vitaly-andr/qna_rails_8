require 'rails_helper'

RSpec.describe DailyDigestMailer, type: :mailer do
  describe '#digest' do
    let(:user) { create(:user) }
    let(:questions) { create_list(:question, 3) }
    let(:mail) { DailyDigestMailer.digest(user, questions) }
    let(:url_helpers) { Rails.application.routes.url_helpers }

    it 'renders the headers' do
      expect(mail.subject).to eq('Your Daily Digest')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders the body' do
      questions.each do |question|
        expect(mail.body.encoded).to include(question.title)
        expect(mail.body.encoded).to include(url_helpers.question_url(question, host: 'localhost', port: 3000))
      end
    end
  end
end
