require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:subscribable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:subscribable) }
  end

  describe 'subscription creation' do
    it 'allows creating a valid subscription' do
      user = create(:user)
      question = create(:question)
      subscription = Subscription.new(user: user, subscribable: question)

      expect(subscription).to be_valid
    end

    it 'does not allow duplicate subscriptions for the same user and subscribable' do
      user = create(:user)
      question = create(:question)
      Subscription.create!(user: user, subscribable: question)

      duplicate_subscription = Subscription.new(user: user, subscribable: question)
      duplicate_subscription.valid?

      expect(duplicate_subscription).not_to be_valid
      expect(duplicate_subscription.errors[:user_id]).to include('has already subscribed')
    end
  end
end
