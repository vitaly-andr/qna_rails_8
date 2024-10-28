require 'rails_helper'

RSpec.describe QuestionPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:question) { create(:question, author: user) }

  subject { described_class }

  permissions ".scope" do
    it "returns all questions for a logged-in user" do
      expect(QuestionPolicy::Scope.new(user, Question.all).resolve).to eq(Question.all)
    end

    it "returns all questions for a guest" do
      expect(QuestionPolicy::Scope.new(nil, Question.all).resolve).to eq(Question.all)
    end
  end


  permissions :create? do
    it "grants access if user is logged in" do
      expect(subject).to permit(user, Question.new)
    end

    it "denies access if user is not logged in" do
      expect(subject).not_to permit(nil, Question.new)
    end
  end

  permissions :update?, :destroy? do
    it "grants access if the user is the author" do
      expect(subject).to permit(user, question)
    end

    it "denies access if the user is not the author" do
      other_user = create(:user)
      expect(subject).not_to permit(other_user, question)
    end
  end

end
