module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy
  end

  def rating
    votes.sum(:value)
  end

  def vote_by(user, value)
    Vote.transaction do
      cancel_vote_by(user)

      vote = votes.new(user: user, value: value)
      Pundit.authorize(user, vote, :create?)

      vote.save!
    end
  end

  def cancel_vote_by(user)
    vote = votes.find_by(user: user)
    if vote
      Pundit.authorize(user, vote, :destroy?)
      vote.destroy
    end
  end

  def voted_by?(user)
    votes.exists?(user: user)
  end

  def voted_value_by(user)
    votes.find_by(user: user)&.value
  end
end
