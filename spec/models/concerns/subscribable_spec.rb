require 'rails_helper'

RSpec.describe 'Subscribable Concern', type: :model do
  let!(:user) { create(:user) }
  let!(:question) { create(:question) }

  describe '#subscribed?' do
    it 'returns false if the user is not subscribed' do
      expect(question.subscribed?(user)).to be_falsey
    end

    it 'returns true if the user is subscribed' do
      question.subscriptions.create(user: user)
      expect(question.subscribed?(user)).to be_truthy
    end
  end

  describe '#subscribers' do
    let!(:another_user) { create(:user) }

    it 'returns a list of unique subscribers' do
      question.subscriptions.create(user: user)
      question.subscriptions.create(user: another_user)

      expect(question.subscribers).to match_array([user, another_user])
    end
  end
end