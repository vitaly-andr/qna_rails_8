require 'rails_helper'

RSpec.describe RewardPolicy do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:reward) { create(:reward, user: user) }
  let!(:other_reward) { create(:reward, user: other_user) }

  subject { described_class }

  describe 'Scope' do
    it 'returns only rewards belonging to the user' do
      scope = Pundit.policy_scope(user, Reward)
      expect(scope).to include(reward)
      expect(scope).not_to include(other_reward)
    end

    it 'returns no rewards for unauthenticated user' do
      scope = Pundit.policy_scope(nil, Reward)
      expect(scope).to be_empty
    end
  end
end
