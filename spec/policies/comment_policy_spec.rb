require 'rails_helper'

RSpec.describe CommentPolicy do
  let(:user) { create(:user) }
  let(:commentable) { create(:question) } # Assuming comments can be added to a question
  let(:comment) { create(:comment, commentable: commentable, author: user) }

  subject { described_class }

  permissions :create? do
    context "when the user is logged in" do
      it "grants access to create a comment" do
        expect(subject).to permit(user, comment)
      end
    end

    context "when the user is not logged in" do
      it "denies access to create a comment" do
        expect(subject).not_to permit(nil, comment) # Expect no access for guests
      end
    end
  end
end
