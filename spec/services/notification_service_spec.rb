require 'rails_helper'

RSpec.describe NotificationService do
  describe '.call' do
    let!(:question) { create(:question) }
    let!(:subscribers) { create_list(:user, 5) }
    let!(:author) { create(:user) }
    before do
      ActionMailer::Base.deliveries.clear

      subscribers.each do |subscriber|
        create(:subscription, user: subscriber, subscribable: question)
      end
    end

    it 'sends notifications to all subscribers except the author of the answer' do
      expect(ActionMailer::Base.deliveries.count).to eq(0)
      answer = create(:answer, question: question, author: author)
      expect(ActionMailer::Base.deliveries.count).to eq(5)

      delivered_emails = ActionMailer::Base.deliveries.map(&:to)
      subscribers.each do |subscriber|
        expect(delivered_emails).to include([subscriber.email])
      end

      expect(delivered_emails).not_to include([author.email])
    end
  end
end

