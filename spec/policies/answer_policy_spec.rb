require 'rails_helper'

RSpec.describe AnswerPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:question) { create(:question, author: user) }
  let(:answer) { create(:answer, question: question, author: user) }

  subject { described_class }

  permissions ".scope" do
    it "returns all answers for a logged-in user" do
      expect(AnswerPolicy::Scope.new(user, Answer.all).resolve).to eq(Answer.all)
    end

    it "returns all answers for a guest" do
      expect(AnswerPolicy::Scope.new(nil, Answer.all).resolve).to eq(Answer.all)
    end
  end

  permissions :create? do
    it "grants access if user is logged in" do
      expect(subject).to permit(user, Answer.new)
    end

    it "denies access if user is not logged in" do
      expect(subject).not_to permit(nil, Answer.new)
    end
  end

  permissions :update?, :destroy? do
    it "grants access if the user is the author" do
      expect(subject).to permit(user, answer)
    end

    it "denies access if the user is not the author" do
      other_user = create(:user)
      expect(subject).not_to permit(other_user, answer)
    end
  end

end
