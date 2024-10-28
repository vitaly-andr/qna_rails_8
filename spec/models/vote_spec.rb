require 'rails_helper'

RSpec.describe Vote, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:votable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:value) }
    it { should validate_inclusion_of(:value).in_array([-1, 1]) }

  end
end
