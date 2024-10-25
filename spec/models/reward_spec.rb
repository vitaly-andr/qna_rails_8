require 'rails_helper'

RSpec.describe Reward, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:image) }
  end

  describe 'associations' do
    it { should belong_to(:question) }
    it { should belong_to(:user).optional }
    it { should have_one_attached(:image) }
  end

  describe 'default attributes' do
    let(:reward) { build(:reward) }

    it 'is not assigned to a user initially' do
      expect(reward.user).to be_nil
    end
  end
end