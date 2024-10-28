class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscribable, polymorphic: true

  validates :user, presence: true
  validates :subscribable, presence: true
  validates :user_id, uniqueness: { scope: [:subscribable_id, :subscribable_type], message: "has already subscribed" }

end
