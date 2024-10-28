class SubscriptionPolicy < ApplicationPolicy
  def subscribe?
    user.present?
  end

  def create?
    user.present?
  end

  def destroy?
    record.user == user
  end
end
