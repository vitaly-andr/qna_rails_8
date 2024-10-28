module Subscribable
  extend ActiveSupport::Concern

  included do
    has_many :subscriptions, as: :subscribable, dependent: :destroy
    has_many :users, through: :subscriptions, source: :user
  end

  def subscribed?(user)
    subscriptions.exists?(user: user)
  end

  def subscribers
    users.distinct
  end
end
