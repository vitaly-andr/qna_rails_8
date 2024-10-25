class ProfilePolicy < ApplicationPolicy
  def me?
    true
  end

  def index?
    user.present?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
