require 'rails_helper'

RSpec.shared_examples_for 'votable' do
  let(:model) { described_class } # Это позволит тестировать любую модель, подключающую концерт
  let(:user) { create(:user) }
  let(:votable) { create(model.to_s.underscore.to_sym) }

  describe '#rating' do
    it 'returns 0 if no votes' do
      expect(votable.rating).to eq 0
    end

    it 'returns sum of votes' do
      votable.votes.create!(value: 1, user: create(:user))
      votable.votes.create!(value: -1, user: create(:user))
      expect(votable.rating).to eq 0
    end
  end

  describe '#vote_by' do
    it 'creates a new vote' do
      expect { votable.vote_by(user, 1) }.to change(votable.votes, :count).by(1)
      expect(votable.votes.last.value).to eq 1
    end

    it 'updates an existing vote' do
      votable.vote_by(user, 1)
      votable.vote_by(user, -1)
      expect(votable.votes.count).to eq 1
      expect(votable.votes.last.value).to eq -1
    end
  end

  describe '#cancel_vote_by' do
    it 'removes the vote of the user' do
      votable.vote_by(user, 1)
      expect { votable.cancel_vote_by(user) }.to change(votable.votes, :count).by(-1)
    end
  end

  describe '#voted_by?' do
    it 'returns true if the user has voted' do
      votable.vote_by(user, 1)
      expect(votable.voted_by?(user)).to be true
    end

    it 'returns false if the user has not voted' do
      expect(votable.voted_by?(user)).to be false
    end
  end

  describe '#voted_value_by' do
    it 'returns the value of the vote if the user has voted' do
      votable.vote_by(user, 1)
      expect(votable.voted_value_by(user)).to eq 1
    end

    it 'returns nil if the user has not voted' do
      expect(votable.voted_value_by(user)).to be_nil
    end
  end
end
