class AnswerPolicy < ApplicationPolicy

  def create?
    user.present?
  end

  def update?
    user == record.author
  end

  def destroy?
    user == record.author
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
