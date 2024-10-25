require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of :email }
  it { should validate_presence_of :password }
  describe '#author_of?' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:question) { create(:question, author: user) }
    let(:answer) { create(:answer, author: user) }

    it 'returns true if user is the author of the resource' do
      expect(user.author_of?(question)).to be true
      expect(user.author_of?(answer)).to be true
    end

    it 'returns false if user is not the author of the resource' do
      expect(other_user.author_of?(question)).to be false
      expect(other_user.author_of?(answer)).to be false
    end
  end
end
