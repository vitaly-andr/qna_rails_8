require 'rails_helper'

RSpec.describe VotePolicy, type: :policy do
  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:votable) { create(:question, author: author) }
  let(:vote) { create(:vote, votable: votable, user: user) }

  subject { described_class }

  permissions :create? do
    it "grants access if user is not the author of the votable" do
      expect(subject).to permit(user, vote)
    end

    it "denies access if user is the author of the votable" do
      expect(subject).not_to permit(author, vote)
    end
  end

  permissions :destroy? do
    it "grants access if the user created the vote" do
      expect(subject).to permit(user, vote)
    end

    it "denies access if the user did not create the vote" do
      another_user = create(:user)
      another_vote = create(:vote, votable: votable, user: another_user)
      expect(subject).not_to permit(user, another_vote)
    end
  end
end
